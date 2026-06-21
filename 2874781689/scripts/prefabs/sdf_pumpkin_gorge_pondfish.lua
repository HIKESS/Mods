local assets =
{
    Asset("IMAGE", "images/inventoryimages/sdf_pumpkin_gorge_pondfish.tex"),
    Asset("ATLAS", "images/inventoryimages/sdf_pumpkin_gorge_pondfish.xml"),
    Asset("IMAGE", "images/inventoryimages/sdf_pumpkin_gorge_pondfish_dead.tex"),
    Asset("ATLAS", "images/inventoryimages/sdf_pumpkin_gorge_pondfish_dead.xml"),
    Asset("IMAGE", "images/inventoryimages/sdf_pumpkin_gorge_pondfish_cooked.tex"),
    Asset("ATLAS", "images/inventoryimages/sdf_pumpkin_gorge_pondfish_cooked.xml"),

    Asset("ANIM", "anim/sdf_pumpkin_gorge_pondfish.zip"),
}

local pondfish_prefabs =
{

}

local function CalcNewSize()
    local p = 2 * math.random() - 1
    return (p*p*p + 1) * 0.5
end

local POND_DIST = TUNING.SDF_PUMPKING_GORGE_POND_SPAWN_DIST + 0.5
local function checkInWater(inst)
    local x, y, z = inst.Transform:GetWorldPosition()
    local ents = TheSim:FindEntities(x, y, z, POND_DIST)
    for i, v in ipairs(ents) do
        if v:HasTag("sdf_pumpkin_gorge_pond") then
	    if v.components.watersource ~= nil and v.components.watersource.available == true then
		inst.inWater = true
		return true
	    else
		inst.inWater = false
	    end
        end
    end
    return false
end

local function flop(inst)
    if not inst.components.inventoryitem.canbepickedup then
	if inst.flop_task ~= nil then
	    inst.flop_task:Cancel()
	    inst.flop_task = nil
	end
	return -- Don't flop if we can't be picked up, this likely means we're in a special place/state.
    end

    local num = math.random(2)
    for i = 1, num do
	inst.AnimState:PushAnimation("idle", false)

	if checkInWater(inst) then
	    local x, y, z = inst.Transform:GetWorldPosition()
	    SpawnPrefab("frogsplash").Transform:SetPosition(x, y, z)

	    if inst.components.perishable:GetPercent() < 1 then
		local adjustPercent = inst.components.perishable:GetPercent() + 0.02
		inst.components.perishable:SetPercent(adjustPercent)
	    end

	    inst.components.perishable:StopPerishing()
	else
	    inst.components.perishable:StartPerishing()
	end
    end

    inst.flop_task = inst:DoTaskInTime(math.random() * 2 + num * 2, flop)
end

local function ondropped(inst)
    if inst.flop_task ~= nil then
        inst.flop_task:Cancel()
    end
    inst.AnimState:PlayAnimation("idle", false)

    if checkInWater(inst) then
	local x, y, z = inst.Transform:GetWorldPosition()
	SpawnPrefab("frogsplash").Transform:SetPosition(x, y, z)
    end

    inst.flop_task = inst:DoTaskInTime(math.random() * 3, flop)
end

local function ondroppedasloot(inst, data)
    if data ~= nil and data.dropper ~= nil then
	inst.components.weighable.prefab_override_owner = data.dropper.prefab
    end
end

local function onpickup(inst)
    if inst.flop_task ~= nil then
        inst.flop_task:Cancel()
        inst.flop_task = nil
    end

    inst.inWater = false
    inst.components.perishable:StartPerishing()
end

local function fn()
    local inst = CreateEntity()
    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddDynamicShadow()
    inst.entity:AddNetwork()

    MakeInventoryPhysics(inst)

    local scale = 0.8
    inst.Transform:SetScale(scale, scale, scale)

    inst.AnimState:SetBank("sdf_pumpkin_gorge_pondfish")
    inst.AnimState:SetBuild("sdf_pumpkin_gorge_pondfish")
    inst.AnimState:PlayAnimation("idle", false)
   
    inst.DynamicShadow:SetSize(1.5,  0.75)

    inst:AddTag("fish")
    inst:AddTag("weighable_fish")
    inst:AddTag("meat")
    inst:AddTag("show_spoilage")
    inst:AddTag("catfood")
    inst:AddTag("smallcreature")
    inst:AddTag("sdf_pumpkin_gorge_pondfish")

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst:AddComponent("perishable")
    inst.components.perishable:SetPerishTime(TUNING.PERISH_ONE_DAY)
    inst.components.perishable:StartPerishing()
    inst.components.perishable.onperishreplacement = "sdf_pumpkin_gorge_pondfish_dead"
    inst.components.perishable.ignorewentness = true

    inst:AddComponent("cookable")
    inst.components.cookable.product = "sdf_pumpkin_gorge_pondfish_cooked"

    inst:AddComponent("inspectable")

    inst:AddComponent("inventoryitem")
    inst.components.inventoryitem.imagename = "sdf_pumpkin_gorge_pondfish"
    inst.components.inventoryitem.atlasname = "images/inventoryimages/sdf_pumpkin_gorge_pondfish.xml"
    inst.components.inventoryitem:SetOnDroppedFn(ondropped)
    inst.components.inventoryitem:SetOnPutInInventoryFn(onpickup)
    inst.components.inventoryitem:SetSinks(true)

    inst:AddComponent("murderable")

    inst:AddComponent("lootdropper")
    inst.components.lootdropper:SetLoot({"sdf_pumpkin_gorge_pondfish_dead"})

    MakeHauntableLaunchAndPerish(inst)

    inst:AddComponent("tradable")
    inst.components.tradable.goldvalue = TUNING.GOLD_VALUES.MEAT
    
    inst.inWater = false
    inst.data = {}

    inst:AddComponent("weighable")
    inst.components.weighable.type = TROPHYSCALE_TYPES.FISH
    inst.components.weighable:Initialize(40.89, 55.28)
    inst.components.weighable:SetWeight(Lerp(40.89, 55.28, CalcNewSize()))

    inst:ListenForEvent("on_loot_dropped", ondroppedasloot)

    inst.flop_task = inst:DoTaskInTime(math.random() * 2 + 1, flop)

    return inst
end

local function fn2()
    local inst = CreateEntity()
    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddDynamicShadow()
    inst.entity:AddNetwork()

    MakeInventoryPhysics(inst)

    local scale = 0.8
    inst.Transform:SetScale(scale, scale, scale)

    inst.AnimState:SetBank("sdf_pumpkin_gorge_pondfish")
    inst.AnimState:SetBuild("sdf_pumpkin_gorge_pondfish")
    inst.AnimState:PlayAnimation("dead")
   
    inst.DynamicShadow:SetSize(1.5,  0.75)

    inst:AddTag("fish")
    inst:AddTag("weighable_fish")
    inst:AddTag("meat")
    inst:AddTag("catfood")
    inst:AddTag("smallcreature")
    inst:AddTag("sdf_pumpkin_gorge_pondfish")

    MakeInventoryFloatable(inst, "med", 0.5)

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst:AddComponent("perishable")
    inst.components.perishable:SetPerishTime(TUNING.PERISH_TWO_DAY)
    inst.components.perishable:StartPerishing()
    inst.components.perishable.onperishreplacement = "spoiled_fish_small"
    inst.components.perishable.ignorewentness = true

    inst:AddComponent("cookable")
    inst.components.cookable.product = "sdf_pumpkin_gorge_pondfish_cooked"

    inst:AddComponent("inspectable")

    inst:AddComponent("inventoryitem")
    inst.components.inventoryitem.imagename = "sdf_pumpkin_gorge_pondfish_dead"
    inst.components.inventoryitem.atlasname = "images/inventoryimages/sdf_pumpkin_gorge_pondfish_dead.xml"

    inst:AddComponent("lootdropper")
    inst.components.lootdropper:SetLoot({"spoiled_fish_small"})

    inst:AddComponent("edible")
    inst.components.edible.ismeat = true
    inst.components.edible.healthvalue = TUNING.HEALING_TINY --1
    inst.components.edible.hungervalue = TUNING.CALORIES_SMALL --12.5
    inst.components.edible.sanityvalue = TUNING.SANITY_TINY --5
    inst.components.edible.foodtype = FOODTYPE.MEAT

    MakeHauntableLaunchAndPerish(inst)

    inst:AddComponent("tradable")
    inst.components.tradable.goldvalue = TUNING.GOLD_VALUES.MEAT
    inst.data = {}

    inst:AddComponent("weighable")
    inst.components.weighable.type = TROPHYSCALE_TYPES.FISH
    inst.components.weighable:Initialize(40.89, 55.28)
    inst.components.weighable:SetWeight(Lerp(40.89, 55.28, CalcNewSize()))

    inst:ListenForEvent("on_loot_dropped", ondroppedasloot)

    return inst
end

local function fn3()
    local inst = CreateEntity()
    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddNetwork()

    MakeInventoryPhysics(inst)

    local scale = 0.8
    inst.Transform:SetScale(scale, scale, scale)

    inst.AnimState:SetBank("sdf_pumpkin_gorge_pondfish")
    inst.AnimState:SetBuild("sdf_pumpkin_gorge_pondfish")
    inst.AnimState:PlayAnimation("cooked")

    inst:AddTag("fish")
    inst:AddTag("meat")
    inst:AddTag("catfood")
    inst:AddTag("smallcreature")
    inst:AddTag("sdf_pumpkin_gorge_pondfish")

    MakeInventoryFloatable(inst, "med", 0.5)

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst:AddComponent("perishable")
    inst.components.perishable:SetPerishTime(TUNING.PERISH_FAST)
    inst.components.perishable:StartPerishing()
    inst.components.perishable.onperishreplacement = "spoiled_fish_small"

    inst:AddComponent("inspectable")

    inst:AddComponent("inventoryitem")
    inst.components.inventoryitem.imagename = "sdf_pumpkin_gorge_pondfish_cooked"
    inst.components.inventoryitem.atlasname = "images/inventoryimages/sdf_pumpkin_gorge_pondfish_cooked.xml"

    inst:AddComponent("stackable")
    inst.components.stackable.maxsize = TUNING.SDF_PUMPKIN_GORGE_PONDFISH_COOKED_MAXSTACKCOUNT

    inst:AddComponent("edible")
    inst.components.edible.ismeat = true
    inst.components.edible.healthvalue = TUNING.HEALING_SMALL --3
    inst.components.edible.hungervalue = TUNING.CALORIES_SMALL  --12.5
    inst.components.edible.sanityvalue = TUNING.SANITY_SUPERTINY --1
    inst.components.edible.foodtype = FOODTYPE.MEAT

    MakeHauntableLaunchAndPerish(inst)

    inst:AddComponent("tradable")
    inst.components.tradable.goldvalue = TUNING.GOLD_VALUES.MEAT
    inst.data = {}

    return inst
end

return Prefab("sdf_pumpkin_gorge_pondfish", fn, assets, prefabs),
	Prefab("sdf_pumpkin_gorge_pondfish_dead", fn2, assets, prefabs),
	Prefab("sdf_pumpkin_gorge_pondfish_cooked", fn3, assets, prefabs)