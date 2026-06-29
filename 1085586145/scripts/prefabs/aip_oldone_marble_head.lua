local dev_mode=aipGetModConfig("dev_mode")=="enabled"
local language=aipGetModConfig("language")
local createEffectVest=require("utils/aip_vest_util").createEffectVest




local LANG_MAP={
english={
NAME="Head Part",
DESC="This is the main part",
},
chinese={
NAME="头颅部件",
DESC="这是它的本体",
},
}

local LANG=LANG_MAP[language] or LANG_MAP.english

STRINGS.NAMES.AIP_OLDONE_MARBLE_HEAD=LANG.NAME
STRINGS.CHARACTERS.GENERIC.DESCRIBE.AIP_OLDONE_MARBLE_HEAD=LANG.DESC

local PHYSICS_RADIUS=.45
local PHYSICS_HEIGHT=1
local PHYSICS_MASS=10
local HEAD_WALK_SPEED=1

local headAssets={
Asset("ANIM","anim/aip_oldone_marble_head.zip"),
Asset("ATLAS","images/inventoryimages/aip_oldone_marble_head.xml"),
}


local function IsDead(inst)
return inst.components.health~=nil and inst.components.health:IsDead()
end

local function resetHeadPhysics(inst)
inst.Physics:SetMotorVel(0,0,0)

inst.Physics:SetCapsule(PHYSICS_RADIUS,PHYSICS_HEIGHT)
end

local function getBody(inst)

local body=Ents[inst._aipBodyGUID]
if body==nil then
body=aipFindEnt("aip_oldone_marble")

if body~=nil then
inst._aipBodyGUID=body.GUID
end
end

return body
end

local function stopTryDrop(inst)
if inst._aipDropTask~=nil then
inst._aipDropTask:Cancel()
inst._aipDropTask=nil
end
end

local function startTryDrop(inst)
stopTryDrop(inst)

local timeout=dev_mode and 3 or (6+math.random()*4)

inst._aipDropTask=inst:DoTaskInTime(timeout,function()
local body=getBody(inst)

if body~=nil and not IsDead(body) then

if body._aipHand~=nil then
startTryDrop(inst)
return
end


local owner=inst.components.inventoryitem:GetGrandOwner()
if owner~=nil then
owner.components.inventory:DropItem(inst,true,true)


inst.AnimState:PlayAnimation("aipAttack")
inst.AnimState:PushAnimation("aipJump",true)

if owner.components.combat~=nil then
owner.components.combat:GetAttacked(body,10)
end
end
end
end)
end

local function stopTryBack(inst)
if inst._aipBackTask~=nil then
inst._aipBackTask:Cancel()
inst._aipBackTask=nil
end

inst.components.locomotor:Stop()
inst.components.locomotor:Clear()
end


local function startTryBack(inst)
stopTryBack(inst)

inst._aipBackTask=inst:DoPeriodicTask(2,function()
local body=getBody(inst)

if body~=nil then

if IsDead(body) then
stopTryBack(inst)
return
end


if body._aipHand~=nil then
return
end


local bodyPos=body:GetPosition()


if aipDist(inst:GetPosition(),bodyPos) < 5 then
inst.AnimState:PlayAnimation("aipJumpBack")
inst:ListenForEvent("animover",function()
body.AnimState:PlayAnimation("launchBack")
body.AnimState:PushAnimation("idle",true)
inst:Remove()
end)
return
end


inst.Physics:SetMass(PHYSICS_MASS)
inst.Physics:CollidesWith(COLLISION.WORLD)
inst.Physics:CollidesWith(COLLISION.OBSTACLES)
inst.Physics:CollidesWith(COLLISION.SMALLOBSTACLES)

if inst.Physics:GetMotorSpeed() <=0 then
inst.Physics:SetMotorVel(HEAD_WALK_SPEED,0,0)
end

inst.components.locomotor:GoToPoint(bodyPos)
end
end,1)
end

local function onequip(inst,owner)
owner.AnimState:OverrideSymbol("swap_body","aip_oldone_marble_head","swap_body")
startTryDrop(inst)
stopTryBack(inst)
end

local function onunequip(inst,owner)
owner.AnimState:ClearOverrideSymbol("swap_body")
stopTryDrop(inst)
startTryBack(inst)
end



local function refreshStatus(inst)

local owner=inst.components.inventoryitem:GetGrandOwner()
if owner==nil then
stopTryDrop(inst)
startTryBack(inst)
else
stopTryBack(inst)
startTryDrop(inst)
end
end


local function onHeadSave(inst,data)
end

local function onHeadLoad(inst)
inst:DoTaskInTime(1,function()
refreshStatus(inst)
end)
end



local function headFn()
local inst=CreateEntity()

inst.entity:AddTransform()
inst.entity:AddAnimState()
inst.entity:AddSoundEmitter()
inst.entity:AddNetwork()



MakeCharacterPhysics(inst,PHYSICS_MASS,PHYSICS_RADIUS)
inst.Physics:CollidesWith(COLLISION.WORLD)

inst.AnimState:SetBank("chesspiece")
inst.AnimState:SetBuild("aip_oldone_marble_head")
inst.AnimState:PlayAnimation("aipJump",true)

inst:AddTag("heavy")
inst:AddTag("aip_oldone_marble_head")

MakeInventoryFloatable(inst,"med",nil,0.65)

inst.entity:SetPristine()

if not TheWorld.ismastersim then
return inst
end



inst:AddComponent("heavyobstaclephysics")
inst.components.heavyobstaclephysics:SetRadius(PHYSICS_RADIUS)

inst:AddComponent("inspectable")

inst:AddComponent("lootdropper")

inst:AddComponent("inventoryitem")
inst.components.inventoryitem.cangoincontainer=false
inst.components.inventoryitem.atlasname="images/inventoryimages/aip_oldone_marble_head.xml"

inst:AddComponent("equippable")
inst.components.equippable.equipslot=EQUIPSLOTS.BODY
inst.components.equippable:SetOnEquip(onequip)
inst.components.equippable:SetOnUnequip(onunequip)
inst.components.equippable.walkspeedmult=TUNING.HEAVY_SPEED_MULT


inst:AddComponent("locomotor")
inst.components.locomotor.walkspeed=HEAD_WALK_SPEED
inst.components.locomotor.runspeed=HEAD_WALK_SPEED
inst.components.locomotor.slowmultiplier=1
inst.components.locomotor.fastmultiplier=1
inst.components.locomotor:SetTriggersCreep(false)
inst.components.locomotor.pathcaps={ ignorecreep=true }

inst:AddComponent("hauntable")
inst.components.hauntable:SetHauntValue(TUNING.HAUNT_TINY)

inst.resetHeadPhysics=resetHeadPhysics



inst.OnLoad=onHeadLoad
inst.OnSave=onHeadSave

return inst
end

return Prefab("aip_oldone_marble_head",headFn,headAssets)
