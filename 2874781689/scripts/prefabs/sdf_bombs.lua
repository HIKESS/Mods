local assets=
{
    Asset("ATLAS", "images/inventoryimages/sdf_bombs.xml"),
    Asset("IMAGE", "images/inventoryimages/sdf_bombs.tex"),

    Asset("ANIM", "anim/sdf_bombs.zip"),
    Asset("ANIM", "anim/swap_sdf_bombs.zip"),
    Asset("ANIM", "anim/sdf_bombs_fx.zip"),
    Asset("ANIM", "anim/sdf_bombs_sinkhole.zip"),
}

prefabs = {
}

local function ReticuleTargetAllowWaterFn()
    local player = ThePlayer
    local ground = TheWorld.Map
    local pos = Vector3()
    --Cast range is 8, leave room for error
    --4 is the aoe range
    for r = 8.5, 6.5, -.25 do
	pos.x, pos.y, pos.z = player.entity:LocalToWorldSpace(r, 0, 0)
	if ground:IsPassableAtPoint(pos.x, 0, pos.z, true) and not ground:IsGroundTargetBlocked(pos) then
	    return pos
	end
    end
    return pos
end

local function OnHitWater(inst, attacker, target)
    local pt = inst:GetPosition()    
    local ents = TheSim:FindEntities(pt.x, pt.y, pt.z, 3)
    for i, v in ipairs(ents) do
	if v.components.health ~= nil then
	    v.components.combat:SuggestTarget(attacker)
	end
    end

    inst.SoundEmitter:KillSound("hiss")
    SpawnPrefab("sdf_bombs_fx").Transform:SetPosition(inst.Transform:GetWorldPosition())
    inst.SoundEmitter:PlaySound("dontstarve/common/dropwood")
    inst:Remove()
end

local function onthrown(inst)
    inst._fx = SpawnPrefab("torchfire")
    inst._fx.entity:SetParent(inst.entity)
    inst._fx.entity:AddFollower()
    inst._fx.Follower:FollowSymbol(inst.GUID, "sdf_bombs", 0, 0, 0)
    inst.AnimState:PlayAnimation("thrown")
    inst:AddTag("NOCLICK")
    inst.persists = false

    inst.SoundEmitter:PlaySound("dontstarve/common/blackpowder_fuse_LP", "hiss")
    inst.Physics:SetMass(1)
    inst.Physics:SetCapsule(0.2, 0.2)
    inst.Physics:SetFriction(0)
    inst.Physics:SetDamping(0)
    inst.Physics:SetCollisionGroup(COLLISION.CHARACTERS)
    inst.Physics:ClearCollisionMask()
    inst.Physics:CollidesWith(COLLISION.WORLD)
    inst.Physics:CollidesWith(COLLISION.OBSTACLES)
    inst.Physics:CollidesWith(COLLISION.ITEMS)
end

local function OnIgniteFn(inst)
    SpawnPrefab("sdf_bombs_fx").Transform:SetPosition(inst.Transform:GetWorldPosition())
    inst:Remove()
end

local function onequip(inst, owner)
    owner.AnimState:OverrideSymbol("swap_object", "swap_sdf_bombs", "swap_sdf_bombs")
    owner.AnimState:Show("ARM_carry")
    owner.AnimState:Hide("ARM_normal")
    owner.components.combat:SetAttackPeriod(TUNING.SDF_BOMBS_ATTACK_SPEED)

    inst:RemoveTag("special_action_toss")
end

local function onunequip(inst, owner)
    owner.AnimState:Hide("ARM_carry")
    owner.AnimState:Show("ARM_normal")
    owner.components.combat:SetAttackPeriod(TUNING.WILSON_ATTACK_PERIOD)

    inst:AddTag("special_action_toss")
end

local function fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()
    inst.entity:AddNetwork()

    MakeInventoryPhysics(inst)
    RemovePhysicsColliders(inst)

    inst.AnimState:SetBank("sdf_bombs")
    inst.AnimState:SetBuild("sdf_bombs")
    inst.AnimState:PlayAnimation("idle")
    inst.AnimState:SetRayTestOnBB(true)

    inst:AddTag("projectile")
    inst:AddTag("special_action_toss")

    inst:AddComponent("reticule")
    inst.components.reticule.targetfn = ReticuleTargetAllowWaterFn
    inst.components.reticule.ease = true

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst:AddComponent("locomotor")

    inst:AddComponent("complexprojectile")
    inst.components.complexprojectile:SetHorizontalSpeed(15)
    inst.components.complexprojectile:SetGravity(-35)
    inst.components.complexprojectile:SetLaunchOffset(Vector3(.25, 1, 0))
    inst.components.complexprojectile:SetOnLaunch(onthrown)
    inst.components.complexprojectile:SetOnHit(OnHitWater)

    inst:AddComponent("wateryprotection")
    inst.components.wateryprotection.witherprotectiontime = TUNING.SDF_BOMBS_PROTECTION_TIME

    inst:AddComponent("inspectable")

    inst:AddComponent("stackable")
    inst.components.stackable.maxsize = TUNING.SDF_BOMBS_MAXSTACKCOUNT

    inst:AddComponent("inventoryitem")
    inst.components.inventoryitem:SetSinks(true)
    inst.components.inventoryitem.imagename = "sdf_bombs"
    inst.components.inventoryitem.atlasname = "images/inventoryimages/sdf_bombs.xml"

    inst:AddComponent("equippable")
    inst.components.equippable:SetOnEquip(onequip)
    inst.components.equippable:SetOnUnequip(onunequip)
    inst.components.equippable.equipstack = true

    MakeSmallBurnable(inst, 3 + math.random() * 3)
    inst.components.burnable:SetOnBurntFn(nil)
    inst.components.burnable:SetOnIgniteFn(OnIgniteFn)

    MakeHauntableLaunch(inst)

    return inst
end

local function OnIgniteFn(inst)
    inst._fx = SpawnPrefab("torchfire")
    inst._fx.entity:SetParent(inst.entity)
    inst._fx.entity:AddFollower()
    inst._fx.Follower:FollowSymbol(inst.GUID, "sdf_bombs_fx", 0, 0, 0)
    inst.SoundEmitter:PlaySound("dontstarve/common/blackpowder_fuse_LP", "hiss")
end

local function OnExtinguishFn(inst)
    inst.SoundEmitter:KillSound("hiss")
end

local function OnExplodeFn(inst)
    local x, y, z = inst.Transform:GetWorldPosition()
    local ents = TheSim:FindEntities(x, y, z, 3)
    for i, v in ipairs(ents) do
	if v.components.health ~= nil then
	    if v:HasTag("player") then				         
	    else
		v.components.health:DoDelta(-25)
	    end
	end
    end
    inst.SoundEmitter:KillSound("hiss")
    SpawnPrefab("explode_small").Transform:SetPosition(inst.Transform:GetWorldPosition())

    local newSinkhole = SpawnPrefab("sdf_bombs_sinkhole")
    newSinkhole.Transform:SetPosition(inst.Transform:GetWorldPosition())
    newSinkhole:DoCollapseFn()
end

local function Explode(inst)
    inst.SoundEmitter:KillSound("hiss")
    inst.components.explosive:OnBurnt()
end

local function fn2()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()
    inst.entity:AddNetwork()

    MakeInventoryPhysics(inst)

    inst.AnimState:SetBank("sdf_bombs_fx")
    inst.AnimState:SetBuild("sdf_bombs_fx")
    inst.AnimState:PlayAnimation("idle")

    inst:AddTag("explosive")
    inst:AddTag("SCARYTOPREY")

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst:AddComponent("explosive")
    inst.components.explosive:SetOnExplodeFn(OnExplodeFn)
    inst.components.explosive.explosivedamage = TUNING.SDF_BOMBS_DAMAGE
    inst.components.explosive.lightonexplode = false
	
    inst._light = nil
    inst:DoTaskInTime(0, OnIgniteFn)
    inst:DoTaskInTime(1, Explode)

    return inst
end

require("stategraphs/commonstates")
local NUM_CRACKING_STAGES = 1
local COLLAPSE_STAGE_DURATION = 1
local OBJECT_SCALE = 0.6
local NUM_FX = 7
local FX_THETA_DELTA = TWOPI / NUM_FX
local FX_RADIUS = 1.6

local function SpawnFx(inst, scale, pos)
    local theta = math.random() * PI * 2

    pos = pos or inst:GetPosition()

    --Spawn an fx at the middle of the sinkhole.
    SpawnPrefab("sinkhole_spawn_fx_"..math.random(3)).Transform:SetPosition(pos:Get())

    --Spawn an fx around the edges of the sinkhole circle.
    for i = 1, NUM_FX do
        local dust = SpawnPrefab("sinkhole_spawn_fx_"..math.random(3))

        dust.Transform:SetPosition(
            pos.x + math.cos(theta) * FX_RADIUS * (1 + math.random() * .1),
            0,
            pos.z - math.sin(theta) * FX_RADIUS * (1 + math.random() * .1)
        )

        local s = scale + math.random() * .2
        local x_scale = (i % 2 == 0 and -s) or s
        dust.Transform:SetScale(x_scale, s, s)

        theta = theta + FX_THETA_DELTA
    end

    inst.SoundEmitter:PlaySoundWithParams("dontstarve/creatures/together/antlion/sfx/ground_break", { size = 2 })
end

local function OnTimerDone(inst, data)
    if data ~= nil and data.name == "repair" then
        if not inst:IsAsleep() then
	    SpawnFx(inst, inst.scale / 2)
        end

        inst.components.unevenground:Disable()
        inst.persists = false
        ErodeAway(inst)
    end
end

local function SmallLaunch(inst, launcher, basespeed)
    local hp = inst:GetPosition()
    local pt = launcher:GetPosition()
    local vel = (hp - pt):GetNormalized()
    local speed = basespeed * .5 + math.random()
    local angle = math.atan2(vel.z, vel.x) + (math.random() * 20 - 10) * DEGREES
    inst.Physics:Teleport(hp.x, .1, hp.z)
    inst.Physics:SetVel(math.cos(angle) * speed, 3 * speed + math.random(), math.sin(angle) * speed)
end

local COLLAPSIBLE_WORK_ACTIONS =
{
    CHOP = true,
    DIG = true,
    HAMMER = true,
    MINE = true,
}
local COLLAPSIBLE_TAGS = { "pickable", "NPC_workable" }
for k, v in pairs(COLLAPSIBLE_WORK_ACTIONS) do
    table.insert(COLLAPSIBLE_TAGS, k.."_workable")
end
local NON_COLLAPSIBLE_TAGS = { "flying", "bird", "ghost", "locomotor", "FX", "NOCLICK", "DECOR", "INLIMBO" }

local TOSS_MUST_TAGS = { "_inventoryitem" }
local TOSS_CANT_TAGS = { "locomotor", "INLIMBO" }

local function SnareAOE(inst)
    local debuffkey = inst.prefab
    local x, y, z = inst.Transform:GetWorldPosition()
    local ents = TheSim:FindEntities(x, y, z, 3)
    for i, v in ipairs(ents) do
	if v ~= nil and v:IsValid() and v.components.locomotor ~= nil and not (v:HasTag("epic") 
	    or v:HasTag("player") or v:HasTag("playerghost") or v:HasTag("INLIMBO")) then
	    --slowing effect
	    if v._sdf_bombs_sinkhole_movespeed_debufftask ~= nil then
		v._sdf_bombs_sinkhole_movespeed_debufftask:Cancel()
	    end
	    v._sdf_bombs_sinkhole_movespeed_debufftask = v:DoTaskInTime(TUNING.SDF_BOMBS_SINKHOLE_MOVESPEED_DEBUFF_DURATION, function(i) i.components.locomotor:RemoveExternalSpeedMultiplier(i, debuffkey) i._sdf_bombs_sinkhole_movespeed_debufftask = nil end)

	    v.components.locomotor:SetExternalSpeedMultiplier(v, debuffkey, TUNING.SDF_BOMBS_SINKHOLE_MOVESPEED_DEBUFF)
	end
    end
end

local function DoCollapse(inst)
    ShakeAllCameras(CAMERASHAKE.FULL, COLLAPSE_STAGE_DURATION, .03, .15, inst, inst.radius * 6)

    inst.components.unevenground:Enable()

    local pos = inst:GetPosition()
	SpawnFx(inst, inst.scale, pos)

    local ents = TheSim:FindEntities(
        pos.x, 0, pos.z,
        inst.radius + 1, nil,
        NON_COLLAPSIBLE_TAGS, COLLAPSIBLE_TAGS
    )

    for _, collapsible_entity in ipairs(ents) do
        local isworkable = false

        if collapsible_entity.components.workable ~= nil then
            local work_action = collapsible_entity.components.workable:GetWorkAction()
            --V2C: nil action for NPC_workable (e.g. campfires)
            --     allow digging spawners (e.g. rabbithole)
            isworkable = (
                (work_action == nil and collapsible_entity:HasTag("NPC_workable")) or
                (collapsible_entity.components.workable:CanBeWorked() and work_action ~= nil and COLLAPSIBLE_WORK_ACTIONS[work_action.id])
            )
        end

	-- Work the object a little if it can be worked (or destroy if inst.maxwork is true),
        -- and pick stuff that can be picked.
        if isworkable then
	    if inst.maxwork then
		collapsible_entity.components.workable:Destroy(inst)
	    else
		if collapsible_entity.components.workable:GetWorkAction() == ACTIONS.MINE then
		    PlayMiningFX(inst, collapsible_entity, true)
		end
		collapsible_entity.components.workable:WorkedBy(inst, 1)
	    end
            if collapsible_entity:IsValid() and collapsible_entity:HasTag("stump") then
                collapsible_entity:Remove()
            end
        elseif collapsible_entity.components.pickable ~= nil
                and collapsible_entity.components.pickable:CanBePicked()
                and not collapsible_entity:HasTag("intense") then

            local num = collapsible_entity.components.pickable.numtoharvest or 1
            local product = collapsible_entity.components.pickable.product

            collapsible_entity.components.pickable:Pick(inst) -- only calling this to trigger callbacks on the object

            if product ~= nil and num > 0 then
                local ce_x, ce_y, ce_z = collapsible_entity.Transform:GetWorldPosition()
                for i = 1, num do
                    SpawnPrefab(product).Transform:SetPosition(ce_x, 0, ce_z)
                end
            end
        end
    end

    local totoss = TheSim:FindEntities(pos.x, 0, pos.z, inst.radius, TOSS_MUST_TAGS, TOSS_CANT_TAGS)
    for _, tossible_entity in ipairs(totoss) do
        if tossible_entity.components.mine ~= nil then
            tossible_entity.components.mine:Deactivate()
        end
        if not tossible_entity.components.inventoryitem.nobounce
                and (tossible_entity.Physics ~= nil and tossible_entity.Physics:IsActive()) then
            SmallLaunch(tossible_entity, inst, 1.5)
        end
    end

    inst.components.timer:StartTimer("repair", TUNING.SDF_BOMBS_SINKHOLE_DURATION)
end

local function OnLoad(inst)--, data)
    if inst.components.timer:TimerExists("repair") then
        inst.components.unevenground:Enable()
    end
end

local function OnLoadPostPass(inst)--, newents, data)
    if inst.persists and not inst.components.timer:TimerExists("repair") then
	--backup, in case sinkholes got spawned and never started collapsing
	inst:Remove()
    end
end

local function fn3()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()
    inst.entity:AddNetwork()

    inst.AnimState:SetBank("sdf_bombs_sinkhole")
    inst.AnimState:SetBuild("sdf_bombs_sinkhole")
    inst.AnimState:PlayAnimation("idle")

    inst.AnimState:SetOrientation(ANIM_ORIENTATION.OnGround)
    inst.AnimState:SetLayer(LAYER_BACKGROUND)
    inst.AnimState:SetSortOrder(2)
    inst.AnimState:SetScale(OBJECT_SCALE, OBJECT_SCALE)

    inst.Transform:SetEightFaced()

    inst:AddTag("antlion_sinkhole")
    inst:AddTag("antlion_sinkhole_blocker")
    inst:AddTag("NOCLICK")

    inst:SetDeployExtraSpacing(4)

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
	return inst
    end

    inst.radius = TUNING.SDF_BOMBS_SINKHOLE_RADIUS
    inst.scale = OBJECT_SCALE
    inst.maxwork = false

    inst:AddComponent("aura")
    inst.components.aura.pretickfn = SnareAOE
    inst.components.aura.radius = TUNING.SDF_BOMBS_SINKHOLE_RADIUS + 1
    inst.components.aura.tickperiod = TUNING.SDF_BOMBS_SINKHOLE_TICK
    inst.components.aura:Enable(true)

    inst:AddComponent("timer")

    inst:AddComponent("unevenground")
    inst.components.unevenground.radius = TUNING.SDF_BOMBS_SINKHOLE_RADIUS

    inst.DoCollapseFn = function() DoCollapse(inst) end

    inst:ListenForEvent("timerdone", OnTimerDone)

    inst.OnLoad = OnLoad
    inst.OnLoadPostPass = OnLoadPostPass

    return inst
end

return  Prefab("common/inventory/sdf_bombs", fn, assets),
	Prefab("sdf_bombs_fx", fn2, assets),
	Prefab("sdf_bombs_sinkhole", fn3, assets)