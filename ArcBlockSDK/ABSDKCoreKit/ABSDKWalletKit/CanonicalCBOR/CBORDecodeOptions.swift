// CBORDecodeOptions.swift
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

import Foundation

/// Resource caps that bound how much work a single CBOR decode may do on
/// dapp-controlled input. The defaults are generous enough that the bundled
/// OCAP fixtures (the largest is well under 10 KB) decode without ever hitting
/// a cap, but tight enough that an adversarial 256-MB header can't pin the
/// wallet's main thread on a single decode.
///
/// Caps are evaluated as the decoder walks the input; the first cap to trip
/// throws `CanonicalCBORError.decodeOptionsExceeded(_:)` with a string
/// identifying which cap was hit (`"maxBytes"` / `"maxDepth"` /
/// `"maxKeyCount"` / `"maxArrayLength"`).
///
/// Plumbed through `CBORDecoder.decode(_:options:)` and surfaced on the
/// public OPAQUE entry point `CanonicalCBOR.decodeOpaque(_:options:)` so
/// callers handling untrusted dapp payloads can dial the limits down.
public struct CBORDecodeOptions: Equatable {

    /// Hard cap on the total size of the decoded byte buffer. Checked
    /// once before any parsing happens — exceeding the cap throws before a
    /// single byte is interpreted, so this also protects against quadratic
    /// blowups in downstream allocation.
    public var maxBytes: Int

    /// Maximum nested map / array depth. Each `.map(...)` / `.array(...)`
    /// frame pushes one. Keeps recursive descent off the failure mode where
    /// 100k nested arrays blow the stack.
    ///
    /// Defaults to 64 — generous enough that the higher-level message
    /// bridge's own 32-deep `recursionDepthExceeded` guard tends to trip
    /// first on schema-driven decoding, leaving this cap to catch
    /// genuinely adversarial pure-CBOR inputs.
    public var maxDepth: Int

    /// Maximum pair count on any single CBOR map. Per-map, not cumulative.
    public var maxKeyCount: Int

    /// Maximum element count on any single CBOR array. Per-array, not
    /// cumulative.
    public var maxArrayLength: Int

    public init(maxBytes: Int = 256 * 1024,
                maxDepth: Int = 64,
                maxKeyCount: Int = 1_000,
                maxArrayLength: Int = 10_000) {
        self.maxBytes = maxBytes
        self.maxDepth = maxDepth
        self.maxKeyCount = maxKeyCount
        self.maxArrayLength = maxArrayLength
    }

    /// Defaults are sized for OCAP fixtures + headroom. Tune down at call
    /// sites that handle dapp-controlled payloads where you know the
    /// expected shape is much smaller.
    public static let `default` = CBORDecodeOptions()
}
