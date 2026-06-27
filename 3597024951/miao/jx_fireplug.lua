local G = GLOBAL

local FIRESUPPRESSOR_PLACER_SCALE = 1
local FIRESUPPRESSOR_PLACER_SCALE_2 = FIRESUPPRESSOR_PLACER_SCALE * (1 + G.TUNING.JX_TUNING.jx_fireplug_scale1)
local PLACER_TRANSFORM_SCALE = 1.55 -- 1.55 在 firesuppressor 的预制件文件中定义
local PLACER_ANIMSTATE_SCALE = 1 + G.TUNING.JX_TUNING.jx_fireplug_scale1

local DEPLOY_RANGE = 4

local function onspawn(inst)
  if inst.old_firedetector_range == nil then
    local x, y, z = inst.Transform:GetWorldPosition()
    local ents = G.TheSim:FindEntities(x, y, z, 4, {"jx_fireplug"})
    if #ents > 0 then
      local range_mult = ents[1].range_mult
      if inst.components.firedetector and inst.old_firedetector_range == nil then
        local old_range = inst.components.firedetector.range
        inst.components.firedetector.range = old_range * range_mult
        inst.old_firedetector_range = old_range
        if inst.jx_firedetector_range then
          inst.jx_firedetector_range:set(true)
        end
      end
    end
  end
end

local function CreateHelperRing()
    local inst = G.CreateEntity()
    
    inst.entity:SetCanSleep(false)
    inst.persists = false
    
    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    
    inst:AddTag("CLASSIFIED")
    inst:AddTag("NOCLICK")
    inst:AddTag("placer")
    
    inst.Transform:SetScale(PLACER_TRANSFORM_SCALE, PLACER_TRANSFORM_SCALE, PLACER_TRANSFORM_SCALE)
    
    inst.AnimState:SetBank("firefighter_placement")
    inst.AnimState:SetBuild("firefighter_placement")
    inst.AnimState:PlayAnimation("idle")
    inst.AnimState:SetScale(PLACER_ANIMSTATE_SCALE, PLACER_ANIMSTATE_SCALE, PLACER_ANIMSTATE_SCALE)
    inst.AnimState:SetLightOverride(1)
    inst.AnimState:SetOrientation(G.ANIM_ORIENTATION.OnGround)
    inst.AnimState:SetLayer(G.LAYER_BACKGROUND)
    inst.AnimState:SetSortOrder(1)
    inst.AnimState:SetAddColour(0, .2, .5, 0)
    
    return inst
end

local function OnUpdatePlacerHelper(outer)
    if not outer.placerinst:IsValid() then
      outer.components.updatelooper:RemoveOnUpdateFn(OnUpdatePlacerHelper)
      outer.AnimState:SetMultColour(1, 1, 1, 0)
    elseif outer:IsNear(outer.placerinst, DEPLOY_RANGE) then
      outer.AnimState:SetMultColour(1, 1, 1, 1)
    else
      outer.AnimState:SetMultColour(1, 1, 1, 0)
    end
end

local function OnEnableHelper(inst, enabled, recipename, placerinst)
  --inst.helper 在旧的函数中被创建。inst.outer_helper 是由此文件新建，指的是扩大25%后的那个圈。
  if enabled then
    if placerinst ~= nil then
      inst:DoTaskInTime(.2, function()
        if inst.helper ~= nil then
          if inst.jx_firedetector_range and inst.jx_firedetector_range:value() then
            inst.helper.AnimState:SetScale(PLACER_ANIMSTATE_SCALE, PLACER_ANIMSTATE_SCALE, PLACER_ANIMSTATE_SCALE)
          elseif recipename == "jx_fireplug" and inst.outer_helper == nil then
            local outer = CreateHelperRing()
            outer.entity:SetParent(inst.entity)
            outer:AddComponent("updatelooper")
            outer.components.updatelooper:AddOnUpdateFn(OnUpdatePlacerHelper)
            outer.placerinst = placerinst
            OnUpdatePlacerHelper(outer)
            inst.outer_helper = outer
          end
        end
      end)
    end
  elseif inst.outer_helper then
    inst.outer_helper:Remove()
    inst.outer_helper = nil
  end
end

AddPrefabPostInit("firesuppressor", function(inst)
    if not G.TheNet:IsDedicated() then
      if inst.components.deployhelper then
        inst.components.deployhelper:AddRecipeFilter("jx_fireplug")
        inst.components.deployhelper:AddRecipeFilter("firesuppressor")
        
        local old_onenablehelper = inst.components.deployhelper.onenablehelper
        inst.components.deployhelper.onenablehelper = function(inst, enabled, recipename, placerinst)
          old_onenablehelper(inst, enabled, recipename, placerinst)
          OnEnableHelper(inst, enabled, recipename, placerinst)
        end
      end
    end
    
    inst.jx_firedetector_range = G.net_bool(inst.GUID, "jx_firedetector_range") -- 用于帮助识别是否在消防栓范围内
    
    if not G.TheWorld.ismastersim then
      return
    end
    
    inst.jx_firedetector_range:set(false)
    
    inst:DoTaskInTime(0, onspawn)
end)

local function OnUpdatePlacerHelper_2(inst)
  local scale = FIRESUPPRESSOR_PLACER_SCALE
  if inst.helperinst_table then -- helperinst_table 在 jx_fireplug 的预制件文件中创建
    local near_enough
    for _, v in pairs(inst.helperinst_table) do
      if v:IsValid() and inst:IsNear(v, DEPLOY_RANGE) then
        near_enough = true
        break
      end
    end
    if near_enough then
      scale = FIRESUPPRESSOR_PLACER_SCALE_2
    end
  end
  inst.AnimState:SetScale(scale, scale, scale)
end

AddPrefabPostInit("firesuppressor_placer", function(inst)
    if G.TheNet:IsDedicated() or G.TheWorld.ismastersim then return end
    if inst.components.updatelooper == nil then
      inst:AddComponent("updatelooper")
    end
    inst.components.updatelooper:AddOnUpdateFn(OnUpdatePlacerHelper_2)
end)