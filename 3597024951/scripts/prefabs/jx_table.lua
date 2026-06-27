local function onopen(inst)
  inst.AnimState:PlayAnimation("open")
end

local function onclose(inst)
  inst.AnimState:PlayAnimation("close")
end

local function AbleToAcceptDecor(inst, item, giver)
    return (item ~= nil)
end

local function OnDecorGiven(inst, item, giver)
    if not item then return end

    inst.SoundEmitter:PlaySound("wintersfeast2019/winters_feast/table/food")

    if item.Physics then item.Physics:SetActive(false) end
    if item.Follower then item.Follower:FollowSymbol(inst.GUID, "swap_object") end
end

local function OnDecorTaken(inst, item)
    if item then
        if item.Physics then item.Physics:SetActive(true) end
        if item.Follower then item.Follower:StopFollowing() end
    end
end

--
local function TossDecorItem(inst)
    local item = inst.components.furnituredecortaker and inst.components.furnituredecortaker:TakeItem()
    if item then
        inst.components.lootdropper:FlingItem(item)
    end
end

local function OnHammer(inst, worker, workleft, workcount)
    inst.AnimState:PlayAnimation("hit")
    if inst.components.fueled then
      inst.AnimState:PushAnimation("idle", true)
    else
      inst.AnimState:PushAnimation("idle", false)
    end
end

local function OnHammered(inst, worker)
    local collapse_fx = SpawnPrefab("collapse_small")
    collapse_fx.Transform:SetPosition(inst.Transform:GetWorldPosition())
    collapse_fx:SetMaterial(inst._burnable and "wood" or "stone")

    inst.components.lootdropper:DropLoot()

    TossDecorItem(inst)

    inst:Remove()
end

--
local function OnBuilt(inst)
    inst.AnimState:PlayAnimation("place")
    if inst.components.fueled then
      inst.AnimState:PushAnimation("idle", true)
      inst.SoundEmitter:PlaySound("dontstarve/common/fireAddFuel")
    else 
      inst.AnimState:PushAnimation("idle", false)
      if not inst.nobuiltsound then
        inst.SoundEmitter:PlaySound("dontstarve/common/repair_stonefurniture")
      end
    end
end

--
local function on_ignite(inst, source, doer)
    inst._controlled_burn = doer and doer:HasTag("controlled_burner") or source and source:HasTag("controlled_burner") or nil
    DefaultBurnFn(inst)
end

local function on_extinguish(inst)
    inst._controlled_burn = nil
    DefaultExtinguishFn(inst)
end

local function OnBurnt(inst)
    DefaultBurntStructureFn(inst)
    
    local item = inst.components.furnituredecortaker and inst.components.furnituredecortaker:TakeItem()
    if item then
        inst.components.lootdropper:FlingItem(item)
        if not inst._controlled_burn and item.components.burnable ~= nil then
            item.components.burnable:Ignite()
        end
    end
    if inst.components.furnituredecortaker then
      inst.components.furnituredecortaker:SetEnabled(false)
    end
    if inst.components.timer then
      inst.components.timer:StopTimer("complain_time")
    end
    if inst.burnt_build then
      inst.AnimState:SetBuild(inst.prefab.."_burnt_build")
      inst.AnimState:PlayAnimation("idle")
    end
end

local function onnear(inst, target)
  if inst:HasTag("burnt") or (inst.components.timer and inst.components.timer:TimerExists("complain_time")) then
    return
  end
  if target ~= nil then
    if target.components.health and not target.components.health:IsDead() and target.components.talker ~= nil then
      target.components.talker:Say(STRINGS.JX_TABLE_5_QUESTION)
      if inst.components.timer then
        inst.components.timer:StartTimer("complain_time", inst.talk_Period or 480)
      end
      inst:DoTaskInTime(1.5,function()
        if inst.components.talker then
          inst.components.talker:Say(STRINGS.JX_TABLE_5_ANSWER)
        end
      end)
    end
	end
end

local function UpdateFireFx(inst, show)
  if show then
    inst.AnimState:ShowSymbol("spark")
    inst.AnimState:ShowSymbol("flames_wide")
  else
    inst.AnimState:HideSymbol("spark")
    inst.AnimState:HideSymbol("flames_wide")
  end
end

local function UpdateLight(inst, show)
  inst.Light:Enable(show)
end

local function onupdatefueled(inst)
  if inst.components.fueled and inst.components.fueled.currentfuel <= 5 then
    if inst.show_fire_fx then
      inst.show_fire_fx = false
      
      inst:UpdateFireFx(false)
      inst:UpdateLight(false)
      
      inst.SoundEmitter:KillSound("fire_loop")
      
      if inst.components.heater then
        inst.components.heater.heat = 0
      end
      if inst:HasTag("cooker") then
        inst:RemoveTag("cooker")
      end
      if inst:HasTag("snowstorm_protection_high") then
        inst:RemoveTag("snowstorm_protection_high")
      end
    end
  else
    if inst.show_fire_fx == false then
      inst.show_fire_fx = true
      
      inst:UpdateFireFx(true)
      inst:UpdateLight(true)
      
      inst.SoundEmitter:PlaySound("dontstarve/common/campfire", "fire_loop", .7)
      
      if inst.components.fueled then
        inst.components.fueled:StartConsuming()
      end
      if inst.components.heater then
        inst.components.heater.heat = 75
      end
      if not inst:HasTag("cooker") then
        inst:AddTag("cooker")
      end
      if not inst:HasTag("snowstorm_protection_high") then
        inst:AddTag("snowstorm_protection_high")
      end
    end
  end
end

local function ontakefuel(inst)
  inst.SoundEmitter:PlaySound("dontstarve/common/fireAddFuel")
  inst.components.fueled.updatefn(inst)
  inst.components.fueled:StartConsuming()
end

local function ontimerdone(inst, data)
  if data then
    if data.name == "cd" then
      if inst:HasTag("jx_refresh_target_in_cd") then
        inst:RemoveTag("jx_refresh_target_in_cd")
      end
    end
  end
end

--
local function OnSave(inst, data)
    if (inst.components.burnable and inst.components.burnable:IsBurning()) or inst:HasTag("burnt") then
        data.burnt = true
    end
    data.controlled_burn = inst._controlled_burn
    data.show_fire_fx = inst.show_fire_fx
end

local function OnLoad(inst, data)
    if data then
        inst._controlled_burn = data.controlled_burn
        onupdatefueled(inst)
        inst.show_fire_fx = data.show_fire_fx
    end
end

local function OnLoadPostPass(inst, newents, data)
    if data and data.burnt then
        inst:PushEvent("onburnt")
        if inst.components.burnable and inst.components.burnable.onburnt then
          inst.components.burnable.onburnt(inst)
        end
    end
end
--
local function AddTable(results, prefab_name, data)
    local assets =
    {
        Asset("ANIM", "anim/"..data.bank..".zip"),
        Asset("ANIM", "anim/"..data.build..".zip"),
    }
    if data.burnt_build then
      table.insert(assets, Asset("ANIM", "anim/"..prefab_name.."_burnt_build.zip"))
    end

    local prefabs =
    {
        "collapse_small",
    }

    local function fn()
        local inst = CreateEntity()

        inst.entity:AddTransform()
        inst.entity:AddAnimState()
        inst.entity:AddSoundEmitter()
        if data.fueled then
          inst.entity:AddLight()
        end
        inst.entity:AddNetwork()
        
        inst:SetDeploySmartRadius(data.deploy_smart_radius)
        
        if data.physics_radius then
          MakeObstaclePhysics(inst, data.physics_radius)
        else
          MakeObstaclePhysics(inst, 0.6)
        end

        inst.AnimState:SetBank(data.bank)
        inst.AnimState:SetBuild(data.build)
        if data.fueled then
          if inst.Light then
            inst.Light:SetRadius(5)
            inst.Light:SetFalloff(.33)
            inst.Light:SetIntensity(0.8)
            inst.Light:SetColour(255/255, 255/255, 192/255)
            inst.Light:Enable(true)
          end
          inst.AnimState:PlayAnimation("idle", true)
        else
          inst.AnimState:PlayAnimation("idle")
        end
        
        inst.AnimState:SetFinalOffset(-1)

        if data.facings == 0 then
		    	inst.Transform:SetNoFaced()
		    elseif data.facings == 8 then
			    inst.Transform:SetEightFaced()
	    	else
		    	inst.Transform:SetFourFaced()
		    end
    
        if data.decortable then
          inst:AddTag("decortable")
        end
        if data.rotatableobject then
          inst:AddTag("rotatableobject")
        end
        if data.cooker then
          inst:AddTag("cooker")
        end
        if data.snowpileblocker then
          inst:AddTag("snowpileblocker")
        end
        if data.fueled then
          inst:AddTag("canlight")
        end
        if data.refresh then
          inst:AddTag("jx_refresh_target")
        end
        inst:AddTag("structure")

        inst.entity:SetPristine()
        
        if data.talker then
          inst:AddComponent("talker")
          inst.components.talker.fontsize = 35
          inst.components.talker.font = TALKINGFONT
          inst.components.talker.colour = Vector3(143/255, 41/255, 41/255)
          inst.components.talker.offset = Vector3(0, -400, 0)
          inst.components.talker:MakeChatter()
          inst:AddComponent("npc_talker")
          inst.talk_Period = 480
        end

        if not TheWorld.ismastersim then
            return inst
        end

        inst._burnable = data.burnable

        --
        if data.decortable then
          local furnituredecortaker = inst:AddComponent("furnituredecortaker")
          furnituredecortaker.abletoaccepttest = AbleToAcceptDecor
          furnituredecortaker.ondecorgiven = OnDecorGiven
          furnituredecortaker.ondecortaken = OnDecorTaken
        end

        --
        local inspectable = inst:AddComponent("inspectable")
        --
        inst:AddComponent("lootdropper")

        --
        local savedrotation = inst:AddComponent("savedrotation")
        savedrotation.dodelayedpostpassapply = true

        --
        local workable = inst:AddComponent("workable")
        workable:SetWorkAction(ACTIONS.HAMMER)
        workable:SetWorkLeft(5)
        workable:SetOnWorkCallback(OnHammer)
        workable:SetOnFinishCallback(OnHammered)
        
        if data.watersource then
          inst:AddComponent("watersource")
        end
        
        if data.talker then
          if inst.components.timer == nil then
            inst:AddComponent("timer")
          end
          if not inst.components.timer:TimerExists("complain_time") then
            inst.components.timer:StartTimer("complain_time", 4)
          end
        
          inst:AddComponent("playerprox")
          inst.components.playerprox:SetDist(3, 5)
          inst.components.playerprox:SetOnPlayerNear(onnear)
        end

        MakeHauntableWork(inst)
        
        if data.decortable then
          inst:ListenForEvent("ondeconstructstructure", TossDecorItem)
        end
        inst:ListenForEvent("onbuilt", OnBuilt)
        
        ------
        if data.burnable then
            MakeMediumBurnable(inst, nil, nil, true)
            inst.components.burnable:SetOnIgniteFn(on_ignite)
            inst.components.burnable:SetOnExtinguishFn(on_extinguish)
            inst.components.burnable:SetOnBurntFn(OnBurnt)
            MakeMediumPropagator(inst)
            --inst:ListenForEvent("onburnt", OnBurnt)
        end
        if data.burnt_build then
          inst.burnt_build = true
        end
        
        if data.fueled then
          inst:AddComponent("fueled")
          inst.components.fueled:InitializeFuelLevel(TUNING.FIREPIT_FUEL_MAX)
          inst.components.fueled:SetTakeFuelFn(ontakefuel)
          inst.components.fueled.accepting = true
          inst.components.fueled.fueltype = FUELTYPE.BURNABLE
          inst.components.fueled:SetUpdateFn(onupdatefueled)
          inst.components.fueled:StartConsuming()
          
          inst.show_fire_fx = true
          inst.UpdateFireFx = UpdateFireFx
          inst.UpdateLight = UpdateLight
          inst:UpdateFireFx(true)
          inst:UpdateLight(true)
      
          inst.SoundEmitter:PlaySound("dontstarve/common/campfire", "fire_loop", .7)
          
          inst:AddComponent("heater")
          inst.components.heater.heat = 75
          
          inst:ListenForEvent("onlighterlight", function() inst.components.fueled:SetPercent(.5) end)
        end
        
        if data.cooker then
          inst:AddComponent("cooker")
        end
        
        if data.container then
          inst:AddComponent("container")
          inst.components.container:WidgetSetup(prefab_name)
          inst.components.container.onopenfn = onopen
          inst.components.container.onclosefn = onclose
        end
        
        if data.refresh then
          if inst.components.timer == nil then
            inst:AddComponent("timer")
          end
        end
        
        inst.nobuiltsound = data.nobuiltsound
        
        ----
        inst.OnSave = OnSave
        inst.OnLoad = OnLoad
        inst.OnLoadPostPass = OnLoadPostPass
        
        if data.snowpileblocker then
          inst:DoPeriodicTask(5, function(inst)
            local x, y, z = inst.Transform:GetWorldPosition()
            local snow = TheSim:FindEntities(x, y, z, 8, { "snowpile" })
            for _, v in ipairs(snow) do
              if v.components.workable ~= nil then
                v.components.workable:Destroy(inst)
              end
            end
          end, 0)
        end
        
        inst:ListenForEvent("timerdone", ontimerdone)

        return inst
    end

    table.insert(results, Prefab(prefab_name, fn, assets, prefabs))
    table.insert(results, MakePlacer(prefab_name.."_placer", data.bank, data.build, "idle", nil, nil, nil, nil, data.fixedcameraoffset, "four"))
end

local result_tables = {}

AddTable(
    result_tables,
    "jx_table",
    {
        bank = "jx_table",
        build = "jx_table",
		    facings = 0,
        deploy_smart_radius = 0.875,
        burnable = true,
        decortable = true,
        fixedcameraoffset = 105,
    }
)

AddTable(
    result_tables,
    "jx_table_3",
    {
        bank = "jx_table_3",
        build = "jx_table_3",
		    facings = 4,
        deploy_smart_radius = 0.875,
        burnable = true,
        decortable = true,
        fixedcameraoffset = 105,
    }
)

AddTable(
    result_tables,
    "jx_table_4",
    {
        bank = "jx_table_4",
        build = "jx_table_4",
		    facings = 0,
        deploy_smart_radius = 0.875,
        burnable = true,
        decortable = true,
        fixedcameraoffset = 105,
    }
)

AddTable(
    result_tables,
    "jx_table_5",
    {
        bank = "jx_table_5",
        build = "jx_table_5",
		    facings = 4,
        deploy_smart_radius = 0.875,
        burnable = true,
        burnt_build = true,
        fixedcameraoffset = 15,
        rotatableobject = true,
        talker = true,
    }
)

AddTable(
    result_tables,
    "jx_table_7",
    {
        bank = "jx_table_7",
        build = "jx_table_7",
		    facings = 4,
        deploy_smart_radius = 0.5,
        fixedcameraoffset = 15,
        rotatableobject = true,
        watersource = true,
    }
)

AddTable(
    result_tables,
    "jx_table_8",
    {
        bank = "jx_table_8",
        build = "jx_table_8",
		    facings = 8,
        deploy_smart_radius = 1.25,
        fixedcameraoffset = 15,
        rotatableobject = true,
        fueled = true,
        physics_radius = 1.5,
        cooker = true,
        snowpileblocker = true,
    }
)

AddTable(
    result_tables,
    "jx_table_9",
    {
        bank = "jx_table_9",
        build = "jx_table_9",
		    facings = 0,
        deploy_smart_radius = 0.5,
        burnable = true,
        fixedcameraoffset = 105,
        container = true,
        watersource = true,
        nobuiltsound = true,
        refresh = TUNING.JX_TUNING.jx_table_9_wash,
    }
)

return unpack(result_tables)