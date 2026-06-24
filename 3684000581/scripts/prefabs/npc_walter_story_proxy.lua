local NPC_TUNING = require("npc_tuning")

local function OnNotNight(inst, isnight)
    if not isnight
        and inst.storyteller ~= nil
        and inst.storyteller:IsValid()
        and inst.storyteller.components.storyteller ~= nil then
        inst.storyteller.components.storyteller:AbortStory("天亮了，故事下次继续。")
    end
end

local function OnFuelSectionChanged(inst, data)
    if data ~= nil
        and data.newsection == 0
        and inst.storyteller ~= nil
        and inst.storyteller:IsValid()
        and inst.storyteller.components.storyteller ~= nil then
        inst.storyteller.components.storyteller:AbortStory("火灭了，故事讲不下去了。")
    end
end

local function AuraFn(inst, observer)
    local per_min = NPC_TUNING.WALTER_STORY_SANITY_PER_MIN or 10
    local val = per_min / 60
    local storyteller = inst.storyteller
    if storyteller ~= nil and storyteller:IsValid() and storyteller == observer then
        local x, y, z = inst.Transform:GetWorldPosition()
        local radius = NPC_TUNING.WALTER_STORY_SANITY_RADIUS or 4
        local radius_sq = radius * radius
        local audience = 0
        for _, player in ipairs(AllPlayers) do
            if player ~= observer
                and not IsEntityDeadOrGhost(player)
                and player.entity:IsVisible()
                and player:GetDistanceSqToPoint(x, y, z) < radius_sq then
                audience = audience + 1
            end
        end
        if audience > 0 then
            local base = NPC_TUNING.WALTER_STORY_SELF_AUDIENCE_MULT or 1.5
            local bonus = NPC_TUNING.WALTER_STORY_SELF_AUDIENCE_BONUS or 0.05
            local max_extra = NPC_TUNING.WALTER_STORY_SELF_AUDIENCE_MAX_EXTRA or 5
            val = val * (base + bonus * math.min(max_extra, audience - 1))
        end
    end
    return val
end

local function Setup(inst, storyteller, prop)
    inst.entity:SetParent(prop.entity)
    inst.storyteller = storyteller
    inst:ListenForEvent("onfueldsectionchanged", OnFuelSectionChanged, prop)
end

local function fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddNetwork()

    inst:AddTag("NOBLOCK")
    inst.entity:SetCanSleep(false)
    inst.persists = false

    inst.entity:SetPristine()
    if not TheWorld.ismastersim then
        return inst
    end

    inst:AddComponent("sanityaura")
    local radius = NPC_TUNING.WALTER_STORY_SANITY_RADIUS or 4
    inst.components.sanityaura.max_distsq = radius * radius
    inst.components.sanityaura.aurafn = AuraFn
    inst.components.sanityaura.fallofffn = function() return 1 end

    inst:WatchWorldState("isnight", OnNotNight)
    inst.Setup = Setup

    return inst
end

return Prefab("npc_walter_story_proxy", fn)
