import XCTest
import Result
@testable import Request

class SessionRequestGenerationTests: XCTestCase {
    func testGET() {
        let params = Params(
            headers: ["X-foo": "foo", "X-bar": "1&2 %"],
            queryItems: ["foo": "bar", "baz": "1&2 %"],
            body: .none
        )

        let result = try! Session().requestFor(
            method: .get,
            url: "/get",
            relativeTo: URL(string: "https://httpbin.org"),
            params: params
        )

        guard let request = result.value else {
            XCTFail("Expected to have request")
            return
        }

        XCTAssertEqual(request.httpMethod, "GET")
        XCTAssertEqual(request.url?.absoluteString, "https://httpbin.org/get?baz=1%262%20%25&foo=bar")
        XCTAssertEqual(request.allHTTPHeaderFields ?? [:], [
            "X-foo": "foo",
            "X-bar": "1&2 %",
        ])

        XCTAssertNil(request.httpBody)
    }

    func testPOST() {
        let params = Params(
            headers: ["foo": "bar", "baz": "1&2 %", "X-BAR": " bar "],
            queryItems: ["foo": "bar", "baz": "1&2 %"],
            body: .jsonObject(["f": 2, "fo": "bar", "foo": [ "baz": false ], "baz": [1, 2, 3]])
        )
        let result = try! Session().requestFor(
            method: .post,
            url: "/post",
            relativeTo: URL(string: "https://httpbin.org"),
            params: params
        )

        guard let request = result.value else {
            XCTFail("Expected to have request")
            return
        }

        XCTAssertEqual(request.httpMethod, "POST")
        XCTAssertEqual(request.url?.absoluteString, "https://httpbin.org/post?baz=1%262%20%25&foo=bar")
        XCTAssertEqual(request.allHTTPHeaderFields ?? [:], [
            "Content-Type": "application/json",
            "foo": "bar",
            "baz": "1&2 %",
            "X-BAR": " bar ",
        ])

        let expectedBody = try! JSONSerialization.data(withJSONObject: ["f": 2, "fo": "bar", "foo": [ "baz": false ], "baz": [1, 2, 3]])
        XCTAssertEqual(request.httpBody, expectedBody)
    }

    static var allTests = [
        ("testGET",  testGET),
        ("testPOST", testPOST),
    ]
}
