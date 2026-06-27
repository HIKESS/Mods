local assets =
{
    Asset("ANIM", "anim/jx_cat_tree.zip"),
}

local prefabs = 
{
  "collapse_big",
}

local function onhammered(inst, worker)
    inst.components.lootdropper:DropLoot()
    local fx = SpawnPrefab("collapse_big")
    fx.Transform:SetPosition(inst.Transform:GetWorldPosition())
    fx:SetMaterial("wood")
    inst:Remove()
end

local function onhit(inst, worker)
  if not inst:HasTag("burnt") then
    inst.AnimState:PlayAnimation("hit")
    inst.AnimState:PushAnimation("idle", false)
  end
end

local function onbuilt(inst)
  inst.AnimState:PlayAnimation("place")
  inst.AnimState:PushAnimation("idle", false)
end

local function OnAddKitcoon(inst, kitcoon, doer)
  if kitcoon.components.follower then
	  kitcoon.components.follower:SetLeader(nil)
  end
  if kitcoon.components.entitytracker then
	  kitcoon.components.entitytracker:TrackEntity("home", inst)
  end
	if kitcoon.components.sleeper ~= nil then
		kitcoon.components.sleeper:WakeUp()
	end

	if IsSpecialEventActive(SPECIAL_EVENTS.YOT_CATCOON) then
		if inst.components.kitcoonden and inst.components.kitcoonden.num_kitcoons == NUM_BASIC_KITCOONS then
			local data = {kitcoons = {}}
			TheWorld:PushEvent("ms_collect_uniquekitcoons", data)
			if #data.kitcoons == 0 then
				local uniquekitcoon = SpawnPrefab("kitcoon_yot")
				uniquekitcoon.Transform:SetPosition(inst.Transform:GetWorldPosition())
			end
		end
	end
end

local function OnRemoveKitcoon(inst, kitcoon)
	if kitcoon:IsValid() and kitcoon.components.entitytracker then
		kitcoon.components.entitytracker:ForgetEntity("home", inst)
	end
end

local function OnBurnt(inst)
	DefaultBurntStructureFn(inst)
	inst:RemoveTag("kitcoonden")
	inst:DoTaskInTime(0, function()
    if inst.components.kitcoonden then
	  	inst.components.kitcoonden:RemoveAllKitcoons() 
    end
	end)
end

local function OnPlayerApproached(inst, player)
	player:AddTag("near_kitcoonden")
end

local function OnPlayerLeft(inst, player)
	player:RemoveTag("near_kitcoonden")
end

local function onremoved(inst)
  if inst.components.playerprox then
	  for player, v in pairs(inst.components.playerprox.closeplayers) do
		  if player:IsValid() then
		  	OnPlayerLeft(inst, player)
		  end
	  end
  end
end

local function OnSave(inst, data)
  if inst:HasTag("burnt") or (inst.components.burnable ~= nil and inst.components.burnable:IsBurning()) then
    data.burnt = true
  end
end

local function OnLoad(inst, data)
	if data ~= nil then
    if data.burnt and not inst:HasTag("burnt") then
      OnBurnt(inst)
    end
	end
end

local function fn()
    local inst = CreateEntity()
    
    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddNetwork()
    
    inst:SetDeploySmartRadius(.5)
    MakeObstaclePhysics(inst, .5)
    
    inst:AddTag("structure")
    inst:AddTag("kitcoonden")
    
    inst.AnimState:SetBank("jx_cat_tree")
    inst.AnimState:SetBuild("jx_cat_tree")
    inst.AnimState:PlayAnimation("idle")
    
    inst.entity:SetPristine()
    
    if not TheWorld.ismastersim then
        return inst
    end
    
    inst:AddComponent("inspectable")
    
    inst:AddComponent("lootdropper")
    inst:AddComponent("workable")
    inst.components.workable:SetWorkAction(ACTIONS.HAMMER)
    inst.components.workable:SetWorkLeft(4)
    inst.components.workable:SetOnFinishCallback(onhammered)
    inst.components.workable:SetOnWorkCallback(onhit)
    
    inst:AddComponent("kitcoonden")
    inst.components.kitcoonden.OnAddKitcoon = OnAddKitcoon
	  inst.components.kitcoonden.OnRemoveKitcoon = OnRemoveKitcoon
    
    inst:AddComponent("playerprox")
  	inst.components.playerprox:SetTargetMode(inst.components.playerprox.TargetModes.AllPlayers)
    inst.components.playerprox:SetDist(TUNING.KITCOON_NEAR_DEN_DIST - 4,TUNING.KITCOON_NEAR_DEN_DIST - 1)
    inst.components.playerprox:SetOnPlayerNear(OnPlayerApproached)
    inst.components.playerprox:SetOnPlayerFar(OnPlayerLeft)
	  inst.components.playerprox:SetPlayerAliveMode(inst.components.playerprox.AliveModes.AliveOnly)
    
    inst:ListenForEvent("onbuilt", onbuilt)
    inst:ListenForEvent("onremove", onremoved)
    
    MakeHauntableWork(inst)
    
    MakeMediumBurnable(inst, nil, nil, true)
    inst.components.burnable:SetOnBurntFn(OnBurnt)
    MakeMediumPropagator(inst)
    
    inst.OnSave = OnSave
    inst.OnLoad = OnLoad
    
    return inst
end


return Prefab("jx_cat_tree", fn, assets, prefabs),
  MakePlacer("jx_cat_tree_placer", "jx_cat_tree", "jx_cat_tree", "idle")