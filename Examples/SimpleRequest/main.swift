//
//  main.swift
//  SimpleRequests
//
//  Created by Gurlanka, Bhargav (Agoda) on 30/06/17.
//  Copyright © 2017 Gurlanka, Bhargav (Agoda). All rights reserved.
//

import Foundation
import Request
import Result


let result = get(url: "https://httpbin.org")

switch result {
case let .success(response):
    print("Got response: ")
    print(response)
case let .failure(error):
    print("Failed with error: ")
    print(error)
}

