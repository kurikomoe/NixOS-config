{
  pkgs,
  inputs,
  config,
  repos,
  ...
}: {
  home.packages = with pkgs; [
    repos.pkgs-unstable.mongodb-ce
    mongodb-tools
    mongosh
  ];
}
