import XCTest

extension XCTest {
    var bundlePath: String {
        for bundle in Bundle.allBundles where bundle.bundlePath.hasSuffix(".xctest") {
            return bundle.bundlePath
        }

        fatalError("Cannot get the bundle path")
    }
}

