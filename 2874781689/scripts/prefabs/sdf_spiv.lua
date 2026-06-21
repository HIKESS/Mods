local assets=
{
    Asset("ATLAS", "images/map_icons/sdf_merchant_gargoyle_mm.xml"),
    Asset("IMAGE", "images/map_icons/sdf_merchant_gargoyle_mm.tex"),

    Asset("ANIM", "anim/sdf_spiv.zip"),
}

prefabs = {
}

local SPIV_ON = false --Use for Spiv

local function spivturnoff(inst)
    if inst.SPIV_ON == true then
	inst.SPIV_ON = false
	inst:RemoveTag("sdf_witch_talisman_offering")
        --inst.AnimState:PlayAnimation("merchant_glow_end")
        --inst.AnimState:PushAnimation("idle")
    end
end

local function spivturnon(inst)
     for k, v in pairs(inst.components.prototyper.doers) do
	if k.prefab == "sdf" then
	    --spiv glow on
	    inst.SPIV_ON = true
	    --inst.AnimState:PlayAnimation("merchant_glow_start")
	    --inst.AnimState:PushAnimation("merchant_glow")

	    --check for shield trade
	    local usedChaliceCount = k.components.sdf_chalice_counter:GetUsedChaliceCount()
	    if usedChaliceCount > 10 then
		inst:AddTag("sdf_witch_talisman_offering")
	    end

	    --greet
	    inst:DoTaskInTime(0.7,function()
		inst.SoundEmitter:PlaySound("dontstarve/common/together/petrified/post")
	    end)
	end
    end
end

local function fn()

    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddMiniMapEntity()
    inst.entity:AddNetwork()
    inst.entity:AddSoundEmitter()

    inst.MiniMapEntity:SetIcon("sdf_merchant_gargoyle_mm.tex")

    local s = 1.5
    inst.Transform:SetScale(s,s,s)
     
    inst.AnimState:SetBank("sdf_spiv")
    inst.AnimState:SetBuild("sdf_spiv")
    inst.AnimState:PlayAnimation("idle")


    MakeObstaclePhysics(inst, .5)

    inst:AddTag("structure")
    inst:AddTag("prototyper")
    inst:AddTag("sdf_spiv")

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst:AddComponent("inspectable")
 
    inst:AddComponent("prototyper")
    inst.components.prototyper.trees = TUNING.PROTOTYPER_TREES.SDF_SPIV_ONE
    inst.components.prototyper.onturnon = spivturnon
    inst.components.prototyper.onturnoff = spivturnoff
    inst.components.prototyper.restrictedtag = "sdf_builder"

    inst:AddComponent("playerprox")
    inst.components.playerprox:SetDist(3,3.2)

    inst:AddComponent("hauntable")
    inst.components.hauntable:SetHauntValue(TUNING.HAUNT_TINY)

    return inst
end

return  Prefab("sdf_spiv", fn, assets)