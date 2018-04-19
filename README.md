# CSGO Custom Arms Fix  
#### Fix csgo glove overlap on custom arms.
  
  
### Usage
``` sourcepawn 
forward Action ArmsFix_OnSpawnModel(int client, char[] model, int modelLen, char[] arms, int armsLen)
forward void ArmsFix_OnArmsFixed(int client)
native bool ArmsFix_ModelSafe(client);
```
More details check example.plugin.sp

### Install
* compile the ArmsFix.sp .
* copy ArmsFix.smx to your plugin folder .
