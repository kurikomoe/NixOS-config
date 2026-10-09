-- lua/plugins/init.lua
-- 只做 spec 聚合，具体插件写在各分组文件里。
-- lazy.nvim 会自动 import 本目录下的其它文件（见 lazy.lua 里 `{ import = "plugins" }`），
-- 但为了显式清晰，这里主动 return 一份空 spec，实际内容在同级 *.lua 文件里定义。
return {}
