// Copyright (c) 2020 Bryan Summersett

import ObservableUserDefaults
import Combine
import XCTest

final class UserDefaultsStringTests: UserDefaultsTests<String> {
  func testPublisherNoOp() throws {
    makeValueSink()
    userDefault = nil
    XCTAssertEqual(values, [nil])
  }

  func testPublisherInitialValue() throws {
    userDefault = "InitialValue"
    makeValueSink()
    XCTAssertEqual(values, ["InitialValue"])
  }

  func testPublisherOnSet() throws {
    makeValueSink()
    userDefault = "NewValue"

    XCTAssertEqual(values, [nil, "NewValue"])
  }

  func testPublisherOnUnset() throws {
    userDefault = "InitialValue"
    makeValueSink()
    userDefault = nil
    XCTAssertEqual(values, ["InitialValue", nil])
  }

  func testPublisherInitialValueThenSet() throws {
    userDefault = "InitialValue"
    makeValueSink()
    userDefault = "NewValue"
    XCTAssertEqual(values, ["InitialValue", "NewValue"])
  }

  func testSubscribeNoDemand() {
    userDefault = "InitialValue"
    let publisher = $userDefault
    let subscriber = makeSubscriber(demand: .none)
    publisher.subscribe(subscriber)

    userDefault = "NewValue"

    XCTAssertEqual(completion, nil)
    XCTAssertEqual(values, [])
  }

  func testSubscribeUnlimitedDemand() {
    userDefault = "InitialValue"
    let publisher = $userDefault
    let subscriber = makeSubscriber(demand: .unlimited)
    publisher.subscribe(subscriber)

    userDefault = "NewValue"

    XCTAssertEqual(completion, nil)
    XCTAssertEqual(values, ["InitialValue", "NewValue"])
  }

  func testSubscribeMax1Demand() {
    userDefault = "InitialValue"
    let publisher = $userDefault
    let subscriber = makeSubscriber(demand: .max(1))
    publisher.subscribe(subscriber)

    userDefault = "NewValue"

    XCTAssertEqual(completion, nil)
    XCTAssertEqual(values, ["InitialValue"])
  }
}
