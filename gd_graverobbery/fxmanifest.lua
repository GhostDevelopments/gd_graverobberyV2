fx_version 'cerulean'
game 'gta5'
lua54 'yes'

author 'GhostDevelopments'
description 'Generated with GhostDevelopments'
version '1.0.0'

shared_scripts {
    '@ox_lib/init.lua',
    '@qbx_core/modules/lib.lua',
    'config.lua',
    'webhook_config.lua'
}

client_scripts {
    'client/main.lua'
}

server_scripts {
    'server/server.lua'
}

dependencies {
    'qbx_core',
    'ox_lib',
    'ox_target',
    'ox_inventory'
}