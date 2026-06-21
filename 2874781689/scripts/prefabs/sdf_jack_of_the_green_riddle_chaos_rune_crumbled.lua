local assets=
{
    Asset("ANIM", "anim/sdf_jack_of_the_green_riddle_chaos_rune_crumbled.zip"),
}

prefabs = {
}

local CHAOS_RUNE_ON = false --Use for pickable

local function ongrow(inst)
end

local function onharvest(inst, picker, produce)
    if inst.components.harvestable then
	inst.components.harvestable:SetGrowTime(nil)
	inst.components.harvestable.pausetime = nil
	inst.components.harvestable:StopGrowing()

	local holder = picker ~= nil and (picker.components.inventory or picker.components.container) or nil

	--give fragments
	local chaosRuneFragment = SpawnPrefab("sdf_jack_of_the_green_riddle_chaos_rune_fragment")
	if chaosRuneFragment.components.stackable then
	    chaosRuneFragment.components.stackable:SetStackSize(TUNING.SDF_JACK_OF_THE_GREEN_RIDDLE_CHAOS_RUNE_FRAGMENT_MAXSTACKCOUNT)
	end
	if holder ~= nil then
	    local slot = holder:GetItemSlot(inst)
	    holder:GiveItem(chaosRuneFragment, slot)
 	end
    end
end


local function chaosruneturnoff(inst)
    if inst.CHAOS_RUNE_ON == true then
	inst.CHAOS_RUNE_ON = false
	inst.components.harvestable:SetUp("", 0, nil, onharvest, ongrow)
    end
end

local function chaosruneturnon(inst, player)
    if player.prefab == "sdf" then
	if player:HasTag("sdf_riddle_3_active") or player:HasTag("sdf_chaos_rock_engraft") then
	    --chaos rune on
	    inst.CHAOS_RUNE_ON = true

	    --greet
	    inst:DoTaskInTime(0,function()
		inst.components.harvestable:SetUp("", 1, 1, onharvest, ongrow)
	    end)
	end
    end
end

local function fn()

    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddNetwork()
    inst.entity:AddSoundEmitter()

    inst.Transform:SetScale(0.5, 0.5, 0.5)

    inst.AnimState:SetBank("sdf_jack_of_the_green_riddle_chaos_rune_crumbled")
    inst.AnimState:SetBuild("sdf_jack_of_the_green_riddle_chaos_rune_crumbled")
    inst.AnimState:PlayAnimation("idle")
    inst.AnimState:SetBloomEffectHandle( "shaders/anim.ksh" )	

    MakeObstaclePhysics(inst, .1)


    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst:AddComponent("harvestable")

    inst:AddComponent("inspectable")

    inst:AddComponent("playerprox")
    inst.components.playerprox:SetDist(2.1,2.3)
    inst.components.playerprox:SetOnPlayerNear(chaosruneturnon)
    inst.components.playerprox:SetOnPlayerFar(chaosruneturnoff)

    inst:AddComponent("hauntable")
    inst.components.hauntable:SetHauntValue(TUNING.HAUNT_TINY)

    return inst
end

return  Prefab("sdf_jack_of_the_green_riddle_chaos_rune_crumbled", fn, assets)