# Request
A Result'ified `URLSession` wrapped, designed to be used for CLI scripts

# Development Status
Still in pre-alpha

# Usage

###### A simple GET request

```Swift
let result = get(url: "https://httpbin.org/get")
```

###### A simple POST request
```Swift
let result = post(url: "https://httpbin.org/post")
```

###### Analyzing the result
```Swift
let result = post(url: "https://httpbin.org/post")

switch result {
case let .success(response):
  print("Got response: \(response)")
case let .failure(error):
  print("Failed with error: \(error)")
}
```

###### Parsing the response to a model object
```Swift
/// Errors
enum InstantiationError: Error {
    case sessionError(SessionError)
    case invalidResponse
}

/// Model
struct HTTPBinResponse {
    let url: String
    let origin: String

    static func from(response: Response) -> Result<HTTPBinResponse, InstantiationError> {
        guard let mayBeDict = try? JSONSerialization.jsonObject(with: response.data) as? [String: Any],
            let dict = mayBeDict else {
                return .failure(.invalidResponse)
        }

        guard let origin = dict["origin"] as? String else {
            return .failure(.invalidResponse)
        }

        guard let url = dict["url"] as? String else {
            return .failure(.invalidResponse)
        }

        return .success(HTTPBinResponse(url: url, origin: origin))
    }
}


/// Make the request and try to parse the response to model
let result = post(
    url: "https://httpbin.org/post",
    params:  [:],
    headers: [:],
    body: .jsonArray(["foo", "bar"])
).mapError({ .sessionError($0) })
 .flatMap(HTTPBinResponse.from(response:))

/// Analyze the response
switch result {
case let .success(model):
    print("Parsed to model: \(model)")
case let .failure(error):
    print("Failed with error: \(error)")
}
```

