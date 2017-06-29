import XCTest
import Result
@testable import Request

class RequestGenerationTests: XCTestCase {
    func testGET() {
        let result = try! Session().requestFor(
            method: .get,
            url: "/get",
            params: [
                "foo": "bar",
                "baz": "1&2 %"
            ],
            relativeTo: URL(string: "https://httpbin.org"),
            baseHeaders: [
                "X-foo": "foo",
                "X-bar": "1&2 %"
            ],
            additionalHeaders: [
                "X-BAR": " bar "
            ],
            body: .none
        )

        guard let request = result.value else {
            XCTFail("Expected to have request")
            return
        }

        XCTAssertEqual(request.httpMethod, "GET")
        XCTAssertEqual(request.url?.absoluteString, "https://httpbin.org/get?baz=1%262%20%25&foo=bar")
        XCTAssertEqual(request.allHTTPHeaderFields ?? [:], [
            "X-foo": "foo",
            "X-BAR": " bar ",
        ])

        XCTAssertNil(request.httpBody)
    }

    func testPOST() {
        let result = try! Session().requestFor(
            method: .post,
            url: "/post",
            params: [
                "foo": "bar",
                "baz": "1&2 %"
            ],
            relativeTo: URL(string: "https://httpbin.org"),
            baseHeaders: [
                "X-foo": "foo",
                "X-bar": "1&2 %"
            ],
            additionalHeaders: [
                "X-BAR": " bar "
            ],
            body: .jsonObject([
                "f": 2,
                "fo": "bar",
                "foo": [
                    "baz": false
                ],
                "baz": [1, 2, 3]
            ])
        )

        guard let request = result.value else {
            XCTFail("Expected to have request")
            return
        }

        XCTAssertEqual(request.httpMethod, "POST")
        XCTAssertEqual(request.url?.absoluteString, "https://httpbin.org/post?baz=1%262%20%25&foo=bar")
        XCTAssertEqual(request.allHTTPHeaderFields ?? [:], [
            "X-foo": "foo",
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
