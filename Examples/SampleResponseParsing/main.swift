//
//  main.swift
//  SampleResponseParsing
//
//  Created by Gurlanka, Bhargav (Agoda) on 30/06/17.
//  Copyright © 2017 Gurlanka, Bhargav (Agoda). All rights reserved.
//

import Foundation
import Result
import Request

let result = post(
    url: "https://httpbin.org/post",
    params: [:],
    headers: [:],
    body: .jsonArray(["foo", "bar"])
).mapError({ .sessionError($0) })
 .flatMap(HTTPBinResponse.from(response:))

print(result.value ?? "Failed with error")
