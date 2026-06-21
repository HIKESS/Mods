local assets =
{
    Asset("ANIM", "anim/sdf_mullock_chief_memorial.zip"),
}

local prefabs = {

}

local function ondig(inst, worker)
    inst.components.workable:SetWorkLeft(1)
    if worker ~= nil then
	local handItem = worker.components.inventory:GetEquippedItem(EQUIPSLOTS.HANDS)
	if handItem and handItem.prefab == "sdf_spade" then
	    inst.digCounter = 0
	    inst.AnimState:PlayAnimation("dug")
	    inst:RemoveComponent("workable")

	    --check for sdf on anubis stone quest
	    if worker.prefab == "sdf" then
		local hasAnubisStonePart1 = worker.components.sdf_anubis_stone_quest:GetAnubisStonePart1FoundStatus()
		if hasAnubisStonePart1 == false then

		    --set anubis stone part 1 found
		    worker.components.sdf_anubis_stone_quest:SetAnubisStonePart1FoundStatus()

		    --create anubis stone part 1
		    inst.components.lootdropper:SpawnLootPrefab("sdf_anubis_stone_part1")
		end
	    end

	    --loot
	    inst.components.lootdropper:SpawnLootPrefab("boneshard")
	    inst.components.lootdropper:SpawnLootPrefab("boneshard")
	    inst.components.lootdropper:SpawnLootPrefab("boneshard")

	    --Break Spade
	    handItem.components.finiteuses:Use(TUNING.SDF_SPADE_DURABILITY)
	else
	    inst.digCounter = inst.digCounter + 1
	    if inst.digCounter == 3 then
		worker:DoTaskInTime(1, function()
		    worker.components.talker:Say(GetString(worker, "ANNOUNCE_MULLOCKCHEIFMEMORIALMOUNTNODIG1"))
		end)
	    elseif inst.digCounter == 6 then
		worker:DoTaskInTime(1, function()
		    worker.components.talker:Say(GetString(worker, "ANNOUNCE_MULLOCKCHEIFMEMORIALMOUNTNODIG2"))
		end)
	    elseif inst.digCounter >= 9 then
		inst.digCounter = 0
		worker:DoTaskInTime(1, function()
		    worker.components.talker:Say(GetString(worker, "ANNOUNCE_MULLOCKCHEIFMEMORIALMOUNTNODIG3"))
		end)
	    end
	end
    end
end

local function on_day_change(inst)
    if inst.components.workable ~= nil then
	return
    end

    local regenerationCount = inst.components.sdf_chest_regeneration:GetRegenerationCount()
    local regenerationCountMax = inst.components.sdf_chest_regeneration:GetMaxRegenerationCount()

    if regenerationCount >= regenerationCountMax then
	local x,_,z = inst.Transform:GetWorldPosition()
	SpawnPrefab("halloween_moonpuff").Transform:SetPosition(x,_,z)
	inst:DoTaskInTime(0.5, function()
	    inst.AnimState:PlayAnimation("gravedirt")
	    inst:AddComponent("workable")
	    inst.components.workable:SetWorkAction(ACTIONS.DIG)
	    inst.components.workable:SetWorkLeft(1)
	    inst.components.workable:SetOnFinishCallback(ondig)
	end)
    else
	inst.components.sdf_chest_regeneration:SetRegenerationCount(regenerationCount + 1)
    end
end

local function GetStatus(inst)
    if not inst.components.workable then
        return "DUG"
    end
end

local function OnSave(inst, data)
    if inst.components.workable == nil then
        data.dug = true
    end
end

local function OnLoad(inst, data)
    if data ~= nil and data.dug or inst.components.workable == nil then
        inst:RemoveComponent("workable")
        inst.AnimState:PlayAnimation("dug")
    end
end

local function OnHaunt(inst, haunter)
    return true
end

local function fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddNetwork()
    inst.entity:AddSoundEmitter()

    local s = 1.3 --1.3
    inst.Transform:SetScale(s,s,s)

    inst.AnimState:SetBank("sdf_mullock_chief_memorial")
    inst.AnimState:SetBuild("sdf_mullock_chief_memorial")
    inst.AnimState:PlayAnimation("gravedirt")

    inst:AddTag("grave")
    inst:AddTag("buried")

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    --Allows regeneration of Mullock chief memorial mound
    inst:AddComponent("sdf_chest_regeneration")
    inst.components.sdf_chest_regeneration:SetMaxRegenerationCount(TUNING.SDF_MULLOCK_CHIEF_MEMORIAL_MOUNT_REGENERATION_DAY_MAX)

    inst:AddComponent("inspectable")
    inst.components.inspectable.getstatus = GetStatus

    inst:AddComponent("lootdropper")

    inst:AddComponent("workable")
    inst.components.workable:SetWorkAction(ACTIONS.DIG)
    inst.components.workable:SetWorkLeft(1)
    inst.components.workable:SetOnFinishCallback(ondig)

    inst:AddComponent("hauntable")
    inst.components.hauntable:SetHauntValue(TUNING.HAUNT_SMALL)
    inst.components.hauntable:SetOnHauntFn(OnHaunt)

    inst.digCounter = 0

    inst:WatchWorldState("cycles", on_day_change)

    inst.OnSave = OnSave
    inst.OnLoad = OnLoad

    return inst
end

local function fn2()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddNetwork()

    local s = 1.5 --1.5
    inst.Transform:SetScale(s,s,s)

    inst.AnimState:SetBank("sdf_mullock_chief_memorial")
    inst.AnimState:SetBuild("sdf_mullock_chief_memorial")
    inst.AnimState:PlayAnimation("ground")

    inst.AnimState:SetOrientation(ANIM_ORIENTATION.OnGround)
    inst.AnimState:SetLayer(LAYER_BACKGROUND)

    inst:AddTag("NOCLICK")
    inst:AddTag("DECOR")

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst:AddComponent("hauntable")
    inst.components.hauntable:SetHauntValue(TUNING.HAUNT_TINY)

    return inst
end

return 	Prefab("sdf_mullock_chief_memorial_mound", fn, assets, prefabs),
	Prefab("sdf_mullock_chief_memorial", fn2, assets, prefabs)