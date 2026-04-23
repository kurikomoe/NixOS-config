{
  pkgs,
  root,
  config,
  kutils,
  repos,
  ...
}: let
  home = config.home.homeDirectory;
  helper = kutils.age.agehelper;

  age_secrets_filelist =
    {}
    // (helper "opencode/config/opencode.jsonc" "${home}/.config/opencode/opencode.jsonc")
    // (helper "opencode/config/tui.jsonc" "${home}/.config/opencode/tui.jsonc");
in {
  home.packages = with pkgs; [
    repos.pkgs-kuriko-nur.opencode
  ];

  home.file = {
    ".agents/prompts/build.md".source = ./prompts/build.md;
    ".agents/prompts/plan.md".source = ./prompts/plan.md;
  };

  age.secrets = age_secrets_filelist;
}
