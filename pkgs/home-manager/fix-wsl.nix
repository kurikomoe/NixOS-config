{
  lib,
  stdenv,
  makeWrapper,
  runtimeShell,
  ...
}:
stdenv.mkDerivation rec {
  name = "fix-wsl";
  version = "1.0";
  buildInputs = [makeWrapper];
  dontUnpack = true;
  installPhase = ''
    mkdir -p $out/bin
    cat > $out/bin/${name} <<'EOF'
    #!${runtimeShell}
    set -e
    sudo true
    if [ -L "$HOME/.agenix" ] && [ ! -e "$HOME/.agenix" ]; then
      sudo systemctl restart user@1000.service
    fi
    # sudo systemctl restart systemd-binfmt.service
    EOF
    chmod +x $out/bin/${name}
  '';
  meta = with lib; {
    description = "Script to fix wsl invalid services";
    license = licenses.mit;
    platforms = platforms.linux;
  };
}
