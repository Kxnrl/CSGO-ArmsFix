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

native bool ArmsFix_ModelSafe(int client); // true = arms has been fixed = 手臂已经修复

// called on spawn model. = 
// Plugin_Continue = set client model and arms to default. = 设定客户端到默认模型及手臂模型
// Plugin_Changed = set client model and arms to custom model. = 设定客户端到自定义模型及手臂模型
// Plugin_Handled = do nothing -> direct fix. 啥也不做，直接修复
// Plugin_Stop = do nothing -> direct fix. 啥也不做，直接修复
// !!!this call only exec last!!! 这只能在exec最后才能调用
forward Action ArmsFix_OnSpawnModel(int client, char[] model, int modelLen, char[] arms, int armsLen);

// called on arms fixed. 修复手臂后调用
forward void ArmsFix_OnArmsFixed(int client);