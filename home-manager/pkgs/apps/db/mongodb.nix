{
  pkgs,
  inputs,
  config,
  repos,
  ...
}: {
  home.packages = with pkgs; [
    repos.pkgs-stable.mongodb-ce
    mongodb-tools
    mongosh
  ];
}
