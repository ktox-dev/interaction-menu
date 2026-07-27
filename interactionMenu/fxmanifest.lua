--                _
--               | |
--   _____      _| | _____  ___ _ __
--  / __\ \ /\ / / |/ / _ \/ _ \ '_ \
--  \__ \\ V  V /|   <  __/  __/ |_) |
--  |___/ \_/\_/ |_|\_\___|\___| .__/
--                             | |
--                             |_|
-- https://github.com/swkeep

fx_version 'cerulean'
games { 'gta5' }

name 'interactionMenu'
description 'A standalone raycast and world based interaction menu for FiveM'
version '1.0.0'
author "swkeep"
repository 'https://github.com/swkeep/interaction-menu'

shared_scripts {
     'config.shared.lua',
}

client_script {
     -- ox_lib
     -- '@ox_lib/init.lua',
     -- PolyZone
     '@PolyZone/client.lua',
     '@PolyZone/BoxZone.lua',
     '@PolyZone/CircleZone.lua',
     '@PolyZone/ComboZone.lua',

     -- bridges
     'lua/bridge/main.lua',

     -- core
     'lua/client/util.lua',
     'lua/client/menuContainer.lua',
     'lua/client/input_manager.lua',

     'lua/client/client.core.lua',
     'lua/client/features/*.lua',

     'lua/client/sprite_renderer.lua',
     'lua/client/GC.lua',
     'lua/client/example_manager.lua',
     'lua/client/extends/*.lua',

     -- providers
     'lua/providers/qb-target.lua',
     'lua/providers/qb-target_test.lua',
     'lua/providers/ox_target.lua',
     'lua/providers/ox_target_test.lua',

     -- examples / tests
     'lua/examples/*.lua',
}

server_script {
     'lua/server/server.lua'
}

files {
     -- Unter Enhanced scheint der Glob 'icons/*.*' nicht mehr zu greifen:
     -- CreateRuntimeTextureFromImage findet indicator.png nicht. Deshalb die
     -- beiden Dateien zusaetzlich namentlich. Der Glob bleibt fuer den Fall,
     -- dass spaeter weitere Icons dazukommen.
     'lua/client/icons/indicator.png',
     'lua/client/icons/glowingball.png',
     'lua/client/icons/*.*',

     -- Die Bruecken werden zur Laufzeit ueber LoadResourceFile geholt, nicht als
     -- Skript eingebunden. Client-seitig kann das nur Dateien lesen, die hier
     -- stehen -- upstream stand nur `qb.lua` drin, `esx.lua` fehlte. Die
     -- ESX-Bruecke laedt dort also bei niemandem, und unsere ox.lua haette
     -- dasselbe Schicksal gehabt. Der Glob deckt jetzt alle ab.
     'lua/bridge/*.lua',
}

provide 'qb-target'
provide 'ox_target'

lua54 'yes'
