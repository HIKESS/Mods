GLOBAL.setmetatable(env, {__index = function(t, k) return GLOBAL.rawget(GLOBAL, k) end})
-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
---- 以下为大部分生物添加击退效果，相关代码抄自不死鸟传说的处理，但是更改了部分逻辑

-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- 这个函数用来处理参数可能是函数的情况
local function FunctionOrValue(param, inst, ...)
    if type(param) == "function" then
        return param(inst, ...)
    end
    return param
end

-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- 击退的时候移除掉冰冻效果
local function ClearStatusAilments(inst)
    if inst.components.freezable ~= nil and inst.components.freezable:IsFrozen() then
        inst.components.freezable:Unfreeze()
    end
    if inst.components.pinnable ~= nil and inst.components.pinnable:IsStuck() then
        inst.components.pinnable:Unstick()
    end
end
-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- 击退时的状态图
local BriarRepelAddRepelSG = function(sgname, add_data)
    add_data = add_data or {}

    local repel_sg = State {
        name = "repel",
        tags = { "busy", "nomorph", "nodangle" },

        onenter = function(inst, data)
            inst:StopBrain()
            ClearStatusAilments(inst)
            if inst.components.rider then
                inst.components.rider:ActualDismount()
            end
            inst.Physics:Stop()
            inst.components.locomotor:Stop()
            inst:ClearBufferedAction()

            if data and data.knocker then
                inst.sg.statemem.knocker = data.knocker
            end

            if data and data.knocker then
                inst.sg.statemem.knocker = data.knocker
            end

            if data and data.is_gwen_repel then
                inst.sg.statemem.is_gwen_repel = data.is_gwen_repel
            else
                inst.sg.statemem.is_gwen_repel = false
            end


            if not data.is_dead then
                inst.AnimState:PlayAnimation(FunctionOrValue(
                        add_data.repel_anim, inst) or "hit")
            end

            if data ~= nil then
                if data.radius ~= nil and data.knocker ~= nil and
                    data.knocker:IsValid() then
                    local x, y, z = data.knocker.Transform:GetWorldPosition()
                    local distsq = inst:GetDistanceSqToPoint(x, y, z)
                    local rangesq = data.radius * data.radius
                    local rot = inst.Transform:GetRotation()
                    local rot1 = distsq > 0 and inst:GetAngleToPoint(x, y, z) or
                        data.knocker.Transform:GetRotation() + 180
                    local drot = math.abs(rot - rot1)
                    while drot > 180 do
                        drot = math.abs(drot - 360)
                    end
                    local k = distsq < rangesq and .3 * distsq / rangesq - 1 or -.7

                    inst.sg.statemem.speed =
                        (FunctionOrValue(data.strengthmult or 1) * 20) * k * (add_data.resist_mult or 1)
                    inst.sg.statemem.dspeed =
                        FunctionOrValue(add_data.dspeed, inst) or 0


                    inst.sg.statemem.hspeed = (data.strengthmult or 1) * 8
                    inst.sg.statemem.dhspeed = -1.5


                    if drot > 90 then
                        inst.sg.statemem.reverse = true
                        inst.Transform:SetRotation(rot1 + 180)
                        inst.Physics:SetMotorVel(-inst.sg.statemem.speed, inst.sg.statemem.hspeed, 0)
                    else
                        inst.Transform:SetRotation(rot1)
                        inst.Physics:SetMotorVel(inst.sg.statemem.speed, inst.sg.statemem.hspeed, 0)
                    end
                end
            end
        end,

        onupdate = function(inst)
            if inst.sg.statemem.speed ~= nil and not inst.sg.statemem.stopped then
                inst.sg.statemem.speed =
                    inst.sg.statemem.speed + inst.sg.statemem.dspeed


                if inst.sg.statemem.speed < 0 then
                    inst.sg.statemem.dspeed =
                        inst.sg.statemem.dspeed +
                        (FunctionOrValue(add_data.vec_acc, inst) or 0.075)
                else
                    inst.sg.statemem.speed = 0
                end

                inst.sg.statemem.hspeed = inst.sg.statemem.hspeed + inst.sg.statemem.dhspeed

                inst.Physics:SetMotorVel(
                    inst.sg.statemem.reverse and -inst.sg.statemem.speed or inst.sg.statemem.speed,
                    inst.sg.statemem.hspeed,
                    0
                )

                local x, y, z = inst.Transform:GetWorldPosition()
                if y <= 0.1 and inst.sg.statemem.hspeed <= -0.5 and not inst.sg.statemem.landed then
                    inst.sg.statemem.landed = true
                    inst.sg.statemem.hspeed = -0.5
                    if inst.AnimState:AnimDone() and
                        not inst.components.health:IsDead() then
                        inst.Transform:SetPosition(x, 0, z)
                        inst.sg:GoToState("idle")
                    end
                end

                if math.abs(inst.sg.statemem.speed or 0) <= 0.1 then
                    inst.sg.statemem.stopped = true
                    inst.Physics:Stop()
                    if not inst.components.health:IsDead() then
                        inst.sg:GoToState("idle")
                    end
                end
            end
        end,

        timeline = {
            TimeEvent(8 * FRAMES, function(inst)
                inst.SoundEmitter:PlaySound("dontstarve/movement/bodyfall_dirt")
            end)
        },

        events = {
            EventHandler("animover", function(inst)
                if inst.AnimState:AnimDone() then
                    if not inst.components.health:IsDead() then
                        inst.sg:GoToState("idle")
                    end
                end
            end)
        },

        onexit = function(inst)
            SpawnAt("dirt_puff", inst)
            local knocker = inst.sg.statemem.knocker
            if knocker and knocker:IsValid() and inst.components.health and not inst.components.health:IsDead() then
                local max_hp = inst.components.health.maxhealth
                local damage = max_hp * 0.05
                if not inst.sg.statemem.is_gwen_repel then
                    if inst.components.health and not inst.components.health:IsDead() then
                        inst.components.combat:GetAttacked(knocker, 100, nil, nil, {planar = damage})
                    end
                end
            end

            if inst.sg.statemem.speed ~= nil then
                inst.Physics:Stop()
            end
            inst:RestartBrain()
            inst.sg.statemem.should_return_to_stun = nil
            inst.SoundEmitter:PlaySound("dontstarve/movement/bodyfall_dirt")
        end
    }
    AddStategraphState(sgname, repel_sg)

    AddStategraphEvent(sgname, EventHandler("repel", function(inst, data)
        data.is_dead = inst.components.health:IsDead()
        if data.is_dead and add_data.dont_repel_ondeath then return end

        inst.sg:GoToState("repel", data)
    end))
end


-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
---- 给下列生物添加击退
BriarRepelAddRepelSG("spider", {  vec_acc = 0.0075 })
BriarRepelAddRepelSG("bee", { resist_mult = 0.65 })
BriarRepelAddRepelSG("beeguard", {  vec_acc = 0.0075 ,resist_mult = 0.85 })
BriarRepelAddRepelSG("hound", {  vec_acc = 0.0075 ,resist_mult = 0.9})
BriarRepelAddRepelSG("frog", {
    repel_anim = "fall_idle",
    vec_acc = 0.0075,
    resist_mult = 0.75
})
BriarRepelAddRepelSG("squid", {  vec_acc = 0.0075 })
BriarRepelAddRepelSG("mole", {
    repel_anim = "stunned_loop",
    vec_acc = 0.0075
})
BriarRepelAddRepelSG("pig", {
    repel_anim = "smacked",
    vec_acc = 0.075
})
BriarRepelAddRepelSG("bunnyman", {
    repel_anim = "hit",
    resist_mult = 0.75,
    vec_acc = 0.0075
})
BriarRepelAddRepelSG("merm", {  vec_acc = 0.0075 })
BriarRepelAddRepelSG("monkey", {  vec_acc = 0.0075 })
BriarRepelAddRepelSG("krampus", {  vec_acc = 0.0075 })
BriarRepelAddRepelSG("penguin", {  vec_acc = 0.0075 })
BriarRepelAddRepelSG("werepig", {  vec_acc = 0.0075 })
BriarRepelAddRepelSG("moonpig", { vec_acc = 0.0075 })
BriarRepelAddRepelSG("spiderqueen")
BriarRepelAddRepelSG("walrus" ,{  vec_acc = 0.0075 })
BriarRepelAddRepelSG("perd")
BriarRepelAddRepelSG("catcoon")
BriarRepelAddRepelSG("molebat")
BriarRepelAddRepelSG("buzzard")
BriarRepelAddRepelSG("rabbit")
BriarRepelAddRepelSG("rabbitking")
BriarRepelAddRepelSG("fruit_dragon")
BriarRepelAddRepelSG("birchnutdrake")
BriarRepelAddRepelSG("slurper")
BriarRepelAddRepelSG("deer",{  vec_acc = 0.0075 })
BriarRepelAddRepelSG("slurtle",{ repel_anim = "hit_out",})
BriarRepelAddRepelSG("bat" , { dont_repel_ondeath = true ,resist_mult = 0.9  })
BriarRepelAddRepelSG("rocky" , { dont_repel_ondeath = true ,resist_mult = 0.85  })
BriarRepelAddRepelSG("lightninggoat" , { dont_repel_ondeath = true ,resist_mult = 0.85  })
BriarRepelAddRepelSG("tallbird" , { dont_repel_ondeath = true ,resist_mult = 0.85  })
BriarRepelAddRepelSG("worm" , { dont_repel_ondeath = true ,resist_mult = 0.85  })


BriarRepelAddRepelSG("shadowthrall_mouth" , { dont_repel_ondeath = true ,resist_mult = 0.95  })

BriarRepelAddRepelSG("shadowthrall_wings" , { dont_repel_ondeath = true ,resist_mult = 0.85  })
BriarRepelAddRepelSG("shadowthrall_hands" , { dont_repel_ondeath = true ,resist_mult = 0.85  })
BriarRepelAddRepelSG("shadowthrall_horns" , { dont_repel_ondeath = true ,resist_mult = 0.8 })

BriarRepelAddRepelSG("eyeofterror_mini", {resist_mult = 0.85 })

BriarRepelAddRepelSG("alterguardian_phase1" , { dont_repel_ondeath = true ,resist_mult = 0.9  })
BriarRepelAddRepelSG("alterguardian_phase2" , { dont_repel_ondeath = true ,resist_mult = 0.85  })
BriarRepelAddRepelSG("alterguardian_phase3" , { dont_repel_ondeath = true ,resist_mult = 0.85  })
BriarRepelAddRepelSG("alterguardian_phase4_lunarrift" , { dont_repel_ondeath = true ,resist_mult = 0.85  })

BriarRepelAddRepelSG("toadstool" , { dont_repel_ondeath = true ,resist_mult = 0.65  })
BriarRepelAddRepelSG("leif")
BriarRepelAddRepelSG("mushgnome")
BriarRepelAddRepelSG("chest_mimic")
BriarRepelAddRepelSG("fused_shadeling")
BriarRepelAddRepelSG("grassgekko")
BriarRepelAddRepelSG("lavae")
BriarRepelAddRepelSG("beefalo" , { dont_repel_ondeath = true ,resist_mult = 0.8 })
BriarRepelAddRepelSG("grassgator" , { dont_repel_ondeath = true ,resist_mult = 0.8 })
BriarRepelAddRepelSG("beequeen" , { dont_repel_ondeath = true ,resist_mult = 0.75 })
BriarRepelAddRepelSG("koalefant", { dont_repel_ondeath = true ,resist_mult = 0.8 })
BriarRepelAddRepelSG("warg", { dont_repel_ondeath = true ,resist_mult = 0.8  })
BriarRepelAddRepelSG("spat")
BriarRepelAddRepelSG("deerclops", { dont_repel_ondeath = true ,resist_mult = 0.75})
BriarRepelAddRepelSG("minotaur", { dont_repel_ondeath = true ,resist_mult = 0.75  })
BriarRepelAddRepelSG("bearger", {
    repel_anim = "standing_hit",
    dont_repel_ondeath = true,
    resist_mult = 0.85
})
BriarRepelAddRepelSG("klaus", {
    dont_repel_ondeath = true,
    resist_mult = 0.75
})


BriarRepelAddRepelSG("fruitfly", {
    dont_repel_ondeath = true,
    resist_mult = 0.75
})

BriarRepelAddRepelSG("sharkboi", {
    dont_repel_ondeath = true,
    resist_mult = 0.85
})

BriarRepelAddRepelSG("daywalker", {
    dont_repel_ondeath = true,
    resist_mult = 0.85
})


BriarRepelAddRepelSG("daywalker2", {
    dont_repel_ondeath = true,
    resist_mult = 0.85
})


-- BriarRepelAddRepelSG("stalker", {
--     dont_repel_ondeath = true,
--     resist_mult = 0.85
-- })

BriarRepelAddRepelSG("wagboss_robot", {
    dont_repel_ondeath = true,
    resist_mult = 0.85
})

BriarRepelAddRepelSG("moose", { dont_repel_ondeath = true , resist_mult = 0.85})
BriarRepelAddRepelSG("dragonfly", {dont_repel_ondeath = true ,resist_mult = 0.75 })

BriarRepelAddRepelSG("eyeofterror", {dont_repel_ondeath = true ,resist_mult = 0.75 })


BriarRepelAddRepelSG("wilson", {repel_anim = "knockback_high",dont_repel_ondeath = true ,resist_mult = 0.85 ,vec_acc = 0.0075 })

BriarRepelAddRepelSG("mossling", {
    repel_anim = "meep",
    resist_mult = 0.75
})
BriarRepelAddRepelSG("bishop",{ resist_mult = 0.85 })
BriarRepelAddRepelSG("knight", { resist_mult = 0.85 })
BriarRepelAddRepelSG("rook")
BriarRepelAddRepelSG("powdermonkey", {
    repel_anim = "hit",
    vec_acc = 0.0075
})
BriarRepelAddRepelSG("otter", {
    repel_anim = "hit",
    vec_acc = 0.0075
})