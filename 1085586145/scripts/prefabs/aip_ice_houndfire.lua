function BurntFn(inst)
aipReplacePrefab(inst,"ice")
end

local function fn()
local inst=CreateEntity()

inst.entity:AddTransform()
inst.entity:AddNetwork()

MakeInventoryPhysics(inst)

inst.entity:SetPristine()

if not TheWorld.ismastersim then
return inst
end

MakeLargeBurnable(inst,6+math.random()*6)


inst.components.burnable.fxdata={}
inst.components.burnable:AddBurnFX("coldfirefire",Vector3(0,0,0),nil,nil,1)


inst.components.burnable:SetOnIgniteFn(nil)
inst.components.burnable:SetOnExtinguishFn(inst.Remove)
inst.components.burnable:Ignite()

inst.components.burnable:SetOnBurntFn(BurntFn)

return inst
end

return Prefab("aip_ice_houndfire",fn)
