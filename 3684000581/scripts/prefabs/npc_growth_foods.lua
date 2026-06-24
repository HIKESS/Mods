local NPC_TUNING = require("npc_tuning")
local NPC_SPEECH = require("npc_speech")

local assets = {
    Asset("ANIM", "anim/NPC_Heart.zip"),
    Asset("ANIM", "anim/NPC_Sword.zip"),
    Asset("ATLAS", "images/NPC_heart.xml"),
    Asset("ATLAS", "images/NPC_sword.xml"),
}

local WORLD_SCALE = 0.85

local function L(zh, en)
    local ok, play = pcall(function() return STRINGS.UI.MAINSCREEN.PLAY end)
    if ok and play and play:match("[\228-\233]") then
        return zh
    end
    local ok2, lt = pcall(function() return LanguageTranslator end)
    if ok2 and lt and lt.defaultlanguage then
        local lang = tostring(lt.defaultlanguage)
        if lang:find("zh") or lang == "schinese" or lang == "tchinese" then
            return zh
        end
    end
    return en
end

local function EnsureNPCFoodType()
    if FOODTYPE.NPCFRIENDS_ONLY == nil then
        FOODTYPE.NPCFRIENDS_ONLY = "NPCFRIENDS_ONLY"
    end
    return FOODTYPE.NPCFRIENDS_ONLY
end

local function RecalcDamageWithCurrentWeapon(eater)
    if not (eater and eater.components and eater.components.combat) then
        return
    end

    local inv = eater.components.inventory
    local weapon_damage = 0
    if inv then
        local weapon = inv:GetEquippedItem(EQUIPSLOTS.HANDS)
        if weapon and weapon.components and weapon.components.weapon then
            weapon_damage = weapon.components.weapon:GetDamage(eater) or 0
        end
    end

    local base = eater.npc_base_damage or 0
    local mult = eater.npc_damage_mult or 1
    eater.components.combat:SetDefaultDamage((base + weapon_damage) * mult)
end

local function OnEatNPCHeart(inst, eater)
    if not (eater and eater:HasTag("npcfriend")) then
        return
    end

    local delta = NPC_TUNING.NPC_HEART_PERM_MAX_HEALTH or 10
    eater._npc_bonus_max_health = (eater._npc_bonus_max_health or 0) + delta

    if eater.components and eater.components.health then
        local new_max = (eater.components.health.maxhealth or 0) + delta
        eater.components.health:SetMaxHealth(new_max)
        eater.components.health:DoDelta(delta, false, "npc_heart")
    end

    if eater._update_hoverinfo then
        eater._update_hoverinfo()
    end
    if eater.components and eater.components.talker then
        eater.components.talker:ShutUp()
        local line = NPC_SPEECH.GetLine(NPC_SPEECH.GROWTH_HEART, eater.npc_character_type)
        if line then
            eater.components.talker:Say(line)
        end
    end
end

local function OnEatNPCSword(inst, eater)
    if not (eater and eater:HasTag("npcfriend")) then
        return
    end

    local delta = NPC_TUNING.NPC_SWORD_PERM_DAMAGE or 2
    eater._npc_bonus_damage = (eater._npc_bonus_damage or 0) + delta
    eater.npc_base_damage = (eater.npc_base_damage or 0) + delta

    RecalcDamageWithCurrentWeapon(eater)

    if eater._update_hoverinfo then
        eater._update_hoverinfo()
    end
    if eater.components and eater.components.talker then
        eater.components.talker:ShutUp()
        local line = NPC_SPEECH.GetLine(NPC_SPEECH.GROWTH_SWORD, eater.npc_character_type)
        if line then
            eater.components.talker:Say(line)
        end
    end
end

local function MakeGrowthFood(def)
    local function fn()
        local inst = CreateEntity()

        inst.entity:AddTransform()
        inst.entity:AddAnimState()
        inst.entity:AddNetwork()

        MakeInventoryPhysics(inst)
        inst.Transform:SetScale(WORLD_SCALE, WORLD_SCALE, WORLD_SCALE)

        inst.AnimState:SetBank(def.world_bank)
        inst.AnimState:SetBuild(def.world_build)
        inst.AnimState:PlayAnimation("idle")

        inst:AddTag("preparedfood")
        inst:AddTag("npc_growth_food")

        EnsureNPCFoodType()
        inst.entity:SetPristine()

        if not TheWorld.ismastersim then
            return inst
        end

        inst:AddComponent("stackable")
        inst.components.stackable.maxsize = TUNING.STACK_SIZE_MEDITEM

        inst:AddComponent("inspectable")

        inst:AddComponent("inventoryitem")
        inst.components.inventoryitem.atlasname = def.atlas
        inst.components.inventoryitem:ChangeImageName(def.image)

        inst:AddComponent("edible")
        inst.components.edible.foodtype = EnsureNPCFoodType()
        inst.components.edible.healthvalue = 0
        inst.components.edible.hungervalue = 0
        inst.components.edible.sanityvalue = 0
        inst.components.edible:SetOnEatenFn(def.oneatenfn)

        return inst
    end

    return Prefab(def.prefab, fn, assets)
end

STRINGS.NAMES.NPC_HEART = STRINGS.NAMES.NPC_HEART or L("方糖", "Cube Sugar")
STRINGS.NAMES.NPC_SWORD = STRINGS.NAMES.NPC_SWORD or L("方糖", "Cube Sugar")

STRINGS.CHARACTERS.GENERIC.DESCRIBE.NPC_HEART =
    STRINGS.CHARACTERS.GENERIC.DESCRIBE.NPC_HEART
    or L("仅可喂食给NPC，永久提升生命上限。", "NPC-only feed. Permanently increases max health.")
STRINGS.CHARACTERS.GENERIC.DESCRIBE.NPC_SWORD =
    STRINGS.CHARACTERS.GENERIC.DESCRIBE.NPC_SWORD
    or L("仅可喂食给NPC，永久提升基础伤害。", "NPC-only feed. Permanently increases base damage.")

return
    MakeGrowthFood({
        prefab = "npc_heart",
        image = "NPC_heart",
        atlas = "images/NPC_heart.xml",
        world_bank = "NPC_Heart",
        world_build = "NPC_Heart",
        oneatenfn = OnEatNPCHeart,
    }),
    MakeGrowthFood({
        prefab = "npc_sword",
        image = "NPC_sword",
        atlas = "images/NPC_sword.xml",
        world_bank = "NPC_Sword",
        world_build = "NPC_Sword",
        oneatenfn = OnEatNPCSword,
    })
