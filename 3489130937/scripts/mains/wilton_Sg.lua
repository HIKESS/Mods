local function SetWiltonSg(sg)
    local old_yawn = sg.events['yawn'].fn
    sg.events['yawn'] = EventHandler('yawn', function(inst, data, ...)
        if inst.prefab == "wiltonmod" then
            return
        end
        old_yawn(inst, data, ...)
    end)

    local old_death = sg.events['death'].fn
    sg.events['death'] = EventHandler('death', function(inst, data, ...)
        if inst.prefab == "wiltonmod" then
            return
        end
        old_death(inst, data, ...)
    end)         
end

AddStategraphPostInit("wilson", SetWiltonSg)

local function AddPlayerSgPostInit(fn)
    AddStategraphPostInit('wilson', fn)
    AddStategraphPostInit('wilson_client', fn)
end
  
AddPlayerSgPostInit(function(self)
    local tent = self.states.tent 
    if tent then
        local old_enter = tent.onenter
        function tent.onenter(inst, ...)
            -- 允许威尔顿在白天也能在坟墓(mound)里睡觉
            local bufferedaction = inst:GetBufferedAction()
            if bufferedaction ~= nil and bufferedaction.target ~= nil 
                and bufferedaction.target.prefab == "mound"
                and inst.prefab == "wiltonmod"
                and TheWorld ~= nil and TheWorld.state.isday then
                local target = bufferedaction.target
                if not target:HasTag("siestahut") then
                    target:AddTag("siestahut")
                    target._wilton_temp_siestatag = true
                end
                inst._wilton_temp_siestatarget = target
            end

            if old_enter then 
                old_enter(inst, ...)  
            end
            if inst.prefab == "wiltonmod" and inst.components.health then  --ThePlayer.AnimState:PlayAnimation("dozy", true)
                --[[
                inst.AnimState:PlayAnimation("yawn", false)
                inst.AnimState:PushAnimation("dozy", false)
                inst.AnimState:PushAnimation("sleep_loop", true)

            	inst:DoTaskInTime(0.24, function(inst)
            	inst:Show()
                end)


                local target = inst:GetBufferedAction() and inst:GetBufferedAction().target
                if target and target.prefab == "mound" then
                inst:Hide()    
                inst.Transform:SetPosition(target.Transform:GetWorldPosition())
                end    
                
                local skel = SpawnPrefab("wiltonmod_skeleton")
                skel.Transform:SetPosition(inst.Transform:GetWorldPosition())

                local fx = SpawnPrefab("chester_transform_fx")
                fx.Transform:SetPosition(inst.Transform:GetWorldPosition())
                ]]                
            end
        end

        local old_exit = tent.onexit 
        function tent.onexit(inst, ...)
            if old_exit then 
                old_exit(inst, ...)  
            end
            if inst.prefab == "wiltonmod" then  --ThePlayer.AnimState:PlayAnimation("dozy", true)
                local skeleton = FindEntity(inst, 1, nil, {"wiltonmod_skeleton"})
                if skeleton and skeleton:IsValid() then
                    skeleton:Remove()
                end
                -- 使用 mound 作为睡袋时，威尔顿在进入睡眠时会在墓穴外生成一个临时稻草人替身（scarecrow2），
                -- 仅用于表现睡眠中的“骨架外观”。这里在 tent 状态退出（起床）时，额外清理贴身的临时稻草人，
                -- 通过 is_wilton_sleep_scarecrow 标记与 wilton_bone_revive 区分，避免误删真正的复活稻草人锚点。
                local scarecrow = FindEntity(inst, 1.2, function(ent)
                    return ent.prefab == "scarecrow2" and ent.is_wilton_sleep_scarecrow
                end)
                if scarecrow ~= nil and scarecrow:IsValid() then
                    scarecrow:Remove()
                end

                -- 清理临时 siestahut 标签和标记
                local target = inst._wilton_temp_siestatarget
                if target ~= nil then
                    inst._wilton_temp_siestatarget = nil
                    if target._wilton_temp_siestatag then
                        target._wilton_temp_siestatag = nil
                        if target:HasTag("siestahut") then
                            target:RemoveTag("siestahut")
                        end
                    end
                end
            end
        end        
    end

    local emote = self.states.emote
    if emote then
        local old_exit = emote.onexit
        function emote.onexit(inst, ...)
            if old_exit then 
                old_exit(inst, ...)  
            end

            if inst.components.leader:CountFollowers("wiltonmod_pet") then
            for k, v in pairs(inst.components.leader.followers) do
            if k.prefab == "wiltonmod_pet" and k.components.health and not k.components.health:IsDead() and k.sg:HasStateTag("emote") then
                k.sg:GoToState("idle")
            end
            end
            end            
        end
    end                                 

    local idle = self.states.idle
    if idle ~= nil then
        local old_idle_onenter = idle.onenter
        -- 禁用威尔顿的官方低理智待机动画：进入 idle 时如果是威尔顿且处于低理智，只使用普通 idle_loop
        function idle.onenter(inst, ...)
            if old_idle_onenter ~= nil then
                old_idle_onenter(inst, ...)
            end

            if inst.prefab == "wiltonmod"
                and inst.components ~= nil
                and inst.components.sanity ~= nil
                and inst.components.sanity:IsInsane() then
                inst.AnimState:PlayAnimation("idle_loop", true)
            end
        end
    end
end)



local function Wilton_Hand(sg)
    local old_handler = sg.actionhandlers[ACTIONS.DIG].deststate
    sg.actionhandlers[ACTIONS.DIG].deststate = function(inst, action)
        if inst.prefab == "wiltonmod" and inst.replica.inventory
        and not inst.replica.inventory:EquipHasTag("DIG_tool") then
            return "dolongaction"
        else
            return old_handler(inst, action)
        end
    end    
end

AddStategraphPostInit("wilson", Wilton_Hand)
AddStategraphPostInit("wilson_client", Wilton_Hand)

local function Wilton_Hand_Atk(sg)
    local old_handler = sg.actionhandlers[ACTIONS.ATTACK].deststate
    sg.actionhandlers[ACTIONS.ATTACK].deststate = function(inst, action)
        local target = action.target or nil
        if inst.prefab == "wiltonmod" and inst.replica.inventory
        and inst.replica.inventory:EquipHasTag("multithruster") and target then
            inst.sg:GoToState("multithrust", target) 
            return
        else
            return old_handler(inst, action)
        end
    end    
end

AddStategraphPostInit("wilson", Wilton_Hand_Atk)