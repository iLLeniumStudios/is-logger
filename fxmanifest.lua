fx_version 'cerulean'
game 'gta5'

version '1.3.3'
author 'iLLeniumStudios'

lua54 'yes'

client_scripts {
    'client/config.lua',
    'client/weapons.lua',
    'client/locale.lua',
    'client/functions.lua',
    'client/client.lua',
}

server_scripts {
    'config.lua',
    'server.lua',
    'functions.lua',
    'events.lua',
}

escrow_ignore {
    'config.lua',
    'functions.lua',
    'client/config.lua',
    'client/weapons.lua',
    'client/locale.lua',
    'client/functions.lua',
    'client/client.lua'
}
