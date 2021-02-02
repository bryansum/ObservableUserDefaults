// Copyright (c) 2020 Bryan Summersett

import Combine
import Foundation

@propertyWrapper
public struct UserDefault<Value> {
  public var name: String
  public var get: () -> Value?
  public var set: (Value?) -> Void

  public var wrappedValue: Value? {
    get {
      get()
    }
    nonmutating set {
      set(newValue)
    }
  }

  public var projectedValue: AnyPublisher<Value?, Never> {
    publisher(self)
  }

  var publisher = { (userDefault: UserDefault<Value>) -> AnyPublisher<Value?, Never> in
    ValuePublisher(userDefault: userDefault).eraseToAnyPublisher()
  }
}

extension UserDefault {
  struct ValuePublisher: Publisher {
    typealias Output = Value?
    typealias Failure = Never

    let userDefault: UserDefault<Value>

    func receive<S>(subscriber: S) where S: Subscriber, Self.Failure == S.Failure, Self.Output == S.Input {
      let subscription = ValueSubscription(userDefault: userDefault, subscriber: subscriber)
      subscriber.receive(subscription: subscription)
    }
  }

  final class ValueSubscription<S: Subscriber>: Subscription where S.Input == Value?, S.Failure == Never {
    private var disposables = [Any]()
    var subscriber: S?
    var userDefault: UserDefault
    var value: Value??
    var demand = Subscribers.Demand.none

    init(userDefault: UserDefault, subscriber: S) {
      self.userDefault = userDefault
      self.subscriber = subscriber
      disposables.append(Foundation.UserDefaults.standard.observe(keyPath: userDefault.name, options: [.initial, .new]) { [unowned self] (value: Value?) in
        self.value = value
        sendIfNeeded()
      })
    }

    func request(_ demand: Subscribers.Demand) {
      self.demand += demand
      sendIfNeeded()
    }

    private func sendIfNeeded() {
      if demand > .none, let value = value, let subscriber = subscriber {
        demand += subscriber.receive(value)
        demand -= 1
      }
    }

    func cancel() {
      subscriber = nil
      disposables.removeAll()
    }
  }
}

public extension UserDefault where Value == String {
  init(name: String) {
    self.name = name
    get = { Foundation.UserDefaults.standard.string(forKey: name) }
    set = { Foundation.UserDefaults.standard.setValue($0, forKey: name) }
  }
}

public extension UserDefault where Value == Bool {
  init(name: String) {
    self.name = name
    get = { Foundation.UserDefaults.standard.bool(forKey: name) }
    set = { Foundation.UserDefaults.standard.setValue($0, forKey: name) }
  }
}

public extension UserDefault where Value: RawRepresentable, Value.RawValue == String {
  init(name: String) {
    self.name = name
    get = { Foundation.UserDefaults.standard.string(forKey: name).flatMap(Value.init(rawValue:)) }
    set = { Foundation.UserDefaults.standard.setValue($0?.rawValue, forKey: name) }
  }
}

public extension UserDefault where Value: RawRepresentable, Value.RawValue == Int {
  init(name: String) {
    self.name = name
    get = { Value(rawValue: Foundation.UserDefaults.standard.integer(forKey: name)) }
    set = { Foundation.UserDefaults.standard.setValue($0?.rawValue, forKey: name) }
  }
}

public extension UserDefault {
  init(name: String) {
    self.name = name
    get = { Foundation.UserDefaults.standard.object(forKey: name) as? Value }
    set = { Foundation.UserDefaults.standard.setValue($0, forKey: name) }
  }
}

public extension UserDefault {
  static func constant(name: String = "constant", _ value: Value?) -> Self {
    Self(name: name,
         get: { value },
         set: { _ in },
         publisher: { _ in
           Optional.Publisher(value).eraseToAnyPublisher()
         })
  }
}
