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

// in this forward, we dont need check player ig-game or alive 在此推进，不需要check游戏中玩家是否存活
public Action ArmsFix_OnSpawnModel(int client, char[] model, int modelLen, char[] arms, int armsLen)
{
    switch (results)
    {
        case 1: 
        {
            // we do nothing... player use map`s default model.  player使用地图默认模型
            return Plugin_Continue;
        }
        case 2:
        {
            // we change player`s model and arms;   改变玩家模型和手臂
            strcopy(model, modelLen, MODEL);
            strcopy(arms,  armsLen,  ARMS);
            return Plugin_Changed;
        }
        case 3:
        {
            // we do nothing... player uses ctm_st6(CT side) or tm_phoenix(T side) by default.    人物模型CT默认海豹，T默认凤凰战士
            return Plugin_Handled;
        }
    }
    
    return Plugin_Continue;
}

// in this forward, we dont need check player ig-game or alive  在此推进，不需要check游戏中玩家是否存活
public void ArmsFix_OnArmsFixed(int client)
{
    if(results == 3)
    {
        // we manual change player`s model 手动改变玩家模型
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