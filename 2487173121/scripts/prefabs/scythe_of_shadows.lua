local assets =
{
    Asset("ANIM", "anim/scythe_of_shadows.zip"),
    Asset("ANIM", "anim/swap_scythe_of_shadows.zip"),
    Asset("ATLAS", "images/inventoryimages/scythe_of_shadows.xml"),
    Asset("IMAGE", "images/inventoryimages/scythe_of_shadows.tex"),
}
local prefabs =
{
    "shadow_despawn",
    "shadowstrike_slash_fx",
    "statue_transition_2",
    "groundpoundring_fx",
}
local DAMAGE = 68
local SPEED_MULT = 1.0
local DAPPERNESS = -20/60
local MAX_USES = 350
local DASH_USE_COST = 5
local DASH_RANGE = 10
local DASH_DISTANCE = 10
local SWEEP_RADIUS = 3
local DASH_DAMAGE_MULT = 1.5
local DASH_COOLDOWN = 8
local function OnPreLunge(inst, doer, startpos, targetpos)
    if doer and doer.SoundEmitter then
        doer.SoundEmitter:PlaySound("dontstarve/common/shadowTentacleAttack_1")
        doer.SoundEmitter:PlaySound("dontstarve/sanity/creature1/taunt")
    end
    if startpos then
        local x, y, z = startpos:Get()
        for i = 1, 3 do
            local fx = SpawnPrefab("shadow_despawn")
            if fx then
                fx.Transform:SetPosition(x, y, z)
                fx.Transform:SetScale(1.2 + i * 0.3, 1.2 + i * 0.3, 1.2 + i * 0.3)
            end
        end
        local ground_fx = SpawnPrefab("groundpound_fx")
        if ground_fx then
            ground_fx.Transform:SetPosition(x, y, z)
            ground_fx.Transform:SetScale(0.8, 0.8, 0.8)
        end
        local ring = SpawnPrefab("statue_transition_2")
        if ring then
            ring.Transform:SetPosition(x, y, z)
            ring.Transform:SetScale(1.2, 1.2, 1.2)
        end
    end
end
local HARVEST_NOTAGS = {"FX", "DECOR", "INLIMBO", "player", "wall"}
local function OnLunged(inst, doer, startingpos, targetpos)
    if inst.components.finiteuses then
        inst.components.finiteuses:Use(DASH_USE_COST)
    end
    if startingpos and targetpos then
        local sx, sy, sz = startingpos:Get()
        local tx, ty, tz = targetpos:Get()
        for i = 0, 10 do
            local progress = i / 10
            local px = sx + (tx - sx) * progress
            local pz = sz + (tz - sz) * progress
            inst:DoTaskInTime(i * 0.03, function()
                local trail = SpawnPrefab("shadow_despawn")
                if trail then
                    trail.Transform:SetPosition(px, 0, pz)
                    trail.Transform:SetScale(0.6, 0.6, 0.6)
                end
                local mist = SpawnPrefab("statue_transition_2")
                if mist then
                    mist.Transform:SetPosition(px, 0, pz)
                    mist.Transform:SetScale(0.5, 0.5, 0.5)
                end
            end)
        end
        if TheWorld.ismastersim and doer and doer:IsValid() then
            local dx, dz = tx - sx, tz - sz
            local path_len = math.sqrt(dx * dx + dz * dz)
            if path_len > 0 then
                local steps = math.max(1, math.floor(path_len / 2))
                local harvested = {}
                for i = 0, steps do
                    local t = i / steps
                    local px = sx + dx * t
                    local pz = sz + dz * t
                    local ents = TheSim:FindEntities(px, 0, pz, SWEEP_RADIUS, nil, HARVEST_NOTAGS)
                    for _, ent in ipairs(ents) do
                        if not harvested[ent] and ent:IsValid() and not ent:IsInLimbo() then
                            local did_harvest = false
                            if ent.components.pickable and ent.components.pickable:CanBePicked() then
                                local product = ent.components.pickable.product
                                local num = ent.components.pickable.numtoharvest or 1
                                local ex, _, ez = ent.Transform:GetWorldPosition()
                                if product then
                                    for j = 1, num do
                                        local loot = SpawnPrefab(product)
                                        if loot then
                                            loot.Transform:SetPosition(
                                                ex + (math.random() - 0.5) * 0.8,
                                                0,
                                                ez + (math.random() - 0.5) * 0.8
                                            )
                                            if loot.components.inventoryitem then
                                                loot.components.inventoryitem:OnDropped(true)
                                            end
                                        end
                                    end
                                end
                                local saved_product = ent.components.pickable.product
                                ent.components.pickable.product = nil
                                ent.components.pickable:Pick(doer)
                                ent.components.pickable.product = saved_product
                                did_harvest = true
                            end
                            if not did_harvest and ent.components.workable and ent.components.workable:CanBeWorked() then
                                local work_action = ent.components.workable:GetWorkAction()
                                if work_action == ACTIONS.PICK or work_action == ACTIONS.HARVEST then
                                    ent.components.workable:Destroy(doer)
                                    did_harvest = true
                                end
                            end
                            if did_harvest then
                                harvested[ent] = true
                                local ex, _, ez = ent.Transform:GetWorldPosition()
                                local fx = SpawnPrefab("shadow_despawn")
                                if fx then
                                    fx.Transform:SetPosition(ex, 0, ez)
                                    fx.Transform:SetScale(0.5, 0.5, 0.5)
                                end
                            end
                        end
                    end
                end
            end
        end
    end
    if targetpos then
        inst:DoTaskInTime(0.4, function()
            if not doer:IsValid() then return end
            local x, y, z = targetpos:Get()
            local ring = SpawnPrefab("groundpoundring_fx")
            if ring then
                ring.Transform:SetPosition(x, y, z)
                ring.Transform:SetScale(1.0, 1.0, 1.0)
            end
            for i = 1, 4 do
                local angle = (i / 4) * 2 * PI
                local dist = 1.5
                local fx = SpawnPrefab("shadow_despawn")
                if fx then
                    fx.Transform:SetPosition(x + math.cos(angle) * dist, y, z + math.sin(angle) * dist)
                    fx.Transform:SetScale(1.0, 1.0, 1.0)
                end
            end
            if doer.SoundEmitter then
                doer.SoundEmitter:PlaySound("dontstarve/common/destroy_wood")
                doer.SoundEmitter:PlaySound("dontstarve/maxwell/shadowmax_despawn")
            end
        end)
    end
end
local function OnLungedHit(inst, doer, target)
    if not target then return end
    if target.components.pickable and target.components.pickable:CanBePicked() then
        target.components.pickable:Pick(doer)
    end
    if target.components.workable and target.components.workable:CanBeWorked() then
        local work_action = target.components.workable:GetWorkAction()
        if work_action == ACTIONS.PICK or work_action == ACTIONS.HARVEST or
           (work_action == ACTIONS.DIG and (target:HasTag("stump") or target:HasTag("grave"))) then
            target.components.workable:Destroy(doer)
        end
    end
    local x, y, z = target.Transform:GetWorldPosition()
    if target.components.combat then
        local slash = SpawnPrefab("shadowstrike_slash_fx")
        if slash then
            slash.Transform:SetPosition(x, y, z)
        end
        local puff = SpawnPrefab("shadow_despawn")
        if puff then
            puff.Transform:SetPosition(x, y, z)
            puff.Transform:SetScale(0.8, 0.8, 0.8)
        end
        if doer and doer.SoundEmitter then
            doer.SoundEmitter:PlaySound("dontstarve/common/shadowTentacleAttack_2")
        end
    else
        local fx = SpawnPrefab("shadow_despawn")
        if fx then
            fx.Transform:SetPosition(x, y, z)
            fx.Transform:SetScale(0.5, 0.5, 0.5)
        end
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
    doer:PushEvent("combat_lunge", { targetpos = pos, weapon = inst })
    if inst.components.rechargeable then
        inst.components.rechargeable:Discharge(DASH_COOLDOWN)
    end
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
        owner.components.talker:Say("*Reap ready*", 1.5, true)
    end
end
local function ReticuleTargetFn()
    local player = ThePlayer
    if not player or not player.entity then
        return Vector3(0, 0, 0)
    end
    return Vector3(player.entity:LocalToWorldSpace(DASH_DISTANCE, 0, 0))
end
local function ReticuleMouseTargetFn(inst, mousepos)
    if mousepos ~= nil then
        local x, y, z = inst.Transform:GetWorldPosition()
        local dx = mousepos.x - x
        local dz = mousepos.z - z
        local l = dx * dx + dz * dz
        if l <= 0 then
            return inst.components.reticule.targetpos
        end
        l = DASH_DISTANCE / math.sqrt(l)
        return Vector3(x + dx * l, 0, z + dz * l)
    end
end
local function ReticuleUpdatePositionFn(inst, pos, reticule, ease, smoothing, dt)
    local x, y, z = inst.Transform:GetWorldPosition()
    reticule.Transform:SetPosition(x, 0, z)
    local rot = -math.atan2(pos.z - z, pos.x - x) / DEGREES
    if ease and dt ~= nil then
        local rot0 = reticule.Transform:GetRotation()
        local drot = rot - rot0
        rot = Lerp((drot > 180 and rot0 + 360) or (drot < -180 and rot0 - 360) or rot0, rot, dt * smoothing)
    end
    reticule.Transform:SetRotation(rot)
end
local function OnEquip(inst, owner)
    owner.AnimState:OverrideSymbol("swap_object", "swap_scythe_of_shadows", "swap_scythe_of_shadows")
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
    if inst.components.aoetargeting and inst.components.rechargeable then
        local is_charged = inst.components.rechargeable:IsCharged()
        inst.components.aoetargeting:SetEnabled(is_charged)
    end
end
local function OnUnequip(inst, owner)
    owner.AnimState:Hide("ARM_carry")
    owner.AnimState:Show("ARM_normal")
end
local function GetStatus(inst)
    local uses_percent = inst.components.finiteuses and inst.components.finiteuses:GetPercent() or 1
    if uses_percent < 0.25 then
        return "BROKEN"
    elseif uses_percent < 0.5 then
        return "DULL"
    end
    return nil
end
local function GetDescription(inst, viewer)
    local lines = {}
    table.insert(lines, "=== SCYTHE OF SHADOWS ===")
    table.insert(lines, "Damage: " .. DAMAGE)
    table.insert(lines, "Reap Dash: " .. math.floor(DAMAGE * DASH_DAMAGE_MULT) .. " sweep")
    table.insert(lines, "Range: " .. DASH_DISTANCE .. " tiles")
    local is_charged = inst.components.rechargeable == nil or
                      inst.components.rechargeable:IsCharged()
    if is_charged then
        table.insert(lines, "Reap: READY")
    else
        local remaining = inst.components.rechargeable and
                         math.ceil(inst.components.rechargeable:GetTimeToCharge()) or 0
        table.insert(lines, "Reap: " .. remaining .. "s")
    end
    if inst.components.finiteuses then
        local percent = math.floor(inst.components.finiteuses:GetPercent() * 100)
        table.insert(lines, "Durability: " .. percent .. "%")
    end
    table.insert(lines, "Harvests during dash")
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
    inst.MiniMapEntity:SetIcon("scythe_of_shadows.tex")
    inst.AnimState:SetBank("scythe_of_shadows")
    inst.AnimState:SetBuild("scythe_of_shadows")
    inst.AnimState:PlayAnimation("idle")
    local swap_data = {sym_build = "swap_scythe_of_shadows"}
    MakeInventoryFloatable(inst, "med", 0.05, {0.6, 0.3, 0.8}, true, 1, swap_data)
    inst:AddTag("sharp")
    inst:AddTag("shadow_item")
    inst:AddTag("weapon")
    inst:AddTag("rechargeable")
    inst:AddTag("aoeweapon_lunge")
    inst:AddTag("allow_action_on_impassable")
    inst:AddComponent("aoetargeting")
    inst.components.aoetargeting:SetRange(DASH_RANGE + 2)
    inst.components.aoetargeting:SetAllowRiding(false)
    inst.components.aoetargeting.reticule.reticuleprefab = "reticulelong"
    inst.components.aoetargeting.reticule.pingprefab = "reticulelongping"
    inst.components.aoetargeting.reticule.targetfn = ReticuleTargetFn
    inst.components.aoetargeting.reticule.mousetargetfn = ReticuleMouseTargetFn
    inst.components.aoetargeting.reticule.updatepositionfn = ReticuleUpdatePositionFn
    inst.components.aoetargeting.reticule.validcolour = { 0.4, 0.2, 0.6, 1 }
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
    inst:AddComponent("inspectable")
    inst.components.inspectable.getstatus = GetStatus
    inst.components.inspectable.getspecialdescription = GetDescription
    inst:AddComponent("finiteuses")
    inst.components.finiteuses:SetMaxUses(MAX_USES)
    inst.components.finiteuses:SetUses(MAX_USES)
    inst.components.finiteuses:SetConsumption(ACTIONS.ATTACK, 1)
    inst:AddComponent("inventoryitem")
    inst.components.inventoryitem.imagename = "scythe_of_shadows"
    inst.components.inventoryitem.atlasname = "images/inventoryimages/scythe_of_shadows.xml"
    inst:AddComponent("equippable")
    inst.components.equippable:SetOnEquip(OnEquip)
    inst.components.equippable:SetOnUnequip(OnUnequip)
    inst.components.equippable.walkspeedmult = SPEED_MULT
    inst.components.equippable.dapperness = DAPPERNESS
    inst:AddComponent("aoeweapon_lunge")
    inst.components.aoeweapon_lunge:SetDamage(DAMAGE * DASH_DAMAGE_MULT)
    inst.components.aoeweapon_lunge:SetSound("dontstarve/common/lava_arena/sfx/scythe")
    inst.components.aoeweapon_lunge:SetSideRange(1.5)
    inst.components.aoeweapon_lunge:SetOnLungedFn(OnLunged)
    inst.components.aoeweapon_lunge:SetOnHitFn(OnLungedHit)
    inst.components.aoeweapon_lunge:SetWorkActions()
    inst.components.aoeweapon_lunge:SetTags("_combat")
    inst.components.aoeweapon_lunge.onprelungefn = OnPreLunge
    inst:AddComponent("aoespell")
    inst.components.aoespell:SetSpellFn(SpellFn)
    inst:AddComponent("rechargeable")
    inst.components.rechargeable:SetOnDischargedFn(OnDischarged)
    inst.components.rechargeable:SetOnChargedFn(OnCharged)
    MakeHauntableLaunch(inst)
    inst.OnLoad = function(inst, data)
        if inst.components.aoetargeting then
            inst.components.aoetargeting:SetEnabled(false)
        end
    end
    return inst
end
return Prefab("scythe_of_shadows", fn, assets, prefabs)
