# csgo_weaponsMenu
A very simple weapon choice menu for CS:GO

This plugin lets you choose a primary and secondary weapon and make them persist for the next round/respawn.


# Installation:

1. Compile the .sp file using SPEdit (https://github.com/JulienKluge/Spedit).
2. Put the generated .smx file on your "plugins" server folder. It should be located on: "server/csgo/addons/sourcemod/plugins".

# CVars - Console Variables

### csgo_weaponsmenu_enabled

 Controls if plugin is enabled - Set "1" to enable and "0" to disable
 
### csgo_weaponsmenu_roundstomenu

Controls number of rounds to re-open the menu automatically, set "0" to disable this function
 
# Console Commands

### sm_weapons

Displays a menu to choose weapons. This menu also opens automatically in the first round. You can also trigger the menu by typing !weapons in the general chat
