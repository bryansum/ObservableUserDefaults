// Copyright (c) 2020 Bryan Summersett

import ObservableUserDefaults
import Combine
import XCTest

class UserDefaultsTests<Value>: XCTestCase {
  @UserDefault(name: "testName") var userDefault: Value?
  var cancellables = Set<AnyCancellable>()

  var completion: Subscribers.Completion<Never>?
  var values: [Value?] = []

  override func setUp() {
    userDefault = nil
  }

  override func tearDown() {
    cancellables.removeAll()
    values = []
    completion = nil
  }
}

extension UserDefaultsTests {
  func makeValueSink() {
    $userDefault
      .sink { [unowned self] value in
        values.append(value)
      }
      .store(in: &cancellables)
  }

  func makeSubscriber(demand: Subscribers.Demand) -> (AnySubscriber<Value?, Never>) {
    var subscription_ = Subscription?.none // hold until complete
    _ = subscription_ // fix Swift warnings
    return AnySubscriber(receiveSubscription: { subscription in
                           subscription_ = subscription
                           subscription.request(demand)
                         },
                         receiveValue: { value in
                           self.values.append(value)
                           return .none
                         },
                         receiveCompletion: { finished in
                           subscription_ = nil
                           self.completion = finished
                         })
  }
}
