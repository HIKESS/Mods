-- scripts/npc/characters/wathgrithr.lua
-- Wathgrithr: 战斗特化 + 只吃肉 + 吸血 + 战斗战歌
-- 数据特化（damage_mult/absorption/lifesteal/inventory_slots）由 npc_tuning 驱动
-- 此文件处理需要代码逻辑的特化：
-- 1) 肉食饮食限制
-- 2) 进入战斗后自动战歌（10秒续时，脱战倒计时），对周围友方玩家/NPC生效
--    并排除敌对 NPC

local NPC_SPEECH = require("npc_speech")
local NPC_TUNING = require("npc_tuning")
local npc_affinity = require("npc/npc_affinity")

local SONG_BUFF_PREFAB = "battlesong_healthgain_buff"
local SONG_SOUND = "dontstarve_DLC001/characters/wathgrithr/song/healthgain"
local SING_SOUND = "dontstarve_DLC001/characters/wathgrithr/sing"
local SONG_SOUND_HANDLE = "npc_wathgrithr_song"
local SING_SOUND_HANDLE = "npc_wathgrithr_sing"

local function IsValidSongTarget(ent)
    if ent == nil or not ent:IsValid() then return false end
    if ent:HasTag("INLIMBO") or ent:HasTag("playerghost") then return false end
    if ent.components.health ~= nil and ent.components.health:IsDead() then return false end
    if ent:HasTag("npc_hostile") then return false end
    return true
end

local function IsInCombatNow(inst)
    if inst == nil or not inst:IsValid() then return false end
    if inst._is_ghost_mode then return false end
    if inst.components.combat == nil then return false end
    if inst.components.combat.target ~= nil then
        return true
    end
    local now = GetTime()
    local grace = NPC_TUNING.WATHGRITHR_BATTLESONG_COMBAT_GRACE or 2
    return inst._wathgrithr_last_combat_time ~= nil and (now - inst._wathgrithr_last_combat_time) <= grace
end

local function ForcePlaySongAnim(inst)
    if inst == nil or not inst:IsValid() or inst._is_ghost_mode then return end
    if inst.sg == nil then return end
    inst.sg:GoToState("emote", { anim = "sing" })
end

local function RefreshNearbySongBuff(inst)
    local radius = NPC_TUNING.WATHGRITHR_BATTLESONG_RADIUS or 12
    local x, y, z = inst.Transform:GetWorldPosition()

    local players = FindPlayersInRange(x, y, z, radius, true)
    for _, p in ipairs(players) do
        if IsValidSongTarget(p) then
            p:AddDebuff(SONG_BUFF_PREFAB, SONG_BUFF_PREFAB)
        end
    end

    local npcs = TheSim:FindEntities(x, y, z, radius, { "npcfriend" }, { "INLIMBO", "playerghost", "npc_hostile" })
    for _, n in ipairs(npcs) do
        if IsValidSongTarget(n) then
            n:AddDebuff(SONG_BUFF_PREFAB, SONG_BUFF_PREFAB)
        end
    end
end

local function StopBattleSong(inst)
    if inst == nil or not inst:IsValid() then return end
    inst._wathgrithr_song_active = false
    inst._wathgrithr_song_expire_time = nil
    if inst.SoundEmitter ~= nil then
        inst.SoundEmitter:KillSound(SONG_SOUND_HANDLE)
        inst.SoundEmitter:KillSound(SING_SOUND_HANDLE)
    end
end

local function StartBattleSong(inst)
    if inst == nil or not inst:IsValid() or inst._is_ghost_mode then return end

    local duration = NPC_TUNING.WATHGRITHR_BATTLESONG_DURATION or 10
    inst._wathgrithr_song_active = true
    inst._wathgrithr_song_expire_time = GetTime() + duration

    -- 战斗开始时强制播放唱歌动画 + 唱歌音效
    ForcePlaySongAnim(inst)
    if inst.SoundEmitter ~= nil then
        inst.SoundEmitter:KillSound(SONG_SOUND_HANDLE)
        inst.SoundEmitter:KillSound(SING_SOUND_HANDLE)
        inst.SoundEmitter:PlaySound(SING_SOUND, SING_SOUND_HANDLE)
        inst.SoundEmitter:PlaySound(SONG_SOUND, SONG_SOUND_HANDLE)
    end

    -- 立即给一轮 buff，避免等下一次 tick
    RefreshNearbySongBuff(inst)
end

local function EnsureBattleSongController(inst)
    if inst._wathgrithr_song_controller_inited then
        return
    end
    inst._wathgrithr_song_controller_inited = true

    -- 唱歌动画覆盖包（动作名含 sing/sing_pre）
    if inst.AnimState ~= nil then
        inst.AnimState:AddOverrideBuild("wathgrithr_sing")
    end

    inst._wathgrithr_last_combat_time = nil
    inst._wathgrithr_song_active = false
    inst._wathgrithr_song_expire_time = nil

    inst._wathgrithr_mark_combat_fn = function(i)
        i._wathgrithr_last_combat_time = GetTime()
    end
    inst:ListenForEvent("onattackother", inst._wathgrithr_mark_combat_fn)
    inst:ListenForEvent("attacked", inst._wathgrithr_mark_combat_fn)
    inst:ListenForEvent("newcombattarget", inst._wathgrithr_mark_combat_fn)

    inst._wathgrithr_song_task = inst:DoPeriodicTask(0.25, function(i)
        if not i:IsValid() then return end
        if i._is_ghost_mode then
            StopBattleSong(i)
            return
        end
        if i.npc_character_type ~= "wathgrithr" then
            StopBattleSong(i)
            return
        end

        local now = GetTime()
        local duration = NPC_TUNING.WATHGRITHR_BATTLESONG_DURATION or 10
        local in_combat = IsInCombatNow(i)

        if in_combat and npc_affinity.MeetsThreshold(i, "battle_song") then
            if not i._wathgrithr_song_active then
                StartBattleSong(i)
            else
                -- 战斗中持续刷新 10 秒倒计时
                i._wathgrithr_song_expire_time = now + duration
            end
        end

        if i._wathgrithr_song_active then
            -- 战歌运行中，周期刷新附近友方目标的吸血 buff
            local period = NPC_TUNING.WATHGRITHR_BATTLESONG_REFRESH_PERIOD or 0.5
            if i._wathgrithr_song_last_buff_time == nil
                or (now - i._wathgrithr_song_last_buff_time) >= period then
                i._wathgrithr_song_last_buff_time = now
                RefreshNearbySongBuff(i)
            end

            if i._wathgrithr_song_expire_time ~= nil and now >= i._wathgrithr_song_expire_time then
                StopBattleSong(i)
            end
        end
    end)

    inst:ListenForEvent("death", function(i)
        StopBattleSong(i)
    end)

    inst:ListenForEvent("onremove", function(i)
        StopBattleSong(i)
        if i._wathgrithr_song_task ~= nil then
            i._wathgrithr_song_task:Cancel()
            i._wathgrithr_song_task = nil
        end
    end)
end

return {
    -- 角色属性应用后的额外初始化
    on_apply = function(inst, stats)
        -- _diet_wrapper_applied 防止 OnLoad 二次调用 SetAppearance 时重复包装 Eat 方法
        if stats.diet == "MEAT" and inst.components.eater and not inst._diet_wrapper_applied then
            inst._diet_wrapper_applied = true
            -- caneat 决定客户端右键 FEED 提示标签；preferseating 决定服务端真正接受什么
            -- 女武神仍只接受肉 + NPC 专属成长糖；普通蔬菜/料理会被下面的 Eat 包装拒绝
            if FOODTYPE.NPCFRIENDS_ONLY == nil then
                FOODTYPE.NPCFRIENDS_ONLY = "NPCFRIENDS_ONLY"
            end
            inst.components.eater:SetDiet(
                { FOODGROUP.OMNI, FOODTYPE.NPCFRIENDS_ONLY },
                { FOODTYPE.MEAT, FOODTYPE.NPCFRIENDS_ONLY }
            )
            inst.components.eater:SetCanEatRawMeat(true)
            inst.components.eater:SetStrongStomach(true)
            local _orig_eat = inst.components.eater.Eat
            inst.components.eater.Eat = function(self, food, feeder)
                if food and not self:PrefersToEat(food) then
                    -- 拒绝台词
                    if inst.components.talker and NPC_SPEECH.REFUSE_FOOD then
                        local lines = NPC_SPEECH.REFUSE_FOOD
                        inst.components.talker:Say(lines[math.random(#lines)])
                    end
                    -- 拒绝动画（摇头）
                    if inst.sg and not inst._is_ghost_mode then
                        inst.sg:GoToState("refuseeat")
                    end
                    return nil  -- 不吃，食物留在玩家手中
                end
                return _orig_eat(self, food, feeder)
            end
        end

        -- 战斗战歌控制（只初始化一次）
        EnsureBattleSongController(inst)
    end,
}
