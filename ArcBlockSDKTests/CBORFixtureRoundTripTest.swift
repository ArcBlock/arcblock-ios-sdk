// CBORFixtureRoundTripTest.swift
//
// Copyright (c) 2017-present ArcBlock Foundation Ltd <https://www.arcblock.io/>
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.

import XCTest
@testable import ArcBlockSDK

/// Phase 2B exit gate — every vendored CBOR fixture must self round-trip
/// byte-exactly through our codec. The TS pipeline produced these fixtures
/// in the canonical encoding; if our codec is also canonical the bytes
/// must match.
///
/// Bundle wiring is still a phase 2.5 task; until the test target's
/// `Resources` glob picks up `CBORFixtures/`, this test discovers the
/// fixtures via either the bundle or a hardcoded source-tree fallback so
/// it stays runnable from `xcodebuild test` and from the smoke harness.
class CBORFixtureRoundTripTest: XCTestCase {

    // MARK: - Discovery

    /// Returns absolute paths to every `*.cbor.bin` fixture, preferring the
    /// test bundle and falling back to the worktree source path. The
    /// fallback exists to keep the test runnable while the pbxproj
    /// resource wiring is in flight (phase 2.5). Once that lands the
    /// fallback can be removed.
    // TODO(phase-2.5): remove this fallback once pbxproj wires Resources/CBORFixtures/ into the test bundle
    private func fixturePaths() -> [String] {
        let bundle = Bundle(for: type(of: self))
        if let urls = bundle.urls(
            forResourcesWithExtension: "bin",
            subdirectory: "CBORFixtures"
        ), !urls.isEmpty {
            return urls.map { $0.path }
                .filter { $0.hasSuffix(".cbor.bin") }
                .sorted()
        }
        // Fallback: walk the source tree relative to this file.
        // `#filePath` (Swift 5.3+) gives the absolute path of this source
        // file, which is stable across xcodebuild and SwiftPM.
        let here = URL(fileURLWithPath: #filePath)
        let resources = here.deletingLastPathComponent()
            .appendingPathComponent("Resources/CBORFixtures", isDirectory: true)
        guard let entries = try? FileManager.default.contentsOfDirectory(
            at: resources,
            includingPropertiesForKeys: nil
        ) else {
            return []
        }
        return entries
            .map { $0.path }
            .filter { $0.hasSuffix(".cbor.bin") }
            .sorted()
    }

    // MARK: - Tests

    /// For every `*.cbor.bin`, decode the top-level value and re-encode it.
    /// The result MUST byte-equal the original or the codec is not
    /// emitting RFC 8949 §4.2.1 canonical output.
    func testFixtureSelfRoundTrip() throws {
        let paths = fixturePaths()
        XCTAssertEqual(paths.count, 15,
            "expected 15 fixtures vendored — losing fixtures should be a hard failure")

        var failures: [String] = []
        for path in paths {
            let name = (path as NSString).lastPathComponent
            guard let original = FileManager.default.contents(atPath: path) else {
                XCTFail("could not load fixture \(name)")
                continue
            }
            do {
                let value = try CBORDecoder.decodeTopLevel(original)
                let reEncoded = try CBOREncoder.encodeTopLevel(value)
                if reEncoded != original {
                    let oh = original.prefix(32).map { String(format: "%02x", $0) }.joined()
                    let rh = reEncoded.prefix(32).map { String(format: "%02x", $0) }.joined()
                    failures.append(
                        "\(name) len(orig=\(original.count) reenc=\(reEncoded.count))\n" +
                        "  orig:  \(oh)\n  reenc: \(rh)"
                    )
                }
            } catch {
                failures.append("\(name) threw \(error)")
            }
        }

        if !failures.isEmpty {
            XCTFail("fixture round-trip failures (\(failures.count)/\(paths.count)):\n" +
                    failures.joined(separator: "\n"))
        }
    }
}
