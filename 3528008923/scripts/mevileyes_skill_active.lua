local cost1 = TUNING.MEVILEYES.SKILLCOST_1
local cost2 = TUNING.MEVILEYES.SKILLCOST_2
local cost3 = TUNING.MEVILEYES.SKILLCOST_3

local function skillcurse(inst, cursedmg, cursetime, ko)

    if inst.components.timer:TimerExists("mevileyes_evilcurse")
        and inst.components.health ~= nil
        and not inst.components.health:IsDead() then

        local health = inst.components.health
        local current = health.currenthealth
        local amount = cursedmg

        if current + amount <= 0 then
            amount = -(current - 1)  
        end

        if amount ~= 0 then
            health:DoDelta(amount)
        end

        --inst.components.timer:StopTimer("mevileyes_evilcurse")
	else
		inst.components.timer:StartTimer("mevileyes_evilcurse", cursetime)
    end
end

local function mactiveskill(inst) -- skill triger
  if inst.prefab == "mevileyes"  then 
	if GLOBAL.TheWorld.ismastersim then
		local old_start = inst.components.combat.StartAttack
		inst.components.combat.StartAttack = function(self)
			old_start(self)
			if self.target then
				local target = self.target
				local weapon = self:GetWeapon()
				local skilltime = .02				
				inst.skill_target = target 
		if weapon ~= nil and weapon.components.weapon then
		
		if (inst.skill1 or inst.skill2 or inst.skill3 or inst.skill4 or inst.skill5 or inst.skill6 or inst.skill7) and not inst.stronggrip then inst:AddTag("stronggrip") end
--start--skill1 Ichimonji		
			if inst.skill1 then
				if weapon.katanamode == 1 and weapon.components.spellcaster ~= nil then weapon.components.spellcaster:CastSpell(inst) end
				inst:DoTaskInTime(skilltime, function()inst.sg:GoToState("mevileyes_ichimonji",inst.skill_target)end)				
				inst.skill1 = nil
				inst.components.timer:StartTimer("mevileyes_cdskill1",TUNING.MEVILEYES.SKILLCD_1) --45
				 if inst.mindpower then inst.mindpower = (inst.mindpower - cost1) end
				skillcurse(inst, TUNING.MEVILEYES.SKILLCURSE_T1, TUNING.MEVILEYES.SKILLCURSE_TIME_T1, 1)
				return
			end	
			
----end--skill1 Ichimonji

--start--skill2 mikiri
						
			if inst.skill2 then					
				if weapon.katanamode == 1 and weapon.components.spellcaster ~= nil then weapon.components.spellcaster:CastSpell(inst) end
					inst:DoTaskInTime(skilltime, function() inst.sg:GoToState("mevileyes_thrust",inst.skill_target) end)
					inst.skill2 = nil
					inst.components.timer:StartTimer("mevileyes_cdskill2",TUNING.MEVILEYES.SKILLCD_2) --60
					 if inst.mindpower then inst.mindpower = (inst.mindpower - cost2) end
					skillcurse(inst, TUNING.MEVILEYES.SKILLCURSE_T1, TUNING.MEVILEYES.SKILLCURSE_TIME_T1, 1)
				return
			end
			
----end--skill2 mikiri

--start--skill3 Ashina cross
				
			if inst.skill3 then
				if weapon.katanamode == 1 and weapon.components.spellcaster ~= nil then weapon.components.spellcaster:CastSpell(inst) end						
					inst:DoTaskInTime(skilltime, function()inst.sg:GoToState("mevileyes_iaicross",inst.skill_target) end)	
					inst.skill3 = nil
					inst.components.timer:StartTimer("mevileyes_cdskill3",TUNING.MEVILEYES.SKILLCD_3) --90
					if inst.mindpower then inst.mindpower = (inst.mindpower - cost3) end
					skillcurse(inst, TUNING.MEVILEYES.SKILLCURSE_T1, TUNING.MEVILEYES.SKILLCURSE_TIME_T1, 1)
				return
			end
			
----end--skill3 Ashina cross

----start--skill4 isshin				
			if inst.skill4 then
				if weapon.katanamode == 1 and weapon.components.spellcaster ~= nil then weapon.components.spellcaster:CastSpell(inst) end					
					inst:DoTaskInTime(skilltime, function() inst.sg:GoToState("mevileyes_onemind",inst.skill_target) end)
					inst.skill4 = nil
					inst.components.timer:StartTimer("mevileyes_cdskill4",TUNING.MEVILEYES.SKILLCD_4) --120
					 if inst.mindpower then inst.mindpower = (inst.mindpower - (cost1+cost2)) end
					skillcurse(inst, TUNING.MEVILEYES.SKILLCURSE_T2, TUNING.MEVILEYES.SKILLCURSE_TIME_T2, 2)					
				return
			end 
--end--skill4 isshin

----start--skill5 Shindenippsen			
			if inst.skill5 then --start										
				if weapon.katanamode == 1 and weapon.components.spellcaster ~= nil then weapon.components.spellcaster:CastSpell(inst) end
					inst:DoTaskInTime(skilltime, function() inst.sg:GoToState("mevileyes_habakiri",inst.skill_target) end)					
					inst.skill5 = nil
					inst.components.timer:StartTimer("mevileyes_cdskill5",TUNING.MEVILEYES.SKILLCD_5)--160
					 if inst.mindpower then inst.mindpower = (inst.mindpower - (cost1+cost3)) end
					skillcurse(inst, TUNING.MEVILEYES.SKILLCURSE_T2, TUNING.MEVILEYES.SKILLCURSE_TIME_T2, 2)					
				return
			end
----end--skill5 Shindenippsen
----start--skill6 Ryusen	
			if inst.skill6 then --start										
				if weapon.katanamode == 1 and weapon.components.spellcaster ~= nil then weapon.components.spellcaster:CastSpell(inst) end
					inst:DoTaskInTime(skilltime, function() inst.sg:GoToState("mevileyes_ryusen",inst.skill_target) end)					
					inst.skill6 = nil
					inst.components.timer:StartTimer("mevileyes_cdskill6",TUNING.MEVILEYES.SKILLCD_6)--180
					 if inst.mindpower then inst.mindpower = (inst.mindpower - (cost2+cost3)) end
					skillcurse(inst, TUNING.MEVILEYES.SKILLCURSE_T2, TUNING.MEVILEYES.SKILLCURSE_TIME_T2, 2)					
				return
			end
----end--skill6 Ryusen
----start--skill7 susanoo		
			
			if inst.skill7 then --start
				if weapon.katanamode == 1 and weapon.components.spellcaster ~= nil then weapon.components.spellcaster:CastSpell(inst) end
					inst:DoTaskInTime(skilltime, function() inst.sg:GoToState("mevileyes_eienwing",inst.skill_target) end)					
					inst.skill7 = nil
					inst.components.timer:StartTimer("mevileyes_cdskill7",TUNING.MEVILEYES.SKILLCD_7)--480
					 if inst.mindpower then inst.mindpower = (inst.mindpower - (cost1+cost2+cost3)) end
					skillcurse(inst, TUNING.MEVILEYES.SKILLCURSE_T3, TUNING.MEVILEYES.SKILLCURSE_TIME_T3, 3)					
				return
			end 
----end--skill7 susanoo
		end--end weapon check
		end
		end
	end
  end
end
AddPlayerPostInit(mactiveskill)

AddStategraphPostInit("wilson", function(sg)

    local old = sg.events.knockback

    sg.events.knockback = GLOBAL.EventHandler("knockback", function(inst, data)

        if inst.sg and inst.sg:HasStateTag("m_noknockback") then           
            return
        end

        if old and old.fn then
            return old.fn(inst, data)
        end
    end)

end)