
public struct Params {
    let headers: [String: String]
    let queryItems: [String: String]
    let body: Session.Body

    static var `default` = Params(headers: [:], queryItems: [:], body: .none)

    public init(
        headers: [String: String],
        queryItems: [String: String],
        body: Session.Body
    ) {
        self.headers = body.additionalHeaders.merge(with: headers)
        self.queryItems = queryItems
        self.body = body
    }

    func merging(sessionHeaders: [String: String]) -> Params {
        let allHeaders = sessionHeaders.merge(with: headers)

        return Params(
            headers: allHeaders,
            queryItems: queryItems,
            body: body
        )
    }


    public class Builder {
        public var headers: [String: String] = [:]
        public var queryItems: [String: String] = [:]
        public var body: Session.Body = .none

        public func build() -> Params {
            return Params(
                headers: headers,
                queryItems: queryItems,
                body: body
            )
        }
    }
}
