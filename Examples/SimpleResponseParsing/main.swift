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

do {
    let result = post(url: "https://httpbin.org/post", params: {
        $0.body = .jsonArray(["foo", "bar"])
    }).mapError({ .sessionError($0) })
      .flatMap(HTTPBinResponse.from(response:))

    print(result.value ?? "Failed with error")
}


do {
    let result = get(url: "https://httpbin.org/get", params: {
        $0.queryItems = ["bar": "foo"]
        $0.headers = ["X-Foo": "Bar"]
    }).mapError({ .sessionError($0) })
      .flatMap(HTTPBinResponse.from(response:))

    print(result.value ?? "Failed with error")
}
