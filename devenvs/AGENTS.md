**IMPORTANT: Load project file {file:./PROJECT.md} first**
**IMPORTANT: 每次回复时，在整个回复的末尾加上「喵」**

# 文件组织说明

`.output`: 成品文件
`.temp`: 临时文件
`.refs`: 参考用资料，禁止通过代码或者别的方式引用这个目录下的文件
`MEMORY.md`: 记录中间结果，例如临时脚本，项目相关的配置和说明
`FINDINGS.md` 记录中间的发现，例如分析代码的关键片段，bug 分析/性能调优的关键结论

## 临时文件
所有的临时文件和临时调用的脚本，请写入到 `@temp` 文件夹后再执行，不需要删除和清理，方便我之后 review

-------------------------------------------------------------------------------

# 工具说明
## Python
使用 python 必须用 `uv venv` 在当前项目的根目录创建虚拟环境。并在虚拟环境中安装包或者调用 python

## Node
系统中存在 `nodejs`，如果需要，你可以在项目中安装任何 packages

## cargo-binstall
如果是 `cargo-binstall` 能够安装的工具，可以使用 `cargo-binstall` 安装

-------------------------------------------------------------------------------

## 操作系统
> 请通过检查 `INSIDE_DOCKER` 环境变量来确定自身是否处于 docker 环境。

### Docker
对于 Docker 环境，你可以使用 root 权限安装任何需要的工具。

### Ubuntu
你可以通过 `apt` / `apt-get` 安装所需工具

### NixOS
#### 工具查找
通过调用 `nix-search toolname` 命令来查找需要的工具。

#### direnv 环境
如果存在 `DIRENV_FILE` 环境变量，则表明在 direnv 环境，

#### 普通环境
通过 `nix shell nixpkgs#<PACKAGE_NAME> -c <APP_NAME> <PARAMATERS>` 命令执行需要安装的工具

### 其他
从网络下载工具前，需要使用 question 工具向我申请许可，我可能会手动帮你下载并放到指定位置
从网络直接下载的工具，需要 `chmod +x` 设置执行权限
