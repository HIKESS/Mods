local G = GLOBAL

for _, v in ipairs({"pitchfork", "goldenpitchfork"}) do
  AddPrefabPostInit(v, function(inst)
      inst:AddTag("jx_toilet_suction")
      if not G.TheWorld.ismastersim then return end
      
      inst.jx_suction_task_period = 1
      inst.jx_suction_task_radius = 20
      
      if inst.components.equippable then
        local old_onequipfn = inst.components.equippable.onequipfn
        inst.components.equippable.onequipfn = function(inst, owner)
          if old_onequipfn then
            old_onequipfn(inst, owner)
          end
          local period = inst.jx_suction_task_period or 1
          local radius = inst.jx_suction_task_radius or 20
          owner.jx_toilet_suction_task = owner:DoPeriodicTask(period,function()
            local x, y, z = owner.Transform:GetWorldPosition()
            local ents = G.TheSim:FindEntities(x, y, z, radius, {"jx_rug", "NOCLICK"})
            for _, v in pairs(ents) do
              v:RemoveTag("NOCLICK")
              if v.NOCLICK_Tag_Task then
                v.NOCLICK_Tag_Task:Cancel()
                v.NOCLICK_Tag_Task = nil
              end
              local time = v.NOCLICK_Tag_Task_Time or 5
              v.NOCLICK_Tag_Task = v:DoTaskInTime(time,function() v:AddTag("NOCLICK") end)
            end
          end, 0)
        end
        
        local old_onunequipfn = inst.components.equippable.onunequipfn
        inst.components.equippable.onunequipfn = function(inst, owner)
          if old_onunequipfn then
            old_onunequipfn(inst, owner)
          end
          if owner.jx_toilet_suction_task then
            owner.jx_toilet_suction_task:Cancel()
            owner.jx_toilet_suction_task = nil
          end
        end
      end
  end)
end

local jx_rug_dig = AddAction("JX_RUG_DIG", G.STRINGS.ACTIONS.DIG, function(act)
    if act.target and act.target:HasTag("jx_rug") and 
      act.doer and act.doer.components.inventory and
      act.doer.components.inventory:EquipHasTag("jx_toilet_suction")
    then
      act.target.components.workable:WorkedBy(act.doer)
      return true
    end
end)
jx_rug_dig.priority  = 1
jx_rug_dig.distance = 2.5
jx_rug_dig.right = true

for _, v in ipairs({"jx_rug_dig", "terraformer"}) do
  AddComponentAction("EQUIPPED", v, function(inst, doer, target, actions, right)
      if right and not (doer.replica.rider ~= nil and doer.replica.rider:IsRiding()) and target:HasTag("jx_rug") then
        table.insert(actions, jx_rug_dig)
      end
  end)
end

AddStategraphActionHandler("wilson", G.ActionHandler(jx_rug_dig, "dig_start"))
AddStategraphActionHandler("wilson_client", G.ActionHandler(jx_rug_dig, "dig_start"))

---
--部署动作距离扩展
local old_extra_arrive_dist = G.ACTIONS.DEPLOY.extra_arrive_dist
G.ACTIONS.DEPLOY.extra_arrive_dist = function(doer, dest, bufferedaction, ...)
  if dest ~= nil then
    local invobject = bufferedaction and bufferedaction.invobject or nil
		if invobject and invobject:HasTag("jx_rug_item") then
			return 2.5 - G.ACTIONS.DEPLOY.distance
		end
  end
  return old_extra_arrive_dist(doer, dest, bufferedaction, ...)
end