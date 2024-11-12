let
  buildAgeSecretsFileList = files: (builtins.foldl' (acc: filename: acc // {${filename}.path = files.${filename};}) {} (builtins.attrNames files));
in {
  inherit buildAgeSecretsFileList;
}
