GLOBAL.setmetatable(env,{__index=function(a,b)return GLOBAL.rawget(GLOBAL,b)end})

AddPrefabPostInit("lava_pond",function (inst)
    inst:AddTag("sdf_dragon_potion_imbue")
end)


local ACTIONS = GLOBAL.ACTIONS
local ActionHandler = GLOBAL.ActionHandler

local id = "SDF_DRAGON_POTION_IMBUE"
local name = STRINGS.ACTIONHANDLER_SDF_DRAGON_POTION_IMBUE

local fn = function(act)
    if act.doer.prefab == "sdf" then

	--play offering FX
	local x,_,z=act.target.Transform:GetWorldPosition()
	SpawnPrefab("firesplash_fx").Transform:SetPosition(x,_,z)
	act.doer.SoundEmitter:PlaySound("dontstarve_DLC001/common/firesupressor_impact")

	--Spawns in inventory
	local owner = act.invobject.components.inventoryitem ~= nil and act.invobject.components.inventoryitem.owner or nil
	local holder = owner ~= nil and (owner.components.inventory or owner.components.container) or nil
	local dragonPotion = SpawnPrefab("sdf_dragon_potion")

	act.doer.components.sdf_key_item_inventory:SetKeyItem(dragonPotion, act.doer)
	if holder ~= nil then
	    local slot = holder:GetItemSlot(act.invobject)
	    act.invobject:Remove()
	    holder:GiveItem(dragonPotion, slot)
	    return true
	end
    end
    return false
end

AddAction(id,name,fn)

local type = "USEITEM"
local component = "sdf_dragon_potion_imbue"
local testfn = function(inst, doer, target, actions)
    if target:HasTag("sdf_dragon_potion_imbue") or target:HasTag("campfire") then
	table.insert(actions, ACTIONS.SDF_DRAGON_POTION_IMBUE)
    end
end

AddComponentAction(type, component, testfn)

local state = "dolongaction"
AddStategraphActionHandler("wilson",ActionHandler(ACTIONS.SDF_DRAGON_POTION_IMBUE, state))
AddStategraphActionHandler("wilson_client",ActionHandler(ACTIONS.SDF_DRAGON_POTION_IMBUE,state))