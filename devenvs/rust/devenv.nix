{
  pkgs,
  lib,
  config,
  inputs,
  ...
}: {
  # https://devenv.sh/basics/
  env.GREET = "devenv";

  # https://devenv.sh/packages/
  packages = with pkgs; [
    hello
    git

    # Github Action Tester
    act
  ];

  languages.python = {
    enable = true;
    package = pkgs.python312;
    poetry = {
      enable = true;
      activate.enable = true;
    };
  };

  enterShell = ''
  '';

  # tasks = {
  #   "myproj:setup".exec = "mytool build";
  #   "devenv:enterShell".after = [ "myproj:setup" ];
  # };

  enterTest = ''
    echo "Running tests"
    git --version | grep --color=auto "${pkgs.git.version}"
  '';

  pre-commit.hooks = {
    alejandra.enable = true;

    isort.enable = true;
    mypy.enable = true;
    pylint.enable = true;
    pyright.enable = true;
    flake8.enable = true;
    autoflake.enable = true;
  };
}
