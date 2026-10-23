# PokeBonk-iOS

把网页游戏 **https://pokebonk.com/** 封装成一个全屏 WebView 的 iOS App。
你的条件：Windows 电脑 + iPhone（iOS 26）、没有 Mac、不上架、只自己装。

本工程走的路线：

```
Windows 写代码(本仓库)  →  推到 GitHub  →  GitHub Actions(macOS) 编译出【未签名 IPA】
        →  下载到 Windows  →  Sideloadly/AltServer 用你的 Apple ID 现场签名并装进 iPhone
```

**不需要 Mac，不需要向任何人（包括我）提供 Apple ID 密码或私钥。**

---

## 一、当前交付物状态（如实说明）

| 产物 | 状态 | 说明 |
|---|---|---|
| Xcode 工程源码（SwiftUI + WKWebView） | ✅ 已生成 | 见 `PokeBonk/` |
| GitHub Actions 云端构建配置 | ✅ 已生成 | 见 `.github/workflows/build-unsigned-ipa.yml` |
| App 图标（精灵球占位图） | ✅ 已生成 | `Icon-1024.png`，可自行替换 |
| **未签名 IPA** | ⏳ 需你触发一次构建 | 本机是 Windows，无 Xcode，**我无法在这里真实编译**；推到 GitHub 后由 macOS runner 产出 |
| **已签名 IPA** | ⏳ 在你 Windows 上由 Sideloadly 现场完成 | 用你自己的免费 Apple ID，密码只输入在 Sideloadly 里 |
| **真机安装成功** | ⏳ 需要你装好后反馈 | 流程见第四节 |

> 我没有伪造任何"构建成功"截图。第一次 GitHub Actions 构建如果报错，把日志贴给我，我来修。

---

## 二、一次性准备（约 10 分钟）

### 1. 建 GitHub 仓库并推上去

1. 注册/登录 <https://github.com>，新建一个 **Private** 仓库，名字随意，例如 `pokebonk-ios`。
2. 把本 ZIP 解压后的全部内容作为仓库根目录推送：

   ```powershell
   cd PokeBonk-iOS
   git init
   git add .
   git commit -m "PokeBonk iOS wrapper"
   git branch -M main
   git remote add origin https://github.com/<你的用户名>/pokebonk-ios.git
   git push -u origin main
   ```

   没有 git 的话，也可以在 GitHub 网页上 `Add file → Upload files` 把整个文件夹拖上去（注意保留 `.github/workflows/` 这个隐藏目录，网页上传时它是可见的）。

### 2. 触发构建

- 推送后 Actions 页会自动开始跑 `Build Unsigned IPA`；
- 或者到仓库 **Actions → Build Unsigned IPA → Run workflow** 手动点一次。
- 跑完（约 5–10 分钟），在该次运行页面底部 **Artifacts → `PokeBonk-unsigned-ipa`**，下载得到一个 zip，解压出 `PokeBonk-unsigned-v1.0.0.ipa`。

> 免费账号的私有仓库：macOS 构建按 10 倍计费，每月额度约够构建 20 次；把仓库设为 Public 则不限量。这个工程不含任何隐私信息，设 Public 即可。

---

## 三、Windows 上签名 + 安装（推荐 Sideloadly）

### 1. 装依赖

- 安装 **iTunes**（必须从 <https://www.apple.com/itunes/download/> 下桌面版，**不要**用 Microsoft Store 版）和 **iCloud**。装完插手机能被 iTunes 识别即可。
- 下载 **Sideloadly**：<https://sideloadly.io/>（免费，Windows 版），安装打开。

### 2. 签名并安装

1. iPhone 用数据线连 Windows，手机上弹"是否信任此电脑"点**信任**并输锁屏密码。
2. 打开 Sideloadly：
   - **IPA** 一栏拖入下载到的 `PokeBonk-unsigned-v1.0.0.ipa`；
   - **Apple account** 填你自己的 Apple ID（随便一个免费的就行，**密码只在这一步输入，不会发给我也不会上传**）；
   - 其它默认，点 **Start**。
3. 首次会要求输入 Apple ID 的 **App-Specific Password**？不需要——免费账号直接用账号密码即可；若你开了双重认证，Sideloadly 会引导你在 appleid.apple.com 生成一个**专用密码**填进去（这也是在你自己浏览器里完成的）。

### 3. iPhone 上信任证书

装完后 App 图标会出现，但点开闪退：

- 打开 **设置 → 通用 → VPN 与设备管理**（iOS 26 路径，旧系统叫"设备管理/描述文件"）；
- 点你那个 Apple ID 对应的开发者证书 → **信任**。

现在打开就是全屏 PokéBonk 了。

### 备选：AltServer

如果 Sideloadly 不顺手，用 **AltServer**（<https://altstore.io/>，Windows 版）：
连上手机 → AltServer 菜单 **Install AltStore** 先装 AltStore，之后在手机 AltStore 里"打开 IPA"选中下载的未签名 IPA 即可。流程与 Sideloadly 等价。

---

## 四、免费 Apple ID 的限制（必读）

- **7 天过期**：免费个人账号签名的 App 每 7 天失效。到期前用数据线连一次电脑，Sideloadly/AltServer 会自动续签；不想续就花 $99/年买个开发者账号（签一次管 1 年）。
- **同时 3 个**：免费账号同一时间只能装 3 个自签 App，删掉一个就能装新的。
- iOS 26 太新，**TrollStore 用不了**（它最高支持到 iOS 17.0b1），别浪费时间找；本方案不需要越狱。

---

## 五、想改网址 / 改 Bundle ID

- **游戏地址**：改 `PokeBonk/WebGameView.swift` 顶部的 `gameURL`。
- **Bundle ID**：改 `PokeBonk.xcodeproj/project.pbxproj` 里两处 `PRODUCT_BUNDLE_IDENTIFIER = com.pokebonk.wrapper;`（Debug/Release 各一行）。免费账号要求 Bundle ID 全球唯一，撞车的话随便加后缀，例如 `com.你的名字.pokebonk123`。
- 改完 push，Actions 会自动重新出包。

---

## 六、排错

| 现象 | 处理 |
|---|---|
| Actions 红叉，日志卡在 `xcodebuild archive` | 把红叉那一步的完整日志发我；最常见是 runner 上 Xcode 版本路径问题，工作流已自动选最新版，一般无需改 |
| Sideloadly 报 `Unable to install` / 网络错误 | 换网络（或手机热点），确认 iTunes 能识别手机 |
| 装上点开秒退 | 99% 是没"信任证书"，见三-3；其次是 Apple ID 密码错或开了双重认证没填专用密码 |
| 进游戏黑屏/转圈 | 确认手机能打开 https://pokebonk.com/；点 App 内"重试"按钮 |
| 游戏操作时页面跟着滚动 | 本工程已禁用滚动/橡皮筋；若仍有问题反馈我 |
