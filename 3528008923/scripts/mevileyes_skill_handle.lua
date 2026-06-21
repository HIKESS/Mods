local function CanUseSkill(inst, weapon)
	if inst.components.health ~= nil and inst.components.health:IsDead() and (inst.sg:HasStateTag("dead") or inst:HasTag("playerghost")) 
		or (inst.components.sleeper and inst.components.sleeper:IsAsleep()) 
		or (inst.components.freezable and inst.components.freezable:IsFrozen()) 
		or (inst.components.rider:IsRiding() or inst.components.inventory:IsHeavyLifting()) then return false 
	end	
		if not(weapon:HasTag("projectile") or weapon:HasTag("whip") or weapon:HasTag("rangedweapon"))then return true end
end 

local function disableallskill(inst)
	inst.skill1,inst.skill2,inst.skill3,inst.skill4,inst.skill5,inst.skill6,inst.skill7 = nil
	inst.components.combat:SetRange(inst.oldrange)
end

local cost1 = TUNING.MEVILEYES.SKILLCOST_1
local cost2 = TUNING.MEVILEYES.SKILLCOST_2
local cost3 = TUNING.MEVILEYES.SKILLCOST_3
local costsp = TUNING.MEVILEYES.SKILLCOST_SP

local function Skillcombine(inst)
if not inst.unlockcombineskill_1 then return end
if inst.mindpower >= (cost1+cost2)then
	if inst.skill1 and inst.skill2 and not inst.components.timer:TimerExists("mevileyes_cdskill4")then disableallskill(inst) inst.skill4=true inst.components.combat:SetRange(3, 8) inst._whisper:DoWord(TUNING.MEVILEYESSKILLSPEECH.SKILL4START)return true end
end	
if inst.mindpower >= (cost1+cost3)then
	if inst.skill2 and inst.skill3 and not inst.components.timer:TimerExists("mevileyes_cdskill5")then disableallskill(inst) inst.skill5=true inst.components.combat:SetRange(15, 20) inst._whisper:DoWord(TUNING.MEVILEYESSKILLSPEECH.SKILL5START)return true end
end
if inst.mindpower >= (cost2+cost3)then	
	if inst.skill3 and inst.skill1 and not inst.components.timer:TimerExists("mevileyes_cdskill6")then disableallskill(inst) inst.skill6=true inst.components.combat:SetRange(5, 8) inst._whisper:DoWord(TUNING.MEVILEYESSKILLSPEECH.SKILL6START)return true end
end

if not inst.unlockcombineskill_2 then return end
if inst.mindpower >= (cost1+cost2+cost3)then	
	if ((inst.skill4 and inst.skill3)or(inst.skill5 and inst.skill1)or(inst.skill6 and inst.skill2)) and not inst.components.timer:TimerExists("mevileyes_cdskill7")then 
		disableallskill(inst) inst.skill7=true inst._whisper:DoWord(TUNING.MEVILEYESSKILLSPEECH.SKILL7START) return true -- inst.components.talker:Say(TUNING.MEVILEYESSKILLSPEECH.SKILL7START, 2, true) 
	end
end

	disableallskill(inst) inst._whisper:DoWord("...")
end

local function mevileyes_SheathFn(inst)
local equip = inst.components.inventory:GetEquippedItem(EQUIPSLOTS.HANDS) 
	if equip and CanUseSkill(inst, equip) and equip.components.weapon ~= nil and not inst.components.timer:TimerExists("mevileyes_qscd") then
				
		if equip.katanamode == 2 then				
			inst.sg:GoToState("mevileyes_sheath")
			inst.components.timer:StartTimer("mevileyes_qscd",.2)
			return
		end
		
		if not inst.components.timer:TimerExists("mevileyes_cdskill_sp") then
			if inst.mindpower >= costsp then				
				inst.components.timer:StartTimer("mevileyes_cdskill_sp", TUNING.MEVILEYES.SKILLSPCD)
				inst.mindpower = (inst.mindpower - costsp)
				
				if equip.katanamode == 1 then
					inst.sg:GoToState("mevileyes_slice")				
					return
				else
					inst.sg:GoToState("mevileyes_smash")				
					return
				end
				
			else 
				inst._whisper:DoWord("I need more focus.")--inst.components.talker:Say("I need more focus.", 2, true)
			end
		end
	end
end

local function Skill1Fn(inst)
if not inst.unlockskill_1 then inst._whisper:DoWord("I need to train harder.") return end -- inst.components.talker:Say("I need to train harder.", 2, true) 
local equip = inst.components.inventory:GetEquippedItem(EQUIPSLOTS.HANDS) 
	if equip and CanUseSkill(inst, equip) and not inst.components.timer:TimerExists("mevileyes_bcdskill1")then inst.components.timer:StartTimer("mevileyes_bcdskill1",.4)
		
		if inst.skill2 or inst.skill3 or inst.skill4 or inst.skill5 or inst.skill6 or inst.skill7 then inst.skill1 = true if Skillcombine(inst) then return end end 
if inst.mindpower >= cost1 then		
		if not inst.components.timer:TimerExists("mevileyes_cdskill1") then 
			if not inst.skill1 then			
				disableallskill(inst) inst.skill1 = true 
				inst._whisper:DoWord(TUNING.MEVILEYESSKILLSPEECH.SKILL1START) inst.components.combat:SetRange(3,8)
				else disableallskill(inst) inst._whisper:DoWord("...")
			end		
		end 
		else inst._whisper:DoWord("I need more focus.") --inst.components.talker:Say("I need more focus.", 2, true)
end	
	end

end

local function Skill2Fn(inst)
if not inst.unlockskill_2 then inst._whisper:DoWord("I need to train my focus further.") return end -- inst.components.talker:Say("I need to train my focus further.", 2, true) 
local equip = inst.components.inventory:GetEquippedItem(EQUIPSLOTS.HANDS) 
	if equip and CanUseSkill(inst, equip) and not inst.components.timer:TimerExists("mevileyes_bcdskill2")then inst.components.timer:StartTimer("mevileyes_bcdskill2",.4)
		
		if inst.skill1 or inst.skill3 or inst.skill4 or inst.skill5 or inst.skill6 or inst.skill7 then inst.skill2 = true if Skillcombine(inst) then return end end
if inst.mindpower >= cost2 then			
		if not inst.components.timer:TimerExists("mevileyes_cdskill2") then 
			if not inst.skill2 then
				disableallskill(inst) inst.skill2 = true 
				inst._whisper:DoWord(TUNING.MEVILEYESSKILLSPEECH.SKILL2START) inst.components.combat:SetRange(2.5,7.5)
				else disableallskill(inst) inst._whisper:DoWord("...")
			end		
		end
		else inst._whisper:DoWord("I need more focus.")--inst.components.talker:Say("I need more focus.", 2, true) 
end		
	end

end

local function Skill3Fn(inst)
if not inst.unlockskill_3 then inst._whisper:DoWord("I must sharpen my concentration.") return end -- inst.components.talker:Say("I must sharpen my concentration.", 2, true) 
local equip = inst.components.inventory:GetEquippedItem(EQUIPSLOTS.HANDS) 
	if equip and CanUseSkill(inst, equip) and not inst.components.timer:TimerExists("mevileyes_bcdskill3")then inst.components.timer:StartTimer("mevileyes_bcdskill3",.4)
		
		if inst.skill1 or inst.skill2 or inst.skill4 or inst.skill5 or inst.skill6 or inst.skill7 then inst.skill3 = true if Skillcombine(inst) then return end end
if inst.mindpower >= cost3 then			
		if not inst.components.timer:TimerExists("mevileyes_cdskill3") then 
			if not inst.skill3 then
				disableallskill(inst) inst.skill3 = true 
				inst._whisper:DoWord(TUNING.MEVILEYESSKILLSPEECH.SKILL3START) inst.components.combat:SetRange(2,7)
				else disableallskill(inst)inst._whisper:DoWord("...")
			end		
		end
		else inst._whisper:DoWord("I need more focus.")--inst.components.talker:Say("I need more focus.", 2, true)
end		
	end

end

local function Black_elecfx(inst)
	if not inst.components.rider:IsRiding() then
		local fx = SpawnPrefab("black_electricchargedfx")
				fx.entity:AddFollower():FollowSymbol(inst.GUID, "swap_body", 0, 0, 0)
	end	
	if inst.evilwavebufffx then inst.evilwavebufffx:Cancel() end
	inst.evilwavebufffx = nil
	inst.evilwavebufffx = inst:DoTaskInTime(1, function()  Black_elecfx(inst) end)	
end

local function EndSpeedMult(target)
	target._evilwave_task = nil
	if target._evilwave_fx then	target._evilwave_fx:KillFX() end
	target._evilwave_fx = nil
	if target.components.locomotor ~= nil then
		target.components.locomotor:RemoveExternalSpeedMultiplier(target, "evilwave_debuff")
	end
end

local function SpawnShadowGlobRings(inst, rings, perRing, spacing)
    local x, y, z = inst.Transform:GetWorldPosition()
    rings = rings or 3          -- จำนวนวง
    perRing = perRing or 12     -- จำนวน fx ต่อวง
    spacing = spacing or 5      -- ระยะห่างระหว่างวง (รัศมีเพิ่มขึ้นทีละเท่าไร)

    for r = 1, rings do
        local radius = r * spacing
        for i = 1, perRing do
            local angle = (2 * PI / perRing) * i
            local fx = SpawnPrefab("shadow_glob_fx")
            fx.Transform:SetPosition(
                x + math.cos(angle) * radius,
                0,
                z + math.sin(angle) * radius
            )
        end
    end
end

--local NO_TAGS_PVP = { "INLIMBO", "playerghost", "FX", "NOCLICK", "DECOR", "notarget", "companion", "decoy", "structure", "wall", "chester", "hutch", "shadowminion", "shadow_aligned" }
local NO_TAGS_PVP = {"playerghost", "FX", "NOCLICK", "DECOR", "notarget", "decoy", "structure", "wall", "chester", "hutch" }
local NO_TAGS = shallowcopy(NO_TAGS_PVP)
table.insert(NO_TAGS, "player")

local function Evilwave(inst) --R

if inst:HasTag("playerghost") then return end
if not inst.components.timer:TimerExists("mevileyes_evilwave") then
   
        inst.components.locomotor:Stop()
        --inst.components.health:SetInvincible(true)
        --if inst.components.playercontroller ~= nil then	inst.components.playercontroller:Enable(false)	end	
        
		inst.components.sanity:DoDelta(-25) --sanity cost
		
        inst.SoundEmitter:PlaySound("dontstarve/creatures/worm/distant")
		inst.SoundEmitter:PlaySound("meta5/abigail/jumpscare")
       
		SpawnPrefab("groundpoundring_fx").Transform:SetPosition(inst:GetPosition():Get())
		inst:ShakeCamera(CAMERASHAKE.FULL, .7, .02, .3, inst, 40)
		
		local shockwavefx = SpawnPrefab("mevileyes_shockwave_fx")
				shockwavefx.entity:SetParent(inst.entity)		
				shockwavefx.AnimState:SetScale(5, 5)
		
		local pulsefx = SpawnPrefab("mevileyes_black_pulse")
				pulsefx.entity:SetParent(inst.entity)
				
		local breakfx = SpawnPrefab("mevileyes_black_break")
				breakfx.entity:SetParent(inst.entity)
				
		if inst.unlockdeathaura and inst._evilspeed_task then	
			SpawnShadowGlobRings(inst, 3, 16, 4)  
		end
		
		local excludetags = TheNet:GetPVPEnabled() and NO_TAGS_PVP or NO_TAGS   
        local x,y,z = inst.Transform:GetWorldPosition()
        local ents = TheSim:FindEntities(x, y, z, 20, nil, excludetags) 
		
		for i,v in pairs(ents) do
			if v and v:IsValid()  and v.prefab ~= "mevileyes"  then
			
				if v:HasTag("bird") and v.sg then v.sg:GoToState("stunned") end
				
				if inst.unlockdeathaura and inst._evilspeed_task and not v:HasTag("companion") then
					if v.components.health and v.components.combat then
						if math.random() <= 0.2 and not v:HasTag("epic") then v.components.combat:GetAttacked(inst, 9999999)	
							else v.components.combat:GetAttacked(inst, math.random(50,100))
						end
					end            
				end
				
				if math.random() <= inst.kenjutsulevel/10 then 
					if v.components.hauntable ~= nil and v.components.hauntable.panicable then
						v.components.hauntable:Panic(TUNING.SHADOW_TRAP_PANIC_TIME)
						if v.components.locomotor ~= nil then
							if v._evilwave_task ~= nil then
								v._evilwave_task:Cancel()
							else
								v._evilwave_fx = SpawnPrefab("shadow_trap_debuff_fx")
								v._evilwave_fx.entity:SetParent(v.entity)
								v._evilwave_fx:OnSetTarget(v)
							end
							SpawnPrefab("shadow_despawn").entity:SetParent(v.entity)
							v._evilwave_task = v:DoTaskInTime(TUNING.SHADOW_TRAP_PANIC_TIME, EndSpeedMult)
							v.components.locomotor:SetExternalSpeedMultiplier(v, "evilwave_debuff", TUNING.SHADOW_TRAP_SPEED_MULT)						
						end
					end
				end
				
				local mount = v.components.rider ~= nil and v.components.rider:GetMount() or nil
				if mount ~= nil then
					mount:PushEvent("ridersleep", { sleepiness = 10, sleeptime = 60 })
				end
				
				if math.random() <= inst.kenjutsulevel/10 then 
					if v.components.sleeper ~= nil then
							v.components.sleeper:AddSleepiness(10, 60)
							if v.components.sleeper:IsAsleep() then
								if v.components.combat then
									v:AddDebuff("wortox_forget_debuff", "wortox_forget_debuff", {toforget = inst})
								end
							end
						elseif v.components.grogginess ~= nil then
							v.components.grogginess:AddGrogginess(10, 12)
						else  
							v:PushEvent("knockedout")
					end
				end
			end
        end
	
	if inst.unlockdeathaura and inst._evilspeed_task then		
        
		inst.components.raindome:Enable() --dome
		inst:DoTaskInTime(.8, function() inst.components.raindome:Disable()  end)
		
		inst:DoTaskInTime(.6, function()	--seccondwave	
			--inst.components.health:SetInvincible(false)
            --if inst.components.playercontroller ~= nil then inst.components.playercontroller:Enable(true) end 
			inst.SoundEmitter:PlaySound("dontstarve/creatures/worm/distant")
			inst.SoundEmitter:PlaySound("meta5/abigail/jumpscare")
			inst.SoundEmitter:PlaySound("maxwell_rework/shadow_trap/explode")
			SpawnPrefab("groundpoundring_fx").Transform:SetPosition(inst:GetPosition():Get())
			
			local shockwavefx2 = SpawnPrefab("mevileyes_shockwave_fx")
				shockwavefx2.AnimState:SetScale(5, 5)
				shockwavefx2.entity:SetParent(inst.entity)
			
			local pulsefx2 = SpawnPrefab("mevileyes_black_pulse")
				pulsefx2.entity:SetParent(inst.entity)
				pulsefx2.AnimState:SetScale(2, 2)
        end)
		
		inst.components.timer:StartTimer("mevileyes_atk_buff", 60)--60		
		inst.components.timer:StartTimer("mevileyes_evilwave", TUNING.MEVILEYES.SKILLCD_WAVE *1.5)
	else
		inst.components.timer:StartTimer("mevileyes_atk_buff", 30)
		inst.components.timer:StartTimer("mevileyes_evilwave", TUNING.MEVILEYES.SKILLCD_WAVE)
	end
	
	inst.evilwavebufffx = inst:DoTaskInTime(1, function()  Black_elecfx(inst) end)
end
end
	
AddModRPCHandler("mevileyes", "mevileyes_sheath", mevileyes_SheathFn) --Z
AddModRPCHandler("mevileyes", "mevileyes_skill1", Skill1Fn) --X
AddModRPCHandler("mevileyes", "mevileyes_skill2", Skill2Fn) --C
AddModRPCHandler("mevileyes", "mevileyes_skill3", Skill3Fn) --V
AddModRPCHandler("mevileyes", "mevileyes_evilwave", Evilwave) --R