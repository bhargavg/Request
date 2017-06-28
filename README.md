# Request
A Result'ified `URLSession` wrapped, designed to be used for CLI scripts

# Development Status
Still in pre-alpha

# Usage

```Swift
let value = try! Session().post(
    url: "https://httpbin.org/post",
    headers: [
        "X-Foo": "Bar"
    ]
).mapError({ _ in ParseError.invalidResponse })
 .flatMap(PostResult.from(response:))

print(type(of: value))


/// A data model to hold the response
struct PostResult {
    let origin: String
    let url: String
    let headers: [String: String]

    static func from(
        response: Response
    ) -> Result<PostResult, ParseError> {

        guard let dict = try? JSONSerialization.jsonObject(with: response.data),
              let jsonDict = dict as? [String: Any] else {
            return .failure(.invalidJSON)
        }

        guard let origin = jsonDict["origin"] as? String else {
            return .failure(.invalidJSON)
        }

        guard let url = jsonDict["url"] as? String else {
            return .failure(.invalidJSON)
        }

        guard let headers = jsonDict["headers"] as? [String: String] else {
            return .failure(.invalidJSON)
        }

        return .success(
            PostResult(
                origin: origin,
                url: url,
                headers: headers
            )
        )
    }
}

enum ParseError: Error {
    case invalidResponse
    case invalidJSON
}
```
