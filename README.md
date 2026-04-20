# OpenACSwift

Swift bindings for the OpenAC zero-knowledge proof system, enabling RS256/RS4096 circuit proof generation and verification on iOS.

The prebuilt binaries are distributed via the [zkID latest release](https://github.com/zkmopro/zkID/releases/tag/latest).

## Requirements

- iOS 16+
- Xcode 15+

## Installation

### Swift Package Manager

Add OpenACSwift to your `Package.swift`:

```swift
dependencies: [
    .package(url: "https://github.com/zkmopro/OpenACSwift", from: "1.0.0"),
],
targets: [
    .target(
        name: "YourTarget",
        dependencies: ["OpenACSwift"]
    ),
]
```

Or in Xcode: **File → Add Package Dependencies**, enter the repository URL.

## Usage

Import the library and call the functions in order: `setupKeys` → `prove*` → `verify*`.

```swift
import OpenACSwift
```

### 1. Setup Keys

Generates proving and verifying keys for both circuits. Run once before any prove/verify calls.

```swift
let documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0].path

do {
    let message = try setupKeys(documentsPath: documentsPath)
    print("Setup complete:", message)
} catch let error as ZkProofError {
    print("Setup failed:", error)
}
```

Before calling `setupKeys`, download the four key files and place them in `documentsPath/keys/`:

| File | Download URL |
|------|-------------|
| `cert_chain_rs4096_proving.key` | [cert_chain_rs4096_proving.key.gz](https://github.com/zkmopro/zkID/releases/download/latest/cert_chain_rs4096_proving.key.gz) |
| `cert_chain_rs4096_verifying.key` | [cert_chain_rs4096_verifying.key.gz](https://github.com/zkmopro/zkID/releases/download/latest/cert_chain_rs4096_verifying.key.gz) |
| `device_sig_rs2048_proving.key` | [device_sig_rs2048_proving.key.gz](https://github.com/zkmopro/zkID/releases/download/latest/device_sig_rs2048_proving.key.gz) |
| `device_sig_rs2048_verifying.key` | [device_sig_rs2048_verifying.key.gz](https://github.com/zkmopro/zkID/releases/download/latest/device_sig_rs2048_verifying.key.gz) |

Each file is gzip-compressed — decompress before use (e.g. `gunzip *.gz`). The decompressed key files must be present at `documentsPath/keys/<filename>` before calling `setupKeys`.

**Parameters:**
- `documentsPath` — directory containing the `keys/` subdirectory with the key files

**Returns:** a status string confirming completion.

---

### 2. Prove

Generate a zero-knowledge proof for a specific circuit. Both functions return a `ProofResult`.

```swift
// Certificate chain circuit (RS4096)
let certResult: ProofResult = try proveCertChainRs4096(documentsPath: documentsPath)
print("Proved in \(certResult.proveMs) ms, size: \(certResult.proofSizeBytes) bytes")

// Device signature circuit (RS2048)
let devResult: ProofResult = try proveDeviceSigRs2048(documentsPath: documentsPath)
print("Proved in \(devResult.proveMs) ms, size: \(devResult.proofSizeBytes) bytes")
```

**Returns:** `ProofResult` with:
- `proveMs: UInt64` — time taken to generate the proof in milliseconds
- `proofSizeBytes: UInt64` — size of the generated proof in bytes

---

### 3. Verify

Verify the proof produced by the corresponding prove function.

```swift
// Verify individually
let certValid = try verifyCertChainRs4096(documentsPath: documentsPath)
let devValid  = try verifyDeviceSigRs2048(documentsPath: documentsPath)

// Or verify both circuits together
let linked = try linkVerify(documentsPath: documentsPath)
```

**Returns:** `true` if the proof is valid, `false` otherwise.

---

### Generate Circuit Input

Use `generateCertChainRs4096Input` to produce a JSON input file for the cert chain circuit from raw credential data.

```swift
let outputPath = try generateCertChainRs4096Input(
    certb64: "<base64-encoded-cert>",
    signedResponse: "<signed-response-json>",
    tbs: "<tbs-data>",
    issuerCertPath: "/path/to/issuer.cer",
    smtServer: nil,          // optional SMT server URL
    issuerId: "<issuer-id>",
    outputDir: documentsPath
)
print("Input written to:", outputPath)
```

---

### Benchmarking

Run the complete pipeline and get timing and size statistics for all stages:

```swift
let results: BenchmarkResults = try runCompleteBenchmark(documentsPath: documentsPath)
print("Setup: \(results.setupMs) ms")
print("Prove: \(results.proveMs) ms")
print("Verify: \(results.verifyMs) ms")
print("Proving key: \(results.provingKeyBytes) bytes")
print("Verifying key: \(results.verifyingKeyBytes) bytes")
print("Proof: \(results.proofBytes) bytes")
print("Witness: \(results.witnessBytes) bytes")
```

---

### Full Example

```swift
import OpenACSwift

func runZKProof() async {
    let documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0].path

    do {
        // 1. Generate keys (run once; skip if keys already exist)
        let status = try setupKeys(documentsPath: documentsPath)
        print("Keys ready:", status)

        // 2. Generate proofs
        let certProof = try proveCertChainRs4096(documentsPath: documentsPath)
        print("cert_chain proved in \(certProof.proveMs) ms (\(certProof.proofSizeBytes) bytes)")

        let devProof = try proveDeviceSigRs2048(documentsPath: documentsPath)
        print("device_sig proved in \(devProof.proveMs) ms (\(devProof.proofSizeBytes) bytes)")

        // 3. Verify proofs
        let certValid = try verifyCertChainRs4096(documentsPath: documentsPath)
        let devValid  = try verifyDeviceSigRs2048(documentsPath: documentsPath)
        let linked    = try linkVerify(documentsPath: documentsPath)
        print("cert_chain valid:", certValid)
        print("device_sig valid:", devValid)
        print("link verify:", linked)
    } catch let error as ZkProofError {
        switch error {
        case .SetupRequired(let msg):         print("Run setupKeys first:", msg)
        case .FileNotFound(let msg):          print("Missing file:", msg)
        case .InvalidInput(let msg):          print("Bad input:", msg)
        case .ProofGenerationFailed(let msg): print("Prove error:", msg)
        case .VerificationFailed(let msg):    print("Verify error:", msg)
        case .IoError(let msg):               print("IO error:", msg)
        }
    } catch {
        print("Unexpected error:", error)
    }
}
```

## API Reference

| Function | Returns | Description |
|----------|---------|-------------|
| `setupKeys(documentsPath:)` | `String` | Generate keys for both circuits |
| `proveCertChainRs4096(documentsPath:)` | `ProofResult` | Prove cert chain (RS4096) circuit |
| `proveDeviceSigRs2048(documentsPath:)` | `ProofResult` | Prove device signature (RS2048) circuit |
| `verifyCertChainRs4096(documentsPath:)` | `Bool` | Verify cert chain proof |
| `verifyDeviceSigRs2048(documentsPath:)` | `Bool` | Verify device signature proof |
| `linkVerify(documentsPath:)` | `Bool` | Verify both proofs together |
| `generateCertChainRs4096Input(...)` | `String` | Generate circuit input JSON from credential data |
| `runCompleteBenchmark(documentsPath:)` | `BenchmarkResults` | Run full pipeline and return timing/size stats |

## Error Handling

All functions throw `ZkProofError`:

| Case | Description |
|------|-------------|
| `SetupRequired` | `prove*` or `verify*` called before `setupKeys` |
| `FileNotFound` | A required file is missing from `documentsPath` |
| `InvalidInput` | The input JSON is malformed or missing required fields |
| `ProofGenerationFailed` | An error occurred during proof generation |
| `VerificationFailed` | The proof failed verification |
| `IoError` | A filesystem read/write error occurred |
