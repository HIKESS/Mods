local _G=GLOBAL


AddPlayerPostInit(function(inst)
if not inst.components.aipc_pet_owner then
inst:AddComponent("aipc_pet_owner")
end
end)



AddPrefabPostInit("player_classified",function(inst)
inst.aip_pet_info=_G.net_string(inst.GUID,"aip_pet_info","aip_pet_info_dirty")


inst:ListenForEvent("aip_pet_info_dirty",function()
local petSkillInfoStr=_G.aipSplit(inst.aip_pet_info:value(),"|")[2]

if _G.ThePlayer~=nil and inst==_G.ThePlayer.player_classified and petSkillInfoStr~="" then
local data=_G.json.decode(petSkillInfoStr)
_G.ThePlayer.HUD:OpenAIPPetInfo(inst,data)
end
end)
end)


local PlayerHud=_G.require("screens/playerhud")

local PetInfoScreen=require("widgets/aip_pet_screen")

function PlayerHud:OpenAIPPetInfo(inst,petSkillInfo)
self.aipPetInfoScreen=PetInfoScreen(self.owner,petSkillInfo)
self:OpenScreenUnderPause(self.aipPetInfoScreen)
return self.aipPetInfoScreen
end

function PlayerHud:CloseAIPPetInfo()
if self.aipPetInfoScreen then
self.aipPetInfoScreen:Close()
self.aipPetInfoScreen=nil
end
end


env.AddModRPCHandler(env.modname,"aipTogglePet",function(player,petId)
if player~=nil and player.components.aipc_pet_owner~=nil then
player.components.aipc_pet_owner:TogglePet(petId)
end
end)