local assets =
{
    Asset("ANIM", "anim/shengaiquan.zip"),
}

local gw_soul_common = require("prefabs/gw_soul_common")

local CHECK_INTERVAL = 0.1 -- 每 0.1 秒检测一次
local EFFECT_RADIUS = 3.5 -- 作用范围
local FX_LIFETIME = 10 -- 持续时间

-- **检查范围内的 gwen 角色，添加或移除 "shengaifanwei" 标签**
local function CheckNearbyEntities(inst)
    if not inst:IsValid() then
        return
    end

    local x, y, z = inst.Transform:GetWorldPosition()
    local ents = TheSim:FindEntities(x, y, z, EFFECT_RADIUS + 1, { "gwen" }) -- 查找带有 "gwen" 标签的目标

    for _, target in ipairs(ents) do
        if target:IsValid() and target.entity:IsVisible() then
            local tx, ty, tz = target.Transform:GetWorldPosition()
            local dist = math.sqrt((tx - x) * (tx - x) + (tz - z) * (tz - z))

            if dist <= EFFECT_RADIUS then
                if not target:HasTag("shengaifanwei") then
                    target:AddTag("shengaifanwei") -- 添加范围内标签
                end

                if inst._owner and inst._owner.components.skilltreeupdater and inst._owner.components.skilltreeupdater:IsActivated("gwen_shengai_radiance_2") then
                    if target.components.health then
                        target.components.health.externalabsorbmodifiers:SetModifier(inst, 0.3)
                    end
                end
            else
                if target:HasTag("shengaifanwei") then
                    target:RemoveTag("shengaifanwei") -- 超出范围移除标签
                end

                 if target.components.health then
                    target.components.health.externalabsorbmodifiers:RemoveModifier(inst)
                end
            end
        end
    end
end

-- 新增效果
local function a_CheckNearbyEntities(inst)
    if not inst:IsValid() then
        return
    end
    local x, y, z = inst.Transform:GetWorldPosition()
    local ents = TheSim:FindEntities(x, y, z, EFFECT_RADIUS + 1, { "gwen" }) -- 查找带有 "gwen" 标签的目标

    for _, target in ipairs(ents) do
        if target:IsValid() and target.entity:IsVisible() then
			if target.components.gwen_shengai and target.components.health and not target.components.health:IsDead() then
				target.components.gwen_shengai:DoDelta(1)
			end
        end
    end
end

-- **FX 消失时，移除范围内的 "shengaifanwei" 标签**
local function RemoveEffectTag(inst)
    local x, y, z = inst.Transform:GetWorldPosition()
    local ents = TheSim:FindEntities(x, y, z, 200, { "gwen", "shengaifanwei" }) -- 查找范围内带有 "shengaifanwei" 的 gwen

    for _, target in ipairs(ents) do
        if target:IsValid() then
            target:RemoveTag("shengaifanwei") -- 移除标签
        end

        if target.components.health then
            target.components.health.externalabsorbmodifiers:RemoveModifier(inst)
        end
    end
end

local function SetOwner(inst, owner)
    if owner and owner:IsValid() then
        inst._owner = owner
    end
end
local function fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddNetwork()
    inst.entity:AddLight()
    inst.entity:SetCanSleep(false)
    inst.entity:AddFollower()   
    inst.persists = false
    inst.Transform:SetScale(1.2, 1.2, 1.2) -- 物品尺寸调整为原始大小的 1.2 倍
	inst.entity:AddSoundEmitter()
	inst.SoundEmitter:PlaySound("Gwen_sound/Gwen_sfx/Gwen_X",nil,.14)----声音结界

    inst.AnimState:SetBank("shengaiquan")
    inst.AnimState:SetBuild("shengaiquan")
    inst.AnimState:PlayAnimation("appear", false) -- 播放 `appear` 动画
    inst.AnimState:PushAnimation("idle", true)						--播放完上一段动画后播放本动画
    inst.AnimState:SetOrientation(ANIM_ORIENTATION.OnGround)		
    inst.AnimState:SetSortOrder(-1)	   
    inst:AddTag("NOCLICK")
    inst:AddTag("NOBLOCK")   

    MakeInventoryFloatable(inst, "med", 0.05, {1.1, 0.5, 1.1}, true, -9)

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    local light = inst.entity:AddLight()                                               
    light:SetFalloff(0.5)                                                                       
    light:SetIntensity(.8)                                                                       
    light:SetRadius(3)                                                                          
    light:SetColour(0 / 255, 221 / 255, 255 / 255, 1)
    light:Enable(true)                                    
    inst.AnimState:SetBloomEffectHandle("shaders/anim.ksh")		

    inst.persists = false

    -- **监听 `appear` 动画结束后切换到 `idle` 动画**
    inst:ListenForEvent("animover", function()
        inst.AnimState:PlayAnimation("idle", true)
    end)

    -- **定期检查范围内的目标**
    inst.task = inst:DoPeriodicTask(CHECK_INTERVAL, CheckNearbyEntities)
    inst.a_task = inst:DoPeriodicTask(1, a_CheckNearbyEntities)

    -- **4秒后自动移除**
    inst:DoTaskInTime(FX_LIFETIME, function()
        RemoveEffectTag(inst) -- 在移除前，确保清理所有 `shengaifanwei` 标签
        inst:Remove()
    end)

    -- **当 FX 被移除时，清理 "shengaifanwei" 标签**
    inst:ListenForEvent("onremove", function()
        RemoveEffectTag(inst)
    end)

    MakeHauntableLaunch(inst)

    inst.SetOwner = SetOwner

    return inst
end

---- 伤害计算时的相应标签
local COMBAT_MUSTHAVE_TAGS = { "_combat", "_health" }
local COMBAT_CANTHAVE_TAGS = {
    "INLIMBO", "FX", "NOCLICK", "DECOR", 
    "playerghost", "companion", "wall", "abigail", 
    "invisible","notarget"
}

if not TheNet:GetPVPEnabled() then
    table.insert(COMBAT_CANTHAVE_TAGS, "player")
end

local function SpawnGwenSpikeRing(inst, x, z, r, n, theta)
    local delta = TWOPI / n
    local map = TheWorld.Map
    local pt = Vector3(0, 0, 0)
    for i = 1, n do
        pt.x = x + r * math.cos(theta)
        pt.z = z - r * math.sin(theta)
        if map:IsPassableAtPoint(pt.x, 0, pt.z, false, true) then
            local spike = SpawnPrefab("gwen_spike")
            spike.Transform:SetPosition(pt:Get())
            spike:SetOwner(inst)          -- 设置圈为主人
            if inst.spikes then
                table.insert(inst.spikes, spike)
            end
        end
        theta = theta + delta
    end
end

local function DoDamage(inst)
    if not inst:IsValid() or not inst._owner or not inst._owner:IsValid() then
        return
    end

    local weapon_damage = 0
    local weapon_planar_damage = 0
    local damage_multiplier = 1
    
    if inst._owner and inst._owner.components.combat then
        local weapon = inst._owner.components.combat:GetWeapon()
        if weapon then
            weapon_damage = weapon.components.weapon and weapon.components.weapon.damage or 10
            if type(weapon_damage) == "function" then
                weapon_damage = weapon_damage(weapon, inst)
            end
            weapon_planar_damage = weapon.components.planardamage and 
                                   weapon.components.planardamage:GetDamage() or 0
            if inst._owner.components.combat.externaldamagemultipliers then
                damage_multiplier = inst._owner.components.combat.externaldamagemultipliers:Get() or 1
            end
        end
    end

    local base_damage = weapon_damage * damage_multiplier * 1.25
    local planar_damage = weapon_planar_damage

    local x, y, z = inst.Transform:GetWorldPosition()
    local ents = TheSim:FindEntities(x, y, z, 8, COMBAT_MUSTHAVE_TAGS, COMBAT_CANTHAVE_TAGS)

    local owner = inst._owner
    for i, v in ipairs(ents) do
        if v:IsValid() and v.components.combat ~= nil
            and v.components.health ~= nil
            and not v.components.health:IsDead() then

            local final_damage = base_damage
            local is_follower = v.components.follower and 
                               v.components.follower:GetLeader() and 
                               v.components.follower:GetLeader():HasTag("player")
            
            
            local is_domesticatable = v:HasTag("domesticatable")
            local obedience = is_domesticatable and v.components.domesticatable and v.components.domesticatable:GetObedience() or 0
            local domestication = is_domesticatable and v.components.domesticatable and v.components.domesticatable:GetDomestication() or 0
            if not is_follower and
            v ~= owner and
            not (is_domesticatable and (obedience > 0 or domestication > 0))  then
                v.components.combat:GetAttacked(
                    inst._owner,
                    final_damage,
                    nil,
                    nil,
                    {planar = planar_damage}
                )

                if owner.components.skilltreeupdater and owner.components.skilltreeupdater:IsActivated("gwen_shengai_shadow_2") then
                    if gw_soul_common.HasSoul(v) and math.random() < 0.6 then
                       local px, py, pz = v.Transform:GetWorldPosition()
                        gw_soul_common.SpawnSoulAt(px, py, pz, v, true)
                    end
                end
            end
        end
    end
end


local function CheckDoDamage(inst)
    if not inst:IsValid() then
        return
    end

    local x, y, z = inst.Transform:GetWorldPosition()
    local ents = TheSim:FindEntities(x, y, z, 8, COMBAT_MUSTHAVE_TAGS, COMBAT_CANTHAVE_TAGS)

    local owner = inst._owner
    for i, v in ipairs(ents) do
        if v:IsValid() and v.components.combat ~= nil
            and v.components.health ~= nil
            and not v.components.health:IsDead() then

            local is_follower = v.components.follower and 
                               v.components.follower:GetLeader() and 
                               v.components.follower:GetLeader():HasTag("player")
            
            
            local is_domesticatable = v:HasTag("domesticatable")
            local obedience = is_domesticatable and v.components.domesticatable and v.components.domesticatable:GetObedience() or 0
            local domestication = is_domesticatable and v.components.domesticatable and v.components.domesticatable:GetDomestication() or 0
            if not is_follower and
            v ~= owner and
            not (is_domesticatable and (obedience > 0 or domestication > 0))  then
                v.components.combat:GetAttacked(
                    inst._owner,
                    25,
                    nil,
                    nil,
                    {planar = 15}
                )
                if owner.components.health and not owner.components.health:IsDead() then
                    owner.components.health:DoDelta(1.5,nil, "gwen_laolong_xishou")
                end

                if owner.components.skilltreeupdater and owner.components.skilltreeupdater:IsActivated("gwen_shengai_shadow_2") then
                    if gw_soul_common.HasSoul(v) and math.random() < 0.1 then
                        local px, py, pz = v.Transform:GetWorldPosition()
                        gw_soul_common.SpawnSoulAt(px, py, pz, v, true)
                    end
                end
            end
        end
    end
end



local function laolong_fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddNetwork()
    inst.entity:AddLight()
    inst.entity:SetCanSleep(false)
    inst.entity:AddFollower()   
    inst.persists = false
    inst.Transform:SetScale(1.65, 1.65, 1.65)
	inst.entity:AddSoundEmitter()
	inst.SoundEmitter:PlaySound("Gwen_sound/Gwen_sfx/Gwen_X",nil,.14)

    inst.AnimState:SetBank("shengaiquan")
    inst.AnimState:SetBuild("shengaiquan")
    inst.AnimState:PlayAnimation("appear", false)
    inst.AnimState:PushAnimation("idle", true)
    inst.AnimState:SetOrientation(ANIM_ORIENTATION.OnGround)		
    inst.AnimState:SetSortOrder(-1)	   
    inst:AddTag("NOCLICK")
    inst:AddTag("NOBLOCK")   

    inst.AnimState:SetMultColour(0.2, 0.8, 0.5, 1)

    MakeInventoryFloatable(inst, "med", 0.05, {1.1, 0.5, 1.1}, true, -9)

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    local light = inst.entity:AddLight()                                               
    light:SetFalloff(0.5)                                                                       
    light:SetIntensity(.8)                                                                       
    light:SetRadius(3)                                                                          
    light:SetColour(0 / 255, 221 / 255, 155 / 255, 1)
    light:Enable(true)                                    
    inst.AnimState:SetBloomEffectHandle("shaders/anim.ksh")		

    inst.persists = false

    inst.spikes = {}

    inst:ListenForEvent("animover", function()
        inst.AnimState:PlayAnimation("idle", true)
    end)

    inst:DoTaskInTime(0.6, function()
        DoDamage(inst)
        local theta = math.random() * TWOPI
        local x, y, z = inst.Transform:GetWorldPosition()
        SpawnGwenSpikeRing(inst, x, z, 7.2, 28, theta + TWOPI / 1.5)
    end)

    inst.damage_task = inst:DoPeriodicTask(1, CheckDoDamage)

    inst:DoTaskInTime(FX_LIFETIME, function()
        inst:Remove()
        if inst.spikes then
            for i, spike in ipairs(inst.spikes) do
                if spike:IsValid() and spike.KillSpike then
                    spike:KillSpike()
                end
            end
            inst.spikes = nil
        end
    end)


    MakeHauntableLaunch(inst)

    inst.SetOwner = SetOwner

    return inst
end

local SCORCH_RED_FRAMES = 20
local SCORCH_DELAY_FRAMES = 40
local SCORCH_FADE_FRAMES = 15

local function Scorch_OnFadeDirty(inst)
    --V2C: hack alert: using SetHightlightColour to achieve something like OverrideAddColour
    --     (that function does not exist), because we know this FX can never be highlighted!
    if inst._fade:value() > SCORCH_FADE_FRAMES + SCORCH_DELAY_FRAMES then
        local k = (inst._fade:value() - SCORCH_FADE_FRAMES - SCORCH_DELAY_FRAMES) / SCORCH_RED_FRAMES
        inst.AnimState:OverrideMultColour(1, 1, 1, 1)
        inst.AnimState:SetHighlightColour(k, k, k, k)
    elseif inst._fade:value() >= SCORCH_FADE_FRAMES then
        inst.AnimState:OverrideMultColour(1, 1, 1, 1)
        inst.AnimState:SetHighlightColour()
    else
        local k = inst._fade:value() / SCORCH_FADE_FRAMES
        k = k * k
        inst.AnimState:OverrideMultColour(1, 1, 1, k)
        inst.AnimState:SetHighlightColour()
    end
end

local function Scorch_OnUpdateFade(inst)
    if inst._fade:value() > 1 then
        inst._fade:set_local(inst._fade:value() - 1)
        Scorch_OnFadeDirty(inst)
    elseif TheWorld.ismastersim then
        inst:Remove()
    elseif inst._fade:value() > 0 then
        inst._fade:set_local(0)
        inst.AnimState:OverrideMultColour(1, 1, 1, 0)
    end
end

local function scorchfn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddNetwork()

    inst.AnimState:SetBuild("burntground")
    inst.AnimState:SetBank("burntground")
    inst.AnimState:PlayAnimation("idle")
    inst.AnimState:SetOrientation(ANIM_ORIENTATION.OnGround)
    inst.AnimState:SetLayer(LAYER_BACKGROUND)
    inst.AnimState:SetSortOrder(3)

    inst:AddTag("NOCLICK")
    inst:AddTag("FX")

    inst._fade = net_byte(inst.GUID, "deerclops_laserscorch._fade", "fadedirty")
    inst._fade:set(SCORCH_RED_FRAMES + SCORCH_DELAY_FRAMES + SCORCH_FADE_FRAMES)

    inst:DoPeriodicTask(0, Scorch_OnUpdateFade)
    Scorch_OnFadeDirty(inst)

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        inst:ListenForEvent("fadedirty", Scorch_OnFadeDirty)

        return inst
    end

    inst.Transform:SetRotation(math.random() * 360)
    inst.persists = false

    return inst
end

return Prefab("shengaifx", fn, assets),
    Prefab("gwen_chongquan_fx", scorchfn, assets),
    Prefab("gwen_laolong", laolong_fn, assets)
