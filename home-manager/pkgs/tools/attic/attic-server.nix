{
  pkgs,
  repos,
  root,
  ...
}: {
  home.packages = with repos.pkgs-unstable.pkgs; [
    attic-server
  ];

  # setup cache
  age.secrets.".config/attic/server.toml" = {
    file = "${root.base}/res/attic/server.toml.age";
    path = ".config/attic/server.toml";
  };
}
