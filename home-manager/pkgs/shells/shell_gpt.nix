{
  root,
  pkgs,
  ...
}: let
  ask = pkgs.writeShellScriptBin "ask" ''
    args="$*"
    ${pkgs.shell-gpt}/bin/sgpt "$args"
  '';
in {
  home.packages = with pkgs; [
    shell-gpt
    ask
  ];

  home.shellAliases = {
    "chat" = "sgpt --repl temp";
  };

  age.secrets.".config/shell_gpt/.sgptrc" = {
    file = "${root.base}/res/misc/shell_gpt/sgptrc.age";
    path = ".config/shell_gpt/.sgptrc";
  };
}
