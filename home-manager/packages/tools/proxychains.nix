{ config, pkgs, ... }:

let
  proxychains_ng_conf = "${config.xdg.configHome}/proxychains.conf";

  proxychains_ng_conf_txt = ''
    [ProxyList]
    http 127.0.0.1 8891
  '';

  fq = (pkgs.writeShellScriptBin "fq" ''
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
  '');

in {
  home.file.${proxychains_ng_conf}.text = proxychains_ng_conf_txt;

  home.packages = with pkgs; [
    proxychains-ng
    fq
  ];
}
