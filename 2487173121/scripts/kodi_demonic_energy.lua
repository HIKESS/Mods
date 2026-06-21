local DemonicEnergy = {}
local GLOBAL = nil
local TUNING = nil
local STRINGS = nil
function DemonicEnergy.SetDependencies(deps)
    GLOBAL = deps.GLOBAL
    TUNING = deps.TUNING
    STRINGS = deps.STRINGS
end
function DemonicEnergy.InitNetvar(inst)
    inst._demonic_percent_net = GLOBAL.net_byte(inst.GUID, "kodi.demonic_percent", "demonic_percent_dirty")
    inst._demonic_percent_net:set(0)
    function inst:GetDemonicPercent()
        return (self._demonic_percent_net:value() or 0) / 100
    end
end
function DemonicEnergy.InitClient(inst)
    inst:ListenForEvent("demonic_percent_dirty", function()
        inst:PushEvent("demonic_energy_changed", {percent = inst:GetDemonicPercent()})
    end)
    inst._kodi_eruption_cd_end = nil
    function inst:GetShadowEruptionCooldown()
        if not self._kodi_eruption_cd_end then return 0 end
        local remaining = self._kodi_eruption_cd_end - GLOBAL.GetTime()
        return math.max(0, remaining)
    end
    function inst:SetShadowEruptionCooldown(duration)
        self._kodi_eruption_cd_end = GLOBAL.GetTime() + duration
    end
    function inst:GetDayStalkerFadeRemaining()
        local in_stealth = self:HasTag("kodi_stealth")
        local is_hiding = self:HasTag("kodi_hiding")
        if not in_stealth and not is_hiding then
            return -1
        end
        if self:HasTag("kodi_pounce_ready") then
            return 0
        end
        if not self._day_stalker_fade_start_time then
            return 3.0
        end
        local elapsed = GLOBAL.GetTime() - self._day_stalker_fade_start_time
        return math.max(0, 3.0 - elapsed)
    end
    function inst:GetHideTimeRemaining()
        if not self:HasTag("kodi_hiding") then
            return -1
        end
        if not self._kodi_hide_start_time then
            return 20
        end
        local elapsed = GLOBAL.GetTime() - self._kodi_hide_start_time
        return math.max(0, 20 - elapsed)
    end
    inst._night_hunter_leap_cd_end = 0
    inst._night_hunter_mark_times = {}
    inst._night_hunter_mark_count = 0
    function inst:GetNightHunterLeapCooldown()
        local remaining = (self._night_hunter_leap_cd_end or 0) - GLOBAL.GetTime()
        return math.max(0, remaining)
    end
    function inst:SetNightHunterLeapCooldown(duration)
        self._night_hunter_leap_cd_end = GLOBAL.GetTime() + duration
    end
    function inst:GetNightHunterMarkTimeRemainingByIndex(index)
        if not self._night_hunter_mark_times or not self._night_hunter_mark_times[index] then
            return -1
        end
        local elapsed = GLOBAL.GetTime() - self._night_hunter_mark_times[index]
        return math.max(0, 30 - elapsed)
    end
    function inst:GetNightHunterMarkCount()
        return self._night_hunter_mark_count or 0
    end
    function inst:SetNightHunterMarkInfo(count, mark_times_data)
        self._night_hunter_mark_count = count
        if mark_times_data then
            self._night_hunter_mark_times = mark_times_data
        elseif count == 0 then
            self._night_hunter_mark_times = {}
        end
    end
    function inst:AddNightHunterMark()
        self._night_hunter_mark_count = (self._night_hunter_mark_count or 0) + 1
        if not self._night_hunter_mark_times then
            self._night_hunter_mark_times = {}
        end
        table.insert(self._night_hunter_mark_times, GLOBAL.GetTime())
    end
    function inst:RemoveNightHunterMark(index)
        self._night_hunter_mark_count = math.max(0, (self._night_hunter_mark_count or 0) - 1)
        if self._night_hunter_mark_times and index then
            table.remove(self._night_hunter_mark_times, index)
        end
    end
    function inst:ClearNightHunterMarksUI()
        self._night_hunter_mark_count = 0
        self._night_hunter_mark_times = {}
    end
    inst._shadow_summon_cd_end = 0
    function inst:GetShadowSummonCooldown()
        local remaining = (self._shadow_summon_cd_end or 0) - GLOBAL.GetTime()
        return math.max(0, remaining)
    end
    function inst:SetShadowSummonCooldown(duration)
        self._shadow_summon_cd_end = GLOBAL.GetTime() + duration
    end
    DemonicEnergy.SetupNightVision(inst)
end
function DemonicEnergy.SetupNightVision(inst)
    local NIGHT_VISION_COLOURCUBES = {
        day = "images/colour_cubes/day05_cc.tex",
        dusk = "images/colour_cubes/purple_moon_cc.tex",
        night = "images/colour_cubes/purple_moon_cc.tex",
        full_moon = "images/colour_cubes/purple_moon_cc.tex",
    }
    inst._night_hunter_vision_active = false
    local function UpdateNightVisionClient(player)
        if not player.components.playervision then return end
        local has_skill = player:HasTag("kodi_night_hunter")
        local is_fox = player:HasTag("NotDemon")
        local is_night = GLOBAL.TheWorld.state.phase == "night"
        local is_cave = GLOBAL.TheWorld:HasTag("cave")
        if has_skill and is_fox and (is_night or is_cave) then
            if not player._night_hunter_vision_active then
                player.components.playervision:ForceNightVision(true)
                player.components.playervision:SetCustomCCTable(NIGHT_VISION_COLOURCUBES)
                player._night_hunter_vision_active = true
            end
        else
            if player._night_hunter_vision_active then
                player.components.playervision:ForceNightVision(false)
                player.components.playervision:SetCustomCCTable(nil)
                player._night_hunter_vision_active = false
            end
        end
    end
    inst:WatchWorldState("phase", function(player, phase)
        UpdateNightVisionClient(player)
    end)
    inst:ListenForEvent("kodi_form_changed", function(player)
        UpdateNightVisionClient(player)
    end)
    inst:DoTaskInTime(0, function() UpdateNightVisionClient(inst) end)
    inst:DoTaskInTime(1, function() UpdateNightVisionClient(inst) end)
    inst:DoTaskInTime(3, function() UpdateNightVisionClient(inst) end)
    inst:ListenForEvent("ms_respawnedfromghost", function()
        inst:DoTaskInTime(0.5, function() UpdateNightVisionClient(inst) end)
    end)
end
function DemonicEnergy.InitServer(inst, ShadowMinionPool, KODI_XP_CONFIG)
    inst.demonic_energy = 0
    inst.demonic_drain_task = nil
    function inst:UpdateDemonicNetvar()
        if self._demonic_percent_net then
            local percent = math.floor((self.demonic_energy or 0) / TUNING.KODI_DEMONIC_MAX * 100)
            percent = math.max(0, math.min(100, percent))
            self._demonic_percent_net:set(percent)
        end
    end
    function inst:AddDemonicEnergy(amount)
        local old = self.demonic_energy or 0
        local sanity_mult = 1
        if self.components.sanity then
            local sanity_pct = self.components.sanity:GetPercent()
            sanity_mult = 1 + (1 - sanity_pct) * 0.5
        end
        local final_amount = amount * sanity_mult
        self.demonic_energy = math.min(TUNING.KODI_DEMONIC_MAX, old + final_amount)
        self:UpdateDemonicNetvar()
        self:PushEvent("demonic_energy_changed", {percent = self:GetDemonicPercent(), old = old, new = self.demonic_energy})
        if old < TUNING.KODI_DEMONIC_MAX and self.demonic_energy >= TUNING.KODI_DEMONIC_MAX then
            if self.components.talker and STRINGS and STRINGS.KODI_SPEECH then
                self.components.talker:Say(STRINGS.KODI_SPEECH.POWER_READY, 2.5, true)
            end
        end
    end
    function inst:CanTransform()
        return (self.demonic_energy or 0) >= TUNING.KODI_DEMONIC_MAX
    end
    DemonicEnergy.SetupDrainSystem(inst)
    DemonicEnergy.SetupFearAura(inst)
    DemonicEnergy.SetupNightVisionServer(inst)
    DemonicEnergy.SetupShadowStrike(inst)
    DemonicEnergy.SetupTemperatureImmunity(inst)
    DemonicEnergy.SetupDemonPenalties(inst)
    DemonicEnergy.SetupProgressiveSystem(inst)
    DemonicEnergy.SetupCombatEvents(inst, ShadowMinionPool, KODI_XP_CONFIG)
    DemonicEnergy.SetupSaveLoad(inst, ShadowMinionPool)
end
function DemonicEnergy.SetupDrainSystem(inst)
    function inst:StartDemonicDrain()
        self:StopDemonicDrain()
        self.demonic_drain_task = self:DoPeriodicTask(0.1, function()
            if self.demonic_energy and self.demonic_energy > 0 then
                local drain_reduction = 0
                if self.GetProgressiveDrainReduction then
                    drain_reduction = self:GetProgressiveDrainReduction()
                end
                local drain_amount = TUNING.KODI_DEMONIC_DRAIN_RATE * 0.1 * (1 - drain_reduction)
                if self._shadow_summon_extra_drain then
                    drain_amount = drain_amount * 1.5
                end
                self.demonic_energy = math.max(0, self.demonic_energy - drain_amount)
                self:UpdateDemonicNetvar()
                self:PushEvent("demonic_energy_changed", {percent = self:GetDemonicPercent()})
                if self.demonic_energy <= 0 and not self:HasTag("NotDemon") then
                    if self.KodiTransform then
                        self:KodiTransform()
                    end
                end
            end
        end)
    end
    function inst:StopDemonicDrain()
        if self.demonic_drain_task then
            self.demonic_drain_task:Cancel()
            self.demonic_drain_task = nil
        end
    end
end
function DemonicEnergy.SetupFearAura(inst)
    inst.fear_aura_task = nil
    local FEAR_RADIUS = 12
    local FEAR_TAGS = {"prey", "rabbit", "bird", "butterfly", "catcoon", "babybeefalo"}
    local FEAR_EXCLUDE = {
        "player", "monster", "epic", "companion", "abigail",
        "hostile", "killer", "bee", "killerbee", "frog", "mosquito",
        "spider", "hound", "tentacle", "leif", "merm", "pigguard",
        "bunnyman", "rocky", "tallbird", "walrus", "penguin",
        "warg", "koalefant", "beefalo", "hostile_mob"
    }
    function inst:StartFearAura()
        self:StopFearAura()
        self.fear_aura_task = self:DoPeriodicTask(0.5, function()
            if self:HasTag("NotDemon") then
                self:StopFearAura()
                return
            end
            local x, y, z = self.Transform:GetWorldPosition()
            local creatures = GLOBAL.TheSim:FindEntities(x, y, z, FEAR_RADIUS, nil, FEAR_EXCLUDE, FEAR_TAGS)
            for _, creature in ipairs(creatures) do
                if creature and creature:IsValid() and creature.components.locomotor then
                    if creature.components.hauntable and creature.components.hauntable.panicable then
                        creature.components.hauntable:Panic(3)
                    elseif creature.brain then
                        local angle = creature:GetAngleToPoint(x, y, z) + 180
                        if creature.components.locomotor then
                            creature.components.locomotor:RunInDirection(angle)
                        end
                    end
                    if creature.sg and creature:HasTag("bird") then
                        local current_state_name = creature.sg.currentstate and creature.sg.currentstate.name
                        if not current_state_name or (current_state_name ~= "flyaway" and current_state_name ~= "glide" and current_state_name ~= "land") then
                            if creature.sg.HasState and creature.sg:HasState("flyaway") then
                                creature.sg:GoToState("flyaway")
                            end
                        end
                    end
                end
            end
        end)
    end
    function inst:StopFearAura()
        if self.fear_aura_task then
            self.fear_aura_task:Cancel()
            self.fear_aura_task = nil
        end
    end
end
function DemonicEnergy.SetupNightVisionServer(inst)
    inst._night_vision_light = nil
    function inst:StartNightVision()
        self:StopNightVision()
        self._night_vision_light = GLOBAL.SpawnPrefab("minerhatlight")
        if self._night_vision_light then
            self._night_vision_light.entity:SetParent(self.entity)
            if self._night_vision_light.Light then
                self._night_vision_light.Light:SetRadius(6)
                self._night_vision_light.Light:SetFalloff(0.7)
                self._night_vision_light.Light:SetIntensity(0.6)
                self._night_vision_light.Light:SetColour(100/255, 0/255, 150/255)
            end
        end
        self:AddTag("nightvision")
    end
    function inst:StopNightVision()
        if self._night_vision_light then
            self._night_vision_light:Remove()
            self._night_vision_light = nil
        end
        self:RemoveTag("nightvision")
    end
end
function DemonicEnergy.SetupShadowStrike(inst)
    inst._shadow_strike_ready = false
    local SHADOW_STRIKE_MULT = 2.0
    function inst:EnableShadowStrike()
        self._shadow_strike_ready = true
        self:AddTag("shadow_strike_ready")
    end
    function inst:DisableShadowStrike()
        self._shadow_strike_ready = false
        self:RemoveTag("shadow_strike_ready")
    end
end
function DemonicEnergy.SetupTemperatureImmunity(inst)
    inst._old_temp_settings = nil
    function inst:StartTemperatureImmunity()
        if self.components.temperature then
            self._old_temp_settings = {
                inherentinsulation = self.components.temperature.inherentinsulation,
                inherentsummerinsulation = self.components.temperature.inherentsummerinsulation,
                overheattemp = self.components.temperature.overheattemp,
                freezetemp = self.components.temperature.freezetemp or 0,
            }
            self.components.temperature.inherentinsulation = 999
            self.components.temperature.inherentsummerinsulation = 999
            self.components.temperature.overheattemp = 999
            self:AddTag("temperature_immune")
        end
    end
    function inst:StopTemperatureImmunity()
        if self.components.temperature and self._old_temp_settings then
            self.components.temperature.inherentinsulation = self._old_temp_settings.inherentinsulation
            self.components.temperature.inherentsummerinsulation = self._old_temp_settings.inherentsummerinsulation
            self.components.temperature.overheattemp = self._old_temp_settings.overheattemp
            self._old_temp_settings = nil
            self:RemoveTag("temperature_immune")
        end
    end
end
function DemonicEnergy.SetupDemonPenalties(inst)
    inst._demon_penalty_task = nil
    local DEMON_SANITY_AURA_RADIUS = 10
    local DEMON_SANITY_AURA_DRAIN = -0.5
    local function IsWearingKitsuneMask(player)
        if player.components.inventory then
            local hat = player.components.inventory:GetEquippedItem(GLOBAL.EQUIPSLOTS.HEAD)
            if hat and hat.prefab == "kitsune_mask" then
                return true
            end
        end
        return false
    end
    local function GetDynamicSanityDrain(player)
        local energy_percent = player:GetDemonicPercent() or 0
        if energy_percent > 0.75 then
            return -0.5
        elseif energy_percent > 0.25 then
            return -1.0
        else
            return -1.5
        end
    end
    function inst:StartDemonPenalties()
        self:StopDemonPenalties()
        self._old_healing_mult = 1
        self._demon_penalty_task = self:DoPeriodicTask(1, function()
            if self:HasTag("NotDemon") then
                self:StopDemonPenalties()
                return
            end
            if self.components.sanity then
                if self:HasTag("kodi_demon_mastery") then
                elseif IsWearingKitsuneMask(self) then
                else
                    local drain = GetDynamicSanityDrain(self)
                    self.components.sanity:DoDelta(drain)
                end
            end
            local x, y, z = self.Transform:GetWorldPosition()
            local players_nearby = GLOBAL.TheSim:FindEntities(x, y, z, DEMON_SANITY_AURA_RADIUS, {"player"}, {"playerghost"})
            for _, player in ipairs(players_nearby) do
                if player ~= self and player.components.sanity then
                    player.components.sanity:DoDelta(DEMON_SANITY_AURA_DRAIN)
                end
            end
            local pigs_nearby = GLOBAL.TheSim:FindEntities(x, y, z, 15, nil, {"player"}, {"pig", "bunnyman"})
            for _, pig in ipairs(pigs_nearby) do
                if pig.components.combat and not pig:HasTag("werepig") then
                    if pig.components.combat.target ~= self then
                        pig.components.combat:SetTarget(self)
                    end
                end
            end
        end)
        if self.components.eater and self._kodi_demon_healabsorb_saved == nil then
            self._kodi_demon_healabsorb_saved = self.components.eater.healthabsorption or 1
            self.components.eater.healthabsorption = self._kodi_demon_healabsorb_saved * 0.7
        end
    end
    function inst:StopDemonPenalties()
        if self._demon_penalty_task then
            self._demon_penalty_task:Cancel()
            self._demon_penalty_task = nil
        end
        if self.components.eater and self._kodi_demon_healabsorb_saved ~= nil then
            self.components.eater.healthabsorption = self._kodi_demon_healabsorb_saved
            self._kodi_demon_healabsorb_saved = nil
        end
    end
end
function DemonicEnergy.SetupProgressiveSystem(inst)
    inst.demon_time_total = 0
    inst._demon_time_task = nil
    local PROG_TIER1 = 600
    local PROG_TIER2 = 1800
    local PROG_TIER3 = 3600
    function inst:GetProgressiveTier()
        if self.demon_time_total >= PROG_TIER3 then
            return 3
        elseif self.demon_time_total >= PROG_TIER2 then
            return 2
        elseif self.demon_time_total >= PROG_TIER1 then
            return 1
        end
        return 0
    end
    function inst:GetProgressiveDamageBonus()
        local bonus = self:GetProgressiveTier() * 0.05
        if self:HasTag("kodi_damage_1") then bonus = bonus + 0.10 end
        if self:HasTag("kodi_damage_2") then bonus = bonus + 0.15 end
        return bonus
    end
    function inst:GetProgressiveDrainReduction()
        local reduction = 0
        if self:GetProgressiveTier() >= 2 then reduction = 0.1 end
        if self:HasTag("kodi_duration_1") then reduction = reduction + 0.10 end
        if self:HasTag("kodi_duration_2") then reduction = reduction + 0.20 end
        if self:HasTag("kodi_duration_3") then reduction = reduction + 0.30 end
        return reduction
    end
    function inst:GetProgressiveDashBonus()
        local bonus = 0
        if self:GetProgressiveTier() >= 3 then bonus = 3 end
        if self:HasTag("kodi_dash_1") then bonus = bonus + 2 end
        return bonus
    end
    function inst:GetDashCooldownReduction()
        if self:HasTag("kodi_dash_2") then return 0.25 end
        return 0
    end
    function inst:StartProgressiveTracking()
        self:StopProgressiveTracking()
        self._demon_time_task = self:DoPeriodicTask(1, function()
            if not self:HasTag("NotDemon") then
                local old_tier = self:GetProgressiveTier()
                self.demon_time_total = self.demon_time_total + 1
                local new_tier = self:GetProgressiveTier()
                if new_tier > old_tier and self.components.talker and STRINGS and STRINGS.KODI_SPEECH then
                    if new_tier == 1 then
                        self.components.talker:Say(STRINGS.KODI_SPEECH.DEMON_STRONGER, 3, true)
                    elseif new_tier == 2 then
                        self.components.talker:Say(STRINGS.KODI_SPEECH.DEMON_SUSTAIN, 3, true)
                    elseif new_tier == 3 then
                        self.components.talker:Say(STRINGS.KODI_SPEECH.DEMON_DASH_MASTER, 3, true)
                    end
                    self.SoundEmitter:PlaySound("dontstarve/common/ghost_spawn")
                end
            end
        end)
    end
    function inst:StopProgressiveTracking()
        if self._demon_time_task then
            self._demon_time_task:Cancel()
            self._demon_time_task = nil
        end
    end
    function inst:RefreshDemonBonuses()
        if self:HasTag("NotDemon") then return end
        local bonus = self:GetProgressiveDamageBonus()
        self.components.combat.damagemultiplier = TUNING.KODI_DAMAGETRANSFORM * (1 + bonus)
    end
end
function DemonicEnergy.SetupCombatEvents(inst, ShadowMinionPool, KODI_XP_CONFIG)
    inst:ListenForEvent("death", function()
        inst.demonic_energy = 0
        inst:UpdateDemonicNetvar()
        inst:StopDemonicDrain()
        inst:PushEvent("demonic_energy_changed", {percent = 0})
    end)
    inst:ListenForEvent("killed", function(inst, data)
        local victim = data and data.victim
        if victim and inst.components.skilltreeupdater and KODI_XP_CONFIG then
            local xp_amount = KODI_XP_CONFIG.GetXPForVictim(victim)
            if xp_amount > 0 then
                inst.components.skilltreeupdater:AddSkillXP(xp_amount)
            end
        end
        if not inst:HasTag("NotDemon") and inst.demonic_energy then
            local bonus = TUNING.KODI_KILL_ENERGY_BONUS or 5
            if inst:HasTag("kodi_kill_extend") then
                bonus = bonus + 5
            end
            inst.demonic_energy = math.min(TUNING.KODI_DEMONIC_MAX, inst.demonic_energy + bonus)
            inst:UpdateDemonicNetvar()
            inst:PushEvent("demonic_energy_changed", {percent = inst:GetDemonicPercent()})
            if inst.components.sanity then
                inst.components.sanity:DoDelta(5)
            end
            inst.SoundEmitter:PlaySound("dontstarve/sanity/creature1/taunt")
            if math.random() < 0.3 and inst.components.talker and STRINGS and STRINGS.KODI_SPEECH then
                inst.components.talker:Say(STRINGS.KODI_SPEECH.MORE_POWER, 1.5, true)
            end
        elseif inst:HasTag("NotDemon") and victim then
            if victim:HasTag("shadow") or victim:HasTag("shadowcreature") or
               victim.prefab == "crawlinghorror" or victim.prefab == "terrorbeak" or
               victim.prefab == "crawlingnightmare" or victim.prefab == "nightmarebeak" then
                inst:AddDemonicEnergy(3)
                inst.SoundEmitter:PlaySound("dontstarve/sanity/creature1/taunt")
                if math.random() < 0.5 and inst.components.talker and STRINGS and STRINGS.KODI_SPEECH then
                    inst.components.talker:Say(STRINGS.KODI_SPEECH.SHADOW_ESSENCE, 1.5, true)
                end
            end
        end
    end)
end
function DemonicEnergy.SetupSaveLoad(inst, ShadowMinionPool)
    local old_onsave = inst.OnSave
    inst.OnSave = function(inst, data)
        if old_onsave then old_onsave(inst, data) end
        data.demon_time_total = inst.demon_time_total
        data.demonic_energy = inst.demonic_energy
        data.last_stand_ready = inst._last_stand_ready
        if inst._shadow_summon_cooldown then
            local remaining = inst._shadow_summon_cooldown - GLOBAL.GetTime()
            if remaining > 0 then
                data.shadow_summon_cooldown = remaining
            end
        end
        if inst._kodi_eruption_cd_end then
            local remaining = inst._kodi_eruption_cd_end - GLOBAL.GetTime()
            if remaining > 0 then
                data.shadow_eruption_cooldown = remaining
            end
        end
        if inst._night_hunter_leap_cd_end then
            local remaining = inst._night_hunter_leap_cd_end - GLOBAL.GetTime()
            if remaining > 0 then
                data.night_hunter_leap_cooldown = remaining
            end
        end
        if ShadowMinionPool then
            local pool_data = ShadowMinionPool.OnSave(inst)
            if pool_data then
                data.shadow_minion_pool = pool_data
            end
        end
    end
    local old_onload = inst.OnLoad
    inst.OnLoad = function(inst, data)
        if old_onload then old_onload(inst, data) end
        if data then
            inst.demon_time_total = data.demon_time_total or 0
            inst.demonic_energy = data.demonic_energy or 0
            inst:UpdateDemonicNetvar()
            inst:PushEvent("demonic_energy_changed", {percent = inst:GetDemonicPercent()})
            if data.last_stand_ready ~= nil then
                inst._last_stand_ready = data.last_stand_ready
            end
            if data.shadow_summon_cooldown and data.shadow_summon_cooldown > 0 then
                inst._shadow_summon_cooldown = GLOBAL.GetTime() + data.shadow_summon_cooldown
            end
            if data.shadow_eruption_cooldown and data.shadow_eruption_cooldown > 0 then
                inst._kodi_eruption_cd_end = GLOBAL.GetTime() + data.shadow_eruption_cooldown
            end
            if data.night_hunter_leap_cooldown and data.night_hunter_leap_cooldown > 0 then
                inst._night_hunter_leap_cd_end = GLOBAL.GetTime() + data.night_hunter_leap_cooldown
            end
            if data.shadow_minion_pool and ShadowMinionPool then
                ShadowMinionPool.OnLoad(inst, data.shadow_minion_pool)
            end
        end
    end
end
return DemonicEnergy
