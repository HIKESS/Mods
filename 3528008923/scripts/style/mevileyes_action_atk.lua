	--------------------------------------------WILSON SG ACTIONHANDLER FOR ATTACK OVERRIDE---------------------------------------------------------------------------
require = GLOBAL.require

RECIPETABS = GLOBAL.RECIPETABS
Recipe = GLOBAL.Recipe
GIngredient = GLOBAL.Ingredient
TECH = GLOBAL.TECH

FRAMES = GLOBAL.FRAMES
ACTIONS = GLOBAL.ACTIONS
State = GLOBAL.State
EventHandler = GLOBAL.EventHandler
ActionHandler = GLOBAL.ActionHandler
TimeEvent = GLOBAL.TimeEvent

EQUIPSLOTS = GLOBAL.EQUIPSLOTS

local originalAttack
local originalClientAttack

local SGWilson = require "stategraphs/SGwilson"
local SGWilsonClient = require "stategraphs/SGwilson_client"

for k1, v1 in pairs(SGWilson.actionhandlers) do
	if SGWilson.actionhandlers[k1]["action"]["id"] == "ATTACK" then originalAttack = SGWilson.actionhandlers[k1]["deststate"] end
end

for k1, v1 in pairs(SGWilsonClient.actionhandlers) do
	if SGWilsonClient.actionhandlers[k1]["action"]["id"] == "ATTACK" then originalClientAttack = SGWilsonClient.actionhandlers[k1]["deststate"] end 
end

local function MevileyesAttack(inst, action) 
	inst.sg.mem.localchainattack = not action.forced or nil
	local weapon = inst.components.inventory:GetEquippedItem(EQUIPSLOTS.HANDS) or nil 
		if weapon and weapon:HasTag("mtachi") and not inst.components.health:IsDead() and not inst.sg:HasStateTag("attack") and inst.components.combat ~= nil then
			return "mtachi"
		elseif weapon and weapon:HasTag("miai") and not inst.components.health:IsDead() and not inst.sg:HasStateTag("attack") and inst.components.combat ~= nil then
			return "miai"		
		else
			return originalAttack(inst, action)
		end
end

local function ClientMevileyesAttack(inst, action)
	local weapon = inst.replica.inventory:GetEquippedItem(EQUIPSLOTS.HANDS) or nil
		if weapon and weapon:HasTag("mtachi") and not inst.sg:HasStateTag("attack") and inst.replica.combat then
			return "mtachi"
		elseif weapon and weapon:HasTag("miai") and not inst.sg:HasStateTag("attack") and inst.replica.combat then
			return "miai"		
		else
			return originalClientAttack(inst, action)
		end
end

AddStategraphActionHandler("wilson", ActionHandler(GLOBAL.ACTIONS.ATTACK,MevileyesAttack))
GLOBAL.package.loaded["stategraphs/SGwilson"] = nil

AddStategraphActionHandler("wilson_client", ActionHandler(GLOBAL.ACTIONS.ATTACK,ClientMevileyesAttack))
GLOBAL.package.loaded["stategraphs/SGwilson_client"] = nil


