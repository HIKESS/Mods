require("stategraphs/commonstates")

local function TrySplashFX(inst, size)
    local x, y, z = inst.Transform:GetWorldPosition()
    if TheWorld.Map:IsOceanAtPoint(x, 0, z) then
        SpawnPrefab("ocean_splash_"..(size or "med")..tostring(math.random(2))).Transform:SetPosition(x, 0, z)
        return true
    end
end

local function TryStepSplash(inst)
    local t = GetTime()
    if (inst.sg.mem.laststepsplash == nil or inst.sg.mem.laststepsplash + .1 < t) and TrySplashFX(inst) then
        inst.sg.mem.laststepsplash = t
    end
end

local function DoSound(inst, sound)
    inst.SoundEmitter:PlaySound(sound)
end

local function DoEmoteFX(inst, prefab)
    local fx = SpawnPrefab(prefab)
    if fx ~= nil then
        if inst.components.rider:IsRiding() then
            fx.Transform:SetSixFaced()
        end
        fx.entity:SetParent(inst.entity)
        fx.entity:AddFollower()
        fx.Follower:FollowSymbol(inst.GUID, "emotefx", 0, 0, 0)
    end
end

local function GetUnequipState(inst, data)
    return (inst:HasTag("wereplayer") and "item_in")
        or (data.eslot ~= EQUIPSLOTS.HANDS and "item_hat")
        or (not data.slip and "item_in")
        or (data.item ~= nil and data.item:IsValid() and "tool_slip")
        or "toolbroke"
        , data.item
end

local function LeaderWork(inst, tag)
    local leader = inst.components.follower.leader
    --return leader ~= nil and leader.sg ~= nil and leader.sg:HasStateTag(tag) 
    return true
end

local actionhandlers =
{    
    ActionHandler(ACTIONS.CHOP, function(inst)
        if not inst.sg:HasStateTag("prechop") and inst.components.inventory:EquipHasTag("CHOP_tool")
        and LeaderWork(inst, "chopping") then
            return inst.sg:HasStateTag("chopping") and "chop" or "chop_start"                            
        end
    end),

    ActionHandler(ACTIONS.MINE, function(inst)  
        if not inst.sg:HasStateTag("premine") and inst.components.inventory:EquipHasTag("MINE_tool")
        and LeaderWork(inst, "mining") == true then 
            return inst.sg:HasStateTag("mining") and "mine" or "mine_start"                                    
        end
    end),

    ActionHandler(ACTIONS.DIG,
        function(inst)
        if not inst.sg:HasStateTag("predig") and inst.components.inventory:EquipHasTag("DIG_tool") then
            return inst.sg:HasStateTag("digging") and "dig" or "dig_start"                                        
        end
    end), 
}

local events =
{
    CommonHandlers.OnLocomote(true, false),
    CommonHandlers.OnAttacked(),
    CommonHandlers.OnDeath(),
   -- CommonHandlers.OnAttack(),

    EventHandler("doattack", function(inst)   --可以进行普通攻击时，收到这个事件
        if not inst.sg:HasStateTag("busy") and inst.components.health ~= nil and not inst.components.health:IsDead() then 
            local weapon = inst.components.combat ~= nil and inst.components.combat:GetWeapon() or nil
            if weapon and (weapon:HasTag("blowdart") or weapon:HasTag("blowpipe")) then
            inst.sg:GoToState("blowdart", inst.components.combat.target)
            else    
            inst.sg:GoToState("attack", inst.components.combat.target)
            end              
        end
    end),

    EventHandler("emote", function(inst, data)
        if not (inst.sg:HasStateTag("busy") or
            inst.sg:HasStateTag("nopredict") or
            inst.sg:HasStateTag("sleeping")) then
            inst.sg:GoToState("emote", data)
        end
    end),

    EventHandler("equip", function(inst, data)
        if inst.sg:HasStateTag("acting") then
            return
        end
        if (inst.sg:HasStateTag("idle") or inst.sg:HasStateTag("channeling")) and not inst:HasTag("wereplayer") then
            inst.sg:GoToState((data.eslot == EQUIPSLOTS.HANDS and "item_out") or "item_hat")
                
        elseif data.item ~= nil and data.item.projectileowner ~= nil then
            SpawnPrefab("lucy_transform_fx").entity:AddFollower():FollowSymbol(inst.GUID, "swap_object", 50, -25, 0)
        end
    end),

    EventHandler("unequip", function(inst, data)
        if inst.sg:HasStateTag("acting") then
            return
        end
        if inst.sg:HasStateTag("idle") or inst.sg:HasStateTag("channeling") then
            inst.sg:GoToState(GetUnequipState(inst, data))
        end
    end),
}

local states =
{
    State{
        name = "funnyidle",
        tags = {"idle", "canrotate"},

        onenter = function(inst, pushanim)
            inst.Physics:Stop() 
            inst.AnimState:PlayAnimation("idle_loop", true)   
        end,
    },

    State{
        name = "spawn",
        tags = { "busy", "noattack", "temp_invincible" },

        onenter = function(inst, mult)
            inst.Physics:Stop()
            inst.AnimState:PlayAnimation("minion_spawn")
            mult = mult or .8 + math.random() * .2

            mult = 1 / mult
            inst.sg.statemem.tasks =

            {
                inst:DoTaskInTime(0 * FRAMES * mult, DoSound, "maxwell_rework/shadow_worker/spawn"),
                inst:DoTaskInTime(0 * FRAMES * mult, TrySplashFX),
                inst:DoTaskInTime(20 * FRAMES * mult, TrySplashFX),
                inst:DoTaskInTime(44 * FRAMES * mult, TrySplashFX, "small"),
            }
            inst.sg:SetTimeout(70 * FRAMES * mult)
        end,

        ontimeout = function(inst)
            inst.sg:AddStateTag("caninterrupt")
        end,

        events =
        {
            EventHandler("animover", function(inst)
                if inst.AnimState:AnimDone() then
                    inst.sg:GoToState("idle")
                end
            end),
        },

        onexit = function(inst)
            if not inst.sg.statemem.spawn then
                inst.AnimState:SetDeltaTimeMultiplier(1)
            end
            for i, v in ipairs(inst.sg.statemem.tasks) do
                v:Cancel()
            end
        end,
    },

    State{
        name = "doshortaction",
        tags = { "doing", "busy", "nodangle" },

        onenter = function(inst)
            inst.sg:SetTimeout(0.35)
            inst.components.locomotor:Stop()
            inst.AnimState:PlayAnimation("pickup")
            inst.AnimState:PushAnimation("pickup_pst", false)
        end,

        timeline =
        {
            TimeEvent(4 * FRAMES, function(inst)
                inst.sg:RemoveStateTag("busy")
            end),

            TimeEvent(6 * FRAMES, function(inst)
                inst:PerformBufferedAction()
            end),          
        },

        events =
        {
            EventHandler("animqueueover", function(inst)
                if inst.AnimState:AnimDone() then
                    inst.sg:GoToState("idle")
                end
            end),
        },
    },

    State{
        name = "dolongaction",
        tags = { "doing", "busy", "nodangle" },

        onenter = function(inst)
            inst.sg:SetTimeout(1)
            inst.components.locomotor:Stop()
            inst.SoundEmitter:PlaySound("dontstarve/wilson/make_trap", "make")
            inst.AnimState:PlayAnimation("build_pre")
            inst.AnimState:PushAnimation("build_loop", true)
        end,

        timeline =
        {
            TimeEvent(4 * FRAMES, function(inst)
                inst.sg:RemoveStateTag("busy")
            end),
        },

        ontimeout = function(inst)
            inst.SoundEmitter:KillSound("make")
            inst.AnimState:PlayAnimation("build_pst")
            inst:PerformBufferedAction()
        end,

        events =
        {
            EventHandler("animqueueover", function(inst)
                if inst.AnimState:AnimDone() then
                    inst.sg:GoToState("idle")
                end
            end),
        },

        onexit = function(inst)
            inst.SoundEmitter:KillSound("make")
            inst:ClearBufferedAction()
        end,
    },

    State{
        name = "item_hat",
        tags = { "idle", "keepchannelcasting" },

        onenter = function(inst)
            inst:ClearBufferedAction()
            inst.components.locomotor:StopMoving()
            inst.AnimState:PlayAnimation("item_hat")
        end,

        events =
        {
            EventHandler("animover", function(inst)
                if inst.AnimState:AnimDone() then
                    inst.sg:GoToState("idle")
                end
            end),
        },
    },

    State{
        name = "item_in", 
        tags = { "idle", "nodangle", "keepchannelcasting" },

        onenter = function(inst)
            inst:ClearBufferedAction()
            inst.components.locomotor:StopMoving()
            inst.AnimState:PlayAnimation("item_in")
        end,

        events =
        {
            EventHandler("animover", function(inst)
                if inst.AnimState:AnimDone() then
                    inst.sg:GoToState("idle")
                end
            end),
        },

        onexit = function(inst)
            if inst.sg.statemem.followfx ~= nil then
                for i, v in ipairs(inst.sg.statemem.followfx) do
                    v:Remove()
                end
            end
        end,
    },

    State{
        name = "item_out",
        tags = { "idle", "nodangle", "keepchannelcasting" },

        onenter = function(inst)
            inst.components.locomotor:StopMoving()
            inst.AnimState:PlayAnimation("item_out")
        end,

        events =
        {
            EventHandler("animover", function(inst)
                if inst.AnimState:AnimDone() then
                    inst.sg:GoToState("idle")
                end
            end),
        },
    },

    State{
        name = "chop_start",
        tags = { "prechop", "working" },

        onenter = function(inst)
            inst.components.locomotor:Stop()
            inst.AnimState:PlayAnimation("chop_pre")
            inst:AddTag("prechop")
        end,

        events =
        {
            EventHandler("unequip", function(inst) inst.sg:GoToState("idle") end),
            EventHandler("animover", function(inst)
                if inst.AnimState:AnimDone() then
                    inst.sg.statemem.chopping = true
                    inst.sg:GoToState("chop")
                end
            end),
        },

        onexit = function(inst)
            if not inst.sg.statemem.chopping then
                inst:RemoveTag("prechop")
            end
        end,
    },

    State{
        name = "chop",
        tags = { "prechop", "chopping", "working" },

        onenter = function(inst)
            inst.sg.statemem.action = inst:GetBufferedAction()
            inst.sg.statemem.iswoodcutter = inst:HasTag("woodcutter")
            inst.AnimState:PlayAnimation(inst.sg.statemem.iswoodcutter and "woodie_chop_loop" or "chop_loop")
            inst:AddTag("prechop")
        end,

        timeline =
        {
            TimeEvent(2 * FRAMES, function(inst)
                if not inst.sg.statemem.iswoodcutter then
                    inst:PerformBufferedAction()
                end
            end),

            TimeEvent(9 * FRAMES, function(inst)
                if not inst.sg.statemem.iswoodcutter then
                    inst.sg:RemoveStateTag("prechop")
                    inst:RemoveTag("prechop")
                end
            end),

            TimeEvent(14 * FRAMES, function(inst)
                if not inst.sg.statemem.iswoodcutter and
                    inst.sg.statemem.action ~= nil and
                    inst.sg.statemem.action:IsValid() and
                    inst.sg.statemem.action.target ~= nil and
                    inst.sg.statemem.action.target.components.workable ~= nil and
                    inst.sg.statemem.action.target.components.workable:CanBeWorked() and
                    inst.sg.statemem.action.target:IsActionValid(inst.sg.statemem.action.action) then

                    local act = inst.sg.statemem.action
                    local target = inst.sg.statemem.action.target
                    local tool = inst.components.inventory:GetEquippedItem(EQUIPSLOTS.HANDS)

                    if tool ~= nil and target ~= nil and target:IsValid() and target.components.workable ~= nil and target.components.workable:CanBeWorked() then
                    target.components.workable:WorkedBy(inst,tool.components.tool:GetEffectiveness(act.action))
                    tool:OnUsedAsItem(act.action, inst, target)
                    end

                    inst.sg.statemem.action.options.no_predict_fastforward = true
                    inst:ClearBufferedAction()
                    inst:PushBufferedAction(inst.sg.statemem.action)
                end
            end),

            TimeEvent(16 * FRAMES, function(inst)
                inst.sg:RemoveStateTag("chopping")
            end),
        },

        events =
        {
            EventHandler("unequip", function(inst) inst.sg:GoToState("idle") end),
            EventHandler("animover", function(inst)
                if inst.AnimState:AnimDone() then
                    inst.sg:GoToState("idle")
                end
            end),
        },

        onexit = function(inst)
            inst:RemoveTag("prechop")
        end,
    },

    State{
        name = "mine_start",
        tags = {"premine", "working"},

        onenter = function(inst)
            local buffaction = inst:GetBufferedAction()
            inst.sg.statemem.target = buffaction ~= nil and buffaction.target or nil

            inst.Physics:Stop()
            inst.AnimState:PlayAnimation("pickaxe_pre")           
        end,

        events =
        {
            EventHandler("animover", function(inst)
                if inst.AnimState:AnimDone() then
                    inst.sg:GoToState("mine")
                end
            end),
        },
    },

    State{
        name = "mine_start",
        tags = { "premine", "working" },

        onenter = function(inst)
            inst.components.locomotor:Stop()
            inst.AnimState:PlayAnimation("pickaxe_pre")
            inst:AddTag("premine")
        end,

        events =
        {
            EventHandler("unequip", function(inst) inst.sg:GoToState("idle") end),
            EventHandler("animover", function(inst)
                if inst.AnimState:AnimDone() then
                    inst.sg.statemem.mining = true
                    inst.sg:GoToState("mine")
                end
            end),
        },

        onexit = function(inst)
            if not inst.sg.statemem.mining then
                inst:RemoveTag("premine")
            end
        end,
    },

    State{
        name = "mine",
        tags = { "premine", "mining", "working" },

        onenter = function(inst)
            inst.sg.statemem.action = inst:GetBufferedAction()
            inst.AnimState:PlayAnimation("pickaxe_loop")
            inst:AddTag("premine")
        end,

        timeline =
        {
            TimeEvent(7 * FRAMES, function(inst)
                if inst.sg.statemem.action ~= nil then
                    PlayMiningFX(inst, inst.sg.statemem.action.target)
                end
                inst.sg.statemem.recoilstate = "mine_recoil"
                inst:PerformBufferedAction()
            end),

            TimeEvent(9 * FRAMES, function(inst)
                inst.sg:RemoveStateTag("premine")
                inst:RemoveTag("premine")
            end),

            TimeEvent(14 * FRAMES, function(inst)
                if  inst.sg.statemem.action ~= nil and
                    inst.sg.statemem.action:IsValid() and
                    inst.sg.statemem.action.target ~= nil and
                    inst.sg.statemem.action.target.components.workable ~= nil and
                    inst.sg.statemem.action.target.components.workable:CanBeWorked() and
                    inst.sg.statemem.action.target:IsActionValid(inst.sg.statemem.action.action) then

                    local act = inst.sg.statemem.action
                    local target = inst.sg.statemem.action.target
                    local tool = inst.components.inventory:GetEquippedItem(EQUIPSLOTS.HANDS)

                    if tool ~= nil and target ~= nil and target:IsValid() and target.components.workable ~= nil and target.components.workable:CanBeWorked() then
                    target.components.workable:WorkedBy(inst,tool.components.tool:GetEffectiveness(act.action))
                    tool:OnUsedAsItem(act.action, inst, target)
                    end

                    inst.sg.statemem.action.options.no_predict_fastforward = true
                    inst:ClearBufferedAction()
                    inst:PushBufferedAction(inst.sg.statemem.action)
                end
            end),
        },

        events =
        {
            EventHandler("unequip", function(inst) inst.sg:GoToState("idle") end),
            EventHandler("animover", function(inst)
                if inst.AnimState:AnimDone() then
                    inst.AnimState:PlayAnimation("pickaxe_pst")
                    inst.sg:GoToState("idle", true)
                end
            end),
        },

        onexit = function(inst)
            inst:RemoveTag("premine")
        end,
    },

    State{
        name = "dig_start",
        tags = { "predig", "working" },

        onenter = function(inst)
            inst.components.locomotor:Stop()
            inst.AnimState:PlayAnimation("shovel_pre")
            inst:AddTag("predig")
        end,

        events =
        {
            EventHandler("unequip", function(inst) inst.sg:GoToState("idle") end),
            EventHandler("animover", function(inst)
                if inst.AnimState:AnimDone() then
                    inst.sg.statemem.digging = true
                    inst.sg:GoToState("dig")
                end
            end),
        },

        onexit = function(inst)
            if not inst.sg.statemem.digging then
                inst:RemoveTag("predig")
            end
        end,
    },

    State{
        name = "dig",
        tags = { "predig", "digging", "working" },

        onenter = function(inst)
            inst.AnimState:PlayAnimation("shovel_loop")
            inst.sg.statemem.action = inst:GetBufferedAction()
            inst:AddTag("predig")
        end,

        timeline =
        {
            TimeEvent(15 * FRAMES, function(inst)
                inst.sg:RemoveStateTag("predig")
                inst:RemoveTag("predig")
                inst.SoundEmitter:PlaySound("dontstarve/wilson/dig")
                inst:PerformBufferedAction()
            end),

            TimeEvent(35 * FRAMES, function(inst)
                if  inst.sg.statemem.action ~= nil and
                    inst.sg.statemem.action:IsValid() and
                    inst.sg.statemem.action.target ~= nil and
                    inst.sg.statemem.action.target.components.workable ~= nil and
                    inst.sg.statemem.action.target.components.workable:CanBeWorked() and
                    inst.sg.statemem.action.target:IsActionValid(inst.sg.statemem.action.action, true) then

                    local act = inst.sg.statemem.action
                    local target = inst.sg.statemem.action.target
                    local tool = inst.components.inventory:GetEquippedItem(EQUIPSLOTS.HANDS)

                    if tool ~= nil and target ~= nil and target:IsValid() and target.components.workable ~= nil and target.components.workable:CanBeWorked() then
                    target.components.workable:WorkedBy(inst,tool.components.tool:GetEffectiveness(act.action))
                    tool:OnUsedAsItem(act.action, inst, target)
                    end

                    inst.sg.statemem.action.options.no_predict_fastforward = true
                    inst:ClearBufferedAction()
                    inst:PushBufferedAction(inst.sg.statemem.action)
                end
            end),
        },

        events =
        {
            EventHandler("unequip", function(inst) inst.sg:GoToState("idle") end),
            EventHandler("animover", function(inst)
                if inst.AnimState:AnimDone() then
                    inst.AnimState:PlayAnimation("shovel_pst")
                    inst.sg:GoToState("idle", true)
                end
            end),
        },

        onexit = function(inst)
            inst:RemoveTag("predig")
        end,
    },

    State{
        name = "run_start",
        tags = {"moving", "running", "canrotate"},

        onenter = function(inst)
            inst.components.locomotor:RunForward()
            inst.AnimState:PlayAnimation("run_pre")            
        end,

        events =
        {
            EventHandler("animover", function(inst)
                if inst.AnimState:AnimDone() then
                    inst.sg:GoToState("run")
                end
            end),
        },
    },

    State{
        name = "run",
        tags = {"moving", "running", "canrotate"},

        onenter = function(inst)
            inst.components.locomotor:RunForward()
            inst.AnimState:PlayAnimation("run_loop", true)

            inst.sg:SetTimeout(inst.AnimState:GetCurrentAnimationLength())
        end,

        ontimeout = function(inst)
            inst.sg:GoToState("run")
        end,
    },

    State{
        name = "run_stop",
        tags = {"canrotate", "idle"},

        onenter = function(inst)
            inst.Physics:Stop()
            inst.AnimState:PlayAnimation("run_pst")               
        end,

        events =
        {
            EventHandler("animover", function(inst)
                if inst.AnimState:AnimDone() then
                    inst.sg:GoToState("idle")
                end
            end),
        },   
    },

    State{
        name = "blowdart",
        tags = { "attack", "notalking", "abouttoattack", "autopredict" },

        onenter = function(inst)
            if inst.components.combat:InCooldown() then
                inst.sg:RemoveStateTag("abouttoattack")
                inst:ClearBufferedAction()
                inst.sg:GoToState("idle", true)
                return
            end

            local buffaction = inst:GetBufferedAction()
            inst.sg.statemem.action = buffaction
            local target = inst.components.combat.target
            local equip = inst.components.inventory:GetEquippedItem(EQUIPSLOTS.HANDS)
            inst.components.combat:SetTarget(target)
            inst.components.combat:StartAttack()
            inst.components.locomotor:Stop()
            inst.AnimState:PlayAnimation("dart_pre")  --ThePlayer.AnimState:PlayAnimation("dart_pre").AnimState:PlayAnimation("dart")
            if inst.sg.laststate == inst.sg.currentstate then
                inst.sg.statemem.chained = true
                inst.AnimState:SetFrame(5)
            end
            inst.AnimState:PushAnimation("dart", false)

            inst.sg:SetTimeout(math.max((inst.sg.statemem.chained and 14 or 18) * FRAMES, inst.components.combat.min_attack_period))

            if target ~= nil and target:IsValid() then
                inst:FacePoint(target.Transform:GetWorldPosition())
                inst.sg.statemem.attacktarget = target
                inst.sg.statemem.retarget = target
            end

            if (equip ~= nil and equip.projectiledelay or 0) > 0 then
                inst.sg.statemem.projectiledelay = (inst.sg.statemem.chained and 9 or 14) * FRAMES - equip.projectiledelay
                if inst.sg.statemem.projectiledelay <= 0 then
                    inst.sg.statemem.projectiledelay = nil
                end
            end
        end,

        onupdate = function(inst, dt)
            if (inst.sg.statemem.projectiledelay or 0) > 0 then
                inst.sg.statemem.projectiledelay = inst.sg.statemem.projectiledelay - dt
                if inst.sg.statemem.projectiledelay <= 0 then
                    inst:PerformBufferedAction()
                    inst.sg:RemoveStateTag("abouttoattack")
                end
            end
        end,

        timeline =
        {
            TimeEvent(13 * FRAMES, function(inst)
                inst.SoundEmitter:PlaySound("dontstarve/wilson/blowdart_shoot", nil, nil, true)
            end),
            TimeEvent(14 * FRAMES, function(inst)
                if inst.sg.statemem.projectiledelay == nil then
                    local act = inst.sg.statemem.action
                    local target = inst.sg.statemem.attacktarget
                    local tool = inst.components.inventory:GetEquippedItem(EQUIPSLOTS.HANDS)

                    -- 只有当手上物品具备 tool 组件且存在有效 Action 时，才对可工作目标追加工作量，兼容无 tool 组件的武器
                    if tool ~= nil
                        and tool.components ~= nil
                        and tool.components.tool ~= nil
                        and act ~= nil
                        and act.action ~= nil
                        and target ~= nil
                        and target:IsValid()
                        and target.components ~= nil
                        and target.components.workable ~= nil
                        and target.components.workable:CanBeWorked() then
                        target.components.workable:WorkedBy(inst, tool.components.tool:GetEffectiveness(act.action))
                        if tool.OnUsedAsItem ~= nil then
                            tool:OnUsedAsItem(act.action, inst, target)
                        end
                    end

                    inst.components.combat:DoAttack(inst.sg.statemem.attacktarget)
                    inst.sg:RemoveStateTag("abouttoattack")
                end
            end),
        },

        ontimeout = function(inst)
            inst.sg:RemoveStateTag("attack")
            inst.sg:AddStateTag("idle")
        end,

        events =
        {
            EventHandler("equip", function(inst) inst.sg:GoToState("idle") end),
            EventHandler("unequip", function(inst) inst.sg:GoToState("idle") end),
            EventHandler("animqueueover", function(inst)
                if inst.AnimState:AnimDone() then
                    inst.sg:GoToState("idle")
                end
            end),
        },
--[[
        onexit = function(inst)
            inst.components.combat:SetTarget(nil)
            if inst.sg:HasStateTag("abouttoattack") then
                inst.components.combat:CancelAttack()
            end
        end,
]]        
    },

    State{
        name = "attack",
        tags = { "attack", "notalking", "abouttoattack", "autopredict" },

        onenter = function(inst)
            if inst.components.combat:InCooldown() then
                inst.sg:RemoveStateTag("abouttoattack")
                inst:ClearBufferedAction()
                inst.sg:GoToState("idle", true)
                return
            end

            if inst.sg.laststate == inst.sg.currentstate then
                inst.sg.statemem.chained = true
            end
            local buffaction = inst:GetBufferedAction()
            inst.sg.statemem.action = buffaction
            local target = inst.components.combat.target
            local equip = inst.components.inventory:GetEquippedItem(EQUIPSLOTS.HANDS)
            --inst.components.combat:SetTarget(target)
            inst.components.combat:StartAttack()
            inst.components.locomotor:Stop()
            local cooldown = inst.components.combat.min_attack_period
            if inst.prefab ~= "wiltonmod_pet" then

            elseif equip ~= nil and equip:HasTag("toolpunch") then
                inst.AnimState:PlayAnimation("toolpunch")
                inst.sg.statemem.istoolpunch = true
                inst.SoundEmitter:PlaySound("dontstarve/wilson/attack_whoosh", nil, inst.sg.statemem.attackvol, true)

                cooldown = math.max(cooldown, 13 * FRAMES)
            elseif equip ~= nil and equip:HasTag("whip") then
                inst.AnimState:PlayAnimation("whip_pre")
                inst.AnimState:PushAnimation("whip", false)
                inst.sg.statemem.iswhip = true
                inst.SoundEmitter:PlaySound("dontstarve/common/whip_pre", nil, nil, true)
                cooldown = math.max(cooldown, 17 * FRAMES)
            elseif equip ~= nil and equip:HasTag("pocketwatch") then
                inst.AnimState:PlayAnimation(inst.sg.statemem.chained and "pocketwatch_atk_pre_2" or "pocketwatch_atk_pre" )
                inst.AnimState:PushAnimation("pocketwatch_atk", false)
                inst.sg.statemem.ispocketwatch = true
                cooldown = math.max(cooldown, 15 * FRAMES)
                if equip:HasTag("shadow_item") then
                    inst.SoundEmitter:PlaySound("wanda2/characters/wanda/watch/weapon/pre_shadow", nil, nil, true)
                    inst.AnimState:Show("pocketwatch_weapon_fx")
                    inst.sg.statemem.ispocketwatch_fueled = true
                else
                    inst.SoundEmitter:PlaySound("wanda2/characters/wanda/watch/weapon/pre", nil, nil, true)
                    inst.AnimState:Hide("pocketwatch_weapon_fx")
                end
            elseif equip ~= nil and equip:HasTag("book") then
                inst.AnimState:PlayAnimation("attack_book")
                inst.sg.statemem.isbook = true
                inst.SoundEmitter:PlaySound("dontstarve/wilson/attack_whoosh", nil, nil, true)
                cooldown = math.max(cooldown, 19 * FRAMES)
            elseif equip ~= nil and equip:HasTag("chop_attack") and inst:HasTag("woodcutter") then
                inst.AnimState:PlayAnimation(inst.AnimState:IsCurrentAnimation("woodie_chop_loop") and inst.AnimState:GetCurrentAnimationFrame() <= 7 and "woodie_chop_atk_pre" or "woodie_chop_pre")
                inst.AnimState:PushAnimation("woodie_chop_loop", false)
                inst.sg.statemem.ischop = true
                cooldown = math.max(cooldown, 11 * FRAMES)
            elseif equip ~= nil and equip:HasTag("jab") then
                inst.AnimState:PlayAnimation("spearjab_pre")
                inst.AnimState:PushAnimation("spearjab", false)
                inst.SoundEmitter:PlaySound("dontstarve/wilson/attack_whoosh", nil, nil, true)
                cooldown = math.max(cooldown, 21 * FRAMES)
            elseif equip ~= nil and equip.components.weapon ~= nil and not equip:HasTag("punch") then
                inst.AnimState:PlayAnimation("atk_pre")
                inst.AnimState:PushAnimation("atk", false)
                if (equip.projectiledelay or 0) > 0 then
                    --V2C: Projectiles don't show in the initial delayed frames so that
                    --     when they do appear, they're already in front of the player.
                    --     Start the attack early to keep animation in sync.
                    inst.sg.statemem.projectiledelay = 8 * FRAMES - equip.projectiledelay
                    if inst.sg.statemem.projectiledelay > FRAMES then
                        inst.sg.statemem.projectilesound =
                            (equip:HasTag("icestaff") and "dontstarve/wilson/attack_icestaff") or
                            (equip:HasTag("firestaff") and "dontstarve/wilson/attack_firestaff") or
                            (equip:HasTag("firepen") and "wickerbottom_rework/firepen/launch") or
                            "dontstarve/wilson/attack_weapon"
                    elseif inst.sg.statemem.projectiledelay <= 0 then
                        inst.sg.statemem.projectiledelay = nil
                    end
                end
                if inst.sg.statemem.projectilesound == nil then
                    inst.SoundEmitter:PlaySound(
                        (equip:HasTag("icestaff") and "dontstarve/wilson/attack_icestaff") or
                        (equip:HasTag("shadow") and "dontstarve/wilson/attack_nightsword") or
                        (equip:HasTag("firestaff") and "dontstarve/wilson/attack_firestaff") or
                        (equip:HasTag("firepen") and "wickerbottom_rework/firepen/launch") or
                        "dontstarve/wilson/attack_weapon",
                        nil, nil, true
                    )
                end
                cooldown = math.max(cooldown, 13 * FRAMES)
            elseif equip ~= nil and (equip:HasTag("light") or equip:HasTag("nopunch")) then
                inst.AnimState:PlayAnimation("atk_pre")
                inst.AnimState:PushAnimation("atk", false)
                inst.SoundEmitter:PlaySound("dontstarve/wilson/attack_weapon", nil, nil, true)
                cooldown = math.max(cooldown, 13 * FRAMES)
            elseif inst:HasTag("beaver") then
                inst.sg.statemem.isbeaver = true
                inst.AnimState:PlayAnimation("atk_pre")
                inst.AnimState:PushAnimation("atk", false)
                inst.SoundEmitter:PlaySound("dontstarve/wilson/attack_whoosh", nil, nil, true)
                cooldown = math.max(cooldown, 13 * FRAMES)
            else
                inst.AnimState:PlayAnimation("punch")
                inst.SoundEmitter:PlaySound("dontstarve/wilson/attack_whoosh", nil, nil, true)
                cooldown = math.max(cooldown, 24 * FRAMES)
            end

            inst.sg:SetTimeout(cooldown)

            if target ~= nil then
                --inst.components.combat:BattleCry()
                if target:IsValid() then
                    inst:FacePoint(target:GetPosition())
                    inst.sg.statemem.attacktarget = target
                    inst.sg.statemem.retarget = target
                end
            end
        end,

        onupdate = function(inst, dt)
            if (inst.sg.statemem.projectiledelay or 0) > 0 then
                inst.sg.statemem.projectiledelay = inst.sg.statemem.projectiledelay - dt
                if inst.sg.statemem.projectiledelay <= FRAMES then
                    if inst.sg.statemem.projectilesound ~= nil then
                        inst.SoundEmitter:PlaySound(inst.sg.statemem.projectilesound, nil, nil, true)
                        inst.sg.statemem.projectilesound = nil
                    end
                    if inst.sg.statemem.projectiledelay <= 0 then
                        --inst:PerformBufferedAction()
                        inst.components.combat:DoAttack(inst.sg.statemem.attacktarget)
                        inst.sg:RemoveStateTag("abouttoattack")
                    end
                end
            end
        end,

        timeline =
        {
            TimeEvent(8 * FRAMES, function(inst)
                if not (inst.sg.statemem.isbeaver or
                        inst.sg.statemem.ismoose or
                        inst.sg.statemem.iswhip or
                        inst.sg.statemem.ispocketwatch or
                        inst.sg.statemem.isbook) and
                    inst.sg.statemem.projectiledelay == nil then
                    inst.components.combat:DoAttack(inst.sg.statemem.attacktarget)
                    inst.sg:RemoveStateTag("abouttoattack")
                end
            end),

            TimeEvent(10 * FRAMES, function(inst)
                if inst.sg.statemem.iswhip or inst.sg.statemem.isbook or inst.sg.statemem.ispocketwatch then
                    --inst:PerformBufferedAction()
                    inst.components.combat:DoAttack(inst.sg.statemem.attacktarget)
                    inst.sg:RemoveStateTag("abouttoattack")

                    local act = inst.sg.statemem.action
                    local target = inst.sg.statemem.attacktarget
                    local tool = inst.components.inventory:GetEquippedItem(EQUIPSLOTS.HANDS)

                    -- 兼容其他模组武器：只有当武器具有 tool 组件且存在有效 Action 与 workable 目标时，才尝试追加工作量
                    if tool ~= nil
                        and tool.components ~= nil
                        and tool.components.tool ~= nil
                        and act ~= nil
                        and act.action ~= nil
                        and target ~= nil
                        and target:IsValid()
                        and target.components ~= nil
                        and target.components.workable ~= nil
                        and target.components.workable:CanBeWorked() then
                        target.components.workable:WorkedBy(inst, tool.components.tool:GetEffectiveness(act.action))
                        if tool.OnUsedAsItem ~= nil then
                            tool:OnUsedAsItem(act.action, inst, target)
                        end
                    end
                end
            end),
        },

        ontimeout = function(inst)
            inst.sg:RemoveStateTag("attack")
            inst.sg:AddStateTag("idle")
        end,

        events =
        {
            EventHandler("equip", function(inst) inst.sg:GoToState("idle") end),
            EventHandler("unequip", function(inst) inst.sg:GoToState("idle") end),
            EventHandler("animqueueover", function(inst)
                if inst.AnimState:AnimDone() then
                    inst.sg:GoToState("idle")
                end
            end),
        },
--[[
        onexit = function(inst)
            inst.components.combat:SetTarget(nil)
            if inst.sg:HasStateTag("abouttoattack") then
                inst.components.combat:CancelAttack()
            end
        end,
]]        
    },

    State{
        name = "death",
        tags = {"busy"},

        onenter = function(inst)
            inst.Physics:Stop()
            inst.AnimState:Hide("swap_arm_carry")
            inst.AnimState:PlayAnimation("death")
        end,

        events =
        {
            EventHandler("animover", function(inst)
                if inst.AnimState:AnimDone() then
                    inst.components.lootdropper:DropLoot()

                    local x, y, z = inst.Transform:GetWorldPosition()
                    SpawnPrefab("shadow_despawn").Transform:SetPosition(x, y, z)
                    SpawnPrefab("statue_transition_2").Transform:SetPosition(x, y, z)
                    inst:Remove()
                end
            end),
        },
    },

    State{
        name = "hit",
        tags = {"busy"},

        onenter = function(inst)
            inst:ClearBufferedAction()
            inst.AnimState:PlayAnimation("hit")
            inst.Physics:Stop()
        end,

        events =
        {
            EventHandler("animover", function(inst)
                if inst.AnimState:AnimDone() then
                    inst.sg:GoToState("idle")
                end
            end),
        },

        timeline =
        {
            TimeEvent(3*FRAMES, function(inst)
                inst.sg:RemoveStateTag("busy")
            end),
        },
    },

    State{
        name = "emote",
        tags = { "busy", "pausepredict", "emote" },

        onenter = function(inst, data)
            inst.components.locomotor:Stop()

            local dancedata = nil
            if data.tags ~= nil then
                for i, v in ipairs(data.tags) do
                    inst.sg:AddStateTag(v)
                    if v == "dancing" then
                        dancedata = dancedata or {}
                        TheWorld:PushEvent("dancingplayer", inst)
                        local hat = inst.components.inventory:GetEquippedItem(EQUIPSLOTS.HEAD)
                        if hat ~= nil and hat.OnStartDancing ~= nil then
                            local newdata = hat:OnStartDancing(inst, data)
                            if newdata ~= nil then
                                inst.sg.statemem.dancinghat = hat
                                data = newdata
                            end
                        end
                    end
                end
                if inst.sg.statemem.dancinghat ~= nil and data.tags ~= nil then
                    for i, v in ipairs(data.tags) do
                        if not inst.sg:HasStateTag(v) then
                            inst.sg:AddStateTag(v)
                        end
                    end
                end
            end

            local anim = data.anim
            local animtype = type(anim)
            if data.randomanim and animtype == "table" then
                anim = anim[math.random(#anim)]
                animtype = type(anim)
            end
            if animtype == "table" and #anim <= 1 then
                anim = anim[1]
                animtype = type(anim)
            end

            if animtype == "string" then
                inst.AnimState:PlayAnimation(anim, data.loop)
                if dancedata ~= nil then
                    table.insert(dancedata, {play = true, anim = anim, loop = data.loop,})
                end
            elseif animtype == "table" then
                local maxanim = #anim
                inst.AnimState:PlayAnimation(anim[1])
                for i = 2, maxanim - 1 do
                    inst.AnimState:PushAnimation(anim[i])
                end
                inst.AnimState:PushAnimation(anim[maxanim], data.loop == true)

                if dancedata ~= nil then
                    table.insert(dancedata, {play = true, anim = anim[1]})
                    for i = 2, maxanim - 1 do
                        table.insert(dancedata, {anim = anim[i]})
                    end
                    table.insert(dancedata, {anim = anim[maxanim], loop = data.loop == true,})
                end
            end
            if dancedata ~= nil then
                TheWorld:PushEvent("dancingplayerdata", {inst = inst, dancedata = dancedata,})
            end
        end,

        timeline =
        {
            TimeEvent(.5, function(inst)
                inst.sg:RemoveStateTag("busy")
                inst.sg:RemoveStateTag("pausepredict")
            end),
        },

        events =
        {
            EventHandler("animqueueover", function(inst)
                if inst.AnimState:AnimDone() then
                    inst.sg:GoToState("idle")
                end
            end),
        },

        onexit = function(inst)
            if inst.sg.statemem.emotefxtask ~= nil then
                inst.sg.statemem.emotefxtask:Cancel()
                inst.sg.statemem.emotefxtask = nil
            end
            if inst.SoundEmitter:PlayingSound("emotesoundloop") then
                inst.SoundEmitter:KillSound("emotesoundloop")
            end
            if inst.sg.statemem.dancinghat ~= nil and
                inst.sg.statemem.dancinghat == inst.components.inventory:GetEquippedItem(EQUIPSLOTS.HEAD) and
                inst.sg.statemem.dancinghat.OnStopDancing ~= nil then
                inst.sg.statemem.dancinghat:OnStopDancing(inst)
            end
        end,
    },   
}

CommonStates.AddIdle(states,"funnyidle")

return StateGraph("wiltonmod_pet", states, events, "idle", actionhandlers)
