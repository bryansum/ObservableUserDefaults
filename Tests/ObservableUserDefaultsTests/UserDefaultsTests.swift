// Copyright (c) 2020 Bryan Summersett

import ObservableUserDefaults
import Combine
import XCTest

final class UserDefaultsStringTests: XCTestCase {
  @UserDefault(name: "testName") private var userDefault: String?
  private var cancellables = Set<AnyCancellable>()

  override func setUp() {
    userDefault = nil
  }

  override func tearDown() {
    cancellables.removeAll()
    values = []
    completion = nil
  }

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

  private var completion: Subscribers.Completion<Never>?
  private var values: [String?] = []

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

private extension UserDefaultsStringTests {
  func makeValueSink() {
    $userDefault
      .sink { [unowned self] value in
        values.append(value)
      }
      .store(in: &cancellables)
  }

  func makeSubscriber(demand: Subscribers.Demand) -> (AnySubscriber<String?, Never>) {
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
