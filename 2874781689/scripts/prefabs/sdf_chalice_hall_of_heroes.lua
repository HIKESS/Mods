local assets=
{
    Asset("ATLAS", "images/map_icons/sdf_chalice_hall_of_heroes_mm.xml"),
    Asset("IMAGE", "images/map_icons/sdf_chalice_hall_of_heroes_mm.tex"),

    Asset("ANIM", "anim/sdf_chalice_hall_of_heroes.zip"),
}

prefabs = {
}

local CHALICEFILLED = false --Use for used chalices
local GOODLIGHTNINGREADY = false --Use for Good Lightning effects

local function updateDescription(inst, sdf)
    --inspect collected update
    local maxChaliceCount = sdf.components.sdf_chalice_counter:GetMaxChaliceCount()
    local usedChaliceCount = sdf.components.sdf_chalice_counter:GetUsedChaliceCount()
    local bonusChaliceCount = usedChaliceCount - maxChaliceCount

    if bonusChaliceCount > 0 then
	inst.components.inspectable:SetDescription("Chalice of Souls \n"..(maxChaliceCount).."/"..(maxChaliceCount).."\n" ..(bonusChaliceCount).." Bonus Collected")
    else
	inst.components.inspectable:SetDescription("Chalice of Souls \n"..(usedChaliceCount).."/"..(maxChaliceCount).."\nCollected")
    end
end

local function goodlightningFX(inst)
    local x,_,z = inst.Transform:GetWorldPosition()
    inst.SoundEmitter:PlaySound("dontstarve/common/lightningrod")
    SpawnPrefab("lightning_rod_fx").Transform:SetPosition(x,_,z)
    inst.goodlightningtask = inst:DoTaskInTime(math.random(2, 5), goodlightningFX)
end

local function startgoodlightning(inst)
    inst.goodlightningtask = inst:DoTaskInTime(math.random(2, 5), goodlightningFX)
end

local function chaliceturnoff(inst)
    inst.components.inspectable:SetDescription("A massive Goblet filled with collection of all the gathered soul chalices.")

    if inst.GOODLIGHTNINGREADY == true then
	inst.GOODLIGHTNINGREADY = false
	inst.goodlightningtask:Cancel()
    	local x,_,z = inst.Transform:GetWorldPosition()
	SpawnPrefab("monkey_morphin_power_players_fx").Transform:SetPosition(x,_,z)
        inst.AnimState:PushAnimation("idle",true)
    end

    if inst.CHALICEFILLED == true then
	inst.CHALICEFILLED = false
	local x,_,z = inst.Transform:GetWorldPosition()
	SpawnPrefab("monkey_morphin_power_players_fx").Transform:SetPosition(x,_,z)
        inst.AnimState:PushAnimation("idle",true)
    end
end

local function chaliceturnon(inst, player)
    if player.prefab == "sdf" then
	local x,_,z = inst.Transform:GetWorldPosition()

	--inspect collected update
	updateDescription(inst, player)

	--Setup for viewing
	--local hero_Enabled = player.components.sdf_chalice_id_lock:CheckHeroStatus()
	local goodLightningSample = player.components.sdf_chalice_id_lock:HasGoodLightningSample()
	local chaliceLock = player.components.sdf_chalice_id_lock:GetLock()
	local chaliceAllCollected = player.components.sdf_chalice_id_lock:CheckLocks(chaliceLock)
	local chaliceFilledPercent = player.components.sdf_souls:GetPercent()

	--Allows Good Lightning effect

	    if (player:HasTag("sdf_goodlightning_builder") and chaliceFilledPercent > 0) or goodLightningSample == true then
		inst.GOODLIGHTNINGREADY = true
		inst.goodlightningtask = inst:DoTaskInTime(0, startgoodlightning)
	    end

	    --chalice filled effect
	    local chaliceUsedCount = player.components.sdf_chalice_counter:GetUsedChaliceCount()
	    local chaliceMaxCount = player.components.sdf_chalice_counter:GetMaxChaliceCount()
	    if chaliceUsedCount >= chaliceMaxCount then
		inst.CHALICEFILLED = true
		inst.AnimState:PushAnimation("filled_100", true)
		SpawnPrefab("monkey_cursed_pre_fx").Transform:SetPosition(x,_,z)
		inst.SoundEmitter:PlaySound("monkeyisland/wonkycurse/curse_fx")
	    elseif chaliceUsedCount >= 15 then
		inst.CHALICEFILLED = true
		inst.AnimState:PushAnimation("filled_75", true)
		SpawnPrefab("monkey_cursed_pre_fx").Transform:SetPosition(x,_,z)
		inst.SoundEmitter:PlaySound("monkeyisland/wonkycurse/curse_fx")
	    elseif chaliceUsedCount >=10 then
		inst.CHALICEFILLED = true
		inst.AnimState:PushAnimation("filled_50", true)
		SpawnPrefab("monkey_cursed_pre_fx").Transform:SetPosition(x,_,z)
		inst.SoundEmitter:PlaySound("monkeyisland/wonkycurse/curse_fx")
	    elseif chaliceUsedCount >=5 then
		inst.CHALICEFILLED = true
		inst.AnimState:PushAnimation("filled_25", true)
		SpawnPrefab("monkey_cursed_pre_fx").Transform:SetPosition(x,_,z)
		inst.SoundEmitter:PlaySound("monkeyisland/wonkycurse/curse_fx")
	    else
		inst.CHALICEFILLED = true
		inst.AnimState:PushAnimation("filled_0", true)
		SpawnPrefab("monkey_cursed_pre_fx").Transform:SetPosition(x,_,z)
		inst.SoundEmitter:PlaySound("monkeyisland/wonkycurse/curse_fx")
	    end
    end
end

local function showOnMap(inst)
    if inst.icon == nil then
        inst.icon = SpawnPrefab("globalmapicon")
        inst.icon:TrackEntity(inst)
    end
end

local function fn()

    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddMiniMapEntity()
    inst.entity:AddNetwork()
    inst.entity:AddSoundEmitter()

    inst.MiniMapEntity:SetIcon("sdf_chalice_hall_of_heroes_mm.tex")
    inst.MiniMapEntity:SetCanUseCache(false)
    inst.MiniMapEntity:SetDrawOverFogOfWar(true)

    local s = 1.5 --1.5
    inst.Transform:SetScale(s,s,s)
    
    MakeObstaclePhysics(inst, 1.3) --1.1

    inst.AnimState:SetBank("sdf_chalice_hall_of_heroes")
    inst.AnimState:SetBuild("sdf_chalice_hall_of_heroes")
    inst.AnimState:PlayAnimation("idle",true)


    inst:AddTag("structure")
    inst:AddTag("sdf_chalice_goodlightning")
    inst:AddTag("sdf_chalice_hall_of_heroes")
    inst:AddTag("sdf_soul_helmet_offering")

    --if not TheNet:IsDedicated() then
        --inst:AddComponent("pointofinterest")
        --inst.components.pointofinterest:SetHeight(200)
    --end

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end


    inst:AddComponent("inspectable")

    inst:AddComponent("playerprox")
    inst.components.playerprox:SetDist(3,3.2)
    inst.components.playerprox:SetOnPlayerNear(chaliceturnon)
    inst.components.playerprox:SetOnPlayerFar(chaliceturnoff)

    inst:AddComponent("hauntable")
    inst.components.hauntable:SetHauntValue(TUNING.HAUNT_TINY)

    inst.goodlightningtask = nil

    inst.icon = nil
    inst:DoTaskInTime(0, showOnMap)

    return inst
end

return  Prefab("sdf_chalice_hall_of_heroes", fn, assets)