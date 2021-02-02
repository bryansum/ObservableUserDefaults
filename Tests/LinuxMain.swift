import XCTest

import ObservableUserDefaultsTests

var tests = [XCTestCaseEntry]()
tests += UserDefaultsStringTests.allTests()
XCTMain(tests)
