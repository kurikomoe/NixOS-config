{
  lib,
  root,
  ...
}: let
  buildAgeSecretsFileList = files: (builtins.foldl' (acc: filename: acc // {${filename}.path = files.${filename};}) {} (builtins.attrNames files));

  agehelper = name: filepath: {
    "${name}" = {
      file = "${root.base}/res/${name}.age";
      path = filepath;
    };
  };
in {
  inherit buildAgeSecretsFileList agehelper;
}
