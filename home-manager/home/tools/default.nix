{ pkgs, inputs, ... }:

{
  imports = [
    ./ssh

    ./gnupg.nix
    ./git

    ./tmux
    ./vim

    ./direnv.nix
    ./vscode.nix


    ./others.nix
  ];
}
