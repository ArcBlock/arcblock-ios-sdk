//
//  Encoding.swift
//
//  Copyright © 2018 Kishikawa Katsumi
//  Copyright © 2018 BitcoinKit developers
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.
//

import Foundation
import BigInt

private protocol Encoding {
    static var zeroAlphabet: Character { get }
    static var base: Int { get }

    // log(256) / log(base), rounded up
    static func sizeFromByte(size: Int) -> Int
    // log(base) / log(256), rounded up
    static func sizeFromBase(size: Int) -> Int

    // Public
    static func encode(_ bytes: Data, _ baseAlphabets: String) -> String
    static func decode(_ string: String, _ baseAlphabets: String) -> Data?
}

private struct _Base58: Encoding {
    static var zeroAlphabet: Character = "1"
    static var base: Int = 58

    static func sizeFromByte(size: Int) -> Int {
        return size * 138 / 100 + 1
    }
    static func sizeFromBase(size: Int) -> Int {
        return size * 733 / 1000 + 1
    }
}

public struct Base58 {
    public static func encode(_ bytes: Data, _ baseAlphabets: String) -> String {
        return _Base58.encode(bytes, baseAlphabets)
    }
    public static func decode(_ string: String, _ baseAlphabets: String) -> Data? {
        return _Base58.decode(string, baseAlphabets)
    }
}

// The Base encoding used is home made, and has some differences. Especially,
// leading zeros are kept as single zeros when conversion happens.
extension Encoding {
    static func convertBytesToBase(_ bytes: Data) -> [UInt8] {
        var length = 0
        let size = sizeFromByte(size: bytes.count)
        var encodedBytes: [UInt8] = Array(repeating: 0, count: size)

        for b in bytes {
            var carry = Int(b)
            var i = 0
            for j in (0...encodedBytes.count - 1).reversed() where carry != 0 || i < length {
                carry += 256 * Int(encodedBytes[j])
                encodedBytes[j] = UInt8(carry % base)
                carry /= base
                i += 1
            }

            assert(carry == 0)

            length = i
        }

        var zerosToRemove = 0
        for b in encodedBytes {
            if b != 0 { break }
            zerosToRemove += 1
        }

        encodedBytes.removeFirst(zerosToRemove)
        return encodedBytes
    }

    static func encode(_ bytes: Data, _ baseAlphabets: String) -> String {
        var bytes = bytes
        var zerosCount = 0

        for b in bytes {
            if b != 0 { break }
            zerosCount += 1
        }

        bytes.removeFirst(zerosCount)

        let encodedBytes = convertBytesToBase(bytes)

        var str = ""
        while 0 < zerosCount {
            str += String(zeroAlphabet)
            zerosCount -= 1
        }

        for b in encodedBytes {
            str += String(baseAlphabets[String.Index(encodedOffset: Int(b))])
        }

        return str
    }

    static func decode(_ string: String, _ baseAlphabets: String) -> Data? {
        var answer = BigUInt(0)
        var j = BigUInt(1)
        let alphabet = [UInt8](baseAlphabets.utf8)
        let radix = BigUInt(alphabet.count)
        let byteString = [UInt8](string.utf8)

        for ch in byteString.reversed() {
            if let index = alphabet.firstIndex(of: ch) {
                answer = answer + (j * BigUInt(index))
                j *= radix
            } else {
                return nil
            }
        }

        let bytes = answer.serialize()
        let leadingOnes = byteString.prefix(while: { value in value == alphabet[0] })
        let leadingZeros: [UInt8] = Array(repeating: 0, count: leadingOnes.count)
        return leadingZeros + bytes
    }
}
