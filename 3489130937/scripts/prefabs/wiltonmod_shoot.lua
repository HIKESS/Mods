local assets =
{
    Asset("ANIM", "anim/wiltonmod_shoot_idle.zip"),
    Asset("ANIM", "anim/completelyregularattack.zip"),
    Asset("ANIM", "anim/swap_completelyregularattack.zip"),

    Asset("ANIM", "anim/wiltonmod_shoot_skin.zip"),    
    Asset("ANIM", "anim/swap_wiltonmod_shoot_skin.zip"),

	Asset("ATLAS", "images/inventoryimages/wiltonmod_shoot.xml"),
	Asset("IMAGE", "images/inventoryimages/wiltonmod_shoot.tex"),

    Asset("ATLAS", "images/inventoryimages/wiltonmod_shoot_skin.xml"),
}

local function OnFinished(inst)
    inst.AnimState:PlayAnimation("used")
    inst:ListenForEvent("animover", inst.Remove)
end

local function OnEquip(inst, owner) 
    owner.AnimState:OverrideSymbol("swap_object", "swap_completelyregularattack", "swap_boomerang")
    owner.AnimState:Show("ARM_carry") 
    owner.AnimState:Hide("ARM_normal") 
end

local function OnDropped(inst)
    inst.AnimState:PlayAnimation("idle")
end

local function OnUnequip(inst, owner)
    owner.AnimState:Hide("ARM_carry")
    owner.AnimState:Show("ARM_normal")
end

local function OnThrown(inst, owner, target)
    inst.AnimState:SetBank("boomerang")
    inst.AnimState:SetBuild("completelyregularattack")

    if target ~= owner then
        inst.SoundEmitter:PlaySound("dontstarve/wilson/boomerang_throw")
    end
    inst.AnimState:PlayAnimation("spin_loop", true)
    inst.components.inventoryitem.pushlandedevents = false
end

local function OnHit(inst, owner, target)
    if target ~= nil and target:IsValid() then
        local impactfx = SpawnPrefab("impact")
        if impactfx ~= nil then
            local follower = impactfx.entity:AddFollower()
            follower:FollowSymbol(target.GUID, target.components.combat.hiteffectsymbol, 0, 0, 0)
            impactfx:FacePoint(inst.Transform:GetWorldPosition())
        end
    end

    inst.AnimState:PlayAnimation("used")
    inst:ListenForEvent("animover", inst.Remove)

    --inst:Remove()
end

local function fn()
    local inst = CreateEntity()
    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()    
    inst.entity:AddNetwork()

    MakeInventoryPhysics(inst)
    RemovePhysicsColliders(inst)
    inst.AnimState:SetBank("wiltonmod_shoot_idle")
    inst.AnimState:SetBuild("wiltonmod_shoot_idle")
    inst.AnimState:PlayAnimation("idle")
    inst.AnimState:SetRayTestOnBB(true)

    inst:AddTag("thrown")
    inst:AddTag("projectile")
    inst:AddTag("wiltonmod_item")

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst:AddComponent("weapon")
    -- 从 TUNING 读取可配置的投掷骨攻击力，默认 34。
    inst.components.weapon:SetDamage(TUNING.WILTON_SHOOT_DAMAGE or 34)
    inst.components.weapon:SetRange(TUNING.BOOMERANG_DISTANCE, TUNING.BOOMERANG_DISTANCE+2)

    inst:AddComponent("inspectable")

    inst:AddComponent("projectile")
    inst.components.projectile:SetSpeed(20)
    inst.components.projectile:SetOnHitFn(OnHit)
    inst:ListenForEvent("onthrown", OnThrown)

    inst:AddComponent("inventoryitem")
    inst.components.inventoryitem.imagename = "wiltonmod_shoot" 
    inst.components.inventoryitem.atlasname = "images/inventoryimages/wiltonmod_shoot.xml"
    inst.components.inventoryitem:SetOnDroppedFn(OnDropped)

    inst:AddComponent("stackable")
    inst.components.stackable.maxsize = TUNING.STACK_SIZE_SMALLITEM

    inst:AddComponent("equippable")
    inst.components.equippable:SetOnEquip(OnEquip)
    inst.components.equippable:SetOnUnequip(OnUnequip)
    inst.components.equippable.equipstack = true

    MakeHauntableLaunch(inst)

    return inst
end

local function OnEquip(inst, owner) 
    owner.AnimState:OverrideSymbol("swap_object", "swap_wiltonmod_shoot_skin", "swap_wiltonmod_shoot_skin")
    owner.AnimState:Show("ARM_carry") 
    owner.AnimState:Hide("ARM_normal") 
end

local function OnDropped(inst)
    inst.AnimState:PlayAnimation("idle")
end

local function OnUnequip(inst, owner)
    owner.AnimState:Hide("ARM_carry")
    owner.AnimState:Show("ARM_normal")
end

local function OnThrown(inst, owner, target)
    if target ~= owner then
        inst.SoundEmitter:PlaySound("dontstarve/wilson/boomerang_throw")
    end
    inst.AnimState:PlayAnimation("spin_loop", true)
    inst.components.inventoryitem.pushlandedevents = false
end

local function OnHit(inst, owner, target)
    if target ~= nil and target:IsValid() then
        local impactfx = SpawnPrefab("impact")
        if impactfx ~= nil then
            local follower = impactfx.entity:AddFollower()
            follower:FollowSymbol(target.GUID, target.components.combat.hiteffectsymbol, 0, 0, 0)
            impactfx:FacePoint(inst.Transform:GetWorldPosition())
        end
    end

    inst.AnimState:SetBank("boomerang")
    inst.AnimState:SetBuild("completelyregularattack")

    inst.AnimState:PlayAnimation("used")
    inst:ListenForEvent("animover", inst.Remove)
end

local function skin()
    local inst = CreateEntity()
    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()    
    inst.entity:AddNetwork()

    MakeInventoryPhysics(inst)
    RemovePhysicsColliders(inst)
    inst.AnimState:SetBank("wiltonmod_shoot_skin")
    inst.AnimState:SetBuild("wiltonmod_shoot_skin")
    inst.AnimState:PlayAnimation("idle")
    inst.AnimState:SetRayTestOnBB(true)

    inst:AddTag("thrown")
    inst:AddTag("projectile")

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst:AddComponent("weapon")
    -- 皮肤版投掷骨同样使用可配置的攻击力，保持与本体数值一致。
    inst.components.weapon:SetDamage(TUNING.WILTON_SHOOT_DAMAGE or 34)
    inst.components.weapon:SetRange(8)

    inst:AddComponent("inspectable")

    inst:AddComponent("projectile")
    inst.components.projectile:SetSpeed(20)
    inst.components.projectile:SetOnHitFn(OnHit)
    inst:ListenForEvent("onthrown", OnThrown)

    inst:AddComponent("inventoryitem")
    inst.components.inventoryitem.imagename = "wiltonmod_shoot_skin" 
    inst.components.inventoryitem.atlasname = "images/inventoryimages/wiltonmod_shoot_skin.xml"
    inst.components.inventoryitem:SetOnDroppedFn(OnDropped)

    inst:AddComponent("stackable")
    inst.components.stackable.maxsize = TUNING.STACK_SIZE_SMALLITEM

    inst:AddComponent("equippable")
    inst.components.equippable:SetOnEquip(OnEquip)
    inst.components.equippable:SetOnUnequip(OnUnequip)
    inst.components.equippable.equipstack = true

    MakeHauntableLaunch(inst)

    return inst
end

return Prefab("wiltonmod_shoot", fn, assets),
       Prefab("wiltonmod_shoot_skin", skin, assets)


