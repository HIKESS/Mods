local assets =
{
    Asset("ANIM", "anim/sdf_professors_lab_generator.zip"),
    Asset("ANIM", "anim/ui_sdf_professors_lab_generator.zip"),
}

prefabs = {
}

local MUST_HAVE_TAGS = {"sdf_professors_lab_generator_powered"}
local CANT_HAVE_TAGS = {"player", "playerghost", "INLIMBO", "companion", "ghost"}
local AOE_RADIUS = 20

local function aoePowerTurnOnCheck(inst)
    local tx, ty, tz = inst.Transform:GetWorldPosition()

    local affected_entity = TheSim:FindEntities(tx, ty, tz, AOE_RADIUS, MUST_HAVE_TAGS, CANT_HAVE_TAGS)
    for i, v in ipairs(affected_entity) do

	--find all structures
	if v ~= nil then
	    v:SdfProfessorsLabPoweredFn()
	end
    end
end

local function aoePowerTurnOffCheck(inst)
    local tx, ty, tz = inst.Transform:GetWorldPosition()

    local affected_entity = TheSim:FindEntities(tx, ty, tz, AOE_RADIUS, MUST_HAVE_TAGS, CANT_HAVE_TAGS)
    for i, v in ipairs(affected_entity) do

	--find all structures
	if v ~= nil then
	    v:SdfProfessorsLabUnpoweredFn()
	end
    end
end

local function HasCharcoal(inst)
    if inst.components.container:Has("charcoal", 1) then
	return true
    end
    return false
end

local function OnOpen(inst)
    --Open animation
    if inst.AnimState:IsCurrentAnimation("idle_work_loop") then
	inst.AnimState:PlayAnimation("open_work_loop", true)
    elseif inst.AnimState:IsCurrentAnimation("idle_full") then
	inst.AnimState:PlayAnimation("open_full")
	inst.AnimState:PushAnimation("open_loop_full", true)
    else
	inst.AnimState:PlayAnimation("open_empty")
	inst.AnimState:PushAnimation("open_loop_empty", true)
    end

    inst.SoundEmitter:PlaySound("dontstarve/wilson/chest_open")
    inst.isopen=true
    inst.components.machine.enabled = false
end

local function OnClose(inst)
    --Close animation
    if inst.AnimState:IsCurrentAnimation("open_work_loop") then
	inst.AnimState:PlayAnimation("close_work_loop")
	inst.AnimState:PushAnimation("idle_work_loop", true)
    elseif inst.AnimState:IsCurrentAnimation("open_loop_full") then
	inst.AnimState:PlayAnimation("close_full")
	inst.AnimState:PushAnimation("idle_full")
    else
	inst.AnimState:PlayAnimation("close_empty")
	inst.AnimState:PushAnimation("idle_empty")
    end

    inst.SoundEmitter:PlaySound("dontstarve/wilson/chest_close")
    inst.isopen=false

    if HasCharcoal(inst) then
	inst.components.machine.enabled = true
    end
end

local function TurnOn(inst)
    --No longer can be opened
    inst.components.container.canbeopened = false

    if not inst.components.fueled.consuming and HasCharcoal(inst) then
        inst.components.fueled:StartConsuming()

	--Power up all structures
    	aoePowerTurnOnCheck(inst)

	if inst.AnimState:IsCurrentAnimation("idle_full") then
	    inst.AnimState:PlayAnimation("idle_work_loop", true)
	end
	inst.SoundEmitter:PlaySound("dontstarve/common/together/battery/up")
    end
end

local function TurnOff(inst)
    --Can be opened
    inst.components.container.canbeopened = true

    inst.components.fueled:StopConsuming()

    --Allows to be turned back on with charcoal
    if HasCharcoal(inst) then
	inst.components.machine.enabled = true
    end

    --Power down all structures
    aoePowerTurnOffCheck(inst)

    if inst.AnimState:IsCurrentAnimation("idle_work_loop") and HasCharcoal(inst) then
	inst.AnimState:PlayAnimation("idle_full")
    end
    if inst.components.machine:IsOn() then
	inst.SoundEmitter:PlaySound("dontstarve/common/together/battery/down")
    end
end

local function ShouldAcceptItem(inst, item)
    if item == nil then
	return false
    elseif item.prefab == "charcoal" then
	if inst.isopen == true then
	    return true
	elseif item.components.inventoryitem.owner ~= nil then
	    inst:DoTaskInTime(0, function()
		if inst.isopen == false then
		    item.components.inventoryitem.owner.components.talker:Say(STRINGS.ANNOUNCE_SDF_PROFESSORS_LAB_GENERATOR_NO_TRADE, 4)
		end
	    end)
	end
    end
    return false
end

local function OnCharcoalStored(inst)
    --adding fuel
    local delta = inst.components.fueled.maxfuel
    if inst.components.fueled:IsEmpty() then
	--prevent battery level flicker by subtracting a tiny bit from initial fuel
	delta = delta - .000001
    else
	local final = inst.components.fueled.currentfuel + delta
    end
    inst.components.fueled:DoDelta(delta)
end

local function OnCharcoalGiven(inst, giver, item)
    --accept Charcoal
    if inst.isopen == true then
	local charcoalItem = SpawnPrefab("charcoal")
	local slot = inst.components.container:GetItemSlot(inst)
	inst.components.container:GiveItem(charcoalItem, slot)
    end

    --Adding fuel
    OnCharcoalStored(inst)
end

local function AddCharcoal(inst)
    if inst._hasCharcoal == true then
	return
    else
	OnCharcoalStored(inst)
	if inst.AnimState:IsCurrentAnimation("open_loop_empty") then
	    inst.AnimState:PlayAnimation("open_loop_full", true)
	else
	    inst.AnimState:PlayAnimation("idle_full")
	end
	inst._hasCharcoal = true
    end
end

local function RemoveCharcoal(inst)
    if inst._hasCharcoal == false then
	return
    elseif HasCharcoal(inst) == true then
	return
    else
	inst.components.fueled:MakeEmpty()
	if inst.AnimState:IsCurrentAnimation("open_loop_full") then
	    inst.AnimState:PlayAnimation("open_loop_empty", true)
	else
	    inst.AnimState:PlayAnimation("idle_empty")
	end
	inst._hasCharcoal = false
    end
end

local function AddFuel(inst)
    local fuel_added = 0
    OnCharcoalStored(inst)
    fuel_added = fuel_added + 1
    return fuel_added
end

local function CheckForFuel(inst)
    if inst.isopen then
	return
    end
    if inst.components.machine.ison == false then
	return
    end
    if HasCharcoal(inst) and inst.isopen == false and inst.components.machine.ison == true then
	AddFuel(inst)
    end
end

local function OnFuelEmpty(inst)
    if HasCharcoal(inst) then
	inst.components.container:ConsumeByName("charcoal", 1)

	--Burning charcoal anim
	local x,_,z = inst.Transform:GetWorldPosition()
	SpawnPrefab("wx78_heat_steam").Transform:SetPosition(x,_ -1.8,z)
	inst.SoundEmitter:PlaySound("rifts3/wagpunk_armor/downgrade")
    end

    --Add more fuel else turn off
    if HasCharcoal(inst) then
	CheckForFuel(inst)
    else
	inst.components.machine:TurnOff(inst)
	inst.components.machine.enabled = false
	if inst.AnimState:IsCurrentAnimation("idle_work_loop") then
            inst.AnimState:PlayAnimation("idle_empty")
	end
    end
end

local function OnLoad(inst, data, ents)
    --Get Animation
    if HasCharcoal(inst) == true then
	if inst.components.machine:IsOn() then
	    TurnOn(inst)
	else
	    TurnOff(inst)
	end
    else
	inst.components.fueled:MakeEmpty()
	inst.components.machine.enabled = false
    end
end

local function fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()
    inst.entity:AddNetwork()

    MakeObstaclePhysics(inst, .8)

    inst.AnimState:SetBank("sdf_professors_lab_generator")
    inst.AnimState:SetBuild("sdf_professors_lab_generator")
    inst.AnimState:PlayAnimation("idle_empty")

    inst:AddTag("structure")
    inst:AddTag("nonpackable")
    inst:AddTag("trader")

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst:AddComponent("inspectable")

    inst:AddComponent("container")
    inst.components.container:WidgetSetup("sdf_professors_lab_generator")
    inst.components.container.onopenfn = OnOpen
    inst.components.container.onclosefn = OnClose
    inst.isopen=false

    inst:AddComponent("trader")
    inst.components.trader:SetAbleToAcceptTest(ShouldAcceptItem)
    inst.components.trader.onaccept = OnCharcoalGiven

    inst:AddComponent("fueled")
    inst.components.fueled:SetDepletedFn(OnFuelEmpty)
    inst.components.fueled.maxfuel = TUNING.SDF_PROFESSORS_LAB_GENERATOR_MAX_FUEL_TIME
    inst.components.fueled.fueltype = FUELTYPE.MAGIC

    inst:AddComponent("machine")
    inst.components.machine.turnonfn = TurnOn
    inst.components.machine.turnofffn = TurnOff
    inst.components.machine.cooldowntime = 0

    inst._hasCharcoal = false
    inst._hasCharcoal = HasCharcoal(inst)
    inst.electricitysoundtask = nil

    inst.OnLoad = OnLoad

    inst:ListenForEvent("itemget", AddCharcoal)
    inst:ListenForEvent("itemlose", RemoveCharcoal)

    return inst
end

return Prefab("sdf_professors_lab_generator", fn, assets)