# =======================================================================
set -g __entered_nu_for_9p 0
set -g __checked_initial_windows_user_dir 0

function __is_windows_user_dir --argument-names dir
    string match -qr '^/mnt/[cC]/Users/[^/]+/?$' -- "$dir"
end

function __is_windows_mount_dir --argument-names dir
    string match -qr '^/mnt/[a-zA-Z](/|$)' -- "$dir"
end

function __cd_home_if_started_in_windows_user_dir
    if test "$__checked_initial_windows_user_dir" -eq 1
        return
    end

    set -g __checked_initial_windows_user_dir 1

    if __is_windows_user_dir "$PWD"
        cd ~
    end
end

function enter_nu_if_9p
    if test "$__entered_nu_for_9p" -eq 1
        return
    end

    if not __is_windows_mount_dir "$PWD"
        return
    end

    if command -q nu.exe
        echo "Entering Windows because you're in a Windows directory."
        set -g __entered_nu_for_9p 1
        nu.exe
        set -g __entered_nu_for_9p 0
    else
        echo "nu.exe not found in PATH"
    end
end

function on_directory_change --on-variable PWD
    enter_nu_if_9p
end

__cd_home_if_started_in_windows_user_dir
enter_nu_if_9p
# =======================================================================
