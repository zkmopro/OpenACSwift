// This file intentionally left empty.
// COpenACFFI exists solely to expose openac_mobile_appFFI as a named Clang
// module that Xcode's explicit-module build scanner can discover.
// Xcode 26+ does not register module maps from binary XCFrameworks containing
// static libraries, so without this shim the #if canImport check in mopro.swift
// evaluates to false. Symbol implementations come from OpenACSwiftBindings.
