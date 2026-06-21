local ShadowMinion = require("skills/shadow_minion")
local ShadowMinionPool = require("skills/shadow_minion_pool")
local SpiderMerge = {}
SpiderMerge.MERGE_RADIUS = 8
SpiderMerge.CONVERGENCE_DIST = 2
SpiderMerge.CONVERGENCE_CHECK_RATE = 0.5
local function FindWalkablePoint(owner, radius)
    local ox, oy, oz = owner.Transform:GetWorldPosition()
    for i = 1, 10 do
        local angle = math.random() * 2 * math.pi
        local dist = radius * 0.5 + math.random() * radius * 0.5
        local tx = ox + math.cos(angle) * dist
        local tz = oz + math.sin(angle) * dist
        if TheWorld.Map:IsPassableAtPoint(tx, 0, tz) then
            return Vector3(tx, 0, tz)
        end
    end
    return Vector3(ox, 0, oz)
end
function SpiderMerge.OnDarkCrystalFed(minion, owner)
    if not minion:IsValid() or not owner:IsValid() then return end
    minion._fed_darkcrystal = true
    if minion.AnimState then
        minion.AnimState:SetMultColour(0.5, 0.2, 0.8, 1.0)
        minion:DoTaskInTime(0.5, function()
            if minion:IsValid() and minion.AnimState then
                minion.AnimState:SetMultColour(0.3, 0.1, 0.4, 0.8)
            end
        end)
    end
    if owner.components.talker then
        local fed_count = 0
        local warriors = SpiderMerge.GetFedSpiderWarriors(owner)
        fed_count = #warriors
        if fed_count < 3 then
            local msg = STRINGS.KODI_SPEECH and STRINGS.KODI_SPEECH.SPIDER_FED
                or string.format("*%d/3 shadows empowered...*", fed_count)
            owner.components.talker:Say(msg, 2, true)
        end
    end
    local fed_warriors = SpiderMerge.GetFedSpiderWarriors(owner)
    if #fed_warriors >= 3 then
        SpiderMerge.StartMerge(owner, fed_warriors)
    end
end
function SpiderMerge.GetFedSpiderWarriors(owner)
    if not owner._shadow_pool then return {} end
    local fed = {}
    for _, minion in ipairs(owner._shadow_pool.active_minions) do
        if minion:IsValid() and minion.prefab == "spider_warrior" and minion._fed_darkcrystal then
            table.insert(fed, minion)
        end
    end
    return fed
end
function SpiderMerge.StartMerge(owner, spiders)
    if owner._spider_merge_active then return end
    owner._spider_merge_active = true
    local convergence_point = FindWalkablePoint(owner, SpiderMerge.MERGE_RADIUS)
    if owner.components.talker then
        local msg = STRINGS.KODI_SPEECH and STRINGS.KODI_SPEECH.SPIDER_MERGE_START
            or "*the shadows converge...*"
        owner.components.talker:Say(msg, 2.5, true)
    end
    for _, spider in ipairs(spiders) do
        spider._merge_convergence_point = convergence_point
        if spider._follow_task then
            spider._follow_task:Cancel()
            spider._follow_task = nil
        end
        if spider.components.combat then
            spider.components.combat:SetTarget(nil)
            spider.components.combat:SetRetargetFunction(1, function() return nil end)
        end
        spider._merge_walk_task = spider:DoPeriodicTask(0.5, function()
            if not spider:IsValid() or not spider._merge_convergence_point then return end
            local sx, sy, sz = spider.Transform:GetWorldPosition()
            local tx, ty, tz = spider._merge_convergence_point.x, 0, spider._merge_convergence_point.z
            local dist = math.sqrt((tx - sx)^2 + (tz - sz)^2)
            if dist > SpiderMerge.CONVERGENCE_DIST and spider.components.locomotor then
                spider.components.locomotor:GoToPoint(spider._merge_convergence_point)
            elseif spider.components.locomotor then
                spider.components.locomotor:Stop()
            end
        end)
        spider._merge_death_listener = function()
            SpiderMerge.CancelMerge(owner, spiders, "spider died")
        end
        spider:ListenForEvent("death", spider._merge_death_listener)
        spider:ListenForEvent("onremove", spider._merge_death_listener)
    end
    owner._merge_check_task = owner:DoPeriodicTask(SpiderMerge.CONVERGENCE_CHECK_RATE, function()
        if not owner:IsValid() or not owner._spider_merge_active then
            if owner._merge_check_task then
                owner._merge_check_task:Cancel()
                owner._merge_check_task = nil
            end
            return
        end
        for _, spider in ipairs(spiders) do
            if not spider:IsValid() then
                SpiderMerge.CancelMerge(owner, spiders, "spider invalid")
                return
            end
        end
        local all_converged = true
        for _, spider in ipairs(spiders) do
            local sx, sy, sz = spider.Transform:GetWorldPosition()
            local tx, tz = convergence_point.x, convergence_point.z
            local dist = math.sqrt((tx - sx)^2 + (tz - sz)^2)
            if dist > SpiderMerge.CONVERGENCE_DIST then
                all_converged = false
                break
            end
        end
        if all_converged then
            if owner._merge_check_task then
                owner._merge_check_task:Cancel()
                owner._merge_check_task = nil
            end
            SpiderMerge.OnAllConverged(owner, spiders, convergence_point)
        end
    end)
    owner._merge_timeout_task = owner:DoTaskInTime(30, function()
        if owner._spider_merge_active then
            SpiderMerge.CancelMerge(owner, spiders, "timeout")
        end
    end)
end
function SpiderMerge.CancelMerge(owner, spiders, reason)
    if not owner._spider_merge_active then return end
    owner._spider_merge_active = nil
    if owner:IsValid() then
        owner:RemoveTag("vigorbuff")
    end
    if owner._merge_check_task then
        owner._merge_check_task:Cancel()
        owner._merge_check_task = nil
    end
    if owner._merge_timeout_task then
        owner._merge_timeout_task:Cancel()
        owner._merge_timeout_task = nil
    end
    for _, spider in ipairs(spiders) do
        if spider:IsValid() then
            if spider._merge_death_listener then
                spider:RemoveEventCallback("death", spider._merge_death_listener)
                spider:RemoveEventCallback("onremove", spider._merge_death_listener)
                spider._merge_death_listener = nil
            end
            if spider._merge_walk_task then
                spider._merge_walk_task:Cancel()
                spider._merge_walk_task = nil
            end
            spider._fed_darkcrystal = false
            spider._merge_convergence_point = nil
            ShadowMinion.ConfigureAI(spider, owner)
        end
    end
    if owner:IsValid() and owner.components.talker then
        local msg = STRINGS.KODI_SPEECH and STRINGS.KODI_SPEECH.SPIDER_MERGE_FAILED
            or "*the merge failed...*"
        owner.components.talker:Say(msg, 2, true)
    end
end
function SpiderMerge.OnAllConverged(owner, spiders, position)
    local sum_lifetime = TUNING.KODI_SHADOW_SPIDERQUEEN_BASE_LIFETIME or 300
    for _, spider in ipairs(spiders) do
        if spider:IsValid() and spider._shadow_lifetime_end then
            local remaining = math.max(0, spider._shadow_lifetime_end - GetTime())
            sum_lifetime = sum_lifetime + remaining
        end
    end
    local x, y, z = position.x, 0, position.z
    for _, spider in ipairs(spiders) do
        if spider:IsValid() then
            if spider._merge_walk_task then
                spider._merge_walk_task:Cancel()
                spider._merge_walk_task = nil
            end
            if spider._merge_death_listener then
                spider:RemoveEventCallback("death", spider._merge_death_listener)
                spider:RemoveEventCallback("onremove", spider._merge_death_listener)
                spider._merge_death_listener = nil
            end
            if spider.brain then
                spider.brain:Stop()
            end
            if spider.components.locomotor then
                spider.components.locomotor:Stop()
            end
            if spider.components.combat then
                spider.components.combat:SetTarget(nil)
            end
            spider.Transform:SetPosition(x, y, z)
            spider:Hide()
        end
    end
    local cocoon = SpawnPrefab("shadow_merge_cocoon")
    cocoon.Transform:SetPosition(x, y, z)
    owner:AddTag("vigorbuff")
    owner.SoundEmitter:PlaySound("dontstarve/sanity/shadowrock_up")
    if spiders[1] and spiders[1]:IsValid() then
        local fx = SpawnPrefab("shadow_puff_large_front")
        if fx then fx.Transform:SetPosition(x, y, z) end
        ShadowMinionPool.UnregisterMinion(owner, spiders[1])
        spiders[1]:Remove()
    end
    cocoon.AnimState:PlayAnimation("grow_sac_to_small")
    cocoon.AnimState:PushAnimation("cocoon_small", true)
    cocoon.SoundEmitter:PlaySound("dontstarve/creatures/spider/cocoon_growB")
    owner:DoTaskInTime(1.5, function()
        if not owner:IsValid() or not cocoon:IsValid() then return end
        if spiders[2] and spiders[2]:IsValid() then
            local fx = SpawnPrefab("shadow_puff_large_front")
            if fx then fx.Transform:SetPosition(x, y, z) end
            ShadowMinionPool.UnregisterMinion(owner, spiders[2])
            spiders[2]:Remove()
        end
        cocoon.AnimState:PlayAnimation("grow_small_to_medium")
        cocoon.AnimState:PushAnimation("cocoon_medium", true)
        cocoon.SoundEmitter:PlaySound("dontstarve/creatures/spider/cocoon_growB")
    end)
    owner:DoTaskInTime(3.0, function()
        if not owner:IsValid() or not cocoon:IsValid() then return end
        if spiders[3] and spiders[3]:IsValid() then
            local fx = SpawnPrefab("shadow_puff_large_front")
            if fx then fx.Transform:SetPosition(x, y, z) end
            ShadowMinionPool.UnregisterMinion(owner, spiders[3])
            spiders[3]:Remove()
        end
        cocoon.AnimState:PlayAnimation("grow_medium_to_large")
        cocoon.AnimState:PushAnimation("cocoon_large", true)
        cocoon.SoundEmitter:PlaySound("dontstarve/creatures/spider/cocoon_growB")
    end)
    local pillars = {}
    owner:DoTaskInTime(5.0, function()
        if not owner:IsValid() or not cocoon:IsValid() then return end
        for i = 1, 5 do
            local angle = (i / 5) * 2 * math.pi
            local radius = 2.5
            local pillar = SpawnPrefab("shadow_pillar")
            if pillar then
                pillar.Transform:SetPosition(x + math.cos(angle) * radius, y, z + math.sin(angle) * radius)
                pillar.Transform:SetScale(0.8, 1.1, 0.8)
                table.insert(pillars, pillar)
            end
        end
        local ground_fx = SpawnPrefab("statue_transition_2")
        if ground_fx then ground_fx.Transform:SetPosition(x, y, z) end
        owner.SoundEmitter:PlaySound("dontstarve/sanity/shadowrock_up")
    end)
    owner:DoTaskInTime(6.5, function()
        if not owner:IsValid() then return end
        for i, pillar in ipairs(pillars) do
            owner:DoTaskInTime((i - 1) * 0.25, function()
                if pillar and pillar:IsValid() then
                    local px, py, pz = pillar.Transform:GetWorldPosition()
                    local lightning = SpawnPrefab("lightning")
                    if lightning then lightning.Transform:SetPosition(px, py, pz) end
                end
            end)
        end
    end)
    owner:DoTaskInTime(7.5, function()
        if not owner:IsValid() or not cocoon:IsValid() then return end
        local lightning = SpawnPrefab("lightning")
        if lightning then lightning.Transform:SetPosition(x, y, z) end
        cocoon.AnimState:PlayAnimation("cocoon_large_burst")
        cocoon.SoundEmitter:PlaySound("dontstarve/creatures/spider/cocoon_destroy")
    end)
    owner:DoTaskInTime(8.5, function()
        if not owner:IsValid() then
            if cocoon and cocoon:IsValid() then cocoon:Remove() end
            owner._spider_merge_active = nil
            return
        end
        if cocoon and cocoon:IsValid() then
            cocoon:Remove()
        end
        owner:RemoveTag("vigorbuff")
        for _, pillar in ipairs(pillars) do
            if pillar and pillar:IsValid() then
                pillar:PushEvent("timerdone", { name = "lifetime" })
            end
        end
        local queen = SpawnPrefab("shadow_spiderqueen")
        if queen then
            queen.Transform:SetPosition(x, y, z)
            queen:SetOwner(owner)
            ShadowMinion.SetLifetime(queen, owner, sum_lifetime)
            ShadowMinion.SetupDeathExplosion(queen, owner)
            ShadowMinionPool.RegisterMinion(owner, queen)
            queen._shadow_owner = owner
            queen._shadow_owner_userid = owner.userid
            local burst_fx = SpawnPrefab("shadow_despawn")
            if burst_fx then
                burst_fx.Transform:SetPosition(x, y, z)
                burst_fx.Transform:SetScale(2, 2, 2)
            end
            local ring = SpawnPrefab("groundpoundring_fx")
            if ring then ring.Transform:SetPosition(x, y, z) end
            ShakeAllCameras(CAMERASHAKE.FULL, 0.7, 0.04, 0.3, Vector3(x, y, z), 25)
            owner.SoundEmitter:PlaySound("dontstarve/cave/nightmare_spawner_open")
            owner.SoundEmitter:PlaySound("dontstarve/creatures/spider_queen/scream")
            if owner.components.talker then
                local msg = STRINGS.KODI_SPEECH and STRINGS.KODI_SPEECH.SPIDER_QUEEN_BORN
                    or "*a queen rises from the shadows!*"
                owner.components.talker:Say(msg, 3, true)
            end
        end
        owner._spider_merge_active = nil
        if owner._merge_timeout_task then
            owner._merge_timeout_task:Cancel()
            owner._merge_timeout_task = nil
        end
    end)
end
return SpiderMerge
