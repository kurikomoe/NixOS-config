# Neovim 配置

Neovim 使用模块化 Lua、Lazy、Mason 和原生 LSP。普通 Vim 继续使用原来的 Nix 插件列表，`init.vim` 和 `.confvim/vimrc` 保留；两套配置独立。不要把整个目录直接链接到 `~/.config/nvim`，否则旧 `init.vim` 会与新 `init.lua` 冲突。

## 部署和依赖

通过本仓库的 Home Manager 配置部署。首次应用前需将新增文件纳入 Git，否则 Git flake 不会包含这些文件。Nix 提供 Neovim、Git、下载解压工具、C 编译器、Make、Node/npm、Go、Python/pip、ripgrep、fd 和 tree-sitter CLI。首轮安装需要联网：

- Lazy 安装插件并编译 LuaSnip/jsregexp、Telescope fzf 扩展。
- 打开代码文件后，Mason 安装语言服务器；格式化工具为 Stylua、Ruff、Prettier、shfmt、goimports、gofumpt。
- Treesitter 安装 24 种语言的 parser，另有共享查询依赖；JSONC 复用 JSON parser。当前锁定版本要求 Neovim 0.12+、tree-sitter CLI 0.26.1+。
- Rust 的 Cargo/Clippy 沿用系统或项目工具链；Nix 为编辑器提供 rustfmt 和 Zig（含 zig fmt）作为 PATH 后备。ZLS 改由 Mason 安装，请保持 Zig/ZLS 版本匹配；C# LSP 保持禁用。

Mason 下载的 Linux 二进制在 NixOS 上依赖可用的 nix-ld。本仓库已有相关系统配置；纯 Home Manager 用户在其他主机上需要自行提供兼容运行环境。`extraPackages` 补充编辑器 PATH，项目已有工具仍可优先生效。

配置入口为 `init.lua`，基础设置在 `lua/config/`，插件按用途放在 `lua/plugins/`。Home Manager 只部署入口、Lua 模块和锁文件种子，不再向 Neovim 注入 CoC、NERDTree、CtrlP 或 airline。

## 默认语言支持

| 语言 | Mason LSP | 格式化器 |
| --- | --- | --- |
| Rust | rust-analyzer | rustfmt（项目工具链或 Nix 后备） |
| Python | pyright | Ruff（Mason） |
| Go | gopls | goimports + gofumpt（Mason） |
| Zig | zls | zig fmt（Zig 工具链） |
| TypeScript / JavaScript（含 TSX/JSX） | typescript-language-server | Prettier（Mason） |

这些服务通过原生 LSP 向 nvim-cmp 提供补全，不需要每种语言单独安装补全前端。打开代码文件会自动安装缺少的服务；也可以用 `:MasonInstall gopls zls typescript-language-server goimports gofumpt` 手动补装。Go 的 `GOPATH`、`GOMODCACHE`、`GOCACHE` 均由 Home Manager 配置为绝对路径。Neovim 也会在 Mason/LSP 启动前展开旧会话传入的 `~/`，保留项目自定义绝对路径和多项 GOPATH。

若已打开的 Neovim 仍报 `GOMODCACHE entry is relative`，可在该窗口执行以下命令后重试，无需删除 Mason 数据：

```vim
:lua vim.env.GOPATH = vim.fn.expand('~/.local/share/go'); vim.env.GOMODCACHE = vim.env.GOPATH .. '/pkg/mod'; vim.env.GOCACHE = vim.fn.expand('~/.cache/go-build')
:MasonInstall gofumpt goimports
```

部署修正后重启 Neovim即可自动修正旧环境；终端里的 Go 命令则需要更新 shell 环境，旧 tmux 服务也可能仍保留原环境变量。

## 常用键位

Leader 仍是反斜杠 `\`，大小写有区别。

| 键位 | 功能 |
| --- | --- |
| Ctrl+P / Leader+pf | 查找文件，显示隐藏文件 |
| F4 / Leader+pg | 项目全文搜索 |
| Ctrl+H / Leader+pw | 搜索光标下单词 |
| F8 / Ctrl+F / Leader+ps | LSP 文档符号；无服务时提示 |
| Leader+pS | LSP 工作区符号 |
| Leader+pb / pr / ph / pd | buffer / 最近文件 / 帮助 / 诊断 |
| Leader+t / T / o | 文件树定位 / 开关 / 聚焦 |
| Ctrl+C / Ctrl+/ / Ctrl+_ | 切换注释；Ctrl+C 不承担复制 |
| `"+y` / `"+p` | 显式使用 OSC52 剪贴板；粘贴需要终端支持读取 |
| f / F / s、Leader+f / wf / wl / L / ww / W | 原 Sneak / EasyMotion 跳转 |
| Leader+U / u / du | 撤销树开关 / 聚焦 / 清空当前撤销历史 |
| Ctrl+Z（插入模式） | 撤销 |
| Tab+数字、Alt+数字 | 跳转 tab page，0 表示第 10 页 |
| Tab+p / n / j / k / h / l | 上下 tab / 移动 tab，沿用旧映射 |
| Tab+Delete / Backspace | 关闭当前 tab / 清理未修改且未显示的文件 buffer |
| F5、终端内 Esc | 打开终端 / 返回普通模式 |
| Ctrl+M | 交换窗口内容（沿用原映射，也可能与普通模式 Enter 相同） |
| gd / gD / gi / gr / gT / K | 定义 / 声明 / 实现 / 引用 / 类型定义 / 文档 |
| gt | 保留 Neovim 原生的下一个 tab |
| Ctrl+K（普通及插入模式） | LSP 签名帮助 |
| Leader+rn / ca | 重命名 / 代码操作 |
| [d / ]d、Leader+e / q | 诊断跳转 / 当前诊断 / 位置列表 |
| Leader+F | 手动格式化 buffer 或选区 |
| Leader+H | 检查光标下高亮，替代旧 Leader+h |
| [c / ]c、Leader+hs / hr / hp / hb | Git hunk 跳转 / 暂存 / 撤销修改 / 预览 / blame |
| Leader+gb / gD | blame 行提示开关 / 当前 hunk 行内预览 |
| Leader+gc / gs | Git 提交 / 工作区状态搜索 |

Telescope 使用 Leader+p 分组，避免与 EasyMotion 的 Leader+f 冲突。文件树隐藏 `.git`、构建及依赖目录；搜索同样排除常见生成目录。保留两空格缩进、Makefile Tab、PaperColor 深色主题（不叠加旧高亮）、折叠记忆、持久化 undo 和 `.xxx.age` 文件类型识别。

## 格式化

默认保存时同步格式化，超时 1 秒。特殊 buffer、不可修改 buffer 及当前内容超过 200 KiB 的文件跳过自动格式化；缺少工具或执行失败不阻止保存。

- Lua：Stylua；Python：Ruff；前端、JSON/JSONC、YAML、Markdown：Prettier；Shell：shfmt。
- Rust：rustfmt；Go：先 goimports 整理 import，再 gofumpt 格式化；Zig：zig fmt；没有外部格式化器时回退到支持格式化的 LSP。
- `:FormatToggle` 只切换当前 buffer 的保存格式化，手动 Leader+F 始终可用。
- 不再额外执行旧的保存时空白清理，避免重复修改；尾随空白仍有提示。
- `.age` 规则只识别文件类型，不负责加解密。

## 更新与排错

插件位于 `stdpath('data')/lazy`，Mason 位于 `stdpath('data')/mason`，parser 位于 `stdpath('data')/site`。Undo 位于 `stdpath('state')/undo`。这些位置均可写，不向 `/nix/store` 写入。

仓库 `lazy-lock.json` 是版本基线，部署为 `lazy-lock.seed.json`。首次启动复制至 `stdpath('data')/lazy-lock.json`，后续不覆盖。`:Lazy update` 仅更新运行锁文件；确认新版本可用后，将运行锁文件复制回仓库才能共享更新。Home Manager 回滚配置不会自动回滚这些用户数据；需要回退插件时，将对应版本的种子复制到运行锁文件，再执行 `:Lazy restore`。已有 CoC 数据不会被清理。

- `:Lazy`：插件和编译状态；`:Lazy restore`：恢复运行锁文件中的版本。
- `:Mason` / `:MasonLog`：语言服务器和格式化器状态、安装失败日志。
- `:MasonUpdate`：刷新工具目录；安装失败可在 Mason 面板重试，或重启让缺失工具再次安装。
- `:checkhealth vim.lsp` / `:LspInfo`：服务连接；ZLS 与其他服务统一由 Mason 安装并启用。
- `:ConformInfo`：当前格式化器、可执行程序及日志。
- `:TSInstall lua` / `:TSUpdate`：补装或更新 parser；首轮异步安装完成后会为已打开文件启用高亮。

首次安装失败时仍可基本编辑；完整安装后离线启动可使用已有插件和工具。主题、字体图标及 OSC52 的最终显示和剪贴板交互需要在实际终端中确认。

friendly-snippets 若显示旧的 `clean failed`，先运行 `git -C ~/.local/share/nvim/lazy/friendly-snippets ls-files -d -m` 检查。输出为空表示当前没有 Lazy 所检查的本地修改，此时 `:Lazy clear` 清除旧任务记录，再执行 `:Lazy restore friendly-snippets`。如仍有输出，应先备份本地修改再恢复或重装，避免直接删除自定义 snippet。

## 本次验证

使用临时 XDG 配置、数据、状态和缓存目录验证，未激活用户配置：独立 Home Manager 模块求值与 Neovim wrapper 构建通过；41 个插件按锁文件安装，24 种语言 parser 编译完成。检查了 PaperColor 主题、Lua/Python/JSON/Rust/Go/Zig/TypeScript/JavaScript 的 LSP、补全与诊断、代码片段、保存格式化、文件树和搜索，以及大文件、缺失格式化器、超时、未保存 buffer 保护、离线启动和 bootstrap 失败回退。

上一轮完整主机求值受仓库已有的 `nix.package` 未设置断言阻碍，该问题不在本次改动范围。尚未执行 Home Manager switch，也未验证其他主机或实际终端的 OSC52 交互。
