import Result

fileprivate let sharedSession = try? Session()

public func get(
   url: String,
   params: Params = .default
) -> Result<Response, SessionError> {
    guard let session = sharedSession else {
        return .failure(.invalidSession)
    }

    return session.get(
        url: url,
        params: params
    )
}

public func get(
    url: String,
    params: (Params.Builder) -> ()
) -> Result<Response, SessionError> {
    guard let session = sharedSession else {
        return .failure(.invalidSession)
    }

    return session.get(
        url: url,
        params: params
    )
}

public func post(
    url: String,
    params: Params = .default
) -> Result<Response, SessionError> {
    guard let session = sharedSession else {
        return .failure(.invalidSession)
    }

    return session.post(
        url: url,
        params: params
    )
}

public func post(
    url: String,
    params: (Params.Builder) -> ()
) -> Result<Response, SessionError> {
    guard let session = sharedSession else {
        return .failure(.invalidSession)
    }

    return session.post(
        url: url,
        params: params
    )
}
