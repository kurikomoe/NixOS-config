{...}: let
in {
  programs.zsh.initExtra = ''
    cdw() {
        local win_path="$1"
        if [ -z "$win_path" ]; then
          echo "Usage: cdw <Windows Path>" >&2
          return 1
        fi
        local linux_path
        if ! linux_path=$(wslpath "$win_path"); then
          return 1
        fi
        if [ ! -d "$linux_path" ]; then
          echo "cdw: Directory not found: $linux_path" >&2
          return 1
        fi
        cd "$linux_path"
      }
  '';

  programs.bash.initExtra = ''
    cdw() {
      local win_path="$1"
      if [ -z "$win_path" ]; then
        echo "Usage: cdw <Windows Path>" >&2
        return 1
      fi
      local linux_path
      if ! linux_path=$(wslpath "$win_path"); then
        return 1
      fi
      if [ ! -d "$linux_path" ]; then
        echo "cdw: Directory not found: $linux_path" >&2
        return 1
      fi
      cd "$linux_path"
    }
  '';

  programs.fish.functions = {
    cdw = {
      body = ''
        # 检查参数数量
        if test (count $argv) -eq 0
            echo "Usage: cdw <Windows Path>" >&2
            return 1
        end
        # 获取路径并转换
        set -l win_path "$argv[1]"
        set -l linux_path (wslpath "$win_path")

        # 检查 wslpath 是否成功
        if test $status -ne 0
            return 1
        end
        # 检查目录是否存在
        if not test -d "$linux_path"
            echo "cdw: Directory not found: '$linux_path'" >&2
            return 1
        end
        # 切换目录
        cd "$linux_path"
      ''; # body 字符串结束
    }; # cdw 函数定义结束
  }; # functions 属性集结束
}
