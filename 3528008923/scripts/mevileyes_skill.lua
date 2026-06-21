--fx
--skill effect

local function groundpoundfx1(inst)
if inst and inst:IsValid() then 
	local x, y, z = inst.Transform:GetWorldPosition()	
			local fx = SpawnPrefab("groundpoundring_fx")			
			fx.Transform:SetPosition(x, y, z)
end
end

local function groundpoundfx_t2(inst, pos)
local fx = SpawnPrefab("groundpoundring_fx")
			fx.Transform:SetScale(.8, .8, .8)
			fx.Transform:SetPosition(pos.x, pos.y, pos.z)
end

local function groundpoundfx_black(inst, fxscale)
if inst and inst:IsValid() then 
	local x, y, z = inst.Transform:GetWorldPosition()	
			local fx = SpawnPrefab("mevileyes_shockwave_fx")
			fx.Transform:SetScale(fxscale, fxscale, fxscale)
			fx.Transform:SetPosition(x, y, z)
end
end

local function pulsefx_black(inst, fxscale)
if inst and inst:IsValid() then 
	local x, y, z = inst.Transform:GetWorldPosition()	
			local fx = SpawnPrefab("mevileyes_black_pulse")
			fx.Transform:SetScale(fxscale, fxscale, fxscale)
			fx.Transform:SetPosition(x, y, z)
end
end

------------------------------------------------------------------------------------------------------------------
--local function slashfx1(inst, pos)
--local effects = SpawnPrefab("shadowstrike_slash_fx")																
--						effects.Transform:SetScale(3, 3, 3)
--						effects.Transform:SetPosition(pos.x, pos.y, pos.z)
--						inst.SoundEmitter:PlaySound("turnoftides/common/together/moon_glass/mine")
--						inst.SoundEmitter:PlaySound("dontstarve/creatures/spiderqueen/swipe")
--
--end
--
--local function slashfx2(inst, pos)
--local effects2 = SpawnPrefab("shadowstrike_slash2_fx")																
--						effects2.Transform:SetScale(3, 3, 3)
--						effects2.Transform:SetPosition(pos.x, pos.y, pos.z)
--						inst.SoundEmitter:PlaySound("turnoftides/common/together/moon_glass/mine")
--						inst.SoundEmitter:PlaySound("dontstarve/wilson/attack_weapon")
--
--end

--local function slashfx3(inst, pos)
--local effects = SpawnPrefab("shadowstrike_slash_fx")																
--						effects.Transform:SetScale(1.6, 1.6, 1.6)
--						effects.Transform:SetPosition(pos.x, pos.y, pos.z)
--						inst.SoundEmitter:PlaySound("turnoftides/common/together/moon_glass/mine")
--						inst.SoundEmitter:PlaySound("dontstarve/creatures/spiderqueen/swipe")
--end

local function slashfx4(inst, pos, fxscale)
	local effects = SpawnPrefab("mevileyes_atk_fx1")																
						effects.Transform:SetScale(fxscale, fxscale, fxscale)
						effects.Transform:SetPosition(pos.x, pos.y, pos.z)
end

local function slashfx5(inst, pos, fxscale)
	local effects = SpawnPrefab("mevileyes_atk_fx3")																
						effects.Transform:SetScale(fxscale, fxscale, fxscale)
						effects.Transform:SetPosition(pos.x, pos.y, pos.z)
end


local function slashfx5black(inst, pos, fxscale) 
	local effects = SpawnPrefab("mevileyes_atk_fx3")																
						effects.Transform:SetScale(fxscale, fxscale, fxscale)
						effects.Transform:SetPosition(pos.x, pos.y, pos.z)						
						effects.AnimState:SetMultColour(0, 0, 0, .7)					
end

local function slashfx6black(inst, pos, fxscale) 
	local effects = SpawnPrefab("mevileyes_atk_fx1")																
						effects.Transform:SetScale(fxscale, fxscale, fxscale)
						effects.Transform:SetPosition(pos.x, pos.y, pos.z)						
						effects.AnimState:SetMultColour(0, 0, 0, .8)					

end


------------------------------------------------------------------------------------------------------------------------------
--DMG
local NO_TAGS_PVP = { "INLIMBO", "playerghost", "FX", "NOCLICK", "DECOR", "notarget", "companion", "decoy" }
local NO_TAGS = shallowcopy(NO_TAGS_PVP)
table.insert(NO_TAGS, "player")
--table.insert(NO_TAGS, "wall")

local function maoeattack(inst, pos, mtpdmg, atkrange, destroy)

    local excludetags = TheNet:GetPVPEnabled() and NO_TAGS_PVP or NO_TAGS
   
    local ents = TheSim:FindEntities(pos.x, pos.y, pos.z, atkrange, nil, excludetags)
    local weapon = inst.components.inventory:GetEquippedItem(EQUIPSLOTS.HANDS)

    for _, v in ipairs(ents) do
	 if v and v:IsValid() and v ~= inst then        
        			
		if v.components.health and not v.components.health:IsDead() then
            if weapon and inst and inst.components.combat and v.components.combat then			
				local dmg, spdmg = inst.components.combat:CalcDamage(v, weapon, mtpdmg)				
                v.components.combat:GetAttacked(inst, dmg, weapon, nil, spdmg)				
			end
        end
			
			if destroy then    
				if v.components.workable ~= nil and
					v.components.workable:CanBeWorked() and
					v.components.workable.action ~= ACTIONS.NET
					then
					v.components.workable:Destroy(inst)
				end
			else	
				if ((v:HasTag("tree") and not v:HasTag("stump") and not v:HasTag("monster")) or v:HasTag("boulder")) then
					if  v.components.workable ~= nil then
						v.components.workable:WorkedBy(inst, math.random(8,16))
					end			
				end
			end
			
		--if v:HasTag("bird") and v.sg ~= nil then v.sg:GoToState("stunned") end
	
     end
	end
end

---------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------------------------------------
--Zzzzzzz
local function slicehit(inst, pos)
	groundpoundfx_black(inst, 1)
	inst:DoTaskInTime(.3, function(inst) groundpoundfx_black(inst, 1.2) end)
	inst:ShakeCamera(CAMERASHAKE.FULL, 0.2, 0.02, .5, inst, 20)	
	slashfx5black(inst, pos, 6)	
		
	maoeattack(inst, pos, 1, 6)
end

local function smashhit(inst, pos)	
	groundpoundfx_black(inst, 1)	
	inst:ShakeCamera(CAMERASHAKE.FULL, 0.2, 0.02, .5, inst, 20)	
	slashfx6black(inst, pos, 6)

	maoeattack(inst, pos, 1.5, 6)
end
------------------------------------------------------------------------------------------------------------
--onemind
local function onemindfx1(inst, pos, fxscale)
	local fx = SpawnPrefab("mevileyes_iaislash_fx")		
	fx.Transform:SetPosition(pos.x, pos.y, pos.z)			
	fx.Transform:SetRotation(inst.Transform:GetRotation())
	fx.Transform:SetScale(fxscale, fxscale, fxscale)
	fx.AnimState:SetMultColour(0, 0, 0, .7)
end

local function onemindhit3(inst, pos)
	inst.SoundEmitter:PlaySound("dontstarve/creatures/spiderqueen/swipe")
	onemindfx1(inst, pos, 1.4)
	maoeattack(inst, pos, 1, 4)
end

local function onemindhit4(inst, pos)
	inst:ShakeCamera(CAMERASHAKE.FULL, 0.2, 0.02, .5, inst, 20)
	
	maoeattack(inst, pos, 1, 4)
	inst.SoundEmitter:PlaySound("dontstarve/tentacle/attack_nightsword")
	inst:DoTaskInTime(.1, function(inst) inst.SoundEmitter:PlaySound("dontstarve/wilson/attack_nightsword")  end)
	inst:DoTaskInTime(.3, function(inst) inst.SoundEmitter:PlaySound("dontstarve/creatures/spiderqueen/swipe") end)
end

local function onemindhit5(inst, pos)
	inst.SoundEmitter:PlaySound("dontstarve/wilson/attack_nightsword")	
	
	local effects = SpawnPrefab("mevileyes_atk_fx2")				
					effects.Transform:SetScale(4, 4, 4)
					effects.Transform:SetPosition(pos.x, pos.y, pos.z)
					effects.Transform:SetRotation(inst.Transform:GetRotation())
					inst:ShakeCamera(CAMERASHAKE.FULL, 0.2, 0.02, .5, inst, 20)
	
	local pufffx = SpawnPrefab("maxwell_smoke")
				pufffx.Transform:SetScale(1.2, 1.2, 1.2)
				pufffx.Transform:SetPosition(pos.x, pos.y, pos.z)		

	groundpoundfx_t2(inst, pos)
	
	maoeattack(inst, pos, 2, 2)

end

------------------------------------------------------------------------------------------------------------
--haba
local function habakirifx(inst, pos, fxscale)

local effects = SpawnPrefab("mevileyes_atk_fx2")				
				effects.Transform:SetScale(fxscale, fxscale, fxscale)
				effects.Transform:SetPosition(pos.x, pos.y, pos.z)
								
local pufffx = SpawnPrefab("maxwell_smoke")
				pufffx.Transform:SetScale(1, 1, 1)
				pufffx.Transform:SetPosition(pos.x, pos.y, pos.z)		

groundpoundfx_t2(inst, pos)	
end

local function habakirihit(inst, pos)	
	
	groundpoundfx_t2(inst, pos)	
	inst:ShakeCamera(CAMERASHAKE.FULL, 0.2, 0.02, .5, inst, 20)
	
	slashfx4(inst, pos, 3)
	maoeattack(inst, pos, 1, 3)
end

local function habakirihit2(inst, pos)
	local pufffx = SpawnPrefab("maxwell_smoke")
			pufffx.Transform:SetScale(1.2, 1.2, 1.2)
			pufffx.Transform:SetPosition(pos.x, pos.y, pos.z)
	
	groundpoundfx_t2(inst, pos)			
	inst:ShakeCamera(CAMERASHAKE.FULL, 0.2, 0.02, .5, inst, 20)

	slashfx5(inst, pos, 3)	
	maoeattack(inst, pos, 1, 3)
end
------------------------------------------------------------------------------------------------------------

------------------------------------------------------------------------------------------------------------
--ryusen
local function ryusenhit(inst, pos, dmg)	
	local fx = SpawnPrefab("groundpoundring_fx")
			fx.Transform:SetScale(.8, .8, .8)
			fx.Transform:SetPosition(pos.x, pos.y, pos.z)
	
	local pufffx = SpawnPrefab("maxwell_smoke")
			pufffx.Transform:SetScale(1.2, 1.2, 1.2)
			pufffx.Transform:SetPosition(pos.x, pos.y, pos.z)
			
	local effects = SpawnPrefab("mevileyes_atk_fx2")				
				effects.Transform:SetScale(6, 6, 6)
				effects.Transform:SetPosition(pos.x, pos.y, pos.z)
				
	inst:ShakeCamera(CAMERASHAKE.FULL, 0.2, 0.02, .5, inst, 20)

	maoeattack(inst, pos, dmg, 6) 
end

local function ryusenhit2(inst, pos, dmg)
	local effects = SpawnPrefab("mevileyes_atk_fx2")				
				effects.Transform:SetScale(3, 3, 3)
				effects.Transform:SetPosition(pos.x, pos.y, pos.z)
	
	local fx = SpawnPrefab("groundpoundring_fx")
			fx.Transform:SetScale(.6, .6, .6)
			fx.Transform:SetPosition(pos.x, pos.y, pos.z)
	
	local pufffx = SpawnPrefab("maxwell_smoke")
			pufffx.Transform:SetScale(1, 1, 1)
			pufffx.Transform:SetPosition(pos.x, pos.y, pos.z)
	
	maoeattack(inst, pos, dmg, 4)
			
end
------------------------------------------------------------------------------------------------------------

------------------------------------------------------------------------------------------------------------
--eienwing_
local function eienwing_fx(inst, fxscale)
local effects = SpawnPrefab("mevileyes_skill7_fx")																
						effects.Transform:SetScale(fxscale, fxscale, fxscale)
						effects.entity:AddFollower():FollowSymbol(inst.GUID, "swap_body", 0, 0, 0)
						
end

local function eienwing_hit(inst, pos)
	maoeattack(inst, pos, 3, 12)
end

local function eienwing_ringfx(inst, rings, perRing, spacing)
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

local function eienwing_fx2(inst, pos)

        inst.SoundEmitter:PlaySound("dontstarve/creatures/worm/distant")
		inst.SoundEmitter:PlaySound("meta5/abigail/jumpscare")       
		SpawnPrefab("groundpoundring_fx").Transform:SetPosition(pos.x, pos.y, pos.z)
		
		inst:ShakeCamera(CAMERASHAKE.FULL, .7, .02, .3, inst, 40)
		
		local shockwavefx = SpawnPrefab("mevileyes_shockwave_fx")
				shockwavefx.Transform:SetPosition(pos.x, pos.y, pos.z)
				shockwavefx.AnimState:SetScale(5, 5)
end

local function eienwing_fx3(inst, pos)
			inst.SoundEmitter:PlaySound("dontstarve/creatures/worm/distant")
			inst.SoundEmitter:PlaySound("meta5/abigail/jumpscare")
			inst.SoundEmitter:PlaySound("maxwell_rework/shadow_trap/explode")
			SpawnPrefab("groundpoundring_fx").Transform:SetPosition(pos.x, pos.y, pos.z)
			
			local shockwavefx2 = SpawnPrefab("mevileyes_shockwave_fx")
				shockwavefx2.AnimState:SetScale(5, 5)
				shockwavefx2.Transform:SetPosition(pos.x, pos.y, pos.z)				
end
------------------------------------------------------------------------------------------------------------
--reset range skill
local function rangereset(inst)
	inst.components.combat:SetRange(inst.oldrange)
	inst.components.combat:SetAreaDamage(nil)
	inst.components.combat:EnableAreaDamage(false)
	inst.AnimState:SetDeltaTimeMultiplier(1)
end

---------------------------------------------------------------------------------
local skillword = {
TUNING.MEVILEYESSKILLSPEECH.SKILL1ATTACK,
TUNING.MEVILEYESSKILLSPEECH.SKILL2ATTACK,
TUNING.MEVILEYESSKILLSPEECH.SKILL3ATTACK,
TUNING.MEVILEYESSKILLSPEECH.SKILL4ATTACK,
TUNING.MEVILEYESSKILLSPEECH.SKILL5ATTACK,
TUNING.MEVILEYESSKILLSPEECH.SKILL6ATTACK,
TUNING.MEVILEYESSKILLSPEECH.SKILL7ATTACK,
TUNING.MEVILEYESSKILLSPEECH.SKILL8ATTACK,
TUNING.MEVILEYESSKILLSPEECH.SKILL8ATTACK2,
}

local function skilltalk(inst, num, sec)
	inst._whisper:DoWord(skillword[num], sec)
end
---------------------------------------------------------------------------------
---------------------------------------------------------------------------------
--Skill
local parryanims = {"atk","scythe_loop"}
local function evileyesparry()
    local state =
    GLOBAL.State{
        name = "evileyesparry",
        tags = {"attack", "doing", "busy", "nointerrupt" ,"nopredict","nomorph"}, --
        onenter = function(inst, target)
		
            inst.components.locomotor:Stop()
			
            inst.AnimState:PlayAnimation(parryanims[math.random(#parryanims)])
			inst.SoundEmitter:PlaySound("dontstarve/wilson/attack_weapon")
			
            target = inst.skill_target
            if target ~= nil and target:IsValid() then
                inst.sg.statemem.target = target
                inst:ForceFacePoint(target.Transform:GetWorldPosition())
            end		
			
        end,

        timeline =
        {
			GLOBAL.TimeEvent(3 * FRAMES, function(inst) 				
				--inst:PerformBufferedAction()
				--inst.components.combat:DoAttack(inst.sg.statemem.target)
				inst.SoundEmitter:PlaySound("dontstarve/wilson/hit")
				SpawnPrefab("sparks").Transform:SetPosition(inst:GetPosition():Get())
            end),
   
        },

        ontimeout = function(inst)
            inst.sg:RemoveStateTag("attack")
            inst.sg:AddStateTag("idle")
			
        end,

        events =
        {            
            GLOBAL.EventHandler("animqueueover", function(inst)
                if inst.AnimState:AnimDone() and inst.components.health ~= nil and not inst.components.health:IsDead()
                and not inst.sg:HasStateTag("dead")
                then
                    inst.sg:GoToState("idle")					
                end
            end),
        },

        onexit = function(inst)
			if inst.components.combat then
				inst.components.combat:SetTarget(nil)			
			end
			
        end,
    }
    return state
end
AddStategraphState("wilson",evileyesparry())
--------------------------------------------------------------------------------

local function evileyes_wp_dash()
    local state =
    GLOBAL.State{
        name = "evileyes_wp_dash",
        tags = { "aoe", "doing", "busy", "nopredict", "nomorph" },

        onenter = function(inst, data)
            if data ~= nil and
                data.targetpos ~= nil and
                data.weapon ~= nil and
                data.weapon.components.aoeweapon_lunge ~= nil then
                inst.AnimState:PlayAnimation("lunge_pst")
				inst.AnimState:OverrideSymbol("fx_lunge_streak", "player_lunge_basic", "fx_lunge_streak") 
                inst.SoundEmitter:PlaySound("dontstarve/wilson/attack_weapon")
                local pos = inst:GetPosition()
				local dir
                if pos.x ~= data.targetpos.x or pos.z ~= data.targetpos.z then
					dir = inst:GetAngleToPoint(data.targetpos)
					inst.Transform:SetRotation(dir)
                end
                if data.weapon.components.aoeweapon_lunge:DoLunge(inst, pos, data.targetpos) then
                    inst.SoundEmitter:PlaySound(data.weapon.components.aoeweapon_lunge.sound or "dontstarve/common/lava_arena/fireball")

					--Make sure we don't land directly on world boundary, where
					--physics may end up popping in the wrong direction to void
					local x, z = data.targetpos.x, data.targetpos.z
					if dir then
						local theta = dir * DEGREES
						local cos_theta = math.cos(theta)
						local sin_theta = math.sin(theta)
						local x1, z1
						local _ispassableatpoint, iscustom = GetActionPassableTestFnAt(pos:Get())
						if not _ispassableatpoint(x, 0, z) then
							--scan for nearby land in case we were slightly off
							--adjust position slightly toward valid ground
							if _ispassableatpoint(x + 0.1 * cos_theta, 0, z - 0.1 * sin_theta) then
								x1 = x + 0.5 * cos_theta
								z1 = z - 0.5 * sin_theta
							elseif _ispassableatpoint(x - 0.1 * cos_theta, 0, z + 0.1 * sin_theta) then
								x1 = x - 0.5 * cos_theta
								z1 = z + 0.5 * sin_theta
							elseif iscustom then
								--for non-default (arena, vault, teetering), we need to be more aggressive in placing us back
								x1, z1 = pos.x, pos.z
								local dist = math.sqrt(distsq(pos.x, pos.z, x, z))
								while dist > 0.5 do
									dist = dist - 0.5
									if _ispassableatpoint(pos.x + (dist + 0.1) * cos_theta, 0, pos.z - (dist + 0.1) * sin_theta) then
										x1 = pos.x + dist * cos_theta
										z1 = pos.z - dist * sin_theta
										break
									end
								end
							end
						else
							--scan to make sure we're not just on the edge of land, could result in popping to the wrong side
							--adjust position slightly away from invalid ground
							if not _ispassableatpoint(x + 0.1 * cos_theta, 0, z - 0.1 * sin_theta) then
								x1 = x - 0.4 * cos_theta
								z1 = z + 0.4 * sin_theta
							elseif not _ispassableatpoint(x - 0.1 * cos_theta, 0, z + 0.1 * sin_theta) then
								x1 = x + 0.4 * cos_theta
								z1 = z - 0.4 * sin_theta
							end
						end

						if x1 and _ispassableatpoint(x1, 0, z1) then
							x, z = x1, z1
						end
					end

					--V2C: -physics doesn't resolve correctly if we teleport from
					--      one point colliding with world to another point still
					--      colliding with world.
					--     -#HACK use mass change to force physics refresh.
					local mass = inst.Physics:GetMass()
					if mass > 0 then
						inst.sg.statemem.restoremass = mass
						inst.Physics:SetMass(mass + 1)
					end
					inst.Physics:Teleport(x, 0, z)

                    -- aoeweapon_lunge:DoLunge can get us out of the state!
                    -- And then, if onexit is run before this: bugs!
                    if not data.skipflash and inst.sg.currentstate == "evileyes_wp_dash" then
                        inst.components.bloomer:PushBloom("lunge", "shaders/anim.ksh", -2)
                        inst.components.colouradder:PushColour("lunge", 1, 1, 0, 0)
                        inst.sg.statemem.flash = 1
                    end
                    return
                end
            end
            --Failed
            inst.sg:GoToState("idle", true)
        end,

        onupdate = function(inst)
            if inst.sg.statemem.flash and inst.sg.statemem.flash > 0 then
                inst.sg.statemem.flash = math.max(0, inst.sg.statemem.flash - .1)
                inst.components.colouradder:PushColour("lunge", inst.sg.statemem.flash, inst.sg.statemem.flash, 0, 0)
            end
        end,

        timeline =
        {
			FrameEvent(8, function(inst)
				if inst.sg.statemem.restoremass ~= nil then
					inst.Physics:SetMass(inst.sg.statemem.restoremass)
					inst.sg.statemem.restoremass = nil
				end
			end),
            TimeEvent(12 * FRAMES, function(inst)
                inst.components.bloomer:PopBloom("lunge")
            end),
        },

        events =
        {
            EventHandler("animover", function(inst)
                if inst.AnimState:AnimDone() then
                    inst.sg:GoToState("idle")
                end
            end),
        },

        onexit = function(inst)
			if inst.sg.statemem.restoremass ~= nil then
				inst.Physics:SetMass(inst.sg.statemem.restoremass)
			end
            inst.components.bloomer:PopBloom("lunge")
            inst.components.colouradder:PopColour("lunge")
        end,
    }
    return state
end
AddStategraphState("wilson",evileyes_wp_dash())

AddStategraphEvent("wilson", EventHandler("evileyes_wp_dash", function(inst, data)
   inst.sg:GoToState("evileyes_wp_dash", data)
end))

--------------------------------------------------------------------------------
local function mevileyes_sheath()	
    local state =
    GLOBAL.State{
        name = "mevileyes_sheath",
        tags = {"busy", "nopredict", "nointerrupt", "nomorph", "doing","notalking","skilling"},
        onenter = function(inst, target)
			inst.components.locomotor:Stop()
		
			inst.AnimState:PlayAnimation("spearjab") 
			inst.AnimState:PushAnimation("spearjab_lag", false) 

			inst.SoundEmitter:PlaySound("dontstarve/wilson/attack_whoosh")	
           
        end,

        timeline =
        {
			GLOBAL.TimeEvent(1.5 * FRAMES, function(inst)
				local equip = inst.components.inventory:GetEquippedItem(EQUIPSLOTS.HANDS)
				if equip and equip.katanamode and equip.components.spellcaster ~= nil then
					equip.katanamode = 2
					equip.components.spellcaster:CastSpell(inst)
				end				
            end),
			GLOBAL.TimeEvent(10 * FRAMES, function(inst) --7
				inst.sg:GoToState("idle")
            end),			
        },

        ontimeout = function(inst)            
            inst.sg:AddStateTag("idle")
        end,

        events =
        {            
            GLOBAL.EventHandler("animqueueover", function(inst)
                if inst.AnimState:AnimDone() and inst.components.health ~= nil and not inst.components.health:IsDead()
                and not inst.sg:HasStateTag("dead")
                then					
                    inst.sg:GoToState("idle")					
                end
            end),
        },

        onexit = function(inst)	
			
        end,
    }
    return state
end
AddStategraphState("wilson",mevileyes_sheath())

local function mevileyes_slice()    
    local state =
    GLOBAL.State{
        name = "mevileyes_slice",
        tags = {"busy", "nopredict", "nointerrupt", "nomorph", "doing","notalking","skilling"},
        onenter = function(inst)
			inst.components.locomotor:Stop()
					
			skilltalk(inst, 8)
			inst.AnimState:PlayAnimation("spearjab_lag")
			
			inst.sg.statemem.instpos = Vector3(inst.Transform:GetWorldPosition())
        end,

        timeline =
        {	
			GLOBAL.TimeEvent(2 * FRAMES, function(inst)
				slicehit(inst, inst.sg.statemem.instpos)			
            end),			
			GLOBAL.TimeEvent(7 * FRAMES, function(inst)
				smashhit(inst, inst.sg.statemem.instpos)			
            end),	
        },

        ontimeout = function(inst)            
            inst.sg:AddStateTag("idle")			
        end,

        events =
        {            
            GLOBAL.EventHandler("animqueueover", function(inst)
                if inst.AnimState:AnimDone() and inst.components.health ~= nil and not inst.components.health:IsDead()
                and not inst.sg:HasStateTag("dead")
                then					
                    inst.sg:GoToState("idle")					
                end
            end),
        },

        onexit = function(inst)			
        end,
    }
    return state
end
AddStategraphState("wilson",mevileyes_slice())

local function mevileyes_smash()   
    local state =
    GLOBAL.State{
        name = "mevileyes_smash",
        tags = {"busy", "nopredict", "nointerrupt", "nomorph", "doing","notalking","skilling"},
        onenter = function(inst)
			inst.components.locomotor:Stop()
			
			skilltalk(inst, 9)
			inst.AnimState:PlayAnimation("scythe_loop")			
			inst.SoundEmitter:PlaySound("dontstarve/wilson/attack_whoosh")
			
			inst.sg.statemem.instpos = Vector3(inst.Transform:GetWorldPosition())
        end,

        timeline =
        {	
			GLOBAL.TimeEvent(4 * FRAMES, function(inst) 				
				smashhit(inst, inst.sg.statemem.instpos)				
            end),
			
			GLOBAL.TimeEvent(16 * FRAMES, function(inst)		
				inst.sg:GoToState("idle")				
            end),			
        },
		
        ontimeout = function(inst)            
            inst.sg:AddStateTag("idle")			
        end,

        events =
        {            
            GLOBAL.EventHandler("animqueueover", function(inst)
                if inst.AnimState:AnimDone() and inst.components.health ~= nil and not inst.components.health:IsDead()
                and not inst.sg:HasStateTag("dead")
                then					
                    inst.sg:GoToState("idle")					
                end
            end),
        },

        onexit = function(inst)			
        end,
    }
    return state
end
AddStategraphState("wilson",mevileyes_smash())

local function mevileyes_ichimonji() 
    local state =
    GLOBAL.State{
        name = "mevileyes_ichimonji",
        tags = {"busy", "nopredict", "nointerrupt", "nomorph", "doing","notalking","skilling"},
        onenter = function(inst, target)
						
            inst.components.locomotor:Stop()
			inst.AnimState:PlayAnimation("atk_prop_pre")
			inst.AnimState:PushAnimation("atk_prop_lag", false)
			inst.AnimState:PushAnimation("atk", false)
			inst.components.combat:EnableAreaDamage(true)
			inst.components.combat:SetAreaDamage(2, 1)	
			inst.AnimState:SetDeltaTimeMultiplier(2)
			
			--skilltalk(inst, 1,4)
			
			target = inst.skill_target
            if target ~= nil and target:IsValid() then
                inst.sg.statemem.target = target
				
				inst.sg.statemem.targetpos = Vector3(target.Transform:GetWorldPosition())

                inst:ForceFacePoint(target.Transform:GetWorldPosition())
            end			
        end,

        timeline =
        {	
			GLOBAL.TimeEvent(8 * FRAMES, function(inst)
				inst.SoundEmitter:PlaySound("dontstarve/creatures/spiderqueen/swipe")
				--SpawnPrefab("electrichitsparks").entity:AddFollower():FollowSymbol(inst.GUID, "swap_body", 0, 0, 0)	
											
            end),			
			GLOBAL.TimeEvent(9 * FRAMES, function(inst)
				inst.AnimState:SetDeltaTimeMultiplier(1)
				inst.Physics:SetMotorVelOverride(32,0,0)
				
				local pos = inst.sg.statemem.targetpos
				inst:ForceFacePoint(pos.x, pos.y, pos.z)
				
            end),
			GLOBAL.TimeEvent(10 * FRAMES, function(inst)
				inst.Physics:ClearMotorVelOverride()					
				local pufffx = SpawnPrefab("maxwell_smoke")
				pufffx.Transform:SetScale(1, 1, 1)
				pufffx.Transform:SetPosition(inst.Transform:GetWorldPosition())
				inst.SoundEmitter:PlaySound("dontstarve/tentacle/tentacle_attack")
            end),
			GLOBAL.TimeEvent(17 * FRAMES, function(inst)
				local pos = inst.sg.statemem.targetpos
				
				inst.SoundEmitter:PlaySound("dontstarve/wilson/hit")
				inst.SoundEmitter:PlaySound("turnoftides/common/together/moon_glass/mine")
				
				habakirifx(inst, pos, 4) --fx
				
				inst.components.combat:DoAttack(inst.sg.statemem.target)	--atk				
				inst.components.combat:DoAttack(inst.sg.statemem.target)	--atk		
				--inst.components.combat:DoAttack(inst.sg.statemem.target)	--atk
				
				if inst.unlockdeathaura then
					inst.components.combat:DoAttack(inst.sg.statemem.target)	--atk
					inst.components.combat:DoAttack(inst.sg.statemem.target)	--atk
				end
				
				maoeattack(inst, pos, 1, 4)	--aoe

				inst:ShakeCamera(CAMERASHAKE.FULL, 0.2, 0.02, .5, inst, 20)				
				inst:PerformBufferedAction()				
				
			end),			
        },

        ontimeout = function(inst)
            inst.sg:RemoveStateTag("attack")
            inst.sg:AddStateTag("idle")			
        end,

        events =
        {    			
            GLOBAL.EventHandler("animqueueover", function(inst)
                if inst.AnimState:AnimDone() and inst.components.health ~= nil and not inst.components.health:IsDead()
                and not inst.sg:HasStateTag("dead")
                then					
                    inst.sg:GoToState("idle")					
                end
            end),
        },

        onexit = function(inst)
			if inst.components.combat then inst.components.combat:SetTarget(nil) end
			if not inst.stronggrip then inst:RemoveTag("stronggrip") end
			rangereset(inst)
			
        end,
    }
    return state
end
AddStategraphState("wilson",mevileyes_ichimonji())

local function mevileyes_iaicross() --flipskill -- ashina cross
    local state =
    GLOBAL.State{
        name = "mevileyes_iaicross",
        tags = {"busy", "nopredict", "nointerrupt", "nomorph", "doing","notalking","skilling"},
        onenter = function(inst, target)
		
            inst.components.locomotor:Stop()			
			inst.AnimState:OverrideSymbol("fx_lunge_streak", "player_lunge_basic", "fx_lunge_streak")			
			inst.components.combat:EnableAreaDamage(true)
			inst.components.combat:SetAreaDamage(2.5, .5)	
			inst.AnimState:SetDeltaTimeMultiplier(1.3)
			
			--skilltalk(inst, 3)
			
			--inst.AnimState:PlayAnimation("lunge_pre")
			inst.AnimState:PlayAnimation("atk_leap_pre")				
			inst.AnimState:PushAnimation("lunge_pst", false)		
					
			inst.SoundEmitter:PlaySound("turnoftides/common/together/boat/jump")	
			
			--local equipskill = inst.components.inventory:GetEquippedItem(EQUIPSLOTS.HANDS)
			--if equipskill and equipskill.katanamode and equipskill.components.spellcaster ~= nil then
			--	equipskill.katanamode = 2
			--	equipskill.components.spellcaster:CastSpell(inst)
			--end	
			
            target = inst.skill_target
            if target ~= nil and target:IsValid() then
                inst.sg.statemem.target = target
				inst.sg.statemem.targetpos = Vector3(target.Transform:GetWorldPosition())
				
                inst:ForceFacePoint(target.Transform:GetWorldPosition())
            end	
			
        end,

        timeline =
        {	
			GLOBAL.TimeEvent(1 * FRAMES, function(inst)		
			inst.Physics:SetMotorVelOverride(32,0,0)
			inst:ForceFacePoint(inst.sg.statemem.target.Transform:GetWorldPosition())			
            end),
			GLOBAL.TimeEvent(2 * FRAMES, function(inst)
			inst.Physics:ClearMotorVelOverride()
            end),
			GLOBAL.TimeEvent(3 * FRAMES, function(inst)
			 inst.SoundEmitter:PlaySound("dontstarve/tentacle/tentacle_attack")			
            end),
			GLOBAL.TimeEvent(4 * FRAMES, function(inst)
			 --inst.SoundEmitter:PlaySound("turnoftides/common/together/boat/jump") 			
            end),
			GLOBAL.TimeEvent(5 * FRAMES, function(inst)
			 --inst.SoundEmitter:PlaySound("turnoftides/common/together/boat/jump") 			
            end),
			GLOBAL.TimeEvent(6 * FRAMES, function(inst)
			 --inst.SoundEmitter:PlaySound("turnoftides/common/together/boat/jump") 			
            end),
			GLOBAL.TimeEvent(7 * FRAMES, function(inst)			
			 inst.SoundEmitter:PlaySound("turnoftides/common/together/boat/jump")
			 inst.SoundEmitter:PlaySound("dontstarve/tentacle/tentacle_attack")
            end),            
			GLOBAL.TimeEvent(8 * FRAMES, function(inst)

				--slashfx5(inst, inst.sg.statemem.target,2)
				inst.components.combat:DoAttack(inst.sg.statemem.target)	--atk 
				inst.components.combat:DoAttack(inst.sg.statemem.target)	--atk
				inst.components.combat:DoAttack(inst.sg.statemem.target)	--atk
				inst.components.combat:DoAttack(inst.sg.statemem.target)	--atk
				
				
				if inst.unlockdeathaura then					
					inst.components.combat:DoAttack(inst.sg.statemem.target)	--atk
					inst.components.combat:DoAttack(inst.sg.statemem.target)	--atk
				end
				
               	inst:PerformBufferedAction()
				inst:ShakeCamera(CAMERASHAKE.FULL, 0.2, 0.02, .5, inst, 20)
				inst.SoundEmitter:PlaySound("turnoftides/common/together/moon_glass/mine")
					
            end),
			GLOBAL.TimeEvent(12 * FRAMES, function(inst)
				local fx = SpawnPrefab("mevileyes_iaislash_fx")		
				fx.Transform:SetPosition(inst.sg.statemem.targetpos.x,1,inst.sg.statemem.targetpos.z)			
				fx.Transform:SetRotation(inst.Transform:GetRotation())		
            end),			
        },

        ontimeout = function(inst)
            inst.sg:RemoveStateTag("attack")
            inst.sg:AddStateTag("idle")
			
        end,

        events =
        {            
            GLOBAL.EventHandler("animqueueover", function(inst)
                if inst.AnimState:AnimDone() and inst.components.health ~= nil and not inst.components.health:IsDead()
                and not inst.sg:HasStateTag("dead")
                then					
                    inst.sg:GoToState("idle")					
                end
            end),
        },

        onexit = function(inst)
			if inst.components.combat then inst.components.combat:SetTarget(nil) end
			if not inst.stronggrip then inst:RemoveTag("stronggrip") end
			rangereset(inst)			
        end,
    }
    return state
end
AddStategraphState("wilson",mevileyes_iaicross())

local function mevileyes_thrust() --thrustskill
    local state =
    GLOBAL.State{
        name = "mevileyes_thrust",
        tags = {"busy", "nopredict", "nointerrupt", "nomorph", "doing","notalking","skilling"},
        onenter = function(inst, target)
			
            inst.components.locomotor:Stop()			
			inst.components.combat:EnableAreaDamage(true)
			inst.components.combat:SetAreaDamage(2, 1)	
			inst.AnimState:SetDeltaTimeMultiplier(1.3)
			--inst.components.health:SetInvincible(true)
			--skilltalk(inst, 2)
			
			inst.AnimState:PlayAnimation("multithrust")			
	        inst.SoundEmitter:PlaySound("dontstarve/wilson/attack_weapon")			
            target = inst.skill_target
            if target ~= nil and target:IsValid() then
                inst.sg.statemem.target = target
                inst:ForceFacePoint(target.Transform:GetWorldPosition())
            end			
        end,

        timeline =
        {	
			GLOBAL.TimeEvent(1 * FRAMES, function(inst)			
			inst.Physics:SetMotorVelOverride(32,0,0)
			inst:ForceFacePoint(inst.sg.statemem.target.Transform:GetWorldPosition())			
            end),
			GLOBAL.TimeEvent(2 * FRAMES, function(inst)
			inst.Physics:ClearMotorVelOverride()
            end),
			GLOBAL.TimeEvent(8 * FRAMES, function(inst)
			inst.SoundEmitter:PlaySound("dontstarve/wilson/attack_nightsword") 			
            end),			
			GLOBAL.TimeEvent(9 * FRAMES, function(inst)
			inst.SoundEmitter:PlaySound("dontstarve/creatures/spiderqueen/swipe")			
			inst.components.combat:DoAttack(inst.sg.statemem.target) --atk
			inst:ShakeCamera(CAMERASHAKE.FULL, 0.2, 0.02, .5, inst, 20)
            inst:PerformBufferedAction()
			
            end),
			GLOBAL.TimeEvent(10 * FRAMES, function(inst)
			inst.SoundEmitter:PlaySound("dontstarve/wilson/attack_nightsword")
			inst.components.combat:DoAttack(inst.sg.statemem.target) --atk
			inst:ShakeCamera(CAMERASHAKE.FULL, 0.2, 0.02, .5, inst, 20)
            inst:PerformBufferedAction()
			
            end),
			GLOBAL.TimeEvent(12 * FRAMES, function(inst)
			inst.SoundEmitter:PlaySound("dontstarve/creatures/spiderqueen/swipe")
			--inst.components.combat:DoAttack(inst.sg.statemem.target) --atk
			inst:ShakeCamera(CAMERASHAKE.FULL, 0.2, 0.02, .5, inst, 20)
            inst:PerformBufferedAction()
			
            end),            
			GLOBAL.TimeEvent(14 * FRAMES, function(inst)				
				inst.components.combat:DoAttack(inst.sg.statemem.target) --atk
				
				if inst.unlockdeathaura then
				inst.components.combat:DoAttack(inst.sg.statemem.target) --atk			
				inst.components.combat:DoAttack(inst.sg.statemem.target) --atk			
				end

               	inst:PerformBufferedAction()
				inst:ShakeCamera(CAMERASHAKE.FULL, 0.2, 0.02, .5, inst, 20)
				inst.SoundEmitter:PlaySound("turnoftides/common/together/moon_glass/mine")

            end),
			GLOBAL.TimeEvent(18 * FRAMES, function(inst) 
						
            end),
        },

        ontimeout = function(inst)
            inst.sg:RemoveStateTag("attack")
            inst.sg:AddStateTag("idle")
			
        end,

        events =
        {    			
            GLOBAL.EventHandler("animqueueover", function(inst)
                if inst.AnimState:AnimDone() and inst.components.health ~= nil and not inst.components.health:IsDead()
                and not inst.sg:HasStateTag("dead")
                then					
                    inst.sg:GoToState("idle")					
					
                end
            end),
        },

        onexit = function(inst)
			if inst.components.combat then inst.components.combat:SetTarget(nil) end
			if not inst.stronggrip then inst:RemoveTag("stronggrip") end
			rangereset(inst)
			--inst.components.health:SetInvincible(false)
			inst.components.timer:StartTimer("mevileyes_evildodge", 2)			
        end,
    }
    return state
end
AddStategraphState("wilson",mevileyes_thrust())

local function mevileyes_habakiri()
    local equipskill
	local state =
    GLOBAL.State{
        name = "mevileyes_habakiri",
        tags = {"busy", "nopredict", "nointerrupt", "nomorph", "doing","notalking","skilling"},
        onenter = function(inst, target)
			
			equipskill = inst.components.inventory:GetEquippedItem(EQUIPSLOTS.HANDS)
            inst.components.locomotor:Stop()
			--inst.components.health:SetInvincible(true)
			inst.AnimState:OverrideSymbol("fx_lunge_streak", "player_lunge_basic", "fx_lunge_streak")			
			inst.components.combat:EnableAreaDamage(true)
			inst.components.combat:SetAreaDamage(3, .75)
			
			skilltalk(inst, 5,4)
			
			inst.AnimState:PlayAnimation("atk")			
			inst.SoundEmitter:PlaySound("turnoftides/common/together/boat/jump")			
            target = inst.skill_target
            if target ~= nil and target:IsValid() then
                inst.sg.statemem.target = target
                inst:ForceFacePoint(target.Transform:GetWorldPosition())
				
				inst.sg.statemem.targetpos = Vector3(target.Transform:GetWorldPosition())
            end			
        end,

        timeline =
        {	
			GLOBAL.TimeEvent(1 * FRAMES, function(inst)				
				inst:ForceFacePoint(inst.sg.statemem.target.Transform:GetWorldPosition())
				inst.Physics:SetMotorVelOverride(-.25,0,10)
            end),
			
			GLOBAL.TimeEvent(3 * FRAMES, function(inst)
				inst.SoundEmitter:PlaySound("turnoftides/common/together/boat/jump")
            end),
			
			GLOBAL.TimeEvent(4 * FRAMES, function(inst)						
				inst.components.combat:DoAttack(inst.sg.statemem.target) --atk
				if inst.unlockdeathaura then
					inst.components.combat:DoAttack(inst.sg.statemem.target) --atk
				end				
				habakirifx(inst, inst.sg.statemem.targetpos, 6) --fx
				
				inst.SoundEmitter:PlaySound("turnoftides/common/together/moon_glass/mine")
				inst:PerformBufferedAction()		
				inst.Physics:ClearMotorVelOverride()
            end),
			
			GLOBAL.TimeEvent(5 * FRAMES, function(inst)			
				inst.SoundEmitter:PlaySound("turnoftides/common/together/boat/jump")
				inst.AnimState:PlayAnimation("lunge_pst")
				inst:ForceFacePoint(inst.sg.statemem.target.Transform:GetWorldPosition())
				inst.Physics:SetMotorVelOverride(-.5,0,-20)
            end),
			
			GLOBAL.TimeEvent(8* FRAMES, function(inst)
				inst.components.combat:DoAttack(inst.sg.statemem.target) --atk
				
				habakirihit(inst, inst.sg.statemem.targetpos) --aoe
				
				inst.SoundEmitter:PlaySound("turnoftides/common/together/moon_glass/mine")
				inst:PerformBufferedAction()			
				inst.Physics:ClearMotorVelOverride()
            end),
			
			GLOBAL.TimeEvent(9 * FRAMES, function(inst)				
				inst.SoundEmitter:PlaySound("turnoftides/common/together/boat/jump")
				inst.AnimState:PlayAnimation("atk")
				inst:ForceFacePoint(inst.sg.statemem.target.Transform:GetWorldPosition())
				inst.Physics:SetMotorVelOverride(-.5,0,20)
            end),				
           
			GLOBAL.TimeEvent(12* FRAMES, function(inst)
				
				inst.components.combat:DoAttack(inst.sg.statemem.target) --atk							
				if inst.unlockdeathaura then
					inst.components.combat:DoAttack(inst.sg.statemem.target) --atk
				end
				habakirihit2(inst, inst.sg.statemem.targetpos) --aoe
				
				inst:PerformBufferedAction()				
				inst.SoundEmitter:PlaySound("turnoftides/common/together/moon_glass/mine")			
				inst.Physics:ClearMotorVelOverride()
				inst.Physics:SetMotorVelOverride(-.5,0,-10)				
            end),
			
			GLOBAL.TimeEvent(15* FRAMES, function(inst)
				equipskill = inst.components.inventory:GetEquippedItem(EQUIPSLOTS.HANDS)
				if equipskill and equipskill.katanamode and equipskill.components.spellcaster ~= nil then
					equipskill.katanamode = 2
					equipskill.components.spellcaster:CastSpell(inst)
				end	
				inst.Physics:ClearMotorVelOverride()
				SpawnPrefab("sparks").Transform:SetPosition(inst:GetPosition():Get())			
            end),						
        },

        ontimeout = function(inst)
            inst.sg:RemoveStateTag("attack")
            inst.sg:AddStateTag("idle")
			
        end,

        events =
        {            
            GLOBAL.EventHandler("animqueueover", function(inst)
                if inst.AnimState:AnimDone() and inst.components.health ~= nil and not inst.components.health:IsDead()
                and not inst.sg:HasStateTag("dead")
                then					
                    inst.sg:GoToState("idle")					
                end
            end),
        },

        onexit = function(inst)			
			if inst.components.combat then inst.components.combat:SetTarget(nil) end
			if not inst.stronggrip then inst:RemoveTag("stronggrip") end
			rangereset(inst)
			--inst.components.health:SetInvincible(false)			
        end,
    }
    return state
end
AddStategraphState("wilson",mevileyes_habakiri())

local function mevileyes_ryusen() --ryusen 6
	local equipskill
    local state =
    GLOBAL.State{
        name = "mevileyes_ryusen",
        tags = {"busy", "nopredict", "nointerrupt", "nomorph", "doing","notalking","skilling"},
        onenter = function(inst, target)
			--inst.components.health:SetInvincible(true)
			
			skilltalk(inst, 6,4)
			
			equipskill = inst.components.inventory:GetEquippedItem(EQUIPSLOTS.HANDS)
            inst.components.locomotor:Stop()						
			--inst.AnimState:PlayAnimation("spearjab_pre")			
			inst.AnimState:PlayAnimation("multithrust")	
			
			if equipskill and equipskill.katanamode and equipskill.components.spellcaster ~= nil then
					equipskill.katanamode = 2
					equipskill.components.spellcaster:CastSpell(inst)
			end
				
			inst.SoundEmitter:PlaySound("dontstarve/wilson/attack_weapon")	
            target = inst.skill_target
            if target ~= nil and target:IsValid() then
                inst.sg.statemem.target = target
                inst:ForceFacePoint(target.Transform:GetWorldPosition())
				
				inst.sg.statemem.targetpos = Vector3(target.Transform:GetWorldPosition())
				inst.sg.statemem.instpos = Vector3(inst.Transform:GetWorldPosition())
            end			
        end,

        timeline =
        {		
			GLOBAL.TimeEvent(10 * FRAMES, function(inst)
				--inst.AnimState:PushAnimation("spearjab_lag", false)
				
				if equipskill and equipskill.katanamode and equipskill.components.spellcaster ~= nil then
					equipskill.katanamode = 2
					equipskill.components.spellcaster:CastSpell(inst)
				end
				
				inst.AnimState:PlayAnimation("atk")					
			end),
			
			GLOBAL.TimeEvent(11 * FRAMES, function(inst)
				if equipskill and equipskill.katanamode and equipskill.components.spellcaster ~= nil then
					equipskill.katanamode = 1
					equipskill.components.spellcaster:CastSpell(inst)
				end				
            end),
			
			GLOBAL.TimeEvent(12 * FRAMES, function(inst)
				ryusenhit2(inst,inst.sg.statemem.targetpos, 2) --aoe
				inst.SoundEmitter:PlaySound("dontstarve/wilson/attack_weapon")
				inst.SoundEmitter:PlaySound("dontstarve/tentacle/tentacle_attack")
				inst.SoundEmitter:PlaySound("turnoftides/common/together/moon_glass/mine")
				
			end),
					
			GLOBAL.TimeEvent(25 * FRAMES, function(inst)		
				ryusenhit(inst,inst.sg.statemem.targetpos, 4)	--aoe
				inst.SoundEmitter:PlaySound("dontstarve/tentacle/tentacle_attack")
				inst.SoundEmitter:PlaySound("turnoftides/common/together/moon_glass/mine")
				
            end),
			
        },

        ontimeout = function(inst)
            inst.sg:RemoveStateTag("attack")
            inst.sg:AddStateTag("idle")
			
        end,

        events =
        {            
            GLOBAL.EventHandler("animqueueover", function(inst)
                if inst.AnimState:AnimDone() and inst.components.health ~= nil and not inst.components.health:IsDead()
                and not inst.sg:HasStateTag("dead")
                then					
                    inst.sg:GoToState("idle")					
                end
            end),
        },

        onexit = function(inst)
			if inst.components.combat then inst.components.combat:SetTarget(nil) end
			if not inst.stronggrip then inst:RemoveTag("stronggrip") end
			rangereset(inst)
			--inst.components.health:SetInvincible(false)
        end,
    }
    return state
end
AddStategraphState("wilson",mevileyes_ryusen())
------------------------------------------------------------------------------------------------------------------------

------------------------------------------------------------------------------------------------------------------------
local function mevileyes_onemind() --4
    local equipskill
    local state =
    GLOBAL.State{
        name = "mevileyes_onemind",
        tags = {"busy", "nopredict", "nointerrupt", "nomorph", "doing","notalking","skilling","skillimue","m_noknockback"},
        onenter = function(inst, target)
			equipskill = inst.components.inventory:GetEquippedItem(EQUIPSLOTS.HANDS)
			
			skilltalk(inst, 4,4)
						
			inst.AnimState:PlayAnimation("atk")
			inst.SoundEmitter:PlaySound("dontstarve/wilson/attack_weapon")			
			target = inst.skill_target
            if target ~= nil and target:IsValid() then
                inst.sg.statemem.target = target
                inst:ForceFacePoint(target.Transform:GetWorldPosition())
								
				inst.sg.statemem.targetpos = Vector3(target.Transform:GetWorldPosition())
				inst.sg.statemem.instpos = Vector3(inst.Transform:GetWorldPosition())
            end          
        end,

        timeline =
        {				
			GLOBAL.TimeEvent(1 * FRAMES, function(inst)
			
				inst.components.combat:DoAttack(inst.sg.statemem.target)	--atk
				
				inst.SoundEmitter:PlaySound("turnoftides/common/together/moon_glass/mine")
			
				equipskill = inst.components.inventory:GetEquippedItem(EQUIPSLOTS.HANDS)				
				inst.Physics:SetMotorVelOverride(20,0,0)				
				inst:ForceFacePoint(inst.sg.statemem.target.Transform:GetWorldPosition())
				
            end),
			GLOBAL.TimeEvent(2 * FRAMES, function(inst)
				inst.AnimState:PlayAnimation("spearjab_pre")					
			end),
			GLOBAL.TimeEvent(3 * FRAMES, function(inst)
				if equipskill and equipskill.katanamode and equipskill.components.spellcaster ~= nil then
					equipskill.katanamode = 2
					equipskill.components.spellcaster:CastSpell(inst)
				end
				inst.Physics:ClearMotorVelOverride()
			end),
			GLOBAL.TimeEvent(4 * FRAMES, function(inst)
				inst.AnimState:PlayAnimation("spearjab_lag")
				onemindhit3(inst, inst.sg.statemem.targetpos) --aoe
				groundpoundfx_t2(inst, inst.sg.statemem.instpos)
			end),

			GLOBAL.TimeEvent(13 * FRAMES, function(inst)
				inst.AnimState:PushAnimation("spearjab_lag", false)				
            end),

			GLOBAL.TimeEvent(22 * FRAMES, function(inst)						
				inst.AnimState:PushAnimation("spearjab_lag", false)
				
				slashfx5black(inst, inst.sg.statemem.targetpos, 4) --fx
				
				groundpoundfx_t2(inst, inst.sg.statemem.instpos)
				
				onemindhit4(inst, inst.sg.statemem.targetpos)	--aoe
				
				inst.SoundEmitter:PlaySound("turnoftides/common/together/moon_glass/mine")
            end),
			GLOBAL.TimeEvent(24 * FRAMES, function(inst)				
				slashfx6black(inst, inst.sg.statemem.targetpos, 4) --fx
            end),
			
			GLOBAL.TimeEvent(26 * FRAMES, function(inst)			
				onemindhit4(inst, inst.sg.statemem.targetpos) --aoe
				
				inst.SoundEmitter:PlaySound("turnoftides/common/together/moon_glass/mine")
            end),	

			GLOBAL.TimeEvent(28 * FRAMES, function(inst)
				inst.AnimState:PushAnimation("spearjab_lag", false)
				
				slashfx5black(inst, inst.sg.statemem.targetpos, 4) --fx
				groundpoundfx_t2(inst, inst.sg.statemem.instpos)
				
				onemindhit4(inst, inst.sg.statemem.targetpos) --aoe
				inst.SoundEmitter:PlaySound("turnoftides/common/together/moon_glass/mine")	
            end),
			
			GLOBAL.TimeEvent(30 * FRAMES, function(inst)				
				slashfx6black(inst, inst.sg.statemem.targetpos, 4) --fx
            end),
			GLOBAL.TimeEvent(40 * FRAMES, function(inst)
				inst.AnimState:PlayAnimation("idle")
				inst.AnimState:PushAnimation("lunge_pst", false)
				inst.AnimState:OverrideSymbol("fx_lunge_streak", "player_lunge_basic", "fx_lunge_streak")
            end),
			GLOBAL.TimeEvent(44 * FRAMES, function(inst)
				if equipskill and equipskill.katanamode and equipskill.components.spellcaster ~= nil then
					equipskill.katanamode = 2
					equipskill.components.spellcaster:CastSpell(inst)
				end
				
            end),
			
			GLOBAL.TimeEvent(45 * FRAMES, function(inst)
				if equipskill and equipskill.katanamode and equipskill.components.spellcaster ~= nil then
					equipskill.katanamode = 1
					equipskill.components.spellcaster:CastSpell(inst)
				end
				
				onemindhit5(inst, inst.sg.statemem.targetpos) --aoe
				inst.SoundEmitter:PlaySound("turnoftides/common/together/moon_glass/mine")
            end),
			
        },

        ontimeout = function(inst)            
            inst.sg:AddStateTag("idle")			
        end,

        events =
        {            
            GLOBAL.EventHandler("animqueueover", function(inst)
                if inst.AnimState:AnimDone() and inst.components.health ~= nil and not inst.components.health:IsDead()
                and not inst.sg:HasStateTag("dead")
                then					
                    inst.sg:GoToState("idle")					
                end
            end),
        },

        onexit = function(inst)		
			inst.components.timer:StartTimer("mevileyes_evildodge", 2)
			rangereset(inst)
			if not inst.stronggrip then inst:RemoveTag("stronggrip") end			
        end,
    }
    return state
end
AddStategraphState("wilson",mevileyes_onemind())
-------------------------------------------------------------------------------------------------------------------------------------------------

-------------------------------------------------------------------------------------------------------------------------------------------------
local function mevileyes_eienwing() --7
    local equipskill
    local state =
    GLOBAL.State{
        name = "mevileyes_eienwing",
        tags = {"busy", "nopredict", "nointerrupt", "nomorph", "doing","notalking","skilling","skillimue","m_noknockback"},
        onenter = function(inst, target)
			equipskill = inst.components.inventory:GetEquippedItem(EQUIPSLOTS.HANDS)
						
			skilltalk(inst, 7,4)
			
			inst.AnimState:PlayAnimation("scythe_loop")
			inst.SoundEmitter:PlaySound("dontstarve/wilson/attack_weapon")			
			target = inst.skill_target
            if target ~= nil and target:IsValid() then
                inst.sg.statemem.target = target
                inst:ForceFacePoint(target.Transform:GetWorldPosition())
				
				inst.sg.statemem.targetpos = Vector3(target.Transform:GetWorldPosition())
				inst.sg.statemem.instpos = Vector3(inst.Transform:GetWorldPosition())
            end          
        end,

        timeline =
        {				
			GLOBAL.TimeEvent(1 * FRAMES, function(inst)
			inst.components.combat:DoAttack(inst.sg.statemem.target) --atk			
				--inst.Physics:SetMotorVelOverride(32,0,0)				
				inst:ForceFacePoint(inst.sg.statemem.target.Transform:GetWorldPosition())				
            end),
			GLOBAL.TimeEvent(4 * FRAMES, function(inst)
				--inst.Physics:ClearMotorVelOverride()
				inst.AnimState:PushAnimation("spearjab_lag", false)
			end),
			GLOBAL.TimeEvent(9 * FRAMES, function(inst)
				
				eienwing_fx2(inst, inst.sg.statemem.instpos)
				
				local breakfx = SpawnPrefab("mevileyes_black_break")
				breakfx.Transform:SetPosition(inst.Transform:GetWorldPosition())
				
				eienwing_fx(inst, 2)
				pulsefx_black(inst, 1)
				inst.DynamicShadow:Enable(false)
				inst:Hide()
				eienwing_hit(inst, inst.sg.statemem.targetpos)	--aoe
				
				inst.AnimState:PushAnimation("spearjab_lag", false)				
				inst.AnimState:PushAnimation("spearjab_lag", false)				
				inst.AnimState:PushAnimation("spearjab_lag", false)							
            end),
			GLOBAL.TimeEvent(16 * FRAMES, function(inst)			
				inst.components.raindome:Enable()
				eienwing_ringfx(inst, 3, 16, 4)
				inst.AnimState:PushAnimation("spearjab_lag", false)
				eienwing_hit(inst, inst.sg.statemem.targetpos)
            end),	
			GLOBAL.TimeEvent(18 * FRAMES, function(inst)			
				eienwing_hit(inst, inst.sg.statemem.targetpos)
				
            end),	
			GLOBAL.TimeEvent(22 * FRAMES, function(inst)			
				
				eienwing_fx3(inst, inst.sg.statemem.instpos)				
				eienwing_hit(inst, inst.sg.statemem.targetpos)	--aoe				

            end),	
			GLOBAL.TimeEvent(28 * FRAMES, function(inst)			
				--eienwing_ringfx(inst, 3, 16, 4)
				eienwing_hit(inst, inst.sg.statemem.targetpos)
            end),
			
			GLOBAL.TimeEvent(32 * FRAMES, function(inst)
				eienwing_fx3(inst, inst.sg.statemem.instpos)
				eienwing_hit(inst, inst.sg.statemem.targetpos)				
            end),
			
			GLOBAL.TimeEvent(40 * FRAMES, function(inst)			
				eienwing_hit(inst, inst.sg.statemem.targetpos)				
            end),
			
			GLOBAL.TimeEvent(48 * FRAMES, function(inst)			
				eienwing_fx2(inst, inst.sg.statemem.instpos)
				eienwing_hit(inst, inst.sg.statemem.targetpos)	--aoe
            end),
			
			GLOBAL.TimeEvent(58 * FRAMES, function(inst)			
				eienwing_hit(inst, inst.sg.statemem.targetpos)				
            end),
			
			GLOBAL.TimeEvent(68 * FRAMES, function(inst)			
				eienwing_fx3(inst, inst.sg.statemem.instpos)
				eienwing_hit(inst, inst.sg.statemem.targetpos)	--aoe
				
            end),
			
			GLOBAL.TimeEvent(74 * FRAMES, function(inst)
				pulsefx_black(inst, 1)
				
				local breakfx = SpawnPrefab("mevileyes_black_break")
				breakfx.Transform:SetPosition(inst.Transform:GetWorldPosition())
				
				inst.DynamicShadow:Enable(true)
				inst:Show()			
				
            end),
			
			GLOBAL.TimeEvent(78 * FRAMES, function(inst)
				
				eienwing_hit(inst, inst.sg.statemem.targetpos)	--aoe
				eienwing_ringfx(inst, 3, 16, 4)
				inst.components.raindome:Disable() 
					
				inst.sg.statemem.skillfinish = true
            end),	
			
        },

        ontimeout = function(inst)            
            inst.sg:AddStateTag("idle")
        end,

        events =
        {            
            GLOBAL.EventHandler("animqueueover", function(inst)
                if inst.AnimState:AnimDone() and inst.components.health ~= nil and not inst.components.health:IsDead()
                and not inst.sg:HasStateTag("dead")
                then					
                    inst.sg:GoToState("idle")					
                end
            end),
        },

        onexit = function(inst)		
			inst.components.timer:StartTimer("mevileyes_evildodge", 2)
			
			if not inst.sg.statemem.skillfinish then
				inst.DynamicShadow:Enable(true)
				inst:Show()				
				inst.sg.statemem.skillfinish = true
			end
			
			rangereset(inst)
			if not inst.stronggrip then inst:RemoveTag("stronggrip") end
        end,
    }
    return state
end
AddStategraphState("wilson",mevileyes_eienwing())
