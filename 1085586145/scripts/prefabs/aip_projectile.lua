
local createEffectVest=require("utils/aip_vest_util").createEffectVest

local function patchColor(inst,color)
if not color or #color < 4 then
return false
end

inst.AnimState:OverrideMultColour(color[1]/10,color[2]/10,color[3]/10,color[4]/10)
return true
end

local function OnUpdateProjectileTail(inst)
local pos=inst:GetPosition()
local sx,sy,sz=inst.Transform:GetScale()

local vest=createEffectVest("aip_dou_scepter_projectile","aip_dou_scepter_projectile","disappear")
vest.Transform:SetPosition(pos.x,pos.y,pos.z)
vest.Transform:SetScale(sx,sy,sz)


vest.Physics:SetMotorVel(0,1,0)


patchColor(vest,inst.components.aipc_info_client:Get("aip_projectile_color"))
end

local assets={
Asset("ANIM","anim/aip_dou_scepter_projectile.zip"),
}

local function fn()
local inst=CreateEntity()

inst.entity:AddTransform()
inst.entity:AddAnimState()
inst.entity:AddNetwork()

MakeProjectilePhysics(inst)
RemovePhysicsColliders(inst)

inst.AnimState:SetBank("aip_dou_scepter_projectile")
inst.AnimState:SetBuild("aip_dou_scepter_projectile")
inst.AnimState:PlayAnimation("idle",true)

inst:AddTag("projectile")
inst:AddTag("flying")
inst:AddTag("ignorewalkableplatformdrowning")


inst:AddComponent("aipc_info_client")
inst.components.aipc_info_client:SetByteArray("aip_projectile_color",nil,true)
inst.components.aipc_info_client:ListenForEvent("aip_projectile_color",function(inst,color)
patchColor(inst,color)
end)


if not TheNet:IsDedicated() then
inst.tailPeriodTask=inst:DoPeriodicTask(0.02,OnUpdateProjectileTail)
end

inst.entity:SetPristine()

if not TheWorld.ismastersim then
return inst
end

inst:AddComponent("aipc_projectile")

inst.OnFinish=function()
local pos=inst:GetPosition()
local vest=createEffectVest("aip_dou_scepter_projectile","aip_dou_scepter_projectile","explode")
vest.Transform:SetPosition(pos.x,pos.y,pos.z)
patchColor(vest,inst.components.aipc_info_client:Get("aip_projectile_color"))
end

return inst
end

return Prefab("aip_projectile",fn,assets)
