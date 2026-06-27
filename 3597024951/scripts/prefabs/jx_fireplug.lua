local assets =
{
  Asset("ANIM", "anim/jx_fireplug.zip"),
	Asset("ANIM", "anim/winona_battery_placement.zip"),
}

local prefabs =
{
	"collapse_small",
}

local function onhammered(inst)--, worker)
	inst.components.lootdropper:DropLoot()
	local fx = SpawnPrefab("collapse_small")
	fx.Transform:SetPosition(inst.Transform:GetWorldPosition())
	fx:SetMaterial("metal")
	inst:Remove()
end

local function onhit(inst)
  inst.AnimState:PlayAnimation("hit")
  inst.AnimState:PushAnimation("idle")
end

local function OnBuilt(inst)
  inst.AnimState:PlayAnimation("place")
  inst.AnimState:PushAnimation("idle")
end

local function onspawn(inst)
  local x, y, z = inst.Transform:GetWorldPosition()
  local ents = TheSim:FindEntities(x, y, z, 4, {"structure"})
  for _, v in pairs(ents) do
    if v.prefab == "firesuppressor" or v.enable_jx_fireplug == true then --enable_jx_fireplug 留作兼容
      if v.components.firedetector and v.old_firedetector_range == nil then
        local old_range = v.components.firedetector.range
        v.components.firedetector.range = old_range * inst.range_mult
        v.old_firedetector_range = old_range
        if v.jx_firedetector_range then
          v.jx_firedetector_range:set(true)
        end
      end
    end
  end
end

local function onremove(inst)
  local x, y, z = inst.Transform:GetWorldPosition()
  local ents = TheSim:FindEntities(x, y, z, 4, {"structure"})
  for _, v in pairs(ents) do
    if v.prefab == "firesuppressor" or v.enable_jx_fireplug == true then --enable_jx_fireplug 留作兼容
      if v.components.firedetector and v.old_firedetector_range then
        v.components.firedetector.range = v.old_firedetector_range
        v.old_firedetector_range = nil
        if v.jx_firedetector_range then
          v.jx_firedetector_range:set(false)
        end
      end
    end
  end
end

local function CreateHelperRing()
    local inst = CreateEntity()
    
    inst.entity:SetCanSleep(false)
    inst.persists = false
    
    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    
    inst:AddTag("CLASSIFIED")
    inst:AddTag("NOCLICK")
    inst:AddTag("placer")
        
    inst.AnimState:SetBank("winona_battery_placement")
    inst.AnimState:SetBuild("winona_battery_placement")
    inst.AnimState:PlayAnimation("idle")
    inst.AnimState:SetLightOverride(1)
    inst.AnimState:SetOrientation(ANIM_ORIENTATION.OnGround)
    inst.AnimState:SetLayer(LAYER_BACKGROUND)
    inst.AnimState:SetSortOrder(1)
    inst.AnimState:SetAddColour(0, .2, .5, 0)
    
    return inst
end

local function OnEnableHelper(inst, enabled, recipename, placerinst)
  if enabled then
    if inst.inner_helper == nil then
      inst.inner_helper = CreateHelperRing()
      inst.inner_helper.AnimState:Hide("outer")
      inst.inner_helper.entity:SetParent(inst.entity)
      local inner_radius_scale = .8
      inst.inner_helper.AnimState:SetScale(inner_radius_scale, inner_radius_scale)
      if recipename == "firesuppressor" and placerinst ~= nil then
        if placerinst.helperinst_table == nil then
          placerinst.helperinst_table = {}
        end
        table.insert(placerinst.helperinst_table, inst.inner_helper)
      end
    end
    if inst.outer_helper == nil then
      inst.outer_helper = CreateHelperRing()
      inst.outer_helper.AnimState:Hide("inner")
      inst.outer_helper.entity:SetParent(inst.entity)
      local outer_radius_scale = 8 / 9
      inst.outer_helper.AnimState:SetScale(outer_radius_scale, outer_radius_scale)
    end
  else
    if inst.inner_helper ~= nil then
      inst.inner_helper:Remove()
      inst.inner_helper = nil
    end
    if inst.outer_helper ~= nil then
      inst.outer_helper:Remove()
      inst.outer_helper = nil
    end
  end
end

local function fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()
    inst.entity:AddNetwork()
    
	  inst:SetDeploySmartRadius(0.5)
    MakeObstaclePhysics(inst, 1)
    
    inst:AddTag("structure")
    inst:AddTag("jx_fireplug")
    
    inst.AnimState:SetBank("jx_fireplug")
    inst.AnimState:SetBuild("jx_fireplug")
    inst.AnimState:PlayAnimation("idle")
    
    if not TheNet:IsDedicated() then
        inst:AddComponent("deployhelper")
        inst.components.deployhelper:AddRecipeFilter("jx_fireplug")
        inst.components.deployhelper:AddRecipeFilter("firesuppressor")
        inst.components.deployhelper.onenablehelper = OnEnableHelper
    end
    
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
    
    inst.range_mult = 1 + TUNING.JX_TUNING.jx_fireplug_scale1
    
    inst:DoTaskInTime(2 * FRAMES, onspawn)--比灭火器的延迟任务推迟一帧
    
    inst:ListenForEvent("onbuilt", OnBuilt)
    inst:ListenForEvent("onremove", onremove)
    
    return inst
end

local function placer_postinit_fn(inst)
	  inst.AnimState:Hide("inner")
    
    local inner = CreateEntity()
    inner.entity:SetCanSleep(false)
    inner.persists = false
    
    inner.entity:AddTransform()
    inner.entity:AddAnimState()

    inner:AddTag("CLASSIFIED")
    inner:AddTag("NOCLICK")
    inner:AddTag("placer")

    inner.AnimState:SetBank("winona_battery_placement")
    inner.AnimState:SetBuild("winona_battery_placement")
    inner.AnimState:PlayAnimation("idle")
    inner.AnimState:SetLightOverride(1)
	  inner.AnimState:SetOrientation(ANIM_ORIENTATION.OnGround)
	  inner.AnimState:Hide("outer")
    
    inner.entity:SetParent(inst.entity)
    inst.components.placer:LinkEntity(inner)

  	local inner_radius_scale = .8
    inner.AnimState:SetScale(inner_radius_scale, inner_radius_scale)

	  local outer_radius_scale = 8 / 9
    inst.AnimState:SetScale(outer_radius_scale, outer_radius_scale)
    ---
    
    local placer2 = CreateEntity()
    placer2.entity:SetCanSleep(false)
    placer2.persists = false

    placer2.entity:AddTransform()
    placer2.entity:AddAnimState()

    placer2:AddTag("CLASSIFIED")
    placer2:AddTag("NOCLICK")
    placer2:AddTag("placer")

    placer2.AnimState:SetBank("jx_fireplug")
    placer2.AnimState:SetBuild("jx_fireplug")
    placer2.AnimState:PlayAnimation("idle")
    placer2.AnimState:SetLightOverride(1)

    placer2.entity:SetParent(inst.entity)
    inst.components.placer:LinkEntity(placer2)
end

return Prefab("jx_fireplug", fn, assets, prefabs),
    MakePlacer("jx_fireplug_placer", "winona_battery_placement", "winona_battery_placement", "idle", true, nil, nil, nil, nil, nil, placer_postinit_fn)