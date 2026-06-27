local ret = {}

local assets =
{
	Asset("ANIM", "anim/jx_rug.zip"),
}

local function onworkfinished(inst)
  if inst.components.lootdropper then
    inst.components.lootdropper:DropLoot()
  end
  local item = SpawnPrefab(tostring(inst.prefab).."_item")
  if item then
    item.Transform:SetPosition(inst.Transform:GetWorldPosition())
    if item.components.inventoryitem then
      item.components.inventoryitem:OnDropped(true)
    end
  end
  inst:Remove()
end

local function workmultiplierfn(inst, worker)--, numworks)
  return (worker == nil or not worker:HasTag("player")) and 0 or 1
end

local function ondeploy(inst, pt, deployer)
    if deployer then
      deployer.SoundEmitter:PlaySound("aqol/new_test/cloth")
    end
    local rug_string, count = string.gsub(tostring(inst.prefab), "_item$", "")
    local rug = SpawnPrefab(rug_string)
    if rug then
      rug.Transform:SetPosition(pt.x, 0, pt.z)
      rug.Transform:SetRotation(0)
      
      --部署时如果携带栅栏击剑则允许被点击到
      if rug:HasTag("rotatableobject") 
        and deployer and deployer.components.inventory 
        and 
        (
          deployer.components.inventory:EquipHasTag("fence_rotator") or
          deployer.components.inventory:HasItemWithTag("fence_rotator", 1)
        )
      then
        rug:RemoveTag("NOCLICK")
        if rug.NOCLICK_Tag_Task then
          rug.NOCLICK_Tag_Task:Cancel()
          rug.NOCLICK_Tag_Task = nil
        end
        rug.NOCLICK_Tag_Task = rug:DoTaskInTime(rug.NOCLICK_Tag_Task_Time,function() rug:AddTag("NOCLICK") end)
      end
    end
    inst:Remove()
end

local function onsave(inst, data)
  data.rotation = inst.Transform:GetRotation()
end	

local function onload(inst, data)
  if data and data.rotation then
    inst.Transform:SetRotation(data.rotation)
  end
end

local function StartColorTask(inst, r, g, b, org_a, targ_a)
  local dc = targ_a < org_a and -0.05 or 0.05
  local life = (targ_a - org_a) / dc
  local color = org_a
  if inst.jx_rug_colortask then
    inst.jx_rug_colortask:Cancel()
    inst.jx_rug_colortask = nil
  end
  inst.jx_rug_colortask = inst:DoPeriodicTask(FRAMES, function()
    if life >= 1 then
      life = life - 1
      color = color + dc
      inst.AnimState:SetMultColour(r, g, b, color)
    else
      if inst.jx_rug_colortask then
        inst.jx_rug_colortask:Cancel()
        inst.jx_rug_colortask = nil
      end
      inst.AnimState:SetMultColour(r, g, b, targ_a)
    end
  end)
end

local function MakeRug(name, scale_x, scale_y, scale_z, rotatable, rotatable_angle, placer_scale)
  local function fn()
  	local inst = CreateEntity()
  
	  inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddNetwork()
    inst.entity:AddSoundEmitter()

    inst.AnimState:SetBuild("jx_rug")
    inst.AnimState:SetBank("jx_rug")
    inst.AnimState:PlayAnimation(name)
	  inst.AnimState:SetOrientation(ANIM_ORIENTATION.OnGround)
	  inst.AnimState:SetLayer(LAYER_BACKGROUND)
	  inst.AnimState:SetSortOrder(3)
    inst.AnimState:SetScale(scale_x, scale_y, scale_z)

    inst:AddTag("jx_rug")
	  inst:AddTag("NOCLICK")
  	inst:AddTag("NOBLOCK")
    if rotatable then
      inst:AddTag("rotatableobject")
    end
    
    inst.entity:SetPristine()
    
    if not TheWorld.ismastersim then
        return inst
    end
    
    inst:AddComponent("workable")
    inst.components.workable:SetWorkAction(ACTIONS.JX_RUG_DIG)
    inst.components.workable:SetWorkLeft(1)
    inst.components.workable:SetOnFinishCallback(onworkfinished)
    inst.components.workable:SetWorkMultiplierFn(workmultiplierfn)
    
    if rotatable then
      inst.rotatable_angle = rotatable_angle
    end
    inst.NOCLICK_Tag_Task_Time = 5
    
  	inst.OnSave = onsave 
    inst.OnLoad = onload
    
    inst.Transform:SetRotation(0)

	  return inst
  end
  
  local function item_fn()
  	local inst = CreateEntity()
  
	  inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddNetwork()
    inst.entity:AddSoundEmitter()
    
    MakeInventoryPhysics(inst)
    
    inst:AddTag("jx_rug_item")

    inst.AnimState:SetBuild("jx_rug")
    inst.AnimState:SetBank("jx_rug_item")
    inst.AnimState:PlayAnimation(name.."_item")
    
    inst.entity:SetPristine()
    
    if not TheWorld.ismastersim then
        return inst
    end
    
    inst:AddComponent("inspectable")
    inst:AddComponent("inventoryitem")
    inst.components.inventoryitem:SetSinks(true)
    
    inst:AddComponent("stackable")
    inst.components.stackable.maxsize = TUNING.STACK_SIZE_LARGEITEM
    
    MakeHauntableLaunch(inst)
    
    inst:AddComponent("deployable")
    inst.components.deployable.ondeploy = ondeploy
    inst.components.deployable:SetDeployMode(DEPLOYMODE.ANYWHERE)
    
	  return inst
  end
  
  local function placer_postinit_fn(inst)
    inst.AnimState:SetSortOrder(-1)
    inst.HelperEntityTable = {}
    inst:DoPeriodicTask(.2, function()
      local x, y, z = inst.Transform:GetWorldPosition()
      local ents = TheSim:FindEntities(x, y, z, 2.5, nil, { "INLIMBO", "jx_rug", "player" })
      for _, v in ipairs(ents) do
        if v.AnimState ~= nil and v.jx_rug_colortask == nil
          and not (v.entity:GetParent() ~= nil and v.entity:GetParent():HasTag("player"))
        then
          if inst.HelperEntityTable[v] == nil then
            local retain_NOCLICK_Tag = v:HasTag("NOCLICK")
            local r, g, b, a = v.AnimState:GetMultColour()
            inst.HelperEntityTable[v] = { r = r, g = g, b = b, a = a , retag = retain_NOCLICK_Tag}
            StartColorTask(v, r, g, b, a, 0)
            v:AddTag("NOCLICK")
          end
        end
      end
      for ent, data in pairs(inst.HelperEntityTable) do
        if ent and ent:IsValid() and not ent:IsNear(inst, 4) then
          local r, g, b, a = ent.AnimState:GetMultColour()
          StartColorTask(ent, data.r, data.g, data.b, a, data.a)
          if not data.retag then
            ent:RemoveTag("NOCLICK")
          end
          inst.HelperEntityTable[ent] = nil
        end
      end
    end)
  
    inst:ListenForEvent("onremove", function()
      for ent, data in pairs(inst.HelperEntityTable) do
        if ent and ent:IsValid() then
          local r, g, b, a = ent.AnimState:GetMultColour()
          StartColorTask(ent, data.r, data.g, data.b, a, data.a)
          if not data.retag then
            ent:RemoveTag("NOCLICK")
          end
        end
      end
    end)
  end
  
  table.insert(ret, Prefab(name, fn, assets))
  table.insert(ret, Prefab(name.."_item", item_fn, assets))
  table.insert(ret, MakePlacer(name.."_item_placer", "jx_rug", "jx_rug", name, true, nil, nil, placer_scale, nil, nil, placer_postinit_fn))
end

--       name,               scale_x, scale_y, scale_z, rotatable,  rotatable_angle,   placer_scale
MakeRug("jx_rug_oval",       1.3,     1.3,     1.3,     true,          90,              1.1       )--椭圆形地毯
MakeRug("jx_rug_forest",     1.31,    1.34,    1.3,     false,         nil,             1.13      )--森林之歌方形地毯
MakeRug("jx_rug_aubusson",   1.31,    1.34,    1.3,     false,         nil,             1.13      )--奥布松丝绸挂毯
MakeRug("jx_rug_tradition",  1.31,    1.34,    1.3,     false,         nil,             1.13      )--传统平织方格地毯
MakeRug("jx_rug_savannah",   1.31,    1.34,    1.3,     true,          90,              1.13      )--萨瓦纳瑞手工地毯
MakeRug("jx_rug_triangle",   1.44,    1.44,    1.44,    true,          180,             1.15      )--印第安图腾三角毯
MakeRug("jx_rug_platoni",    1.7,     1.7,     1.7,     false,         nil,             1.30      )--普拉托尼正圆地毯

return unpack(ret)