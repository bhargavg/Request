import Foundation
import Result

public struct Response {
    public let statusCode: Int
    public let headerFields: [String: String]
    public let data: Data
}

extension Response: Equatable {
    public static func == (lhs: Response, rhs: Response) -> Bool {
        return (lhs.statusCode == rhs.statusCode)
                && (lhs.headerFields == rhs.headerFields)
                && (lhs.data == rhs.data)
    }
}
