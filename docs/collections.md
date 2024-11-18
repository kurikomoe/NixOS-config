## nativeBuildInputs vs buildInputs

ref: https://discourse.nixos.org/t/use-buildinputs-or-nativebuildinputs-for-nix-shell/8464

nativeBuildInputs: 

Should be used for commands which need to run at build time (e.g. cmake) or shell hooks (e.g. autoPatchelfHook). These packages will be of the buildPlatforms architecture, and added to PATH.

buildInputs: 

Should be used for things that need to be linked against (e.g. openssl). These will be of the hostPlaform’s architecture. With strictDeps = true; (or by extension cross-platform builds), these will not be added to PATH. However, linking related variables will capture these packages (e.g. NIX_LD_FLAGS, CMAKE_PREFIX_PATH, PKG_CONFIG_PATH)


## Can I use flakes within a git repo without committing flake.nix?
[url](https://discourse.nixos.org/t/can-i-use-flakes-within-a-git-repo-without-committing-flake-nix/18196)

Here’s a neat workaround:

    Tell git to track flake.nix but without adding it:

git add --intent-to-add flake.nix

Tell git to assume that flake.nix doesn’t have any changes:

    git update-index --assume-unchanged flake.nix

This way you end up with a clean git status, but flake.nix still being tracked by git and therefore accessible to Nix. The only restriction is that you can’t do git operations which would modify/remove the flake.nix

This sounds perfect for a local workaround
