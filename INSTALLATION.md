# 安装说明 / INSTALLATION

## 声明

HMCL 主程序来自开源项目 [HMCL-dev/HMCL](https://github.com/HMCL-dev/HMCL)。

本仓库生成的 `HMCL.app` 只是一个**简单封装**，用于在 macOS 上双击直接启动 `HMCL.jar`，**本包作者未对上游源程序做任何修改**。

本包按“原样（AS IS）”提供，使用过程中产生的任何问题与 BUG **均不负责**。

## 安装

- 将 `HMCL.app` 拖拽到 `Applications`（应用程序）目录即可。

## macOS 安全提示（已损坏 / 不安全）

如果在 macOS 上打开 `HMCL.app` 时提示“已损坏”或“不安全”，通常是 Gatekeeper 的隔离属性导致。你可以在终端执行以下命令移除隔离标记后再打开：

```bash
xattr -rd com.apple.quarantine /Applications/HMCL.app
```
