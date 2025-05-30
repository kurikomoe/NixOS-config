{
  config,
  pkgs,
  koptions,
  ...
}: let
  proxychains_ng_conf = ".config/proxychains.conf";

  proxychains_ng_conf_txt = ''
    [ProxyList]
    ${koptions.proxychains.proxy}
  '';

  fq = pkgs.writeShellScriptBin "fq" ''
    unset ALL_PROXY
    unset HTTP_PROXY
    unset HTTPS_PROXY
    unset SOCKS_PROXY
    unset all_proxy
    unset http_proxy
    unset https_proxy
    unset socks_proxy

    ${pkgs.proxychains-ng}/bin/proxychains4 -q \
      -f ${proxychains_ng_conf} \
      $@
  '';
in {
  nixpkgs.overlays = [
    (final: prev: {
      proxychains-helper = fq;
    })
  ];

  home.file.${proxychains_ng_conf}.text = proxychains_ng_conf_txt;

  home.packages = with pkgs; [
    proxychains-ng
    proxychains-helper
  ];
}
