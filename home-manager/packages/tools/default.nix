{ pkgs, inputs, ... }:

{
  imports = [
    ./ssh

    ./git
    ./gnupg.nix

    ./vim

    ./tmux
    ./topgrade

    ./direnv.nix
    ./vscode-server.nix

    ./network.nix

    ./others.nix

    ./sys.nix
  ];
}
