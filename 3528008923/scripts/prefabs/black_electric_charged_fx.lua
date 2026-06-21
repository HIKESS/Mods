local assets =
{
    Asset("ANIM", "anim/black_elec_charged_fx.zip"),
}

local prefabs =
{
	"warg_mutated_breath_fx",
	"warg_mutated_ember_fx",
}

local function onupdate(inst, dt)
    if inst.sound then
        inst.SoundEmitter:PlaySound("dontstarve/characters/wx78/spark")
        inst.sound = nil
    end

    inst.Light:SetIntensity(inst.i)
    inst.i = inst.i - dt * 2
    if inst.i <= 0 then
        if inst.killfx then
            inst:Remove()
        else
            inst.task:Cancel()
            inst.task = nil
        end
    end
end

local function OnAnimOver(inst)
    if inst.task == nil then
        inst:Remove()
    else
        inst:RemoveEventCallback("animover", OnAnimOver)
        inst.killfx = true
    end
end

local function StartFX(proxy, animindex, build)
    local inst = CreateEntity()

    inst:AddTag("FX")
    --[[Non-networked entity]]
    inst.entity:SetCanSleep(false)
    inst.persists = false

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    if not TheNet:IsDedicated() then
        inst.entity:AddSoundEmitter()
    end
    inst.entity:AddLight()

    local parent = proxy.entity:GetParent()
    if parent ~= nil then
        inst.entity:SetParent(parent.entity)
    end
    inst.Transform:SetFromProxy(proxy.GUID)

    inst.AnimState:SetBank("elec_charged_fx")
    inst.AnimState:SetBuild("black_elec_charged_fx")
    inst.AnimState:PlayAnimation("discharged")
		
    inst.AnimState:SetBloomEffectHandle("shaders/anim.ksh")
	
	inst.Transform:SetScale(.65, .65, .65)

    inst.Light:Enable(true)
    inst.Light:SetRadius(1)
    inst.Light:SetFalloff(.7)
    inst.Light:SetIntensity(.5)
    inst.Light:SetColour(80 / 255, 0 / 255, 0 / 255)

    local dt = 1 / 20
    inst.i = .9
    inst.sound = inst.SoundEmitter ~= nil
    inst.task = inst:DoPeriodicTask(dt, onupdate, nil, dt)

    inst:ListenForEvent("animover", OnAnimOver)
end

local function OnRemoveFlash(inst)
    if inst.target.components.colouradder == nil and inst.target:IsValid() then
        if inst.target.components.freezable ~= nil then
            inst.target.components.freezable:UpdateTint()
        else
            inst.target.AnimState:SetAddColour(0, 0, 0, 0)
        end
    end
end

local function OnUpdateFlash(inst)
    if not inst.target:IsValid() then
        inst.OnRemoveEntity = nil
        inst:RemoveComponent("updatelooper")
    elseif inst.flash > .1 then
        inst.flash = inst.flash - .07
        inst.blink = inst.blink < 3 and inst.blink + 1 or 0
        local c = inst.blink < 2 and inst.flash * .25 or 0
        if inst.target.components.colouradder ~= nil then
            inst.target.components.colouradder:PushColour(inst, c, c, c, 0)
        else
            inst.target.AnimState:SetAddColour(c, c, c, 0)
        end
    else
        if inst.target.components.colouradder ~= nil then
            inst.target.components.colouradder:PopColour(inst)
        elseif inst.target.components.freezable ~= nil then
            inst.target.components.freezable:UpdateTint()
        else
            inst.target.AnimState:SetAddColour(0, 0, 0, 0)
        end
        inst.OnRemoveEntity = nil
        inst:RemoveComponent("updatelooper")
    end
end

local function SetTarget(inst, target)
    inst.entity:SetParent(target.entity)

    if inst.components.updatelooper == nil then
        inst.OnRemoveEntity = OnRemoveFlash
        inst.target = target
        inst.flash = 1
        inst.blink = 0

        inst:AddComponent("updatelooper")
        inst.components.updatelooper:AddOnUpdateFn(OnUpdateFlash)
        OnUpdateFlash(inst)
    end
end

local function fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddNetwork()

    inst:AddTag("FX")
		
    --Delay one frame in case we are about to be removed
    inst:DoTaskInTime(0, StartFX)

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst.persists = false
    inst:DoTaskInTime(1, inst.Remove)

    inst.SetTarget = SetTarget

    return inst
end

--------------------------------------------------------------------------------------------------------------------------------------

local function SpawnBreathFX(inst, dist, targets, updateangle)
	if updateangle then
		inst.angle = (inst.entity:GetParent() or inst).Transform:GetRotation() * DEGREES

		if not inst.SoundEmitter:PlayingSound("loop") then
			inst.SoundEmitter:PlaySound("dontstarve/common/fireAddFuel")
			inst.SoundEmitter:PlaySound("rifts3/mutated_varg/blast_lp", "loop")
		end
	end

	local fx = table.remove(inst.flame_pool)
	if fx == nil then
		fx = SpawnPrefab("warg_mutated_breath_fx")
		fx.AnimState:SetMultColour(0, 0, 0, .9)		
		fx:SetFXOwner(inst, inst.flamethrower_attacker)
	end

	local scale = (1.4 + math.random() * 0.25)
	if dist < 6 then
		scale = scale * 1.2
	elseif dist > 7 then
		scale = scale * (1 + (dist - 7) / 6)
	end

	local fadeoption = (dist < 6 and "nofade") or (dist <= 7 and "latefade") or nil

	local x, y, z = inst.Transform:GetWorldPosition()
	local angle = inst.angle
	x = x + math.cos(angle) * dist
	z = z - math.sin(angle) * dist
	dist = dist / 20
	angle = math.random() * PI2
	x = x + math.cos(angle) * dist
	z = z - math.sin(angle) * dist

	fx.Transform:SetPosition(x, 0, z)
	fx:RestartFX(scale, fadeoption, targets)
end

local function SetFlamethrowerAttacker(inst, attacker)
	inst.flamethrower_attacker = attacker
end

local function OnRemoveEntity(inst)
	if inst.flame_pool ~= nil then
		for i, v in ipairs(inst.flame_pool) do
			v:Remove()
		end
		inst.flame_pool = nil
	end
	if inst.ember_pool ~= nil then
		for i, v in ipairs(inst.ember_pool) do
			v:Remove()
		end
		inst.ember_pool = nil
	end
end

local function KillSound(inst)
	inst.SoundEmitter:KillSound("loop")
end

local function KillFX(inst)
	for i, v in ipairs(inst.tasks) do
		v:Cancel()
	end
	inst.OnRemoveEntity = nil
	OnRemoveEntity(inst)
	--Delay removal because lingering flame fx still references us for weapon damage
	inst:DoTaskInTime(1, inst.Remove)

	inst.SoundEmitter:PlaySound("rifts3/mutated_varg/blast_pst")
	inst:DoTaskInTime(6 * FRAMES, KillSound)
end

local function flamefn()
	local inst = CreateEntity()

	inst.entity:AddTransform()
	inst.entity:AddSoundEmitter()
	inst.entity:AddNetwork()

	inst:AddTag("CLASSIFIED")

	inst.entity:SetPristine()

	if not TheWorld.ismastersim then
		return inst
	end

	inst.flame_pool = {}
	inst.ember_pool = {}
	inst.angle = 0

	local targets = {}
	local period = 10 * FRAMES
	inst.tasks =
	{
		inst:DoPeriodicTask(period, SpawnBreathFX, 0 * FRAMES, 3, targets, true),
		inst:DoPeriodicTask(period, SpawnBreathFX, 3 * FRAMES, 5, targets),
		inst:DoPeriodicTask(period, SpawnBreathFX, 6 * FRAMES, 7, targets),
		inst:DoPeriodicTask(period, SpawnBreathFX, 9 * FRAMES, 9, targets),
	}

	inst:AddComponent("weapon")
	inst.components.weapon:SetDamage(TUNING.WILLOW_LUNAR_FIRE_DAMAGE)

	inst:AddComponent("planardamage")
	inst.components.planardamage:SetBaseDamage(TUNING.WILLOW_LUNAR_FIRE_PLANAR_DAMAGE)

	inst:AddComponent("damagetypebonus")
	inst.components.damagetypebonus:AddBonus("shadow_aligned", inst, TUNING.WILLOW_LUNAR_FIRE_BONUS)	

	inst.SetFlamethrowerAttacker = SetFlamethrowerAttacker
	inst.KillFX = KillFX
	inst.OnRemoveEntity = OnRemoveEntity

	inst.persists = false

	return inst
end

return Prefab("black_electricchargedfx", fn, assets),
		Prefab("blackflamethrower_fx", flamefn, nil, prefabs)
		
