
local EMOTE_TYPE = {
    EMOTION = 0,
    ACTION = 1,
    UNLOCKABLE = 2,
}

local MY_EMOTES = {
    ["yeah"] = {
        aliases = { "yay", "woo" },
        data = {
            anim = "gwen_shear",
            sitting = false,
            mounted = false,
            fx = false,
            sound = "gw_emote/emote/waou"
        },
        type = EMOTE_TYPE.EMOTION,
    },

    ["gwen_dance"] = {
        aliases = { "gw_dance" },
        data = {
            anim =  { "gwen_dance_pre", "gwen_dance_loop"} ,
            sitting = false,
            mounted = false,
            fx = false,
            loop = true,
            sound = "gw_emote/emote/tiaowu",
            soundlooped = true,
        },
        type = EMOTE_TYPE.ACTION,
    },
}

local function CreateEmoteCommand(emotedef)
    return {
        aliases = emotedef.aliases,
        prettyname = function(command)
            return tostring(command.name) .. " (Emote)"
        end,
        desc = function() return "Perform a custom emote." end,
        permission = COMMAND_PERMISSION.USER,
        params = {},
        emote = true,
        slash = true,
        usermenu = false,
        servermenu = false,
        vote = false,
        serverfn = function(params, caller)
            local player = UserToPlayer(caller.userid)
            if player ~= nil then
                player:PushEvent("emote", emotedef.data)
            end
        end,
        displayname = emotedef.displayname
    }
end

-- 注册命令
for cmd_name, cmd_def in pairs(MY_EMOTES) do
    AddUserCommand(cmd_name, CreateEmoteCommand(cmd_def))
end