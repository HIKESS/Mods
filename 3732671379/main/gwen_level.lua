local ThePlayer = GLOBAL.ThePlayer
local TheInput = GLOBAL.TheInput
local SpawnPrefab = GLOBAL.SpawnPrefab

GLOBAL.setmetatable(env,{__index=function(t,k) return GLOBAL.rawget(GLOBAL,k) end})

----[]----[]----[]----[]----[]----[]----[]----[]----[]----[]----[]----[]----[]----[]----[]----
----击杀经验-----------------------------------------------------------------------------------
local IsServer = TheNet:GetIsServer() or TheNet:IsDedicated()

----记录攻击者
local function Attack_Record(inst,data)
    local attacker = data and data.attacker
	local leader = attacker and attacker.components.follower and attacker.components.follower:GetLeader()
	if (attacker and attacker:HasTag("player")) or (leader and leader:HasTag("player")) then
		inst.gw_Attack_Record[attacker.userid or leader.userid] = true
	end
end

----被攻击
local function gw_OnAttacked(inst, data)
    Attack_Record(inst,data)
end

----死亡
local function gw_OnDead(inst,data)
	Attack_Record(inst,data)
	for ID, data in pairs(inst.gw_Attack_Record) do
		for i, player in ipairs(AllPlayers) do
            if player.userid == ID then 
				player:PushEvent("gw_killed", { victim = inst, attacker = player })
            end
        end
    end
end


local function Gwen_UpGrade(inst)
	if not IsServer then
		return inst
	end

	inst.gw_Attack_Record = {}

    inst:ListenForEvent("attacked", gw_OnAttacked)
    inst:ListenForEvent("death", gw_OnDead)

	return inst
end

AddPrefabPostInitAny(function(inst)
	if not IsServer then
		return inst
	end

	if not inst:HasTag("player") and inst.components.health ~= nil and not inst.components.health:IsDead() and inst.components.health.currenthealth ~= 0 then
		if not inst:HasTag("wall") and not inst:HasTag("boat") then
			Gwen_UpGrade(inst)
		end
	end
end)

----获得经验
----经验获取
local function gw_Up_Level(inst, data)
	local victim = data and data.victim
	if victim and victim.components.health ~= nil and not victim:HasTag("wall") then
		local TargetMaxHp = victim and victim.components.health and victim.components.health.maxhealth
		local victimnum = (victim and victim.components and victim.components.stackable and victim.components.stackable:StackSize()) or 1
		local gw_Exp
		if victim:HasTag("epic") then
			gw_Exp = math.min((math.floor(TargetMaxHp/100) or 0), 600)
		else
			gw_Exp = math.min((math.floor(TargetMaxHp/100) or 0), 60)
		end

		if inst:HasTag("zhandoukin") then
			gw_Exp = math.floor(gw_Exp * 1.2)
		end

		if inst:HasTag("zhandoukin2") then
			gw_Exp = math.floor(gw_Exp * 1.4)
		end

		local backpack = nil
		if inst.components.inventory then
			local equipslots = inst.components.inventory.equipslots
			if equipslots then
				local back_slot = equipslots[EQUIPSLOTS.BACK]
				if back_slot and back_slot:HasTag("gw_backpack") then
					backpack = back_slot
				else
					local body_slot = equipslots[EQUIPSLOTS.BODY]
					if body_slot and body_slot:HasTag("gw_backpack") then
						backpack = body_slot
					end
				end
			end
		end

		if backpack and backpack.components.container then
			local guajian = backpack.components.container:GetItemInSlot(17)
			if guajian then
				if guajian.prefab == "gw_gj_zhihui1"  then
					gw_Exp = math.floor(gw_Exp * 1.25)
				elseif guajian.prefab == "gw_gj_zhihui2" then
					gw_Exp = math.floor(gw_Exp * 1.5)
				elseif guajian.prefab == "gw_gj_zhihui3" then
					gw_Exp = math.floor(gw_Exp * 2.0)
				end
			end
		end
		
		if inst.prefab ~= nil and inst.prefab == "gwen"
		and inst.components.gwen_competence
		and inst:HasTag("player") and inst.components.health and not inst.components.health:IsDead() and not inst:HasTag("playerghost")
		then
			inst.components.gwen_competence:Incr_gwen_Exp(gw_Exp)
		end
	end
end

----记录攻击
local function gw_Up_Exp(inst, data)
	local target = data and data.target
	if inst.prefab ~= nil and inst.prefab == "gwen"
	and inst.components.gwen_competence
	and inst:HasTag("player") and inst.components.health and not inst.components.health:IsDead() and not inst:HasTag("playerghost")
	then
		if target ~= nil and target.components.combat and target.components.combat ~= nil then
			if inst and target.gw_Attack_Record ~= nil then
				target.gw_Attack_Record[inst.userid] = true
			end
		end
	end
end

AddPlayerPostInit(function(inst)
	inst:ListenForEvent("gw_killed", gw_Up_Level)----经验获取
	inst:ListenForEvent("onattackother", gw_Up_Exp)----记录攻击
end)