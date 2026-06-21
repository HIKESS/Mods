local assets =
{
    Asset("ANIM", "anim/gw_mojing.zip"),
    Asset("ATLAS", "images/inventoryimages/gw_mojing.xml"),
    Asset("IMAGE", "images/inventoryimages/gw_mojing.tex"),
}

local function CreateFX()
    local inst = CreateEntity()
    
    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddFollower()
    inst.entity:AddNetwork()
    
    inst:AddTag("FX")
    -- inst:AddTag("NOCLICK")
    
    inst.AnimState:SetBank("gw_mojing")
    inst.AnimState:SetBuild("gw_mojing")
    inst.AnimState:PlayAnimation("swap_0", true)
    
    inst.entity:SetPristine()
    
    if not TheWorld.ismastersim then
        return inst
    end
    
    inst.persists = false
    
    return inst
end

local function CreateFollowFX(inst, owner)
    if inst._fxactive then
        return 
    end

    inst.fx_swap0 = SpawnPrefab("gw_mojing_fx")
    if inst.fx_swap0 ~= nil then
        inst.fx_swap0.entity:SetParent(owner.entity)
        inst.fx_swap0.Follower:FollowSymbol(owner.GUID, "headbase",nil, nil,nil, false, nil,1) 
        inst._fxactive = true
    end
end

local function RemoveFollowFX(inst,owner)
    if inst.fx_swap0 ~= nil then
        inst.fx_swap0:Remove()
        inst.fx_swap0 = nil
    end
    inst._fxactive = nil
end

local function OnDropped(inst)
    if inst._fxactive then
        RemoveFollowFX(inst)
    end
end


local function mojing_spell(inst) 
    local doer = inst.components.inventoryitem.owner or nil

    if doer == nil or not doer:IsValid() then
        return
    end

    if inst._fxactive then
        RemoveFollowFX(inst)
        doer.AnimState:ClearOverrideSymbol("swap_face", "gw_mojing", "swap_hat")
        if doer.components.talker ~= nil then
            doer.components.talker:Say("墨镜特效已关闭")
        end
    else
        CreateFollowFX(inst, doer)
        doer.AnimState:OverrideSymbol("swap_face", "gw_mojing", "swap_hat")
        if doer.components.talker ~= nil then
            doer.components.talker:Say("墨镜特效已开启")
        end
    end
end


local function fn()
	local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddNetwork()

    MakeInventoryPhysics(inst)
	MakeInventoryFloatable(inst, "med", .15, 0.71)

    inst.AnimState:SetBank("gw_mojing")
    inst.AnimState:SetBuild("gw_mojing")
    inst.AnimState:PlayAnimation("anim")

	inst:AddTag("hat")
	inst:AddTag("hide")

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst:AddComponent("inspectable")

    inst:AddComponent("inventoryitem")
	inst.components.inventoryitem.atlasname = "images/inventoryimages/gw_mojing.xml"
    inst.components.inventoryitem:SetOnDroppedFn(OnDropped) 


    inst:AddComponent("tradable")

    inst:AddComponent("spellcaster")
    inst.components.spellcaster:SetSpellFn(mojing_spell)
    inst.components.spellcaster.canusefrominventory = true
    inst.components.spellcaster.veryquickcast = true


	MakeHauntableLaunchAndPerish(inst)

    return inst
end 

return Prefab("gw_mojing", fn, assets),
Prefab("gw_mojing_fx", CreateFX, assets)