{
  pkgs,
  lib,
  root,
  config,
  kutils,
  repos,
  ...
}: let
  # dst（dsh-tui）自己的设置文件，即 `/settings` 里的 dsh-tui 分区，所有内核
  # （DSH / Claude / Codex）共用一份。放在这里作为跨机器同步的默认值。
  tuiSettings = ./settings.json;
in {
  home.packages = with pkgs; [
    # repos.pkgs-kuriko-nur.dsh
    repos.pkgs-kuriko-nur.dsh-tui
  ];

  # 不使用 home.file：它生成指向 /nix/store 的只读软链，而 dst 保存设置时是
  # 「临时文件 + rename」原子重写（lib/types/tuiSettingsFile.js），软链会写失败。
  # 这里改为种子式部署，落成普通的 0600 文件，dst 可以照常改写：
  #   * 文件不存在               -> 写入本仓库的默认值
  #   * 内容仍是上次写入的默认值 -> 跟随本仓库更新（重新写入）
  #   * 其余情况                 -> 当作已在 /settings 里改过，保留本机内容
  # `.settings.json.hm-default` 是上次写入内容的副本，用来区分「没动过」和
  # 「本地改过」。想恢复默认值：删掉 ~/.dsh-tui/settings.json 再 switch 即可。
  home.activation.dshTuiSettings = lib.hm.dag.entryAfter ["writeBoundary"] ''
    dsh_tui_target="''$HOME/.dsh-tui/settings.json"
    dsh_tui_seeded="''$HOME/.dsh-tui/.settings.json.hm-default"
    dsh_tui_default=${tuiSettings}
    dsh_tui_install=1

    if [ -e "''$dsh_tui_target" ]; then
      if ! cmp -s "''$dsh_tui_target" "''$dsh_tui_seeded" \
        && ! cmp -s "''$dsh_tui_target" "''$dsh_tui_default"; then
        dsh_tui_install=0
      fi
    fi

    if [ "''$dsh_tui_install" = 1 ]; then
      run mkdir -p "''$HOME/.dsh-tui"
      run install -m 0600 "''$dsh_tui_default" "''$dsh_tui_target"
      run install -m 0644 "''$dsh_tui_default" "''$dsh_tui_seeded"
    else
      echo "dsh-tui: 保留本机已修改的 ''$dsh_tui_target（默认值: ''$dsh_tui_default）"
    fi
  '';

  programs.dsh = {
    # conflicts with self built dsh
    enable = false;
    profiles.headless = {
      plugins = ["@deepseek-ai/dsh-base" "@deepseek-ai/dsh-headless"];
    };
    profiles.web = {
      plugins = ["@deepseek-ai/dsh-base" "@deepseek-ai/dsh-web-app"];
    };
    profiles.custom = {
      plugins = [
        "@deepseek-ai/dsh-base"
        # "github:someone/cool-plugin"          # build-time resolve
      ];
      # specsHash = "";               # pin the resolution
      # userPatchesFile = ./patches.yml;        # profile-level cordis.patch.yml
    };
    # homePatchesFile = ./home-patches.yml;     # -> ~/.dsh/cordis.patch.yml
    # settings = { ... };                     # seeds ~/.dsh/settings.yaml once
  };
}
