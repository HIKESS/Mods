local assets=
{
    Asset("ANIM", "anim/sdf_witch_cauldron.zip"),

    Asset("IMAGE", "images/map_icons/sdf_witch_cauldron_mm.tex"),
    Asset("ATLAS", "images/map_icons/sdf_witch_cauldron_mm.xml"),
}


local prefabs = {
}

local function boil(inst)
    if inst:HasTag("boiling") then
	local chance = math.random(1,2)
	local pos = inst:GetPosition()
	if chance ==1 then
	    inst.SoundEmitter:PlaySound("dontstarve/creatures/together/lavae/move_small")
	else
	    inst.SoundEmitter:PlaySound("dontstarve/creatures/together/lavae/move")
	end	
    end
	
    if inst:HasTag("slowboiling") then
	local chance2 = math.random(1,4)
	local pos = inst:GetPosition()
	if chance2 ==1 then
	    inst.SoundEmitter:PlaySound("dontstarve/creatures/together/lavae/move_small")
	elseif chance2 ==2 then
	    inst.SoundEmitter:PlaySound("dontstarve/creatures/together/lavae/move")
	end
		
    end
end

local function setcauldrontype(inst, typeid)
    typeid = typeid
    if typeid ~= inst.typeid then
        inst.typeid = typeid
    end
end

local function onload(inst, data, newents)
    if data ~= nil and data.typeid ~= nil then
        setcauldrontype(inst, data.typeid)
    end
end

local function onsave(inst, data)
    data.typeid = inst.typeid
end

local function fn(Sim)
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()
    inst.entity:AddMiniMapEntity()
    inst.entity:AddNetwork()

    inst.MiniMapEntity:SetIcon("sdf_witch_cauldron_mm.tex")

    MakeObstaclePhysics(inst, .75)

    local s = 1.2 --1.2
    inst.Transform:SetScale(s,s,s)

    --[[local light = inst.entity:AddLight()
    inst.Light:Enable(false)
    inst.Light:SetRadius(.6)
    inst.Light:SetFalloff(1)
    inst.Light:SetIntensity(.5)
    inst.Light:SetColour(235/255,62/255,12/255)]]

    inst.AnimState:SetBank("sdf_witch_cauldron")
    inst.AnimState:SetBuild("sdf_witch_cauldron")
    inst.AnimState:PlayAnimation("idle")

    --inst.AnimState:PlayAnimation("emptying")
    --inst.AnimState:PushAnimation("filling")
    --inst.AnimState:PushAnimation("idle_loop", true)

    inst:AddTag("blocker")
    inst:AddTag("structure")
    inst:AddTag("antlion_sinkhole_blocker")

    inst.entity:SetPristine()
	
    if not TheWorld.ismastersim then
        return inst
    end

    inst.typeid = 0
    setcauldrontype(inst, inst.typeid)

    inst:AddComponent("inspectable")

    inst:AddComponent("hauntable")
    inst.components.hauntable:SetHauntValue(TUNING.HAUNT_TINY)

    MakeSnowCovered(inst)

    inst:DoPeriodicTask(1, function() boil(inst) end)

    inst.OnSave = onsave
    inst.OnLoad = onload

    return inst
end

return Prefab("sdf_witch_cauldron", fn, assets, prefabs)