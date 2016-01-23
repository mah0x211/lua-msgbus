package = "msgbus"
version = "scm-1"
source = {
    url = "git://github.com/mah0x211/lua-msgbus.git"
}
description = {
    summary = "message-bus module",
    homepage = "https://github.com/mah0x211/lua-msgbus",
    license = "MIT/X11",
    maintainer = "Masatoshi Teruya"
}
dependencies = {
    "lua >= 5.1"
}
build = {
    type = "builtin",
    modules = {
        msgbus = "msgbus.lua",
    }
}

