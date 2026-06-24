-- scripts/npc/npc_utils.lua
-- NPC 共享工具函数：UpdateHoverInfo, APPEARANCE 外观表, GetCharDisplayName
-- 被 npcfriend.lua 及各子模块 require

local NPC_TUNING = require("npc_tuning")
local NPC_SPEECH = require("npc_speech")

local npc_utils = {}

-- ── 语言检测 ──────────────────────────────────────────────────
npc_utils._is_chinese = NPC_SPEECH._is_chinese
local _zh = npc_utils._is_chinese
function npc_utils.L(zh, en) return _zh and zh or en end
local L = npc_utils.L

-- ── 默认属性（当 CHARACTER_STATS 中找不到 prefab 名称时使用）──
npc_utils.DEFAULT_STATS = { health = 150, max_health = 150, damage = 5, attack_range = 2 }

-- ── 各角色外观配置 ────────────────────────────────────────────
-- bank 统一为 "wilson"（DST 所有角色共用同一 bank），build 区分角色外观
npc_utils.APPEARANCE = {
    wilson       = { bank = "wilson", build = "wilson"       },
    willow       = { bank = "wilson", build = "willow"       },
    wolfgang     = { bank = "wilson", build = "wolfgang"     },
    wendy        = { bank = "wilson", build = "wendy"        },
    wx78         = { bank = "wilson", build = "wx78"         },
    wickerbottom = { bank = "wilson", build = "wickerbottom" },
    woodie       = { bank = "wilson", build = "woodie"       },
    wes          = { bank = "wilson", build = "wes"          },
    waxwell      = { bank = "wilson", build = "waxwell"      },
    wathgrithr   = { bank = "wilson", build = "wathgrithr"   },
    webber       = { bank = "wilson", build = "webber"       },
    winona       = { bank = "wilson", build = "winona"       },
    warly        = { bank = "wilson", build = "warly"        },
    wortox       = { bank = "wilson", build = "wortox_npc_face" },
    wormwood     = { bank = "wilson", build = "wormwood_npc_free" },
    wurt         = { bank = "wilson", build = "wurt_npc_free" },
    walter       = { bank = "wilson", build = "walter"       },
    wanda        = { bank = "wilson", build = NPC_TUNING.WANDA_BUILD_NORMAL or "wanda_NPC" },
    wonkey       = { bank = "wilson", build = "wonkey"       },
    wilba        = { bank = "wilson", build = "wilba_npc"     },  -- 猪人公主 (Hamlet DLC)
    -- 默认自定义伙伴：使用威尔逊外观
    npcfriend    = { bank = "wilson", build = "wilson"       },
}

-- ── 从游戏 STRINGS 获取角色显示名（服务端运行，自动跟随游戏语言）──
function npc_utils.GetCharDisplayName(char_key)
    if char_key then
        local key = string.upper(char_key)
        if STRINGS and STRINGS.NAMES and STRINGS.NAMES[key] then
            return STRINGS.NAMES[key]
        end
    end
    return char_key or "NPC"
end

-- ── 悬停提示构建（服务端调用，将格式化文本写入 net_string 同步到客户端）──
function npc_utils.UpdateHoverInfo(inst)
    if not (TheWorld.ismastersim and inst:IsValid() and inst.npc_hoverinfo) then return end
    local char_name = npc_utils.GetCharDisplayName(inst.npc_character_type)
    local hp_cur = inst.components.health and math.floor(inst.components.health.currenthealth) or 0
    local hp_max = inst.components.health and math.floor(inst.components.health.maxhealth)    or 0

    -- defaultdamage 已包含武器加成和角色倍率，直接使用
    -- 例：温蒂空手=3.75，温蒂+长矛=29.25，沃尔夫mighty+长矛=78
    local actual_dmg = inst.components.combat and inst.components.combat.defaultdamage or 0
    -- 旺达额外年龄倍率显示修正：
    -- defaultdamage 不包含 wanda.lua 中对 customdamagemultfn 的年龄倍率叠乘，
    -- 这里做一次预估显示，避免“面板显示低于实战命中”。
    if inst.npc_character_type == "wanda" then
        local state = inst._wanda_age_state or "normal"
        local weapon = inst.components.inventory and inst.components.inventory:GetEquippedItem(EQUIPSLOTS.HANDS) or nil
        local is_shadow = weapon ~= nil and weapon:HasTag("shadow_item")
        local age_mult = 1
        if is_shadow then
            if state == "old" then
                age_mult = NPC_TUNING.WANDA_SHADOW_DAMAGE_OLD or 1.75
            elseif state == "young" then
                age_mult = NPC_TUNING.WANDA_SHADOW_DAMAGE_YOUNG or 1
            else
                age_mult = NPC_TUNING.WANDA_SHADOW_DAMAGE_NORMAL or 1.2
            end
        else
            if state == "old" then
                age_mult = NPC_TUNING.WANDA_REGULAR_DAMAGE_OLD or 0.5
            elseif state == "young" then
                age_mult = NPC_TUNING.WANDA_REGULAR_DAMAGE_YOUNG or 1
            else
                age_mult = NPC_TUNING.WANDA_REGULAR_DAMAGE_NORMAL or 1
            end
        end
        actual_dmg = actual_dmg * age_mult
    end

    local text
    local leader = inst.components.follower and inst.components.follower.leader
    if leader then
        text = char_name .. L("的小伙伴","'s Companion") .. "\nHP: " .. hp_cur .. "/" .. hp_max
                 .. "\n" .. L("伤害: ","DMG: ") .. math.floor(actual_dmg)
    else
        text = char_name .. L(" (喂食招募)"," (Feed to Recruit)") .. "\nHP: " .. hp_cur .. "/" .. hp_max
                 .. "\n" .. L("伤害: ","DMG: ") .. math.floor(actual_dmg)
    end

    -- 角色固有减伤（如薇格弗德 25%）
    local char_absorb = inst.components.health and inst.components.health.absorb or 0

    -- 护甲减伤：遍历 BODY 和 HEAD 两个装备槽，多件防具叠加
    local armor_absorb = 0
    if inst.components.inventory then
        for _, eslot in ipairs({ EQUIPSLOTS.BODY, EQUIPSLOTS.HEAD }) do
            local armor_item = inst.components.inventory:GetEquippedItem(eslot)
            if armor_item and armor_item.components and armor_item.components.armor then
                local a = armor_item.components.armor.absorb_percent or 0
                -- 多件防具叠加公式：combined = 1-(1-a1)*(1-a2)
                armor_absorb = 1 - (1 - armor_absorb) * (1 - a)
            end
        end
    end

    -- 综合减伤 = 1 - (1-固有) * (1-护甲)
    local total_absorb = 1 - (1 - char_absorb) * (1 - armor_absorb)
    if total_absorb > 0 then
        text = text .. "\n" .. L("减伤: ","DEF: ") .. math.floor(total_absorb * 100) .. "%"
    end

    -- 吸血显示
    local stats = NPC_TUNING.CHARACTER_STATS[inst.npc_character_type]
    if stats and stats.lifesteal and stats.lifesteal > 0 then
        text = text .. "\n" .. L("吸血: +","Lifesteal: +") .. stats.lifesteal .. " HP/" .. L("击","hit")
    end

    -- Wolfgang 饱食度显示
    if inst._wolfgang_hunger ~= nil then
        local state_names = {
            wimpy  = L("虚弱","Wimpy"),
            normal = L("正常","Normal"),
            mighty = L("威猛","Mighty"),
        }
        local state_label = state_names[inst._wolfgang_state] or ""
        local max_h = inst._wolfgang_max_hunger or NPC_TUNING.WOLFGANG_MAX_HUNGER or 300
        text = text .. "\n" .. L("饱食: ","Hunger: ") .. math.floor(inst._wolfgang_hunger) .. "/" .. max_h .. " [" .. state_label .. "]"
    end

    inst.npc_hoverinfo:set(text)
end

return npc_utils
