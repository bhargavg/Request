import Foundation
import Result

public struct Response {
    public let statusCode: Int
    public let headerFields: [String: String]
    public let data: Data
}

