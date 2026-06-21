local assets =
{
    Asset("ANIM", "anim/sdf_jack_of_the_green_riddle_moleworm.zip"),
    Asset("SOUND", "sound/mole.fsb"),
}

-- make him pop up periodically

local prefabs ={
}

local brain = require("brains/sdf_jack_of_the_green_riddle_molewormbrain")

local MUST_HAVE_TAGS = {"sdf_riddle_3_koalefant"}
local CANT_HAVE_TAGS = {"player", "playerghost", "INLIMBO", "companion", "ghost"}
local AOE_RADIUS = 3.5

local function aoeKoalefantCheck(inst)
    local tx, ty, tz = inst.Transform:GetWorldPosition()

    local affected_entity = TheSim:FindEntities(tx, ty, tz, AOE_RADIUS, MUST_HAVE_TAGS, CANT_HAVE_TAGS)
    for i, v in ipairs(affected_entity) do

	--find koalefant
	if v ~= nil then
	    v:KoalefantStomp()
	end
    end
end

local function scarekoalefant(inst)
    --find koalefant
    aoeKoalefantCheck(inst)
end

local function decayFX(inst)
    inst.components.health:DoDelta(-(TUNING.SDF_JACK_OF_THE_GREEN_RIDDLE_MOLEWORM_DECAY_RATE), true, "decay")
    inst.decaytask = inst:DoTaskInTime(TUNING.SDF_JACK_OF_THE_GREEN_RIDDLE_MOLEWORM_DECAY_RATE, decayFX)
end

local function startdecay(inst)
    inst.decaytask = inst:DoTaskInTime(TUNING.SDF_JACK_OF_THE_GREEN_RIDDLE_MOLEWORM_DECAY_RATE, decayFX)
end


local function SetUnderPhysics(inst)
    if inst.isunder ~= true then
        inst.isunder = true
	inst:AddTag("notdrawable")
        inst.Physics:SetCollisionGroup(COLLISION.CHARACTERS)
        inst.Physics:ClearCollisionMask()
        inst.Physics:CollidesWith(COLLISION.WORLD)
        inst.Physics:CollidesWith(COLLISION.OBSTACLES)
    end
end

local function SetAbovePhysics(inst)
    if inst.isunder ~= false then
        inst.isunder = false
  	inst:RemoveTag("notdrawable")
        ChangeToCharacterPhysics(inst)
    end
end

local function displaynamefn(inst)
    return inst:HasTag("noattack") and not inst:HasTag("INLIMBO") 
	and STRINGS.ANNOUNCE_SDF_JACK_OF_THE_GREEN_RIDDLE_MOLEWORM_MOVING --"Creeping Brush"
        or STRINGS.NAMES.SDF_JACK_OF_THE_GREEN_RIDDLE_MOLEWORM --"Moleworm Hedge"
end

local function getstatus(inst)
    return (inst.components.inventoryitem ~= nil and inst.components.inventoryitem:IsHeld() and "HELD")
        or (inst.isunder and "UNDERGROUND")
        or "ABOVEGROUND"
end

local function OnRemove(inst)
    if inst.decaytask ~= nil then
	inst.decaytask:Cancel()
    end

    inst.SoundEmitter:KillAllSounds()
end

local function fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()
    inst.entity:AddNetwork()

    inst.Transform:SetFourFaced()
    inst.Transform:SetScale(0.6, 0.6, 0.6)

    MakeCharacterPhysics(inst, 99999, 0.2)
    SetUnderPhysics(inst)

    inst.AnimState:SetBank("mole")
    inst.AnimState:SetBuild("sdf_jack_of_the_green_riddle_moleworm")
    inst.AnimState:PlayAnimation("idle_under")

    inst:AddTag("sdf_riddle_3_moleworm")
    inst:AddTag("animal")
    inst:AddTag("prey")
    inst:AddTag("mole")
    inst:AddTag("smallcreature")
    inst:AddTag("baitstealer")
    inst:AddTag("cattoy")
    inst:AddTag("catfood")
    inst:AddTag("whackable")
    inst:AddTag("stunnedbybomb")
    inst:AddTag("character")

    --inst.scrapbook_specialinfo = "MOLE"

    MakeFeedableSmallLivestockPristine(inst)

    inst.displaynamefn = displaynamefn

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        inst.isunder = nil --this flag is not valid on clients

        return inst
    end

    inst:AddComponent("locomotor")
    inst.components.locomotor.walkspeed = 2.75
    inst.components.locomotor:SetSlowMultiplier(1)
    inst.components.locomotor:SetTriggersCreep(false)
    inst.components.locomotor.pathcaps = {ignorecreep = true,}

    inst:SetStateGraph("SGsdf_jack_of_the_green_riddle_moleworm")
    inst:SetBrain(brain)

    inst:AddComponent("health")
    inst.components.health:SetMaxHealth(TUNING.SDF_JACK_OF_THE_GREEN_RIDDLE_MOLEWORM_HEALTH)
    inst.components.health.murdersound = "dontstarve_DLC001/creatures/mole/death"
    inst.components.health.fire_damage_scale = 0

    inst:AddComponent("combat")

    inst:AddComponent("lootdropper")
    inst.components.lootdropper:SetLoot({"cutgrass"})
    inst.components.lootdropper.trappable = false

    inst:AddComponent("inventory")
    inst.components.inventory.maxslots = 3

    inst:AddComponent("knownlocations")
    inst.last_above_time = 0
    inst.make_home_delay = math.random(5,10)
    inst.peek_interval = math.random(15,25)

    inst:AddComponent("inspectable")
    inst.components.inspectable.getstatus = getstatus

    inst.SetUnderPhysics = SetUnderPhysics
    inst.SetAbovePhysics = SetAbovePhysics

    MakeSmallBurnable(inst)

    inst.OnRemoveEntity = OnRemove
    inst:ListenForEvent("enterlimbo", OnRemove)

    AddHauntableCustomReaction(inst, function(inst, haunter)
        if math.random() < TUNING.HAUNT_CHANCE_OFTEN then
            local action = BufferedAction(inst, nil, ACTIONS.MOLEPEEK)
            inst.components.locomotor:PushAction(action, true)
            return true
        end
        return false
    end, nil, true, true)

    inst.ScareKoalefant = function() scarekoalefant(inst) end

    inst.decaytask = nil
    inst.decaytask = inst:DoTaskInTime(0, startdecay)

    return inst
end

return Prefab("sdf_jack_of_the_green_riddle_moleworm", fn, assets, prefabs)
