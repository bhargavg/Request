import XCTest
@testable import RequestTests

XCTMain([
    testCase(SessoinRequestGenerationTests.allTests),
    testCase(EndToEndTests.allTests),
])
