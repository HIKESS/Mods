-- scripts/npc/characters/wurt_combat.lua
-- 敌对沃特专属战斗技能

local NPC_TUNING = require("npc_tuning")
local InvUtil    = require("npc/npc_inventory_util")

local M = {}

local function CombatDbg(inst, fmt, ...)
    if not (NPC_TUNING and NPC_TUNING.HOSTILE_WURT_DODGE_DEBUG) then return end
    local prefix = string.format("[WURT_COMBAT][%s]", tostring(inst and inst.GUID or 0))
    if select("#", ...) > 0 then
        print(prefix .. " " .. string.format(fmt, ...))
    else
        print(prefix .. " " .. tostring(fmt))
    end
end

local function IsValidLivingTarget(ent)
    return ent ~= nil and ent:IsValid()
        and not (ent.components and ent.components.health and ent.components.health:IsDead())
end

local function GetSpecialTarget(inst, attacker)
    local combat = inst.components and inst.components.combat or nil
    local target = combat and combat.target or nil
    if IsValidLivingTarget(target) then
        return target
    end
    if IsValidLivingTarget(attacker) then
        return attacker
    end
    return nil
end

local function EnsureWeaponEquipped(inst)
    local inv = inst.components and inst.components.inventory or nil
    if not inv then return end
    local best_weapon = InvUtil.FindBestWeapon(inst)
    if best_weapon ~= nil and best_weapon ~= inv:GetEquippedItem(EQUIPSLOTS.HANDS) then
        inv:Equip(best_weapon)
    end
end

M.EnsureWeaponEquipped = EnsureWeaponEquipped

local WATERBALLOON_FREEZE_COLDNESS = 60  -- 足够大，确保命中即冻（超过常见冰冻抗性）
local function ApplyFreezeAtHit(projinst, attacker)
    if not (TheWorld and TheWorld.ismastersim) then return end
    if not (projinst and projinst:IsValid()) then return end
    local px, py, pz = projinst.Transform:GetWorldPosition()
    local freezetime = NPC_TUNING.HOSTILE_WURT_WATERBALLOON_FREEZE_TIME or 4
    local radius = NPC_TUNING.HOSTILE_WURT_WATERBALLOON_FREEZE_RADIUS or 2.5
    local combat = attacker and attacker.components and attacker.components.combat or nil
    local ents = TheSim:FindEntities(px, py, pz, radius, { "freezable" }, { "INLIMBO", "playerghost", "FX", "DECOR" })
    for _, ent in ipairs(ents) do
        if ent ~= attacker and ent.components.freezable
            and not ent:HasTag("merm")
            and not (ent.components.health and ent.components.health:IsDead())
            and (combat == nil or combat:CanTarget(ent)) then
            ent.components.freezable:AddColdness(WATERBALLOON_FREEZE_COLDNESS, freezetime)
        end
    end
end

function M.LaunchWaterBalloon(inst, target)
    if not (inst and inst:IsValid()) or not IsValidLivingTarget(target) then return false end
    if not (TheWorld and TheWorld.ismastersim) then return false end

    local proj = SpawnPrefab("waterballoon")
    if not proj then return false end
    if not (proj.components and proj.components.complexprojectile) then
        proj:Remove()
        return false
    end

    local orig_onhit = proj.components.complexprojectile.onhitfn
    proj.components.complexprojectile:SetOnHit(function(projinst, atk, tgt)
        ApplyFreezeAtHit(projinst, atk)
        if orig_onhit ~= nil then
            orig_onhit(projinst, atk, tgt)
        end
    end)

    local x, y, z = inst.Transform:GetWorldPosition()
    proj.Transform:SetPosition(x, y, z)
    local tx, ty, tz = target.Transform:GetWorldPosition()
    proj.components.complexprojectile:Launch(Vector3(tx, ty, tz), inst, inst)

    CombatDbg(inst, "throw waterballoon at %s", tostring(target.prefab))
    return true
end

function M.DoWaterBalloon(inst, target)
    if not (inst and inst:IsValid()) or not IsValidLivingTarget(target) then return false end
    if not (TheWorld and TheWorld.ismastersim) then return false end

    if inst.sg ~= nil and inst.sg:HasState("wurt_throw_waterballoon")
        and not inst.sg:HasStateTag("busy") then
        inst.sg:GoToState("wurt_throw_waterballoon", target)
        return true
    end

    local ok = M.LaunchWaterBalloon(inst, target)
    EnsureWeaponEquipped(inst)
    return ok
end

function M.EquipTornadoStaff(inst)
    local inv = inst.components and inst.components.inventory or nil
    if not inv then return nil end
    local staff = InvUtil.FindItemByPrefab(inst, "staff_tornado")
    if not (staff and staff.components and staff.components.spellcaster) then return nil end
    if inv:GetEquippedItem(EQUIPSLOTS.HANDS) ~= staff then
        inv:Equip(staff)
    end
    return staff
end

function M.PerformTornadoCast(inst, target)
    if not (inst and inst:IsValid()) or not IsValidLivingTarget(target) then return false end
    local staff = M.EquipTornadoStaff(inst)
    if not staff then return false end

    staff.components.spellcaster:CastSpell(target, nil, inst)

    if staff.components.finiteuses then
        staff.components.finiteuses:SetPercent(1)
    end
    CombatDbg(inst, "cast tornado at %s", tostring(target.prefab))
    return true
end

function M.DoTornado(inst, target)
    if not (inst and inst:IsValid()) or not IsValidLivingTarget(target) then return false end
    local staff = InvUtil.FindItemByPrefab(inst, "staff_tornado")
    if not (staff and staff.components and staff.components.spellcaster) then return false end

    if inst.sg ~= nil and inst.sg:HasState("wurt_cast_tornado")
        and not inst.sg:HasStateTag("busy") then
        inst.sg:GoToState("wurt_cast_tornado", target)
        return true
    end

    M.PerformTornadoCast(inst, target)
    EnsureWeaponEquipped(inst)
    return true
end

local ACTION_FNS = {
    waterballoon = M.DoWaterBalloon,
    tornado      = M.DoTornado,
}

-- 按权重二选一释放特殊技能（传送后、或连续打空后均复用此入口）
function M.DoWeightedSpecial(inst, attacker_or_target)
    local target = GetSpecialTarget(inst, attacker_or_target)
    if target == nil then return false end

    local actions = NPC_TUNING.HOSTILE_WURT_SPECIAL_ACTIONS
    if type(actions) ~= "table" or #actions == 0 then
        return M.DoTornado(inst, target) or M.DoWaterBalloon(inst, target)
    end

    local pool = {}
    local total = 0
    for _, entry in ipairs(actions) do
        local w = (type(entry) == "table" and tonumber(entry.weight)) or 0
        if w > 0 and ACTION_FNS[entry.action] then
            total = total + w
            pool[#pool + 1] = { action = entry.action, weight = w }
        end
    end
    if total <= 0 then
        return M.DoTornado(inst, target) or M.DoWaterBalloon(inst, target)
    end

    while #pool > 0 do
        local r = math.random() * total
        local acc = 0
        local idx = #pool
        for i, entry in ipairs(pool) do
            acc = acc + entry.weight
            if r <= acc then
                idx = i
                break
            end
        end
        local picked = pool[idx]
        if ACTION_FNS[picked.action](inst, target) then
            return true
        end
        total = total - picked.weight
        table.remove(pool, idx)
    end
    return false
end

return M
