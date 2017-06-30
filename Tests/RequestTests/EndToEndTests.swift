import XCTest
import Result
@testable import Request

class EndToEndTests: XCTestCase {
    func testSimpleGET() {
        let result = get(url: "https://httpbin.org/get")

        switch result {
        case let .success(response):
            XCTAssertEqual(200, response.statusCode)
        case let .failure(error):
            XCTFail("Failed with error: \(error)")
        }
    }

    func testSimplePOST() {
        let result = post(url: "https://httpbin.org/post")

        switch result {
        case let .success(response):
            XCTAssertEqual(200, response.statusCode)
        case let .failure(error):
            XCTFail("Failed with error: \(error)")
        }
    }

    func testGET() {
        let result = get(
            url: "https://httpbin.org/get",
            params: [
                "foo": "bar",
                "2": "%@#^)",
                "c": "2",
            ],
            headers: [
                "X-Custom-Header": "foo bar"
            ]
        )

        switch result {
        case let .success(response):
            XCTAssertEqual(200, response.statusCode)

            guard let binResponse = HTTPBinResponse(data: response.data) else {
                XCTFail("Invalid HTTPBinResponse")
                return
            }

            let expectedHeaders = [
                "X-Custom-Header": "foo bar"
            ]
            for (key, value) in expectedHeaders {
                XCTAssertEqual(binResponse.headers[key], value)
            }

            XCTAssertEqual(binResponse.args, ["2": "%@#^)", "c": "2", "foo": "bar"])
            XCTAssertEqual(binResponse.url, "https://httpbin.org/get?2=%25%40%23^)&c=2&foo=bar")

        case let .failure(error):
            XCTFail("Failed with error: \(error)")
        }
    }

    func testPOST() {
        let result = post(
            url: "https://httpbin.org/post",
            params: [
                "foo": "bar",
                "2": "%@#^)",
                "c": "2",
            ],
            headers: [
                "X-Custom-Header": "foo bar"
            ],
            body: .jsonObject([
                "foo": "bar"
            ])
        )

        switch result {
        case let .success(response):
            XCTAssertEqual(200, response.statusCode)
            guard let binResponse = HTTPBinResponse(data: response.data) else {
                XCTFail("Invalid HTTPBinResponse")
                return
            }

            let expectedHeaders = [
                "X-Custom-Header": "foo bar"
            ]
            for (key, value) in expectedHeaders {
                XCTAssertEqual(binResponse.headers[key], value)
            }

            XCTAssertEqual(binResponse.args, ["2": "%@#^)", "c": "2", "foo": "bar"])
            XCTAssertEqual(binResponse.url, "https://httpbin.org/post?2=%25%40%23^)&c=2&foo=bar")
            XCTAssertEqual(binResponse.data, "{\"foo\":\"bar\"}")

        case let .failure(error):
            XCTFail("Failed with error: \(error)")
        }
    }

    static var allTests = [
        ("testSimpleGET",  testSimpleGET),
        ("testSimplePOST",  testSimplePOST),
    ]
}

