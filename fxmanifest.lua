fx_version 'cerulean'
game 'gta5'
lua54 'yes'

name 'shop'
author 'cereZ'
version "1.0.0"

shared_scripts {

    '@es_extended/imports.lua',
	'@ox_lib/init.lua',
    'shared/*.lua'
}

client_script 'client/client.lua'
server_script 'server/server.lua'

dependencies {
    'es_extended',
    'ox_inventory',
    'ox_lib'
}