{
  pkgs,
  repos,
  ...
}: {
  programs.jetbrains-remote.enable = true;
  programs.jetbrains-remote.ides = with repos.pkgs-unstable.jetbrains; [
    webstorm
    rust-rover
    pycharm-professional
    rider
    idea-ultimate
    goland
    clion
  ];
}
