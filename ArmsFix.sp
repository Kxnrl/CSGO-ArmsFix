/******************************************************************/
/*                                                                */
/*                      CSGO Custom Arms Fix                      */
/*                                                                */
/*                                                                */
/*  File:          ArmsFix.sp                                     */
/*  Description:   Fix csgo glove overlap on custom arms.         */
/*                                                                */
/*                                                                */
/*  Copyright (C) 2018  Kyle                                      */
/*  2018/04/19 16:13:14                                           */
/*                                                                */
/*  This code is licensed under the GPLv3 License.                  */
/*                                                                */
/******************************************************************/

#pragma semicolon 1
#pragma newdecls required

#include <smutils>
#include <armsfix>

#define PI_NAME "[CSGO] Arms Fix"
#define PI_AUTH "Kyle"
#define PI_DESC "Fix csgo glove overlap on custom arms"
#define PI_VERS "1.4"
#define PI_URLS "https://kxnrl.com"

public Plugin myinfo = 
{
    name        = PI_NAME,
    author      = PI_AUTH,
    description = PI_DESC,
    version     = PI_VERS,
    url         = PI_URLS
};

#define TEAM_TE 0
#define TEAM_CT 1

static char g_szCurMapSkin[2][128];
static char g_szCurMapArms[2][128];

static char g_szSoRetarded[2][128];

static Handle g_fwdOnSpawnSkin;
static Handle g_fwdOnArmsFixed;

static bool g_bArmsFixed[MAXPLAYERS+1];

static int g_iFileTime;


public APLRes AskPluginLoad2(Handle myself, bool late, char[] error, int err_max)
{
    RegPluginLibrary("ArmsFix");

    CreateNative("ArmsFix_ModelSafe", IamNative);

    return APLRes_Success;
}

public int IamNative(Handle plugin, int numParams)
{
    int client = GetNativeCell(1);
    if(client > MaxClients || client < MinClients)
    {
        ThrowNativeError(SP_ERROR_PARAM, "client %d is invalid.", client);
        return false;
    }

    return g_bArmsFixed[client];
}

public void OnPluginStart()
{
    g_fwdOnSpawnSkin = CreateGlobalForward("ArmsFix_OnSpawnModel", ET_Single, Param_Cell, Param_String, Param_Cell, Param_String, Param_Cell);
    g_fwdOnArmsFixed = CreateGlobalForward("ArmsFix_OnArmsFixed",  ET_Ignore, Param_Cell);

    if(!HookEventEx("player_spawn", Event_PlayerSpawn, EventHookMode_Post))
    {
        SetFailState("Hook event \"player_spawn\" failed");
        return;
    }

    HookEvent("player_death", Event_PlayerDeath, EventHookMode_Post);
    
    CheckGameModes();
}

public void OnMapStart()
{
    strcopy(g_szCurMapSkin[TEAM_TE], 128, "models/player/custom_player/legacy/tm_phoenix.mdl");
    strcopy(g_szCurMapSkin[TEAM_CT], 128, "models/player/custom_player/legacy/ctm_st6.mdl");
    
    strcopy(g_szCurMapArms[TEAM_TE], 128, "models/weapons/t_arms.mdl");
    strcopy(g_szCurMapArms[TEAM_CT], 128, "models/weapons/ct_arms.mdl");
    
    strcopy(g_szSoRetarded[TEAM_TE], 128, "models/player/custom_player/legacy/tm_pirate.mdl");
    strcopy(g_szSoRetarded[TEAM_CT], 128, "models/player/custom_player/legacy/ctm_gign.mdl");

    LoadMapKV();

    PrecacheModel(g_szCurMapSkin[TEAM_TE], true);
    PrecacheModel(g_szCurMapSkin[TEAM_CT], true);
    PrecacheModel(g_szCurMapArms[TEAM_TE], true);
    PrecacheModel(g_szCurMapArms[TEAM_CT], true);
    PrecacheModel(g_szSoRetarded[TEAM_TE], true);
    PrecacheModel(g_szSoRetarded[TEAM_CT], true);
}

public void OnMapEnd()
{
    CheckGameModes();
}

static void LoadMapKV()
{
    char path[256];
    GetCurrentMap(path, 256);

    KeyValues kv = new KeyValues(path);

    Format(path, 256, "maps/%s.kv", path);

    if(!kv.ImportFromFile(path))
    {
        delete kv;
        return;
    }

    kv.GetString("t_arms",  g_szCurMapArms[TEAM_TE], 128, "models/weapons/t_arms.mdl");
    kv.GetString("ct_arms", g_szCurMapArms[TEAM_CT], 128, "models/weapons/ct_arms.mdl");

    if(kv.JumpToKey("t_models", false) && kv.GotoFirstSubKey(false))
    {
        char model[128];
        if(kv.GetSectionName(model, 128) && strlen(model) > 3)
        {
            Format(model, 128, "models/player/custom_player/legacy/%s.mdl", model);
            StringToLower(model, g_szCurMapSkin[TEAM_TE], 128);
            
            if(strcmp(g_szCurMapSkin[TEAM_TE], g_szSoRetarded[TEAM_TE]) == 0)
            {
                // CHANGE SKIN
                strcopy(g_szSoRetarded[TEAM_TE], 128, "models/player/custom_player/legacy/tm_anarchist.mdl");
            }
        }
    }

    kv.Rewind();

    if(kv.JumpToKey("ct_models", false) && kv.GotoFirstSubKey(false))
    {
        char model[128];
        if(kv.GetSectionName(model, 128) && strlen(model) > 3)
        {
            Format(model, 128, "models/player/custom_player/legacy/%s.mdl", model);
            StringToLower(model, g_szCurMapSkin[TEAM_CT], 128);
            
            if(strcmp(g_szCurMapSkin[TEAM_CT], g_szSoRetarded[TEAM_CT]) == 0)
            {
                // CHANGE SKIN
                strcopy(g_szSoRetarded[TEAM_CT], 128, "models/player/custom_player/legacy/ctm_fbi.mdl");
            }
        }
    }

    delete kv;
}

static void CheckGameModes()
{
    if(GetFileTime("gamemodes_server.txt", FileTime_LastChange) == g_iFileTime)
    {
        return;
    }

    KeyValues kv = new KeyValues("GameModes_Server.txt");
    
    if(FileExists("gamemodes_server.txt"))
    {
        kv.ImportFromFile("gamemodes_server.txt");
    }
    else
    {
        kv.ExportToFile("gamemodes_server.txt");
    }

    kv.JumpToKey("maps", true);

    DirectoryListing hDir = OpenDirectory("maps");
    if(hDir == null)
    {
        SetFailState("Can not open maps folder");
        return;
    }

    FileType type;
    char map[256];
    while(hDir.GetNext(map, 256, type))
    {
        if(type != FileType_File || StrContains(map, ".bsp", false) == -1)
        {
            continue;
        }

        ReplaceString(map, 256, ".bsp", "", false);

        //*** processing ***//
        
        // create tree
        kv.JumpToKey(map, true);

        // global data
        kv.SetString("name", map);
        kv.SetNum("default_game_type", 0);
        kv.SetNum("default_game_mode", 0);
        
        // t-side
        kv.SetString("t_arms", "models/weapons/t_arms_phoenix.mdl");
        kv.JumpToKey("t_models", true);
        kv.SetString("tm_phoenix", " ");
        kv.SetString("tm_phoenix_variantA", " ");
        kv.SetString("tm_phoenix_variantB", " ");
        kv.SetString("tm_phoenix_variantC", " ");
        kv.SetString("tm_phoenix_variantD", " ");
        kv.GoBack();
        
        // ct-side
        kv.SetString("ct_arms", "models/weapons/ct_arms_st6.mdl");
        kv.JumpToKey("ct_models", true);
        kv.SetString("ctm_st6", " ");
        kv.SetString("ctm_st6_variantA", " ");
        kv.SetString("ctm_st6_variantB", " ");
        kv.SetString("ctm_st6_variantC", " ");
        kv.SetString("ctm_st6_variantD", " ");
        kv.GoBack();

        // go back
        kv.GoBack();
    }
    
    kv.Rewind();
    kv.ExportToFile("gamemodes_server.txt");
    
    delete hDir;
    delete kv;
    
    g_iFileTime = GetFileTime("gamemodes_server.txt", FileTime_LastChange);
}

public void OnClientConnected(int client)
{
    g_bArmsFixed[client] = false;
}

public void OnClientDisconnect_Post(int client)
{
    g_bArmsFixed[client] = false;
}

public void Event_PlayerSpawn(Event event, const char[] name, bool dontBroadcast)
{
    CreateTimer(0.02, Timer_SpawnPost, event.GetInt("userid"), TIMER_FLAG_NO_MAPCHANGE);
}

public Action Timer_SpawnPost(Handle timer, int userid)
{
    int client = GetClientOfUserId(userid);
    if(!ClientIsAlive(client, true))
        return Plugin_Stop;
    
    int iTeam = GetClientTeam(client);

    Action result = Plugin_Continue;
    
    char skin[128], arms[128];
    strcopy(skin, 128, g_szCurMapSkin[iTeam-2]);
    strcopy(arms, 128, g_szCurMapArms[iTeam-2]);

    Call_StartForward(g_fwdOnSpawnSkin);
    Call_PushCell(client);
    Call_PushStringEx(skin, 128, SM_PARAM_STRING_UTF8|SM_PARAM_STRING_COPY, SM_PARAM_COPYBACK);
    Call_PushCell(128);
    Call_PushStringEx(arms,  128, SM_PARAM_STRING_UTF8|SM_PARAM_STRING_COPY, SM_PARAM_COPYBACK);
    Call_PushCell(128);
    Call_Finish(result);

    if(result == Plugin_Continue)
    {
        SetEntityModel(client, g_szCurMapSkin[iTeam-2]);
        SetEntPropString(client, Prop_Send, "m_szArmsModel", g_szCurMapArms[iTeam-2]);

        CreateTimer(0.02, Timer_ArmsFixed, GetClientUserId(client), TIMER_FLAG_NO_MAPCHANGE);

        return Plugin_Stop;
    }
    else if(result == Plugin_Changed)
    {
        // Fucking retarded bug...
        // If we wanna change arms model only (without changing player skin), The gloves overlap may appear .
        if(strcmp(skin, g_szCurMapSkin[iTeam-2]) == 0)
        {
            // we need change player skin.
            SetEntityModel(client, g_szSoRetarded[iTeam-2]);
        }
        else
        {
            if(IsModelPrecached(skin))
            {
                SetEntityModel(client, skin);
            }
            else
            {
                LogError(" [%s] is not precached", skin);
                SetEntityModel(client, g_szCurMapSkin[iTeam-2]);
            }
        }

        if(IsModelPrecached(arms))
        {
            SetEntPropString(client, Prop_Send, "m_szArmsModel", arms);
        }
        else
        {
            LogError(" [%s] is not precached", arms);
            SetEntPropString(client, Prop_Send, "m_szArmsModel", g_szCurMapArms[iTeam-2]);
        }

        CreateTimer(0.02, Timer_ArmsFixed, GetClientUserId(client), TIMER_FLAG_NO_MAPCHANGE);

        return Plugin_Stop;
    }

    CreateTimer(0.02, Timer_ArmsFixed, GetClientUserId(client), TIMER_FLAG_NO_MAPCHANGE);

    return Plugin_Stop;
}

public Action Timer_ArmsFixed(Handle timer, int userid)
{
    int client = GetClientOfUserId(userid);

    if(ClientIsAlive(client, true))
    {
        g_bArmsFixed[client] = true;

        Call_StartForward(g_fwdOnArmsFixed);
        Call_PushCell(client);
        Call_Finish();
    }

    return Plugin_Stop;
}

public void Event_PlayerDeath(Event event, const char[] name, bool dontBroadcast)
{
    g_bArmsFixed[GetClientOfUserId(event.GetInt("userid"))] = false;
}