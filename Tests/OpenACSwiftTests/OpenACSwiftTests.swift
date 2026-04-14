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

  static var bundledProvingKeyPath: String? {
    testBundle.path(forResource: "rs256_4096_proving", ofType: "key", inDirectory: "TestVectors")
  }

  static var bundledVerifyingKeyPath: String? {
    testBundle.path(forResource: "rs256_4096_verifying", ofType: "key", inDirectory: "TestVectors")
  }

  static var bundledResponseJSONPath: String? {
    testBundle.path(forResource: "response_sign", ofType: "json", inDirectory: "TestVectors")
  }

  static var bundledFidoResponseJSONPath: String? {
    testBundle.path(forResource: "fido_response_sign", ofType: "json", inDirectory: "TestVectors")
  }

  static var bundledMOICA_G3CertPath: String? {
    testBundle.path(forResource: "MOICA-G3", ofType: "cer", inDirectory: "TestVectors")
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

    let message = try setupKeysFido(
      documentsPath: TestSupport.documentsPath,
      inputPath: inputPath
    )

    #expect(!message.isEmpty, "setupKeysFido should return a non-empty status string.")
  }

  @Test func setupKeysSucceedsWithMissingInputFile() async throws {
    let missingInput = (NSTemporaryDirectory() as NSString)
      .appendingPathComponent("openac-missing-input-\(UUID().uuidString).json")

    let message = try setupKeysFido(
      documentsPath: TestSupport.documentsPath,
      inputPath: missingInput
    )

    #expect(
      !message.isEmpty, "setupKeysFido should succeed even when inputPath points to a missing file.")
  }

  @Test func proveReturnsValidResultWithBundledInput() async throws {
    let inputPath = try #require(
      TestSupport.bundledInputJSONPath,
      "TestVectors/input.json must be copied into the test bundle (see Package.swift resources)."
    )

    _ = try setupKeysFido(documentsPath: TestSupport.documentsPath, inputPath: inputPath)

    let result = try proveFido(documentsPath: TestSupport.documentsPath, inputPath: inputPath)

    #expect(result.proveMs > 0, "Proof generation should take measurable time.")
    #expect(result.proofSizeBytes > 0, "Proof should have a non-zero size.")
  }

  @Test func proveAndVerifySucceed() async throws {
    let inputPath = try #require(
      TestSupport.bundledInputJSONPath,
      "TestVectors/input.json must be copied into the test bundle (see Package.swift resources)."
    )

    _ = try proveFido(documentsPath: TestSupport.documentsPath, inputPath: inputPath)

    let valid = try verifyFido(documentsPath: TestSupport.documentsPath)

    #expect(valid, "Verification should succeed after a valid proveFido call.")
  }

  // @Test func generateInputSucceeds() async throws {
  //   let responsePath = try #require(
  //     TestSupport.bundledFidoResponseJSONPath,
  //     "TestVectors/fido_response_sign.json must be copied into the test bundle (see Package.swift resources)."
  //   )

  //   // Parse fido_response_sign.json to extract cert and signed_response.
  //   let responseData = try Data(contentsOf: URL(fileURLWithPath: responsePath))
  //   let responseJSON = try #require(
  //     try JSONSerialization.jsonObject(with: responseData) as? [String: Any],
  //     "fido_response_sign.json must be a JSON object."
  //   )
  //   let result = try #require(
  //     responseJSON["result"] as? [String: Any],
  //     "fido_response_sign.json must contain a 'result' object."
  //   )
  //   let certb64 = try #require(
  //     result["cert"] as? String,
  //     "fido_response_sign.json result must contain a 'cert' string."
  //   )
  //   let signedResponse = try #require(
  //     result["signed_response"] as? String,
  //     "fido_response_sign.json result must contain a 'signed_response' string."
  //   )

  //   let tbs = "e775f2805fb993e05a208dbff15d1c1"

  //   let issuerCertPath = try #require(
  //     TestSupport.bundledMOICA_G3CertPath,
  //     "TestVectors/pkcs11info_withcert.json must be copied into the test bundle (see Package.swift resources)."
  //   )

  //   let outputPath = (NSTemporaryDirectory() as NSString)
  //     .appendingPathComponent("openac-input-\(UUID().uuidString).json")
  //   let smtServer: String? = nil
  //   let issuerId = "g2"

  //   let _ = try generateInputFido(
  //     certb64: certb64,
  //     signedResponse: signedResponse,
  //     tbs: tbs,
  //     issuerCertPath: issuerCertPath,
  //     smtServer: smtServer,
  //     issuerId: issuerId,
  //     outputPath: outputPath
  //   )

  //   #expect(
  //     FileManager.default.fileExists(atPath: outputPath),
  //     "generateInputFido should write a circuit input JSON to outputPath."
  //   )
  // }
}
