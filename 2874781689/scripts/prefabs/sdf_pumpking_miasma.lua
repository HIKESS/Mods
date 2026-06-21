local assets =
{
    Asset("ANIM", "anim/sdf_pumpking_miasma.zip"),
    Asset("ANIM", "anim/sdf_pumpking_miasma_death.zip"),
    Asset("ANIM", "anim/sdf_pumpking_miasma_telegraph.zip"),
}

local prefs = {
}


local function miasmaAOE(inst)
    local x, y, z = inst.Transform:GetWorldPosition()
    local ents = TheSim:FindEntities(x, y, z, TUNING.SDF_PUMPKIN_KING_MIASMA_AOE_RADIUS)
    for i, v in ipairs(ents) do
	if v:HasTag("sdf_pumpking_friend") or v:HasTag("bird") then
	elseif v.components.health ~= nil and not v.components.health:IsDead() and v.components.combat ~= nil then
	    if v:HasTag("player") then
		v.components.combat:GetAttacked(v, TUNING.SDF_PUMPKIN_KING_MIASMA_AOE_DAMAGE)
		v.components.health:DeltaPenalty(TUNING.SDF_PUMPKIN_KING_MIASMA_AOE_HEALTH_PENALTY_DAMAGE)
	    else
		v.components.combat:GetAttacked(v, TUNING.SDF_PUMPKIN_KING_MIASMA_AOE_DAMAGE * 3)
	    end
	end
    end

    inst:DoTaskInTime(2.5, inst.Remove)
end

local function fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddNetwork()
    inst.entity:AddSoundEmitter()

    local scale = TUNING.SDF_PUMPKIN_KING_MIASMA_TELEGRAPH_RADIUS - 0.7
    inst.AnimState:SetScale(scale, scale)

    inst.AnimState:SetBank("sdf_pumpking_miasma")
    inst.AnimState:SetBuild("sdf_pumpking_miasma")
    inst.AnimState:PlayAnimation("aoe_pre")
    inst.AnimState:PushAnimation("aoe_pst", false)

    inst:AddTag("FX")
    inst:AddTag("NOCLICK")

    inst.SoundEmitter:PlaySound("dontstarve/creatures/together/toad_stool/infection_attack")

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst.entity:SetCanSleep(false)

    inst.persists = false
    inst:DoTaskInTime(0.1, miasmaAOE)

    return inst
end

local function miasmaTelegraphFade(inst)
    inst.AnimState:PlayAnimation("telegraph_base_pst")

    --create miasma
    inst:DoTaskInTime(0.25,function()
	local x,_,z=inst.Transform:GetWorldPosition()
	local miasmaFX = SpawnPrefab("sdf_pumpking_miasma")
	miasmaFX.Transform:SetPosition(x,_-2,z)

	inst:Remove()
    end)
end

local function fn2()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddNetwork()
    inst.entity:AddSoundEmitter()

    local scale = TUNING.SDF_PUMPKIN_KING_MIASMA_TELEGRAPH_RADIUS
    inst.AnimState:SetScale(scale, scale)

    inst.AnimState:SetBank("sdf_pumpking_miasma_telegraph")
    inst.AnimState:SetBuild("sdf_pumpking_miasma_telegraph")
    inst.AnimState:PlayAnimation("telegraph_base_pre")
    inst.AnimState:PushAnimation("telegraph_base_idle", true)
    inst.AnimState:SetOrientation(ANIM_ORIENTATION.OnGround)
    inst.AnimState:SetLayer(LAYER_BACKGROUND)
    inst.AnimState:SetSortOrder(3)

    inst:AddTag("FX")
    inst:AddTag("NOCLICK")

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst.entity:SetCanSleep(false)

    inst.persists = false

    inst:DoTaskInTime(2.5, inst.SoundEmitter:PlaySound("dontstarve/creatures/together/toad_stool/spore_shoot"))
    inst:DoTaskInTime(TUNING.SDF_PUMPKIN_KING_MIASMA_TELEGRAPH_TIME, miasmaTelegraphFade)

    return inst
end

local function miasmaSmallAOE(inst)
    local x, y, z = inst.Transform:GetWorldPosition()

    SpawnPrefab("sdf_pumpking_gutted_splash_fx").Transform:SetPosition(x, y, z)

    local ents = TheSim:FindEntities(x, y, z, TUNING.SDF_PUMPKIN_KING_MIASMA_SMALL_AOE_RADIUS)
    for i, v in ipairs(ents) do
	if v:HasTag("sdf_pumpking_friend") or v:HasTag("bird") then
	elseif v.components.health ~= nil and not v.components.health:IsDead() and v.components.combat ~= nil then
	    v.components.combat:GetAttacked(v, TUNING.SDF_PUMPKIN_KING_MIASMA_SMALL_AOE_DAMAGE)

	    --gutable blind effect
	    if v.components.inkable and v.components.sdf_pumpking_gutable then
		v.components.sdf_pumpking_gutable:Gutted()
	    end
	end
    end

    inst:DoTaskInTime(2.5, inst.Remove)
end

local function fn3()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddNetwork()
    inst.entity:AddSoundEmitter()

    local scale = TUNING.SDF_PUMPKIN_KING_MIASMA_SMALL_TELEGRAPH_RADIUS
    inst.AnimState:SetScale(scale, scale)

    inst.AnimState:SetBank("sdf_pumpking_miasma")
    inst.AnimState:SetBuild("sdf_pumpking_miasma")
    inst.AnimState:PlayAnimation("bomb_aoe")

    inst:AddTag("FX")
    inst:AddTag("NOCLICK")

    inst.SoundEmitter:PlaySound("dontstarve/creatures/together/toad_stool/infection_post")

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst.entity:SetCanSleep(false)

    inst.persists = false
    inst:DoTaskInTime(0.1, miasmaSmallAOE)

    return inst
end

local function miasmaSmallTelegraphFade(inst)
    inst.AnimState:PlayAnimation("telegraph_base_pst")

    --create miasma small
    inst:DoTaskInTime(0.25,function()
	local x,_,z=inst.Transform:GetWorldPosition()
	local miasmaSmallFX = SpawnPrefab("sdf_pumpking_miasma_small")
	miasmaSmallFX.Transform:SetPosition(x,_-2,z)

	inst:Remove()
    end)
end

local function fn4()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddNetwork()
    inst.entity:AddSoundEmitter()

    local scale = TUNING.SDF_PUMPKIN_KING_MIASMA_SMALL_TELEGRAPH_RADIUS - 0.2
    inst.AnimState:SetScale(scale, scale)

    inst.AnimState:SetBank("sdf_pumpking_miasma_telegraph")
    inst.AnimState:SetBuild("sdf_pumpking_miasma_telegraph")
    inst.AnimState:PlayAnimation("telegraph_base_pre")
    inst.AnimState:PushAnimation("telegraph_base_idle", true)
    inst.AnimState:SetOrientation(ANIM_ORIENTATION.OnGround)
    inst.AnimState:SetLayer(LAYER_BACKGROUND)
    inst.AnimState:SetSortOrder(3)

    inst:AddTag("FX")
    inst:AddTag("NOCLICK")

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst:AddComponent("entitytracker")

    inst.entity:SetCanSleep(false)

    inst.persists = false

    inst:DoTaskInTime(2.5, inst.SoundEmitter:PlaySound("dontstarve/creatures/together/toad_stool/spore_shoot"))
    inst:DoTaskInTime(TUNING.SDF_PUMPKIN_KING_MIASMA_SMALL_TELEGRAPH_TIME, miasmaSmallTelegraphFade)

    return inst
end

local function miasmaDeathAOE(inst)
    local x, y, z = inst.Transform:GetWorldPosition()
    local ents = TheSim:FindEntities(x, y, z, TUNING.SDF_PUMPKIN_KING_MIASMA_DEATH_AOE_RADIUS)
    for i, v in ipairs(ents) do
	if v.components.health ~= nil and not v.components.health:IsDead() and v.components.combat ~= nil then
	    if v:HasTag("sdf_pumpkin_king") or v:HasTag("sdf_pumpking_seed_pod") then
	    elseif v:HasTag("sdf_pumpking_gourd") or v:HasTag("sdf_pumpking_gourd_vine") or v:HasTag("sdf_pumpking_bomb") or v:HasTag("sdf_pumpking_creeper")
		or v:HasTag("sdf_pumpkin_gourd") or v:HasTag("sdf_pumpkin_gourd_vine") or v:HasTag("sdf_pumpkin_bomb") or v:HasTag("sdf_pumpkin_creeper") then
		v.components.health:Kill()
	    else
		v.components.combat:GetAttacked(v, TUNING.SDF_PUMPKIN_KING_MIASMA_DEATH_AOE_DAMAGE)
	    end
	elseif v:HasTag("sdf_pumpking_gourd_plant") or v:HasTag("sdf_pumpking_bomb_plant") or v:HasTag("sdf_pumpking_creeper_plant") 
		or v:HasTag("sdf_pumpkin_gourd_plant") or v:HasTag("sdf_pumpkin_bomb_plant") or v:HasTag("sdf_pumpkin_creeper_plant") then
	    v:Remove()
	end
    end

    inst:DoTaskInTime(2.5, inst.Remove)
end

local function fn5()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddNetwork()
    inst.entity:AddSoundEmitter()

    local scale = TUNING.SDF_PUMPKIN_KING_MIASMA_DEATH_TELEGRAPH_RADIUS + 0.5
    inst.AnimState:SetScale(scale, scale)

    inst.AnimState:SetBank("sdf_pumpking_miasma_death")
    inst.AnimState:SetBuild("sdf_pumpking_miasma_death")
    inst.AnimState:PlayAnimation("aoe_pre")
    inst.AnimState:PushAnimation("aoe_pst", false)

    inst:AddTag("FX")
    inst:AddTag("NOCLICK")

    inst.SoundEmitter:PlaySound("dontstarve/creatures/together/toad_stool/infection_attack_pre")

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst.entity:SetCanSleep(false)

    inst.persists = false
    inst:DoTaskInTime(0.1, miasmaDeathAOE)

    return inst
end

local function miasmaDeathTelegraphFade(inst)
    inst.AnimState:PlayAnimation("telegraph_base_pst")

    --create miasma death
    inst:DoTaskInTime(0.25,function()
	local x,_,z=inst.Transform:GetWorldPosition()
	local miasmaDeathFX = SpawnPrefab("sdf_pumpking_miasma_death")
	miasmaDeathFX.Transform:SetPosition(x,_,z)

	inst:Remove()
    end)
end

local function fn6()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddNetwork()
    inst.entity:AddSoundEmitter()

    local scale = TUNING.SDF_PUMPKIN_KING_MIASMA_DEATH_TELEGRAPH_RADIUS
    inst.AnimState:SetScale(scale, scale)

    inst.AnimState:SetBank("sdf_pumpking_miasma_telegraph")
    inst.AnimState:SetBuild("sdf_pumpking_miasma_telegraph")
    inst.AnimState:PlayAnimation("telegraph_base_pre")
    inst.AnimState:PushAnimation("telegraph_base_idle", true)
    inst.AnimState:SetOrientation(ANIM_ORIENTATION.OnGround)
    inst.AnimState:SetLayer(LAYER_BACKGROUND)
    inst.AnimState:SetSortOrder(3)

    inst:AddTag("FX")
    inst:AddTag("NOCLICK")

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst.entity:SetCanSleep(false)

    inst.persists = false

    inst:DoTaskInTime(2.5, inst.SoundEmitter:PlaySound("dontstarve/creatures/together/toad_stool/spore_shoot"))
    inst:DoTaskInTime(TUNING.SDF_PUMPKIN_KING_MIASMA_DEATH_TELEGRAPH_TIME, miasmaDeathTelegraphFade)

    return inst
end

return Prefab("sdf_pumpking_miasma", fn, assets),
	Prefab("sdf_pumpking_miasma_telegraph", fn2, assets),
	Prefab("sdf_pumpking_miasma_small", fn3, assets),
	Prefab("sdf_pumpking_miasma_small_telegraph", fn4, assets),
	Prefab("sdf_pumpking_miasma_death", fn5, assets),
	Prefab("sdf_pumpking_miasma_death_telegraph", fn6, assets)