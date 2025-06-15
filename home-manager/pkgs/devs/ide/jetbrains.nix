{
  root,
  pkgs,
  repos,
  ...
}: let
  # TODO(kuriko): this is not implemented
  pluginList = [
    ".env files"
    ".ignore"
    "atom material icons"
    "better highlights"
    "gittoolbox"
    "grep console"
    "ideavim"
    "indent rainbow"
    "just"
    "key promoter x"
    "macos for all"
    "nyan progress bar"
    "one dark darker"
    "rainbow bracket lite"
    "wakatime"
    "nixidea"
    "direnv integration"
  ];
in {
  # https://github.com/nix-community/home-manager/blob/release-25.05/modules/programs/jetbrains-remote.nix
  # 250615: seem fixed
  # disabledModules = [
  #   "programs/jetbrains-remote.nix"
  # ];

  # imports = [
  #   "${root.pkgs}/home-manager/jetbrains-remote.nix"
  # ];

  # home.packages = with pkgs-unstable.jetbrains; [
  #   (plugins.addPlugins webstorm [
  #     "ideavim"
  #     "nixidea"
  #   ])
  # ];

  programs.jetbrains-remote.enable = true;
  programs.jetbrains-remote.ides = with repos.pkgs-kuriko-nur; [
    webstorm
    rust-rover
    pycharm-professional
    rider
    idea-ultimate
    goland
    clion
  ];
}
