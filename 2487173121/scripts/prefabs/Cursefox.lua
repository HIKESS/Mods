local assets =
{
    Asset("ANIM", "anim/Cursefox.zip"),
    Asset("ANIM", "anim/swap_Cursefox.zip"),
    Asset("ATLAS", "images/inventoryimages/Cursefox.xml"),
    Asset("IMAGE", "images/inventoryimages/Cursefox.tex"),
}
local prefabs =
{
    "shadowtentacle",
    "shadow_despawn",
    "shadowstrike_slash_fx",
    "groundpound_fx",
    "statue_transition_2",
}
local ShakeAllCameras = ShakeAllCameras
local CAMERASHAKE = CAMERASHAKE
local DAMAGE = 72
local LIFESTEAL = 8
local TENTACLE_CHANCE = 0.25
local SPEED_MULT = 0.90
local MAX_USES = 400
local LEAP_RANGE = 8
local LEAP_COOLDOWN = 30
local LEAP_DAMAGE = 150
local LEAP_RADIUS = 4
local LEAP_USE_COST = 10
local function NoHoles(pt)
    return not TheWorld.Map:IsPointNearHole(pt)
end
local function UpdateStats(inst)
    inst.components.weapon:SetDamage(DAMAGE)
    inst.components.equippable.walkspeedmult = SPEED_MULT
    if inst.components.aoetargeting then
        local is_charged = inst.components.rechargeable == nil or
                          inst.components.rechargeable:IsCharged()
        inst.components.aoetargeting:SetEnabled(is_charged)
    end
    if inst.components.aoeweapon_leap then
        inst.components.aoeweapon_leap:SetDamage(LEAP_DAMAGE)
    end
end
local function OnAttack(inst, owner, target)
    if not target or not target:IsValid() then return end
    if not owner or not owner:IsValid() then return end
    if owner.components.health and owner.components.health:GetPercent() < 1 and not target:HasTag("wall") then
        owner.components.health:DoDelta(LIFESTEAL)
    end
    if math.random() < TENTACLE_CHANCE then
        local pt = target:IsValid() and target:GetPosition() or owner:GetPosition()
        local offset = FindWalkableOffset(pt, math.random() * 2 * PI, 2, 3, false, true, NoHoles)
        if offset then
            inst.SoundEmitter:PlaySound("dontstarve/common/shadowTentacleAttack_1")
            inst.SoundEmitter:PlaySound("dontstarve/common/shadowTentacleAttack_2")
            local tentacle = SpawnPrefab("shadowtentacle")
            if tentacle then
                tentacle.Transform:SetPosition(pt.x + offset.x, 0, pt.z + offset.z)
                tentacle.components.combat:SetTarget(target)
            end
        end
    end
end
local function OnLeapt(inst, doer, startingpos, targetpos)
    if inst.components.finiteuses then
        inst.components.finiteuses:Use(LEAP_USE_COST)
    end
    local x, y, z = targetpos.x, 0, targetpos.z
    local shadow_fx = SpawnPrefab("shadow_despawn")
    if shadow_fx then
        shadow_fx.Transform:SetPosition(x, y, z)
        shadow_fx.Transform:SetScale(2, 2, 2)
    end
    local ring_fx = SpawnPrefab("shadowstrike_slash_fx")
    if ring_fx then
        ring_fx.Transform:SetPosition(x, y, z)
    end
    local ground_fx = SpawnPrefab("groundpound_fx")
    if ground_fx then
        ground_fx.Transform:SetPosition(x, y, z)
    end
    local num_particles = 8
    for i = 1, num_particles do
        local angle = (i / num_particles) * 2 * PI
        local dist = 1.5
        local px = x + math.cos(angle) * dist
        local pz = z + math.sin(angle) * dist
        local particle = SpawnPrefab("statue_transition_2")
        if particle then
            particle.Transform:SetPosition(px, y, pz)
        end
    end
    for i = 1, 6 do
        doer:DoTaskInTime(i * 0.05, function()
            if doer:IsValid() then
                local wave_angle = math.random() * 2 * PI
                local wave_dist = i * 0.8
                local wx = x + math.cos(wave_angle) * wave_dist
                local wz = z + math.sin(wave_angle) * wave_dist
                if TheWorld.Map:IsPassableAtPoint(wx, 0, wz) then
                    local wave_fx = SpawnPrefab("shadow_despawn")
                    if wave_fx then
                        wave_fx.Transform:SetPosition(wx, 0, wz)
                        wave_fx.Transform:SetScale(0.8, 0.8, 0.8)
                    end
                end
            end
        end)
    end
    doer.SoundEmitter:PlaySound("dontstarve/common/shadowTentacleAttack_1")
    doer.SoundEmitter:PlaySound("dontstarve/common/shadowTentacleAttack_2")
    doer.SoundEmitter:PlaySound("dontstarve/creatures/together/shadow_knight/attack")
    doer.SoundEmitter:PlaySound("dontstarve/common/deathpoof")
    ShakeAllCameras(CAMERASHAKE.VERTICAL, 0.7, 0.03, 1, doer, 30)
    local num_tentacles = TUNING.CURSEFOX and TUNING.CURSEFOX.LEAP_TENTACLES or 4
    for i = 1, num_tentacles do
        doer:DoTaskInTime(0.1 + i * 0.08, function()
            if not doer:IsValid() then return end
            local angle = (i / num_tentacles) * 2 * PI + math.random() * 0.3
            local offset_x = math.cos(angle) * 2.5
            local offset_z = math.sin(angle) * 2.5
            local tent_pos = Vector3(x + offset_x, 0, z + offset_z)
            if TheWorld.Map:IsPassableAtPoint(tent_pos:Get()) then
                local pre_fx = SpawnPrefab("shadow_despawn")
                if pre_fx then
                    pre_fx.Transform:SetPosition(tent_pos:Get())
                    pre_fx.Transform:SetScale(0.6, 0.6, 0.6)
                end
                local tentacle = SpawnPrefab("shadowtentacle")
                if tentacle then
                    tentacle.Transform:SetPosition(tent_pos:Get())
                    local ents = TheSim:FindEntities(x, 0, z, 8, {"_combat"}, {"player", "companion", "wall", "INLIMBO", "shadow"})
                    if #ents > 0 then
                        tentacle.components.combat:SetTarget(ents[math.random(#ents)])
                    end
                end
            end
        end)
    end
    if inst.components.rechargeable then
        inst.components.rechargeable:Discharge(LEAP_COOLDOWN)
    end
end
local function SpellFn(inst, doer, pos)
    if inst.components.rechargeable and not inst.components.rechargeable:IsCharged() then
        if doer and doer.components.talker then
            doer.components.talker:Say("*Recharging...*", 1, true)
        end
        return false, "RECHARGING"
    end
    if inst.components.aoetargeting and not inst.components.aoetargeting.enabled then
        return false, "NOT_READY"
    end
    doer:PushEvent("combat_superjump", {
        targetpos = pos,
        weapon = inst,
    })
    return true
end
local function OnDischarged(inst)
    if inst.components.aoetargeting then
        inst.components.aoetargeting:SetEnabled(false)
    end
end
local function OnCharged(inst)
    local owner = inst.components.inventoryitem and inst.components.inventoryitem.owner
    local is_equipped = owner and owner.components.inventory and
                      owner.components.inventory:GetEquippedItem(EQUIPSLOTS.HANDS) == inst
    if is_equipped and inst.components.aoetargeting then
        inst.components.aoetargeting:SetEnabled(true)
    end
    if owner and owner.components.talker then
        owner.components.talker:Say("*Shadow Leap ready*", 1.5, true)
    end
end
local function ReticuleTargetFn()
    local player = ThePlayer
    if not player or not player.entity then
        return Vector3(0, 0, 0)
    end
    local ground = TheWorld.Map
    local pos = Vector3()
    for r = LEAP_RANGE, 0, -0.25 do
        pos.x, pos.y, pos.z = player.entity:LocalToWorldSpace(r, 0, 0)
        if ground:IsPassableAtPoint(pos:Get()) and not ground:IsGroundTargetBlocked(pos) then
            return pos
        end
    end
    return pos
end
local function OnEquip(inst, owner)
    owner.AnimState:OverrideSymbol("swap_object", "swap_Cursefox", "swap_Cursefox")
    owner.AnimState:Show("ARM_carry")
    owner.AnimState:Hide("ARM_normal")
    if not inst.share_item and owner and not owner:HasTag("kodi") and owner.components.inventory then
        owner.components.inventory:Unequip(EQUIPSLOTS.HANDS, true)
        owner:DoTaskInTime(0.1, function()
            owner.components.inventory:DropItem(inst)
            if TUNING.KODI_LANGUAGE == "ENGLISH" then
                owner.components.talker:Say("It looks like some kind of magical power is preventing me from using this...")
            else
                owner.components.talker:Say("Схоже, що якась магічна сила забороняє мені цим користуватися...")
            end
        end)
        return
    end
    UpdateStats(inst)
    if inst.components.aoetargeting and inst.components.rechargeable then
        local is_charged = inst.components.rechargeable:IsCharged()
        inst.components.aoetargeting:SetEnabled(is_charged)
    end
end
local function OnUnequip(inst, owner)
    owner.AnimState:Hide("ARM_carry")
    owner.AnimState:Show("ARM_normal")
end
local function OnSave(inst, data)
end
local function OnLoad(inst, data)
    UpdateStats(inst)
    if inst.components.aoetargeting then
        inst.components.aoetargeting:SetEnabled(false)
    end
end
local function GetStatus(inst)
    local uses_percent = inst.components.finiteuses and inst.components.finiteuses:GetPercent() or 1
    if uses_percent < 0.25 then
        return "BROKEN"
    elseif uses_percent < 0.5 then
        return "WEAK"
    end
    return nil
end
local function GetDescription(inst, viewer)
    local lines = {}
    table.insert(lines, "=== CURSEFOX ===")
    table.insert(lines, "Damage: " .. DAMAGE)
    table.insert(lines, "Lifesteal: " .. LIFESTEAL .. " HP")
    table.insert(lines, "Tentacle: " .. math.floor(TENTACLE_CHANCE * 100) .. "%")
    table.insert(lines, "Speed: " .. math.floor(SPEED_MULT * 100) .. "%")
    local is_charged = inst.components.rechargeable == nil or
                      inst.components.rechargeable:IsCharged()
    if is_charged then
        table.insert(lines, "Shadow Leap: READY")
    else
        local remaining = inst.components.rechargeable and
                         math.ceil(inst.components.rechargeable:GetTimeToCharge()) or 0
        table.insert(lines, "Shadow Leap: " .. remaining .. "s")
    end
    if inst.components.finiteuses then
        local percent = math.floor(inst.components.finiteuses:GetPercent() * 100)
        table.insert(lines, "Durability: " .. percent .. "%")
    end
    return table.concat(lines, "\n")
end
local function fn()
    local inst = CreateEntity()
    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()
    inst.entity:AddNetwork()
    MakeInventoryPhysics(inst)
    inst.entity:AddMiniMapEntity()
    inst.MiniMapEntity:SetIcon("Cursefox.tex")
    inst.AnimState:SetBank("Cursefox")
    inst.AnimState:SetBuild("Cursefox")
    inst.AnimState:PlayAnimation("idle")
    local swap_data = {sym_build = "swap_Cursefox"}
    MakeInventoryFloatable(inst, "med", 0.05, {0.85, 0.45, 0.85}, true, 1, swap_data)
    inst:AddTag("sharp")
    inst:AddTag("shadow_item")
    inst:AddTag("weapon")
    inst:AddTag("aoeweapon_leap")
    inst:AddTag("superjump")
    inst:AddTag("rechargeable")
    inst:AddTag("allow_action_on_impassable")
    inst:AddComponent("aoetargeting")
    inst.components.aoetargeting:SetRange(LEAP_RANGE)
    inst.components.aoetargeting:SetAllowRiding(false)
    inst.components.aoetargeting.reticule.reticuleprefab = "reticuleaoe"
    inst.components.aoetargeting.reticule.pingprefab = "reticuleaoeping"
    inst.components.aoetargeting.reticule.targetfn = ReticuleTargetFn
    inst.components.aoetargeting.reticule.validcolour = { 0.3, 0, 0.5, 1 }
    inst.components.aoetargeting.reticule.invalidcolour = { 0.5, 0, 0, 1 }
    inst.components.aoetargeting.reticule.ease = true
    inst.components.aoetargeting.reticule.mouseenabled = true
    inst.components.aoetargeting:SetEnabled(false)
    inst.entity:SetPristine()
    if not TheWorld.ismastersim then
        return inst
    end
    inst:AddComponent("weapon")
    inst.components.weapon:SetDamage(DAMAGE)
    inst.components.weapon:SetOnAttack(OnAttack)
    inst:AddComponent("inspectable")
    inst.components.inspectable.getstatus = GetStatus
    inst.components.inspectable.getspecialdescription = GetDescription
    inst:AddComponent("finiteuses")
    inst.components.finiteuses:SetMaxUses(MAX_USES)
    inst.components.finiteuses:SetUses(MAX_USES)
    inst.components.finiteuses:SetConsumption(ACTIONS.ATTACK, 1)
    inst:AddComponent("inventoryitem")
    inst.components.inventoryitem.imagename = "Cursefox"
    inst.components.inventoryitem.atlasname = "images/inventoryimages/Cursefox.xml"
    inst:AddComponent("equippable")
    inst.components.equippable:SetOnEquip(OnEquip)
    inst.components.equippable:SetOnUnequip(OnUnequip)
    inst.components.equippable.walkspeedmult = SPEED_MULT
    inst.components.equippable.dapperness = TUNING.CRAZINESS_MED
    local AOEWeapon_Leap = require("components/aoeweapon_leap")
    inst:AddComponent("aoeweapon_leap")
    inst.components.aoeweapon_leap:SetDamage(LEAP_DAMAGE)
    inst.components.aoeweapon_leap:SetAOERadius(LEAP_RADIUS)
    inst.components.aoeweapon_leap:SetOnLeaptFn(OnLeapt)
    inst.components.aoeweapon_leap:SetNoTags("player", "companion", "wall", "INLIMBO")
    inst:AddComponent("aoespell")
    inst.components.aoespell:SetSpellFn(SpellFn)
    inst:AddComponent("rechargeable")
    inst.components.rechargeable:SetOnDischargedFn(OnDischarged)
    inst.components.rechargeable:SetOnChargedFn(OnCharged)
    for _, delay in ipairs({0.1, 0.5, 1, 2}) do
        inst:DoTaskInTime(delay, function()
            if inst:IsValid() and inst.components.rechargeable and inst.components.aoetargeting then
                local is_charged = inst.components.rechargeable:IsCharged()
                inst.components.aoetargeting:SetEnabled(is_charged)
            end
        end)
    end
    MakeHauntableLaunch(inst)
    inst.OnSave = OnSave
    inst.OnLoad = OnLoad
    inst:ListenForEvent("superjumpstarted", function(inst, doer)
        if doer and doer:IsValid() then
            local x, y, z = doer.Transform:GetWorldPosition()
            local fx = SpawnPrefab("shadow_despawn")
            if fx then
                fx.Transform:SetPosition(x, y, z)
                fx.Transform:SetScale(1.5, 1.5, 1.5)
            end
            local ground = SpawnPrefab("groundpound_fx")
            if ground then
                ground.Transform:SetPosition(x, y, z)
                ground.Transform:SetScale(0.7, 0.7, 0.7)
            end
            doer.SoundEmitter:PlaySound("dontstarve/common/shadowTentacleAttack_1")
            ShakeAllCameras(CAMERASHAKE.VERTICAL, 0.3, 0.02, 0.3, doer, 15)
        end
    end)
    return inst
end
return Prefab("cursefox", fn, assets, prefabs)
