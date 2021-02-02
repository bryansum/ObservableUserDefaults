// Copyright (c) 2020 Bryan Summersett

import Foundation

extension NSObject {
  func observe<Value>(keyPath: String, type _: Value.Type? = nil, options: NSKeyValueObservingOptions = [.new], completion: @escaping (Value?) -> Void) -> Any {
    let observer = KeyValueObserver<Value>(object: self, keyPath: keyPath, options: options) { value in
      completion(value)
    }
    return Disposable { observer.invalidate() }
  }
}

private final class KeyValueObserver<Value>: NSObject {
  public init(object: NSObject,
              keyPath: String,
              options: NSKeyValueObservingOptions,
              callback: @escaping (Value?) -> Void)
  {
    self.object = object
    self.keyPath = keyPath
    self.callback = callback
    self.options = options
    super.init()
    object.addObserver(self, forKeyPath: keyPath, options: options, context: &context)
  }

  deinit {
    invalidate()
  }

  func invalidate() {
    if !invalidated {
      invalidated = true
      object.removeObserver(self, forKeyPath: keyPath, context: &context)
    }
  }

  override func observeValue(forKeyPath keyPath: String?,
                             of object: Any?,
                             change: [NSKeyValueChangeKey: Any]?,
                             context: UnsafeMutableRawPointer?)
  {
    if context == &self.context, keyPath == self.keyPath, let change = change {
      let key: NSKeyValueChangeKey = options.contains(.new) ? .newKey : .oldKey
      switch change[key] {
      case is NSNull:
        callback(nil)
      case let value as Value?:
        callback(value)
      default:
        fatalError("Unexpected value")
      }
    } else {
      super.observeValue(forKeyPath: keyPath, of: object, change: change, context: context)
    }
  }

  private var invalidated = false
  private var context = 0 // Values don't really matter. Only address is important.
  private let object: NSObject
  private let keyPath: String
  private let callback: (Value?) -> Void
  private let options: NSKeyValueObservingOptions
}
