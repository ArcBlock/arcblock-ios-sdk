<!-- Vendored from did-wallet-sdk-android/planning/canonical-cbor/spec.md on 2026-04-29. Single source of truth: TS canonical-cbor + Android implementation. -->
# Canonical CBOR Transaction — Wire Format Spec

This doc is the **protocol contract** between clients (Web extension wallet,
Android wallet, chain nodes ≥ 1.30.4) for how an OCAP `Transaction` is
serialized to CBOR bytes. If the Kotlin implementation disagrees with this doc
in **any** byte position, signatures will fail verification.

Source: `blockchain/core/message/src/canonical-cbor.ts` (≈600 lines).
All line numbers in this doc refer to that file.

## 0. TL;DR

- Every encoded Transaction begins with `d9 d9 f7` (CBOR tag 55799, RFC 8949
  §3.4.6 self-describe). This is how receivers detect CBOR vs protobuf.
- The rest is a CBOR **map with integer keys**, where the key is the proto
  field number and the value is the field's canonical encoding.
- Keys are sorted ascending. Default-valued fields are omitted.
- The encoding uses **RFC 8949 §4.2.1 Core Deterministic Encoding** (shortest
  integer form, definite-length maps / arrays, no floats reused for integers).
- BigUint / BigSint use **CBOR tag 2 / 3** (unsigned / negative bignum).
- The `itx` field (google.protobuf.Any) is **not** wrapped — its content is
  expanded into a CBOR map where key 0 is the typeUrl string and keys 1+ are
  the inner message's fields.

## 1. Top-level structure

A `Transaction` encodes as:

```
d9 d9 f7           # CBOR tag 55799 (self-describe)
  a<N>             # map with N entries (short form if N ≤ 23)
    <field id>     # proto field number, sorted ascending
    <field value>  # encoded per rules in §3
    ...
```

Example: `TransferV2Tx { to: "z1def", value: 10^18 }` encodes as

```
d9 d9 f7 a2 01 65 7a 31 64 65 66 02 c2 48 0d e0 b6 b3 a7 64 00 00
│        │  │  │  └────── "z1def" ─────┘  │  │  └─ 8-byte bignum ───────┘
│        │  │  └─ text string (5 chars)    │  └─ 8-byte bstr
│        │  └─ field 1 (`to`)              └─ field 2 (`value`), tag 2 bignum
│        └─ 2-entry map
└─ self-describe tag
```

(22 bytes; see `vectors/transfer_v2.cbor.bin`.)

## 2. Field order

Proto field number, ascending. `canonical-cbor.ts:378` iterates
`Object.entries(fields)` which for V8 preserves schema declaration order — but
`encodeMessageFields` sets values into a `Map<number, unknown>` and **cborg
serializes in insertion order**. Practical implication for the Kotlin port:
**always sort by proto field id before writing**, don't rely on iteration
order of whatever schema lookup structure you use.

## 3. Scalar types (line 292–358)

| Proto type | CBOR encoding |
|---|---|
| `int32` / `sint32` / `uint32` / `sfixed32` / `fixed32` / `int64` / `sint64` / `uint64` / `sfixed64` / `fixed64` | CBOR integer (shortest form). Accepts number, bigint, or decimal string in Kotlin-side input; emit as bigint if >2^53. |
| `double` / `float` | CBOR float (64-bit double). |
| `bool` | CBOR simple `f4`/`f5`. |
| `string` | CBOR text string (major type 3), UTF-8. |
| `bytes` | CBOR byte string (major type 2). **No hex or base64 conversion.** |
| enum | CBOR integer (numeric value). String enum names in input are resolved via the schema (line 326–336). |
| nested message | Recursively encoded as a CBOR map `Map<number, ...>` per §1. |

## 4. Default / empty-value folding (line 137–155, 385–404)

A field is **omitted entirely** when its value is one of:

- `undefined` / `null` (line 387, unconditional drop)
- Integer 0
- Float 0.0
- Empty string `""`
- Empty byte string (zero-length `Uint8Array`)
- Empty repeated field (empty array, line 394)
- `false` for `bool`
- Enum value 0 or `""`

Rationale: matches protobuf3 defaults + JS `undefined` semantics so that
`decode(encode(x))` is a pure round-trip.

**Trap for Kotlin port**: Java/Kotlin has no `undefined`. The Web
implementation relies on a distinction between "property not present" and
"property set to undefined", both of which fold to omit. On Android your data
model should use **nullable types** (`Long?`, `String?`, `ByteArray?`) and
treat `null` as "omit". Never default-initialize a field to 0 and expect the
encoder to omit it correctly — it will.

## 5. BigUint / BigSint (line 82–119, 310–315, 365–373)

The OCAP schema wraps arbitrary-precision integers in a
`BigUint { value: bytes }` or `BigSint { value: bytes, minus: bool }` message.

**Encoding rules:**

1. Compute magnitude as big-endian bytes with leading zeros stripped
   (line 67–72).
2. If magnitude is zero, emit **nothing** (the whole field is omitted, line 95
   and line 102).
3. Otherwise emit `Tagged(tag, magnitude_bytes)`:
   - Tag **2** for `BigUint` and non-negative `BigSint`
   - Tag **3** for `BigSint` with `minus: true`
4. Wire-level result: `c2 <bstr>` or `c3 <bstr>`.

**Top-level BigUint/BigSint** (when the outer message *is* a BigUint, line
365–373): emit as a map `{1: tagged-bytes, 2?: true}` — field 2 (the `minus`
bit) appears only when negative.

**Kotlin input flexibility:** the Web encoder accepts many shapes — native
BigInt, decimal string, wrapped `{value: bytes, minus: bool}`, BN-like object.
Kotlin port should accept at least `BigInteger` and `{value: ByteArray, minus:
Boolean}`. Decimal strings are nice-to-have (easier for JSON interop).

## 6. Timestamps (line 157–175, 317–319)

`google.protobuf.Timestamp` encodes as an **ISO-8601 string** (not a CBOR tag
0/1 datetime). Round-tripping:

- Input can be `{seconds, nanos}` (proto object), `Date`, or ISO-8601 string.
- `{seconds, nanos}` → `new Date(seconds * 1000 + trunc(nanos / 1e6)).toISOString()`.
- Milliseconds-and-above only; sub-ms precision is truncated.

## 7. Any fields — the `itx` case (line 177–290)

`google.protobuf.Any` is **not** serialized as the protobuf wire format would
suggest `{type_url, value: bytes}`. Instead it is **expanded in place**:

```
itx: { typeUrl: "fg:t:transfer_v2", to: "z1def", value: BigUint(1e18) }
```

Encodes to a nested map:

```
{0: "fg:t:transfer_v2", 1: "z1def", 2: tag2(bignum bytes)}
```

Where keys 1 and 2 come from `TransferV2Tx`'s proto field numbers.

### 7.1 Input shape discrimination (line 183–199)

The encoder accepts three input shapes for an Any value:

- **Flat**: `{typeUrl, ...fields}` — typeUrl at same level as inner fields
- **Wire**: `{typeUrl, value: <bytes|object>}` — typeUrl + opaque inner
- **Friendly**: `{type, value: {...}}` — type is the message NAME (e.g.
  `"TransferV2Tx"`), value carries the fields; unwrapped before encoding.

The discriminant (line 197) is **precise**:

```typescript
const wasUnwrapped = !value.typeUrl && !value.type_url && typeof value.type === 'string';
```

**Do not** simplify this to `value.type !== undefined`. Some inner message
types have a legitimate `type` field (e.g. `AccountMigrateTx.type` is a
`WalletType` enum, `MigrateRollupTx.type` is a "vault"|"contract" string). A
loose check false-positives and produces an empty Any body.

### 7.2 Type key stripping (line 253–271)

After unwrapping, the encoder strips wrapper keys from the inner object:

- Always strip `typeUrl` and `type_url`.
- Strip `type` **only if** the inner message's schema does NOT declare a
  `type` field. (Line 266: `if (!innerSchemaFields || !('type' in innerSchemaFields))`.)

### 7.3 Opaque payloads (line 236–242)

For three special typeUrls, the inner payload is passed to CBOR verbatim
instead of schema-driven encoded:

- `json`
- `vc`
- `fg:x:address`

Only `Date → ISO-8601` normalization and `undefined` property stripping are
applied (line 215–229). This matches chain-side decode-then-re-encode.

## 8. Repeated fields (line 302–308, 389–396)

Empty array → field omitted. Non-empty → CBOR array of encoded items.

**Aliases** (line 382, for decoder): both `fieldName` and `fieldNameList`
(jspb's `toObject()` naming) are accepted on input, because after
`createMessage(...).toObject()` the canonical name is `fieldNameList`. Both
produce identical output.

## 9. Map fields

Not yet supported (line 298–300). Throws immediately. This is a Phase 2+
follow-up in the blockchain planning.

**Implication for Android:** the current Transaction schema does not have any
`map<K,V>` fields, so this is a forward-compat guard. Port can mirror it:
throw "unsupported" if a map field is encountered.

## 10. Decoder

The decoder is the inverse of the encoder. Entry: `parseCanonical(type,
bytes)`.

**Input validation (line 566–573):** rejects input if first 3 bytes are not
`d9 d9 f7`.

**Two output quirks:**

### 10.1 Dual key emission (line 546–557)

For every decoded field, the decoder emits **both** the canonical proto name
AND the jspb alias:

- repeated: both `fieldName` and `fieldNameList`
- map: both `fieldName` and `fieldNameMap`

Rationale: existing consumers read either name, so CBOR decode must be
drop-in compatible with both access patterns. Port should match.

### 10.2 Map → plain object recursion (line 434–446)

When decoding opaque (json/vc) payloads, cborg's `useMaps: true` option
returns nested CBOR maps as JS `Map` instances. `JSON.stringify(map)` produces
`{}` — silent data loss. The decoder recursively converts nested `Map` to
plain objects.

**Android parallel:** if your CBOR library returns `Map<Any, Any>` inside
opaque payloads, convert to `Map<String, Any>` or a JSON-friendly structure
before returning.

## 11. Error messages

Error messages **must not echo user input** (see line 162–164 comment for
why). If the input is unparseable, throw a generic error — don't include the
rejected string.

## 12. Constants

```kotlin
const val TAG_SELF_DESCRIBE     = 55799
const val TAG_POSITIVE_BIGNUM   = 2
const val TAG_NEGATIVE_BIGNUM   = 3
val SELF_DESCRIBE_PREFIX: ByteArray = byteArrayOf(0xd9.toByte(), 0xd9.toByte(), 0xf7.toByte())
```

## 13. Verification checklist for Kotlin port

Before claiming done, all 5 golden vectors at
`arc-wallet-android/planning/cbor-support/vectors/` must pass:

- `encode(input.json) == cbor.bin` — byte-exact
- `decode(cbor.bin)` produces a structure that, re-encoded, equals `cbor.bin`
  (round-trip)

Plus these edge cases:

- Empty `signatures` list → field omitted (not `a0` or similar)
- `signature = null` → field omitted
- `BigUint { value: [0] }` → field omitted entirely
- `AccountMigrateTx.type` enum value round-trips (not stripped as Any
  wrapper)

## 14. See also

- `kotlin-port.md` — implementation guide
- `arc-wallet-android/planning/cbor-support/` — app-layer integration plan
- Upstream source: `blockchain/core/message/src/canonical-cbor.ts`
- Upstream planning: `blockchain/planning/43-transaction-cbor-encoding/README.md`
