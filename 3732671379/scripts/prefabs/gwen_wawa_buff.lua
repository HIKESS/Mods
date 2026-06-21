
local DURATION = 5
local NEG_AURA_MOD = 0.5
local HEALTH_GAIN = 1
local SANITY_GAIN = 1

local function IsValidAttack(attacker, target, data)
    if not attacker or not attacker:IsValid() then
        return false
    end
    if not target or not target:IsValid() then
        return false
    end
    if attacker == target then
        return false
    end
    return true
end

-- 攻击时的回调函数
local function OnAttackOther(inst, target, data)
    local buff_holder = inst
    local owner = buff_holder.target 
    if not owner or not owner:IsValid() then
        return
    end
    local victim = data and data.target or target
    if not IsValidAttack(owner, victim, data) then
        return
    end

    if owner.components.health and not owner.components.health:IsDead() then
        owner.components.health:DoDelta(HEALTH_GAIN, nil, "gwen_wawa_buff_heal")
    end

    if owner.components.sanity then
        owner.components.sanity:DoDelta(SANITY_GAIN, nil, "gwen_wawa_buff_sanity")
    end
end

-----------------------------------------------------------
-- 生命周期

local function OnTargetDeath(inst)
    if inst and inst.components and inst.components.debuff then
        inst.components.debuff:Stop()
    end
end

local function ApplyCasterSkills(inst, target, caster)
    if not caster or not caster:IsValid() then
        return
    end

    -- 暗影技能
    if caster.components.skilltreeupdater and caster.components.skilltreeupdater:IsActivated("gwen_wawa_shadow") then
        if target.components.combat then
            target.components.combat.externaldamagemultipliers:SetModifier(inst, 1.2, "gwen_wawa_shadow_damage")
            inst._shadow_mod_applied = true
        end
    end

    -- 神圣技能
    if caster.components.skilltreeupdater and caster.components.skilltreeupdater:IsActivated("gwen_wawa_radiance") then
        if target.components.health then
            target.components.health.externalabsorbmodifiers:SetModifier(inst, 0.2)
            inst._radiance_mod_applied = true
        end
    end
end

local function RemoveCasterSkills(inst, target)
    if inst._shadow_mod_applied then
        if target.components.combat then
            target.components.combat.externaldamagemultipliers:RemoveModifier(inst, "gwen_wawa_shadow_damage")
        end
        inst._shadow_mod_applied = nil
    end

    if inst._radiance_mod_applied then
        if target.components.health then
            target.components.health.externalabsorbmodifiers:RemoveModifier(inst)
        end
        inst._radiance_mod_applied = nil
    end
end

local function gwen_wawa_buff_OnAttached(inst, target, followsymbol, followoffset, data)
    inst.entity:SetParent(target.entity)
    inst.Transform:SetPosition(0, 0, 0)
    inst.target = target

    if target.components.sanity then
        target.components.sanity.neg_aura_modifiers:SetModifier(inst, NEG_AURA_MOD)
    end

    if target.components.health and target.components.sanity then
        local on_attack_fn = function(_, data)
            OnAttackOther(inst, data and data.target, data)
        end
        inst:ListenForEvent("onattackother", on_attack_fn, target)
        inst._onattack_callback = on_attack_fn
    end


    if data and data.caster then
        ApplyCasterSkills(inst, target, data.caster)
    end

    local duration = DURATION
    if data and data.duration then
        duration = data.duration
    end
    inst.components.timer:StartTimer("buff_duration", duration)

    local death_fn = function() OnTargetDeath(inst) end
    inst:ListenForEvent("death", death_fn, target)
    inst._ondeath_callback = death_fn
end

local function gwen_wawa_buff_OnDetached(inst, target)
    if not target or not target:IsValid() then
        return
    end

    if target.components.sanity then
        target.components.sanity.neg_aura_modifiers:RemoveModifier(inst)
    end

    if inst._onattack_callback then
        target:RemoveEventCallback("onattackother", inst._onattack_callback)
        inst._onattack_callback = nil
    end

    if inst._ondeath_callback then
        target:RemoveEventCallback("death", inst._ondeath_callback)
        inst._ondeath_callback = nil
    end

    RemoveCasterSkills(inst, target)
end

local function gwen_wawa_buff_OnExtended(inst, target, followsymbol, followoffset, data)
    -- 刷新持续时间
    local duration = DURATION
    if data and data.duration then
        duration = data.duration
    end
    inst.components.timer:StopTimer("buff_duration")
    inst.components.timer:StartTimer("buff_duration", duration)
end

local function gwen_wawa_buff_OnTimerDone(inst, data)
    if data.name == "buff_duration" then
        inst.components.debuff:Stop()
    end
end

-----------------------------------------------------------
local function gwen_wawa_buff_fn()
    local inst = CreateEntity()

    if not TheWorld.ismastersim then
        inst:DoTaskInTime(0, inst.Remove)
        return inst
    end

    inst.entity:AddTransform()
    inst.entity:Hide()
    inst.persists = false

    inst:AddTag("CLASSIFIED")

    inst:AddComponent("debuff")
    inst.components.debuff:SetAttachedFn(gwen_wawa_buff_OnAttached)
    inst.components.debuff:SetDetachedFn(gwen_wawa_buff_OnDetached)
    inst.components.debuff:SetExtendedFn(gwen_wawa_buff_OnExtended)

    inst:AddComponent("timer")
    inst:ListenForEvent("timerdone", gwen_wawa_buff_OnTimerDone)

    return inst
end

return Prefab("gwen_wawa_buff", gwen_wawa_buff_fn)