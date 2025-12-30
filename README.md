# HMCL for macOS

## 这是什么

这是一个用于 **在 macOS 上自动封装/打包 HMCL** 的仓库：自动获取上游最新 Release 的 `HMCL.jar`，生成 `HMCL.app`，并可进一步打包成可拖拽安装的 `HMCL.dmg`。

- **上游项目**：HMCL 主程序来自开源项目 [HMCL-dev/HMCL](https://github.com/HMCL-dev/HMCL)
- **本仓库做的事**：仅提供 macOS 封装与打包脚本（不修改上游程序逻辑），方便用户双击启动与拖拽安装

> 提醒：本仓库不会把 `HMCL.jar` 或 HMCL 源码提交进仓库；构建时会通过 GitHub API 下载缓存到本地 `.cache/`。

## 快速开始

在仓库根目录执行：

```bash
make workflow
```

它会依次完成：

- 通过 GitHub API 获取最新 Release，并下载 `HMCL.jar` 到 `.cache/`（已下载则跳过）
- 从 `icon/HMCL.png` 生成 `HMCL.icns`
- 创建 `.output/HMCL.app`（把 jar 与图标复制到 `Contents/Resources/`）
- 创建 `.output/HMCL.dmg`（包含 `HMCL.app`、`Applications` 软链接、以及说明/许可证文件）

## 产物与缓存目录

- **产物目录**：`.output/`
  - `HMCL.app`
  - `HMCL.dmg`
  - `HMCL.icns`
- **缓存目录**：`.cache/`
  - `HMCL-latest.jar`：固定入口（软链接指向缓存的 jar 文件名）
  - `hmcl-latest.json`：记录本次使用的上游 Release 信息（例如 `tag_name`、下载链接等）
  - `LICENSE-HMCL.txt`：上游许可证文本（构建时下载缓存）

## 常用命令

- **只下载 jar（缓存）**：

```bash
make jar
```

- **只缓存上游 LICENSE**：

```bash
make license
```

- **只生成 icns / app / dmg**：

```bash
make icon
make app
make dmg
```

- **安装到本机 Applications（方便测试，会备份现有存档）**：

```bash
make install-app
```

## 系统依赖

本仓库假设你在 macOS 上运行，并可使用系统自带工具：

- `curl`（下载）
- `jq`（解析 GitHub API 返回的 JSON）
- `sips` / `iconutil`（生成 `.icns`）
- `hdiutil`（生成 `.dmg`）
- `make` / `bash`

其中 `jq` 可能需要自行安装（例如使用 Homebrew）：

```bash
brew install jq
```

运行 `HMCL.app` 时，系统需要能找到 `java`（脚本会优先使用 `/usr/libexec/java_home`，否则使用 `PATH` 中的 `java`）。

## macOS 提示“已损坏 / 不安全”

如果打开 `HMCL.app` 时提示“已损坏”或“不安全”，可以移除隔离属性后再打开：

```bash
xattr -rd com.apple.quarantine /Applications/HMCL.app
```

## 许可证与合规说明

- **本仓库脚本/封装文件**：使用 `LICENSE`（MIT License）。
- **HMCL（上游）**：许可证与条款以 [HMCL-dev/HMCL](https://github.com/HMCL-dev/HMCL) 为准；本仓库在打包 dmg 时会附带：
  - `LICENSE-HMCL.txt`（上游许可证文本）
  - `SOURCE_CODE.md`（说明如何按 `tag_name` 获取对应源代码）
  - `HMCL-RELEASE.json`（本次使用的 Release 元数据）
  - `INSTALLATION.md`（声明与安装说明）

本仓库不对上游程序做任何修改；打包产物按“原样（AS IS）”提供，风险自担。
