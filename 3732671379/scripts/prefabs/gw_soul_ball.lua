local assets =
{
    Asset("ANIM", "anim/gw_soul_ball.zip"),
    Asset("SCRIPT", "scripts/prefabs/gw_soul_common.lua"),
    Asset("ATLAS", "images/inventoryimages/gw_soul_ball.xml"),
    Asset("IMAGE", "images/inventoryimages/gw_soul_ball.tex"),
}


local SCALE = .8
local SPEED = 10

local gw_soul_common = require("prefabs/gw_soul_common")


local function CreateTail()
    local inst = CreateEntity()

    inst:AddTag("FX")
    inst:AddTag("NOCLICK")
    --[[Non-networked entity]]
    inst.entity:SetCanSleep(false)
    inst.persists = false

    inst.entity:AddTransform()
    inst.entity:AddAnimState()

    MakeInventoryPhysics(inst)
    inst.Physics:ClearCollisionMask()

    inst.AnimState:SetBank("gw_soul_ball")
    inst.AnimState:SetBuild("baise_soul_ball.autosave")
    inst.AnimState:PlayAnimation("disappear")
    inst.AnimState:SetScale(SCALE, SCALE)
    inst.AnimState:SetFinalOffset(3)

    inst:ListenForEvent("animover", inst.Remove)

    return inst
end

local function OnUpdateProjectileTail(inst)--, dt)
    local x, y, z = inst.Transform:GetWorldPosition()
    for tail, _ in pairs(inst._tails) do
        tail:ForceFacePoint(x, y, z)
    end
    if inst.entity:IsVisible() then
        local tail = CreateTail()
        local rot = inst.Transform:GetRotation()
        tail.Transform:SetRotation(rot)
        rot = rot * DEGREES
        local offsangle = math.random() * TWOPI
        local offsradius = (math.random() * .2 + .2) * SCALE
        local hoffset = math.cos(offsangle) * offsradius
        local voffset = math.sin(offsangle) * offsradius
        tail.Transform:SetPosition(x + math.sin(rot) * hoffset, y + voffset, z + math.cos(rot) * hoffset)
        tail.Physics:SetMotorVel(SPEED * (.2 + math.random() * .3), 0, 0)
        inst._tails[tail] = true
        inst:ListenForEvent("onremove", function(tail) inst._tails[tail] = nil end, tail)
        tail:ListenForEvent("onremove", function(inst)
            tail.Transform:SetRotation(tail.Transform:GetRotation() + math.random() * 30 - 15)
        end, inst)
    end
end

local function OnHit(inst, attacker, target)
    if target ~= nil then
        local x, y, z = inst.Transform:GetWorldPosition()
        local fx = SpawnPrefab("gw_soul_in_fx")
        fx.Transform:SetPosition(x, y, z)
        fx:Setup(target)
        local soul = SpawnPrefab("gw_soul_ball")
        local equipped_item = target.components.inventory and target.components.inventory:GetEquippedItem(EQUIPSLOTS.HANDS)
        if equipped_item and equipped_item.prefab == "gw_hundeng" and equipped_item.components.container then
            if not equipped_item.components.container:GiveItem(soul) then
                target.components.inventory:GiveItem(soul)
            end
        else
            target.components.inventory:GiveItem(soul)
        end
    end
    inst:Remove()
end

local function OnHasTailDirty(inst)
    if inst._hastail:value() and inst._tails == nil then
        inst._tails = {}
        if inst.components.updatelooper == nil then
            inst:AddComponent("updatelooper")
        end
        inst.components.updatelooper:AddOnUpdateFn(OnUpdateProjectileTail)
    end
end

local function OnThrownTimeout(inst)
    inst._timeouttask = nil
    inst.components.projectile:Miss(inst.components.projectile.target)
end

local function OnThrown(inst)
    if inst._timeouttask ~= nil then
        inst._timeouttask:Cancel()
    end
    inst._timeouttask = inst:DoTaskInTime(6, OnThrownTimeout)
    if inst._seektask ~= nil then
        inst._seektask:Cancel()
        inst._seektask = nil
    end
    inst.AnimState:Hide("blob")
    inst._hastail:set(true)
    if not TheNet:IsDedicated() then
        OnHasTailDirty(inst)
    end
end

local function ThiefSort(a, b) -- Better than bogo!
    return a.distsq < b.distsq
end

local function SeekSoul(inst)

    if inst.components.inventoryitem ~= nil and inst.components.inventoryitem:IsHeld() then
        return
    end
    
    if inst._healtask ~= nil then
        return
    end

    local x, y, z = inst.Transform:GetWorldPosition()
    local rangesq = TUNING.WORTOX_SOULSTEALER_RANGE * TUNING.WORTOX_SOULSTEALER_RANGE
    local soulthieves = {}
    local soulthiefreceiver = nil
    local hasthief = false
    for i, v in ipairs(AllPlayers) do
        if v:HasTag("gw_hundeng") and
            not (v.components.health:IsDead() or v:HasTag("playerghost")) and
            not (v.sg ~= nil and (v.sg:HasStateTag("nomorph") or v.sg:HasStateTag("silentmorph"))) and
            v.entity:IsVisible() then
            local distsq = v:GetDistanceSqToPoint(x, y, z)
            if distsq < rangesq then
                hasthief = true
                if inst._soulsource == v then
                    soulthiefreceiver = v
                    break
                end
                table.insert(soulthieves, {thief = v, distsq = distsq,})
            end
        end
    end
    if hasthief then
        if soulthiefreceiver == nil then
            table.sort(soulthieves, ThiefSort)
            soulthiefreceiver = soulthieves[1].thief
        end
        inst.components.projectile:Throw(inst, soulthiefreceiver, inst)
    end
end

local function OnTimeout(inst)
    inst._timeouttask = nil
    if inst._seektask ~= nil then
        inst._seektask:Cancel()
        inst._seektask = nil
    end
    inst:ListenForEvent("animover", inst.Remove)
    inst.AnimState:PlayAnimation("idle_pst")
    inst.SoundEmitter:PlaySound("dontstarve/characters/wortox/soul/spawn", nil, .5)

end

local TINT = { r = 23 / 255, g = 153 / 255, b = 89 / 255 }

local function PushColour(inst, addval, multval)
    if inst.components.highlight == nil then
        inst.AnimState:SetHighlightColour(TINT.r * addval, TINT.g * addval, TINT.b * addval, 0)
        inst.AnimState:OverrideMultColour(multval, multval, multval, 1)
    else
        inst.AnimState:OverrideMultColour()
    end
end

local function PopColour(inst)
    if inst.components.highlight == nil then
        inst.AnimState:SetHighlightColour()
    end
    inst.AnimState:OverrideMultColour()
end

local function OnUpdateTargetTint(inst)--, dt)
    if inst and inst._tinttarget:IsValid() then
		local curframe = inst.AnimState:GetCurrentAnimationFrame()
        if curframe < 15 then
            local k = curframe / 15
            k = k * k
            PushColour(inst._tinttarget, 1 - k, k)
        else
            inst.components.updatelooper:RemoveOnUpdateFn(OnUpdateTargetTint)
            inst.OnRemoveEntity = nil
            PopColour(inst._tinttarget)
        end
    else
        inst.components.updatelooper:RemoveOnUpdateFn(OnUpdateTargetTint)
        inst.OnRemoveEntity = nil
    end
end

local function OnRemoveEntity(inst)
    if inst._tinttarget:IsValid() then
        PopColour(inst._tinttarget)
    end
end

local function OnTargetDirty(inst)
    if inst._target:value() ~= nil and inst._tinttarget == nil then
        if inst.components.updatelooper == nil then
            inst:AddComponent("updatelooper")
        end
        inst.components.updatelooper:AddOnUpdateFn(OnUpdateTargetTint)
        inst._tinttarget = inst._target:value()
        inst.OnRemoveEntity = OnRemoveEntity
    end
end

local function Setup(inst, target)
    inst.SoundEmitter:PlaySound("dontstarve/characters/wortox/soul/spawn", nil, .5)
    inst._target:set(target)
    if not TheNet:IsDedicated() then
        OnTargetDirty(inst)
    end
end



local function KillSoul_FromPocket(inst)
    inst.soulhealfinishing = true
    inst.AnimState:PlayAnimation("idle_pst")
    inst:ListenForEvent("animover", inst.Remove)
    inst.SoundEmitter:PlaySound("dontstarve/characters/wortox/soul/spawn", nil, .5)
    gw_soul_common.DoHeal(inst)
end

local function topocket(inst)
    inst.persists = true
    if inst._timeouttask ~= nil then
        inst._timeouttask:Cancel()
        inst._timeouttask = nil
    end
    if inst._seektask ~= nil then
        inst._seektask:Cancel()
        inst._seektask = nil
    end
    if inst.components.projectile ~= nil then
        inst.components.projectile:Stop()
    end
    if inst._healtask ~= nil then
        inst._healtask:Cancel()
        inst._healtask = nil
    end
end

local function toground(inst)
    inst.persists = false
    if inst._timeouttask == nil then
        inst._timeouttask = inst:DoTaskInTime(10, OnTimeout)
    end
    if inst._seektask == nil then
        inst._seektask = inst:DoPeriodicTask(.5, SeekSoul, 1)
    end
    if inst._healtask == nil then
        inst._healtask = inst:DoTaskInTime(TUNING.WORTOX_SOUL_HEAL_DELAY, KillSoul_FromPocket)
    end
end

local function fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()
    inst.entity:AddNetwork()

    MakeInventoryPhysics(inst)
    RemovePhysicsColliders(inst)

    inst.AnimState:SetBank("gw_soul_ball")
    inst.AnimState:SetBuild("baise_soul_ball.autosave")
    inst.AnimState:PlayAnimation("idle_pre")
    inst.AnimState:SetScale(SCALE, SCALE)
    inst.AnimState:SetFinalOffset(3)

    inst:AddTag("NOCLICK")
    inst:AddTag("projectile")

    inst:AddTag("gw_soul")

    inst._target = net_entity(inst.GUID, "gw_soul_ball._target", "targetdirty")
    inst._hastail = net_bool(inst.GUID, "gw_soul_ball._hastail", "hastaildirty")

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        inst:ListenForEvent("targetdirty", OnTargetDirty)
        inst:ListenForEvent("hastaildirty", OnHasTailDirty)

        return inst
    end

    inst.AnimState:PushAnimation("idle_loop", true)

    inst:AddComponent("inventoryitem")
    inst.components.inventoryitem.atlasname = "images/inventoryimages/gw_soul_ball.xml"
    inst.components.inventoryitem.imagename = "gw_soul_ball"

    inst:AddComponent("fuel")
    inst.components.fuel.fuelvalue = TUNING.MED_LARGE_FUEL
    inst.components.fuel.fueltype = FUELTYPE.GW_SOUL_BALL
        
    inst.components.inventoryitem.canbepickedup = true
    inst.components.inventoryitem.canonlygoinpocketorpocketcontainers = true
    inst.components.inventoryitem:SetOnPutInInventoryFn(topocket)
    inst.components.inventoryitem:SetOnDroppedFn(toground)

    inst:AddComponent("stackable")
    inst.components.stackable.maxsize = TUNING.STACK_SIZE_SMALLITEM
    inst.components.stackable.forcedropsingle = true

    inst:AddComponent("projectile")
    inst.components.projectile:SetSpeed(SPEED)
    inst.components.projectile:SetHitDist(.5)
    inst.components.projectile:SetOnThrownFn(OnThrown)
    inst.components.projectile:SetOnHitFn(OnHit)
    inst.components.projectile:SetOnMissFn(inst.Remove)

    inst:AddComponent("inspectable")

    inst._seektask = inst:DoPeriodicTask(.5, SeekSoul, 1)
    inst._timeouttask = inst:DoTaskInTime(10, OnTimeout)
    inst._healtask = nil


    inst.persists = false
    inst.Setup = Setup

    return inst
end

local function in_fn()

    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddNetwork()
    inst.entity:AddSoundEmitter()

    inst.AnimState:SetBank("gw_soul_ball")
    inst.AnimState:SetBuild("baise_soul_ball.autosave")
    inst.AnimState:PlayAnimation("idle_pst")
	inst.AnimState:SetFrame(6)
    inst.AnimState:SetScale(SCALE, SCALE)
    inst.AnimState:SetFinalOffset(3)

    inst:AddTag("FX")

    inst._target = net_entity(inst.GUID, "wortox_soul_in_fx._target", "targetdirty")

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        inst:ListenForEvent("targetdirty", OnTargetDirty)

        return inst
    end

    inst:ListenForEvent("animover", inst.Remove)
    inst.persists = false
    inst.Setup = Setup

    return inst
end


return Prefab("gw_soul_ball", fn, assets),
Prefab("gw_soul_in_fx",in_fn)
