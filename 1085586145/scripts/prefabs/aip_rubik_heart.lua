
local dev_mode=aipGetModConfig("dev_mode")=="enabled"

local BaseHealth=dev_mode and 100 or TUNING.LEIF_HEALTH

local assets={
Asset("ANIM","anim/aip_rubik_heart.zip"),
}

local language=aipGetModConfig("language")

local LANG_MAP={
english={
NAME="Skits Heart",
DESC="A beating heart",
},
chinese={
NAME="诙谐之心",
DESC="一颗跳动的心脏",
},
}

local LANG=LANG_MAP[language] or LANG_MAP.english


STRINGS.NAMES.AIP_RUBIK_HEART=LANG.NAME
STRINGS.CHARACTERS.GENERIC.DESCRIBE.AIP_RUBIK_HEART=LANG.DESC


local loot={
"aip_fake_fly_totem_blueprint",
"aip_wizard_hat",
}

local createProjectile=require("utils/aip_vest_util").createProjectile



local function refreshGhosts(inst)
inst.aipGhosts=aipFilterTable(inst.aipGhosts or {},function(ghost)
return ghost and ghost:IsValid() and ghost.components.health and not ghost.components.health:IsDead()
end)
end

local function onHit(inst)
inst.SoundEmitter:PlaySound("dontstarve/creatures/leif/livingtree_hit")


if inst.AnimState:IsCurrentAnimation("idle") then
inst.AnimState:PlayAnimation("hit")
inst.AnimState:PushAnimation("idle",true)
end

if
inst.components.health~=nil and
inst.components.health:GetPercent() < 0.5
then
refreshGhosts(inst)


if inst.components.timer~=nil and not inst.components.timer:TimerExists("aip_eat_snity") then
inst.components.timer:StartTimer("aip_eat_snity",5)
inst.AnimState:PlayAnimation("spell")

inst:DoTaskInTime(.5,function()
if inst.components.health:IsDead() then
return
end

local players=aipFindNearPlayers(inst,10)

for i,player in ipairs(players) do
if player.components.sanity~=nil and player.components.sanity:GetPercent() > 0 then
player.components.sanity:DoDelta(-30)

createProjectile(player,inst,function()
if not inst.components.health:IsDead() then
inst.components.health:DoDelta(50)
end
end,{ 0,0,0,5 })
end
end
end)
elseif #inst.aipGhosts <=0 and not inst.components.timer:TimerExists("aip_spawn_ghost") then
inst.components.timer:StartTimer("aip_spawn_ghost",10)


local homePos=inst:GetPosition()
local ghostPt=aipGetSpawnPoint(homePos,5)

if ghostPt~=nil then
createProjectile(
inst,ghostPt,function(proj)
local effect=aipSpawnPrefab(proj,"aip_shadow_wrapper",nil,0.1)
effect.DoShow()


if not inst.components.health:IsDead() then
local ghost=aipSpawnPrefab(proj,"aip_rubik_ghost")
if ghost.components.knownlocations then
ghost.components.knownlocations:RememberLocation("home",homePos)
end

ghost.aipHeart=inst
table.insert(inst.aipGhosts,ghost)
end
end,{ 0,0,0,5 }
)
end
end
end
end

local function OnDead(inst)
if inst.aipGhosts then

local tmpGhosts=inst.aipGhosts
inst.aipGhosts={}

for i,ghost in ipairs(tmpGhosts) do
ghost.aipHeartDead=true
if ghost.components.health and not ghost.components.health:IsDead() then
ghost.components.health:Kill()
end
end
end

inst:DoTaskInTime(0.1,function()
inst.AnimState:PlayAnimation("dead")
inst:ListenForEvent("animover",function()
aipSpawnPrefab(inst,"aip_shadow_wrapper",nil,4).DoShow()
local pt=inst:GetPosition()
pt.y=4
inst.components.lootdropper:DropLoot(pt)
inst:Remove()
end)
end)
end


local function fn()
local inst=CreateEntity()

inst.entity:AddTransform()
inst.entity:AddAnimState()
inst.entity:AddSoundEmitter()
inst.entity:AddDynamicShadow()
inst.entity:AddNetwork()

inst.DynamicShadow:SetSize(.8,.5)

MakeFlyingCharacterPhysics(inst,0,0)

inst:AddTag("aip_shadowcreature")
inst:AddTag("gestaltnoloot")
inst:AddTag("monster")
inst:AddTag("hostile")
inst:AddTag("shadow")
inst:AddTag("notraptrigger")

inst.AnimState:SetBank("aip_rubik_heart")
inst.AnimState:SetBuild("aip_rubik_heart")
inst.AnimState:PlayAnimation("idle",true)

inst.entity:SetPristine()

if not TheWorld.ismastersim then
return inst
end

inst:AddComponent("inspectable")

inst:AddComponent("timer")

inst:AddComponent("health")
inst.components.health:SetMaxHealth(BaseHealth)
inst.components.health.nofadeout=true

inst:AddComponent("combat")
inst.components.combat:SetOnHit(onHit)

inst:AddComponent("lootdropper")
inst.components.lootdropper:SetLoot(loot)

inst:ListenForEvent("death",OnDead)

inst.persists=false

return inst
end

return Prefab("aip_rubik_heart",fn,assets)
