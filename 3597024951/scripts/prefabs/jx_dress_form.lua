local ret = {}

local prefabs =
{
  "collapse_small",
}

local function onopen(inst)
    if not inst:HasTag("burnt") then
        if inst.swap then
          inst.AnimState:PlayAnimation("hit_swap")
          inst.AnimState:PushAnimation("idle_swap")
        else
          inst.AnimState:PlayAnimation("hit_empty")
          inst.AnimState:PushAnimation("idle_empty")
        end
        inst.SoundEmitter:PlaySound("dontstarve/wilson/backpack_open")
    end
end

local function onclose(inst)
    if not inst:HasTag("burnt") then
        if inst.swap then
          inst.AnimState:PlayAnimation("hit_swap")
          inst.AnimState:PushAnimation("idle_swap")
        else
          inst.AnimState:PlayAnimation("hit_empty")
          inst.AnimState:PushAnimation("idle_empty")
        end
        --inst.SoundEmitter:PlaySound("dontstarve/wilson/backpack_close")
        inst.SoundEmitter:PlaySound("dontstarve/wilson/backpack_open", nil, .8)
    end
end

local function onhammered(inst)--, worker)
    inst.components.lootdropper:DropLoot()
    local fx = SpawnPrefab("collapse_small")
    fx.Transform:SetPosition(inst.Transform:GetWorldPosition())
    fx:SetMaterial("wood")
    inst:Remove()
end

local function onhit(inst, worker)
    if not inst:HasTag("burnt") then
      if inst.components.container ~= nil then
        inst.components.container:DropEverything()
        inst.components.container:Close()
      end
      if inst.swap then
        inst.AnimState:PlayAnimation("hit_swap")
        inst.AnimState:PushAnimation("idle_swap")
      else
        inst.AnimState:PlayAnimation("hit_empty")
        inst.AnimState:PushAnimation("idle_empty")
      end
    end
end

local function onburnt(inst)
    if inst.components.container ~= nil then
      inst.components.container:DropEverything()
	  end
   	DefaultBurntStructureFn(inst)
end

local function onitemchange(inst)--, data)
    if inst.components.container then
      if inst.components.container:IsEmpty() then
        if inst.swap then
          inst.AnimState:PlayAnimation("hit_swap")
          inst.AnimState:PushAnimation("idle_empty")
          inst.swap = false
        end
      else
        if not inst.swap then
          inst.AnimState:PlayAnimation("swap")
          inst.AnimState:PushAnimation("idle_swap")
          inst.swap = true
        end
      end
    end
end

local function onbuilt(inst)
  inst.AnimState:PlayAnimation("place")
  inst.AnimState:PushAnimation("idle_empty")
end

local function onsave(inst, data)
    if inst.components.burnable ~= nil and inst.components.burnable:IsBurning() or inst:HasTag("burnt") then
        data.burnt = true
    end
end

local function onload(inst, data)
    if data ~= nil and data.burnt and inst.components.burnable ~= nil then
        inst.components.burnable.onburnt(inst)
    end
end

local function MakeDressForm(name)
    local assets =
    {
      Asset("ANIM", "anim/jx_dress_form_bank.zip"),
      Asset("ANIM", "anim/ui_chest_1x1.zip"),
      Asset("ANIM", "anim/ui_chest_3x3.zip"),
      Asset("ANIM", "anim/"..name..".zip"),
    }
    
    local function fn()
      local inst = CreateEntity()
      
      inst.entity:AddTransform()
      inst.entity:AddAnimState()
      inst.entity:AddSoundEmitter()
      inst.entity:AddNetwork()
      
      MakeObstaclePhysics(inst, .3)
      
      inst:SetDeploySmartRadius(0.5)
      
      inst:AddTag("structure")
      inst:AddTag("jx_dress_form")
      
      inst.AnimState:SetBank("jx_dress_form")
      inst.AnimState:SetBuild(name)
      inst.AnimState:PlayAnimation("idle_empty")
      
      inst.entity:SetPristine()
      
      if not TheWorld.ismastersim then
          return inst
      end
      
      inst:AddComponent("inspectable")
      
      inst:AddComponent("container")
      inst.components.container:WidgetSetup(name)
      inst.components.container.onopenfn = onopen
      inst.components.container.onclosefn = onclose
      inst.components.container.skipclosesnd = true
      inst.components.container.skipopensnd = true
      
      inst:AddComponent("lootdropper")
      inst:AddComponent("workable")
      inst.components.workable:SetWorkAction(ACTIONS.HAMMER)
      inst.components.workable:SetWorkLeft(4)
      inst.components.workable:SetOnFinishCallback(onhammered)
      inst.components.workable:SetOnWorkCallback(onhit)
      
      MakeMediumBurnable(inst, nil, nil, true)
      inst.components.burnable:SetOnBurntFn(onburnt)
      MakeMediumPropagator(inst)
      
      inst.OnSave = onsave
      inst.OnLoad = onload
      
      inst.swap = false
      
      inst:ListenForEvent("itemget", onitemchange)
      inst:ListenForEvent("itemlose", onitemchange)
      
      inst:ListenForEvent("onbuilt", onbuilt)
      
      return inst
    end
    table.insert(ret, Prefab(name, fn, assets, prefabs))
    table.insert(ret, MakePlacer(name.."_placer", "jx_dress_form", name, "placer"))
end

MakeDressForm("jx_dress_form_m")--黑金燕尾服人台
MakeDressForm("jx_dress_form_w")--哥特洛丽塔人台

return unpack(ret)