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

    public func post( url: String, headers: [String: String] = [:]) -> Result<Response, SessionError> {
        return request(
            method: .post,
            url: url,
            relativeTo: baseURL,
            baseHeaders: self.headers,
            additionalHeaders: headers
        )
    }

    public func get(url: String, headers: [String: String] = [:]) -> Result<Response, SessionError> {
        return request(
            method: .get,
            url: url,
            relativeTo: baseURL,
            baseHeaders: self.headers,
            additionalHeaders: headers
        )
    }

    public func head(url: String, headers: [String: String] = [:]) -> Result<Response, SessionError> {
        return request(
            method: .head,
            url: url,
            relativeTo: baseURL,
            baseHeaders: self.headers,
            additionalHeaders: headers
        )
    }

    public func delete(url: String, headers: [String: String] = [:]) -> Result<Response, SessionError> {
        return request(
            method: .delete,
            url: url,
            relativeTo: baseURL,
            baseHeaders: self.headers,
            additionalHeaders: headers
        )
    }

    public func patch(url: String, headers: [String: String] = [:]) -> Result<Response, SessionError> {
        return request(
            method: .patch,
            url: url,
            relativeTo: baseURL,
            baseHeaders: self.headers,
            additionalHeaders: headers
        )
    }

    public func request(
        method: HTTPMethod,
        url: String,
        relativeTo baseURL: URL?,
        baseHeaders: [String: String],
        additionalHeaders: [String: String]
    ) -> Result<Response, SessionError> {

        guard let endpoint = URL(string: url, relativeTo: baseURL) else {
            return .failure(.invalidURL)
        }

        var request = URLRequest(url: endpoint)
        request.httpMethod = method.rawValue
        for headers in [baseHeaders, additionalHeaders] {
            for (key, value) in headers {
                request.setValue(value, forHTTPHeaderField: key)
            }
        }

        var sessionError: NSError? = nil
        var statusCode: Int? = nil
        var responseData: Data? = nil
        var responseHeaders: [String: String]? = nil
        urlSession.dataTask(with: request, completionHandler: { (data, response, error) in
            defer {
                self.singleResourceSemaphore.signal()
            }

            sessionError = error.map({ $0 as NSError })
            let response = response as? HTTPURLResponse

            statusCode = response?.statusCode
            responseHeaders = response?.allHeaderFields as? [String: String]
            responseData = data ?? Data()
        }).resume()

        singleResourceSemaphore.wait()

        switch (sessionError, statusCode, responseHeaders, responseData) {
        case let (.some(error), _, _, _):
            return .failure(.error(error))
        case let(.none, .some(code), .some(headers), .some(data)):
            return .success(Response(statusCode: code, headerFields: headers, data: data))
        default:
            return .failure(.invalidResponse)
        }
    }

    public enum HTTPMethod: String {
        case get    = "GET"
        case post   = "POST"
        case head   = "HEAD"
        case put    = "PUT"
        case delete = "DELETE"
        case patch  = "PATCH"
    }
}


public enum SessionError: Error {
    case invalidURL
    case invalidResponse
    case error(NSError)
}

