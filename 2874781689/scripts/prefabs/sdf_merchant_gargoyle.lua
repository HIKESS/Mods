local assets=
{
    Asset("ATLAS", "images/map_icons/sdf_merchant_gargoyle_mm.xml"),
    Asset("IMAGE", "images/map_icons/sdf_merchant_gargoyle_mm.tex"),

    Asset("ANIM", "anim/sdf_merchant_gargoyle.zip"),
}

prefabs = {
}

local MERCHANT_ON = false --Use for mercent glow

local function merchantturnoff(inst)
    if inst.MERCHANT_ON == true then
	inst.MERCHANT_ON = false
	inst:RemoveTag("sdf_witch_talisman_offering")
        inst.AnimState:PlayAnimation("merchant_glow_end")
        inst.AnimState:PushAnimation("idle")
    end
end

local function merchantturnon(inst)
     for k, v in pairs(inst.components.prototyper.doers) do
	if k.prefab == "sdf" then
	    --merchant glow on
	    inst.MERCHANT_ON = true
	    inst.AnimState:PlayAnimation("merchant_glow_start")
	    inst.AnimState:PushAnimation("merchant_glow")

	    inst:AddTag("sdf_witch_talisman_offering")

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
     
    inst.AnimState:SetBank("sdf_merchant_gargoyle")
    inst.AnimState:SetBuild("sdf_merchant_gargoyle")
    inst.AnimState:PlayAnimation("idle")

    MakeObstaclePhysics(inst, .5)

    inst:AddTag("structure")
    inst:AddTag("prototyper")
    inst:AddTag("sdf_merchant_gargoyle")
    inst:AddTag("sdf_soul_helmet_offering")

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst:AddComponent("inspectable")
 
    inst:AddComponent("prototyper")
    inst.components.prototyper.trees = TUNING.PROTOTYPER_TREES.SDF_MERCHANT_GARGOYLE_ONE
    inst.components.prototyper.onturnon = merchantturnon
    inst.components.prototyper.onturnoff = merchantturnoff
    --inst.components.prototyper.restrictedtag = "sdf_builder"

    inst:AddComponent("playerprox")
    inst.components.playerprox:SetDist(3,3.2)

    inst:AddComponent("hauntable")
    inst.components.hauntable:SetHauntValue(TUNING.HAUNT_TINY)

    return inst
end

return  Prefab("sdf_merchant_gargoyle", fn, assets)