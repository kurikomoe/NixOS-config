# 文件组织说明

@output: 成品文件

@temp: 临时文件

@refs: 参考用资料，禁止通过代码或者别的方式引用这个目录下的文件

## 临时文件

所有的临时文件和临时调用的脚本，请写入到 @temp 文件夹中，并且不需要删除和清理（方便我之后 review）


# 工具说明

根目录已经使用 uv venv 创建了 virtualenv，你可以使用任何 python 命令，或者使用 pip 安装任何包

系统中存在 nodejs，你可以安装任何 node packages

# 额外工具安装说明

系统是 NixOS，如果你有任何需要安装的工具，先输出出来，之后使用 question 相关的命令暂停执行，我在安装完相关工具后会通过 question 返回结果

请尽量使用非安装软件包的方式执行工具。

## 额外工具查找说明

你可以调用 `nix-search toolname` 命令来查找需要的工具。

目录中有 direnv（参见 .envrc 和 nix/flake.nix），你可以通过修改 nix/flake.nix 的方式添加需要的软件）

你可以通过 `nix shell nixpkgs#cowsay -c cowsay "Temp run"` 的形式直接调用相关的程序

