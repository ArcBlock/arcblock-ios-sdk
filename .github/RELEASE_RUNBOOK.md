# iOS SDK Release Runbook & Known Issues

> **目的**: 记录 `arcblock-ios-sdk` 当前发布管道的真实状态、坑点、临时 workaround、长期治理项。让团队任何成员看到这份文档就能安全完成 SDK 发布,不重蹈今天 6 轮 CI 拼搏的覆辙。
>
> **诚实声明**: 本文档**故意暴露所有问题**,包括 SDK 仓库内长期失修的环节。"PR 能合并 ≠ 发布管道是好的"。

---

## 1. 仓库与发布拓扑

```
arcblock-ios-sdk (GitHub)
├── master branch                ← 真实代码源
├── tags v0.11.X                 ← 稳定版本锚点
├── GitHub Releases              ← release.yml 自动生成
└── workflows/
    ├── coverage.yml  (PR 触发,目前: build-only)
    ├── main.yml      (master push 触发,即 Prerelease,目前: 损坏)
    └── release.yml   (push tag 触发,目前: 工作)

arc-wallet-ios (downstream)
└── Podfile devPods["ArcBlockSDK/WalletKit"]
    依赖一个 git source + branch/tag + mode 选择
```

---

## 2. 发布管道当前真实状态

| 环节 | 应该的样子 | 实际状态 | 备注 |
|---|---|---|---|
| PR coverage.yml CI | 完整跑 test + 覆盖率 + 评论 PR | ❌ 损坏 | macOS runner 缺 iOS Simulator runtime,降级为 build-only |
| PR review | review + CI 双绿后合并 | ⚠️ 半工作 | CI 是绿的(build-only),但不再是真正测试 gate |
| master push → Prerelease workflow | 自动 bump version + push tag | ❌ 损坏 | `secrets.ACCESS_TOKEN` 未配置/过期 → checkout 失败 |
| Tag push → release.yml | 自动建 GitHub Release | ✅ 工作 | `secrets.GIT_HUB_TOKEN`(注意拼写)居然是配的 |
| Wallet 拉 SDK | `pod install` 立即生效 | ✅ 工作 | mode=`'test'`+`master` 路径稳定 |

**净效**: Wallet 这端用得上 v0.11.50,但**该 release 是手动 tag 出来的,不是 Prerelease 自动跑出来的**。下次 SDK 改完合并到 master,如果不手动 tag,master HEAD 不会自动有新 tag。

---

## 3. 已知问题(全部如实暴露)

### 3.1 GitHub macOS runner image 不稳定

**症状**: 一周内 6 轮 CI,每次 `Available destinations` 不一样:
- Run 1-2: iPad (10th gen) 18.5/18.6/26.0.1 可用
- Run 3+: 任何 iOS Simulator 都没装,只剩 Mac Catalyst placeholder

**根因**: GitHub 在迁移 `macos-latest` 到 macos-26 的过渡期,新 image 不再预装 iOS Simulator runtime。

**Workaround**:
- 当前 `coverage.yml` 改成 build-only (`destination=platform=macOS,variant=Mac Catalyst`),不依赖 simulator
- 长期: **self-hosted runner**(团队 Mac mini 装 Xcode 16.1 + simulator)

### 3.2 `secrets.ACCESS_TOKEN` 未配置 → Prerelease workflow 死

**症状**: master push 后 `Prerelease` workflow 失败:
```
fatal: could not read Username for 'https://github.com': terminal prompts disabled
```

**根因**: `main.yml` 用 `actions/checkout@v2` + `token: ${{ secrets.ACCESS_TOKEN }}`,而 `ACCESS_TOKEN` repo secret 不存在或已过期。注释里说明必须用 PAT(不能用内置 GITHUB_TOKEN,否则 push tag 不触发后续 push event)。

**修复路径**(必须 owner 操作):
1. Repo Settings → Secrets and variables → Actions → New repository secret
2. Name: `ACCESS_TOKEN`
3. Value: 一个具有 `repo` scope 的 Personal Access Token (生成于 GitHub Settings → Developer settings → PAT)

修好之前,**只能手动打 tag** 触发 release。

### 3.3 pbxproj 不与源代码同步

**症状**: Phase 1-5 commits 加了 `CanonicalCBOR/*` 和 `TxCodec/*` swift 文件,但 `ArcBlockSDK.xcodeproj/project.pbxproj` 不知道它们存在。`xcodebuild test` 报 `Cannot find 'TxCodec' in scope`。

**根因**: 提交 SDK source 文件时只管 `git add *.swift`,忘了在 Xcode GUI 把文件加到 ArcBlockSDK / ArcBlockSDKTests target。Pod 模式下,`source_files` glob 自动包含,**所以下游 wallet 集成场景看不到这个问题** — 只有 SDK 自己工程链路才暴露。

**今天的修复**: `eac422e` commit 用 `xcodeproj` Ruby gem 一次性补齐 13 + 2 + 5 swift 文件 + 资源。

**长期治理**: PR 模板加一行 "如果新增 .swift 文件到 SDK 模块,确保已在 Xcode 工程加到对应 target 的 Compile Sources"。或加一个 lint 脚本对比 source_files glob vs pbxproj。

### 3.4 Makefile / CI yml 写死 iPhone 8

**症状**: master 上 `Makefile` `test:` 目标 destination=iPhone 8,`coverage.yml` destination=iPhone 8。runner 早就不装 iPhone 8 了。

**根因**: 开发时间未维护,master 上长期失修 — 只是没人提 PR 撞上。

**修复**: PR `8833eef` 改 destination 到 iPad 10th gen,后续因 runner image 演化又改了几次,最终 build-only。Makefile 没动,因为不是 CI 必跑。

### 3.5 测试代码用了较新 SwiftProtobuf 1.28+ API + 较新 schema

**症状**:
```
incorrect argument label in call (have 'serializedBytes:', expected 'serializedData:')
value of type 'Ocap_DelegateTx' has no member 'deny'
```

**根因**: phase 3 commits 写测试时,作者本机 SwiftProtobuf >= 1.28(用了新 API `init(serializedBytes:)`),且本地有更新的 protobuf schema(`Ocap_DelegateTx.deny` / `validUntil` 字段)。仓库的 protobuf 头较旧,CI 上的 SwiftProtobuf 也较旧。

**修复**: PR `885fbd8` 把测试代码降级到 `serializedData:` + 删掉新字段引用。

### 3.6 web3swift / wallet-connect-swift / TweetNacl Xcode 26 / Swift 6 兼容

**症状**: Xcode 26 + Swift 6 下,`data.bytes` 返回 `RawSpan` 而非 `[UInt8]`;CTweetNacl modulemap 路径解析问题。

**根因**: 这些第三方 pod 老旧,不再维护或还没出 Swift 6 兼容版本。

**Workaround**:
- Wallet 仓库有 `Script/fix-xcode26.sh` 修 wallet-connect-swift 和 R.swift
- Wallet `Podfile` 有 post_install hook 修 Solana.Swift 和 TweetNacl modulemap
- SDK 仓库现状: 没有等价 patch 脚本,本地用 Xcode 26 跑 SDK 测试需要手动 patch web3swift

**长期**: 升级 web3swift 版本或换 fork。或全员保持 Xcode 16.x,**不要升级到 26.x 直到第三方 pod 跟上**。

### 3.7 `xcodebuild -downloadPlatform iOS` 不能在 CI 上 scripted

**症状**: 想在 CI 里下载 iOS Simulator runtime,命令会卡在 Apple ID 登录 prompt。

**根因**: Apple 把 platform download 跟 Apple ID 绑定。

**Workaround**: 不在 CI 上 download,改用 self-hosted runner(预装好的环境)或退到 Mac Catalyst build。

### 3.8 PR description DRAFT 标记残留

**症状**: PR #129 body 第一行有 `> **DRAFT** — paste into gh pr create --body after pushing branch.`,这是 SDK_PR.md 模板作者注释。

**修复**: `gh pr edit 129 --body-file SDK_PR.md`(已修)。

**长期**: PR 模板写好后立即从 SDK_PR.md 移除作者注释段,避免下次再泄漏。

---

## 4. 完整发布 SOP(给后人)

### 4.1 SDK 改动 → 发布

```bash
# 1. 在 SDK feat/xxx 分支开发,本地通过验证

# 2. 推 PR
git push -u origin feat/xxx
gh pr create ...
# CI 跑 build-only smoke (Mac Catalyst),全绿后让 reviewer 在本地 Xcode 16.1 跑一次完整 test

# 3. 合并 PR 到 master

# 4. ⚠️ Prerelease workflow 当前损坏,必须手动打 tag:
git fetch origin master
git tag vX.Y.Z origin/master
git push origin vX.Y.Z

# 5. Tag push 触发 release.yml,自动建 GitHub Release
gh release view vX.Y.Z --repo ArcBlock/arcblock-ios-sdk
```

### 4.2 Wallet 集成 SDK 新版本

```bash
# 在 wallet 仓库
# 改 Podfile L36 dev pods 的 mode + branch/tag 配置:

# 持续跟最新(常态,develop 分支用):
"ArcBlockSDK/WalletKit" => [URL, 'master', 'master', 'test']

# 锁版本(切 release branch 准备发版时用):
"ArcBlockSDK/WalletKit" => [URL, 'master', 'vX.Y.Z', 'release']

# 本地联调(开发期临时,合并前必须改回去):
"ArcBlockSDK/WalletKit" => [URL, 'feat/xxx', 'master', 'dev']

# 跑 pod install,验证版本
pod install
grep ArcBlockSDK Podfile.lock  # 应显示目标版本
```

---

## 5. 长期治理项(优先级排序)

| # | 项目 | 影响 | 谁来做 | 难度 |
|---|---|---|---|---|
| 1 | 配置 `secrets.ACCESS_TOKEN` PAT | Prerelease 自动 bump + tag,不再需要手动 | repo owner (Pengfei) | 5 分钟 |
| 2 | Self-hosted macOS runner(团队 Mac) | CI 真测试可恢复 | DevOps | 1 天 |
| 3 | pbxproj sync lint(脚本对比 source_files glob vs pbxproj) | 防止再有 phase 5 那种漏更 | SDK 维护者 | 半天 |
| 4 | 升级 web3swift / 升级 / 换 fork | Xcode 26 兼容,长期可维护 | SDK 维护者 | 1-2 天调研 + 验证 |
| 5 | PR 模板加 "新增源文件检查" 提示 | 防漏 pbxproj | repo owner | 10 分钟 |
| 6 | Makefile `test:` destination 跟 CI 同步 | 本地 `make test` 可用 | SDK 维护者 | 5 分钟 |

---

## 6. 本次 PR #129 (canonical CBOR) 在以上问题中的位置

| 问题 | 这次 PR 处理方式 |
|---|---|
| 3.1 runner image | downgrade coverage.yml 为 build-only(commit `4754df9`/`35668d8`) |
| 3.2 ACCESS_TOKEN | **没修**,handler 由手动 tag 兜底(`v0.11.50` 是手动打的) |
| 3.3 pbxproj sync | 修了 PR 自身漏的(`eac422e`),没加 lint 脚本 |
| 3.4 iPhone 8 destination | 修了 coverage.yml(`8833eef`),Makefile 没动 |
| 3.5 SwiftProtobuf API | 测试代码降级(`885fbd8`) |
| 3.6 web3swift Xcode 26 | **没修**,绕过(CI 用 Mac Catalyst,不撞 web3swift simulator path) |
| 3.7 download platform | 试过失败(`ff4f893`),最终 sidestep |
| 3.8 DRAFT 残留 | 修了(`gh pr edit`) |

**因此本 PR 是**: 修复了 PR 内容相关的问题 + workaround 了仓库基础设施问题,**没有解决基础设施根本问题**。下个 SDK PR 仍然会撞 3.1 / 3.2 / 3.6,需要长期治理(章节 5)。

---

## 7. 维护

这份 runbook 跟 SDK 仓库一起演进。每次发现新坑,在 §3 "已知问题"加一节;每次解决一项,在 §5 "长期治理项"标记 ✅ 并在 §3 注明已修复(连带 commit hash)。

下次有人尝试 SDK release 但卡住,**第一件事是读这份文档**,别从零拼搏 6 轮 CI。
