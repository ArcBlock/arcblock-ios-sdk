# 钱包安全审计报告：arcblock-ios-sdk

## 执行摘要

- **审计范围**：/Users/nategu/work/arcblock/did-wallet/arcblock-ios-sdk
- **审计日期**：2026-05-11（基于 2026-05-09 报告更新）
- **审计版本**：arcblock-ios-sdk (master 分支)
- **总体风险**：中高
- **核心问题**：非标准的 Seed 派生逻辑、不安全的加密默认值。
- **高优先级修复项**：
    1. 使用 BIP39 标准替换自定义的 Seed 派生逻辑。
    2. 在 `AESUtils` 中弃用 AES-ECB 模式。
    3. 更新 `RSAUtils`，将默认密钥长度提升至 3072 位，并改用 SHA-256 OAEP。

## 审计方法

- **静态审查**：验证了前次审计报告（2026-05-09）中的发现。对手动审阅 `BIP44Utils.swift`、`AESUtils.swift` 和 `RSAUtils.swift`。
- **工具使用**：`audit-wallet-security` 参考审计流程。
- **审计限制**：仅限静态分析。

## 发现汇总

| 编号 | 严重级别 | 状态 | 领域 | 标题 | 影响仓库 |
| --- | --- | --- | --- | --- | --- |
| SDK-IOS-001 | 高 (High) | 已确认 | Seed 派生 | 自定义 Seed 派生逻辑使用了哈希截断 | arcblock-ios-sdk |
| SDK-IOS-002 | 中 (Medium) | 已确认 | 密码学 | AESUtils 使用了不安全的 ECB 模式 | arcblock-ios-sdk |
| SDK-IOS-003 | 中 (Medium) | 已确认 | 密码学 | RSAUtils 默认使用较弱的 1024 位密钥 | arcblock-ios-sdk |

## 详细发现

### SDK-IOS-001：自定义 Seed 派生逻辑使用了哈希截断

- **严重级别**：高 (High)
- **状态**：已确认
- **影响文件**：`ArcBlockSDK/ABSDKCoreKit/BIP44Utils.swift`
- **资产影响**：削弱了钱包 Seed 恢复的熵值。
- **攻击场景**：自定义的 `getEntropy` 逻辑对 Secret Code 和 Recovery Code 仅执行了一次哈希并截断。这比标准的 KDF（如 PBKDF2 或 Argon2id）要脆弱得多，更容易受到暴力破解。
- **证据**：`BIP44Utils.swift:60-64` 使用 `sha3` 和 `prefix(32)` 实现了 `getEntropy`。
- **根本原因**：使用了非标准的熵值生成实现。
- **修复建议**：转向使用 BIP39 标准的助记词和熵值生成逻辑。

### SDK-IOS-002：AESUtils 使用了不安全的 ECB 模式

- **严重级别**：中 (Medium)
- **状态**：已确认
- **影响文件**：`ArcBlockSDK/ABSDKCoreKit/AESUtils.swift`
- **资产影响**：加密数据中存在模式泄露。
- **攻击场景**：AES-ECB 模式不使用 IV（初始化向量），会将相同的明文块加密为相同的密文块，从而暴露数据中的结构模式。
- **证据**：`AESUtils.swift` 中配置使用了 `blockMode: ECB()`。
- **修复建议**：将 ECB 替换为 GCM 模式，或使用带有随机 IV 的 CBC 模式。

### SDK-IOS-003：RSAUtils 默认使用较弱的 1024 位密钥

- **严重级别**：中 (Medium)
- **状态**：已确认
- **影响文件**：`ArcBlockSDK/ABSDKCoreKit/RSAUtils.swift`
- **资产影响**：密钥容易受到现代算力的因数分解攻击。
- **攻击场景**：1024 位 RSA 已被认为是不安全的。SDK 在生成密钥时默认使用了这一长度。
- **证据**：`RSAUtils.swift` 中 `kSecAttrKeySizeInBits` 默认设为 `1024`。
- **修复建议**：将默认密钥长度增加到 3072 位或 4096 位。

## 正向控制措施

- **CSPRNG**：使用了 `SecRandomCopyBytes` 进行随机数生成。
- **CBOR 限制**：CBOR 解析器包含深度和大小限制，以防止拒绝服务（DoS）攻击。

## 建议后续步骤

1. 转向使用 BIP39 进行 Seed 生成 (SDK-IOS-001)。
2. 加固密码学工具类 (SDK-IOS-002, SDK-IOS-003)。
3. 在 CI 中添加自动化安全扫描（如 OSV-Scanner）。
