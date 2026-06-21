local assets =
{
    Asset("ANIM", "anim/sdf_pumpkin_gorge_creeper.zip"),

    Asset("IMAGE", "images/map_icons/sdf_pumpkin_gorge_creeper_mm.tex"),
    Asset("ATLAS", "images/map_icons/sdf_pumpkin_gorge_creeper_mm.xml"),
}

local prefabs =
{

}

local function onregenfn(inst)
    inst.AnimState:PlayAnimation("empty_to_full")
    inst.AnimState:PushAnimation("full", true)
    inst.harvested = false
end

local function onpickedfn(inst)
    inst.AnimState:PlayAnimation("full_to_empty")
    inst.AnimState:PushAnimation("empty", true)
    inst.harvested = true
end

local function OnBurnt(inst, immediate)
    if inst.components.pickable:CanBePicked() then
	onpickedfn(inst)
	inst.components.pickable:MakeEmpty()

	local pumpkinCooked = SpawnPrefab("pumpkin_cooked")
	if pumpkinCooked ~= nil then
	    pumpkinCooked.Transform:SetPosition(inst.Transform:GetWorldPosition())
	end
    end
end

local function OnSave(inst, data)
    if inst.harvested == true then
	data.harvested = true
    else
	data.harvested = false
    end
end

local function OnLoad(inst, data)
    if data ~= nil and data.harvested ~= nil then
	if data.harvested == true then
	    inst.harvested = true
	    inst.AnimState:PlayAnimation("empty")
	 end	
    end
end

local function OnSnowLevel(inst, snowlevel)
    if snowlevel >= .01 then
        if not inst.frozen then
            inst.frozen = true

	    --add frost
	    inst.components.colouradder:PushColour("frost", 82 / 255, 115 / 255, 124 / 255, 0)
	end
    elseif inst.frozen then
        inst.frozen = false

	--remove frost
	inst.components.colouradder:PopColour("frost")

    elseif inst.frozen == nil then
        inst.frozen = false

	--remove frost
	inst.components.colouradder:PopColour("frost")

    elseif inst.frozen == false then

	--remove frost
	inst.components.colouradder:PopColour("frost")
    end
end

local function OnInit(inst)
    inst.task = nil
    inst:WatchWorldState("snowlevel", OnSnowLevel)
    OnSnowLevel(inst, TheWorld.state.snowlevel)
end

local function fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddMiniMapEntity()
    inst.entity:AddNetwork()

    inst.MiniMapEntity:SetIcon("sdf_pumpkin_gorge_creeper_mm.tex")

    MakeInventoryPhysics(inst)

    inst.AnimState:SetBank("sdf_pumpkin_gorge_creeper")
    inst.AnimState:SetBuild("sdf_pumpkin_gorge_creeper")
    inst.AnimState:PlayAnimation("full")

    inst.Transform:SetScale(1.15, 1.15, 1.15)

    inst:AddTag("sdf_pumpkin_gorge")
    inst:AddTag("plant")

    inst.entity:SetPristine()
	
    if not TheWorld.ismastersim then
        return inst
    end

    inst:AddComponent("pickable")
    inst.components.pickable.picksound = "dontstarve/wilson/pickup_reeds"
    inst.components.pickable:SetUp("pumpkin", GetRandomMinMax((TUNING.SDF_PUMPKIN_GORGE_CREEPER_GROWTH_TIME_MIN*TUNING.TOTAL_DAY_TIME) * 1, (TUNING.SDF_PUMPKIN_GORGE_CREEPER_GROWTH_TIME_MAX*TUNING.TOTAL_DAY_TIME) * 1), 1)
    --inst.components.pickable.jostlepick = true
    inst.components.pickable.onregenfn = onregenfn
    inst.components.pickable.onpickedfn = onpickedfn

    inst:AddComponent("inspectable")

    inst:AddComponent("colouradder")

    MakeMediumBurnable(inst)
    inst.components.burnable:SetOnBurntFn(OnBurnt)
    MakeSmallPropagator(inst)

    MakeNoGrowInWinter(inst)
    MakeHauntableIgnite(inst)

    inst.harvested = false

    inst.task = inst:DoTaskInTime(0, OnInit)
    inst.OnSave = OnSave
    inst.OnLoad = OnLoad

    return inst
end

return Prefab("sdf_pumpkin_gorge_creeper", fn, assets, prefabs)