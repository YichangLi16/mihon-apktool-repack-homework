# APKTool 解包、修改与重打包实验报告

## 1. 实验对象

本次实验针对大作业项目 `mihon-main` 中的 Mihon APK 进行逆向修改与重打包验证。

- 项目路径：`/Users/wayne/Desktop/mihon-main`
- 项目远程仓库：`https://github.com/YichangLi16/mihon-testing-homework.git`
- 项目分支：`yichang/chapter-update-tests`
- 项目提交：`331f51d`
- 被测 APK：`/Users/wayne/Desktop/mihon-main/mihon-apks/universal.apk`
- 包名：`app.mihon.dev`
- 版本号：`0.19.9-11`
- versionCode：`22`
- 源 APK SHA-256：`d167333e8504bff3baa8e6f5f8276e5df0767c4d3ad952bf58049fb03264db4a`

## 2. 参考课件内容

参考课件 `MT2026-L14-Android应用逆向分析技术-v1-r3-20260611.pdf` 中第 14.2 和 14.3 节：

- 使用 APKTool 对 APK 执行反汇编：`apktool d app-debug.apk`
- 查看反汇编目录，重点关注 `smali` 相关目录
- 修改反汇编目录中的资源或 smali 代码
- 使用 APKTool 对修改后的目录重新打包：`apktool b app-debug -o app-debug-1.apk`
- 对重新打包后的 APK 进行签名

本实验按照上述流程完成：解包、资源修改、重打包、签名和验证。

## 3. 实验环境

```text
macOS
APKTool 3.0.2
Java 25
Android SDK build-tools 37.0.0
apksigner
zipalign
```

环境检查脚本：

```bash
./scripts/00_check_env.sh
```

实际输出摘要：

```text
apktool: 3.0.2
java: openjdk version "25" 2025-09-16
build-tools: /Users/wayne/Library/Android/sdk/build-tools/37.0.0
```

## 4. APKTool 解包

命令：

```bash
apktool d /Users/wayne/Desktop/mihon-main/mihon-apks/universal.apk \
  -o work/mihon_decoded \
  -f
```

对应脚本：

```bash
./scripts/01_decode.sh
```

解包后目录中包含多个 smali 目录，说明 APK 中存在多 dex：

```text
work/mihon_decoded/smali
work/mihon_decoded/smali_classes2
...
work/mihon_decoded/smali_classes38
```

`AndroidManifest.xml` 中应用标签引用如下：

```xml
<application
    android:label="@string/app_name"
    android:name="eu.kanade.tachiyomi.App" />
```

## 5. 修改内容

为了保证修改可验证且不破坏核心业务逻辑，本次选择修改应用名称资源。

修改文件：

```text
work/mihon_decoded/res/values/strings.xml
```

修改前：

```xml
<string name="app_name">Mihon</string>
```

修改后：

```xml
<string name="app_name">Mihon APKTool Demo</string>
```

对应脚本：

```bash
./scripts/02_modify_resources.sh
```

该修改会影响 Launcher 中显示的应用名称，可以用于安装后的可视化验证。

## 6. 重打包与 zipalign

命令：

```bash
apktool b work/mihon_decoded -o dist/mihon-apktool-demo-unsigned.apk
zipalign -f -p 4 \
  dist/mihon-apktool-demo-unsigned.apk \
  dist/mihon-apktool-demo-aligned.apk
```

对应脚本：

```bash
./scripts/03_build.sh
```

实际输出摘要：

```text
I: Built apk into: dist/mihon-apktool-demo-unsigned.apk
Unsigned APK: dist/mihon-apktool-demo-unsigned.apk
Aligned APK: dist/mihon-apktool-demo-aligned.apk
```

## 7. 签名与验证

使用实验 keystore 对 aligned APK 进行签名。

对应脚本：

```bash
./scripts/04_sign_verify.sh
```

签名验证结果摘要：

```text
Verifies
Verified using v1 scheme (JAR signing): false
Verified using v2 scheme (APK Signature Scheme v2): true
Verified using v3 scheme (APK Signature Scheme v3): true
Number of signers: 1
```

签名后 APK：

```text
dist/mihon-apktool-demo-signed.apk
```

签名 APK SHA-256：

```text
366b7dfb1697cbc7ad94972b579f0191ad76d7c6c12a6d2c70ed6c0446492641
```

## 8. 结果验证

为了验证重打包后的 APK 中确实保留了修改内容，对签名后的 APK 再次使用 APKTool 反解：

```bash
apktool d dist/mihon-apktool-demo-signed.apk -o work/verify_decoded -f
```

验证结果：

```text
work/verify_decoded/AndroidManifest.xml:
android:label="@string/app_name"

work/verify_decoded/res/values/strings.xml:
<string name="app_name">Mihon APKTool Demo</string>
```

说明最终签名 APK 中已经包含修改后的应用名称资源。

随后使用 Android Studio 虚拟机 `Pixel_7_2` 进行 adb 安装验证。

启动并等待设备在线：

```bash
emulator -avd Pixel_7_2 -no-snapshot-load -no-audio -no-boot-anim
adb devices -l
```

设备状态：

```text
emulator-5554 device product:sdk_gphone16k_arm64 model:sdk_gphone16k_arm64 device:emu64a16k
```

首次执行 `adb install -r` 时，虚拟机中已经存在同包名应用，且签名不同，因此出现更新安装失败：

```text
INSTALL_FAILED_UPDATE_INCOMPATIBLE: Existing package app.mihon.dev signatures do not match newer version
```

因此先卸载旧包，再安装重签名 APK：

```bash
adb uninstall app.mihon.dev
adb install dist/mihon-apktool-demo-signed.apk
```

安装结果：

```text
Success
Performing Incremental Install
Success
Install command complete in 920 ms
```

安装后查询包信息：

```bash
adb shell pm list packages | grep app.mihon.dev
adb shell pm path app.mihon.dev
adb shell dumpsys package app.mihon.dev
```

输出摘要：

```text
package:app.mihon.dev
package:/data/app/.../app.mihon.dev-.../base.apk
versionCode=22 minSdk=26 targetSdk=36
versionName=0.19.9-11
firstInstallTime=2026-06-11 09:07:28
lastUpdateTime=2026-06-11 09:07:28
```

解析主 Activity：

```bash
adb shell cmd package resolve-activity --brief app.mihon.dev
```

输出：

```text
app.mihon.dev/eu.kanade.tachiyomi.ui.main.MainActivity
```

启动应用：

```bash
adb shell monkey -p app.mihon.dev -c android.intent.category.LAUNCHER 1
```

输出：

```text
Events injected: 1
```

Launcher 数据中可见修改后的应用名称：

```text
targetComponent=ComponentInfo{app.mihon.dev/eu.kanade.tachiyomi.ui.main.MainActivity}
title=Mihon APKTool Demo
```

虚拟机截图见：[screenshots/emulator-mihon-apktool-demo.png](screenshots/emulator-mihon-apktool-demo.png)。

## 9. 实验结论

本实验基于 Mihon 项目 APK 完成了 APKTool 解包、资源修改、重打包、zipalign、签名、签名验证和虚拟机安装验证。通过对最终签名 APK 的二次反解，确认修改后的 `app_name` 已写入重打包产物；通过 adb 安装、包信息查询、主 Activity 启动和 Launcher 标题检查，确认重打包 APK 可以在 Android 虚拟机中安装和运行。
