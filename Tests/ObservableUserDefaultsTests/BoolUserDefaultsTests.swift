// Copyright (c) 2020 Bryan Summersett

import ObservableUserDefaults
import Combine
import XCTest

class BoolUserDefaultsTests: XCTestCase {
  @UserDefault(name: "testName") var userDefault: Bool?
  var cancellables = Set<AnyCancellable>()

  var completion: Subscribers.Completion<Never>?
  var values: [Bool?] = []

  override func setUp() {
    userDefault = nil
  }

  override func tearDown() {
    cancellables.removeAll()
    values = []
    completion = nil
  }

  func testConvertsBool() {
    makeValueSink()
    UserDefaults.standard.setValue("true", forKey: "testName")
    UserDefaults.standard.setValue("false", forKey: "testName")
    UserDefaults.standard.setValue(true, forKey: "testName")
    UserDefaults.standard.setValue("nil", forKey: "testName")

    XCTAssertEqual(values, [true, false, true, nil])
  }
}

extension BoolUserDefaultsTests {
  func makeValueSink() {
    $userDefault
      .sink { [unowned self] value in
        values.append(value)
      }
      .store(in: &cancellables)
  }
}
