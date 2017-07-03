import Foundation
import Result

public struct Session {
    let urlSession: URLSession
    let baseURL: URL?
    let headers: [String: String]
    let singleResourceSemaphore: DispatchSemaphore

    public init(
        baseURL: String? = nil,
        urlSession: URLSession = URLSession.shared,
        headers: [String: String] = [:]
    ) throws {
        if let baseURL = baseURL {
            guard let url = URL(string: baseURL) else {
                throw SessionError.invalidURL
            }
            self.baseURL = url
        } else {
            self.baseURL = nil
        }

        self.urlSession = urlSession
        self.headers = headers
        self.singleResourceSemaphore = DispatchSemaphore(value: 0)
    }

    public func post(
        url: String,
        params: (Params.Builder) -> ()
    ) -> Result<Response, SessionError> {

        let builder = Params.Builder()
        params(builder)

        return post(url: url, params: builder.build())
    }

    public func post(
        url: String,
        params: Params = Params.default
    ) -> Result<Response, SessionError> {
        let fullParams = params.merging(sessionHeaders: headers)

        return requestFor(
            method: .post,
            url: url,
            relativeTo: baseURL,
            params: fullParams
        ).flatMap(exec(request:))
    }

    public func get(
        url: String,
        params: Params = Params.default
    ) -> Result<Response, SessionError> {
        return requestFor(
            method: .get,
            url: url,
            relativeTo: baseURL,
            params: params
        ).flatMap(exec(request:))
    }

    public func get(
        url: String,
        params: (Params.Builder) -> ()
    ) -> Result<Response, SessionError> {
        let builder = Params.Builder()
        params(builder)

        return get(url: url, params: builder.build())
    }

    public func requestFor(
        method: HTTPMethod,
        url: String,
        relativeTo baseURL: URL?,
        params: Params
    ) -> Result<URLRequest, SessionError> {

        guard let endpoint = URL(string: url, relativeTo: baseURL) else {
            return .failure(.invalidURL)
        }

        guard var components = URLComponents(url: endpoint, resolvingAgainstBaseURL: true) else {
            return .failure(.invalidURL)
        }

        components.queryItems = params.queryItems.map({ URLQueryItem(name: $0, value: $1) })

        guard let finalURL = components.url else {
            return .failure(.invalidURL)
        }

        var request = URLRequest(url: finalURL)
        request.httpMethod = method.rawValue

        for (key, value) in params.headers {
            request.setValue(value, forHTTPHeaderField: key)
        }

        let requestBody: Data?
        switch params.body {
        case .none:
            requestBody = nil
            break
        case let .jsonObject(obj):
            guard let data = try? JSONSerialization.data(withJSONObject: obj as NSDictionary, options: []) else {
                return .failure(.invalidBody)
            }

            requestBody = data
        case let .jsonArray(array):
            guard let data = try? JSONSerialization.data(withJSONObject: array, options: []) else {
                return .failure(.invalidBody)
            }
            requestBody = data
        case let .custom(data):
            requestBody = data
        case .formEncoded:
            requestBody = nil
            fatalError("Not implemented")
        }

        request.httpBody = requestBody

        return .success(request)
    }

    public func exec(request: URLRequest) -> Result<Response, SessionError> {
        var status: Result<Response, SessionError> = .failure(.invalidResponse)
        urlSession.dataTask(with: request, completionHandler: { (data, response, error) in
            defer {
                self.singleResourceSemaphore.signal()
            }

            if let error = error {
                status = .failure(.error(error as NSError))
                return
            }

            guard let response = response as? HTTPURLResponse,
                  let data = data else {
                status = .failure(.invalidResponse)
                return
            }

            status = .success(
                Response(
                    statusCode: response.statusCode,
                    headerFields: response.allHeaderFields as? [String: String] ?? [:],
                    data: data
                )
            )
        }).resume()

        singleResourceSemaphore.wait()

        return status
    }

    public enum HTTPMethod: String {
        case get    = "GET"
        case post   = "POST"
        case head   = "HEAD"
        case put    = "PUT"
        case delete = "DELETE"
        case patch  = "PATCH"
    }

    public enum Body {
        case none
        case jsonObject([String: Any])
        case jsonArray([Any])
        case formEncoded([String: String])
        case custom(Data)

        var additionalHeaders: [String: String] {
            switch self {
            case .jsonObject, .jsonArray:
                return ["Content-Type": "application/json"]
            case .formEncoded:
                return ["Content-Type": "application/x-www-form-urlencoded"]
            case .custom, .none:
                return [:]
            }
        }
    }
}


public enum SessionError: Error {
    case invalidURL
    case invalidBody
    case invalidResponse
    case invalidSession
    case error(NSError)
}

