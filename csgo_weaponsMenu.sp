#pragma semicolon 1

#define DEBUG

#define PLUGIN_AUTHOR "Vinicius do Prado Vieira"
#define PLUGIN_VERSION "0.01"

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

// Menu

bool g_bOpenMenuOnSpawn[MAXPLAYERS + 1] = {true,...};


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
	
	RegConsoleCmd("sm_weapons", Command_WeaponsMenu, "Displays a menu to choose weapons");
	
	// Event Hooks //
	
	// HookEvent("player_death", PlayerDeath_Callback, EventHookMode_Post);
	HookEvent("player_spawn", PlayerSpawn_Callback, EventHookMode_Post);
	
}

public Action Command_WeaponsMenu(int client, int args)
{
	MenuPrimaryWeapon().Display(client, MENU_TIME_FOREVER);
	return Plugin_Handled;
}


public Menu MenuPrimaryWeapon()
{
	Menu menu = new Menu(MenuPrimaryWeaponHandler, MENU_ACTIONS_ALL);
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
	Menu menu = new Menu(MenuSecondaryWeaponHandler, MENU_ACTIONS_ALL);
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

/*public void PlayerDeath_Callback(Event e, const char[] name, bool dontBroadcast)
{
	// Getting values from event
	int client = GetClientOfUserId(GetEventInt(e, "userid"));

	
	if(!IsFakeClient(client))
	{
		// Getting entity index for the weapons
		int EntityIndexPrimary = GetPlayerWeaponSlot(client, Slot_Primary);
		int EntityIndexSecondary = GetPlayerWeaponSlot(client, Slot_Secondary);
		
		// If both the slots are empty or are standard weapons
		if (EntityIndexPrimary != -1 && (StrEqual("weapon_hkp2000",g_sSecondaryWeapon[client])) || 
										(StrEqual("weapon_glock", g_sSecondaryWeapon[client])) ||
										(StrEqual("weapon_usp_silencer", g_sSecondaryWeapon[client]))
																							)	
		{	
			
			// Getting class names for the weapons equipped before dying
			GetEdictClassname(EntityIndexPrimary, g_sPrimaryWeapon[client], MAX_WEAPON_NAME_LENGTH);
			GetEdictClassname(EntityIndexSecondary, g_sSecondaryWeapon[client], MAX_WEAPON_NAME_LENGTH);
			g_bOpenMenuOnSpawn[client] = false;
		}
		else
		{
			PrintToServer("PlayerDeath else");
			g_bOpenMenuOnSpawn[client] = true;
		}
	}
}*/

public void PlayerSpawn_Callback(Event e, const char[] name, bool dontBroadcast)
{
	
	// Getting values from event
	int client = GetClientOfUserId(GetEventInt(e, "userid"));
	
	if(IsFakeClient(client) || client == 0)
	{
		return;
	}
	
	if(g_bOpenMenuOnSpawn[client])
	{
		PrintToServer("PlayerSpawned Open menu");
		MenuPrimaryWeapon().Display(client, MENU_TIME_FOREVER);
	}
	else
	{
		PrintToServer("PlayerSpawned EquipPlayerWeapon");
		GiveWeapon(client, Slot_Primary, g_sPrimaryWeapon[client]);
		GiveWeapon(client, Slot_Secondary, g_sSecondaryWeapon[client]);
	}
	
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