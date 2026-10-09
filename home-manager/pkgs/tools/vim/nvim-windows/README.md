# Neovim Windows 配置与部署

本目录由 `../nvim` 的模块化 Lua 配置适配而来，用于 **Windows 原生 Neovim**。保留 PaperColor 深色主题、原有 Leader 键位、文件树、搜索、补全、原生 LSP、格式化和持久化撤销。无需 Nix、Home Manager 或 WSL。

入口是 `init.lua`，基础配置在 `lua/config/`，插件配置在 `lua/plugins/`。旧 `init.vim`、CoC 设置和旧 GUI 配置没有复制过来，避免双入口及主题冲突。原 `nvim` 目录继续用于原有环境。

## 1. 安装依赖

适用环境：Windows 10/11，推荐 Windows Terminal。先安装以下工具，并确保在**新打开的终端**中能找到它们。

| 工具 | 用途 |
| --- | --- |
| Neovim **0.12+** | 本配置锁定的 Treesitter 版本要求；更旧版本会提示升级并停止加载配置 |
| Git | Lazy 下载及更新插件、Git 状态 |
| PowerShell 7（推荐） | `:!` 和 F5 终端；缺少时回退到 Windows PowerShell |
| Node.js LTS / npm | TypeScript、JSON、HTML、CSS 等语言服务及 Prettier |
| ripgrep、fd | Telescope 全文搜索及文件查找 |
| curl、GNU tar、7-Zip | 下载及解压 parser、Mason 工具 |
| tree-sitter CLI **0.26.1+** | 编译语法 parser，使用原生发行包，不通过 npm 安装 |
| C 编译器 | 推荐 MinGW GCC；安装后 `gcc.exe` 必须在 PATH 中 |
| diffutils | Undotree 差异比较；需要可执行的 `diff.exe` |

这些版本约束来自仓库保留的 [Treesitter 版本说明](https://github.com/nvim-treesitter/nvim-treesitter/blob/61df84986b4b4ec469ee745a182e433d49f8c27e/README.md)。Mason 的 Windows 解压依赖见[官方要求](https://github.com/mason-org/mason.nvim#requirements)。安装器提供的版本可能变化，以实际版本输出为准。

如果已经安装 [Scoop](https://scoop.sh/)，可在普通 PowerShell 中执行：

```powershell
scoop install neovim git pwsh nodejs-lts ripgrep fd curl tar 7zip tree-sitter mingw diffutils
```

若已有 Node.js、Git 等工具，只安装缺少的项目即可。其他安装方式也可以，只要可执行程序位于 PATH 中；不要混用 WSL 的 Linux 可执行文件。

重新打开终端并检查：

```powershell
nvim --version
tree-sitter --version
gcc --version
git --version
node --version
npm.cmd --version
rg --version
fd --version
tar --version
Get-Command nvim, git, pwsh, node, npm.cmd, rg, fd, curl.exe, tar.exe, 7z.exe, tree-sitter, gcc, diff.exe
```

Windows 自带的 `tar.exe` 可能是 bsdtar；若 Mason 报解压错误，确认安装的 GNU tar 在 PATH 中优先被找到。配置在未指定 `CC` 且能找到 GCC 时，会为 Neovim 子进程设置 `CC=gcc`。使用 MSVC 时应在已初始化 C++ 编译环境的 Developer PowerShell 中启动 Neovim；保留用户指定的 `CC`。

按开发语言选装：

| 语言 | 需要的本地工具链 | 自动安装的 LSP / 格式化器 |
| --- | --- | --- |
| Lua | 无额外运行时 | lua-language-server、Stylua |
| Python | Python / pip（项目运行、虚拟环境） | Pyright、Ruff |
| JS / TS / TSX / JSX | Node.js / npm | typescript-language-server、Prettier |
| Go | Go | gopls、goimports、gofumpt；检测到 Go 后才自动安装 |
| Rust | Rustup、Cargo、Clippy、rustfmt | rust-analyzer；rustfmt 使用本地工具链 |
| Zig | Zig，与 ZLS 版本兼容 | ZLS；格式化使用 `zig fmt` |
| C / C++ | 项目编译工具链 | clangd |
| Shell | 运行脚本时需要相应 shell | bash-language-server、shfmt |

例如使用 Scoop 安装 `go`、`python`、`rustup` 或 `zig`。Rust 安装后执行 `rustup component add rustfmt clippy`。JSON、YAML、TOML、HTML、CSS 的服务也由 Mason 管理；C# 沿用原配置，未启用。Mason 安装语言服务器不等于安装项目运行时。

## 2. 部署配置

先关闭正在运行的 Neovim。下面命令在仓库的 `home-manager\pkgs\tools\vim` 目录运行，采用默认 Windows 路径：

- 配置：`%LOCALAPPDATA%\nvim`
- 插件、Mason、运行锁文件等数据：`%LOCALAPPDATA%\nvim-data`

如果设置过 `XDG_CONFIG_HOME`、`XDG_DATA_HOME`、`XDG_STATE_HOME` 或 `NVIM_APPNAME`，路径可能不同。先用以下命令确认，并相应调整部署目标；不要直接把这些环境变量清空：

```powershell
nvim --clean --headless -c 'lua print(vim.fn.stdpath("config")); print(vim.fn.stdpath("data")); print(vim.fn.stdpath("state"))' -c qa
```

默认路径的备份与部署命令如下。它会将旧配置和旧数据改名保留，然后复制新配置；首次启动会重新安装插件。

```powershell
$source = (Resolve-Path -LiteralPath '.\nvim-windows' -ErrorAction Stop).Path
$configDir = Join-Path $env:LOCALAPPDATA 'nvim'
$dataDir = Join-Path $env:LOCALAPPDATA 'nvim-data'
$stamp = Get-Date -Format 'yyyyMMdd-HHmmss-fff'

foreach ($path in @($configDir, $dataDir)) {
    if (Test-Path -LiteralPath $path) {
        Move-Item -LiteralPath $path -Destination "$path.backup-$stamp" -ErrorAction Stop
    }
}
Copy-Item -LiteralPath $source -Destination $configDir -Recurse -ErrorAction Stop
Test-Path -LiteralPath (Join-Path $configDir 'init.lua')
nvim
```

最后的 `Test-Path` 应输出 `True`。目标应为 `nvim\init.lua`，不能多套一层 `nvim\nvim-windows\init.lua`，也不要把旧的 `init.vim` 放进目标目录。

### 并行试用（可选）

若想与已有配置并存，可在一个新的 PowerShell 窗口使用独立应用名：

```powershell
$env:NVIM_APPNAME = 'nvim-windows'
$trialDir = Join-Path $env:LOCALAPPDATA 'nvim-windows'
if (Test-Path -LiteralPath $trialDir) { throw '试用目录已存在，请先备份或换一个应用名。' }
Copy-Item -LiteralPath '.\nvim-windows' -Destination $trialDir -Recurse
nvim
```

此例同样假设未覆盖 XDG 路径。配置和数据分别位于 `nvim-windows`、`nvim-windows-data`；关闭该 PowerShell 窗口就结束本次环境变量设置。仅执行 `nvim -u 某路径\init.lua` 不会自动切换 Lua 模块搜索路径或隔离插件数据，不建议用它代替上述部署。

## 3. 首次启动

首次安装需要访问 GitHub、Mason 下载源及 npm 等包源。等待 Lazy 安装完成后重启 Neovim；打开代码文件后等待 Mason 安装相应工具。

```vim
:Lazy
:Mason
:checkhealth lazy
:checkhealth mason
:checkhealth nvim-treesitter
:checkhealth vim.provider
```

- Lazy 使用本目录的 `lazy-lock.json` 作为首次安装基线。
- Treesitter 自动补装原配置的 24 种语言 parser。若缺少 CLI、下载工具或 C 编译器，会提示并跳过安装，基本编辑及已有 parser 仍可用。安装依赖后重启即可补装；可以用 `:TSInstall lua` 验证单个 parser。
- Mason 自动安装缺失的语言服务器及 Stylua、Ruff、Prettier、shfmt。检测到 Go 后再安装 Go 服务及格式化器。
- 安装过程是异步的，`:Lazy` 完成不代表 Mason 和 parser 已全部安装完成。

Go 环境变量中的 `~/` 和 `~\` 会展开为用户目录；多项 `GOPATH` 使用 Windows 的分号 `;` 分隔，保留 `C:\...` 等绝对路径。检查可用 `:lua print(vim.env.GOPATH, vim.env.GOMODCACHE, vim.env.GOCACHE)`。

## 4. Windows 行为与键位

PowerShell 设置位于 `lua/config/windows.lua`，遵循 Neovim 的 [`shell-powershell` 说明](https://neovim.io/doc/user/options/#shell-powershell)，为外部命令设置 UTF-8 输出。F5 打开交互终端，终端内 Esc 返回普通模式；`:!` 命令使用 PowerShell 语法。

剪贴板交由 Neovim 的 Windows provider 自动检测，默认 `clipboard=unnamedplus`。官方 Windows 包通常带有 `win32yank.exe`。普通 `y` / `p` 使用系统剪贴板，`"+y` / `"+p` 也可显式操作。保留原来的 **Ctrl+C 切换注释** 行为；Ctrl+V 保留 Vim 块选择，Windows Terminal 粘贴可用 Ctrl+Shift+V。

新文件默认 LF，读取已有 CRLF 文件时保留其格式；`:setlocal fileformat?` 可查看。外部格式化器的换行策略仍受项目配置影响。两空格缩进、Makefile Tab、折叠记忆、`.xxx.age` 文件类型识别均保留；`.age` 规则不负责加解密。

Leader 是反斜杠 `\`，大小写有区别：

| 键位 | 功能 |
| --- | --- |
| Ctrl+P / Leader+pf | 查找文件（含隐藏文件） |
| F4 / Leader+pg | 项目全文搜索 |
| F8 / Ctrl+F / Leader+ps | 文档符号 |
| Leader+t / T / o | 文件树定位 / 开关 / 聚焦 |
| Leader+pb / pr / ph / pd | buffer / 最近文件 / 帮助 / 诊断 |
| Ctrl+C / Ctrl+/ | 切换注释 |
| f / F / s、Leader+f | Sneak / EasyMotion 跳转 |
| Tab+数字 / Alt+数字 | 切换 tab page，0 表示第 10 页 |
| Tab+Delete / Backspace | 关闭 tab / 清理未修改的隐藏文件 buffer |
| Leader+U / u / du | 撤销树开关 / 聚焦 / 清空当前撤销历史 |
| F5 / 终端内 Esc | 打开终端 / 返回普通模式 |
| gd / gr / gT / K | 定义 / 引用 / 类型定义 / 文档 |
| Leader+rn / ca | 重命名 / 代码操作 |
| Leader+F | 手动格式化 buffer 或选区 |
| [d / ]d、Leader+e | 诊断跳转 / 当前诊断 |
| [c / ]c、Leader+hs / hr / hp | Git hunk 跳转 / 暂存 / 撤销修改 / 预览 |

Windows Terminal 若拦截 Alt+数字或 Ctrl+Shift 等组合，可调整终端绑定或改用 Leader 键位。图标显示需要终端选择 Nerd Font；字体未安装不影响编辑。

保存时默认同步格式化，超时 1 秒，特殊 buffer 和超过 200 KiB 的内容跳过。`:FormatToggle` 切换当前 buffer 自动格式化，`:ConformInfo` 查看格式化器状态。

## 5. 与原配置的兼容性取舍

- Telescope 使用内置 Lua sorter，文件与全文搜索保留；默认不编译 `telescope-fzf-native.nvim`，不要求 GNU Make。
- LuaSnip 不自动编译可选的 `jsregexp`。普通片段及占位符可用，依赖正则转换的 LSP / VS Code 片段功能受限。确有需要时，按 [LuaSnip Windows 构建说明](https://github.com/L3MON4D3/LuaSnip#install) 准备 Make、C 编译器及 Git 的 `sh.exe`，再在 `lua/plugins/cmp.lua` 添加 `build = "make install_jsregexp"` 并执行 `:Lazy build LuaSnip`。
- Undotree 使用 `diff.exe`，避免调用 PowerShell 的同名别名。找不到该程序时不加载撤销树插件，原生 `u` / Ctrl+R 及持久化撤销仍可用。安装 Scoop 的 `diffutils` 后重启即可启用撤销树；PowerShell 的 `diff` 别名不能替代 GNU diff。
- 没有强制 OSC52，不依赖 xclip、Linux 路径或 Nix 提供的工具包。

## 6. 更新、回滚与排错

插件在 `stdpath('data')/lazy`，Mason 在 `stdpath('data')/mason`，parser 在 `stdpath('data')/site`，undo 在 `stdpath('state')/undo`。Lua 中使用 `/` 或 `vim.fs` 路径是 Windows Neovim 支持的形式，无需将每条路径改写为反斜杠。

首次启动将配置目录的 `lazy-lock.json` 复制到 `stdpath('data')/lazy-lock.json`。之后不覆盖运行锁文件；`:Lazy update` 更新运行锁文件。若要共享已验证的插件更新，将运行锁文件复制回本目录。Mason 工具版本不由 Lazy 锁文件固定。

恢复仓库插件版本时，在 Neovim 内执行（会替换当前运行锁文件，先保留需要的版本）：

```vim
:lua local dst = vim.fn.stdpath('data') .. '/lazy-lock.json'; vim.fn.writefile(vim.fn.readfile(vim.fn.stdpath('config') .. '/lazy-lock.json'), dst)
:Lazy restore
:TSUpdate
```

插件回滚后也需按对应版本更新 parser。若要恢复部署前的全部配置，先关闭 Neovim，将当前配置、数据目录改名留存，再把第 2 节生成的两份 `.backup-时间戳` 目录改回原名。

| 现象 | 检查与处理 |
| --- | --- |
| 找不到 git / 首次安装失败 | 在新终端执行 `git --version`；检查网络；恢复后重启。基本编辑仍可使用 |
| 插件下载失败 | `:Lazy` 查看具体任务，恢复 GitHub 连接后执行 `:Lazy restore` |
| parser 安装失败 | 检查 `tree-sitter --version`、`gcc --version`、curl、tar；确认是 Windows 原生工具，执行 `:checkhealth nvim-treesitter` |
| Mason 安装失败 | `:MasonLog`、`:checkhealth mason`；检查 npm、GNU tar、7-Zip、Go 等具体依赖，`:MasonUpdate` 后重试 |
| npm.ps1 被执行策略拦截 | 在 PowerShell 验证工具时使用 `npm.cmd`；检查 Node/npm 安装及 PATH |
| LSP 未连接 | `:checkhealth vim.lsp` / `:LspInfo`；确认项目根目录、工具链和 Mason 安装状态，安装完成后重新打开文件 |
| Go 服务未安装 | 确认 `go version` 成功后重启；可手动 `:MasonInstall gopls goimports gofumpt` |
| Zig 服务异常 | 检查 `zig version` 与 `:Mason` 中 ZLS 版本兼容性 |
| 剪贴板无效 | `:checkhealth vim.provider`；`:echo executable('win32yank.exe')`；确认使用完整的 Windows Neovim 发行包 |
| 搜索无结果 | 检查 `rg`、`fd` 的 PATH；确认当前目录，生成目录默认被过滤 |
| 图标方框或终端键位冲突 | 设置 Nerd Font，检查 Windows Terminal 的快捷键 |

完整安装后可离线使用已有插件和工具；仍缺少的工具需要联网安装。字体、终端快捷键和剪贴板交互应在实际使用的终端中确认。

## 7. 本次验证范围

在 Windows 原生 Neovim 0.12.5 下使用临时 XDG 目录验证，未部署到当前用户的正式配置目录。Lua 语法、锁文件 JSON、文档 PowerShell 示例语法检查通过；安装并核对了插件锁定提交，验证了主题、补全模块加载、文件树、含中文及空格路径的文件搜索、CRLF 识别、PowerShell 7 和 Windows PowerShell 外部命令的中文输出、交互终端启动、Go 路径展开及缺 Git 时的回退。Windows 剪贴板 provider 检测通过，未修改系统剪贴板进行读写测试。

本机缺少 tree-sitter CLI、C 编译器、Go 和 diff.exe，因此验证了相关缺依赖分支，未验证 parser 编译、Go 工具安装或 Undotree 差异面板；也未逐个完成所有 Mason 工具的安装及 LSP 连接测试。
