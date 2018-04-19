#pragma semicolon 1
#pragma newdecls required

#include <smutils>
#include <armsfix>

int results = 2;

#define MODEL "models/player/custom_player/maoling/vocaloid/hatsune_miku/racing_2015/miku.mdl"
#define ARMS  "models/player/custom_player/maoling/vocaloid/hatsune_miku/racing_2015/miku_arms.mdl"

public void OnPluginStart()
{
    HookEvent("player_team", Event_PlayerTeam, EventHookMode_Post);
}

public void OnMapStart()
{
    PrecacheModel(MODEL, true);
    PrecacheModel(ARMS,  true);
}

// in this forward, we dont need check player ig-game or alive
public Action ArmsFix_OnSpawnModel(int client, char[] model, int modelLen, char[] arms, int armsLen)
{
    switch (results)
    {
        case 1: 
        {
            // we do nothing... player use map`s default model.
            return Plugin_Continue;
        }
        case 2:
        {
            // we change player`s model and arms;
            strcopy(model, modelLen, MODEL);
            strcopy(arms,  armsLen,  ARMS);
            return Plugin_Changed;
        }
        case 3:
        {
            // we do nothing... player uses ctm_st6(CT side) or tm_phoenix(T side) by default.
            return Plugin_Handled;
        }
    }
    
    return Plugin_Continue;
}

// in this forward, we dont need check player ig-game or alive
public void ArmsFix_OnArmsFixed(int client)
{
    if(results == 3)
    {
        // we manual change player`s model
        SetEntityModel(client, MODEL);
        SetEntPropString(client, Prop_Send, "m_szArmsModel", ARMS);
    }
}

public void Event_PlayerTeam(Event event, const char[] name, bool dontBroadcast)
{
    int client = GetClientOfUserId(event.GetInt("userid"));
    if(!ClientIsAlive(client))
        return;

    // check status
    if(ArmsFix_ModelSafe(client))
    {
        SetEntityModel(client, MODEL);
        SetEntPropString(client, Prop_Send, "m_szArmsModel", ARMS);
    }
}