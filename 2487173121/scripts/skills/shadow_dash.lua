local KodiUtils = require("kodi_utils")
local ShadowDash = {}
ShadowDash.PURPLE_TINT = {0.15, 0, 1.0, 1}
ShadowDash.MIN_DISTANCE = TUNING.KODI_SHADOW_DASH_MIN_DISTANCE
ShadowDash.ENERGY_PER_TILE = TUNING.KODI_SHADOW_DASH_ENERGY_PER_TILE
ShadowDash.MIN_ENERGY = TUNING.KODI_SHADOW_DASH_MIN_ENERGY
ShadowDash.ENERGY_RESERVE = TUNING.KODI_SHADOW_DASH_ENERGY_RESERVE
ShadowDash.BASE_COOLDOWN = TUNING.KODI_SHADOW_DASH_BASE_COOLDOWN
ShadowDash.MAX_RANGE = TUNING.KODI_SHADOW_DASH_MAX_RANGE
function ShadowDash.IsValidPosition(target_x, target_z)
    if not TheWorld or not TheWorld.Map then
        return false, "no_map"
    end
    local map = TheWorld.Map
    if not map:IsPassableAtPoint(target_x, 0, target_z) then
        return false, "impassable"
    end
    local tile = map:GetTileAtPoint(target_x, 0, target_z)
    if tile == GROUND.IMPASSABLE or tile == GROUND.INVALID then
        return false, "invalid_tile"
    end
    if map:IsOceanAtPoint(target_x, 0, target_z) then
        return false, "water"
    end
    local width, height = map:GetSize()
    local half_width = width * 2
    local half_height = height * 2
    if math.abs(target_x) > half_width or math.abs(target_z) > half_height then
        return false, "out_of_bounds"
    end
    return true, "ok"
end
function ShadowDash.CalculateEnergyCost(distance)
    local cost = math.max(ShadowDash.MIN_ENERGY, distance * ShadowDash.ENERGY_PER_TILE)
    return math.floor(cost)
end
function ShadowDash.Execute(inst, target_x, target_z)
    if not KodiUtils.IsValidEntity(inst) then
        return false
    end
    if not inst.Transform or not inst.Physics then
        return false
    end
    if not KodiUtils.IsDemonForm(inst) then
        KodiUtils.CallComponent(inst, "talker", "Say", STRINGS.KODI_SPEECH.DASH_ONLY_DEMON, 2, true)
        return false
    end
    if inst:HasTag("shadow_dash_cooldown") then
        return false
    end
    if inst.components.inventory then
        local item = inst.components.inventory:GetEquippedItem(EQUIPSLOTS.HANDS)
        if item and item:HasTag("rechargeable") then
            return false
        end
    end
    local x, y, z = inst.Transform:GetWorldPosition()
    local dx = target_x - x
    local dz = target_z - z
    local distance = math.sqrt(dx * dx + dz * dz)
    if distance < ShadowDash.MIN_DISTANCE then
        KodiUtils.CallComponent(inst, "talker", "Say", STRINGS.KODI_SPEECH.DASH_TOO_CLOSE, 2, true)
        return false
    end
    local cost = ShadowDash.CalculateEnergyCost(distance)
    if not inst.GetDemonicPercent or not inst.demonic_energy then
        return false
    end
    local current_energy_percent = inst:GetDemonicPercent()
    local current_energy = current_energy_percent * 100
    local available_energy = current_energy - ShadowDash.ENERGY_RESERVE
    if available_energy < cost then
        if current_energy <= ShadowDash.ENERGY_RESERVE then
            KodiUtils.CallComponent(inst, "talker", "Say", STRINGS.KODI_SPEECH.DASH_LOW_RESERVE, 2, true)
        else
            KodiUtils.CallComponent(inst, "talker", "Say", string.format(STRINGS.KODI_SPEECH.DASH_NOT_ENOUGH, cost, math.floor(available_energy)), 2, true)
        end
        return false
    end
    local is_valid, reason = ShadowDash.IsValidPosition(target_x, target_z)
    if not is_valid then
        if inst.components.talker then
            local msg
            if reason == "water" then
                msg = STRINGS.KODI_SPEECH.DASH_INTO_WATER
            elseif reason == "out_of_bounds" then
                msg = STRINGS.KODI_SPEECH.DASH_OUT_OF_BOUNDS
            else
                msg = STRINGS.KODI_SPEECH.DASH_CANT_THERE
            end
            inst.components.talker:Say(msg, 2, true)
        end
        return false
    end
    if inst.demonic_energy ~= nil then
        inst.demonic_energy = math.max(0, inst.demonic_energy - cost)
        if inst.UpdateDemonicNetvar then
            inst:UpdateDemonicNetvar()
        end
        inst:PushEvent("demonic_energy_changed", {percent = inst:GetDemonicPercent()})
    end
    if inst:HasTag("kodi_dash_damage") then
        ShadowDash.DealPathDamage(inst, x, z, target_x, target_z, dx, dz, distance)
    end
    ShadowDash.SpawnStartEffects(inst, x, y, z)
    inst.SoundEmitter:PlaySound("dontstarve/common/shadowTentacle_attack")
    inst.SoundEmitter:PlaySound("dontstarve/characters/wortox/soul/spawn")
    inst:Hide()
    inst:DoTaskInTime(0.1, function()
        if inst:IsValid() then
            inst.Physics:Teleport(target_x, 0, target_z)
            ShadowDash.SpawnEndEffects(inst, target_x, target_z)
            inst:Show()
            inst.SoundEmitter:PlaySound("dontstarve/characters/wortox/soul/hop_out")
            inst:ShakeCamera(CAMERASHAKE.SIDE, 0.3, 0.02, 0.3)
        end
    end)
    local cooldown_reduction = 0
    if inst.GetDashCooldownReduction then
        cooldown_reduction = inst:GetDashCooldownReduction()
    end
    local final_cooldown = ShadowDash.BASE_COOLDOWN * (1 - cooldown_reduction)
    inst:AddTag("shadow_dash_cooldown")
    inst:DoTaskInTime(final_cooldown, function()
        inst:RemoveTag("shadow_dash_cooldown")
    end)
    return true
end
function ShadowDash.DealPathDamage(inst, start_x, start_z, target_x, target_z, dx, dz, distance)
    local dash_damage = TUNING.KODI_SHADOW_DASH_PATH_DAMAGE
    local path_width = TUNING.KODI_SHADOW_DASH_PATH_WIDTH
    local mid_x = (start_x + target_x) / 2
    local mid_z = (start_z + target_z) / 2
    local search_radius = distance / 2 + path_width
    local enemies = TheSim:FindEntities(mid_x, 0, mid_z, search_radius,
        {"_combat"},
        {"player", "companion", "wall", "structure", "INLIMBO"}
    )
    for _, ent in ipairs(enemies) do
        if ent and ent:IsValid() and ent.components.health and not ent.components.health:IsDead() then
            local ex, _, ez = ent.Transform:GetWorldPosition()
            local line_len = distance
            local t = math.max(0, math.min(1, ((ex - start_x) * dx + (ez - start_z) * dz) / (line_len * line_len)))
            local closest_x = start_x + t * dx
            local closest_z = start_z + t * dz
            local dist_to_line = math.sqrt((ex - closest_x)^2 + (ez - closest_z)^2)
            if dist_to_line <= path_width then
                ent.components.health:DoDelta(-dash_damage)
                local fx = SpawnPrefab("shadowstrike_slash_fx")
                if fx then
                    fx.Transform:SetPosition(ex, 0, ez)
                end
            end
        end
    end
end
function ShadowDash.SpawnStartEffects(inst, x, y, z)
    local tint = ShadowDash.PURPLE_TINT
    local fx_start = SpawnPrefab("shadow_despawn")
    if fx_start then
        fx_start.Transform:SetPosition(x, y, z)
    end
    local portal_in = SpawnPrefab("wortox_portal_jumpin_fx")
    if portal_in then
        portal_in.Transform:SetPosition(x, y, z)
        if portal_in.AnimState then
            portal_in.AnimState:SetMultColour(tint[1], tint[2], tint[3], tint[4])
        end
    end
    local smoke_start = SpawnPrefab("statue_transition")
    if smoke_start then
        smoke_start.Transform:SetPosition(x, y, z)
        if smoke_start.AnimState then
            smoke_start.AnimState:SetMultColour(tint[1], tint[2], tint[3], tint[4])
        end
    end
end
function ShadowDash.SpawnEndEffects(inst, target_x, target_z)
    local tint = ShadowDash.PURPLE_TINT
    local fx_end = SpawnPrefab("shadow_despawn")
    if fx_end then
        fx_end.Transform:SetPosition(target_x, 0, target_z)
    end
    local portal_out = SpawnPrefab("wortox_portal_jumpout_fx")
    if portal_out then
        portal_out.Transform:SetPosition(target_x, 0, target_z)
        if portal_out.AnimState then
            portal_out.AnimState:SetMultColour(tint[1], tint[2], tint[3], tint[4])
        end
    end
    local smoke_end = SpawnPrefab("statue_transition_2")
    if smoke_end then
        smoke_end.Transform:SetPosition(target_x, 0, target_z)
        if smoke_end.AnimState then
            smoke_end.AnimState:SetMultColour(tint[1], tint[2], tint[3], tint[4])
        end
    end
    local electric = SpawnPrefab("sparks")
    if electric then
        electric.Transform:SetPosition(target_x, 0.5, target_z)
        if electric.AnimState then
            electric.AnimState:SetMultColour(tint[1], tint[2], tint[3], tint[4])
        end
    end
end
function ShadowDash.CanExecute(inst, pos)
    if inst.prefab ~= "kodi" then return false end
    if inst:HasTag("NotDemon") then return false end
    if inst:HasTag("shadow_dash_cooldown") then return false end
    if inst.replica and inst.replica.inventory then
        local item = inst.replica.inventory:GetEquippedItem(EQUIPSLOTS.HANDS)
        if item and item:HasTag("rechargeable") then return false end
    end
    local is_valid = ShadowDash.IsValidPosition(pos.x, pos.z)
    if not is_valid then return false end
    return true
end
function ShadowDash.SetupPlayer(inst)
    inst.ShadowDashToPosition = function(self, target_x, target_z)
        return ShadowDash.Execute(self, target_x, target_z)
    end
end
function ShadowDash.CreateStategraphState(modname)
    return State {
        name = "shadow_dash",
        tags = { "doing", "busy", "canrotate" },
        onenter = function(inst)
            if inst.replica and inst.replica.inventory then
                local item = inst.replica.inventory:GetEquippedItem(EQUIPSLOTS.HANDS)
                if item and item:HasTag("rechargeable") then
                    inst.sg:GoToState("idle")
                    return
                end
            end
            if inst.components and inst.components.locomotor then
                inst.components.locomotor:Stop()
            end
            inst.AnimState:PlayAnimation("jump_pre")
            inst.SoundEmitter:PlaySound("dontstarve/common/shadowTentacle_attack")
        end,
        timeline = {
            TimeEvent(4 * FRAMES, function(inst)
                if inst.bufferedaction then
                    local act = inst.bufferedaction
                    local pos = act:GetActionPoint()
                    if pos then
                        if TheWorld.ismastersim then
                            if inst.ShadowDashToPosition then
                                inst:ShadowDashToPosition(pos.x, pos.z)
                            end
                        else
                            SendModRPCToServer(MOD_RPC[modname]["ShadowDashToPos"], pos.x, pos.z)
                        end
                    end
                end
                if inst.PerformBufferedAction then
                    inst:PerformBufferedAction()
                end
            end),
        },
        events = {
            EventHandler("animover", function(inst)
                inst.sg:GoToState("idle")
            end),
        },
    }
end
function ShadowDash.CreateAction()
    local action = Action({
        priority = 10,
        rmb = true,
        distance = ShadowDash.MAX_RANGE,
        mount_valid = false,
        encumbered_valid = false
    })
    action.id = "SHADOW_DASH"
    action.str = "Shadow Dash"
    action.fn = function(act)
        return true
    end
    return action
end
return ShadowDash
