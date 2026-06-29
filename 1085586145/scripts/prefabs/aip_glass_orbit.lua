local dev_mode=aipGetModConfig("dev_mode")=="enabled"

local language=aipGetModConfig("language")


local LANG_MAP={
english={
NAME="Moon Connection Point",
DESC="Create an invisible path",
},
chinese={
NAME="月能联结点",
DESC="链接着远方的道路",
},
}

local LANG=LANG_MAP[language] or LANG_MAP.english

STRINGS.NAMES.AIP_GLASS_ORBIT_POINT=LANG.NAME
STRINGS.CHARACTERS.GENERIC.DESCRIBE.AIP_GLASS_ORBIT_POINT=LANG.DESC


local assets={
Asset("ANIM","anim/aip_glass_orbit.zip"),
Asset("ANIM","anim/aip_glass_orbit_column.zip"),
}


local function onPointRemove(inst)
if inst._aip_columns~=nil then
for _,column in pairs(inst._aip_columns) do
column:Remove()
end
end
end

local function pointFn()
local inst=CreateEntity()

inst.entity:AddTransform()
inst.entity:AddAnimState()
inst.entity:AddNetwork()

MakeTinyFlyingCharacterPhysics(inst,0,0)

inst.AnimState:SetBank("aip_glass_orbit")
inst.AnimState:SetBuild("aip_glass_orbit")
inst.AnimState:PlayAnimation("loop",true)


inst.AnimState:SetOrientation(ANIM_ORIENTATION.OnGround)




inst:DoTaskInTime(1,function()
local pt=inst:GetPosition()
if pt.y==0 then
inst.AnimState:SetLayer(LAYER_WORLD_BACKGROUND)
inst.AnimState:SetSortOrder(3)
else
if TheNet:IsDedicated() then
return
end

inst._aip_columns={}
for i=0,pt.y,0.5 do
local column=aipSpawnPrefab(inst,"aip_glass_orbit_column",nil,i)
table.insert(inst._aip_columns,column)

local cols=TheSim:FindEntities(pt.x,pt.y,pt.z,5,{ "aip_glass_orbit_column" })
end



inst.OnRemoveEntity=onPointRemove
end
end)

inst:AddTag("aip_glass_orbit_point")


inst:AddTag("flying")


inst:AddComponent("aipc_orbit_point")

inst.entity:SetPristine()

if not TheWorld.ismastersim then
return inst
end

inst:AddComponent("inspectable")

MakeHauntableLaunch(inst)





return inst
end



local function columnFn()
local inst=CreateEntity()

inst.entity:AddTransform()
inst.entity:AddAnimState()

inst.AnimState:SetBank("aip_glass_orbit_column")
inst.AnimState:SetBuild("aip_glass_orbit_column")
inst.AnimState:PlayAnimation("idle")

inst:AddTag("aip_glass_orbit_column")
inst:AddTag("NOCLICK")
inst:AddTag("fx")

if not TheWorld.ismastersim then
return inst
end

inst.persists=false

return inst
end



local function orbitFn()
local inst=CreateEntity()

inst.entity:AddTransform()
inst.entity:AddAnimState()


inst.AnimState:SetOrientation(ANIM_ORIENTATION.OnGround)



inst.AnimState:SetBank("aip_glass_orbit")
inst.AnimState:SetBuild("aip_glass_orbit")
inst.AnimState:PlayAnimation("idle")

inst:AddTag("NOCLICK")
inst:AddTag("fx")



inst:DoTaskInTime(1,function()
if inst:GetPosition().y==0 then
inst.AnimState:SetLayer(LAYER_WORLD_BACKGROUND)
inst.AnimState:SetSortOrder(2)
end
end)

if not TheWorld.ismastersim then
return inst
end

inst.persists=false

return inst
end


local function linkFn()
local inst=CreateEntity()

inst.entity:AddTransform()
inst.entity:AddAnimState()
inst.entity:AddNetwork()

MakeTinyFlyingCharacterPhysics(inst,0,0)

inst.AnimState:SetBank("aip_glass_orbit_point")
inst.AnimState:SetBuild("aip_glass_orbit_point")
inst.AnimState:PlayAnimation("idle")

inst.AnimState:OverrideMultColour(0,0,0,dev_mode and 0.3 or 0)

inst:AddTag("NOCLICK")
inst:AddTag("fx")


inst:AddComponent("aipc_orbit_link")

inst.entity:SetPristine()

if not TheWorld.ismastersim then
return inst
end

return inst
end

return Prefab("aip_glass_orbit_point",pointFn,assets),
Prefab("aip_glass_orbit_column",columnFn,assets),
Prefab("aip_glass_orbit",orbitFn,assets),
Prefab("aip_glass_orbit_link",linkFn,assets)
