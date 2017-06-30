import Foundation

struct HTTPBinResponse {
    let args: [String: String]
    let headers: [String: String]
    let data: String?
    let origin: String
    let url: String

    init?(data: Data) {
        guard let mayBeDict = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
              let dict = mayBeDict else {
            return nil
        }

        guard let args = dict["args"] as? [String: String] else {
            return nil
        }

        guard let headers = dict["headers"] as? [String: String] else {
            return nil
        }

        guard let origin = dict["origin"] as? String else {
            return nil
        }

        guard let url = dict["url"] as? String else {
            return nil
        }

        self.args = args
        self.headers = headers
        self.origin = origin
        self.url = url
        self.data = dict["data"] as? String
    }
}

