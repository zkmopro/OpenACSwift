# OpenACSwift

Swift bindings for the OpenAC zero-knowledge proof system, enabling RS256 circuit proof generation and verification on iOS.

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

Import the library and call the three main functions in order: `setupKeys` → `prove` → `verify`.

```swift
import OpenACSwift
```

### 1. Setup Keys

Generates the proving and verifying keys for the RS256 circuit. This is a one-time setup step that writes key files to `documentsPath`. Run this before the first call to `prove`.

```swift
let documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0].path
let inputPath = Bundle.main.path(forResource: "input", ofType: "json")

do {
    let message = try setupKeys(documentsPath: documentsPath, inputPath: inputPath)
    print("Setup complete:", message)
} catch let error as ZkProofError {
    print("Setup failed:", error)
}
```

**Parameters:**
- `documentsPath` — directory where key files are written and read
- `inputPath` — optional path to a JSON file with circuit inputs; pass `nil` to use defaults

**Returns:** a status string confirming completion.

---

### 2. Prove

Generates a zero-knowledge proof using the keys created by `setupKeys`.

```swift
do {
    let result: ProofResult = try prove(documentsPath: documentsPath, inputPath: inputPath)
    print("Proof generated in \(result.proveMs) ms, size: \(result.proofSizeBytes) bytes")
} catch let error as ZkProofError {
    print("Proving failed:", error)
}
```

**Parameters:**
- `documentsPath` — same directory passed to `setupKeys`
- `inputPath` — optional path to the circuit input JSON

**Returns:** `ProofResult` with:
- `proveMs: UInt64` — time taken to generate the proof in milliseconds
- `proofSizeBytes: UInt64` — size of the generated proof in bytes

---

### 3. Verify

Verifies the proof produced by `prove`.

```swift
do {
    let valid = try verify(documentsPath: documentsPath)
    print(valid ? "Proof is valid" : "Proof is invalid")
} catch let error as ZkProofError {
    print("Verification failed:", error)
}
```

**Parameters:**
- `documentsPath` — same directory passed to `setupKeys` and `prove`

**Returns:** `true` if the proof is valid, `false` otherwise.

---

### Full Example

```swift
import OpenACSwift

func runZKProof() {
    let documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0].path
    let inputPath = Bundle.main.path(forResource: "input", ofType: "json")

    do {
        // 1. Generate keys (run once; skip if keys already exist)
        let status = try setupKeys(documentsPath: documentsPath, inputPath: inputPath)
        print("Keys ready:", status)

        // 2. Generate proof
        let proof = try prove(documentsPath: documentsPath, inputPath: inputPath)
        print("Proved in \(proof.proveMs) ms (\(proof.proofSizeBytes) bytes)")

        // 3. Verify proof
        let valid = try verify(documentsPath: documentsPath)
        print("Valid:", valid)
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

## Error Handling

All three functions throw `ZkProofError`:

| Case | Description |
|------|-------------|
| `SetupRequired` | `prove` or `verify` called before `setupKeys` |
| `FileNotFound` | A required file is missing from `documentsPath` |
| `InvalidInput` | The input JSON is malformed or missing required fields |
| `ProofGenerationFailed` | An error occurred during proof generation |
| `VerificationFailed` | The proof failed verification |
| `IoError` | A filesystem read/write error occurred |
