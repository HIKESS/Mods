local ShadowHands = {}
ShadowHands.OnCooldownCallback = nil
ShadowHands.RANGE = 15
ShadowHands.MIN_DAMAGE = 40
ShadowHands.MAX_DAMAGE = 180
ShadowHands.TICK = 0.5
ShadowHands.ENERGY_COST = 15
ShadowHands.COOLDOWN = 6
ShadowHands.HAND_SPACING = 1.2
ShadowHands.CAGE_DURATION = 3
ShadowHands.TIMEOUT = 3.0
function ShadowHands.SpawnBoneCage(inst, target, tx, ty, tz)
    if target:HasTag("kodi_caged") then return end
    target:AddTag("kodi_caged")
    local cage_radius = (target:GetPhysicsRadius(0) or 0.5) + 0.6
    local cage_spikes = target:HasTag("largecreature") and 14 or 10
    for i = 1, cage_spikes do
        local angle = (i / cage_spikes) * 2 * math.pi + math.random() * 0.2
        local spike_x = tx + math.cos(angle) * cage_radius
        local spike_z = tz + math.sin(angle) * cage_radius
        local spike = SpawnPrefab("fossilspike")
        if spike then
            spike.Transform:SetPosition(spike_x, 0, spike_z)
            spike.AnimState:SetMultColour(0, 0, 0, 1)
            if spike.components.combat then
                local spike_owner = inst
                local old_cantarget = spike.components.combat.CanTarget
                spike.components.combat.CanTarget = function(combat_self, targ)
                    if targ then
                        if targ == spike_owner then return false end
                        if targ.components.follower and targ.components.follower:GetLeader() == spike_owner then return false end
                        if (targ:HasTag("chester") or targ:HasTag("hutch")) and targ.components.follower then
                            local leader = targ.components.follower:GetLeader()
                            if leader and leader.components.leader and leader.components.leader:IsFollower(spike_owner) then return false end
                        end
                    end
                    return old_cantarget and old_cantarget(combat_self, targ) or true
                end
            end
            local variation = math.random(7)
            spike:RestartSpike(i * 0.05, ShadowHands.CAGE_DURATION, variation)
        end
    end
    target:DoTaskInTime(ShadowHands.CAGE_DURATION, function()
        if target:IsValid() then
            target:RemoveTag("kodi_caged")
        end
    end)
end
function ShadowHands.Start(inst, target)
    if not inst:HasTag("kodi_shadow_hands") then
        return false
    end
    if not target or not target:IsValid() then
        return false
    end
    if inst:HasTag("NotDemon") then
        inst.components.talker:Say(STRINGS.KODI_SPEECH.SHADOW_HANDS_ONLY_DEMON, 2, true)
        return false
    end
    if inst._shadow_hands_cooldown then
        if inst.components.talker then
            inst.components.talker:Say(STRINGS.KODI_SPEECH.SHADOW_HANDS_NOT_READY or "*Shadow hands not ready*", 2, true)
        end
        return false
    end
    if inst.demonic_energy and inst.demonic_energy < ShadowHands.ENERGY_COST then
        if inst.components.talker then
            inst.components.talker:Say(STRINGS.KODI_SPEECH.SHADOW_HANDS_NO_ENERGY or "*Not enough shadow energy*", 2, true)
        end
        return false
    end
    local px, py, pz = inst.Transform:GetWorldPosition()
    local tx, ty, tz = target.Transform:GetWorldPosition()
    local dist = math.sqrt((tx - px)^2 + (tz - pz)^2)
    if dist > ShadowHands.RANGE then
        inst.components.talker:Say(STRINGS.KODI_SPEECH.SHADOW_HANDS_TOO_FAR, 2, true)
        return false
    end
    inst._shadow_hands_active = true
    inst._shadow_hands_target = target
    inst:AddTag("kodi_channeling")
    if inst.components.playercontroller then
        inst.components.playercontroller:Enable(false)
    end
    if inst.components.locomotor then
        inst.components.locomotor:Stop()
        inst.components.locomotor:SetExternalSpeedMultiplier(inst, "kodi_channel_lock", 0)
    end
    inst.AnimState:PlayAnimation("idle_sanity_pre")
    inst.AnimState:PushAnimation("idle_sanity_loop", true)
    inst._shadow_hands_anim_task = inst:DoPeriodicTask(0.5, function()
        if inst._shadow_hands_active then
            if not inst.AnimState:IsCurrentAnimation("idle_sanity_loop") then
                inst.AnimState:PlayAnimation("idle_sanity_loop", true)
            end
        end
    end)
    ShadowHands.SpawnStartEffects(inst, px, py, pz)
    inst._shadow_hands_cast_fx_task = inst:DoPeriodicTask(0.6, function()
        if inst._shadow_hands_active then
            local fx = SpawnPrefab("shadow_glob_fx")
            if fx then
                local x, y, z = inst.Transform:GetWorldPosition()
                fx.Transform:SetPosition(x, y, z)
            end
        end
    end)
    if inst.demonic_energy then
        inst.demonic_energy = math.max(0, inst.demonic_energy - ShadowHands.ENERGY_COST)
        inst:UpdateDemonicNetvar()
        inst:PushEvent("demonic_energy_changed", {percent = inst:GetDemonicPercent()})
    end
    inst._shadow_hands_cooldown = true
    inst:DoTaskInTime(ShadowHands.COOLDOWN, function()
        inst._shadow_hands_cooldown = false
    end)
    if ShadowHands.OnCooldownCallback then
        ShadowHands.OnCooldownCallback(inst, ShadowHands.COOLDOWN)
    end
    if target:HasTag("bird") or target:HasTag("rabbit") or target:HasTag("butterfly") then
        inst:DoTaskInTime(0.3, function()
            if target:IsValid() and target.components.combat then
                ShadowHands.DealDamage(inst, target, nil)
            elseif target:IsValid() and target.components.health then
                target.components.health:Kill()
            end
        end)
        ShadowHands.SpawnHandPair(inst, target, px, pz, tx, tz)
    else
        ShadowHands.SpawnHandPair(inst, target, px, pz, tx, tz)
    end
    inst.SoundEmitter:PlaySound("dontstarve/sanity/creature1/taunt")
    return true
end
function ShadowHands.Stop(inst)
    if not inst._shadow_hands_active then return end
    inst._shadow_hands_active = false
    inst._shadow_hands_target = nil
    inst:RemoveTag("kodi_channeling")
    if inst._shadow_hands_anim_task then
        inst._shadow_hands_anim_task:Cancel()
        inst._shadow_hands_anim_task = nil
    end
    if inst._shadow_hands_cast_fx_task then
        inst._shadow_hands_cast_fx_task:Cancel()
        inst._shadow_hands_cast_fx_task = nil
    end
    if inst.components.playercontroller then
        inst.components.playercontroller:Enable(true)
    end
    if inst.components.locomotor then
        inst.components.locomotor:RemoveExternalSpeedMultiplier(inst, "kodi_channel_lock")
    end
    if inst.sg then
        inst.sg:GoToState("idle")
    end
    inst.AnimState:SetMultColour(1, 1, 1, 1)
end
function ShadowHands.SpawnHandPair(inst, target, px, pz, tx, tz)
    local dx, dz = tx - px, tz - pz
    local len = math.sqrt(dx * dx + dz * dz)
    local perp_x, perp_z = -dz / len, dx / len
    local damage_dealt = false
    for i, side in ipairs({-1, 1}) do
        local spawn_x = px + perp_x * ShadowHands.HAND_SPACING * side
        local spawn_z = pz + perp_z * ShadowHands.HAND_SPACING * side
        local hand = SpawnPrefab("shadowhand")
        if not hand then return end
        hand.Transform:SetPosition(spawn_x, 0, spawn_z)
        hand:FacePoint(tx, 0, tz)
        local arm = SpawnPrefab("shadowhand_arm")
        if arm then
            arm.Transform:SetPosition(spawn_x, 0, spawn_z)
            arm:FacePoint(tx, 0, tz)
            if arm.components.stretcher then
                arm.components.stretcher:SetStretchTarget(hand)
            end
            hand.arm = arm
        end
        if hand.components.locomotor then
            hand.components.locomotor:Stop()
            hand.components.locomotor:Clear()
            hand.components.locomotor.walkspeed = 12
            hand.components.locomotor:GoToEntity(target)
        end
        hand.AnimState:PlayAnimation("hand_in")
        hand.AnimState:PushAnimation("hand_in_loop", true)
        hand.SoundEmitter:PlaySound("dontstarve/sanity/shadowhand_creep", "creeping")
        local check_task
        check_task = hand:DoPeriodicTask(0.1, function()
            if not hand:IsValid() or not target:IsValid() then
                if check_task then check_task:Cancel() end
                if hand:IsValid() then hand:Remove() end
                if arm and arm:IsValid() then arm:Remove() end
                return
            end
            local hx, hy, hz = hand.Transform:GetWorldPosition()
            local ttx, tty, ttz = target.Transform:GetWorldPosition()
            local dist = math.sqrt((ttx - hx)^2 + (ttz - hz)^2)
            if dist < 1.5 then
                if check_task then check_task:Cancel() end
                if hand.components.locomotor then
                    hand.components.locomotor:Stop()
                    hand.components.locomotor:Clear()
                end
                hand.SoundEmitter:KillSound("creeping")
                hand.AnimState:PlayAnimation("grab")
                hand.AnimState:PushAnimation("grab_pst", false)
                hand.SoundEmitter:PlaySound("dontstarve/sanity/shadowhand_snuff")
                if not damage_dealt then
                    damage_dealt = true
                    hand:DoTaskInTime(0.3, function()
                        ShadowHands.DealDamage(inst, target, hand)
                    end)
                end
                hand:ListenForEvent("animover", function()
                    if arm and arm:IsValid() then arm:Remove() end
                    if hand:IsValid() then hand:Remove() end
                end)
            end
        end)
        hand:DoTaskInTime(ShadowHands.TIMEOUT, function()
            if check_task then check_task:Cancel() end
            if hand:IsValid() then
                hand.SoundEmitter:KillSound("creeping")
                hand:Remove()
            end
            if arm and arm:IsValid() then arm:Remove() end
            ShadowHands.Stop(inst)
        end)
    end
end
function ShadowHands.DealDamage(inst, target, hand)
    if not target:IsValid() or not target.components.combat then
        ShadowHands.Stop(inst)
        return
    end
    local energy_percent = inst:GetDemonicPercent() or 0.5
    local damage = ShadowHands.MIN_DAMAGE + (ShadowHands.MAX_DAMAGE - ShadowHands.MIN_DAMAGE) * energy_percent
    target.components.combat:GetAttacked(inst, damage)
    local ttx, tty, ttz = target.Transform:GetWorldPosition()
    ShadowHands.SpawnHitEffects(ttx, tty, ttz)
    local target_died = target.components.health and target.components.health:IsDead()
    if not target_died then
        ShadowHands.SpawnBoneCage(inst, target, ttx, tty, ttz)
    else
        target.AnimState:SetMultColour(0, 0, 0, 1)
        if target:HasTag("bird") or target:HasTag("flying") then
            target:DoTaskInTime(0.1, function()
                if target:IsValid() then
                    if target.components.lootdropper then
                        target.components.lootdropper:DropLoot()
                    end
                    target:Remove()
                end
            end)
        end
    end
    ShadowHands.Stop(inst)
end
function ShadowHands.SpawnStartEffects(inst, px, py, pz)
    local start_fx = SpawnPrefab("shadow_teleport_out")
    if start_fx then start_fx.Transform:SetPosition(px, py, pz) end
    local burst_fx = SpawnPrefab("shadow_despawn")
    if burst_fx then burst_fx.Transform:SetPosition(px, py, pz) end
    for i = 1, 5 do
        local angle = (i / 5) * 2 * math.pi
        local puff = SpawnPrefab("shadow_puff")
        if puff then
            puff.Transform:SetPosition(px + math.cos(angle) * 1, py, pz + math.sin(angle) * 1)
        end
    end
end
function ShadowHands.SpawnHitEffects(tx, ty, tz)
    local shadow_hit = SpawnPrefab("shadow_despawn")
    if shadow_hit then shadow_hit.Transform:SetPosition(tx, ty, tz) end
    for i = 1, 6 do
        local angle = (i / 6) * 2 * math.pi
        local puff = SpawnPrefab("shadow_puff_large_front")
        if puff then
            puff.Transform:SetPosition(tx + math.cos(angle) * 1.5, ty, tz + math.sin(angle) * 1.5)
        end
    end
end
function ShadowHands.SetupPlayer(inst)
    inst._shadow_hands_active = false
    inst._shadow_hands_target = nil
    inst._shadow_hands_task = nil
    inst._shadow_hands_cooldown = false
    inst.StartShadowHands = function(self, target) return ShadowHands.Start(self, target) end
    inst.StopShadowHands = function(self) return ShadowHands.Stop(self) end
end
return ShadowHands
