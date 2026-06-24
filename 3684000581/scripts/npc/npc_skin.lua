-- scripts/npc/npc_skin.lua
-- NPC 服装皮肤系统（清洁扫把随机换肤）
-- 使用 DST 服装系统（body/hand/legs/feet 四槽位）

local npc_utils = require("npc/npc_utils")
local NPC_SPEECH = require("npc_speech")
local NPC_TUNING = require("npc_tuning")

local APPEARANCE = npc_utils.APPEARANCE

local function ReskinDbg(fmt, ...)
    if not (NPC_TUNING and NPC_TUNING.DEBUG_RESKIN) then
        return
    end
    print(string.format(fmt, ...))
end

-- 不兼容 DST 服装系统的角色黑名单

local RESKIN_INCOMPATIBLE_CHARS = {
    wilba = true,  
}

local npc_skin = {}

local HEAD_SYMBOLS = {
    "headbase", "headbase_hat",
    "hair", "hair_hat",
    "hairfront", "hairpigtails",
    "face", "cheeks", "beard",
}

-- ────────────────────────────────────────────────────────────
-- 应用服装到 NPC（服务端 + 自动同步到客户端）
-- ────────────────────────────────────────────────────────────
function npc_skin.ApplyNPCClothing(inst, clothing, userid)
    if not clothing or not inst.AnimState then
        ReskinDbg("[NPC_RESKIN] Apply 跳过: clothing 为空 或 无 AnimState")
        return
    end
    if inst._is_ghost_mode then
        ReskinDbg("[NPC_RESKIN] Apply 跳过: NPC 处于幽灵模式 _is_ghost_mode=true")
        return
    end

    local char_type = inst.npc_character_type or "wilson"

    if RESKIN_INCOMPATIBLE_CHARS[char_type] then
        ReskinDbg(
            "[NPC_RESKIN] Apply 跳过: char_type=%s 在不兼容黑名单中（build symbol 与 DST 服装系统不匹配）",
            tostring(char_type))
        return
    end

    if inst._silvernecklace_were
        or inst._silvernecklace_transform_pending
        or (inst.AnimState:GetBuild() == "werewilba") then
        ReskinDbg(
            "[NPC_RESKIN] Apply 跳过: char_type=%s 当前为狼猪形态，换肤不生效",
            tostring(char_type))
        return
    end

    local base_skin = char_type
    if GetSkinData then
        local sd = GetSkinData(char_type .. "_none")
        if sd and sd.skins then
            base_skin = sd.skins["normal_skin"] or char_type
        end
    end

    ReskinDbg(
        "[NPC_RESKIN] Apply 入口: char_type=%s base_skin=%s userid=%s clothing={base=%s,body=%s,hand=%s,legs=%s,feet=%s}",
        tostring(char_type), tostring(base_skin), tostring(userid),
        tostring(clothing.base), tostring(clothing.body),
        tostring(clothing.hand), tostring(clothing.legs), tostring(clothing.feet))

    if not userid or userid == "" then
        ReskinDbg("[NPC_RESKIN] Apply 跳过: userid 为空（衣柜/扫把未传入有效 userid）")
        return
    end

    local char_skin_name = clothing.base or ""
    local char_skin_build = nil
    if char_skin_name ~= "" and GetSkinData then
        local sd = GetSkinData(char_skin_name)
        if sd and sd.skins then
            char_skin_build = sd.skins["normal_skin"] or char_skin_name
        else
            char_skin_build = char_skin_name
        end
    end
    ReskinDbg(
        "[NPC_RESKIN] Apply 角色皮肤: char_skin_name=%s, char_skin_build=%s",
        tostring(char_skin_name), tostring(char_skin_build))

    -- 关键：AssignItemSkins 把整套服装登记到实体并联网同步到客户端，
    local load_base = char_skin_name ~= "" and char_skin_name or (char_type .. "_none")
    inst.AnimState:AssignItemSkins(
        userid,
        load_base,
        clothing.body or "",
        clothing.hand or "",
        clothing.legs or "",
        clothing.feet or ""
    )

    inst.AnimState:SetSkin(base_skin, char_type)

    if CLOTHING then
        local cleared = {}
        for _, data in pairs(CLOTHING) do
            if data.symbol_overrides then
                for _, sym in ipairs(data.symbol_overrides) do
                    if not cleared[sym] then
                        inst.AnimState:ClearOverrideSymbol(sym)
                        cleared[sym] = true
                    end
                end
            end
        end
        for _, data in pairs(CLOTHING) do
            if data.symbol_hides then
                for _, sym in ipairs(data.symbol_hides) do
                    inst.AnimState:ShowSymbol(sym)
                end
            end
        end
    end


    if char_skin_build then
        for _, sym in ipairs(HEAD_SYMBOLS) do
            inst.AnimState:OverrideItemSkinSymbol(sym, char_skin_build, sym, inst.GUID, char_type)
        end
        ReskinDbg(
            "[NPC_RESKIN] Apply 头部 Override: build=%s, syms=[headbase,headbase_hat,hair,hair_hat,hairfront,hairpigtails,face,cheeks,beard]",
            tostring(char_skin_build))
    else
        ReskinDbg("[NPC_RESKIN] Apply 头部 Override: 跳过（char_skin_build 为 nil）")
    end

    local clothing_order = { "legs", "body", "feet", "hand" }
    for _, ctype in ipairs(clothing_order) do
        local name = clothing[ctype]
        if name and name ~= "" and CLOTHING and CLOTHING[name] then
            local build = GetBuildForItem(name)
            local override_syms = CLOTHING[name].symbol_overrides or {}
            local hide_syms = CLOTHING[name].symbol_hides or {}
            ReskinDbg(
                "[NPC_RESKIN] Apply ctype=%s name=%s build=%s overrides=%d hides=%d",
                tostring(ctype), tostring(name), tostring(build),
                #override_syms, #hide_syms)
            if not build or build == "" then
                ReskinDbg(
                    "[NPC_RESKIN] WARN: ctype=%s name=%s 没有有效 build（GetBuildForItem 返回 %s），可能透明",
                    tostring(ctype), tostring(name), tostring(build))
            end
            for _, sym in ipairs(override_syms) do
                inst.AnimState:ShowSymbol(sym)
                inst.AnimState:OverrideItemSkinSymbol(sym, build, sym, inst.GUID, char_type)
            end
            if #override_syms > 0 then
                ReskinDbg("[NPC_RESKIN]   override_syms=%s", table.concat(override_syms, ","))
            end
            for _, sym in ipairs(hide_syms) do
                inst.AnimState:HideSymbol(sym)
            end
            if #hide_syms > 0 then
                ReskinDbg("[NPC_RESKIN]   hide_syms=%s", table.concat(hide_syms, ","))
            end
        elseif name and name ~= "" then
            ReskinDbg(
                "[NPC_RESKIN] WARN: ctype=%s name=%s 在 CLOTHING 表中找不到（CLOTHING=%s）",
                tostring(ctype), tostring(name), tostring(CLOTHING ~= nil))
        end
    end


    local inv = inst.components.inventory
    if inv then
        for _, eslot in ipairs({ EQUIPSLOTS.HANDS, EQUIPSLOTS.HEAD, EQUIPSLOTS.BODY }) do
            local item = inv:GetEquippedItem(eslot)
            if item and item.components.equippable and item.components.equippable.onequipfn then
                item.components.equippable.onequipfn(item, inst)
            end
        end
    end

    inst._npc_clothing = clothing
    inst._npc_clothing_userid = userid

    -- 临时诊断：换肤后立即 / 0.5 秒后回读实际 build，检测是否被其它逻辑覆盖回默认
    if NPC_TUNING and NPC_TUNING.DEBUG_RESKIN and inst.AnimState.GetBuild then
        ReskinDbg("[NPC_RESKIN] Apply 完成后即时 build=%s", tostring(inst.AnimState:GetBuild()))
        inst:DoTaskInTime(0.5, function()
            if inst:IsValid() and inst.AnimState.GetBuild then
                ReskinDbg("[NPC_RESKIN] Apply 后 0.5s build=%s（若变回默认说明被覆盖）",
                    tostring(inst.AnimState:GetBuild()))
            end
        end)
    end
end

-- ────────────────────────────────────────────────────────────
-- 随机换肤：从使用扫把的玩家 Steam 库存中随机选取各部位服装
-- ────────────────────────────────────────────────────────────
function npc_skin.RandomizeNPCClothing(inst, caster)
    if not caster or not caster.userid or caster.userid == "" then
        return false
    end
    local userid = caster.userid

    if not CLOTHING then
        return false
    end

    local char_type_pre = inst.npc_character_type or "wilson"
    if RESKIN_INCOMPATIBLE_CHARS[char_type_pre] then
        ReskinDbg(
            "[NPC_RESKIN] Randomize 跳过: char_type=%s 在不兼容黑名单中",
            tostring(char_type_pre))
        if inst.components.talker and NPC_SPEECH.RESKIN_NO_SKINS then
            local line = NPC_SPEECH.GetLine(NPC_SPEECH.RESKIN_NO_SKINS, inst.npc_character_type)
            if line then inst.components.talker:Say(line) end
        end
        return false
    end

    local owned = { body = {}, hand = {}, legs = {}, feet = {} }
    local checked_count = 0
    for name, data in pairs(CLOTHING) do
        if data and data.type and owned[data.type] and not data.is_default then
            local skip = false
            if SKINS_EVENTLOCK and SKINS_EVENTLOCK[name]
               and not IsSpecialEventActive(SKINS_EVENTLOCK[name]) then
                skip = true
            end
            if not skip then
                checked_count = checked_count + 1
                if TheInventory:CheckClientOwnership(userid, name) then
                    table.insert(owned[data.type], name)
                end
            end
        end
    end
    ReskinDbg(
        "[NPC_RESKIN] Randomize 拥有皮肤: body=%d hand=%d legs=%d feet=%d (checked=%d)",
        #owned.body, #owned.hand, #owned.legs, #owned.feet, checked_count)

    local total = 0
    for _, list in pairs(owned) do total = total + #list end
    if total == 0 then
        if inst.components.talker and NPC_SPEECH.RESKIN_NO_SKINS then
            local line = NPC_SPEECH.GetLine(NPC_SPEECH.RESKIN_NO_SKINS, inst.npc_character_type)
            if line then inst.components.talker:Say(line) end
        end
        return false
    end

    local clothing = { base = "", body = "", hand = "", legs = "", feet = "" }
    for ctype, list in pairs(owned) do
        if #list > 0 then
            clothing[ctype] = list[math.random(#list)]
        end
    end

    local char_type = inst.npc_character_type or "wilson"
    local owned_base = {}
    if PREFAB_SKINS and PREFAB_SKINS[char_type] then
        for _, skin_name in ipairs(PREFAB_SKINS[char_type]) do
            if TheInventory:CheckClientOwnership(userid, skin_name) then
                table.insert(owned_base, skin_name)
            end
        end
    end
    if #owned_base > 0 then
        clothing.base = owned_base[math.random(#owned_base)]
    end
    ReskinDbg(
        "[NPC_RESKIN] Randomize 选中: char_type=%s base=%s body=%s hand=%s legs=%s feet=%s (owned_base=%d)",
        tostring(char_type), tostring(clothing.base),
        tostring(clothing.body), tostring(clothing.hand),
        tostring(clothing.legs), tostring(clothing.feet), #owned_base)

    npc_skin.ApplyNPCClothing(inst, clothing, userid)

    if inst.components.talker and NPC_SPEECH.RESKIN then
        local line = NPC_SPEECH.GetLine(NPC_SPEECH.RESKIN, inst.npc_character_type)
        if line then inst.components.talker:Say(line) end
    end

    return true
end

-- ────────────────────────────────────────────────────────────
-- 清除换肤施加的符号覆盖（变身成狼猪时调用）
-- ────────────────────────────────────────────────────────────
function npc_skin.ClearNPCClothingSymbols(inst)
    if not (inst and inst.AnimState) then
        return
    end

    for _, sym in ipairs(HEAD_SYMBOLS) do
        inst.AnimState:ClearOverrideSymbol(sym)
    end

    if CLOTHING then
        for _, data in pairs(CLOTHING) do
            if data.symbol_overrides then
                for _, sym in ipairs(data.symbol_overrides) do
                    inst.AnimState:ClearOverrideSymbol(sym)
                end
            end
            if data.symbol_hides then
                for _, sym in ipairs(data.symbol_hides) do
                    inst.AnimState:ShowSymbol(sym)
                end
            end
        end
    end
end

return npc_skin
