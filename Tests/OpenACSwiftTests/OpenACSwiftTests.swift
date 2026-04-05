import Foundation
import Testing
@testable import OpenACSwift

private enum TestSupport {
    static var testBundle: Bundle { Bundle.module }

    /// Matches app-style usage: keys and artifacts use the TestVectors directory as the documents root.
    static var documentsPath: String {
        (testBundle.bundlePath as NSString).appendingPathComponent("TestVectors")
    }

    static var bundledInputJSONPath: String? {
        testBundle.path(forResource: "input", ofType: "json", inDirectory: "TestVectors")
    }
}

// Serialized so tests don't race on the shared documentsPath (keys, proof files written there).
@Suite(.serialized)
struct OpenACSwiftTests {

    @Test func setupKeysSucceedsWithBundleDocumentsPathAndBundledInput() async throws {
        let inputPath = try #require(
            TestSupport.bundledInputJSONPath,
            "TestVectors/input.json must be copied into the test bundle (see Package.swift resources)."
        )

        let message = try setupKeys(
            documentsPath: TestSupport.documentsPath,
            inputPath: inputPath
        )

        #expect(!message.isEmpty, "setupKeys should return a non-empty status string.")
    }

    @Test func setupKeysSucceedsWithMissingInputFile() async throws {
        let missingInput = (NSTemporaryDirectory() as NSString)
            .appendingPathComponent("openac-missing-input-\(UUID().uuidString).json")

        let message = try setupKeys(
            documentsPath: TestSupport.documentsPath,
            inputPath: missingInput
        )

        #expect(!message.isEmpty, "setupKeys should succeed even when inputPath points to a missing file.")
    }

    @Test func proveReturnsValidResultWithBundledInput() async throws {
        let inputPath = try #require(
            TestSupport.bundledInputJSONPath,
            "TestVectors/input.json must be copied into the test bundle (see Package.swift resources)."
        )

        _ = try setupKeys(documentsPath: TestSupport.documentsPath, inputPath: inputPath)

        let result = try prove(documentsPath: TestSupport.documentsPath, inputPath: inputPath)

        #expect(result.proveMs > 0, "Proof generation should take measurable time.")
        #expect(result.proofSizeBytes > 0, "Proof should have a non-zero size.")
    }

    @Test func proveAndVerifySucceed() async throws {
        let inputPath = try #require(
            TestSupport.bundledInputJSONPath,
            "TestVectors/input.json must be copied into the test bundle (see Package.swift resources)."
        )

        _ = try setupKeys(documentsPath: TestSupport.documentsPath, inputPath: inputPath)
        _ = try prove(documentsPath: TestSupport.documentsPath, inputPath: inputPath)

        let valid = try verify(documentsPath: TestSupport.documentsPath)

        #expect(valid, "Verification should succeed after a valid prove call.")
    }
}
