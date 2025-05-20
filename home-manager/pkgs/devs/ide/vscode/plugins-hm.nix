{
  lib,
  repos,
  ...
}: let
  # vscode-extensions-json
  # https://github.com/NixOS/nixpkgs/blob/3dd8376449bb57b3e0ffece3851649c105075536/pkgs/applications/editors/vscode/extensions/vscode-utils.nix#L154
  toExtensionJsonEntry = ext: rec {
    identifier = {
      id = ext.vscodeExtUniqueId;
      uuid = "";
    };

    version = ext.version;

    relativeLocation = ext.vscodeExtUniqueId;

    location = {
      "$mid" = 1;
      fsPath = "~/.vscode-server/extensions/${ext.vscodeExtUniqueId}";
      path = location.fsPath;
      scheme = "file";
    };

    metadata = {
      id = "";
      publisherId = "";
      publisherDisplayName = ext.vscodeExtPublisher;
      targetPlatform = "undefined";
      isApplicationScoped = false;
      updated = false;
      isPreReleaseVersion = false;
      installedTimestamp = 0;
      preRelease = false;
    };
  };

  toExtensionJson = extensions: builtins.toJSON (map toExtensionJsonEntry extensions);

  pkgs = repos.pkgs-unstable;
  deps = pkgs.callPackage ./plugins.nix {inherit pkgs repos;};

  # Solution 1: copy
  # addVscodeServerExtention = exts: let
  #   extensionJsonFile = toExtensionJson exts;
  #   genHomeConfig = ext: let
  #     extName = ext.vscodeExtUniqueId;
  #     version = ext.version;
  #     srcPath = "${ext}/share/vscode/extensions/${extName}";
  #     homePath = ".vscode-server/extensions/${extName}";
  #   in {
  #     inherit srcPath homePath;
  #     packages = [ext];
  #     script = pkgs.writeShellScript "copy-${extName}" ''
  #       echo "Copying ${srcPath} to ${homePath}"
  #       mkdir -p "${homePath}"
  #       cp -T -rf "${srcPath}" "${homePath}"
  #       chmod +rw -R "${homePath}"
  #     '';
  #   };
  #
  #   configs = builtins.map (x: genHomeConfig x) exts;
  #
  #   combine-configs-stage1 =
  #     builtins.foldl' (acc: x: {
  #       packages = acc.packages ++ x.packages;
  #       script = ''
  #         ${acc.script}
  #         run ${x.script}
  #       '';
  #     }) {
  #       packages = [];
  #       script = "set -e";
  #     }
  #     configs;
  # in {
  #   home.packages = combine-configs-stage1.packages;
  #   home.file.".vscode-server/extensions/extensions.json".text = extensionJsonFile;
  #   home.activation.copyVscodeExtensions = lib.hm.dag.entryAfter ["writeBoundary"] combine-configs-stage1.script;
  # };

  # Solution 2: Links to $HOME
  addVscodeServerExtention = exts: let
    extensionJsonFile = toExtensionJson exts;
    genHomeConfig = ext: let
      extName = ext.vscodeExtUniqueId;
      version = ext.version;
      srcPath = "${ext}/share/vscode/extensions/${extName}";
      homePath = ".vscode-server/extensions/${extName}";
    in {
      packages = [ext];
      file.${homePath} = {source = srcPath;};
    };
    configs = builtins.map (x: genHomeConfig x) exts;
  in
    lib.lists.foldl' (acc: x: {
      home.packages = acc.home.packages ++ x.packages;
      home.file = lib.attrsets.recursiveUpdate acc.home.file x.file;
    })
    {
      home.packages = [];
      home.file.".vscode-server/extensions/extensions.json".text = extensionJsonFile;
    }
    configs;
  # Solution 3: Links to /nix/store (broken)
  # addVscodeServerExtention = exts: let
  #   extensionJsonFile = pkgs.vscode-utils.toExtensionJson exts;
  # in {
  #   home.packages = exts;
  #   home.file.".vscode-server/extensions/extensions.json".text = extensionJsonFile;
  # };
in
  addVscodeServerExtention (
    deps.extensions
    # with pkgs.vscode-extensions;
    # with pkgs.vscode-marketplace;
    # [
    #   github.copilot-chat
    #   github.copilot
    #
    #   ms-dotnettools.csharp
    #   ms-dotnettools.csdevkit
    #   ms-dotnettools.vscodeintellicode-csharp
    #   ms-dotnettools.vscode-dotnet-runtime
    # ]
  )
