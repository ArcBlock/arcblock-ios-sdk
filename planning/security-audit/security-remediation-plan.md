# 安全修复计划：arcblock-ios-sdk

本计划整合了 2026-05-09 (Codex) 和 2026-05-11 (Gemini) 的审计发现，并根据风险等级梳理了分阶段的修复路径。

## 1. 审计报告整合

### 1.1 2026-05-11 审计报告 (Gemini)
> [!IMPORTANT]
> 完整内容详见：`./wallet-security-audit-2026-05-11.md`

**核心发现：**
- **SDK-IOS-001 (High)**: 自定义 Seed 派生逻辑使用了哈希截断。
- **SDK-IOS-002 (Medium)**: `AESUtils` 使用了不安全的 ECB 模式。
- **SDK-IOS-003 (Medium)**: `RSAUtils` 默认使用较弱的 1024 位密钥。

---

### 1.2 2026-05-09 审计报告 (Codex)
> [!IMPORTANT]
> 完整内容详见：`./wallet-security-audit-2026-05-09.md`

**核心发现：**
- **WSA-IOS-001 (High)**: 自定义钱包 Seed 派生使用一次性 Hash 和截断。
- **WSA-IOS-002 (Medium)**: `AESUtils` 使用 AES-ECB 且没有认证加密。
- **WSA-IOS-003 (Medium)**: `RSAUtils` 默认使用 1024-bit RSA。
- **WSA-IOS-004 (Medium)**: secp256k1/Ethereum 签名 API 没有限制 32-byte digest 输入长度。
- **WSA-IOS-005 (Medium)**: CI/Release 供应链存在 Mutable Action 和被掩盖的失败。
- **WSA-IOS-007 (Low)**: PASSKEY 已建模但实现路径静默不支持。

## 2. 审计对比分析

- **一致性**：两份报告在 SDK 的核心密码学缺陷（Seed 派生、AES-ECB、RSA 长度）上完全对齐。
- **准确性**：SDK 作为 DID 钱包的底层底座，其加密原语的安全直接影响所有消费方应用，修复优先级较高。
- **结论**：修复非标准加密实现是首要任务。

## 3. 分阶段执行计划

### 阶段 1：密码学原语修正 (High Priority)
- [ ] **重构 Seed 派生 (SDK-IOS-001)**：
    - 废弃自定义的 `getEntropy` 截断哈希算法。
    - 转向 BIP39 标准的助记词与熵值生成。
- [ ] **加固 AES 工具 (SDK-IOS-002)**：
    - 弃用 `AES/ECB/PKCS5Padding`。
    - 默认采用 `AES-GCM`，支持 Nonce 和认证标签。
- [ ] **提升 RSA 强度 (SDK-IOS-003)**：
    - 将默认 `kSecAttrKeySizeInBits` 从 1024 提升至 3072。
    - 默认改用 SHA-256 OAEP Padding。

### 阶段 2：API 健壮性与安全边界 (Medium Priority)
- [ ] **签名输入校验 (WSA-IOS-004)**：
    - 在 secp256k1 签名 API 中增加 `guard message.count == 32` 强制校验。
- [ ] **Passkey 路径修正 (WSA-IOS-007)**：
    - 将 Passkey 分支从静默返回 `nil` 改为抛出 `unsupportedKeyType` 异常，实现 Fail-Closed。

### 阶段 3：供应链与 CI 加固 (Governance)
- [ ] **Action Pinning (WSA-IOS-005)**：将所有第三方 GitHub Action pin 到 Commit SHA。
- [ ] **清理 Release 脚本 (WSA-IOS-005)**：
    - 移除 `.makefiles/release.mk` 中掩盖失败的 `| true` 逻辑。
    - 为 Workflow 配置显式的最小权限 `permissions`。
- [ ] **依赖漏洞扫描 (WSA-IOS-006)**：在 CI 中引入 `osv-scanner` 自动扫描依赖清单。

## 4. 后续跟进
- 发布包含安全修复的 SDK 新版本，并通知 `arc-wallet-ios` 等消费方进行升级。
- 在 `ArcBlockSDKTests` 中增加针对 0/31/33 字节等异常输入长度的鲁棒性测试。
