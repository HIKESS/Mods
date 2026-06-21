local MakePlayerCharacter = require "prefabs/player_common"
local assets = {
    Asset("SCRIPT", "scripts/prefabs/player_common.lua"),
	Asset("SCRIPT", "scripts/prefabs/skilltree_mevileyes.lua"),
	
}

-- Your character's stats
TUNING.MEVILEYES_HEALTH = TUNING.MEVILEYES.HEALTH
TUNING.MEVILEYES_HUNGER = TUNING.MEVILEYES.HUNGER 
TUNING.MEVILEYES_SANITY = TUNING.MEVILEYES.SANITY 

local myohomuramasa = TUNING.MEVILEYES.STARTITEM and "myoho" or "yukishigure"
TUNING.GAMEMODE_STARTING_ITEMS.DEFAULT.MEVILEYES = {myohomuramasa,"netrajournal"} --,"nightmarefuel","nightmarefuel","nightmarefuel","nightmarefuel","nightmarefuel","nightmarefuel"

local start_inv = {}
for k, v in pairs(TUNING.GAMEMODE_STARTING_ITEMS) do
    start_inv[string.lower(k)] = v.MEVILEYES
end
local prefabs = FlattenTree(start_inv, true)

local function disableallskill(inst)
	inst.skill1,inst.skill2,inst.skill3,inst.skill4,inst.skill5,inst.skill6,inst.skill7 = nil
	inst.components.combat:SetRange(inst.oldrange)
end

local function skillfxremove(inst)
	if inst.evilwavebufffx then inst.evilwavebufffx:Cancel()end
	 inst.evilwavebufffx = nil	
	if inst._evilspeed_fx then inst._evilspeed_fx:KillFX() end
	inst._evilspeed_fx = nil
end

local function OnTimerDone(inst, data)
	if data.name then local name = data.name
		if name == "mevileyes_atk_buff" then if inst.evilwavebufffx then inst.evilwavebufffx:Cancel() end  inst.evilwavebufffx = nil return end	
		if name == "mevileyes_cri_atk_cd" then  inst.components.combat.externaldamagemultipliers:RemoveModifier(inst, "evileyes_cri_atk")  return end		
		if name == "kenjutsufoodbuff" then  inst.kenjutsufoodbuff = nil  return end
	end
end

--waxwell--
local function KillPet(pet)
	if pet.components.health:IsInvincible() then
		--reschedule
		pet._killtask = pet:DoTaskInTime(.5, KillPet)
	else
		pet.components.health:Kill()
	end
end

local shadow_equipment = {
	--{ build = "swap_yukishigure", 			symbol = "swap_object", 	},
    { build = "swap_m_katana", 			symbol = "swap_object", 	},
    { build = "swap_nagarehime", 		symbol = "swap_object", 	},   
    --{ build = "swap_nightmaresword_shadow", 		symbol = "swap_nightmaresword_shadow", 	},   
}

local function OnPetKill(inst, data)
	local victim = data.victim
	local leader = inst.components.follower:GetLeader()
	
	if victim ~= nil and victim:IsValid() and leader ~= nil then
       
        if victim.components.combat ~= nil then
            victim.components.combat.lastattacker = leader
        end
		
        leader:PushEvent("killed", { victim = victim })
        
        if victim:HasTag("shadow") and victim.sanityreward ~= nil and leader.components.sanity ~= nil then
            leader.components.sanity:DoDelta(victim.sanityreward)
        end
    end	
end

local function leaderinsane(inst)
	local leader = inst.components.follower:GetLeader()
	local leaderskilltree = leader and leader.components.skilltreeupdater ~= nil and leader.components.skilltreeupdater:IsActivated("mevileyes_crazy") 		
		if leaderskilltree and leader.components.sanity:IsInsane() and not leader.skullhaton then 
			inst:AddTag("crazy")
		else
			inst:RemoveTag("crazy") 
		end		
end
	
local function OnSpawnPet(inst, pet)

    if pet:HasTag("shadowminion") then
        if not (inst.components.health:IsDead() or inst:HasTag("playerghost")) then
			inst.components.sanity:AddSanityPenalty(pet, TUNING.SHADOWWAXWELL_SANITY_PENALTY[string.upper(pet.prefab)])
            inst:ListenForEvent("onremove", inst._onpetlost, pet)
            pet.components.skinner:CopySkinsFromPlayer(inst)
			pet.AnimState:SetScale(0.95, 0.95, 1)
			pet.AnimState:Hide("HEAD_HAT")
			
			if  pet.prefab == "shadowduelist" then				
				pet.despawnpetloot = false
			end
			
			if pet.components.locomotor and inst.components.skilltreeupdater ~= nil and inst.components.skilltreeupdater:IsActivated("mevileyes_minion_speed") then
				pet.components.locomotor:SetExternalSpeedMultiplier(inst, "shadow_speed_buff", 1.25)
			end
			
			if TUNING.MEVILEYES.MINIONWEAPON then	
				if pet.prefab == "shadowprotector" or pet.prefab == "shadowduelist" then
				local choice = shadow_equipment[math.random(#shadow_equipment)]				
						pet.AnimState:OverrideSymbol("swap_object", choice.build, choice.symbol)
				end
			end
						
			pet:DoTaskInTime(3, function(p)
				
				if TUNING.MEVILEYES.MINIONCOLOR and p.prefab == "shadowworker" then p.AnimState:SetMultColour(.2, .2, .2, .8) end			
				if TUNING.MEVILEYES.MINIONCOLOR2 and (p.prefab == "shadowprotector" or p.prefab == "shadowduelist") then p.AnimState:SetMultColour(.2, .2, .2, .8) end		
						
				if TUNING.MEVILEYES.SKILLTREE then
					if p:IsValid() and (p.prefab == "shadowprotector" or p.prefab == "shadowduelist") then
					
						p:ListenForEvent("killed", OnPetKill)
						p:DoPeriodicTask(2, leaderinsane)

						if p.components.combat and inst.myshadowattack then
							p.components.combat.externaldamagemultipliers:SetModifier(inst, inst.myshadowattack, "shadow_atk_buff")	
						end
						
						if p.components.health and inst.myshadowdef then
							p.components.health:SetAbsorptionAmount(inst.myshadowdef)
						end
					end
				end
            end)
			
        elseif pet._killtask == nil then
            pet._killtask = pet:DoTaskInTime(math.random(), KillPet)
        end
    elseif inst._OnSpawnPet ~= nil then
        inst:_OnSpawnPet(pet)
    end	
end

local function OnDespawnPet(inst, pet)	
	if pet:HasTag("shadowminion") then
		if not inst.is_snapshot_user_session and pet.sg ~= nil then
			pet.sg:GoToState("quickdespawn")
		else
			pet:Remove()
		end
    elseif inst._OnDespawnPet ~= nil then
        inst:_OnDespawnPet(pet)
    end
end

local function ReskinPet(pet, player, nofx)
    pet._dressuptask = nil
    if player:IsValid() then
        if not nofx then
            local x, y, z = pet.Transform:GetWorldPosition()
            local fx = SpawnPrefab("slurper_respawn")
            fx.Transform:SetPosition(x, y, z)
        end
        pet.components.skinner:CopySkinsFromPlayer(player)
    end
end

local function OnSkinsChanged(inst, data)
    for k, v in pairs(inst.components.petleash:GetPets()) do
        if v:HasTag("shadowminion") then
            if v._dressuptask ~= nil then
                v._dressuptask:Cancel()
                v._dressuptask = nil
            end
            if data and data.nofx then
                ReskinPet(v, inst, data.nofx)
            else
                v._dressuptask = v:DoTaskInTime(math.random()*0.5 + 0.25, ReskinPet, inst)
            end
        end
    end
end

local function OnDeath(inst)
	disableallskill(inst)
	skillfxremove(inst)
    for k, v in pairs(inst.components.petleash:GetPets()) do
        if v:HasTag("shadowminion") and v._killtask == nil then
            v._killtask = v:DoTaskInTime(math.random(), KillPet)
        end
    end
end

local function OnBecameGhost(inst)
	for k, v in pairs(inst.components.petleash:GetPets()) do
		if v:HasTag("shadowminion") then
			inst:RemoveEventCallback("onremove", inst._onpetlost, v)
			inst.components.sanity:RemoveSanityPenalty(v)
			if v._killtask == nil then
				v._killtask = v:DoTaskInTime(math.random(), KillPet)
			end
		end
	end	
end

local function ForceDespawnShadowMinions(inst)
    local todespawn = {}
    for k, v in pairs(inst.components.petleash:GetPets()) do
        if v:HasTag("shadowminion") then
            table.insert(todespawn, v)
        end
    end
    for i, v in ipairs(todespawn) do
        inst.components.petleash:DespawnPet(v)
    end
end

local function OnDespawn(inst, migrationdata)
	skillfxremove(inst)
	if migrationdata ~= nil then
		ForceDespawnShadowMinions(inst)
	end
end

local function GetEquippableDapperness(owner, equippable)
	local dapperness = equippable:GetDapperness(owner, owner.components.sanity.no_moisture_penalty)
	return equippable.inst:HasTag("shadow_item") --and owner.shadowitemresist
		and dapperness * TUNING.WAXWELL_SHADOW_ITEM_RESISTANCE
		or dapperness
end

local function OnEquip(inst,data)
	local item = data ~= nil and (data.prev_item or data.item)	
	if item and item.prefab == "skeletonhat" then 
		inst.skullhaton = true
	end
end

local function OnUnEquip(inst,data)
	local item = data ~= nil and (data.prev_item or data.item)
	disableallskill(inst)		
	if item and item.prefab == "skeletonhat" then 
		inst.skullhaton = nil
	end
end

local function OnResisqueen(inst)
	inst.components.talker:Say("Nice, try!")	
end
---------------------------------------------------------------------------------------------------------------------------------------------------------
local function mindregenfn(inst)
	inst.mindpower = inst.mindpower+1	
end

local function mindregen(inst)
	if inst.mindpower < math.ceil((TUNING.MEVILEYES.MAXMIND + inst.kenjutsulevel) / 2) then mindregenfn(inst) end
	if inst.startregen then	inst.startregen:Cancel() inst.startregen = nil inst.startregen = inst:DoTaskInTime(TUNING.MEVILEYES.MINDREGENRATE, mindregen) end
end

local function kenjutsuupgrades(inst)
	if not TUNING.MEVILEYES.KENJUTSU then return end

	if inst.kenjutsulevel >= 2 then inst.unlockskill_1 = true 
	--health
	local current_health = inst.health_percent or inst.components.health:GetPercent()
    inst.health_percent = nil
	local maxhealth = math.ceil(TUNING.MEVILEYES_HEALTH + inst.kenjutsulevel * 10)
	
	inst.components.health:SetMaxHealth(maxhealth)
    inst.components.health:SetPercent(current_health)
	--
	end	
	
	if inst.kenjutsulevel >= 3 then 
		inst.unlockskill_2 = true		
	end	
	
	if inst.kenjutsulevel >= 4 then 
		inst.unlockskill_3 = true 
	end	
	
	if inst.kenjutsulevel >= 5 then 
		inst.unlockcombineskill_1 = true
		inst.criticalhit = true		
	end
	
	if inst.kenjutsulevel >= 6 then 
		inst.unlockdeathaura = true		
	end	
	
	if inst.kenjutsulevel >= 7 then 
		inst.unlockcombineskill_2 = true 
		if inst.startregen == nil then inst.startregen = inst:DoTaskInTime(TUNING.MEVILEYES.MINDREGENRATE, mindregen) end
	end
	
	if inst.kenjutsulevel >= 8 then inst.criplus = .25 end
	if inst.kenjutsulevel >= 10 then inst.kenjutsuexp = 0 end
					
	local fx = SpawnPrefab("fused_shadeling_spawn_fx")
			fx.entity:SetParent(inst.entity)	
end

local function kenjutsulevelup(inst)
	inst.kenjutsulevel = inst.kenjutsulevel + 1	
	kenjutsuupgrades(inst)
end

local hitcount = 0
local function Onattack(inst, data)	--Attack
if not inst.components.rider:IsRiding() then
	local target = data.target
	local equip = inst.components.inventory:GetEquippedItem(EQUIPSLOTS.HANDS)
	local skilltreeupdater = inst.components.skilltreeupdater ~= nil
	
	if equip ~= nil and (equip:HasTag("projectile") or equip:HasTag("rangedweapon") or equip:HasTag("magicweapon")) then return end
	if ( target:HasTag("structure")or target:HasTag("DECOR")or target:HasTag("wall") ) then return end
	
	if skilltreeupdater and inst.components.skilltreeupdater:IsActivated("mevileyes_allegiance_shadow") then --unlock by skill tree
		if equip ~= nil and equip.components.finiteuses ~= nil and inst.components.sanity ~= nil and inst.components.sanity:IsInsane() and  (equip:HasTag("shadow_item") or equip:HasTag("netra_item")) then 
			local current = equip.components.finiteuses:GetUses()
			local maxuses = equip.components.finiteuses.total
			if current < maxuses then equip.components.finiteuses:Repair(2) end
		end
	end
	
	if skilltreeupdater and inst.components.skilltreeupdater:IsActivated("mevileyes_allegiance_shadow") and inst._evilspeed_task  then --unlock by skill tree
		if equip ~= nil and (equip.prefab == "voidcloth_scythe")then
			if equip.DoShadowAoE ~= nil then equip:DoShadowAoE(inst, target) end  
		end				
	end		
	
--critical--------------------------------------------------------------------------------------------------------------------
	if inst.criticalhit and math.random(1,100) <= 5 and not inst.components.timer:TimerExists("mevileyes_cri_cd") then					
		inst.SoundEmitter:PlaySound("turnoftides/common/together/moon_glass/mine")
		inst:ShakeCamera(CAMERASHAKE.FULL, 0.2, 0.02, .5, inst, 20)
		
		inst.components.combat.externaldamagemultipliers:SetModifier(inst, 1.25 + (inst.criplus or 0), "evileyes_cri_atk")
		inst.components.timer:StartTimer("mevileyes_cri_atk_cd",.1)
		inst.components.timer:StartTimer("mevileyes_cri_cd",20)
		
	end		

--kenjutsulevel------------------------------------------------------------------------------------------------------------------------------------------
		if not inst.components.timer:TimerExists("mevileyes_HitCD") and not inst.sg:HasStateTag("skilling")  then 	--GainKenExp		
			if inst.kenjutsulevel < 10 then inst.kenjutsuexp = inst.kenjutsuexp + 1 + (inst.kenjutsurate or 0) + (inst.kenjutsufoodbuff or 0) end --1
			inst.components.timer:StartTimer("mevileyes_HitCD",.4)
			if inst.kenjutsuexp >= (TUNING.MEVILEYES.MAXEXP * inst.kenjutsulevel) then inst.kenjutsuexp = inst.kenjutsuexp - (TUNING.MEVILEYES.MAXEXP * inst.kenjutsulevel) kenjutsulevelup(inst) end --OnKenLevelUp
		end		
--kenjutsulevelend------------------------------------------------------------------------------------------------------------------------------------------
--mind count		
		if not inst.components.timer:TimerExists("mevileyes_HeartCD") and not inst.sg:HasStateTag("skilling") then inst.components.timer:StartTimer("mevileyes_HeartCD",.4)  --mind gain
			hitcount = hitcount + 1	
			if hitcount >= TUNING.MEVILEYES.MINDHITCOUNT then		
					if inst.mindpower < (TUNING.MEVILEYES.MAXMIND+inst.kenjutsulevel) then mindregenfn(inst) end
			hitcount = 0 end
		end	

--------------------------------------------------------------------------------------------------------------------	
end
end

local PLAYER_TAGS = { "player" }
local function sanityfn(inst)
    local sanity_cap = TUNING.DAPPERNESS_LARGE * 5  
    local sanity_per_ent = TUNING.DAPPERNESS_LARGE
    local max_rad = 8                            
	local normal = (TUNING.DAPPERNESS_MED_LARGE) * (inst.introvert or 1)
	local total_loss = 0
	
    local x, y, z = inst.Transform:GetWorldPosition()
    local ents = TheSim:FindEntities(x, y, z, max_rad, PLAYER_TAGS)
       
	if #ents > 1 then
		if inst.friendcount and #ents <= (1 + inst.friendcount)  then return normal end
		
		
		for _, v in ipairs(ents) do
			if v ~= inst then
				local dist_sq = inst:GetDistanceSqToInst(v)
				local dist = math.sqrt(dist_sq)
			
				local loss = sanity_per_ent * (1 - math.min(dist / max_rad, 1))
				total_loss = total_loss + loss
			end
		end
	
		total_loss = math.min(total_loss, sanity_cap)
		return - total_loss
	end

   return normal
end

local function hudcooldown(inst)
	 inst:DoPeriodicTask(0, function()
        local evilwave_Time = inst.components.timer ~= nil and (inst.components.timer:GetTimeLeft("mevileyes_evilwave") or 0) or nil
        local evilwarp_Time = inst.components.timer ~= nil and (inst.components.timer:GetTimeLeft("mevileyes_evilwarp") or 0) or nil
        local evilcurse_Time = inst.components.timer ~= nil and (inst.components.timer:GetTimeLeft("mevileyes_evilcurse") or 0) or nil
        local evilskillsp_Time = inst.components.timer ~= nil and (inst.components.timer:GetTimeLeft("mevileyes_cdskill_sp") or 0) or nil
		
		if evilwave_Time then inst._evilwave:set(evilwave_Time) end   
        if evilwarp_Time then inst._evilwarp:set(evilwarp_Time) end
        if evilcurse_Time then inst._evilcurse:set(evilcurse_Time) end
        if evilskillsp_Time then inst._evilskillsp:set(evilskillsp_Time) end
		
        local skill1_Time = inst.components.timer ~= nil and (inst.components.timer:GetTimeLeft("mevileyes_cdskill1") or 0) or nil
        local skill2_Time = inst.components.timer ~= nil and (inst.components.timer:GetTimeLeft("mevileyes_cdskill2") or 0) or nil
        local skill3_Time = inst.components.timer ~= nil and (inst.components.timer:GetTimeLeft("mevileyes_cdskill3") or 0) or nil
        local skill4_Time = inst.components.timer ~= nil and (inst.components.timer:GetTimeLeft("mevileyes_cdskill4") or 0) or nil
        local skill5_Time = inst.components.timer ~= nil and (inst.components.timer:GetTimeLeft("mevileyes_cdskill5") or 0) or nil
        local skill6_Time = inst.components.timer ~= nil and (inst.components.timer:GetTimeLeft("mevileyes_cdskill6") or 0) or nil
        local skill7_Time = inst.components.timer ~= nil and (inst.components.timer:GetTimeLeft("mevileyes_cdskill7") or 0) or nil                
		
        if skill1_Time then inst._skill1:set(skill1_Time) end  
        if skill2_Time then inst._skill2:set(skill2_Time) end        
        if skill3_Time then inst._skill3:set(skill3_Time) end
        if skill4_Time then inst._skill4:set(skill4_Time) end
        if skill5_Time then inst._skill5:set(skill5_Time) end
        if skill6_Time then inst._skill6:set(skill6_Time) end
        if skill7_Time then inst._skill7:set(skill7_Time) end
				
		if inst.mindpower then inst._mindpower:set(inst.mindpower) end				
		if inst.kenjutsulevel then inst._kenjutsulevel:set(inst.kenjutsulevel) end		
		if inst.kenjutsuexp then inst._kenjutsuexp:set(inst.kenjutsuexp) end
		
    end)      
end
local function onbecamehuman(inst)
	if inst.components.timer:TimerExists("mevileyes_evilcurse") then
		inst.components.timer:StopTimer("mevileyes_evilcurse")
	end
	inst.components.timer:StartTimer("mevileyes_evilcurse", TUNING.TOTAL_DAY_TIME)
	inst.mindpower = 0
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

local function OnPreLoad(inst, data)
	if data then
		if data.health_percent then inst.health_percent = data.health_percent end
		if data.mindpower ~= nil then inst.mindpower = data.mindpower end
		if data.kenjutsulevel ~= nil then inst.kenjutsulevel = data.kenjutsulevel end
		if data.kenjutsuexp ~= nil then inst.kenjutsuexp = data.kenjutsuexp end
	end
	kenjutsuupgrades(inst)	
end

local function onsave(inst, data) 
	data.health_percent = inst.health_percent or inst.components.health:GetPercent()
	data.mindpower = inst.mindpower
	data.kenjutsulevel = inst.kenjutsulevel
	data.kenjutsuexp = inst.kenjutsuexp
end

local function onload(inst, data)
	if not inst:HasTag("playerghost") and inst.components.timer and inst.components.timer:TimerExists("mevileyes_atk_buff") then	inst.evilwavebufffx = inst:DoTaskInTime(1, function()  Black_elecfx(inst) end) end

    OnSkinsChanged(inst, {nofx = true})
end

local function OnChangeChar(inst)
	ForceDespawnShadowMinions(inst)
	disableallskill(inst)
	skillfxremove(inst)
	if inst.kenjutsulevel > 1 then
		local x, y, z = inst.Transform:GetWorldPosition()        
		local fruit = SpawnPrefab("mevileyesfruit")
			fruit.Transform:SetPosition(x, y, z)			
			fruit._kenjutsulevel = inst.kenjutsulevel
			fruit._kenjutsuexp =  inst.kenjutsuexp
			inst.components.inventory:GiveItem(fruit)
	end
end

local function OnEat(inst, food)
    if food ~= nil and food.components.edible ~= nil then
        if food.prefab == "icecream" then
			inst.kenjutsufoodbuff = 1
			inst.components.timer:StopTimer("kenjutsufoodbuff")
			inst.components.timer:StartTimer("kenjutsufoodbuff",300)
		end
		
        if food.prefab == "mevileyesfruit" then
			if food._kenjutsulevel and food._kenjutsulevel > inst.kenjutsulevel then			 
				inst.kenjutsulevel = food._kenjutsulevel			
			end			
			if food._kenjutsuexp and food._kenjutsuexp > inst.kenjutsuexp then
				inst.kenjutsuexp = food._kenjutsuexp 
			end
			kenjutsuupgrades(inst)
        end
    end   
end

local function CustomCombatDamage(inst, target, weapon, multiplier, mount)   
	if inst.components.timer:TimerExists("mevileyes_atk_buff") then		
	   return 1.25 + (inst.kenjutsulevel/100)
    end	 
end

local common_postinit = function(inst) 
	-- Minimap icon	
	inst.MiniMapEntity:SetIcon( "mevileyes.tex" )
	
	if TUNING.MEVILEYES.ITEM then	
	inst:AddTag("mevileyescraft")
	end

	--warly
	if TUNING.MEVILEYES.WARLY then
	inst:AddTag("masterchef")
	inst:AddTag("professionalchef")
	end
	
	inst:AddComponent("raindome")
	------------------------------------------------------------------------------------
	--Key
	if TUNING.MEVILEYES.KENJUTSU then
	inst:AddComponent("keyhandler")
	inst.components.keyhandler:AddActionListener("mevileyes", TUNING.MEVILEYES.KEYSQUICKSHEATH, "mevileyes_sheath")
	inst.components.keyhandler:AddActionListener("mevileyes", TUNING.MEVILEYES.KEYSKILL1, "mevileyes_skill1")
	inst.components.keyhandler:AddActionListener("mevileyes", TUNING.MEVILEYES.KEYSKILL2, "mevileyes_skill2")
	inst.components.keyhandler:AddActionListener("mevileyes", TUNING.MEVILEYES.KEYSKILL3, "mevileyes_skill3")
	inst.components.keyhandler:AddActionListener("mevileyes", TUNING.MEVILEYES.EVILWAVE, "mevileyes_evilwave")
	
	inst._evilwave = net_shortint(inst.GUID, "inst._evilwave", "inst._evilwave")
    inst._evilwarp = net_shortint(inst.GUID, "inst._evilwarp", "inst._evilwarp")
    inst._evilcurse = net_shortint(inst.GUID, "inst._evilcurse", "inst._evilcurse")
    inst._evilskillsp = net_shortint(inst.GUID, "inst._evilskillsp", "inst._evilskillsp")
	
    inst._skill1 = net_shortint(inst.GUID, "inst._skill1", "inst._skill1")
    inst._skill2 = net_shortint(inst.GUID, "inst._skill2", "inst._skill2")
    inst._skill3 = net_shortint(inst.GUID, "inst._skill3", "inst._skill3")
    inst._skill4 = net_shortint(inst.GUID, "inst._skill4", "inst._skill4")
    inst._skill5 = net_shortint(inst.GUID, "inst._skill5", "inst._skill5")
    inst._skill6 = net_shortint(inst.GUID, "inst._skill6", "inst._skill6")
    inst._skill7 = net_shortint(inst.GUID, "inst._skill7", "inst._skill7")
	
    inst._mindpower = net_shortint(inst.GUID, "inst._mindpower", "inst._mindpower")
    inst._kenjutsulevel = net_shortint(inst.GUID, "inst._kenjutsulevel", "inst._kenjutsulevel")
    inst._kenjutsuexp = net_shortint(inst.GUID, "inst._kenjutsuexp", "inst._kenjutsuexp")
   	end
end

local master_postinit = function(inst)	
	inst.starting_inventory = start_inv[TheNet:GetServerGameMode()] or start_inv.default
		
	inst.oldrange = inst.components.combat.hitrange
	inst.mindpower = 0
	inst.kenjutsulevel = 1
	inst.kenjutsuexp = 0
		
	inst.katanauser = true
	inst.refusestobowtoroyalty = true --not bow for bee hat
	
	if TUNING.MEVILEYES.STARTLEVEL then inst:DoTaskInTime(1, function()	if inst.kenjutsulevel < TUNING.MEVILEYES.STARTLEVEL then inst.kenjutsulevel = TUNING.MEVILEYES.STARTLEVEL kenjutsuupgrades(inst)end end) end
	
	inst.soundsname = "wortox"	
	inst.AnimState:SetScale(0.95, 0.95, 1)

	inst.components.raindome:SetRadius(TUNING.VOIDCLOTH_UMBRELLA_DOME_RADIUS)-- skilldome
	--waxwell
    if inst.components.petleash ~= nil then
        inst._OnSpawnPet = inst.components.petleash.onspawnfn
        inst._OnDespawnPet = inst.components.petleash.ondespawnfn
		inst.components.petleash:SetMaxPets(inst.components.petleash:GetMaxPets() + 2)
    else
        inst:AddComponent("petleash")
		inst.components.petleash:SetMaxPets(2)
    end
    inst.components.petleash:SetOnSpawnFn(OnSpawnPet)
    inst.components.petleash:SetOnDespawnFn(OnDespawnPet)
    inst:ListenForEvent("onskinschanged", OnSkinsChanged) -- Fashion Shadows.
	--	
	--wes
	inst.components.temperature.inherentinsulation = -TUNING.INSULATION_TINY   --fast freeze   	
	inst.components.grogginess.decayrate = TUNING.WES_GROGGINESS_DECAY_RATE
	
	inst.components.workmultiplier:AddMultiplier(ACTIONS.CHOP,   TUNING.WES_WORKEFFECTIVENESS_MODIFIER, inst)
	inst.components.workmultiplier:AddMultiplier(ACTIONS.MINE,   TUNING.WES_WORKEFFECTIVENESS_MODIFIER, inst)
	inst.components.workmultiplier:AddMultiplier(ACTIONS.HAMMER, TUNING.WES_WORKEFFECTIVENESS_MODIFIER, inst)
	
	if inst.components.efficientuser == nil then
		inst:AddComponent("efficientuser")
	end
	
	inst.components.efficientuser:AddMultiplier(ACTIONS.CHOP,   TUNING.WES_WORKEFFECTIVENESS_MODIFIER, inst)
	inst.components.efficientuser:AddMultiplier(ACTIONS.MINE,   TUNING.WES_WORKEFFECTIVENESS_MODIFIER, inst)
	inst.components.efficientuser:AddMultiplier(ACTIONS.HAMMER, TUNING.WES_WORKEFFECTIVENESS_MODIFIER, inst)
	inst.components.efficientuser:AddMultiplier(ACTIONS.ATTACK, TUNING.WES_DAMAGE_MULT, inst)
	--
	
	-- food	
	inst.components.foodaffinity:AddPrefabAffinity("icecream", TUNING.AFFINITY_15_CALORIES_MED)		
	if inst.components.eater ~= nil then
		local eater = inst.components.eater
		eater.stale_hunger = TUNING.WICKERBOTTOM_STALE_FOOD_HUNGER
        eater.stale_health = TUNING.WICKERBOTTOM_STALE_FOOD_HEALTH
        eater:SetRefusesSpoiledFood(true)
		
		table.insert(eater.preferseating, FOODTYPE.EVILEYESMEMO)
		table.insert(eater.caneat, FOODTYPE.EVILEYESMEMO)
		eater.inst:AddTag(FOODTYPE.EVILEYESMEMO.."_eater")
		
		local _TestFood = eater.TestFood
		eater.TestFood = function(self, food, testvalues)			
			if food and food.components.edible and food.components.edible.foodtype == FOODTYPE.EVILEYESMEMO then
				return food.prefab == "mevileyesfruit"
			end
			return _TestFood(self, food, testvalues)
		end		
		eater:SetOnEatFn(OnEat)		
	end
	
	--inst:AddComponent("foodmemory")
    --inst.components.foodmemory:SetDuration(TUNING.MEVILEYES.FOOD_TIMES)
    --inst.components.foodmemory:SetMultipliers(TUNING.MEVILEYES.FOOD_MULTIPLIERS)

	-- Stats	
	inst.components.health:SetMaxHealth(TUNING.MEVILEYES_HEALTH)
    inst.components.hunger:SetMax(TUNING.MEVILEYES_HUNGER)	
    inst.components.sanity:SetMax(TUNING.MEVILEYES_SANITY)		
	inst.components.sanity.get_equippable_dappernessfn = GetEquippableDapperness
	inst.components.sanity.custom_rate_fn = sanityfn
	
	-- Damage multiplier (optional)	
    inst.components.combat.damagemultiplier = 1
	inst.components.combat.customdamagemultfn = CustomCombatDamage	
	
	-- Hunger rate (optional)
	inst.components.hunger.hungerrate = TUNING.WILSON_HUNGER_RATE * 1.1
	
	if inst.components.timer == nil then inst:AddComponent("timer")end
	
----------------------------------------------------------------------------------------------------------------
	--waxwell
	inst._onpetlost = function(pet) inst.components.sanity:RemoveSanityPenalty(pet) end

    inst:ListenForEvent("death", OnDeath)
	inst:ListenForEvent("ms_becameghost", OnBecameGhost)

----------------------------------------------------------------------------------------------------------------
	inst.OnDespawn = OnDespawn
	inst.OnPreLoad = OnPreLoad
	inst.OnLoad = onload
	inst.OnSave = onsave	
	inst:ListenForEvent("timerdone", OnTimerDone)	
	inst:ListenForEvent("onattackother", Onattack)
	
	if TUNING.MEVILEYES.KENJUTSU then
		inst:DoTaskInTime(1, function()	hudcooldown(inst) end)
	end
--Reset Skill
	inst:ListenForEvent("mounted", disableallskill)	
	inst:ListenForEvent("ms_playerreroll", OnChangeChar)
	
	inst:ListenForEvent("ms_respawnedfromghost", onbecamehuman) 
	inst:ListenForEvent("equip", OnEquip)
	inst:ListenForEvent("unequip", OnUnEquip)
	
	inst:ListenForEvent("resistedgrue", OnResisqueen)
	
	inst._whisper = SpawnPrefab("mevileyes_whisper2")
    inst._whisper.entity:SetParent(inst.entity)
    inst._whisper.Transform:SetPosition(0, 3.5, 0)
    
	
--NoDMG---------------
	inst._GetAttacked = inst.components.combat.GetAttacked		
	inst.components.combat.GetAttacked = function(attacker, damage, weapon, stimuli)			
		
		if inst.components.timer:TimerExists("mevileyes_evildodge") or inst.sg:HasStateTag("skillimue") then	--dodge ability
			local fx = SpawnPrefab("shadow_merm_smacked_poof_fx")
			fx.entity:SetParent(inst.entity)
			
		else inst._GetAttacked(attacker, damage, weapon, stimuli)end	
	end	
--NoDMG------------

end
return MakePlayerCharacter("mevileyes", prefabs, assets, common_postinit, master_postinit, start_inv)