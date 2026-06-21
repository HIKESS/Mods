local assets =
{
    Asset("ANIM", "anim/mevileyesfruit.zip"),
	Asset("ATLAS", "images/inventoryimages/mevileyesfruit.xml"),
    Asset("IMAGE", "images/inventoryimages/mevileyesfruit.tex"),
}

local function onSave(inst, data)   
    data._kenjutsulevel = inst._kenjutsulevel  
    data._kenjutsuexp = inst._kenjutsuexp  
end

local function onLoad(inst, data)
    if data then	
        if data._kenjutsulevel then inst._kenjutsulevel = data._kenjutsulevel end	
		if data._kenjutsuexp then inst._kenjutsuexp = data._kenjutsuexp end
	end	
end

local function fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()
    inst.entity:AddNetwork()
	inst.entity:AddLight()
	
	inst.entity:AddMiniMapEntity()
	inst.MiniMapEntity:SetIcon("mevileyesfruit.tex")
	
    MakeInventoryPhysics(inst)
	
	inst.Light:SetFalloff(0.7)
    inst.Light:SetIntensity(.5)
    inst.Light:SetRadius(0.5)
    inst.Light:SetColour(80 / 255, 0 / 255, 0 / 255)
    inst.Light:Enable(true)

    inst.AnimState:SetBank("mevileyesfruit")
    inst.AnimState:SetBuild("mevileyesfruit")
    inst.AnimState:PlayAnimation("idle")
	inst.AnimState:SetBloomEffectHandle("shaders/anim.ksh")
	
	inst.AnimState:SetMultColour(1, 1, 1, 1)
	
	inst:AddTag("nosteal")
	inst:AddTag("nonstackable")
	inst:AddTag("light")
	
    MakeInventoryFloatable(inst)
	inst.components.floater:SetSize("small")
    inst.components.floater:SetVerticalOffset(0.1)
	
    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst:AddComponent("inspectable")

    inst:AddComponent("inventoryitem")
	inst.components.inventoryitem.keepondeath = true
	inst.components.inventoryitem.keepondrown = true	
	
	inst.components.inventoryitem.imagename = "mevileyesfruit"
    inst.components.inventoryitem.atlasname = "images/inventoryimages/mevileyesfruit.xml"	

    inst:AddComponent("edible")
    inst.components.edible.foodtype = FOODTYPE.EVILEYESMEMO
    inst.components.edible.hungervalue = 150
	
	if inst.icon == nil then
        inst.icon = SpawnPrefab("globalmapicon")
        inst.icon:TrackEntity(inst)
    end
	
	inst.OnSave = onSave
    inst.OnLoad = onLoad
	
    return inst
end

return Prefab("mevileyesfruit", fn, assets)