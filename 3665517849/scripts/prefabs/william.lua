local MakePlayerCharacter = require("prefabs/player_common")
local easing = require("easing")


local assets = {
    Asset("SCRIPT", "scripts/prefabs/player_common.lua"),
	Asset("ANIM", "anim/william.zip"),


}
local prefabs = {}

local start_inv =
{
    default =
    {
        "williamgadget",
    },
}

for k, v in pairs(TUNING.GAMEMODE_STARTING_ITEMS) do
    start_inv[string.lower(k)] = v.WILLIAM
end

prefabs = FlattenTree({ prefabs, start_inv }, true)

local function onsanitychange(inst)
	inst:DoTaskInTime(0, function()
    if not (inst.sg:HasStateTag("nomorph") or
        inst:HasTag("playerghost") or
        inst.components.health:IsDead()) then
    inst.components.sanity.dapperness = (TUNING.DAPPERNESS_HUGE)*(inst.components.sanity:GetPercent()-0.5)
	if inst.components.sanity:GetPercent() <= .44 then
	if inst.hassanity ~= "none" then
	inst.hassanity = "none"
    inst.components.skinner:SetSkinMode("mighty_skin", "william_insane")
	end
	elseif inst.components.sanity:GetPercent() <= .53 then
	if inst.hassanity ~= "some" then
	inst.hassanity = "some"
    inst.components.skinner:SetSkinMode("wimpy_skin", "william_scuff")
	end
	else
	if inst.hassanity ~= "plenty" then
	inst.hassanity = "plenty"
    inst.components.skinner:SetSkinMode("normal_skin", "william")
	end
	end
    end
	end)
    end

local function onnewstate(inst)
    if inst._wasnomorph ~= inst.sg:HasStateTag("nomorph") then
        inst._wasnomorph = not inst._wasnomorph
        if not inst._wasnomorph then
            onsanitychange(inst)
        end
    end
end

local function onbecamehuman(inst, data)
    if inst._wasnomorph == nil then
        if not (data ~= nil and data.corpse) then
            inst.hassanity = nil
        end
        inst._wasnomorph = inst.sg:HasStateTag("nomorph")
        inst:ListenForEvent("newstate", onnewstate)
        inst:ListenForEvent("sanitydelta", onsanitychange)
       -- onsanitychange(inst, true)
    end
end

local function onbecameghost(inst, data)
    if inst._wasnomorph ~= nil then
        if not (data ~= nil and data.corpse) then
            inst.hassanity = "none"
        end
        inst._wasnomorph = nil
        inst:RemoveEventCallback("sanitydelta", onsanitychange)
        inst:RemoveEventCallback("newstate", onnewstate)
    end
end

local function onload(inst)
    inst:ListenForEvent("ms_respawnedfromghost", onbecamehuman)
    inst:ListenForEvent("ms_becameghost", onbecameghost)

    if inst:HasTag("playerghost") then
        onbecameghost(inst)
    elseif inst:HasTag("corpse") then
        onbecameghost(inst, { corpse = true })
    else
        onbecamehuman(inst)
    end
end

local function OnDeath(inst)
    for k, v in pairs(inst.components.petleash:GetPets()) do
        if v:HasTag("willminion") then
            v:DoTaskInTime(math.random(), function() v.sg:GoToState("powerdown") end)
        end
    end
end

local function DoEffects(pet)
    local x, y, z = pet.Transform:GetWorldPosition()
    SpawnPrefab("small_puff").Transform:SetPosition(x, y, z)

end

local function KillPet(pet)
    pet.components.health:Kill()
end

local function OnSpawnPet(inst, pet)
    if pet:HasTag("willminion") then
    elseif inst._OnSpawnPet ~= nil then
        inst:_OnSpawnPet(pet)
    end
    inst:ListenForEvent("onremove", inst._onpetlost, pet)
end

local function OnDespawnPet(inst, pet)
    if pet:HasTag("willminion") then
        pet:Remove()
    elseif inst._OnDespawnPet ~= nil then
        inst:_OnDespawnPet(pet)
    end
end


-- Stats and stuff!  ------------------------------

local common_postinit = function(inst) 

	inst.MiniMapEntity:SetIcon( "william.tex" )

	inst:AddTag("william")
	inst:AddTag("williamcrafter")
	inst:AddTag("chessfriend")
    inst.foleysound = "dontstarve/movement/walk_marble_small"

end


local master_postinit = function(inst)
    inst.starting_inventory = start_inv[TheNet:GetServerGameMode()] or start_inv.default
	inst.soundsname = "william"

    inst.components.foodaffinity:AddPrefabAffinity("mashedpotatoes", TUNING.AFFINITY_15_CALORIES_HUGE)

--  Don't mind me, just jumping on the custom idle bandwagon
    inst.customidleanim = "emote_feet"

    inst._wasnomorph = nil
	inst.hassanity = nil
        inst.components.health:SetMaxHealth(TUNING.WILLIAM_HEALTH)
	inst.components.hunger:SetMax(TUNING.WILLIAM_HUNGER)
	inst.components.sanity:SetMax(TUNING.WILLIAM_SANITY)
	inst.components.combat.damagemultiplier = TUNING.WILLIAM_DAMAGE

    if inst.components.petleash ~= nil then
        inst._OnSpawnPet = inst.components.petleash.onspawnfn
        inst._OnDespawnPet = inst.components.petleash.ondespawnfn
        inst.components.petleash:SetMaxPets(99)
    else
        inst:AddComponent("petleash")
        inst.components.petleash:SetMaxPets(99)
    end
    inst.components.petleash:SetOnSpawnFn(OnSpawnPet)
    inst.components.petleash:SetOnDespawnFn(OnDespawnPet)

    inst._onpetlost = function(pet)
        if pet:HasTag("willminion") then
        end
    end

    inst:ListenForEvent("death", OnDeath)
        inst.OnLoad = onload
        inst.OnNewSpawn = onload



end

return MakePlayerCharacter("william", prefabs, assets, common_postinit, master_postinit, start_inv)
