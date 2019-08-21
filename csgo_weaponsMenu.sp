#pragma semicolon 1

#define DEBUG

#define PLUGIN_AUTHOR "Vinicius do Prado Vieira"
#define PLUGIN_VERSION "0.01"

#include <sourcemod>
#include <sdktools>
#include <cstrike>
//#include <sdkhooks>

#pragma newdecls required

EngineVersion g_Game;

// Enums

enum Slots
{
	Slot_Primary,
	Slot_Secondary,
	Slot_Knife,
	Slot_Grenade,
	Slot_C4,
	Slot_None
};

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
	menu.AddItem("1", "AK-47");
	menu.AddItem("2", "M4A4");
	menu.AddItem("3", "M4A1-S");
	menu.AddItem("4", "SSG 553");
	menu.AddItem("5", "AUG");
	menu.AddItem("6", "AWP");
	menu.ExitButton = true;
		
	return menu;
}
	
public int MenuPrimaryWeaponHandler(Menu menu, MenuAction action, int client, int item)
{
	switch(action)
	{
		case MenuAction_Select:
		{
			char choice[32];
			menu.GetItem(item, choice, sizeof(choice));
			if(StrEqual(choice, "1"))
			{
				GiveWeapon(client, Slot_Primary, "weapon_ak47");
				delete menu;
				MenuSecondaryWeapon().Display(client, MENU_TIME_FOREVER);
			}
			else if(StrEqual(choice, "2"))
			{
				GiveWeapon(client, Slot_Primary, "weapon_m4a1");
				delete menu;
				MenuSecondaryWeapon().Display(client, MENU_TIME_FOREVER);
			}
			else if(StrEqual(choice, "3"))
			{
				GiveWeapon(client, Slot_Primary, "weapon_m4a1_silencer");
				delete menu;
				MenuSecondaryWeapon().Display(client, MENU_TIME_FOREVER);
			}
			else if(StrEqual(choice, "4"))
			{
				GiveWeapon(client, Slot_Primary, "weapon_sg556");
				delete menu;
				MenuSecondaryWeapon().Display(client, MENU_TIME_FOREVER);
			}
			else if(StrEqual(choice, "5"))
			{
				GiveWeapon(client, Slot_Primary, "weapon_aug");
				delete menu;
				MenuSecondaryWeapon().Display(client, MENU_TIME_FOREVER);
			}
			else if(StrEqual(choice, "6"))
			{
				GiveWeapon(client, Slot_Primary, "weapon_awp");
				delete menu;
				MenuSecondaryWeapon().Display(client, MENU_TIME_FOREVER);
			}
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
	menu.AddItem("1", "USP-S");
	menu.AddItem("2", "Desert Eagle");
	menu.AddItem("3", "Fiveseven");
	menu.AddItem("4", "Glock");
	menu.AddItem("5", "Tec9");
	menu.AddItem("6", "cz75");
	menu.ExitBackButton = true;
	menu.ExitButton = true;
	
	
	return menu;
}

public int MenuSecondaryWeaponHandler (Menu menu, MenuAction action, int client, int item)
{
	switch(action)
	{
		case MenuAction_Select:
		{
			char choice[32];
			menu.GetItem(item, choice, sizeof(choice));
			if(StrEqual(choice, "1"))
			{
				GiveWeapon(client, Slot_Secondary, "weapon_usp_silencer");
			}
			else if(StrEqual(choice, "2"))
			{
				GiveWeapon(client, Slot_Secondary, "weapon_deagle");
			}
			else if(StrEqual(choice, "3"))
			{
				GiveWeapon(client, Slot_Secondary, "weapon_glock");
			}
			else if(StrEqual(choice, "4"))
			{
				GiveWeapon(client, Slot_Secondary, "weapon_p250");
			}
			else if(StrEqual(choice, "5"))
			{
				GiveWeapon(client, Slot_Secondary, "weapon_tec9");
			}
			else if(StrEqual(choice, "6"))
			{
				GiveWeapon(client, Slot_Secondary, "weapon_cz75a");
			}
			
		}
		case MenuAction_Cancel:
		{
			MenuPrimaryWeapon().Display(client, MENU_TIME_FOREVER);
			
		}
		case MenuAction_End:
		{
			delete menu;
		}
	}
}

stock void RemoveWeaponBySlot(int client, Slots slot)
{
	int item = GetPlayerWeaponSlot(client, slot);
	if(item != -1) // If there's a weapon
	{
		RemovePlayerItem(client, item);
	}
}

stock void GiveWeapon(int client, Slots slot, const char[] weapon)
{
		RemoveWeaponBySlot(client, slot);
		GivePlayerItem(client, weapon);
}