local _G=GLOBAL
local language=_G.aipGetModConfig("language")

local dev_mode=_G.aipGetModConfig("dev_mode")=="enabled"

env.AddReplicableComponent("aipc_buffer")



local function triggerComponentAction(player,item,target,targetPoint,clientOnly)
if clientOnly and item.components.aipc_action_client~=nil then
item.components.aipc_action_client:DoAction(player)
elseif item.components.aipc_action~=nil then

if target~=nil then
item.components.aipc_action:DoTargetAction(player,target)
elseif targetPoint~=nil then
item.components.aipc_action:DoPointAction(player,targetPoint)
else
item.components.aipc_action:DoAction(player)
end
end

if item~=nil and target~=nil and target.components.aipc_action~=nil then
target.components.aipc_action:DoGiveAction(player,item)
end
end

env.AddModRPCHandler(env.modname,"aipComponentAction",function(player,item,target,targetPoint)
triggerComponentAction(player,item,target,targetPoint)
end)

env.AddClientModRPCHandler(env.modname,"aipClientComponentAction",function(item,target,targetPoint)
triggerComponentAction(_G.ThePlayer,item,target,targetPoint,true)
end)


local LANG_MAP={
english={
GIVE="Give",
FUEL="Fuel",
USE="Use",
CAST="Cast",
READ="Read",
EAT="Eat",
TAKE="Take",
MAP_USE="Use",
},
chinese={
GIVE="给予",
FUEL="充能",
USE="使用",
CAST="释放",
READ="阅读",
EAT="吃",
TAKE="拿取",
MAP_USE="使用",
},
}
local LANG=LANG_MAP[language] or LANG_MAP.english

_G.STRINGS.ACTIONS.AIP_USE=LANG.USE


local function actionFn(act)
local doer=act.doer
local item=act.invobject
local target=act.target

if _G.TheNet:GetIsServer() then

triggerComponentAction(doer,item,target,nil)
else

_G.aipRPC("aipComponentAction",item,target,nil)
end

return true
end


local AIPC_ACTION=env.AddAction("AIPC_ACTION",LANG.GIVE,actionFn)
AIPC_ACTION.priority=1

AddStategraphActionHandler("wilson",_G.ActionHandler(AIPC_ACTION,"dolongaction"))
AddStategraphActionHandler("wilson_client",_G.ActionHandler(AIPC_ACTION,"dolongaction"))


local AIPC_REMOTE_ACTION=env.AddAction("AIPC_REMOTE_ACTION",LANG.USE,actionFn)
AIPC_REMOTE_ACTION.priority=1
AIPC_REMOTE_ACTION.distance=10

AddStategraphActionHandler("wilson",_G.ActionHandler(AIPC_REMOTE_ACTION,"throw"))
AddStategraphActionHandler("wilson_client",_G.ActionHandler(AIPC_REMOTE_ACTION,"throw"))


local AIPC_GIVE_ACTION=env.AddAction("AIPC_GIVE_ACTION",LANG.GIVE,actionFn)
AIPC_GIVE_ACTION.priority=1

AddStategraphActionHandler("wilson",_G.ActionHandler(AIPC_GIVE_ACTION,"doshortaction"))
AddStategraphActionHandler("wilson_client",_G.ActionHandler(AIPC_GIVE_ACTION,"doshortaction"))


env.AddComponentAction("USEITEM","aipc_action_client",function(inst,doer,target,actions,right)
if not inst or not target then
return
end

local canActOn,remoteAction=inst.components.aipc_action_client:CanActOn(doer,target)
if canActOn then
if remoteAction==true then
table.insert(actions,_G.ACTIONS.AIPC_REMOTE_ACTION)
else
table.insert(actions,_G.ACTIONS.AIPC_ACTION)
end
end
end)



env.AddComponentAction("USEITEM","inventoryitem",function(inst,doer,target,actions,right)
if not inst or not target then
return
end

if
target.components.aipc_action_client~=nil and
target.components.aipc_action_client:CanBeGiveOn(doer,inst)
then
table.insert(actions,_G.ACTIONS.AIPC_GIVE_ACTION)
end
end)


local AIPC_FUEL_ACTION=env.AddAction("AIPC_FUEL_ACTION",LANG.FUEL,function(act)
local doer=act.doer
local item=act.invobject
local target=act.target

if doer~=nil and item~=nil and target~=nil and target.components.aipc_fueled~=nil then
return target.components.aipc_fueled:TakeFuel(item,player)
end

return false
end)

AddStategraphActionHandler("wilson",_G.ActionHandler(AIPC_FUEL_ACTION,"dolongaction"))
AddStategraphActionHandler("wilson_client",_G.ActionHandler(AIPC_FUEL_ACTION,"dolongaction"))


env.AddComponentAction("USEITEM","aipc_fuel",function(inst,doer,target,actions,right)
if not inst or not target then
return
end

if target.components.aipc_fueled~=nil and target.components.aipc_fueled:CanUse(inst,doer) then
table.insert(actions,_G.ACTIONS.AIPC_FUEL_ACTION)
end
end)


local function mapAction(act)

local doer=act.doer
local target=act.target
local act_pos=act:GetActionPoint()


if doer and act_pos and target and target.components.aipc_action then
target.components.aipc_action:DoAction(doer,{
pos=act_pos,
})
end
end


local AIPC_MAP_USE=env.AddAction("AIPC_MAP_USE",LANG.MAP_USE,mapAction)
AIPC_MAP_USE.priority=10
AIPC_MAP_USE.rmb=true
AIPC_MAP_USE.instant=true
AIPC_MAP_USE.map_action=true
AIPC_MAP_USE.map_only=true

AIPC_MAP_USE.closes_map=true
AIPC_MAP_USE.customarrivecheck=function()
return true
end
AIPC_MAP_USE.maponly_checkvalidpos_fn=function(act)
local act_pos=act:GetActionPoint()

return _G.TheWorld.Map:IsAboveGroundAtPoint(act_pos.x,act_pos.y,act_pos.z)
end

AddStategraphActionHandler("wilson",_G.ActionHandler(AIPC_MAP_USE,"doshortaction"))
AddStategraphActionHandler("wilson_client",_G.ActionHandler(AIPC_MAP_USE,"doshortaction"))


local function beAction(act)
local doer=act.doer
local item=act.invobject
local target=act.target

local mergedTarget=target or item


if mergedTarget and mergedTarget:HasTag("aip_client_action") then
_G.aipRPCClient("aipClientComponentAction",doer,mergedTarget,nil,nil)
return true
end

if _G.TheNet:GetIsServer() then

triggerComponentAction(doer,mergedTarget,nil,nil)
else

_G.aipRPC("aipComponentAction",mergedTarget,nil,nil)
end

return true
end


local function ExtraPickupRange(doer,dest)
if dest~=nil then
local target_x,target_y,target_z=dest:GetPoint()

local is_on_water=_G.TheWorld.Map:IsOceanTileAtPoint(target_x,0,target_z) and
not _G.TheWorld.Map:IsPassableAtPoint(target_x,0,target_z)
if is_on_water then
return 0.75
end
end
return 0
end

local AIPC_BE_ACTION=env.AddAction("AIPC_BE_ACTION",LANG.USE,beAction)
local AIPC_BE_TAKE_ACTION=env.AddAction("AIPC_BE_TAKE_ACTION",LANG.TAKE,beAction)
local AIPC_BE_CAST_ACTION=env.AddAction("AIPC_BE_CAST_ACTION",LANG.CAST,beAction)

AIPC_BE_ACTION.map_action=true

AIPC_BE_TAKE_ACTION.extra_arrive_dist=ExtraPickupRange

AddStategraphActionHandler("wilson",_G.ActionHandler(AIPC_BE_ACTION,"doshortaction"))
AddStategraphActionHandler("wilson_client",_G.ActionHandler(AIPC_BE_ACTION,"doshortaction"))
AddStategraphActionHandler("wilson",_G.ActionHandler(AIPC_BE_TAKE_ACTION,"doshortaction"))
AddStategraphActionHandler("wilson_client",_G.ActionHandler(AIPC_BE_TAKE_ACTION,"doshortaction"))
AddStategraphActionHandler("wilson",_G.ActionHandler(AIPC_BE_CAST_ACTION,"quicktele"))
AddStategraphActionHandler("wilson_client",_G.ActionHandler(AIPC_BE_CAST_ACTION,"quicktele"))


env.AddComponentAction("SCENE","aipc_action_client",function(inst,doer,actions,right)
if not inst or not right then
return
end

if
inst.components.aipc_action_client and
inst.components.aipc_action_client:CanBeActOn(doer)
then
table.insert(actions,_G.ACTIONS.AIPC_BE_ACTION)
end

if
inst.components.aipc_action_client and
inst.components.aipc_action_client:CanBeTakeOn(doer)
then
table.insert(actions,_G.ACTIONS.AIPC_BE_TAKE_ACTION)
end
end)


local AIPC_EAT_ACTION=env.AddAction("AIPC_EAT_ACTION",LANG.EAT,function(act)
local doer=act.doer
local item=act.invobject
local target=act.target

if _G.TheNet:GetIsServer() then

triggerComponentAction(doer,item,target,nil)
else

_G.aipRPC("aipComponentAction",item,target,nil)
end

return true
end)

AddStategraphActionHandler("wilson",_G.ActionHandler(AIPC_EAT_ACTION,"eat"))
AddStategraphActionHandler("wilson_client",_G.ActionHandler(AIPC_EAT_ACTION,"eat"))


local AIPC_READ_ACTION=env.AddAction("AIPC_READ_ACTION",LANG.READ,function(act)
local doer=act.doer
local item=act.invobject
local target=act.target

if _G.TheNet:GetIsServer() then

triggerComponentAction(doer,item,target,nil)
else

_G.aipRPC("aipComponentAction",item,target,nil)
end

return true
end)

AddStategraphActionHandler("wilson",_G.ActionHandler(AIPC_READ_ACTION,"book"))
AddStategraphActionHandler("wilson_client",_G.ActionHandler(AIPC_READ_ACTION,"book"))


env.AddComponentAction("INVENTORY","aipc_action_client",function(inst,doer,actions,right)
if inst.components.aipc_action_client:CanBeActOn(doer) then
table.insert(actions,_G.ACTIONS.AIPC_BE_ACTION)
end

if inst.components.aipc_action_client:CanBeCastOn(doer) then
table.insert(actions,_G.ACTIONS.AIPC_BE_CAST_ACTION)
end

if inst.components.aipc_action_client:CanBeRead(doer) then
table.insert(actions,_G.ACTIONS.AIPC_READ_ACTION)
end

if inst.components.aipc_action_client:CanBeEat(doer) then
table.insert(actions,_G.ACTIONS.AIPC_EAT_ACTION)
end
end)



local function doCastAction(act)
local doer=act.doer

local pos=act.pos
local target=act.target
local item=_G.aipGetActionableItem(doer) or act.invobject

if _G.TheNet:GetIsServer() then

triggerComponentAction(doer,item,target,pos~=nil and act:GetActionPoint())
else

_G.aipRPC("aipComponentAction",item,target,pos)
end

return true
end


local AIPC_CASTER_ACTION=env.AddAction("AIPC_CASTER_ACTION",LANG.CAST,doCastAction)
AIPC_CASTER_ACTION.distance=10

AddStategraphActionHandler("wilson",_G.ActionHandler(AIPC_CASTER_ACTION,"quicktele"))
AddStategraphActionHandler("wilson_client",_G.ActionHandler(AIPC_CASTER_ACTION,"quicktele"))


local AIPC_GRID_CASTER_ACTION=env.AddAction("AIPC_GRID_CASTER_ACTION",LANG.CAST,function(act)
local doer=act.doer

local pos=act.pos
local target=act.target
local item=_G.aipGetActionableItem(doer)

if _G.TheNet:GetIsServer() then

triggerComponentAction(doer,item,target,pos~=nil and act:GetActionPoint())
else

SendModRPCToServer(MOD_RPC[env.modname]["aipComponentAction"],doer,item,target,pos)
end

return true
end)
AIPC_GRID_CASTER_ACTION.tile_placer="aip_xinyue_gridplacer"
AIPC_GRID_CASTER_ACTION.theme_music="farming"
AIPC_GRID_CASTER_ACTION.customarrivecheck=function(doer,dest)
local doer_pos=doer:GetPosition()
local target_pos=_G.Vector3(dest:GetPoint())

local tile_x,tile_y,tile_z=_G.TheWorld.Map:GetTileCenterPoint(target_pos.x,0,target_pos.z)
local dist=_G.TILE_SCALE*0.5
if math.abs(tile_x-doer_pos.x) <=dist and math.abs(tile_z-doer_pos.z) <=dist then
return true
end
end

AddStategraphActionHandler("wilson",_G.ActionHandler(AIPC_GRID_CASTER_ACTION,"quicktele"))
AddStategraphActionHandler("wilson_client",_G.ActionHandler(AIPC_GRID_CASTER_ACTION,"quicktele"))


env.AddComponentAction("POINT","aipc_action_client",function(inst,doer,pos,actions,right)
if not inst or not pos or not right then
return
end

if inst.components.aipc_action_client:CanActOnPoint(doer,pos) then
if inst.components.aipc_action_client.gridplacer then
table.insert(actions,_G.ACTIONS.AIPC_GRID_CASTER_ACTION)
else
table.insert(actions,_G.ACTIONS.AIPC_CASTER_ACTION)
end
end
end)


env.AddComponentAction("SCENE","combat",function(inst,doer,actions,right)
if not inst or not right then
return
end

local item=_G.aipGetActionableItem(doer)

if item~=nil and item.components.aipc_action_client:CanActOn(doer,inst) then
table.insert(actions,_G.ACTIONS.AIPC_CASTER_ACTION)
end
end)


local AIPC_LIGHT_ACTION=env.AddAction("AIPC_LIGHT_ACTION",_G.STRINGS.ACTIONS.LIGHT,function(act)
if act.invobject~=nil and act.invobject.components.aipc_lighter~=nil then
if act.doer~=nil then
act.doer:PushEvent("onstartedfire",{ target=act.target })
end
act.invobject.components.aipc_lighter:Light(act.target,act.doer)
return true
end
end)
AIPC_LIGHT_ACTION.distance=3

AddStategraphActionHandler("wilson",_G.ActionHandler(AIPC_LIGHT_ACTION,"catchonfire"))
AddStategraphActionHandler("wilson_client",_G.ActionHandler(AIPC_LIGHT_ACTION,"catchonfire"))
local function canLighter(inst,target)

if
inst:HasTag("aip_lighter_hot") and
target:HasTag("canlight") and not ((target:HasTag("fueldepleted") and not target:HasTag("burnableignorefuel")) or target:HasTag("INLIMBO"))
then
return true
end


if inst:HasTag("aip_lighter") and target:HasTag("aip_can_lighten") then
return true
end
end
env.AddComponentAction("USEITEM","aipc_lighter",function(inst,doer,target,actions)
if canLighter(inst,target) then
table.insert(actions,_G.ACTIONS.AIPC_LIGHT_ACTION)
end
end)
env.AddComponentAction("EQUIPPED","aipc_lighter",function(inst,doer,target,actions,right)
if right and canLighter(inst,target) then
table.insert(actions,_G.ACTIONS.AIPC_LIGHT_ACTION)
end
end)


local ORIGIN_MINE_FN=_G.ACTIONS.MINE.fn
local ORIGIN_MINE_VALID_FN=_G.ACTIONS.MINE.validfn


_G.ACTIONS.MINE.validfn=function(act)
return ORIGIN_MINE_VALID_FN(act) or act.target:HasTag("aip_showcase")
end

_G.ACTIONS.MINE.fn=function(act)
return (
act.target._aipMineFn~=nil and
act.target._aipMineFn(act.target)
) or ORIGIN_MINE_FN(act)
end


local function AipPostComp(componentName,callback)
AddComponentPostInit(componentName,callback)

if dev_mode then
_G.aipPrint("添加组件钩子：" .. componentName)
end
end


AipPostComp("health",function(self)

local originDoDelta=self.DoDelta

function self:DoDelta(amount,overtime,cause,ignore_invincible,afflicter,ignore_absorb,...)

if _G.aipBufferExist(self.inst,"healthCost") and amount < 0 then
amount=amount*2
end

local data={ amount=amount,afflicter=afflicter,cause=cause }
self.inst:PushEvent("aip_healthdelta",data)

if data.amount==0 then
return
end

return originDoDelta(
self,data.amount,overtime,cause,ignore_invincible,afflicter,ignore_absorb,...
)
end

local originDoFireDamage=self.DoFireDamage
function self:DoFireDamage(amount,doer,instant,...)
local data={ amount=amount,doer=doer,instant=instant }
self.inst:PushEvent("aip_health_firedamage",data)

if data.amount==0 then
return
end

return originDoFireDamage(
self,data.amount,doer,instant,...
)
end


function self:LockInvincible(val)
self.aipLockInvincible=val
end


local originSetInvincible=self.SetInvincible
function self:SetInvincible(val,...)
if self.aipLockInvincible~=true then
return originSetInvincible(self,val,...)
end
end

end)


AipPostComp("writeable",function(self)
local originEndWriting=self.EndWriting

function self:EndWriting(...)
if self.onAipEndWriting~=nil then
self.onAipEndWriting()
end

originEndWriting(self,...)
end
end)


AipPostComp("witherable",function(self)
local originProtect=self.Protect

function self:Protect(...)
if self.onAipProtected~=nil then
self.onAipProtected(self.inst)
end

return originProtect(self,...)
end
end)



AipPostComp("oceanfishingrod",function(self)
local originReel=self.Reel

function self:Reel(...)
local originTension=TUNING.OCEAN_FISHING.REELING_SNAP_TENSION
if self.fisher:HasTag("aip_oldone_good_fisher") then

TUNING.OCEAN_FISHING.REELING_SNAP_TENSION=999999
end

local ret=originReel(self,...)

TUNING.OCEAN_FISHING.REELING_SNAP_TENSION=originTension
return ret
end
end)


AipPostComp("tool",function(self)
local originGetEffectiveness=self.GetEffectiveness

function self:GetEffectiveness(action,...)
local num=originGetEffectiveness(self,action,...)


if self.inst.components.inventoryitem~=nil then
local owner=self.inst.components.inventoryitem.owner

if
(
action==_G.ACTIONS.CHOP and
_G.aipBufferExist(
owner,
"aip_oldone_smiling_axe"
)
) or (
action==_G.ACTIONS.MINE and
_G.aipBufferExist(
owner,
"aip_oldone_smiling_mine"
)
)
then
num=num*3
end


if
(action==_G.ACTIONS.CHOP or action==_G.ACTIONS.MINE) and
owner~=nil and owner.components.aipc_pet_owner~=nil
then
local players=_G.aipFindNearPlayers(owner,20)


if #players <=1 then
local skillInfo,skillLv=owner.components.aipc_pet_owner:GetSkillInfo("alone")

if skillInfo~=nil then
local multi=1+skillInfo.multi*skillLv
num=num*multi
end
end
end
end

return num
end
end)


AipPostComp("playercontroller",function(self)
local originDoActionAutoEquip=self.DoActionAutoEquip

function self:DoActionAutoEquip(buffaction,...)

if
buffaction.action==AIPC_GIVE_ACTION or
buffaction.action==_G.ACTIONS.SHAVE
then
return
end

return originDoActionAutoEquip(self,buffaction,...)
end
end)


AipPostComp("drownable",function(self)
local originOnFallInOcean=self.OnFallInOcean
local originDropInventory=self.DropInventory
local originTakeDrowningDamage=self.TakeDrowningDamage


function self:OnFallInOcean(...)
local inv=self.inst.components.inventory

if inv~=nil then

if self.inst.components.aipc_pet_owner~=nil then
local skillInfo=self.inst.components.aipc_pet_owner:GetSkillInfo("winterSwim")

if skillInfo~=nil then

local active_item=inv:GetActiveItem()
local handitem=inv:GetEquippedItem(_G.EQUIPSLOTS.HANDS)

local active_keepondrown=nil
local handitem_keepondrown=nil


if active_item~=nil then
active_keepondrown=active_item.components.inventoryitem.keepondrown
active_item.components.inventoryitem.keepondrown=true
end

if handitem~=nil then
handitem_keepondrown=handitem.components.inventoryitem.keepondrown
handitem.components.inventoryitem.keepondrown=true
end


local ret=originOnFallInOcean(self,...)


if active_item~=nil then
active_item.components.inventoryitem.keepondrown=active_keepondrown
end

if handitem~=nil then
handitem.components.inventoryitem.keepondrown=handitem_keepondrown
end

return ret
end
end
end

return originOnFallInOcean(self,...)
end


function self:DropInventory(...)

if self.inst.components.aipc_pet_owner~=nil then
local skillInfo=self.inst.components.aipc_pet_owner:GetSkillInfo("winterSwim")

if skillInfo~=nil then
return false
end
end


originDropInventory(self,...)
end


function self:TakeDrowningDamage(...)

if self.inst.components.aipc_pet_owner~=nil then
local skillInfo=self.inst.components.aipc_pet_owner:GetSkillInfo("winterSwim")

if skillInfo~=nil then

if self.inst.components.freezable~=nil then
self.inst.components.freezable:Freeze()
end
return false
end
end


return originTakeDrowningDamage(self,...)
end
end)


AipPostComp("healer",function(self)
local originHeal=self.Heal


function self:Heal(target,...)
local originHealth=self.health


if self.aipGetHealth~=nil then
self.health=self.aipGetHealth(self.inst,target,originHealth) or originHealth
end


if target~=nil and target.components.aipc_pet_owner~=nil then
local skillInfo,skillLv=target.components.aipc_pet_owner:GetSkillInfo("acupuncture")

if skillInfo~=nil then
local multi=1+skillInfo.multi*skillLv
self.health=self.health*multi
end
end

local ret=originHeal(self,target,...)

self.health=originHealth
return ret
end
end)


AipPostComp("eater",function(self)
local originTestFood=self.TestFood
local originEat=self.Eat


function self:TestFood(food,testvalues,...)
if food~=nil and food:HasTag("NOCLICK") then
return false
end

return originTestFood(self,food,testvalues,...)
end


function self:Eat(food,...)
if food~=nil and food.components.edible~=nil and food.components.edible.aipStartEat~=nil then
food.components.edible.aipStartEat(food,self.inst)
end

return originEat(self,food,...)
end
end)


AipPostComp("stewer",function(self)
local originStartCooking=self.StartCooking


function self:StartCooking(doer,...)

if doer~=nil then
doer:PushEvent("aipStartCooking",
{cookpot=self.inst}
)
end

return originStartCooking(self,doer,...)
end
end)


AipPostComp("farmplantstress",function(self)
local originSetStressed=self.SetStressed


function self:SetStressed(name,stressed,doer,...)

if doer~=nil then
doer:PushEvent("aipStressPlant",
{plant=self.inst}
)
end

return originSetStressed(self,name,stressed,doer,...)
end
end)


AipPostComp("equippable",function(self)















local originUnequip=self.Unequip
function self:Unequip(owner,...)

if owner~=nil then
owner:PushEvent("aipUnequipItem",
{item=self.inst}
)
end

return originUnequip(self,owner,...)
end
end)


AipPostComp("moisture",function(self)
local oriDoDelta=self.DoDelta


function self:DoDelta(num,no_announce,...)

if num > 0 and self.inst.components.aipc_pet_owner~=nil then
local skillInfo,skillLv=self.inst.components.aipc_pet_owner:GetSkillInfo("rainbow")

if skillInfo~=nil then
num=num*(1+skillInfo.wet*skillLv)
end
end

return oriDoDelta(self,num,no_announce,...)
end
end)


AipPostComp("hunger",function(self)
local oriDoDelta=self.DoDelta


function self:DoDelta(delta,overtime,ignore_invincible,...)

if _G.aipBufferExist(self.inst,"aip_food_plov") and delta < 0 then
delta=delta*(dev_mode and 0 or 0.5)
end

return oriDoDelta(self,delta,overtime,ignore_invincible,...)
end
end)


AipPostComp("thief",function(self)
local originStealItem=self.StealItem


function self:StealItem(victim,itemtosteal,attack,...)

if victim~=nil and _G.aipBufferExist(victim,"fish_froggle") then
return
end

return originStealItem(self,victim,itemtosteal,attack,...)
end
end)


AipPostComp("sanity",function(self)
local oriDoDelta=self.DoDelta


function self:DoDelta(delta,overtime,...)

if delta < 0 and _G.aipBufferExist(self.inst,"veggie_skewers") then
delta=delta*(dev_mode and 0 or 0.5)
end


if delta > 0 and _G.aipBufferExist(self.inst,"aip_food_nest_sausage") then
delta=delta*2
end

return oriDoDelta(self,delta,overtime,...)
end
end)


AipPostComp("weapon",function(self)

if self.inst and not self.inst.components.aipc_snakeoil then
self.inst:AddComponent("aipc_snakeoil")
end


local originOnAttack=self.OnAttack

function self:OnAttack(attacker,target,projectile,...)

if self.inst.components.aipc_snakeoil~=nil then
self.inst.components.aipc_snakeoil:OnWeaponAttack(attacker,target,projectile)
end

return originOnAttack(self,attacker,target,projectile,...)
end
end)
