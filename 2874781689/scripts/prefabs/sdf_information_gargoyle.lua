local assets=
{
    Asset("ATLAS", "images/map_icons/sdf_information_gargoyle_mm.xml"),
    Asset("IMAGE", "images/map_icons/sdf_information_gargoyle_mm.tex"),

    Asset("ANIM", "anim/sdf_information_gargoyle.zip"),
}

prefabs = {
}

local INFORMATION_ON = false --Use for mercent glow

local function talkingFX(inst, player)
    if inst.INFORMATION_ON == true and inst.talked == true and player ~= nil then	
	inst.SoundEmitter:PlaySound("dontstarve/common/together/petrified/post")

	--spawn
	if inst.typeid == 0 then
	    if player.prefab == "sdf" then
		inst.components.talker:Say(STRINGS.ANNOUNCE_SDF_INFORMATION_GARGOYLE_QUOTES_SPAWN_SDF[math.random(#STRINGS.ANNOUNCE_SDF_INFORMATION_GARGOYLE_QUOTES_SPAWN_SDF)], 8)
	    else
		inst.components.talker:Say(STRINGS.ANNOUNCE_SDF_INFORMATION_GARGOYLE_QUOTES_SPAWN[math.random(#STRINGS.ANNOUNCE_SDF_INFORMATION_GARGOYLE_QUOTES_SPAWN)], 6)
	    end

	--hall of heroes
	elseif inst.typeid == 1 then
	    if player.prefab == "sdf" then
		inst.components.talker:Say(STRINGS.ANNOUNCE_SDF_INFORMATION_GARGOYLE_QUOTES_HOH_SDF[math.random(#STRINGS.ANNOUNCE_SDF_INFORMATION_GARGOYLE_QUOTES_HOH_SDF)], 8)
	    else
		inst.components.talker:Say(STRINGS.ANNOUNCE_SDF_INFORMATION_GARGOYLE_QUOTES_HOH[math.random(#STRINGS.ANNOUNCE_SDF_INFORMATION_GARGOYLE_QUOTES_HOH)], 8)
	    end

	--jack of the green
	elseif inst.typeid == 2 then
	   inst.components.talker:Say(STRINGS.ANNOUNCE_SDF_INFORMATION_GARGOYLE_QUOTES_JOTG[math.random(#STRINGS.ANNOUNCE_SDF_INFORMATION_GARGOYLE_QUOTES_JOTG)], 8)

	--haunted grounds
	elseif inst.typeid == 3 then
	    if player.prefab == "sdf" then
		inst.components.talker:Say(STRINGS.ANNOUNCE_SDF_INFORMATION_GARGOYLE_QUOTES_HG_SDF[math.random(#STRINGS.ANNOUNCE_SDF_INFORMATION_GARGOYLE_QUOTES_HG_SDF)], 8)
	    else
		inst.components.talker:Say(STRINGS.ANNOUNCE_SDF_INFORMATION_GARGOYLE_QUOTES_HG[math.random(#STRINGS.ANNOUNCE_SDF_INFORMATION_GARGOYLE_QUOTES_HG)], 8)
	    end

	--mullock chief memorial
	elseif inst.typeid == 4 then
	   inst.components.talker:Say(STRINGS.ANNOUNCE_SDF_INFORMATION_GARGOYLE_QUOTES_MCM[math.random(#STRINGS.ANNOUNCE_SDF_INFORMATION_GARGOYLE_QUOTES_MCM)], 8)

	--pumpkin gorge
	elseif inst.typeid == 5 then
	    if player.prefab == "sdf" then
		inst.components.talker:Say(STRINGS.ANNOUNCE_SDF_INFORMATION_GARGOYLE_QUOTES_PG_SDF[math.random(#STRINGS.ANNOUNCE_SDF_INFORMATION_GARGOYLE_QUOTES_PG_SDF)], 8)
	    else
		inst.components.talker:Say(STRINGS.ANNOUNCE_SDF_INFORMATION_GARGOYLE_QUOTES_PG[math.random(#STRINGS.ANNOUNCE_SDF_INFORMATION_GARGOYLE_QUOTES_PG)], 8)
	    end

	--enchanted earth
	elseif inst.typeid == 6 then
	    if player.prefab == "sdf" then
		inst.components.talker:Say(STRINGS.ANNOUNCE_SDF_INFORMATION_GARGOYLE_QUOTES_EE_SDF[math.random(#STRINGS.ANNOUNCE_SDF_INFORMATION_GARGOYLE_QUOTES_EE_SDF)], 8)
	    else
		inst.components.talker:Say(STRINGS.ANNOUNCE_SDF_INFORMATION_GARGOYLE_QUOTES_EE[math.random(#STRINGS.ANNOUNCE_SDF_INFORMATION_GARGOYLE_QUOTES_EE)], 8)
	    end

	--shadow demon tomb
	elseif inst.typeid == 7 then
	    if player.prefab == "sdf" then
		inst.components.talker:Say(STRINGS.ANNOUNCE_SDF_INFORMATION_GARGOYLE_QUOTES_SDT_SDF[math.random(#STRINGS.ANNOUNCE_SDF_INFORMATION_GARGOYLE_QUOTES_SDT_SDF)], 8)
	    else
		inst.components.talker:Say(STRINGS.ANNOUNCE_SDF_INFORMATION_GARGOYLE_QUOTES_SDT[math.random(#STRINGS.ANNOUNCE_SDF_INFORMATION_GARGOYLE_QUOTES_SDT)], 8)
	    end

	--ant caves
	elseif inst.typeid == 8 then
	    if player.prefab == "sdf" then
		inst.components.talker:Say(STRINGS.ANNOUNCE_SDF_INFORMATION_GARGOYLE_QUOTES_AC_SDF[math.random(#STRINGS.ANNOUNCE_SDF_INFORMATION_GARGOYLE_QUOTES_AC_SDF)], 8)
	    end

	--crystal caves
	elseif inst.typeid == 9 then
	   inst.components.talker:Say(STRINGS.ANNOUNCE_SDF_INFORMATION_GARGOYLE_QUOTES_CC[math.random(#STRINGS.ANNOUNCE_SDF_INFORMATION_GARGOYLE_QUOTES_CC)], 8)

	--zaroks lair
	elseif inst.typeid == 10 then
	    if player.prefab == "sdf" then
		inst.components.talker:Say(STRINGS.ANNOUNCE_SDF_INFORMATION_GARGOYLE_QUOTES_ZL_SDF[math.random(#STRINGS.ANNOUNCE_SDF_INFORMATION_GARGOYLE_QUOTES_ZL_SDF)], 8)
	    end
	end

	--additional quotes
	inst:DoTaskInTime(math.random(12, 16), function(inst)
	    inst.talkingtask = inst:DoTaskInTime(0,  talkingFX(inst, player))
	end)

    else
	inst.talked = false
	if inst.talkingtask ~= nil then
	    inst.talkingtask:Cancel()
	end
    end
end

local function informationturnoff(inst)
    if inst.INFORMATION_ON == true then
	inst.INFORMATION_ON = false
        inst.AnimState:PlayAnimation("information_glow_end")
        inst.AnimState:PushAnimation("idle")
    end
end

local function informationturnon(inst, player)

    if player == nil then
	return
    end

    --information glow on
    inst.INFORMATION_ON = true
    inst.AnimState:PlayAnimation("information_glow_start")
    inst.AnimState:PushAnimation("information_glow")

    if player.prefab == "sdf" then
	inst:AddTag("sdf_witch_talisman_offering")
    end

    --greet
    inst:DoTaskInTime(0.7,function()
	if inst.talked == false then
	    inst.talked = true
	    inst.SoundEmitter:PlaySound("dontstarve/common/together/petrified/post")

	    --spawn
	    if inst.typeid == 0 then
		if player.prefab == "sdf" then
		    inst.components.talker:Say(STRINGS.ANNOUNCE_SDF_INFORMATION_GARGOYLE_GREETINGS_SPAWN_SDF[math.random(#STRINGS.ANNOUNCE_SDF_INFORMATION_GARGOYLE_GREETINGS_SPAWN_SDF)], 6)
		else
		    inst.components.talker:Say(STRINGS.ANNOUNCE_SDF_INFORMATION_GARGOYLE_GREETINGS_SPAWN[math.random(#STRINGS.ANNOUNCE_SDF_INFORMATION_GARGOYLE_GREETINGS_SPAWN)], 6)
		end

	    --hall of heroes
	    elseif inst.typeid == 1 then
		if player.prefab == "sdf" then
		    inst.components.talker:Say(STRINGS.ANNOUNCE_SDF_INFORMATION_GARGOYLE_GREETINGS_HOH_SDF[math.random(#STRINGS.ANNOUNCE_SDF_INFORMATION_GARGOYLE_GREETINGS_HOH_SDF)], 8)
		else
		    inst.components.talker:Say(STRINGS.ANNOUNCE_SDF_INFORMATION_GARGOYLE_GREETINGS_HOH[math.random(#STRINGS.ANNOUNCE_SDF_INFORMATION_GARGOYLE_GREETINGS_HOH)], 8)
		end

	    --jack of the green
	    elseif inst.typeid == 2 then
		inst.components.talker:Say(STRINGS.ANNOUNCE_SDF_INFORMATION_GARGOYLE_GREETINGS_JOTG[math.random(#STRINGS.ANNOUNCE_SDF_INFORMATION_GARGOYLE_GREETINGS_JOTG)], 8)

	    --haunted ruins
	    elseif inst.typeid == 3 then
		if player.prefab == "sdf" then
		    inst.components.talker:Say(STRINGS.ANNOUNCE_SDF_INFORMATION_GARGOYLE_GREETINGS_HG_SDF[math.random(#STRINGS.ANNOUNCE_SDF_INFORMATION_GARGOYLE_GREETINGS_HG_SDF)], 8)
		else
		    inst.components.talker:Say(STRINGS.ANNOUNCE_SDF_INFORMATION_GARGOYLE_GREETINGS_HG[math.random(#STRINGS.ANNOUNCE_SDF_INFORMATION_GARGOYLE_GREETINGS_HG)], 8)
		end

	    --mullock chief memorial
	    elseif inst.typeid == 4 then
		inst.components.talker:Say(STRINGS.ANNOUNCE_SDF_INFORMATION_GARGOYLE_GREETINGS_MCM[math.random(#STRINGS.ANNOUNCE_SDF_INFORMATION_GARGOYLE_GREETINGS_MCM)], 8)

	    --pumpkin gorge
	    elseif inst.typeid == 5 then
		inst.components.talker:Say(STRINGS.ANNOUNCE_SDF_INFORMATION_GARGOYLE_GREETINGS_PG[math.random(#STRINGS.ANNOUNCE_SDF_INFORMATION_GARGOYLE_GREETINGS_PG)], 8)

	    --enchanted earth
	    elseif inst.typeid == 6 then
		inst.components.talker:Say(STRINGS.ANNOUNCE_SDF_INFORMATION_GARGOYLE_GREETINGS_EE[math.random(#STRINGS.ANNOUNCE_SDF_INFORMATION_GARGOYLE_GREETINGS_EE)], 8)

	    --shadow demon tomb
	    elseif inst.typeid == 7 then
		inst.components.talker:Say(STRINGS.ANNOUNCE_SDF_INFORMATION_GARGOYLE_GREETINGS_SDT[math.random(#STRINGS.ANNOUNCE_SDF_INFORMATION_GARGOYLE_GREETINGS_SDT)], 8)

	    --ant caves
	    elseif inst.typeid == 8 then
		inst.components.talker:Say(STRINGS.ANNOUNCE_SDF_INFORMATION_GARGOYLE_GREETINGS_AC[math.random(#STRINGS.ANNOUNCE_SDF_INFORMATION_GARGOYLE_GREETINGS_AC)], 8)

	    --crystal caves
	    elseif inst.typeid == 9 then
		inst.components.talker:Say(STRINGS.ANNOUNCE_SDF_INFORMATION_GARGOYLE_GREETINGS_CC[math.random(#STRINGS.ANNOUNCE_SDF_INFORMATION_GARGOYLE_GREETINGS_CC)], 8)

	    --zaroks lair
	    elseif inst.typeid == 10 then
		if player.prefab == "sdf" then
		    inst.components.talker:Say(STRINGS.ANNOUNCE_SDF_INFORMATION_GARGOYLE_GREETINGS_ZL_SDF[math.random(#STRINGS.ANNOUNCE_SDF_INFORMATION_GARGOYLE_GREETINGS_ZL_SDF)], 8)
		end
	    end

	    --additonal quotes
	    inst:DoTaskInTime(10, function(inst)
		inst.talkingtask = inst:DoTaskInTime(0, talkingFX(inst, player))
	    end)
	end
    end)
end

local function onSave(inst, data)
    data.typeid = inst.typeid
end

local function OnLoad(inst, data)
    if data ~= nil and data.typeid ~= nil then
        inst.typeid = data.typeid
    end
end

local function OnInit(inst)
    inst.task = nil
    inst:AddTag("sdf_information_gargoyle_"..inst.typeid.."")
end

local function fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddMiniMapEntity()
    inst.entity:AddNetwork()
    inst.entity:AddSoundEmitter()

    inst.MiniMapEntity:SetIcon("sdf_information_gargoyle_mm.tex")

    local s = 1.5
    inst.Transform:SetScale(s,s,s)
     
    inst.AnimState:SetBank("sdf_information_gargoyle")
    inst.AnimState:SetBuild("sdf_information_gargoyle")
    inst.AnimState:PlayAnimation("idle")

    MakeObstaclePhysics(inst, .5)

    inst:AddTag("structure")
    inst:AddTag("prototyper")
    inst:AddTag("sdf_information_gargoyle")

    inst:AddComponent("talker")
    if inst.components and inst.components.talker ~= nil then
        inst.components.talker.fontsize = 35
        inst.components.talker.font = TALKINGFONT
	inst.components.talker.colour = Vector3(1, 1, 0, 0)
	inst.components.talker.offset = Vector3(0, -400, 0)
    end

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst.typeid = 0

    inst:AddComponent("inspectable")
 
    inst:AddComponent("playerprox")
    inst.components.playerprox:SetDist(2.1,2.3)
    inst.components.playerprox:SetOnPlayerNear(informationturnon)
    inst.components.playerprox:SetOnPlayerFar(informationturnoff)

    inst:AddComponent("hauntable")
    inst.components.hauntable:SetHauntValue(TUNING.HAUNT_TINY)

    inst.talked = false
    inst.talkingtask = nil

    inst.task = inst:DoTaskInTime(0, OnInit)

    inst.OnLoad = OnLoad
    inst.OnSave = onSave

    return inst
end

return  Prefab("sdf_information_gargoyle", fn, assets)