
local dev_mode=aipGetModConfig("dev_mode")=="enabled"

local brain=require("brains/aip_rubik_ghost_brain")

local assets={
Asset("ANIM","anim/aip_rubik_ghost.zip"),
}

local language=aipGetModConfig("language")

local LANG_MAP={
english={
NAME="Mr. Skits",
},
chinese={
NAME="诙谐梦魇",
},
}

local LANG=LANG_MAP[language] or LANG_MAP.english


STRINGS.NAMES.AIP_RUBIK_GHOST=LANG.NAME

local sounds={
attack="dontstarve/sanity/creature2/attack",
attack_grunt="dontstarve/sanity/creature2/attack_grunt",
death="dontstarve/sanity/creature2/die",
idle="dontstarve/sanity/creature2/idle",
taunt="dontstarve/sanity/creature2/taunt",
appear="dontstarve/sanity/creature2/appear",
disappear="dontstarve/sanity/creature2/dissappear",
}


local BaseHealth=dev_mode and 100 or TUNING.WORM_HEALTH
local MultipleHealth=BaseHealth*0.5

local BaseDamage=dev_mode and 4 or 40
local MultipleDamage=BaseDamage*0.5

local BASE_SCALE=1
local MULTIPLE_SCALE=0.2

local function refreshGrow(inst,nextLevel)
local currentLevel=inst.aipGrow or 0


inst.aipGrow=nextLevel
local scale=BASE_SCALE+nextLevel*MULTIPLE_SCALE
inst.Transform:SetScale(scale,scale,scale)


local healthPTG=inst.components.health:GetPercent()
inst.components.health:SetMaxHealth(BaseHealth+nextLevel*MultipleHealth)
inst.components.health:SetPercent(healthPTG)


inst.components.combat:SetDefaultDamage(BaseDamage+nextLevel*MultipleDamage)
end


local RETARGET_CANT_TAGS={}
local RETARGET_ONEOF_TAGS={"character"}
local function Retarget(inst)
local newtarget=FindEntity(
inst,
dev_mode and TUNING.BAT_TARGET_DIST or TUNING.PIG_TARGET_DIST,
function(guy)
return inst.components.combat:CanTarget(guy)
end,
nil,
RETARGET_CANT_TAGS,
RETARGET_ONEOF_TAGS
)

return newtarget
end

local function OnAttacked(inst,data)
inst.components.combat:SetTarget(data.attacker)
inst.components.combat:ShareTarget(data.attacker,30,function(dude)
return dude:HasTag("aip_rubik_ghost") and not dude.components.health:IsDead()
end,99)
end

local function OnDead(inst)
if inst.aipHeart and inst.aipHeart.aipGhosts then
for i,ghost in ipairs(inst.aipHeart.aipGhosts) do
if ghost~=inst and ghost.components.health and not ghost.components.health:IsDead() then

local proj=aipSpawnPrefab(inst,"aip_projectile")
proj.components.aipc_info_client:SetByteArray(
"aip_projectile_color",{ 0,0,0,5 }
)
proj.components.aipc_projectile.speed=10
proj.components.aipc_projectile:GoToTarget(ghost,function()
if ghost.components and ghost.components.health and not ghost.components.health:IsDead() then
refreshGrow(ghost,(ghost.aipGrow or 1)+1)
end
end)
end
end
end
end


local function fn()
local inst=CreateEntity()

inst.entity:AddTransform()
inst.entity:AddAnimState()
inst.entity:AddSoundEmitter()
inst.entity:AddNetwork()

MakeFlyingCharacterPhysics(inst,1,.5)

inst.Transform:SetTwoFaced()


inst:AddTag("shadowcreature")
inst:AddTag("gestaltnoloot")
inst:AddTag("monster")
inst:AddTag("hostile")
inst:AddTag("shadow")
inst:AddTag("notraptrigger")

inst:AddTag("aip_rubik_ghost")

inst.AnimState:SetBank("aip_rubik_ghost")
inst.AnimState:SetBuild("aip_rubik_ghost")
inst.AnimState:PlayAnimation("idle_loop",true)
inst.AnimState:SetMultColour(1,1,1,.7)

inst.entity:SetPristine()

if not TheWorld.ismastersim then
return inst
end

inst:AddComponent("locomotor")
inst.components.locomotor.walkspeed=TUNING.BEEQUEEN_SPEED
inst.components.locomotor:SetTriggersCreep(false)
inst.components.locomotor.pathcaps={ ignorecreep=true }

inst.sounds=sounds

inst:SetStateGraph("SGaip_rubik_ghost")
inst:SetBrain(brain)

inst:AddComponent("health")
inst.components.health:SetMaxHealth(BaseHealth)

inst:AddComponent("knownlocations")

inst:AddComponent("combat")
inst.components.combat.hiteffectsymbol="body"
inst.components.combat:SetDefaultDamage(BaseDamage)
inst.components.combat:SetAttackPeriod(TUNING.BEEQUEEN_ATTACK_PERIOD)

inst.components.combat:SetRetargetFunction(1,Retarget)

inst:ListenForEvent("attacked",OnAttacked)
inst:ListenForEvent("death",OnDead)

inst.persists=false

inst:DoTaskInTime(0.1,function()
refreshGrow(inst,0)
end)

return inst
end

return Prefab("aip_rubik_ghost",fn,assets)
