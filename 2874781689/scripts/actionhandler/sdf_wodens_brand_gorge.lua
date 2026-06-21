GLOBAL.setmetatable(env,{__index=function(a,b)return GLOBAL.rawget(GLOBAL,b)end})

local materials={
    {"reviver", 1},
    {"mosquitosack", 0.1},
    {"visceralharvester_ichor", 0.3},
}

--Allow custom blood related items to be used and healing values.
for index, value in ipairs(materials) do
    AddPrefabPostInit(value[1],function (inst)
        inst:AddComponent("sdf_wodens_brand_gorge")
	inst.components.sdf_wodens_brand_gorge:SetConsumeValue(value[2])
    end)
end

--Repair Wodens Brand
local ACTIONS = GLOBAL.ACTIONS
local ActionHandler = GLOBAL.ActionHandler

local id = "SDF_WODENS_BRAND_GORGE"
local name = STRINGS.ACTIONHANDLER_SDF_WODENS_BRAND_GORGE


local fn = function(act)

    if act.target.prefab == "sdf_wodens_brand" then
    	local x,_,z=act.target.Transform:GetWorldPosition()
    	SpawnPrefab("minotaur_blood3").Transform:SetPosition(x,_,z)

	act.target.SoundEmitter:PlaySound("dontstarve/ghost/bloodpump")

	if act.target.components.armor then
	    if act.invobject.components.sdf_wodens_brand_gorge then
		local consumeValue = act.invobject.components.sdf_wodens_brand_gorge:GetConsumeValue()
		local currentPercent = act.target.components.armor:GetPercent()
		if currentPercent <= 0 then
		    currentPercent = 0
		end

		act.target.components.armor:SetPercent(currentPercent + consumeValue)
		act.target:PushEvent("percentusedchange", { percent = act.target.components.armor:GetPercent() })
		act.target:GorgeUpdateFn()
	    end
	end

	--Remove blood type item
	local num=act.invobject.components.stackable and
	act.invobject.components.stackable:StackSize() or 1
	if num>1 then
	    act.invobject.components.stackable:SetStackSize(num-1)
	else
	    act.invobject:Remove()
	end

	return true
    end
    return false
end

AddAction(id,name,fn)

local type = "USEITEM"
local component = "sdf_wodens_brand_gorge"
local testfn = function(inst, doer, target, actions)
    if target:HasTag("sdf_wodens_brand_gorge") then
	table.insert(actions, ACTIONS.SDF_WODENS_BRAND_GORGE)
    end
end

AddComponentAction(type, component, testfn)

local state = "dolongaction"
AddStategraphActionHandler("wilson",ActionHandler(ACTIONS.SDF_WODENS_BRAND_GORGE, state))
AddStategraphActionHandler("wilson_client",ActionHandler(ACTIONS.SDF_WODENS_BRAND_GORGE,state))