{
  root,
  pkgs,
  ...
}: {
  home.packages = with pkgs; [
    shell-gpt
  ];

  home.shellAliases = {
    "ask" = "sgpt";
    "chat" = "sgpt --repl temp";
  };

  age.secrets.".config/shell_gpt/.sgptrc" = {
    file = "${root.base}/res/misc/shell_gpt/sgptrc.age";
    path = ".config/shell_gpt/.sgptrc";
  };
}
