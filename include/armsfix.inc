#if defined _ArmsFix_Include_
    #endinput
#endif

#define _ArmsFix_Include_

public SharedPlugin __pl_arms_fix =
{
	name = "ArmsFix",
	file = "ArmsFix.smx",
#if !defined REQUIRE_PLUGIN
    required = 0
#else
    required = 1
#endif
};

native bool ArmsFix_ModelSafe(int client); // true = arms has been fixed

// called on spawn model.
// Plugin_Continue = set client model and arms to default.
// Plugin_Changed = set client model and arms to custom model.
// Plugin_Handled = do nothing -> direct fix.
// Plugin_Stop = do nothing -> direct fix.
// !!!this call only exec last!!!
forward Action ArmsFix_OnSpawnModel(int client, char[] model, int modelLen, char[] arms, int armsLen);

// called on arms fixed.
forward void ArmsFix_OnArmsFixed(int client);