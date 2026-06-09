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

  http_proxy = "http://localhost:8899";
  socks_proxy = "socks5://localhost:8899";

  prompt_dir = ".config/opencode/prompts";

  age_secrets_filelist =
    {}
    // (helper "opencode/config/opencode.jsonc" "${home}/.config/opencode/opencode.jsonc")
    // (helper "opencode/config/tui.jsonc" "${home}/.config/opencode/tui.jsonc");
in {
  home.packages = with pkgs; [
    repos.pkgs-kuriko-nur.opencode-bin
  ];

  home.file = {
    "${prompt_dir}/build.md".source = ./prompts/build.md;
    "${prompt_dir}/plan.md".source = ./prompts/plan.md;
    "${prompt_dir}/read-paper.md".source = ./prompts/read-paper.md;
  };

  home.shellAliases = {
    oc = "opencode";
    ocp = "http_proxy=${http_proxy} https_proxy=${http_proxy} socks_proxy=${socks_proxy} all_proxy=${socks_proxy} opencode";
  };

  age.secrets = age_secrets_filelist;
}
