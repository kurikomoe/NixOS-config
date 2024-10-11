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
    ./vscode.nix

    ./network.nix

    ./others.nix
  ];
}
