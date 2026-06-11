# Mihon APKTool Repack Homework

本仓库是移动测试课程 APKTool 随堂练习项目，针对本机 `mihon-main` 项目中的 Mihon APK 完成：

- APKTool 解包
- 资源修改
- APKTool 重打包
- zipalign 对齐
- apksigner 签名与验证

完整实验报告见 [REPORT.md](REPORT.md)。

## 一键运行

默认 APK 来源：

```text
/Users/wayne/Desktop/mihon-main/mihon-apks/universal.apk
```

执行：

```bash
./scripts/run_all.sh
```

也可以显式指定 APK：

```bash
./scripts/run_all.sh /Users/wayne/Desktop/mihon-main/mihon-apks/universal.apk
```

生成产物位于本地 `dist/` 目录，该目录未纳入 Git 管理。

## 主要脚本

```text
scripts/00_check_env.sh          检查 apktool、Java、Android build-tools
scripts/01_decode.sh             使用 apktool d 解包 Mihon APK
scripts/02_modify_resources.sh   修改 app_name 资源字符串
scripts/03_build.sh              使用 apktool b 重打包并 zipalign
scripts/04_sign_verify.sh        生成 keystore、签名并验证
scripts/05_install_optional.sh   可选：通过 adb 安装到设备
scripts/run_all.sh               顺序执行完整流程
```

