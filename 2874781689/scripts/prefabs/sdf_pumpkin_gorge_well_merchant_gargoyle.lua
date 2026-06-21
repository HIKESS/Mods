local assets=
{
    Asset("ANIM", "anim/sdf_pumpkin_gorge_well_merchant_gargoyle.zip"),
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
    inst.entity:AddNetwork()
    inst.entity:AddSoundEmitter()

    local s = 1.5
    inst.Transform:SetScale(s,s,s)
     
    inst.AnimState:SetBank("sdf_pumpkin_gorge_well_merchant_gargoyle")
    inst.AnimState:SetBuild("sdf_pumpkin_gorge_well_merchant_gargoyle")
    inst.AnimState:PlayAnimation("idle")

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
    inst.components.playerprox:SetDist(0.1,0.3)

    inst:AddComponent("hauntable")
    inst.components.hauntable:SetHauntValue(TUNING.HAUNT_TINY)

    return inst
end

return  Prefab("sdf_pumpkin_gorge_well_merchant_gargoyle", fn, assets)