GLOBAL.require("recipe")

--local PlayerHud=GLOBAL.require("screens/playerhud")
--local ConfigWidget=GLOBAL.require("widgets/aipConfigWidget")

local function canPackage(inst)
if not inst then
return false
end


if not inst:HasTag("structure") then
return false
end


if not GLOBAL.IsRecipeValid(inst.prefab) then
return false
end

return true
end




























local old_HAMMER=GLOBAL.ACTIONS.HAMMER.fn


GLOBAL.ACTIONS.HAMMER.fn=function(act,...)
local doer=act.doer
local target=act.target
local item=act.invobject

if item and item:HasTag("aip_proxy_action") and item.components.aipc_action then

if not canPackage(target) then
return false,"INUSE"
end


if item.components.aipc_action then
item.components.aipc_action:DoTargetAction(doer,target)
return true
end

return false,"INUSE"
end

if old_HAMMER then
return old_HAMMER(act,...)
end

return false,"INUSE"
end


--rmb=true
local AIP_PACKAGER=env.AddAction("AIP_PACKAGER","Package",function(act,...)
return GLOBAL.ACTIONS.HAMMER.fn(act,...)
















end)
AIP_PACKAGER.rmb=true
AIP_PACKAGER.priority=10
AIP_PACKAGER.mount_valid=true

AddStategraphActionHandler("wilson",GLOBAL.ActionHandler(AIP_PACKAGER,"doshortaction"))
AddStategraphActionHandler("wilson_client",GLOBAL.ActionHandler(AIP_PACKAGER,"doshortaction"))


env.AddComponentAction("USEITEM","aipc_info_client",function(inst,doer,target,actions,right)

if not canPackage(target) then
return
end

if inst:HasTag("aip_package") then
table.insert(actions,GLOBAL.ACTIONS.AIP_PACKAGER)
end
end)
