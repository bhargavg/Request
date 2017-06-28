// swift-tools-version:3.1

import PackageDescription

let package = Package(
    name: "Request",
    dependencies: [
        .Package(url: "https://github.com/antitypical/Result", majorVersion: 3, minor: 2)
    ]
)
