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

public Action ArmsFix_OnSpawnModel(int client, char[] model, int modelLen, char[] arms, int armsLen)
{
    switch (results)
    {
        case 1: 
        {
            // Do nothing... But let players uses map`s default model.
            return Plugin_Continue;
        }
        case 2:
        {
            // We changed player`s model and arms here;
            strcopy(model, modelLen, MODEL);
            strcopy(arms,  armsLen,  ARMS);
            return Plugin_Changed;
        }
        case 3:
        {
            // Do nothing... But let players uses ctm_st6(CT side) or tm_phoenix(T side) by default.
            return Plugin_Handled;
        }
    }
    
    return Plugin_Continue;
}

// In this forward, there's no necessary for check if in-game player is alive.
public void ArmsFix_OnArmsFixed(int client)
{
    if(results == 3)
    {
        // We changed player`s model manually.
        SetEntityModel(client, MODEL);
        SetEntPropString(client, Prop_Send, "m_szArmsModel", ARMS);
    }
}

public void Event_PlayerTeam(Event event, const char[] name, bool dontBroadcast)
{
    int client = GetClientOfUserId(event.GetInt("userid"));
    if(!ClientIsAlive(client))
        return;

    // Check status
    if(ArmsFix_ModelSafe(client))
    {
        SetEntityModel(client, MODEL);
        SetEntPropString(client, Prop_Send, "m_szArmsModel", ARMS);
    }
}