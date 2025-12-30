# 对应源代码获取方式（GPLv3）

本 dmg 内包含的 `HMCL.jar` 来自开源项目 [HMCL-dev/HMCL](https://github.com/HMCL-dev/HMCL) 的 Release 构建产物。

为方便你获取与本 dmg 内 `HMCL.jar` **对应的源代码**，我们在 dmg 根目录同时附带：

- `HMCL-RELEASE.json`：记录本次使用的上游 Release 信息（例如 `tag_name`、下载链接等）
- `LICENSE-HMCL.txt`：上游项目的许可证文本（GPLv3）

## 获取源代码

1. 打开 `HMCL-RELEASE.json`，找到其中的 `tag_name`（例如 `v3.8.2`）。
2. 使用以下任一方式获取对应版本的源代码：
   - 对应 tag 的源码：`https://github.com/HMCL-dev/HMCL/tree/<tag_name>`
   - 对应 tag 的 Release 页面：`https://github.com/HMCL-dev/HMCL/releases/tag/<tag_name>`

说明：本封装仅用于 macOS 双击启动，未对上游程序做任何修改。
