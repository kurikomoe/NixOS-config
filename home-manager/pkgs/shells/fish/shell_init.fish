# =======================================================================
# 用于存储已进入 9P 目录的状态
set -g __entered_nu_for_9p 0

function enter_nu_if_9p
    if test $__entered_nu_for_9p -eq 1
        return
    end

    if string match -r '^/mnt/c/Users' "$PWD"
        return
    end

    # 获取当前目录的挂载点信息
    set mount_info (df --output=fstype "$PWD" | tail -n 1)
    # 检查文件系统是否为 9P
    if test "$mount_info" = "9p" -a $__entered_nu_for_9p -eq 0
        # 检查 nu.exe 是否存在
        if command -v nu.exe > /dev/null
            # 运行 nu.exe
            echo "Entering windows because you're in a windows directory."
            set -g __entered_nu_for_9p 1
            nu.exe
        else
            echo "nu.exe not found in PATH"
        end
    end
end

# 每次切换目录时运行检测函数
function on_directory_change --on-variable PWD
    enter_nu_if_9p
end

enter_nu_if_9p
# =======================================================================

if status is-interactive
    # 1. 设置 GPG_TTY 环境变量
    # -g 表示全局 (global)，-x 表示导出 (export) 给子进程
    set -gx GPG_TTY (tty)

    # 2. 强制刷新 gpg-agent 的 TTY 上下文
    # 这一步同样关键，告诉后台的 agent 更新当前窗口信息
    gpg-connect-agent updatestartuptty /bye > /dev/null 2>&1
end
