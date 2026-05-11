# ArcBlock iOS SDK 钱包安全审计报告

## 执行摘要

- 审计范围：`/Users/nategu/work/arcblock/did-wallet/arcblock-ios-sdk`
- 审计日期：2026-05-09
- 审计仓库/提交：`arcblock-ios-sdk`，`master` 分支，提交 `077c882`
- 审计方式：静态源码审计、依赖清单审计、CI/release 链路审计、移动端配置审计
- 总体风险：Medium-High。此次审计没有确认可直接远程利用的漏洞，但 SDK 暴露了多个钱包关键密码学 helper，其中存在不安全默认值或输入校验不足。
- 最高优先级修复项：
  1. 在这些 API 用于钱包密钥、种子、备份等敏感材料前，替换自定义 seed 派生逻辑以及 AES/RSA helper 的不安全默认实现。
  2. 为 secp256k1/Ethereum digest 签名 API 增加严格输入长度校验。
  3. 加固 GitHub Actions 和 release 脚本，降低依赖或 workflow 被污染后影响 release 的风险。

## 审计方法

- 使用本地 `audit-wallet-security` skill 流程和 inventory 脚本，梳理依赖清单、密码学/签名文件、移动端元数据、CI workflow 和 release 脚本。
- 优先审计钱包高风险路径：seed 生成、密钥派生、加解密 wrapper、RSA helper、DID key handling、交易签名、CBOR 解析、随机数生成和测试 fixture。
- 审计供应链输入：CocoaPods、Ruby/Bundler、package lockfile、GitHub Actions workflow、release make target、Git 托管依赖。
- 检查移动端 metadata 中明显的 ATS、URL scheme、associated domain 暴露面。
- 用于基线判断的外部参考：
  - OWASP Cryptographic Storage Cheat Sheet：https://cheatsheetseries.owasp.org/cheatsheets/Cryptographic_Storage_Cheat_Sheet.html
  - GitHub Actions security hardening：https://docs.github.com/actions/security-guides/security-hardening-for-github-actions
  - OSV-Scanner source/lockfile scanning：https://google.github.io/osv-scanner/usage/scan-source

## 验证情况与限制

- 生成报告前确认仓库工作区是干净的。
- `xcodebuild -list -project ArcBlockSDK.xcodeproj` 能列出 `ArcBlockSDK` 和 `ArcBlockSDKTests` 两个 scheme，但在当前沙箱环境下出现 CoreSimulator 和 DerivedData 日志权限相关 warning。本次没有完成 build 或 test。
- `pod --version` 失败，原因是 `/usr/local/bin/pod` 找不到 `cocoapods` gem。
- 本地未安装 `osv-scanner` 和 `bundle-audit`，因此没有完成本地依赖漏洞库匹配。
- 本次没有做动态 iOS runtime 测试、真机测试、越狱/root 环境测试，也没有验证二进制 release artifact 的 provenance。
- 下方 findings 明确区分 `Confirmed`、`Likely` 和 `Needs protocol confirmation`，避免把静态审计假设写成已确认漏洞。

## 发现汇总

| ID | 严重级别 | 状态 | 领域 | 标题 | 影响仓库 |
| --- | --- | --- | --- | --- | --- |
| WSA-IOS-001 | High | Confirmed | Seed/key derivation | 自定义钱包 seed 派生使用一次性 hash 和截断 | `arcblock-ios-sdk` |
| WSA-IOS-002 | Medium | Confirmed | Symmetric crypto | `AESUtils` 使用 AES-ECB 且没有认证加密 | `arcblock-ios-sdk` |
| WSA-IOS-003 | Medium | Confirmed | Asymmetric crypto | `RSAUtils` 默认使用 1024-bit RSA 和 OAEP-SHA1 | `arcblock-ios-sdk` |
| WSA-IOS-004 | Medium | Confirmed | Signing | secp256k1/Ethereum 签名 API 没有限制 32-byte digest 输入 | `arcblock-ios-sdk` |
| WSA-IOS-005 | Medium | Confirmed | CI/release supply chain | Workflow 和 release 脚本使用 mutable action、较宽 secret 和被掩盖的失败 | `arcblock-ios-sdk` |
| WSA-IOS-006 | Medium | Likely | Dependency governance | 缺少依赖审计 gate，且多个锁定的工具/运行时依赖偏旧 | `arcblock-ios-sdk` |
| WSA-IOS-007 | Low | Confirmed | DID/key handling | PASSKEY 已建模但 key/sign/verify 路径静默不支持 | `arcblock-ios-sdk` |
| WSA-IOS-008 | Low | Confirmed | Secret/log hygiene | README 暴露 Travis token-like 值，RSA 测试打印 key material | `arcblock-ios-sdk` |
| WSA-IOS-009 | Low | Needs protocol confirmation | Transaction integrity | 默认 timestamp nonce 可能碰撞或偏离链上 nonce 语义 | `arcblock-ios-sdk` |

## 详细发现

### WSA-IOS-001：自定义钱包 Seed 派生使用一次性 Hash 和截断

- 严重级别：High
- 状态：Confirmed
- 影响文件：
  - `ArcBlockSDK/ABSDKCoreKit/BIP44Utils.swift:27`
  - `ArcBlockSDK/ABSDKCoreKit/BIP44Utils.swift:36`
  - `ArcBlockSDK/ABSDKCoreKit/BIP44Utils.swift:60`
- 钱包资产影响：弱或非标准 seed 派生函数会降低离线攻击 wallet seed 和派生私钥的成本，尤其是在 recovery material 或用户自选 secret 部分已知时。
- 利用场景：如果攻击者获得 recovery code、备份载荷或其他 seed-adjacent material，短 `secretCode` 可以针对确定性的单次 hash 派生逻辑进行暴力枚举。由于没有 memory-hard KDF，也没有显式 salt/work factor，每次猜测成本很低。
- 证据：
  - `generateRecoveryCode()` 返回 16 字节随机数的 base58 编码，但 RNG 失败时返回空字符串。
  - `generateSeed(secretCode:recoveryCode:)` 通过 `getEntropy` 派生 entropy。
  - `getEntropy` 计算 `keccak256(keccak256(secretCode).uppercased() + recoveryCode)`，再截断到 32 个 hex 字符，并把 ASCII hex 文本转换为 entropy bytes。
- 根因：钱包 seed 派生使用了自定义构造，而不是标准 KDF 或经过充分审查的 mnemonic/passphrase flow。
- 修复建议：
  - 优先使用标准 BIP39 mnemonic + passphrase seed derivation；如果需要新方案，应使用带版本号的迁移方案，并采用 Argon2id/scrypt/PBKDF2 等带 per-wallet salt 和显式参数的 KDF。
  - RNG 失败时抛出 typed error，不要返回 `""`。
  - 增加已有钱包兼容性测试，以及低熵 `secretCode` 拒绝测试。
  - 在导出/恢复钱包 metadata 中记录 derivation version，方便未来迁移。
- 验证：
  - 静态审计已确认实现方式。
  - 未运行暴力枚举 benchmark 或兼容迁移测试。
- 剩余风险：已经通过此算法派生的钱包需要谨慎设计向后兼容迁移方案；简单替换可能导致用户无法恢复资产。

### WSA-IOS-002：`AESUtils` 使用 AES-ECB 且没有认证加密

- 严重级别：Medium
- 状态：Confirmed
- 影响文件：
  - `ArcBlockSDK/ABSDKCoreKit/AESUtils.swift:28`
  - `ArcBlockSDK/ABSDKCoreKit/AESUtils.swift:38`
  - `ArcBlockSDK/ABSDKCoreKit/AESUtils.swift:61`
  - `ArcBlockSDK/ABSDKCoreKit/AESUtils.swift:65`
- 钱包资产影响：如果下游钱包代码用该 helper 加密私钥、seed、备份或 token，AES-ECB 会泄露重复明文结构，并且没有完整性/真实性校验。能修改 ciphertext 的攻击者可能进行未被检测的篡改尝试。
- 利用场景：通过 `AESUtils` 加密的 wallet backup 如果包含重复或结构化明文，会产生重复 ciphertext block。由于没有 AEAD tag 或 MAC，篡改后的 ciphertext 可能直到解析失败或污染下游状态时才被发现。
- 证据：
  - `createKey(_:)` 对 UTF-8 字符串做一次 SHA3-256，并直接把结果作为 AES key。
  - 加密和解密都实例化 `AES(key: keyData, blockMode: ECB(), padding: .pkcs5)`。
  - 解密 catch error 后调用 `print(error)`。
- 根因：SDK 以 public utility 的形式暴露了低级 block cipher mode 和直接 password-to-key transform。
- 修复建议：
  - 对钱包敏感数据弃用该 API。
  - 引入 AES-GCM 或 ChaCha20-Poly1305 等认证加密方案，每次加密使用唯一随机 nonce，并显式支持 associated data。
  - 如果 caller 提供 password/passcode，应使用带版本、salt 和 work factor 的 KDF 派生加密 key。
  - 返回 typed error，避免打印密码学失败细节。
- 验证：
  - 静态审计已确认 ECB 使用和缺少认证。
- 剩余风险：SDK 消费方可能已经依赖当前 ciphertext 格式，需要提供 decrypt-old/encrypt-new 的版本化迁移路径。

### WSA-IOS-003：`RSAUtils` 默认使用 1024-Bit RSA 和 OAEP-SHA1

- 严重级别：Medium
- 状态：Confirmed
- 影响文件：
  - `ArcBlockSDK/ABSDKCoreKit/RSAUtils.swift:28`
  - `ArcBlockSDK/ABSDKCoreKit/RSAUtils.swift:31`
  - `ArcBlockSDK/ABSDKCoreKit/RSAUtils.swift:69`
  - `ArcBlockSDK/ABSDKCoreKit/RSAUtils.swift:78`
  - `ArcBlockSDK/ABSDKCoreKit/RSAUtils.swift:100`
  - `ArcBlockSDK/ABSDKCoreKit/RSAUtils.swift:167`
  - `ArcBlockSDK/ABSDKCoreKit/RSAUtils.swift:191`
  - `ArcBlockSDK/ABSDKCoreKit/RSAUtils.swift:204`
  - `ArcBlockSDK/ABSDKCoreKit/RSAUtils.swift:214`
- 钱包资产影响：如果 RSA helper 被用于钱包备份封装、传输加密或身份 bootstrap，调用方会继承弱默认值。1024-bit RSA 已低于现代安全预期，OAEP-SHA1 也属于 legacy padding 选择。
- 利用场景：下游代码通过 SDK 默认值生成或导入 RSA key，并把加密数据当成长期钱包材料保护机制。
- 证据：
  - key generation 设置 `kSecAttrKeySizeInBits: 1024`。
  - `decodeSecKeyFromBase64` 默认 `keySzie` 为 `1024`。
  - 加密/解密使用 `.rsaEncryptionOAEPSHA1`。
  - `exportPemB58BtcSk` 暴露 private-key export 功能。
- 根因：legacy compatibility default 被暴露为通用 public crypto helper。
- 修复建议：
  - 将 RSA 最小长度提升到 3072-bit；如果可行，在钱包敏感流程中移除 RSA，改用现代椭圆曲线原语。
  - 仍需 RSA encryption 时使用 SHA-256 OAEP 变体。
  - 将 private-key export 限制为 test-only，或明确标注 unsafe/deprecated 并要求 caller 显式 opt-in。
  - 增加测试，确保 production key generation/import 拒绝 1024-bit RSA。
- 验证：
  - 静态审计已确认弱默认值和 SHA1 OAEP 使用。
- 剩余风险：部分外部集成可能仍需要 legacy RSA。建议保留在明确命名的 legacy API 中，而不是作为看似安全的默认路径。

### WSA-IOS-004：secp256k1/Ethereum 签名 API 没有限制 32-Byte Digest 输入

- 严重级别：Medium
- 状态：Confirmed
- 影响文件：
  - `ArcBlockSDK/ABSDKCoreKit/MCrypto.swift:120`
  - `ArcBlockSDK/ABSDKCoreKit/MCrypto.swift:132`
  - `ArcBlockSDK/ABSDKCoreKit/MCrypto.swift:147`
  - `ArcBlockSDK/ABSDKCoreKit/MCrypto.swift:162`
  - `ArcBlockSDK/ABSDKCoreKit/ABSDKWalletKit/TxHelper.swift:152`
- 钱包资产影响：public signing helper 可能被 SDK 消费方误用。libsecp256k1 ECDSA sign/verify 操作的是 32-byte message digest；接受任意 `Data` 可能导致 undefined behavior、crash，或签名语义不符合 caller 预期。
- 利用场景：caller 把未 hash 的交易 bytes、空 buffer 或短 message 传给 `MCrypto.Signer.M_SECP256K1.sign`。SDK 在传入 C API 前没有拒绝该输入。
- 证据：
  - `MCrypto.Signer.M_SECP256K1.sign(message:privateKey:)` 直接把 `Array(message)` 传给 `secp256k1_ecdsa_sign`。
  - verify 路径同样把 `Array(message)` 传给 `secp256k1_ecdsa_verify`。
  - `TxHelper.calculateSignature` 会先 hash 交易 bytes 再签名，因此内置交易路径受到保护；但更底层的 public API 对通用 caller 仍不安全。
- 根因：API 参数名是 `message`，但底层 primitive 期望的是 32-byte digest。
- 修复建议：
  - 在 secp256k1/Ethereum sign 和 verify 路径增加 `guard message.count == 32 else { return nil }`，或改为抛出 typed error。
  - 将低层 API 重命名为 `signDigest32`/`verifyDigest32`，另提供显式 domain separation 的 `signMessage` helper。
  - 增加 empty、31-byte、32-byte、33-byte 输入测试。
- 验证：
  - 静态审计已确认缺少长度校验。
- 剩余风险：短 array 的实际行为取决于 Swift/C bridging 和 libsecp256k1 调用边界；建议用动态测试确认是否可 crash，再决定是否上调严重级别。

### WSA-IOS-005：Workflow 和 Release 脚本使用 Mutable Action、较宽 Secret 和被掩盖的失败

- 严重级别：Medium
- 状态：Confirmed
- 影响文件：
  - `.github/workflows/main.yml:15`
  - `.github/workflows/main.yml:20`
  - `.github/workflows/release.yml:16`
  - `.github/workflows/release.yml:21`
  - `.github/workflows/coverage.yml:25`
  - `.github/workflows/coverage.yml:27`
  - `.github/workflows/coverage.yml:37`
  - `.github/workflows/coverage.yml:38`
  - `.makefiles/release.mk:8`
  - `.makefiles/release.mk:9`
  - `.makefiles/release.mk:24`
  - `.makefiles/release.mk:25`
- 钱包资产影响：被污染的 CI 依赖、mutable action tag 或权限过宽 token 会影响 release 完整性。对钱包 SDK 来说，release-chain compromise 可能进一步演变为下游资产风险。
- 利用场景：第三方 action tag 被移动或被污染，并在 repository/secrets context 中执行。release workflow 使用自定义 secret token 和 mutable action reference。release make target 通过 `| true` 掩盖 tag/push 失败，使错误 release 更难被发现。
- 证据：
  - workflow 使用 `actions/checkout@v2`、`maxim-lobanov/setup-xcode@v1`、`sersoft-gmbh/xcodebuild-action@v1`、`softprops/action-gh-release@v1`，均为 mutable tag，不是 full-length commit SHA。
  - `main.yml` 使用 `secrets.ACCESS_TOKEN`；`release.yml` 使用 `secrets.GIT_HUB_TOKEN`。
  - 已审计 workflow 中没有声明 least-privilege `permissions:`。
  - `coverage.yml` 在 `pod install` 前运行 `bundle update`，CI 中 Ruby 依赖解析可能发生漂移。
  - `.makefiles/release.mk` 对 tag/push 失败使用 `| true`；`create-pr` 执行 `git add .;git commit -a -m "bump version";git push`。
- 根因：release automation 更偏向便利性，而不是可复现性、最小权限和不可变依赖。
- 修复建议：
  - 所有第三方 action pin 到 full-length commit SHA，并审查更新 provenance。
  - 添加显式 `permissions:`。默认 `contents: read`；只有受保护 release job 才授予 `contents: write`。
  - 尽可能使用 `GITHUB_TOKEN` 配合 protected environment 或 OIDC/short-lived credentials，替代长期 PAT。
  - 用 lockfile-respecting install 替代 `bundle update`，例如 `bundle install`/`bundle exec`；CocoaPods 使用 `pod install --deployment`。
  - 从 release-critical git 操作中移除 `| true`。
  - release 前 build/test artifact，并增加 SBOM/provenance 生成。
- 验证：
  - 静态审计已确认 workflow 和 release script 模式。
- 剩余风险：token 真实 scope 无法仅从源码确认，需要在 GitHub repository/org settings 中验证 secret 权限。

### WSA-IOS-006：缺少依赖审计 Gate，且多个锁定依赖偏旧

- 严重级别：Medium
- 状态：Likely
- 影响文件：
  - `ArcBlockSDK.podspec:42`
  - `ArcBlockSDK.podspec:44`
  - `ArcBlockSDK.podspec:51`
  - `Podfile:4`
  - `Podfile:7`
  - `Podfile.lock:2`
  - `Podfile.lock:4`
  - `Podfile.lock:17`
  - `Podfile.lock:18`
  - `Podfile.lock:19`
  - `Podfile.lock:20`
  - `Gemfile.lock:6`
  - `Gemfile.lock:69`
  - `Gemfile.lock:173`
- 钱包资产影响：密码学、网络、构建工具依赖偏旧，且缺少自动 advisory gate，会增加已知漏洞或被污染 transitive dependency 进入 consumer 的概率。
- 利用场景：runtime 或 release dependency 出现安全公告，但 CI 没有 OSV/bundle-audit/Dependabot gate，因此 vulnerable version 继续发布。
- 证据：
  - CocoaPods 依赖包括 `CryptoSwift`、`web3swift`、`SwiftProtobuf`、`Starscream`、`secp256k1.swift`。
  - Ruby tooling 锁定 `fastlane 2.182.0`、`addressable 2.8.0`、`rexml 3.2.5`。
  - Git 托管 Pods 在 `Podfile.lock` 中按 commit pin，这优于 floating branch；但没有可见的自动 advisory scanning gate。
  - 本地验证工具不可用：未安装 `osv-scanner` 和 `bundle-audit`；`pod --version` 因缺失 `cocoapods` gem 失败。
- 根因：依赖安全扫描和更新策略没有固化到 CI/release workflow。
- 修复建议：
  - 为 `Podfile.lock`、`Gemfile.lock` 和未来可能出现的 SwiftPM/npm lockfile 添加 OSV-Scanner 或等效 lockfile scanning。
  - 如果继续使用 Bundler 作为 release/CI 工具，添加 `bundler-audit`。
  - 为 CocoaPods、Bundler 和 GitHub Actions 启用 Dependabot 或 Renovate。
  - CI 必须使用 lockfile-respecting install，并在发现 high/critical advisory 时阻断 release。
- 验证：
  - 已完成静态 manifest review。
  - 当前环境没有完成完整漏洞库匹配。
- 剩余风险：如果确认当前 runtime dependency 存在高影响 advisory，严重级别可能需要上调。

### WSA-IOS-007：PASSKEY 已建模但 Key/Sign/Verify 路径静默不支持

- 严重级别：Low
- 状态：Confirmed
- 影响文件：
  - `ArcBlockSDK/ABSDKCoreKit/DidHelper.swift:49`
  - `ArcBlockSDK/ABSDKCoreKit/DidHelper.swift:165`
  - `ArcBlockSDK/ABSDKCoreKit/DidHelper.swift:176`
  - `ArcBlockSDK/ABSDKCoreKit/DidHelper.swift:189`
  - `ArcBlockSDK/ABSDKCoreKit/DidHelper.swift:202`
  - `ArcBlockSDK/ABSDKCoreKit/DidHelper.swift:337`
  - `ArcBlockSDK/ABSDKCoreKit/DidHelper.swift:350`
  - `ArcBlockSDK/ABSDKCoreKit/DidHelper.swift:363`
- 钱包资产影响：静默返回 `nil`/`false` 可能让 caller 把 unsupported passkey flow 当成暂时失败，而不是明确的策略失败。钱包代码中的模糊失败模式可能诱发更弱认证 fallback。
- 利用场景：caller 尝试 passkey DID verification，收到 `false` 后 fallback 到其他更弱 key type，或跳过用户可见的 passkey requirement。
- 证据：
  - DID/key enum 中表示了 PASSKEY。
  - private-key-to-public-key、keypair generation、signing、verification、user public-key extraction 对 PASSKEY 返回 `nil` 或 `false`。
- 根因：public API 中建模了 unsupported key type，但没有 typed unsupported-operation error。
- 修复建议：
  - 在 key generation/sign/verify API 中引入显式 `unsupportedKeyType(.passkey)` error。
  - 在实现完成前将 PASSKEY 方法标记为 unavailable，或完整实现 passkey support 并补充测试。
  - 添加测试，断言 passkey 调用 fail closed，且不能静默 fallback。
- 验证：
  - 静态审计已确认 PASSKEY 分支。
- 剩余风险：真实可利用性取决于下游 consumer fallback 行为。

### WSA-IOS-008：README 暴露 Travis Token-Like 值，RSA 测试打印 Key Material

- 严重级别：Low
- 状态：Confirmed
- 影响文件：
  - `README.md:3`
  - `ArcBlockSDKTests/RSAUtilsSpec.swift:36`
  - `ArcBlockSDKTests/RSAUtilsSpec.swift:49`
  - `ArcBlockSDKTests/RSAUtilsSpec.swift:75`
  - `ArcBlockSDKTests/RSAUtilsSpec.swift:76`
- 钱包资产影响：测试 fixture 不是生产 key，但反复暴露 key material 的模式会提高真实 secret 进入日志的概率。README 中 token-like 值在确认已失效前应按潜在敏感信息处理。
- 利用场景：如果 Travis token-like query parameter 仍然有效，取决于 Travis 配置，它可能暴露 CI metadata 或被滥用。RSA 测试中的 print 可能把生成的私钥材料写入 CI 日志。
- 证据：
  - README badge 包含 `https://travis-ci.com/ArcBlock/arcblock-ios-sdk.svg?token=...`。
  - RSA tests 包含 PEM private key fixture，并打印生成的 public/private key export。
- 根因：测试/debug output 和 legacy badge token 没有在仓库维护时清理。
- 修复建议：
  - 如果 Travis 仍连接该仓库，轮换或撤销 token-like 值。
  - 从 README 移除 token query parameter。
  - 保留 test private key fixture 时明确标记为 fixture，并移除测试中的 key-material `print`。
  - 为 PR 添加 secret-scanning gate。
- 验证：
  - 静态 grep 已确认相关位置。
- 剩余风险：无法从源码判断 Travis token 是否仍有效。

### WSA-IOS-009：默认 Timestamp Nonce 可能碰撞或偏离链上 Nonce 语义

- 严重级别：Low
- 状态：Needs protocol confirmation
- 影响文件：
  - `ArcBlockSDK/ABSDKCoreKit/ABSDKWalletKit/TxHelper.swift:38`
  - `ArcBlockSDK/ABSDKCoreKit/ABSDKWalletKit/TxHelper.swift:47`
  - `ArcBlockSDK/ABSDKCoreKit/ABSDKWalletKit/TxHelper.swift:141`
- 钱包资产影响：nonce 行为不正确可能导致交易被拒绝、replay 语义混乱，或用户签名意图与实际链上处理不一致，具体取决于链协议语义。
- 利用场景：多个交易在同一毫秒内创建，或链要求 account-sequence nonce 而不是本地 timestamp。SDK 会签出链可能拒绝或以非预期方式处理的 payload。
- 证据：
  - caller 没有提供 nonce 时，`TxParams` 默认使用 `UInt64(Date.init().timeIntervalSince1970 * 1000)`。
  - nonce 在签名前写入 transaction。
- 根因：SDK 为一个可能需要链上语义的字段提供了本地 timestamp 默认值。
- 修复建议：
  - 确认 ArcBlock chain transaction 的 nonce 预期语义。
  - 如果 nonce 必须来自链状态，移除默认值，并要求 caller 从可信链查询传入 nonce。
  - 如果 timestamp nonce 是协议设计，增加高并发签名唯一性保证，并添加并发 transaction generation 测试。
- 验证：
  - 静态审计已确认默认值。
  - 未验证协议层行为。
- 剩余风险：如果协议明确规定 nonce 是毫秒 timestamp，该行为可能可接受，但需要文档和测试固化该 contract。

## 供应链审计备注

- 已审计的 package ecosystem：
  - CocoaPods：`ArcBlockSDK.podspec`、`Podfile`、`Podfile.lock`
  - Ruby/Bundler：`Gemfile.lock`
  - npm：`package-lock.json` 存在，但看起来基本为空
  - GitHub Actions：`.github/workflows/*.yml`
  - Make release scripts：`.makefiles/release.mk`、`Makefile`
- Lockfile 状态：
  - `Podfile.lock` pin 了 resolved Pod 版本，并将 Git-hosted Pods pin 到具体 commit。
  - `Gemfile.lock` pin 了 Ruby release tooling。
  - CI 当前运行 `bundle update`，这会削弱可复现性。
- 高风险依赖模式：
  - GitHub Actions 使用 mutable tag，而不是 full-length commit SHA。
  - CI/release workflow 使用 repository secrets，但没有显式 least-privilege `permissions:`。
  - 没有可见的 CocoaPods、Bundler 或 GitHub Actions advisory gate。
- 必要后续验证：
  - 安装 OSV-Scanner 后运行 `osv-scanner scan source -r .`。
  - 安装 `bundler-audit` 后运行 `bundle audit check --update`。
  - 在干净环境中运行 `pod install --deployment`，确认 lockfile 可复现。
  - 在 GitHub 设置中验证 secret scope 和 protected release environment。

## 正向控制

- `MCrypto.generateRandomBytes` 使用 `SecRandomCopyBytes`，这是 iOS 上适合安全敏感随机数的 CSPRNG primitive。
- 内置交易签名路径在 `TxHelper.calculateSignature` 中会先 hash serialized partial transaction data 再签名；digest 长度缺失校验主要存在于较低层 public API。
- CBOR parsing code 包含最大输入大小、最大 depth、最大 key count、最大 array length 等资源限制，降低 parser DoS 风险。
- DID validation 有围绕 DID type decoding 和 checksum validation 的测试。
- `Podfile.lock` 将 Git-hosted Pods pin 到具体 commit，优于只 pin branch 的 Git dependency。
- 仓库中没有发现明显的 `.p12`、`.mobileprovision`、`.pem`、`.key`、`.env`、`GoogleService-Info.plist` 或 signing credential 文件。
- 已审计的 `Info.plist` 文件中没有看到明显的 `NSAllowsArbitraryLoads` ATS bypass 或 URL-scheme 攻击面。

## 建议后续步骤

1. 优先修复 WSA-IOS-001。Seed 派生影响 wallet recovery 和 private-key generation，修复时必须同时考虑兼容性和迁移。
2. 替换或弃用 `AESUtils` 和 `RSAUtils` 的不安全默认值。增加测试，确保非 legacy API 不会使用 ECB、1024-bit RSA 或 OAEP-SHA1。
3. 为 secp256k1/Ethereum sign/verify API 增加 digest 长度校验，并为 0/31/32/33-byte 输入补充回归测试。
4. 加固 CI/release：将 actions pin 到 SHA，收紧 token permissions，尽可能移除 PAT，移除被掩盖的 release 失败，并强制 lockfile-respecting install。
5. 添加 OSV、Bundler 和 GitHub Actions dependency review 等自动依赖 gate。
6. 修复后在干净 CocoaPods/Xcode 环境中重新运行审计，并启用动态测试。
