{
  lib,
  stdenv,
  fetchzip,
  installShellFiles,
  autoPatchelfHook,
}: let
  inherit (stdenv.hostPlatform) system;

  pname = "1password-cli";
  version = "2.30.3";

  fetch = srcPlatform: hash: let
    args = {
      inherit hash;
      url = "https://cache.agilebits.com/dist/1P/op2/pkg/v${version}/op_${srcPlatform}_v${version}.zip";
      stripRoot = false;
    };
  in
    fetchzip args;

  sources = rec {
    x86_64-linux = fetch "linux_amd64" "sha256-MsBSjJi7hJbS1wU3lVeywRrhGAZkoqxRb4FTg8fFN00=";
  };

  platforms = builtins.attrNames sources;
  mainProgram = "op";
in
  stdenv.mkDerivation rec {
    inherit pname version;

    src =
      if (builtins.elem system platforms)
      then sources.${system}
      else throw "Source for ${pname} is not available for ${system}";

    nativeBuildInputs = [installShellFiles] ++ lib.optional stdenv.isLinux autoPatchelfHook;

    buildInputs = [];

    installPhase = ''
      runHook preInstall
      install -D ${mainProgram} $out/bin/${mainProgram}
      runHook postInstall
    '';

    postInstall = ''
      HOME=$TMPDIR
      installShellCompletion --cmd ${mainProgram} \
        --bash <($out/bin/${mainProgram} completion bash) \
        --fish <($out/bin/${mainProgram} completion fish) \
        --zsh <($out/bin/${mainProgram} completion zsh)
    '';

    doInstallCheck = true;

    installCheckPhase = ''
      $out/bin/${mainProgram} --version
    '';

    meta = with lib; {
      description = "1Password command-line tool";
      homepage = "https://developer.1password.com/docs/cli/";
      downloadPage = "https://app-updates.agilebits.com/product_history/CLI2";
      sourceProvenance = with sourceTypes; [binaryNativeCode];
      license = licenses.unfree;
      inherit mainProgram platforms;
    };
  }
