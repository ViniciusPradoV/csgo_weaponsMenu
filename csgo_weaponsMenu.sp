#pragma semicolon 1

#define DEBUG

#define PLUGIN_AUTHOR "Vinicius do Prado Vieira"
#define PLUGIN_VERSION "0.02"

// Slots

#define Slot_Primary		0
#define Slot_Secondary		1
#define Slot_Melee			2
#define Slot_Grenade		3
#define Slot_C4				4
#define Slot_None			5


#define MAX_WEAPON_NAME_LENGTH 	32

#include <sourcemod>
#include <sdktools>
#include <cstrike>
//#include <sdkhooks>

#pragma newdecls required

EngineVersion g_Game;


// Weapon chosen //
char g_sPrimaryWeapon[MAXPLAYERS + 1][MAX_WEAPON_NAME_LENGTH];
char g_sSecondaryWeapon[MAXPLAYERS + 1][MAX_WEAPON_NAME_LENGTH];

// Menu //

bool g_bOpenMenuOnSpawn[MAXPLAYERS + 1] = {true,...};

// Rounds to open menu control variable //

int g_iRoundsToOpenMenu;

// ConVars //

ConVar g_cvPluginEnabled;
ConVar g_cvRoundsToOpenMenu;


public Plugin myinfo = 
{
	name = "[CS:GO] Weapons Menu",
	author = PLUGIN_AUTHOR,
	description = "Lets user choose weapons from a menu",
	version = PLUGIN_VERSION,
	url = ""
};


public void OnPluginStart()
{
	g_Game = GetEngineVersion();
	if(g_Game != Engine_CSGO && g_Game != Engine_CSS)
	{
		SetFailState("This plugin is for CSGO/CSS only.");	
	}
	
	// ConVars //
	
	CreateConVar("csgo_weaponsmenu_version", PLUGIN_VERSION, "[CS:GO] Weapons Menu");
	g_cvPluginEnabled = CreateConVar("csgo_weaponsmenu_enabled", "1", "Controls if plugin is enabled");
	g_cvRoundsToOpenMenu = CreateConVar("csgo_weaponsmenu_roundstomenu", "1", "Set a number of rounds to re-open the menu");
	
	
	
	// Console Commands // 
	
	RegConsoleCmd("sm_weapons", Command_WeaponsMenu, "Displays a menu to choose weapons");
	
	// Event Hooks //

	HookEvent("round_end", RoundEnd_Callback, EventHookMode_Post);
	HookEvent("player_spawn", PlayerSpawn_Callback, EventHookMode_Post);
	
	// Setting open menu control variable //
	
 	g_iRoundsToOpenMenu = g_cvRoundsToOpenMenu.IntValue;
	
	
	AutoExecConfig(true, "csgo_weaponsmenu");
}

public Action Command_WeaponsMenu(int client, int args)
{
	if(!g_cvPluginEnabled.BoolValue)
	{
		return Plugin_Stop;
	}
	
	MenuPrimaryWeapon().Display(client, MENU_TIME_FOREVER);
	return Plugin_Handled;
}


public Menu MenuPrimaryWeapon()
{
	Menu menu = new Menu(MenuPrimaryWeaponHandler, MENU_ACTIONS_DEFAULT);
	menu.SetTitle("Choose a primary weapon");
	menu.AddItem("weapon_ak47", "AK-47");
	menu.AddItem("weapon_m4a1", "M4A4");
	menu.AddItem("weapon_m4a1_silencer", "M4A1-S");
	menu.AddItem("weapon_sg556", "SSG 553");
	menu.AddItem("weapon_aug", "AUG");
	menu.AddItem("weapon_awp", "AWP");
	menu.ExitButton = true;
		
	return menu;
}
	
public int MenuPrimaryWeaponHandler(Menu menu, MenuAction action, int param1, int param2)
{
	switch(action)
	{
		case MenuAction_Select:
		{
			int client = param1;
			int item = param2;
			char weaponChoice[MAX_WEAPON_NAME_LENGTH];
			
			// Storing chosen weapon in weaponChoice string
			menu.GetItem(item, weaponChoice, sizeof(weaponChoice));
			
			// Giving weapon to player
			GiveWeapon(client, Slot_Primary, weaponChoice);
			
			// Copying the chosen weapon into the global variable
			g_sPrimaryWeapon[client] = weaponChoice;
			MenuSecondaryWeapon().Display(client, MENU_TIME_FOREVER);
			
			
		}
		case MenuAction_End:
		{
			delete menu;
		}
	}
}

public Menu MenuSecondaryWeapon()
{
	Menu menu = new Menu(MenuSecondaryWeaponHandler, MENU_ACTIONS_DEFAULT);
	menu.SetTitle("Choose your secondary weapon");
	menu.AddItem("weapon_usp_silencer", "USP-S");
	menu.AddItem("weapon_deagle", "Desert Eagle");
	menu.AddItem("weapon_fiveseven", "Fiveseven");
	menu.AddItem("weapon_glock", "Glock");
	menu.AddItem("weapon_tec9", "Tec9");
	menu.AddItem("weapon_cz75a", "cz75");
	menu.ExitBackButton = true;
	menu.ExitButton = true;
	
	
	return menu;
}

public int MenuSecondaryWeaponHandler (Menu menu, MenuAction action, int param1, int param2)
{
	switch(action)
	{
		case MenuAction_Select:
		{
			int client = param1;
			int item = param2;
			char weaponChoice[MAX_WEAPON_NAME_LENGTH];
			
			// Storing chosen weapon in weaponChoice string
			menu.GetItem(item, weaponChoice, sizeof(weaponChoice));
			
			// Giving weapon to player
			GiveWeapon(client, Slot_Secondary, weaponChoice);
			
			// Copying the chosen weapon into the global variable
			g_sSecondaryWeapon[client] = weaponChoice;
			g_bOpenMenuOnSpawn[client] = false;
			
		}
		case MenuAction_Cancel:
		{
			if(param2 == MenuCancel_ExitBack)
				MenuPrimaryWeapon().Display(param1, MENU_TIME_FOREVER);
			
		}
		case MenuAction_End:
		{
			delete menu;
		}
	}
}

public void PlayerSpawn_Callback(Event e, const char[] name, bool dontBroadcast)
{
	if(!g_cvPluginEnabled.BoolValue)
	{
		return;
	}
	
	// Getting values from event
	int client = GetClientOfUserId(GetEventInt(e, "userid"));
	
	if(IsFakeClient(client) || client == 0)
	{
		return;
	}
	
	if(g_cvRoundsToOpenMenu.IntValue == 0)
	{
		g_bOpenMenuOnSpawn[client] = true;
	}
	
	if(g_bOpenMenuOnSpawn[client])
	{
		MenuPrimaryWeapon().Display(client, MENU_TIME_FOREVER);
	}
	else
	{
		GiveWeapon(client, Slot_Primary, g_sPrimaryWeapon[client]);
		GiveWeapon(client, Slot_Secondary, g_sSecondaryWeapon[client]);
		
	}
	
}

public void RoundEnd_Callback(Event e, const char[] name, bool dontBroadcast)
{
	if(!g_cvPluginEnabled.BoolValue)
	{
		return;
	}
	
	if(g_cvRoundsToOpenMenu.IntValue == 0)
	{
		return;
	}
	
	// If menu opened in the last iteration, reset the control variable
	if(g_iRoundsToOpenMenu == 0)
		g_iRoundsToOpenMenu = g_cvRoundsToOpenMenu.IntValue;
	
	g_iRoundsToOpenMenu--;
	
}

public void OnClientDisconnect(int client)
{
	if (IsFakeClient(client))
	{
		return;
	}
	
	g_bOpenMenuOnSpawn[client] = true;
}



stock void RemoveWeaponBySlot(int client, int slot)
{
	int item = GetPlayerWeaponSlot(client, slot);
	if(item != -1) // If there's a weapon
	{
		RemovePlayerItem(client, item);
	}
}

stock void GiveWeapon(int client, int slot, const char[] weapon)
{
		RemoveWeaponBySlot(client, slot);
		GivePlayerItem(client, weapon);
}