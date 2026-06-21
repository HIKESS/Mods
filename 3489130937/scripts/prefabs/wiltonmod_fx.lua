local function CreateTail(bank, build, lightoverride,colour)
    local inst = CreateEntity()

    inst:AddTag("FX")
    inst:AddTag("NOCLICK")

    inst.entity:SetCanSleep(false)
    inst.persists = false

    inst.entity:AddTransform()
    inst.entity:AddAnimState()

    MakeInventoryPhysics(inst)
    inst.Physics:ClearCollisionMask()

    inst.AnimState:SetBank(bank)
    inst.AnimState:SetBuild(build)
    inst.AnimState:PlayAnimation("disappear")
    local cr, cg, cb = 1, 1, 1
    if type(colour) == "table" then
        cr = colour[1] or 1
        cg = colour[2] or 1
        cb = colour[3] or 1
    elseif colour ~= nil then
        cr, cg, cb = colour, colour, colour
    end
    inst.AnimState:SetMultColour(cr, cg, cb, 1)
    if lightoverride > 0 then
        inst.AnimState:SetLightOverride(lightoverride)
    end
    inst.AnimState:SetFinalOffset(-1)

    inst:ListenForEvent("animover", inst.Remove)

    return inst
end

local function OnUpdateProjectileTail(inst, bank, build, speed, lightoverride, hitfx,colour, tails)
    local x, y, z = inst.Transform:GetWorldPosition()
    for tail, _ in pairs(tails) do
        tail:ForceFacePoint(x, y, z)
    end
    if inst.entity:IsVisible() then
        local tail = CreateTail(bank, build, lightoverride,colour)
        local rot = inst.Transform:GetRotation()
        tail.Transform:SetRotation(rot)
        rot = rot * DEGREES
        local offsangle = math.random() * 2 * PI
        local offsradius = math.random() * .2 + .2
        local hoffset = math.cos(offsangle) * offsradius
        local voffset = math.sin(offsangle) * offsradius
        tail.Transform:SetPosition(x + math.sin(rot) * hoffset, y + voffset, z + math.cos(rot) * hoffset)
        tail.Physics:SetMotorVel(speed * (.2 + math.random() * .3), 0, 0)
        tails[tail] = true
        inst:ListenForEvent("onremove", function(tail) tails[tail] = nil end, tail)
        tail:ListenForEvent("onremove", function(inst)
            tail.Transform:SetRotation(tail.Transform:GetRotation() + math.random() * 30 - 15)
        end, inst)
    end
end

local function onhit(inst, attacker, target)
    if target then
    local fx = SpawnPrefab("wiltonmod_staff_projectile2_hit")
    local pos = Vector3(target.Transform:GetWorldPosition())
    fx.Transform:SetPosition(pos.x, 1, pos.z)
    end

    inst:Remove()
end

local function fx2()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()
    inst.entity:AddNetwork()

    inst:AddTag("FX")
    inst:AddTag("NOCLICK")

    MakeInventoryPhysics(inst)
    RemovePhysicsColliders(inst)

    inst.AnimState:SetBank("fireball_fx")
    inst.AnimState:SetBuild("fireball_2_fx")
    inst.AnimState:PlayAnimation("idle_loop", true)
    inst.AnimState:SetBloomEffectHandle("shaders/anim.ksh")

    inst.AnimState:SetLightOverride(1)
    inst.AnimState:SetFinalOffset(-1)
    inst.AnimState:SetMultColour(0, 0, 0, 1)

    if not TheNet:IsDedicated() then  
        inst:DoPeriodicTask(0, OnUpdateProjectileTail, nil, "fireball_fx", "fireball_2_fx", 20, 1, nil, 0 ,{})
    end

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst.persists = false
    
    inst:AddComponent("projectile")
    inst.components.projectile:SetSpeed(20)
    inst.components.projectile:SetLaunchOffset(Vector3(2, 0, 0))
    inst.components.projectile:SetOnHitFn(onhit)

    inst.SoundEmitter:PlaySound("dontstarve/wilson/attack_nightsword")

    return inst
end

local function fx2_hit()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()
    inst.entity:AddNetwork()

    inst:AddTag("FX")
    inst:AddTag("NOCLICK")

    inst.AnimState:SetBank("deer_fire_charge")
    inst.AnimState:SetBuild("deer_fire_charge")
    inst.AnimState:PlayAnimation("blast", false)
    inst.AnimState:SetMultColour(0, 0, 0, 1)

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst.persists = false
    inst:ListenForEvent("animover", inst.Remove)
    
    inst.SoundEmitter:PlaySound("dontstarve/common/deathpoof")

    return inst
end

local function onhit2_purple(inst, attacker, target)
    if target then
    local fx = SpawnPrefab("wiltonmod_staff_projectile2_hit_purple")
    local pos = Vector3(target.Transform:GetWorldPosition())
    fx.Transform:SetPosition(pos.x, 1, pos.z)
    end

    inst:Remove()
end

local function fx2_purple()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()
    inst.entity:AddNetwork()

    inst:AddTag("FX")
    inst:AddTag("NOCLICK")

    MakeInventoryPhysics(inst)
    RemovePhysicsColliders(inst)

    inst.AnimState:SetBank("fireball_fx")
    inst.AnimState:SetBuild("fireball_2_fx")
    inst.AnimState:PlayAnimation("idle_loop", true)
    inst.AnimState:SetBloomEffectHandle("shaders/anim.ksh")

    inst.AnimState:SetLightOverride(1)
    inst.AnimState:SetFinalOffset(-1)
    inst.AnimState:SetMultColour(0.7, 0.3, 1, 1)
    inst.AnimState:SetAddColour(0.3, 0.0, 0.6, 0.5)

    if not TheNet:IsDedicated() then  
        inst:DoPeriodicTask(0, OnUpdateProjectileTail, nil, "fireball_fx", "fireball_2_fx", 20, 1, nil, {0.7, 0.3, 1}, {})
    end

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst.persists = false
    
    inst:AddComponent("projectile")
    inst.components.projectile:SetSpeed(20)
    inst.components.projectile:SetLaunchOffset(Vector3(2, 0, 0))
    inst.components.projectile:SetOnHitFn(onhit2_purple)

    inst.SoundEmitter:PlaySound("dontstarve/wilson/attack_nightsword")

    return inst
end

local function fx2_hit_purple()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()
    inst.entity:AddNetwork()

    inst:AddTag("FX")
    inst:AddTag("NOCLICK")

    inst.AnimState:SetBank("deer_fire_charge")
    inst.AnimState:SetBuild("deer_fire_charge")
    inst.AnimState:PlayAnimation("blast", false)
    inst.AnimState:SetMultColour(0.7, 0.3, 1, 1)
    inst.AnimState:SetAddColour(0.3, 0.0, 0.6, 0.5)

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst.persists = false
    inst:ListenForEvent("animover", inst.Remove)
    
    inst.SoundEmitter:PlaySound("dontstarve/common/deathpoof")

    return inst
end

local function onhit(inst, attacker, target)
    if target then
    local fx = SpawnPrefab("wiltonmod_staff_projectile3_hit")
    local pos = Vector3(target.Transform:GetWorldPosition())
    fx.Transform:SetPosition(pos.x, 1, pos.z)
    end

    inst:Remove()
end

local function fx3()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()
    inst.entity:AddNetwork()

    inst:AddTag("FX")
    inst:AddTag("NOCLICK")

    inst.AnimState:SetBank("fireball_fx")
    inst.AnimState:SetBuild("fireball_2_fx")
    inst.AnimState:PlayAnimation("idle_loop", true)
    inst.AnimState:SetBloomEffectHandle("shaders/anim.ksh")

    inst.AnimState:SetLightOverride(1)
    inst.AnimState:SetFinalOffset(-1)
    inst.AnimState:SetAddColour(1, 1, 1, 1)

    MakeInventoryPhysics(inst)
    RemovePhysicsColliders(inst)

    if not TheNet:IsDedicated() then  
        inst:DoPeriodicTask(0, OnUpdateProjectileTail, nil, "fireball_fx", "fireball_2_fx", 20, 0, nil, 1 ,{})
    end

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst.persists = false
    
    inst:AddComponent("projectile")
    inst.components.projectile:SetSpeed(20)
    inst.components.projectile:SetLaunchOffset(Vector3(2, 0, 0))
    inst.components.projectile:SetOnHitFn(onhit)

    inst.SoundEmitter:PlaySound("dontstarve/wilson/attack_nightsword")

    return inst
end

local function fx3_hit()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()
    inst.entity:AddNetwork()

    inst:AddTag("FX")
    inst:AddTag("NOCLICK")

    inst.AnimState:SetBank("deer_fire_charge")
    inst.AnimState:SetBuild("deer_fire_charge")
    inst.AnimState:PlayAnimation("blast", false)
    inst.AnimState:SetAddColour(1, 1, 1, 1)

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst.persists = false
    inst:ListenForEvent("animover", inst.Remove)
    
    inst.SoundEmitter:PlaySound("dontstarve/common/deathpoof")

    return inst
end

local function DoAtk(inst)
    if inst.target and inst.target:IsValid() and inst:IsNear(inst.target, 1.5) and inst.target.components.combat
    and inst.target.components.health and not inst.target.components.health:IsDead() then
        inst.target.components.combat:GetAttacked(inst, 30)
        if inst.target.components.locomotor then   
            inst.target.components.locomotor:SetExternalSpeedMultiplier(inst, "skelhead_debuff", 0.6)
            if inst.target.skelhead_debuff_task then
                inst.target.skelhead_debuff_task:Cancel()
                inst.target.skelhead_debuff_task = nil
            end 

            inst.target.skelhead_debuff_task = inst:DoTaskInTime(3, function()
                inst.target.components.locomotor:RemoveExternalSpeedMultiplier(inst, "skelhead_debuff")
                if inst.target.skelhead_debuff_task then
                    inst.target.skelhead_debuff_task:Cancel()
                    inst.target.skelhead_debuff_task = nil
                end     
            end)             
        end    

    elseif inst.target == nil or (inst.target and not inst.target:IsValid()) 
    or (inst.target and inst.target:IsValid() and inst.target.components.health and inst.target.components.health:IsDead()) then
        inst:Remove()
    end    
end

local function fx4()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()
    inst.entity:AddNetwork()

    inst:AddTag("FX")
    inst:AddTag("NOCLICK")

    inst.AnimState:SetBank("fireball_fx")
    inst.AnimState:SetBuild("fireball_2_fx")
    inst.AnimState:PlayAnimation("idle_loop", true)
    inst.AnimState:SetBloomEffectHandle("shaders/anim.ksh")

    inst.AnimState:SetLightOverride(1)
    inst.AnimState:SetFinalOffset(-1)
    inst.AnimState:SetMultColour(1, 1, 1, 1)

    MakeInventoryPhysics(inst)
    RemovePhysicsColliders(inst)

    inst.Transform:SetScale(2, 2, 2)

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst.persists = false
    
    inst:AddComponent("projectile")
    inst.components.projectile:SetSpeed(5)
    inst.components.projectile:SetLaunchOffset(Vector3(2, 0, 0))
    --inst.components.projectile:SetOnHitFn(onhit)
    inst.components.projectile.Hit = function(self, target, ...)
    --if self.onhit ~= nil then
        --self.onhit(self.inst, attacker, target)
    --end   
    end

    inst:DoTaskInTime(3, inst.Remove)
    inst:DoPeriodicTask(0.25, DoAtk)

    inst.SoundEmitter:PlaySound("dontstarve/wilson/attack_nightsword")

    return inst
end

local WILTON_LIGHTNING_MAX_DIST_SQ = 140 * 140

local function WiltonReviveLightning_PlayThunderSound(lighting)
	if lighting == nil or not lighting:IsValid() or TheFocalPoint == nil then
		return
	end

	local pos = Vector3(lighting.Transform:GetWorldPosition())
	local pos0 = Vector3(TheFocalPoint.Transform:GetWorldPosition())
	local diff = pos - pos0
	local distsq = diff:LengthSq()

	local k = math.max(0, math.min(1, distsq / WILTON_LIGHTNING_MAX_DIST_SQ))
	local intensity = math.min(1, k * 1.1 * (k - 2) + 1.1)
	if intensity <= 0 then
		return
	end

	local minsounddist = 10
	local normpos = pos
	if distsq > minsounddist * minsounddist then
		local normdiff = diff * (minsounddist / math.sqrt(distsq))
		normpos = pos0 + normdiff
	end

	local inst = CreateEntity()

	-- 只在本地创建非网络音效实体，播放与玩家位置相对合理的雷声。
	inst.entity:AddTransform()
	inst.entity:AddSoundEmitter()

	inst.Transform:SetPosition(normpos:Get())
	inst.SoundEmitter:PlaySound("dontstarve/rain/thunder_close", nil, intensity, true)

	inst:Remove()
end

local function WiltonReviveLightning_StartFX(inst)
	for _, v in ipairs(AllPlayers) do
		local dist_sq = v:GetDistanceSqToInst(inst)
		local k = math.max(0, math.min(1, dist_sq / WILTON_LIGHTNING_MAX_DIST_SQ))
		local intensity = -(k - 1) * (k - 1) * (k - 1)

		if intensity > 0 then
			v:ScreenFlash(intensity <= 0.05 and 0.05 or intensity)
			v:ShakeCamera(CAMERASHAKE.FULL, .7, .02, intensity / 3)
		end
	end
end

local function wilton_revive_lightning_fx()
	local inst = CreateEntity()

	inst.entity:AddTransform()
	inst.entity:AddAnimState()
	inst.entity:AddSoundEmitter()
	inst.entity:AddNetwork()

	inst.Transform:SetScale(2, 2, 2)

	inst.AnimState:SetBloomEffectHandle("shaders/anim.ksh")
	inst.AnimState:SetLightOverride(1)
	inst.AnimState:SetBank("lightning")
	inst.AnimState:SetBuild("lightning")
	inst.AnimState:PlayAnimation("anim")

	inst.SoundEmitter:PlaySound("dontstarve/rain/thunder_close", nil, nil, true)

	inst:AddTag("FX")

	-- Dedicated server 不需要本地音效，但客户端需要根据距离调整雷声。
	if not TheNet:IsDedicated() then
		inst:DoTaskInTime(0, WiltonReviveLightning_PlayThunderSound)
	end

	inst.entity:SetPristine()

	if not TheWorld.ismastersim then
		return inst
	end

	-- 仅在服务器端驱动屏幕闪烁与镜头震动，保证所有玩家收到同一事件。
	inst:DoTaskInTime(0, WiltonReviveLightning_StartFX)

	inst.entity:SetCanSleep(false)
	inst.persists = false
	inst:DoTaskInTime(.5, inst.Remove)

	return inst
end

return Prefab("wiltonmod_staff_projectile2", fx2),
	   Prefab("wiltonmod_staff_projectile2_hit", fx2_hit), 
	   Prefab("wiltonmod_staff_projectile2_purple", fx2_purple),
	   Prefab("wiltonmod_staff_projectile2_hit_purple", fx2_hit_purple), 
	   Prefab("wiltonmod_staff_projectile3", fx3),
	   Prefab("wiltonmod_staff_projectile3_hit", fx3_hit),  --c_spawn"wiltonmod_staff_projectile3_hit".AnimState:SetAddColour(1, 1, 1, 0.8)
	   Prefab("wiltonmod_staff_skelhead_project", fx4),
	   Prefab("wilton_revive_lightning_fx", wilton_revive_lightning_fx)
