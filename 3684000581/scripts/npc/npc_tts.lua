-- scripts/npc/npc_tts.lua


local NPC_SPEECH  = require("npc_speech")
local NPC_TUNING  = require("npc_tuning")

local NPC_TTS = {}

local EVENT_GROUP = "untitled"

local function GetBankName(char)
    return "npc_" .. tostring(char)
end

NPC_TTS.audio_chars = {}
NPC_TTS.voice_mode = "abstract"

local CHAR_LIST = {
    "wilson", "wathgrithr", "wendy", "wolfgang", "wormwood", "warly", "waxwell", "wes",
    "winona", "woodie", "willow", "wickerbottom", "walter", "webber", "wurt", "wx78",
    "wortox", "wanda", "wonkey", "wilba",
}
NPC_TTS.CHAR_LIST = CHAR_LIST

local text_to_event = nil

local function IsLineArray(t)
    return type(t) == "table" and type(t[1]) == "string"
end

local function BuildMaps()
    text_to_event = {}
    for _, char in ipairs(CHAR_LIST) do
        text_to_event[char] = {}
    end

    for scene_name, scene_tbl in pairs(NPC_SPEECH) do
        if type(scene_tbl) == "table" then
            for _, char in ipairs(CHAR_LIST) do
                local pool = scene_tbl[char]
                if not IsLineArray(pool) then
                    pool = scene_tbl._default
                end
                if IsLineArray(pool) then
                    for i, line in ipairs(pool) do
                        if type(line) == "string" and text_to_event[char][line] == nil then
                            text_to_event[char][line] = scene_name .. "_" .. char .. "_" .. i
                        end
                    end
                end
            end
        end
    end
end

function NPC_TTS.Init(audio_char_list, config)
    NPC_TTS.audio_chars = {}
    if type(audio_char_list) == "table" then
        for _, c in ipairs(audio_char_list) do
            NPC_TTS.audio_chars[c] = true
        end
    end

    config = config or {}
    NPC_TTS.voice_mode = config.voice_mode == "original" and "original" or "abstract"
    NPC_TUNING.TTS_ENABLED = NPC_TUNING.TTS_ENABLED or {}
    for _, c in ipairs(CHAR_LIST) do
        NPC_TUNING.TTS_ENABLED[c] = (config["voice_" .. c] ~= false)
    end

    if text_to_event == nil then
        BuildMaps()
    end
end

function NPC_TTS.GetVolume(char)
    local v = NPC_TUNING.TTS_VOLUME
    return (v and (v[char] or v._default)) or 1.0
end

function NPC_TTS.SetVolume(char, vol)
    NPC_TUNING.TTS_VOLUME = NPC_TUNING.TTS_VOLUME or {}
    NPC_TUNING.TTS_VOLUME[char] = vol
end

function NPC_TTS.IsEnabled(char)
    local e = NPC_TUNING.TTS_ENABLED
    return not (e and e[char] == false)
end

function NPC_TTS.SetEnabled(char, on)
    NPC_TUNING.TTS_ENABLED = NPC_TUNING.TTS_ENABLED or {}
    NPC_TUNING.TTS_ENABLED[char] = (on and true or false)
end

function NPC_TTS.GetEventName(char, text)
    if not char or not text then return nil end
    local m = text_to_event and text_to_event[char]
    return m and m[text] or nil
end

function NPC_TTS.OnSay(inst, text)
    if not (inst and inst.SoundEmitter) then return end
    if not NPC_SPEECH._is_chinese then return end          -- 目前仅中文
    if NPC_TTS.voice_mode ~= "abstract" then return end     -- 原版模式只保留角色 talk_LP 音效
    local char = inst.npc_character_type
    if not char or not NPC_TTS.audio_chars[char] then return end
    if not NPC_TTS.IsEnabled(char) then return end          -- 该角色语音被关闭
    local event = NPC_TTS.GetEventName(char, text)
    if not event then return end
    inst.SoundEmitter:KillSound("npc_tts")
    inst.SoundEmitter:PlaySound(GetBankName(char) .. "/" .. EVENT_GROUP .. "/" .. event, "npc_tts", NPC_TTS.GetVolume(char))
end

return NPC_TTS
