local KodiUtils = require("kodi_utils")
local ShadowCache = {}
ShadowCache.MAX_SLOTS = 9
ShadowCache.COOLDOWN = 10
ShadowCache.ENERGY_COST = 5
ShadowCache.SANITY_COST = 10
ShadowCache.COLOR = {
    r = 0.4,
    g = 0.2,
    b = 0.6,
    a = 1.0
}
function ShadowCache.CreateOpenState()
    return State {
        name = "kodi_shadow_cache_open",
        tags = { "nodangle" },
        onenter = function(inst)
            if inst.components and inst.components.locomotor then
                inst.components.locomotor:Stop()
            end
            inst.AnimState:PlayAnimation("channel_pre")
            inst.AnimState:PushAnimation("channel_loop", true)
            local x, y, z = inst.Transform:GetWorldPosition()
            local facing = inst.Transform:GetRotation() * DEGREES
            local offset_x = x + math.cos(facing) * 1.5
            local offset_z = z - math.sin(facing) * 1.5
            inst._shadow_cache_fx_pos = { x = offset_x, y = y, z = offset_z }
            inst._shadow_cache_fx_list = {}
            local ground_shadow = SpawnPrefab("warningshadow")
            if ground_shadow then
                ground_shadow.Transform:SetPosition(offset_x, y, offset_z)
                ground_shadow.Transform:SetScale(1.8, 1.8, 1.8)
                table.insert(inst._shadow_cache_fx_list, ground_shadow)
            end
            local glob = SpawnPrefab("shadow_glob_fx")
            if glob then
                glob.Transform:SetPosition(offset_x, y, offset_z)
            end
            local teleport = SpawnPrefab("shadow_teleport_in")
            if teleport then
                teleport.Transform:SetPosition(offset_x, y, offset_z)
            end
            local trans = SpawnPrefab("statue_transition_2")
            if trans then
                trans.Transform:SetPosition(offset_x, y, offset_z)
            end
            local ring = SpawnPrefab("groundpoundring_fx")
            if ring then
                ring.Transform:SetPosition(offset_x, y, offset_z)
            end
            for i = 1, 4 do
                local angle = (i / 4) * 2 * math.pi
                local puff = SpawnPrefab("shadow_puff")
                if puff then
                    puff.Transform:SetPosition(
                        offset_x + math.cos(angle) * 0.8,
                        y,
                        offset_z + math.sin(angle) * 0.8
                    )
                end
            end
            inst.SoundEmitter:PlaySound("dontstarve/sanity/creature2/taunt")
            inst._shadow_cache_loop_task = inst:DoPeriodicTask(0.8, function()
                if inst._shadow_cache_fx_pos then
                    local pos = inst._shadow_cache_fx_pos
                    local teleport = SpawnPrefab("shadow_teleport_in")
                    if teleport then
                        teleport.Transform:SetPosition(pos.x, pos.y, pos.z)
                    end
                    local glob = SpawnPrefab("shadow_glob_fx")
                    if glob then
                        local ox = pos.x + (math.random() - 0.5) * 0.8
                        local oz = pos.z + (math.random() - 0.5) * 0.8
                        glob.Transform:SetPosition(ox, pos.y, oz)
                        if glob.AnimState then
                            local scale = 0.4 + math.random() * 0.3
                            glob.AnimState:SetScale(scale, scale, 1)
                        end
                    end
                    if math.random() < 0.4 then
                        local puff = SpawnPrefab("shadow_puff")
                        if puff then
                            local ox = pos.x + (math.random() - 0.5) * 0.5
                            local oz = pos.z + (math.random() - 0.5) * 0.5
                            puff.Transform:SetPosition(ox, pos.y, oz)
                        end
                    end
                end
            end)
            if KodiUtils.IsMasterSim() then
                inst:DoTaskInTime(0.2, function()
                    if inst.DoOpenShadowCacheInternal then
                        inst:DoOpenShadowCacheInternal()
                    end
                end)
            end
        end,
        events = {
            EventHandler("attacked", function(inst)
                if inst._shadow_cache_open and inst.DoCloseShadowCache then
                    inst:DoCloseShadowCache()
                end
            end),
        },
        onexit = function(inst)
            if inst._shadow_cache_loop_task then
                inst._shadow_cache_loop_task:Cancel()
                inst._shadow_cache_loop_task = nil
            end
            if inst._shadow_cache_fx_list then
                for _, fx in ipairs(inst._shadow_cache_fx_list) do
                    if fx and fx:IsValid() then
                        fx:Remove()
                    end
                end
                inst._shadow_cache_fx_list = nil
            end
            inst._shadow_cache_fx_pos = nil
        end,
    }
end
function ShadowCache.SpawnCloseEffects(inst, x, y, z)
    local facing = inst.Transform:GetRotation() * DEGREES
    local offset_x = x + math.cos(facing) * 1.5
    local offset_z = z - math.sin(facing) * 1.5
    ShadowCache.SpawnCloseEffectsAt(inst, offset_x, y, offset_z)
end
function ShadowCache.SpawnCloseEffectsAt(inst, x, y, z)
    local teleport = SpawnPrefab("shadow_teleport_out")
    if teleport then
        teleport.Transform:SetPosition(x, y, z)
    end
    local trans = SpawnPrefab("statue_transition_2")
    if trans then
        trans.Transform:SetPosition(x, y, z)
    end
    local ring = SpawnPrefab("groundpoundring_fx")
    if ring then
        ring.Transform:SetPosition(x, y, z)
    end
    for i = 1, 4 do
        local angle = (i / 4) * 2 * math.pi
        local puff = SpawnPrefab("shadow_puff")
        if puff then
            puff.Transform:SetPosition(
                x + math.cos(angle) * 0.6,
                y,
                z + math.sin(angle) * 0.6
            )
        end
    end
    inst.SoundEmitter:PlaySound("dontstarve/sanity/creature2/taunt")
end
function ShadowCache.Initialize(inst)
    if not inst._shadow_cache_items then
        inst._shadow_cache_items = {}
    end
    inst._shadow_cache_cooldown = inst._shadow_cache_cooldown or 0
    inst._shadow_cache_open = false
end
function ShadowCache.CanOpen(inst)
    if not inst:HasTag("kodi_shadow_cache") then
        return false, "no_skill"
    end
    if inst._shadow_cache_open then
        return false, "already_open"
    end
    local remaining = inst._shadow_cache_cooldown - GetTime()
    if remaining > 0 then
        return false, "cooldown", math.ceil(remaining)
    end
    local current_energy = inst.demonic_energy or 0
    if current_energy < ShadowCache.ENERGY_COST then
        return false, "no_energy"
    end
    return true
end
function ShadowCache.Open(inst)
    local can_open, reason, remaining = ShadowCache.CanOpen(inst)
    if not can_open then
        if reason == "cooldown" then
            inst.components.talker:Say("*" .. remaining .. "s*", 1, true)
        elseif reason == "already_open" then
            inst.components.talker:Say(STRINGS.KODI_SPEECH and STRINGS.KODI_SPEECH.CACHE_ALREADY_OPEN or "*already open*", 1.5, true)
        elseif reason == "no_energy" then
            inst.components.talker:Say(STRINGS.KODI_SPEECH and STRINGS.KODI_SPEECH.NO_ENERGY or "*not enough energy*", 1.5, true)
        end
        return false
    end
    if inst.demonic_energy then
        inst.demonic_energy = math.max(0, inst.demonic_energy - ShadowCache.ENERGY_COST)
        if inst.UpdateDemonicNetvar then
            inst:UpdateDemonicNetvar()
        end
        inst:PushEvent("demonic_energy_changed", {percent = inst:GetDemonicPercent()})
    end
    if inst.components.sanity then
        inst.components.sanity:DoDelta(-ShadowCache.SANITY_COST)
    end
    inst._shadow_cache_cooldown = GetTime() + ShadowCache.COOLDOWN
    inst._shadow_cache_open = true
    if inst.sg and inst.sg.GoToState then
        inst.sg:GoToState("kodi_shadow_cache_open")
    else
        ShadowCache.OpenInternal(inst)
    end
    return true
end
function ShadowCache.OpenInternal(inst)
    ShadowCache.CreateContainer(inst)
    if inst.components.talker then
        inst.components.talker:Say(STRINGS.KODI_SPEECH and STRINGS.KODI_SPEECH.CACHE_OPEN or "*the shadows part...*", 2, true)
    end
end
function ShadowCache.Close(inst)
    if not inst._shadow_cache_open then return end
    if inst._shadow_cache_closing then return end
    inst._shadow_cache_closing = true
    inst._shadow_cache_open = false
    if inst._shadow_cache_loop_task then
        inst._shadow_cache_loop_task:Cancel()
        inst._shadow_cache_loop_task = nil
    end
    if inst._shadow_cache_fx_list then
        for _, fx in ipairs(inst._shadow_cache_fx_list) do
            if fx and fx:IsValid() then
                fx:Remove()
            end
        end
        inst._shadow_cache_fx_list = nil
    end
    local x, y, z = inst.Transform:GetWorldPosition()
    if inst._shadow_cache_fx_pos then
        local pos = inst._shadow_cache_fx_pos
        ShadowCache.SpawnCloseEffectsAt(inst, pos.x, pos.y, pos.z)
        inst._shadow_cache_fx_pos = nil
    else
        ShadowCache.SpawnCloseEffects(inst, x, y, z)
    end
    ShadowCache.CloseContainer(inst)
    if inst.sg then
        inst.sg:GoToState("idle")
    end
    if inst.components.talker then
        inst.components.talker:Say(STRINGS.KODI_SPEECH and STRINGS.KODI_SPEECH.CACHE_CLOSE or "*sealed away*", 1.5, true)
    end
    inst._shadow_cache_closing = false
end
function ShadowCache.Toggle(inst)
    if inst._shadow_cache_open then
        ShadowCache.Close(inst)
    else
        ShadowCache.Open(inst)
    end
end
function ShadowCache.CreateContainer(inst)
    if not KodiUtils.IsMasterSim() then
        return
    end
    if inst._shadow_cache_container and inst._shadow_cache_container:IsValid() then
        inst._shadow_cache_container.components.container:Open(inst)
        return
    end
    local container = SpawnPrefab("kodi_shadow_cache")
    if not container then
        return
    end
    local x, y, z = inst.Transform:GetWorldPosition()
    container.Transform:SetPosition(x, y, z)
    ShadowCache.LoadItems(inst, container)
    inst._shadow_cache_container = container
    container.components.container:Open(inst)
    inst:DoTaskInTime(0.2, function()
        if container and container:IsValid() then
            inst:ListenForEvent("onclose", function()
                if inst._shadow_cache_open then
                    ShadowCache.SaveItems(inst, container)
                    inst._shadow_cache_items_saved = true
                    ShadowCache.Close(inst)
                end
            end, container)
        end
    end)
end
function ShadowCache.CloseContainer(inst)
    if inst._shadow_cache_container and inst._shadow_cache_container:IsValid() then
        if not inst._shadow_cache_items_saved then
            ShadowCache.SaveItems(inst, inst._shadow_cache_container)
        end
        inst._shadow_cache_items_saved = false
        if inst._shadow_cache_container.components.container then
            inst._shadow_cache_container.components.container:Close()
        end
        inst._shadow_cache_container:Remove()
        inst._shadow_cache_container = nil
    end
end
local function SpawnLegacyItem(item_data)
    local item = SpawnPrefab(item_data.prefab)
    if not item then return nil end
    if item.components.stackable and item_data.stacksize and item_data.stacksize > 1 then
        item.components.stackable:SetStackSize(item_data.stacksize)
    end
    if item.components.perishable and item_data.percent then
        item.components.perishable:SetPercent(item_data.percent)
    end
    if item.components.finiteuses and item_data.uses then
        item.components.finiteuses:SetUses(item_data.uses)
    end
    if item.components.fueled and item_data.fuel then
        item.components.fueled:SetPercent(item_data.fuel)
    end
    return item
end
function ShadowCache.SaveItems(inst, container)
    if not container or not container.components.container then return end
    inst._shadow_cache_items = {}
    local slots = container.components.container:GetNumSlots()
    for i = 1, math.min(slots, ShadowCache.MAX_SLOTS) do
        local item = container.components.container:GetItemInSlot(i)
        if item and item:IsValid() and item.persists then
            table.insert(inst._shadow_cache_items, {
                slot = i,
                record = item:GetSaveRecord(),
            })
        end
    end
end
function ShadowCache.LoadItems(inst, container)
    if not container or not container.components.container then return end
    if not inst._shadow_cache_items then return end
    if #inst._shadow_cache_items == 0 then return end
    for _, item_data in ipairs(inst._shadow_cache_items) do
        local item
        if item_data.record then
            item = SpawnSaveRecord(item_data.record)
        elseif item_data.prefab then
            item = SpawnLegacyItem(item_data)
        end
        if item then
            container.components.container:GiveItem(item, item_data.slot or nil)
        end
    end
end
function ShadowCache.OnSave(inst, data)
    if inst._shadow_cache_items and #inst._shadow_cache_items > 0 then
        data.shadow_cache_items = inst._shadow_cache_items
    end
end
function ShadowCache.OnLoad(inst, data)
    if data and data.shadow_cache_items then
        inst._shadow_cache_items = data.shadow_cache_items
    end
end
function ShadowCache.SetupPlayer(inst)
    ShadowCache.Initialize(inst)
    inst.DoOpenShadowCache = function(self)
        return ShadowCache.Toggle(self)
    end
    inst.DoOpenShadowCacheInternal = function(self)
        return ShadowCache.OpenInternal(self)
    end
    inst.DoCloseShadowCache = function(self)
        return ShadowCache.Close(self)
    end
    local old_onsave = inst.OnSave
    inst.OnSave = function(inst, data)
        if old_onsave then old_onsave(inst, data) end
        ShadowCache.OnSave(inst, data)
    end
    local old_onload = inst.OnLoad
    inst.OnLoad = function(inst, data)
        if old_onload then old_onload(inst, data) end
        ShadowCache.OnLoad(inst, data)
    end
    inst:ListenForEvent("death", function()
        if inst._shadow_cache_open then
            ShadowCache.Close(inst)
        end
    end)
    inst:ListenForEvent("attacked", function()
        if inst._shadow_cache_open then
            ShadowCache.Close(inst)
        end
    end)
    inst:ListenForEvent("onremove", function()
        if inst._shadow_cache_open then
            ShadowCache.Close(inst)
        end
    end)
end
return ShadowCache
