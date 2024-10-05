{ pkgs, inputs, config, lib, ... }:

let

in {
  home.packages = with pkgs; [
    p7zip
  ];

  programs = {
    gpg = {
      enable = true;
    };
  };

  services = {
    gpg-agent = {
      enable = true;
      enableSshSupport = true;
      pinentryPackage = pkgs.pinentry-tty;
      defaultCacheTtl = 7200;
      defaultCacheTtlSsh = 7200;
    };
  };

  home.activation = {
    initGPG = lib.hm.dag.entryAfter ["linkGeneration"] ''
      run chmod 0700 $HOME/.gnupg;
      run ${pkgs.gnupg}/bin/gpg --import ${config.age.secrets."gnupg/private.pgp".path}
      run ${pkgs.gnupg}/bin/gpg --import ${config.age.secrets."gnupg/public.pgp".path}
    '';
  };
}
