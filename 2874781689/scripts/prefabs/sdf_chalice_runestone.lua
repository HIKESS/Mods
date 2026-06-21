local assets=
{
    Asset("ATLAS", "images/map_icons/sdf_chalice_runestone_mm.xml"),
    Asset("IMAGE", "images/map_icons/sdf_chalice_runestone_mm.tex"),

    Asset("ANIM", "anim/sdf_chalice_runestone.zip"),
}

prefabs = {
}

local sdf_chalice_runestone_chaliceloot ={
{"IQ","sdf_crossbow","sdf_standard_bolts",TUNING.SDF_STANDARD_BOLTS_MAXSTACKCOUNT}, {"IO","sdf_lifebottle",1}, {"I","sdf_hammer"}, {"I","sdf_silver_shield"}, 
{"IE","sdf_broad_sword", "sdf_enchanted_sword"}, {"C",{"goldnugget","goldnugget","goldnugget","goldnugget"}}, {"IQ","sdf_longbow","sdf_standard_arrows",TUNING.SDF_STANDARD_ARROWS_MAXSTACKCOUNT}, 
{"IO","sdf_spear",TUNING.SDF_SPEAR_MAXSTACKCOUNT}, {"I","sdf_axe"}, {"IQ","sdf_flaming_longbow","sdf_flaming_arrows",TUNING.SDF_FLAMING_ARROWS_MAXSTACKCOUNT},
{"IO","sdf_gold_shield",1}, {"C",{"goldnugget","goldnugget","goldnugget","goldnugget","goldnugget","goldnugget"}}, {"I","sdf_magic_sword"},
{"IQ","sdf_magic_longbow","sdf_magical_arrows",TUNING.SDF_MAGICAL_ARROWS_MAXSTACKCOUNT}, {"IQ","sdf_lightning_gauntlet","sdf_lightning",1}, {"IO","sdf_lifebottle", 1}, 
{"IO","sdf_energyvial",2}, {"C",{"goldnugget","goldnugget","goldnugget","goldnugget","goldnugget","goldnugget","goldnugget","goldnugget","goldnugget","goldnugget"}},
{"IO","sdf_energyvial",3}, {"IO","sdf_lifebottle",1}
}
--I-Item, IE-Item Enchanted, IQ-Item Quiver, IO-Item Only, C-Chest, 
--{"crossbow","lifebottle1-ItemOnly","hammer","slivershield","broadsword","gold4-Chest","longbow","spear","axe","flamingbow",
--"gold shield-ItemOnly","gold6-Chest","magicsword","magiclongbow","lightning","lifebottle2-ItemOnly","engeryvial2-ItemOnly","gold10-Chest","engeryvial3-ItemOnly","lifebottle3-ItemOnly"}

local sdf_chalice_runestone_chaliceloot_bonus ={
{"goldnugget","goldnugget","goldnugget","goldnugget","goldnugget","goldnugget","goldnugget","goldnugget","goldnugget","goldnugget"},
{"goldnugget","goldnugget","goldnugget","goldnugget", "sdf_chicken_drumstick"},
{"goldnugget","goldnugget","goldnugget","goldnugget", "sdf_energyvial"},
{"goldnugget","goldnugget","sdf_chicken_drumstick", "sdf_chicken_drumstick"},
{"goldnugget","goldnugget","sdf_energyvial", "sdf_energyvial"},
{"goldnugget","goldnugget","sdf_chicken_drumstick", "sdf_energyvial"},
{"sdf_chicken_drumstick","sdf_chicken_drumstick", "sdf_chicken_drumstick"},
{"sdf_energyvial","sdf_energyvial", "sdf_energyvial"},
{"sdf_chicken_drumstick","sdf_chicken_drumstick", "sdf_energyvial"},
{"sdf_chicken_drumstick","sdf_energyvial", "sdf_energyvial"}
} --gold,chickendrumstick,energyvials


local RUNESTONE_ACTIVATE = false --Use for chalice animation
local RUNESTONE_REWARDREADY = false --Use for chalice exchange

local function runestoneturnoff(inst)
    if inst.RUNESTONE_REWARDREADY == true then
	inst.RUNESTONE_REWARDREADY = false
    end

    if inst.RUNESTONE_ACTIVATE == true then
	inst.RUNESTONE_ACTIVATE = false
    	local x,_,z = inst.Transform:GetWorldPosition()
    	SpawnPrefab("sand_puff").Transform:SetPosition(x,_,z)
	inst.AnimState:PushAnimation("idle", true)
    end
end

local function runestoneturnon(inst, player)
    if player.prefab == "sdf" then

	--runestone glow on
	if player.components.inventory:Has("sdf_chalice_of_souls", 1, true) then
	    inst.AnimState:PushAnimation("runestone_glow")

	    --setup offerings
	    inst.RUNESTONE_ACTIVATE = true
	    local maxChaliceCount = player.components.sdf_chalice_counter:GetMaxChaliceCount()
	    local usedChaliceCount = player.components.sdf_chalice_counter:GetUsedChaliceCount()
	    local x,_,z = inst.Transform:GetWorldPosition()
	    if usedChaliceCount > maxChaliceCount then   
		inst.AnimState:PushAnimation("runestone_offering_max",true) --make special random animation
		SpawnPrefab("farm_plant_happy").Transform:SetPosition(x,_,z)
		inst:DoTaskInTime(0.5, function()
		    inst.RUNESTONE_REWARDREADY = true
		end)
	    else
		inst.RUNESTONE_ACTIVATE = true
		inst.AnimState:PushAnimation("runestone_offering_"..usedChaliceCount.."", true)
		SpawnPrefab("farm_plant_happy").Transform:SetPosition(x,_,z)
		inst:DoTaskInTime(0.5, function()
		    inst.RUNESTONE_REWARDREADY = true
		end)
	    end
	end
    end
end

local function fn()

    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddMiniMapEntity()
    inst.entity:AddNetwork()
    inst.entity:AddSoundEmitter()

    inst.MiniMapEntity:SetIcon("sdf_chalice_runestone_mm.tex")

    local s = 1.5
    inst.Transform:SetScale(s,s,s)
     
    inst.AnimState:SetBank("sdf_chalice_runestone")
    inst.AnimState:SetBuild("sdf_chalice_runestone")
    inst.AnimState:PlayAnimation("idle")


    inst:AddTag("structure")
    inst:AddTag("sdf_runestone_offering")

    inst:AddComponent("talker")
    if inst.components and inst.components.talker ~= nil then
        inst.components.talker.fontsize = 35
        inst.components.talker.font = TALKINGFONT
	inst.components.talker.colour = Vector3(0.6, 0.58, 0.58, 0)
	inst.components.talker.offset = Vector3(0, -400, 0)
    end

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    --Adding RewardsBank
    inst:AddComponent("sdf_chalice_rewards")
    inst.components.sdf_chalice_rewards:SetRewardBank(sdf_chalice_runestone_chaliceloot)
    inst.components.sdf_chalice_rewards:SetBonusRewardBank(sdf_chalice_runestone_chaliceloot_bonus)

    inst:AddComponent("inspectable")

    inst:AddComponent("playerprox")
    inst.components.playerprox:SetDist(1.2,1.4)
    inst.components.playerprox:SetOnPlayerNear(runestoneturnon)
    inst.components.playerprox:SetOnPlayerFar(runestoneturnoff)

    inst:AddComponent("hauntable")
    inst.components.hauntable:SetHauntValue(TUNING.HAUNT_TINY)

    return inst
end

return  Prefab("sdf_chalice_runestone", fn, assets)