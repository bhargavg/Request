import Result

fileprivate let sharedSession = try? Session()

public func get(
   url: String,
   params: [String: String] = [:],
   headers: [String: String] = [:]
) -> Result<Response, SessionError> {
    guard let session = sharedSession else {
        return .failure(.invalidSession)
    }

    return session.get(
        url: url,
        params: params,
        headers: headers
    )
}

public func post(
    url: String,
    params: [String: String] = [:],
    headers: [String: String] = [:],
    body: Session.Body = .none
) -> Result<Response, SessionError> {
    guard let session = sharedSession else {
        return .failure(.invalidSession)
    }

    return session.post(
        url: url,
        params: params,
        body: body,
        headers: headers
    )
}

