// RSAPublicKeyExporter.swift
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

public struct RSAPublicKeyExporter {

  // ASN.1 identifier byte
  public let sequenceIdentifier: UInt8 = 0x30

  // ASN.1 AlgorithmIdentfier for RSA encryption: OID 1 2 840 113549 1 1 1 and NULL
  private let algorithmIdentifierForRSAEncryption: [UInt8] = [0x30, 0x0d, 0x06, 0x09, 0x2a, 0x86,
    0x48, 0x86, 0xf7, 0x0d, 0x01, 0x01, 0x01, 0x05, 0x00]

  public init() {}

  public func toSubjectPublicKeyInfo(_ rsaPublicKey: Data) -> Data {
    let writer = SimpleASN1Writer()

    // Insert the ‘unwrapped’ DER encoding of the RSA public key
    writer.write([UInt8](rsaPublicKey))

    // Insert ASN.1 BIT STRING length and identifier bytes on top of it (as a wrapper)
    writer.wrapBitString()

    // Insert ASN.1 AlgorithmIdentifier bytes on top of it (as a sibling)
    writer.write(algorithmIdentifierForRSAEncryption)

    // Insert ASN.1 SEQUENCE length and identifier bytes on top it (as a wrapper)
    writer.wrap(with: sequenceIdentifier)

    return Data(writer.encoding)
  }
}
