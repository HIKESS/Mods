-- npc_config.lua
-- NPCFriends 全局配置表

-- 注意：GetModConfigData 仅在 mod 环境中可用，需通过参数传入
local function CreateConfig(GetModConfigData)
    return {
        combat_hotkey = GetModConfigData("combat_hotkey") or "R",
        max_followers = GetModConfigData("max_followers") or 2,
        voice_mode = GetModConfigData("voice_mode") or "abstract",

        -- 好感度系统总开关（nil 或无配置时默认开启）
        affinity_enabled = GetModConfigData("affinity_system") ~= false,
        
        -- 角色开关（nil 或无配置时默认启用）
        npc_wilson       = GetModConfigData("npc_wilson") ~= false,
        npc_wormwood     = GetModConfigData("npc_wormwood") ~= false,
        npc_warly        = GetModConfigData("npc_warly") ~= false,
        npc_woodie       = GetModConfigData("npc_woodie") ~= false,
        npc_wes          = GetModConfigData("npc_wes") ~= false,
        npc_winona       = GetModConfigData("npc_winona") ~= false,
        npc_wendy        = GetModConfigData("npc_wendy") ~= false,
        npc_wickerbottom = GetModConfigData("npc_wickerbottom") ~= false,
        npc_willow       = GetModConfigData("npc_willow") ~= false,
        npc_waxwell      = GetModConfigData("npc_waxwell") ~= false,
        npc_wathgrithr   = GetModConfigData("npc_wathgrithr") ~= false,
        npc_wolfgang     = GetModConfigData("npc_wolfgang") ~= false,
        npc_walter       = GetModConfigData("npc_walter") ~= false,
        npc_wortox       = GetModConfigData("npc_wortox") ~= false,
        npc_wanda        = GetModConfigData("npc_wanda") ~= false,
        npc_webber       = GetModConfigData("npc_webber") ~= false,
        npc_wurt         = GetModConfigData("npc_wurt") ~= false,
        npc_wx78         = GetModConfigData("npc_wx78") ~= false,
        npc_wonkey       = GetModConfigData("npc_wonkey") ~= false,
        npc_wilba        = GetModConfigData("npc_wilba") ~= false,

        -- 每角色语音(TTS)开关（nil 或无配置时默认开启）
        voice_wilson       = GetModConfigData("voice_wilson") ~= false,
        voice_wormwood     = GetModConfigData("voice_wormwood") ~= false,
        voice_warly        = GetModConfigData("voice_warly") ~= false,
        voice_woodie       = GetModConfigData("voice_woodie") ~= false,
        voice_wes          = GetModConfigData("voice_wes") ~= false,
        voice_winona       = GetModConfigData("voice_winona") ~= false,
        voice_wendy        = GetModConfigData("voice_wendy") ~= false,
        voice_wickerbottom = GetModConfigData("voice_wickerbottom") ~= false,
        voice_willow       = GetModConfigData("voice_willow") ~= false,
        voice_waxwell      = GetModConfigData("voice_waxwell") ~= false,
        voice_wathgrithr   = GetModConfigData("voice_wathgrithr") ~= false,
        voice_wolfgang     = GetModConfigData("voice_wolfgang") ~= false,
        voice_walter       = GetModConfigData("voice_walter") ~= false,
        voice_wortox       = GetModConfigData("voice_wortox") ~= false,
        voice_wanda        = GetModConfigData("voice_wanda") ~= false,
        voice_webber       = GetModConfigData("voice_webber") ~= false,
        voice_wurt         = GetModConfigData("voice_wurt") ~= false,
        voice_wx78         = GetModConfigData("voice_wx78") ~= false,
        voice_wonkey       = GetModConfigData("voice_wonkey") ~= false,
        voice_wilba        = GetModConfigData("voice_wilba") ~= false,
    }
end

return CreateConfig
