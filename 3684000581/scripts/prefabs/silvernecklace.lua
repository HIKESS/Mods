-- 银项链 
-- ──────────────────────────────────────────────────────────────────────
-- 模块化变身系统：
--   佩戴 → 强制变身动画 → 切换为 werewilba 外观
--   摘下 → 强制还原动画 → 恢复原外观（含玩家皮肤 / NPC 服装）

-- ──────────────────────────────────────────────────────────────────────
-- 架构：silvernecklace.lua 是唯一调度者
--   ▸ NPC：DoTaskInTime(0) → 直接 sg:GoToState("transform_werewilba"/"transform_wilba")
--   ▸ 玩家：DoTaskInTime(0) → 直接 sg:GoToState("silvernecklace_transform"/"silvernecklace_reform")
--     （wilson 状态机的新状态由 modmain.lua 通过 AddStategraphState 注入）
--   SGnpcfriend 的 equip/unequip 中对银项链分支只做 return，不再触发状态切换

local assets =
{
    Asset("ANIM", "anim/silvernecklace.zip"),
    Asset("ANIM", "anim/torso_silvernecklace.zip"),
}


local WERE_TRANSFORM = {
    transform_build  = "werewilba",
    transform_bank   = "wilson",
    override_build   = "werewilba_transform",
    anim_pre         = "transform_pre",
    anim_pst         = "transform_pst",
    anim_reform      = "reform",
    sound_to_were    = "dontstarve/creatures/werepig/transformToWere",
    sound_to_human   = "dontstarve/creatures/werepig/transformToPig",
    puff_fx          = "small_puff",
    colour_cube      = "images/colour_cubes/beaver_vision_cc.tex",
    light_colour     = { 1, 0.2, 0.2 },
    light_radius     = 4,
    light_intensity  = 0.6,
    light_falloff    = 0.5,
    grunt_sounds     = {
        "dontstarve/creatures/werepig/grunt",
        "dontstarve/creatures/werepig/idle",
    },
}


local VALID_TRANSFORM_PREFABS = {
    wilson = true, willow = true, wolfgang = true, wendy = true,
    wx78 = true, wickerbottom = true, wes = true,
    maxwell = true, wigfrid = true, webber = true, winona = true,
    wortox = true, wormwood = true, wurt = true, walter = true,

}

local function CanTransform(owner)
    if not owner then return false end
    if VALID_TRANSFORM_PREFABS[owner.prefab] then return true end
    if VALID_TRANSFORM_PREFABS[owner.npc_character_type] then return true end
    return false
end

local function SayNoEffect(owner)
    if owner and owner.components and owner.components.talker then
        owner.components.talker:Say("这个项链似乎对我没用")
    end
end


local SILVERNECKLACE_ABSORB = 0.30    
local SILVERNECKLACE_DAMAGE = 20      
local SILVERNECKLACE_DEBUG = false     


NPCFRIENDS_SILVERNECKLACE_PARAMS = WERE_TRANSFORM
if _G then
    _G.NPCFRIENDS_SILVERNECKLACE_PARAMS = WERE_TRANSFORM
end





local function OwnerLabel(owner)
    if not owner then return "nil" end
    return string.format("%s[%s] build=%s were=%s tpend=%s rpend=%s qreform=%s",
        tostring(owner.prefab),
        tostring(owner.npc_character_type or owner.userid or owner.GUID),
        tostring(owner.AnimState and owner.AnimState:GetBuild() or "noanim"),
        tostring(owner._silvernecklace_were),
        tostring(owner._silvernecklace_transform_pending),
        tostring(owner._silvernecklace_reform_pending),
        tostring(owner._silvernecklace_queue_reform))
end

local function DebugLog(where, owner, extra)
    if SILVERNECKLACE_DEBUG then
        print("[silvernecklace] " .. tostring(where) .. " owner=" .. OwnerLabel(owner) .. " " .. tostring(extra or ""))
    end
end

local function SpawnPuff(owner)
    if owner and owner:IsValid() and owner.Transform then
        local x, y, z = owner.Transform:GetWorldPosition()
        local fx = SpawnPrefab(WERE_TRANSFORM.puff_fx)
        if fx then
            fx.Transform:SetPosition(x, y, z)
        end
    end
end

local function StartWerewilbaSounds(owner)
    if not (owner and owner:IsValid()) then return end
    if owner._werewilba_sound_task then
        owner._werewilba_sound_task:Cancel()
    end
    owner._werewilba_sound_task = owner:DoPeriodicTask(8, function()
        if owner.SoundEmitter then
            local snd = WERE_TRANSFORM.grunt_sounds[math.random(#WERE_TRANSFORM.grunt_sounds)]
            owner.SoundEmitter:PlaySound(snd)
        end
    end)
end

local function StopWerewilbaSounds(owner)
    if owner and owner._werewilba_sound_task then
        owner._werewilba_sound_task:Cancel()
        owner._werewilba_sound_task = nil
    end
end

local function SetRedLight(owner, on)
    if not owner.Light then
        if not on then return end
        if _G and _G.pcall then
            _G.pcall(function() owner:AddComponent("light") end)
        else
            owner:AddComponent("light")
        end
    end
    if not owner.Light then return end
    if on then
        owner.Light:Enable(true)
        owner.Light:SetColour(WERE_TRANSFORM.light_colour[1], WERE_TRANSFORM.light_colour[2], WERE_TRANSFORM.light_colour[3])
        owner.Light:SetRadius(WERE_TRANSFORM.light_radius)
        owner.Light:SetIntensity(WERE_TRANSFORM.light_intensity)
        owner.Light:SetFalloff(WERE_TRANSFORM.light_falloff)
    else
        owner.Light:Enable(false)
    end
end

local function SetRedFilter(on)
    if TheWorld and TheWorld.components and TheWorld.components.colourcubemanager then
        TheWorld.components.colourcubemanager:SetOverrideColourCube(on and WERE_TRANSFORM.colour_cube or nil)
    end
end


NPCFRIENDS_SILVERNECKLACE_UTILS = {
    SpawnPuff             = SpawnPuff,
    StartWerewilbaSounds  = StartWerewilbaSounds,
    StopWerewilbaSounds   = StopWerewilbaSounds,
    SetRedLight           = SetRedLight,
    SetRedFilter          = SetRedFilter,
    DebugLog              = DebugLog,
}
if _G then
    _G.NPCFRIENDS_SILVERNECKLACE_UTILS = NPCFRIENDS_SILVERNECKLACE_UTILS
end





local function IsPlayer(owner)
    return owner and owner.components and owner.components.playercontroller ~= nil
end

local function SaveAppearance(owner)
    owner._silvernecklace_is_player = IsPlayer(owner)
    if owner.AnimState then
        owner._silvernecklace_orig_build = owner.AnimState:GetBuild()
    end
    if owner.components.skinner then
        owner._silvernecklace_orig_skin_name = owner.components.skinner.skin_name
        if owner.components.skinner.GetSkinMode then
            owner._silvernecklace_orig_skin_mode = owner.components.skinner:GetSkinMode()
        end
    end
    
    owner._silvernecklace_orig_npc_clothing = owner._npc_clothing
    owner._silvernecklace_orig_npc_clothing_uid = owner._npc_clothing_userid
end

local function RestoreAppearance(owner)
    if not (owner and owner.AnimState) then return end
    local is_player = owner._silvernecklace_is_player
    if is_player == nil then
        is_player = IsPlayer(owner)
    end
    
    if is_player and owner.components.skinner then
        local name = owner._silvernecklace_orig_skin_name
        local mode = owner._silvernecklace_orig_skin_mode
        if name and name ~= "" then
            owner.components.skinner:SetSkinName(name)
        end
        if mode and owner.components.skinner.SetSkinMode then
            owner.components.skinner:SetSkinMode(mode)
        end
        local cur = owner.AnimState:GetBuild()
        if cur == WERE_TRANSFORM.transform_build then
            local fallback = owner._silvernecklace_orig_build or owner.prefab or "wilson"
            owner.AnimState:SetBuild(fallback)
        end
        return
    end
    
    local build = owner._silvernecklace_orig_build
    if (not build or build == "") and owner.AnimState:GetBuild() == WERE_TRANSFORM.transform_build then
        build = owner.npc_character_type or "wilson"
    end
    if build and build ~= "" then
        owner.AnimState:SetBuild(build)
    end
    local clothing = owner._silvernecklace_orig_npc_clothing or owner._npc_clothing
    if clothing and owner.ApplyNPCClothing then
        owner:ApplyNPCClothing(clothing, (owner._silvernecklace_orig_npc_clothing_uid or owner._npc_clothing_userid or ""))
    end
end

local function ClearSavedAppearance(owner)
    owner._silvernecklace_is_player = nil
    owner._silvernecklace_orig_build = nil
    owner._silvernecklace_orig_skin_name = nil
    owner._silvernecklace_orig_skin_mode = nil
    owner._silvernecklace_orig_npc_clothing = nil
    owner._silvernecklace_orig_npc_clothing_uid = nil

end


NPCFRIENDS_SILVERNECKLACE_UTILS.RestoreAppearance = RestoreAppearance
NPCFRIENDS_SILVERNECKLACE_UTILS.ClearSavedAppearance = ClearSavedAppearance
if _G then
    _G.NPCFRIENDS_SILVERNECKLACE_UTILS = NPCFRIENDS_SILVERNECKLACE_UTILS
end







local BONUS_KEY = "_silvernecklace_bonusfn"
local PREV_BONUS_KEY = "_silvernecklace_prev_bonusfn"
local NPC_BONUS_INSTALLED_KEY = "_silvernecklace_npc_bonus_installed"


local function RecalcNPCDamage(owner)
    if not (owner.components and owner.components.combat) then return end
    local base = owner.npc_base_damage or 0
    local mult = owner.npc_damage_mult or 1
    local weapon_dmg = 0
    if owner.components.inventory then
        local w = owner.components.inventory:GetEquippedItem(EQUIPSLOTS.HANDS)
        if w and w.components.weapon then
            weapon_dmg = w.components.weapon:GetDamage(owner) or 0
        end
    end
    owner.components.combat:SetDefaultDamage((base + weapon_dmg) * mult)
end

local function InstallDamageBonus(owner)
    if not (owner.components and owner.components.combat) then return end

    if owner.npc_base_damage ~= nil and not owner[NPC_BONUS_INSTALLED_KEY] then
        owner.npc_base_damage = owner.npc_base_damage + SILVERNECKLACE_DAMAGE
        owner[NPC_BONUS_INSTALLED_KEY] = true
        RecalcNPCDamage(owner)
        return
    end

    if owner[BONUS_KEY] then return end
    owner[PREV_BONUS_KEY] = owner.components.combat.bonusdamagefn
    local fn = function(attacker, target, damage, weapon)
        local prev = 0
        if owner[PREV_BONUS_KEY] then
            prev = owner[PREV_BONUS_KEY](attacker, target, damage, weapon) or 0
        end
        return prev + SILVERNECKLACE_DAMAGE
    end
    owner[BONUS_KEY] = fn
    owner.components.combat.bonusdamagefn = fn
end

local function RemoveDamageBonus(owner)
    if not (owner.components and owner.components.combat) then return end

    
    if owner[NPC_BONUS_INSTALLED_KEY] and owner.npc_base_damage ~= nil then
        owner.npc_base_damage = owner.npc_base_damage - SILVERNECKLACE_DAMAGE
        owner[NPC_BONUS_INSTALLED_KEY] = nil
        RecalcNPCDamage(owner)
        return
    end

    
    if owner[BONUS_KEY] and owner.components.combat.bonusdamagefn == owner[BONUS_KEY] then
        owner.components.combat.bonusdamagefn = owner[PREV_BONUS_KEY]
    end
    owner[BONUS_KEY] = nil
    owner[PREV_BONUS_KEY] = nil
end







local function TransformStateName(owner)
    return owner._silvernecklace_is_player
        and "silvernecklace_transform"
        or  "transform_werewilba"
end

local function ReformStateName(owner)
    return owner._silvernecklace_is_player
        and "silvernecklace_reform"
        or  "transform_wilba"
end

local function BuildStateData(owner)
    return {
        transform_build  = WERE_TRANSFORM.transform_build,
        transform_bank   = WERE_TRANSFORM.transform_bank,
        original_build   = owner._silvernecklace_orig_build,
        original_bank    = "wilson",
        npc_clothing     = owner._silvernecklace_orig_npc_clothing,
        npc_clothing_uid = owner._silvernecklace_orig_npc_clothing_uid,
        skin_name        = owner._silvernecklace_orig_skin_name,
        skin_mode        = owner._silvernecklace_orig_skin_mode,
    }
end





local function IsWilba(owner)
    if not owner then return false end
    if owner.prefab == "wilba" then return true end
    if owner.npc_character_type == "wilba" then return true end
    return false
end

local function IsWoodie(owner)
    if not owner then return false end
    if owner.prefab == "woodie" then return true end
    if owner.npc_character_type == "woodie" then return true end
    return false
end

local function IsSilverNecklaceEquipped(owner)
    if owner and owner._silvernecklace_equipped ~= nil then
        return owner._silvernecklace_equipped
    end
    local inv = owner and owner.components and owner.components.inventory
    local body = inv and inv:GetEquippedItem(EQUIPSLOTS.BODY) or nil
    return body ~= nil and body.prefab == "silvernecklace"
end


local function IsLoadingWindow(owner)
    if not owner then return false end
    if owner._silvernecklace_loading then return true end
    if owner.prefab == "npcfriend" and owner.npc_character_type == nil then
        return true
    end
    return false
end

local function IsDeadOrGhost(owner)
    if not (owner and owner:IsValid()) then return true end
    if owner._is_ghost_mode then return true end          
    if owner:HasTag("playerghost") then return true end   
    local h = owner.components and owner.components.health
    if h and h:IsDead() then return true end
    
    if owner.sg and owner.sg.currentstate
        and owner.sg.currentstate.name == "death" then
        return true
    end
    return false
end

local function GetEquippedSilverNecklace(owner)
    local inv = owner and owner.components and owner.components.inventory
    local body = inv and inv:GetEquippedItem(EQUIPSLOTS.BODY) or nil
    return body ~= nil and body.prefab == "silvernecklace" and body or nil
end


local function ShouldBeWereByEquipment(owner)
    if not owner then return false end
    if IsWoodie(owner) then return false end
    if not CanTransform(owner) and not IsWilba(owner) then return false end
    local equipped = IsSilverNecklaceEquipped(owner)
    if IsWilba(owner) then
        return not equipped
    end
    return equipped
end





local function StartTransform(owner)
    if not owner.sg then return end
    if IsDeadOrGhost(owner) then
        
        DebugLog("StartTransform.skip.dead_or_ghost", owner)
        return
    end
    if owner._silvernecklace_transform_pending then
        DebugLog("StartTransform.skip.transform_pending", owner)
        return
    end
    if owner._silvernecklace_were then
        DebugLog("StartTransform.skip.already_were", owner)
        return
    end
    owner._silvernecklace_transform_pending = true
    DebugLog("StartTransform.GoToState", owner, TransformStateName(owner))
    owner.sg:GoToState(TransformStateName(owner), BuildStateData(owner))
end

local function StartReform(owner)
    if not owner.sg then return end
    if IsDeadOrGhost(owner) then
        DebugLog("StartReform.skip.dead_or_ghost", owner)
        return
    end
    if owner._silvernecklace_reform_pending then
        DebugLog("StartReform.skip.reform_pending", owner)
        return
    end
    if not owner._silvernecklace_were
        and not (owner.AnimState and owner.AnimState:GetBuild() == WERE_TRANSFORM.transform_build) then
        DebugLog("StartReform.skip.not_were", owner)
        return
    end
    owner._silvernecklace_reform_pending = true
    DebugLog("StartReform.GoToState", owner, ReformStateName(owner))
    owner.sg:GoToState(ReformStateName(owner), BuildStateData(owner))
end

local function ReconcileAfterTransform(owner)
    local equipped = IsSilverNecklaceEquipped(owner)
    local should_were = ShouldBeWereByEquipment(owner)
    DebugLog("ReconcileAfterTransform", owner,
        "equipped=" .. tostring(equipped) .. " should_were=" .. tostring(should_were))
    if not should_were then
        owner._silvernecklace_queue_reform = false
        StartReform(owner)
        return true
    end
    owner._silvernecklace_queue_reform = false
    return false
end

local function ReconcileAfterReform(owner)
    local equipped = IsSilverNecklaceEquipped(owner)
    local should_were = ShouldBeWereByEquipment(owner)
    DebugLog("ReconcileAfterReform", owner,
        "equipped=" .. tostring(equipped) .. " should_were=" .. tostring(should_were))
    if should_were then
        owner._silvernecklace_queue_reform = false
        StartTransform(owner)
        return true
    end
    owner._silvernecklace_queue_reform = false
    return false
end

local function ApplyFinalFormAfterLoad(owner)
    if not (owner and owner:IsValid() and owner.AnimState) then return end
    if IsWoodie(owner) then return end
    if not CanTransform(owner) and not IsWilba(owner) then return end
    if IsDeadOrGhost(owner) then
        DebugLog("ApplyFinalFormAfterLoad.skip.dead_or_ghost", owner)
        return
    end

    local equipped_item = GetEquippedSilverNecklace(owner)
    owner._silvernecklace_equipped = equipped_item ~= nil

    if equipped_item ~= nil then
        equipped_item._silvernecklace_current_owner = owner
        equipped_item._silvernecklace_unequip_handled = false
        InstallDamageBonus(owner)
    else
        RemoveDamageBonus(owner)
    end


    owner._silvernecklace_transform_pending = false
    owner._silvernecklace_reform_pending = false
    owner._silvernecklace_queue_reform = false

    local should_were = ShouldBeWereByEquipment(owner)
    local is_were = owner._silvernecklace_were
        or (owner.AnimState and owner.AnimState:GetBuild() == WERE_TRANSFORM.transform_build)

    DebugLog("ApplyFinalFormAfterLoad", owner, "equipped=" .. tostring(equipped_item ~= nil) .. " should_were=" .. tostring(should_were) .. " is_were=" .. tostring(is_were))

    if should_were and not is_were then
        SaveAppearance(owner)
        StartTransform(owner)
    elseif not should_were and is_were then
        StartReform(owner)
    else
        
        owner._silvernecklace_were = is_were and true or false
    end
end

NPCFRIENDS_SILVERNECKLACE_UTILS.ShouldBeWereByEquipment = ShouldBeWereByEquipment
NPCFRIENDS_SILVERNECKLACE_UTILS.ReconcileAfterTransform = ReconcileAfterTransform
NPCFRIENDS_SILVERNECKLACE_UTILS.ReconcileAfterReform = ReconcileAfterReform
NPCFRIENDS_SILVERNECKLACE_UTILS.ApplyFinalFormAfterLoad = ApplyFinalFormAfterLoad
NPCFRIENDS_SILVERNECKLACE_UTILS.DebugLog = DebugLog
if _G then
    _G.NPCFRIENDS_SILVERNECKLACE_UTILS = NPCFRIENDS_SILVERNECKLACE_UTILS
end





local function onequip(inst, owner)
    if not owner or not owner.AnimState then return end

    
    if inst._silvernecklace_current_owner == owner then
        DebugLog("onequip.duplicate", owner)
        return
    end
    inst._silvernecklace_current_owner = owner
    inst._silvernecklace_unequip_handled = false
    owner._silvernecklace_equipped = true
    owner._silvernecklace_equip_token = inst
    DebugLog("onequip.enter", owner)


    if IsLoadingWindow(owner) then
        DebugLog("onequip.defer_to_load_handler", owner)
        return
    end

    InstallDamageBonus(owner)

    if IsDeadOrGhost(owner) then
        DebugLog("onequip.skip.dead_or_ghost", owner)
        return
    end

    if IsWoodie(owner) then
        DebugLog("onequip.woodie_stats_only", owner)
        SayNoEffect(owner)
        return
    end

    if owner._silvernecklace_transform_pending or owner._silvernecklace_reform_pending then
        DebugLog("onequip.defer_to_reconcile", owner, "should_were=" .. tostring(ShouldBeWereByEquipment(owner)))
        return
    end

    if not CanTransform(owner) and not IsWilba(owner) then
        DebugLog("onequip.cannot_transform", owner)
        SayNoEffect(owner)
        return
    end

    if IsWilba(owner) then
        if not owner._silvernecklace_were
            and (not owner.AnimState
                 or owner.AnimState:GetBuild() ~= WERE_TRANSFORM.transform_build) then
            DebugLog("onequip.wilba.keep_human", owner)
            return
        end
        owner:DoTaskInTime(0, function(o)
            if not o:IsValid() then return end
            local inv = o.components.inventory
            if not (inv and inv:GetEquippedItem(EQUIPSLOTS.BODY) == inst) then
                DebugLog("onequip.wilba.reform.skip.not_equipped", o)
                return
            end
            StartReform(o)
        end)
        return
    end

    if owner._silvernecklace_were then return end  

    SaveAppearance(owner)
    owner._silvernecklace_equip_item = inst
    DebugLog("onequip.normal.saved_appearance", owner)

    owner:DoTaskInTime(0, function(o)
        if not o:IsValid() then return end
        local inv = o.components.inventory
        if not (inv and inv:GetEquippedItem(EQUIPSLOTS.BODY) == inst) then
            DebugLog("onequip.normal.skip.not_equipped", o)
            return
        end
        StartTransform(o)
    end)
end

local function onunequip(inst, owner)
    if not owner then return end

    if inst._silvernecklace_unequip_handled then
        DebugLog("onunequip.duplicate", owner)
        return
    end
    inst._silvernecklace_unequip_handled = true
    inst._silvernecklace_current_owner = nil
    owner._silvernecklace_equipped = false
    owner._silvernecklace_equip_token = nil
    DebugLog("onunequip.enter", owner)

    StopWerewilbaSounds(owner)
    RemoveDamageBonus(owner)
    owner._silvernecklace_equip_item = nil

    if IsLoadingWindow(owner) then
        DebugLog("onunequip.defer_to_load_handler", owner)
        return
    end


    if IsDeadOrGhost(owner) then
        SetRedLight(owner, false)
        DebugLog("onunequip.skip.dead_or_ghost", owner)
        return
    end

    
    if IsWoodie(owner) then
        DebugLog("onunequip.woodie_stats_only", owner)
        SayNoEffect(owner)
        return
    end

    if owner._silvernecklace_transform_pending or owner._silvernecklace_reform_pending then
        DebugLog("onunequip.defer_to_reconcile", owner, "should_were=" .. tostring(ShouldBeWereByEquipment(owner)))
        return
    end

    if IsWilba(owner) then
        local in_were_form = owner._silvernecklace_were
            or (owner.AnimState and owner.AnimState:GetBuild() == WERE_TRANSFORM.transform_build)
        if in_were_form then
            DebugLog("onunequip.wilba.already_were", owner)
            return
        end
        SaveAppearance(owner)
        DebugLog("onunequip.wilba.start_transform", owner)
        owner:DoTaskInTime(0, function(o)
            if not o:IsValid() then return end
            if o._silvernecklace_transform_pending then
                DebugLog("onunequip.wilba.skip.transform_pending", o)
                return
            end
            
            local inv = o.components.inventory
            if inv and inv:GetEquippedItem(EQUIPSLOTS.BODY)
                and inv:GetEquippedItem(EQUIPSLOTS.BODY).prefab == "silvernecklace" then
                DebugLog("onunequip.wilba.skip.reequipped", o)
                return
            end
            StartTransform(o)
        end)
        return
    end

    local in_were_form = owner._silvernecklace_were
        or (owner.AnimState and owner.AnimState:GetBuild() == WERE_TRANSFORM.transform_build)
    if not in_were_form then
        if owner._silvernecklace_orig_build and not owner._silvernecklace_transform_pending then
            owner._silvernecklace_queue_reform = true
            DebugLog("onunequip.normal.queue_transform_then_reform_before_start", owner)
            StartTransform(owner)
            return
        end
        SetRedLight(owner, false)
        SetRedFilter(false)
        ClearSavedAppearance(owner)
        DebugLog("onunequip.normal.skip.not_were", owner)
        return
    end

    
    owner:DoTaskInTime(0, function(o)
        if not o:IsValid() then return end
        if o._silvernecklace_reform_pending then
            DebugLog("onunequip.normal.skip.reform_pending", o)
            return
        end
        local inv = o.components.inventory
        if inv and inv:GetEquippedItem(EQUIPSLOTS.BODY)
            and inv:GetEquippedItem(EQUIPSLOTS.BODY).prefab == "silvernecklace" then
            DebugLog("onunequip.normal.skip.reequipped", o)
            return
        end
        StartReform(o)
    end)
end





local function fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()

    inst.entity:AddNetwork()

    MakeInventoryPhysics(inst)

    inst.entity:AddMiniMapEntity()
    inst.MiniMapEntity:SetIcon("silvernecklace.png")

    MakeInventoryFloatable(inst, "silvernecklace_water", "silvernecklace")

    inst.AnimState:SetBank("silvernecklace")
    inst.AnimState:SetBuild("silvernecklace")
    inst.AnimState:PlayAnimation("silvernecklace")

    inst.AnimState:SetBloomEffectHandle("shaders/anim.ksh")

    inst:AddTag("silvernecklace_damage_bonus")

    inst.entity:SetPristine()
    if not TheWorld.ismastersim then
        return inst
    end

    inst:AddComponent("inspectable")

    inst:AddComponent("equippable")
    inst.components.equippable.equipslot = EQUIPSLOTS.BODY
    inst.components.equippable:SetOnEquip(onequip)
    inst.components.equippable:SetOnUnequip(onunequip)

    inst:AddComponent("armor")
    inst.components.armor:InitIndestructible(SILVERNECKLACE_ABSORB)

    inst:AddComponent("weapon")
    inst.components.weapon:SetDamage(SILVERNECKLACE_DAMAGE)
    inst.damage = SILVERNECKLACE_DAMAGE

    inst:AddComponent("inventoryitem")
    inst.components.inventoryitem.atlasname = "images/hamlet_inv1.xml"
    inst.components.inventoryitem.imagename = "silvernecklace"
    inst.components.inventoryitem.foleysound = "dontstarve/movement/foley/jewlery"

    return inst
end

return Prefab("silvernecklace", fn, assets)
