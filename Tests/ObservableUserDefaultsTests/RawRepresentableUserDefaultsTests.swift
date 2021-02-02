// Copyright (c) 2020 Bryan Summersett

import ObservableUserDefaults
import Combine
import XCTest

class RawRepresentableUserDefaultsTests: XCTestCase {

  enum IntEnum: Int {
    case one = 1
    case two = 2
  }

  @UserDefault(name: "testName") var userDefault: IntEnum?
  var cancellables = Set<AnyCancellable>()

  var completion: Subscribers.Completion<Never>?
  var values: [IntEnum?] = []

  override func setUp() {
    userDefault = nil
  }

  override func tearDown() {
    cancellables.removeAll()
    values = []
    completion = nil
  }

  func testConvertsEnum() {
    makeValueSink()
    UserDefaults.standard.setValue("1", forKey: "testName")
    UserDefaults.standard.setValue("2", forKey: "testName")

    UserDefaults.standard.setValue("3", forKey: "testName")
    UserDefaults.standard.setValue("nonsense", forKey: "testName")

    UserDefaults.standard.setValue(1, forKey: "testName")
    UserDefaults.standard.setValue(2, forKey: "testName")

    XCTAssertEqual(values, [.one, .two,
                            nil, nil,
                            .one, .two])
  }
}

extension RawRepresentableUserDefaultsTests {
  func makeValueSink() {
    $userDefault
      .sink { [unowned self] value in
        values.append(value)
      }
      .store(in: &cancellables)
  }
}
