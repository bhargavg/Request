//
//  HTTPBinResponse.swift
//  SampleResponseParsing
//
//  Created by Gurlanka, Bhargav (Agoda) on 30/06/17.
//  Copyright © 2017 Gurlanka, Bhargav (Agoda). All rights reserved.
//

import Foundation
import Request
import Result

struct HTTPBinResponse {
    let args: [String: String]
    let headers: [String: String]
    let data: String?
    let origin: String
    let url: String

    static func from(response: Response) -> Result<HTTPBinResponse, InstantiationError> {
        guard let mayBeDict = try? JSONSerialization.jsonObject(with: response.data) as? [String: Any],
            let dict = mayBeDict else {
                return .failure(.invalidResponse)
        }

        guard let args = dict["args"] as? [String: String] else {
            return .failure(.invalidResponse)
        }

        guard let headers = dict["headers"] as? [String: String] else {
            return .failure(.invalidResponse)
        }

        guard let origin = dict["origin"] as? String else {
            return .failure(.invalidResponse)
        }

        guard let url = dict["url"] as? String else {
            return .failure(.invalidResponse)
        }

        return .success(HTTPBinResponse(
            args: args,
            headers: headers,
            data: dict["data"] as? String,
            origin: origin,
            url: url
        ))
    }

    enum InstantiationError: Error {
        case sessionError(SessionError)
        case invalidResponse
    }
}
