fx_version "cerulean"
game "gta5"
lua54 "yes"

name "fst_custom_minimap"
description "Adds extra tiles with textures on the minimap and pause menu map beyond the default game limit."
author "Frostbyte Studios"
version "3.0.1"

client_scripts {
  "utils.lua",
  "scaleforms.lua",
  "exports.lua",
  "client.lua",
}

shared_scripts {
  "config.lua"
}

files {
  "stream/*.ytd",
  "stream/minimap_main_map.gfx"
}
