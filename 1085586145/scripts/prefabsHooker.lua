local _G=GLOBAL


local open_beta=_G.aipGetModConfig("open_beta")=="open"


local dev_mode=_G.aipGetModConfig("dev_mode")=="enabled"

local skinUtil=_G.require("utils/aip_skin_util")


local additional_food=_G.aipGetModConfig("additional_food")=="open"


local additional_chesspieces=_G.aipGetModConfig("additional_chesspieces")=="open"



local function AddCozyNestGuestFollower(inst)
if inst.Follower==nil then
inst.entity:AddFollower()
end
end

AddPrefabPostInit("chester",AddCozyNestGuestFollower)
AddPrefabPostInit("hutch",AddCozyNestGuestFollower)
AddPrefabPostInit("glommer",AddCozyNestGuestFollower)



function ShadowFollowerPrefabPostInit(inst)
if not _G.TheWorld.ismastersim then
return
end

if not inst.components.shadow_follower then
inst:AddComponent("shadow_follower")
end
end

AddPrefabPostInit("dragonfly",function(inst) ShadowFollowerPrefabPostInit(inst) end)
AddPrefabPostInit("deerclops",function(inst) ShadowFollowerPrefabPostInit(inst) end)
AddPrefabPostInit("bearger",function(inst) ShadowFollowerPrefabPostInit(inst) end)
AddPrefabPostInit("moose",function(inst) ShadowFollowerPrefabPostInit(inst) end)
AddPrefabPostInit("beequeen",function(inst) ShadowFollowerPrefabPostInit(inst) end)
AddPrefabPostInit("klaus",function(inst) ShadowFollowerPrefabPostInit(inst) end)
AddPrefabPostInit("klaus_sack",function(inst) ShadowFollowerPrefabPostInit(inst) end)
AddPrefabPostInit("antlion",function(inst) ShadowFollowerPrefabPostInit(inst) end)
AddPrefabPostInit("toadstool",function(inst) ShadowFollowerPrefabPostInit(inst) end)
AddPrefabPostInit("toadstool_dark",function(inst) ShadowFollowerPrefabPostInit(inst) end)
AddPrefabPostInit("crabking",function(inst) ShadowFollowerPrefabPostInit(inst) end)
AddPrefabPostInit("hermithouse",function(inst) ShadowFollowerPrefabPostInit(inst) end)
AddPrefabPostInit("malbatross",function(inst) ShadowFollowerPrefabPostInit(inst) end)


local birds={ "crow","robin","robin_winter","canary","quagmire_pigeon","puffin" }
if additional_chesspieces then
for i,name in ipairs(birds) do
AddPrefabPostInit(name,function(inst)

if inst.components.periodicspawner~=nil and inst.components.periodicspawner.randtime~=nil then

inst.components.periodicspawner.randtime=inst.components.periodicspawner.randtime*0.95

local originPrefab=inst.components.periodicspawner.prefab


inst.components.periodicspawner.prefab=function(inst)
local prefab=originPrefab
if type(originPrefab)=="function" then
prefab=originPrefab(inst)
end

if prefab=="seeds" and math.random() <=(dev_mode and 9 or .02) then
return "aip_leaf_note"
end

return prefab
end
end
end)
end
end



function dropLeafNote(inst)
if _G.TheWorld.ismastersim and inst.components.lootdropper~=nil and additional_chesspieces then
inst.components.lootdropper:AddChanceLoot("aip_leaf_note",dev_mode and 1 or 0.1)
end
end

AddPrefabPostInit("leif",dropLeafNote)
AddPrefabPostInit("leif_sparse",dropLeafNote)



function createFootPrint(inst)
inst:ListenForEvent("death",function()

if math.random() <=(dev_mode and 1 or 0.33) then
_G.aipSpawnPrefab(inst,"aip_dragon_footprint")
end
end)
end

AddPrefabPostInit("crawlinghorror",createFootPrint)
AddPrefabPostInit("terrorbeak",createFootPrint)
AddPrefabPostInit("crawlingnightmare",createFootPrint)
AddPrefabPostInit("nightmarebeak",createFootPrint)


local function canActOnLiving(inst,doer,target)
return target.prefab=="aip_joker_face"
end

local function onDoLivingTargetAction(inst,doer,target)

if target.components.fueled~=nil then
target.components.fueled:DoDelta(target.components.fueled.maxfuel/5,doer)

_G.aipRemove(inst)
end
end

AddPrefabPostInit("livinglog",function(inst)

inst:AddComponent("aipc_action_client")
inst.components.aipc_action_client.canActOn=canActOnLiving

if not _G.TheWorld.ismastersim then
return inst
end

inst:AddComponent("aipc_action")
inst.components.aipc_action.onDoTargetAction=onDoLivingTargetAction
end)


local function canActOnGold(inst,doer,target)
return target.prefab=="aip_xinyue_hoe"
end

local function onDoGoldTargetAction(inst,doer,target)

if target.components.fueled~=nil then
target.components.fueled:DoDelta(target.components.fueled.maxfuel,doer)

_G.aipRemove(inst)
end
end

AddPrefabPostInit("goldnugget",function(inst)

inst:AddComponent("aipc_action_client")
inst.components.aipc_action_client.canActOn=canActOnGold

if not _G.TheWorld.ismastersim then
return inst
end

inst:AddComponent("aipc_action")
inst.components.aipc_action.onDoTargetAction=onDoGoldTargetAction
end)


AddPrefabPostInit("moonglass",function(inst)

inst:AddComponent("aipc_fuel")
end)


AddPrefabPostInit("saltrock",function(inst)

inst:AddComponent("aipc_fuel")
end)


AddPrefabPostInit("pigman",function(inst)

if _G.TheWorld.ismastersim and inst.components.lootdropper~=nil then
inst.components.lootdropper:AddChanceLoot("aip_xiyou_card_pigsy",dev_mode and 1 or 0.01)
end
end)


AddPrefabPostInit("bunnyman",function(inst)

if _G.TheWorld.ismastersim and inst.components.lootdropper~=nil then
inst.components.lootdropper:AddChanceLoot("aip_xiyou_card_myth_yutu",dev_mode and 1 or 0.01)
end
end)


AddPrefabPostInit("rabbit",function(inst)

if inst.components.aipc_petable==nil then
inst:AddComponent("aipc_petable")
end


if _G.TheWorld.ismastersim and inst.components.lootdropper~=nil then
inst.components.lootdropper:AddChanceLoot("aip_xiyou_card_myth_yutu",dev_mode and 1 or 0.001)
end
end)



local FROG_LOTUS_SEED_DROP_CHANCE=0.05

AddPrefabPostInit("frog",function(inst)
if _G.TheWorld.ismastersim and inst.components.lootdropper~=nil then

inst.components.lootdropper:AddChanceLoot("aip_endless_lotus_seed",dev_mode and 1 or FROG_LOTUS_SEED_DROP_CHANCE)
end
end)


local function onRock2Worked(inst,data)
if
inst and data and
data.worker and data.worker:HasTag("player") and data.workleft==0 and
_G.aipChance(dev_mode and 1 or 0.01,data.worker,0.01)
then
_G.aipFlingItem(
_G.aipSpawnPrefab(inst,"aip_stone_gourd")
)
end
end

AddPrefabPostInit("rock2",function(inst)
if not _G.TheWorld.ismastersim then
return inst
end

inst:ListenForEvent("worked",onRock2Worked)
end)


local animalList={

"spider","spider_warrior","spider_hider","spider_healer",
"spider_spitter","spider_dropper","spider_moon","spider_water",


"hound","firehound","icehound","moonhound",
"clayhound",
"mutatedhound",
"hedgehound",


"bee",
"killerbee",
"beeguard",


"mandrake_active",


"butterfly",


"stalker_minion1","stalker_minion2",


"mole",


"catcoon",


"slurper",


"lightflier",


"wobster_sheller_land","wobster_moonglass_land",


"slurtle","snurtle",


"monkey","powder_monkey","prime_mate",


"gestalt",
}

for i,prefab in ipairs(animalList) do
AddPrefabPostInit(prefab,function(inst)

if inst.components.aipc_petable==nil then
inst:AddComponent("aipc_petable")
end
end)
end


AddPrefabPostInit("icehound",function(inst)

if _G.TheWorld.ismastersim and inst.components.lootdropper~=nil then
inst.components.lootdropper:AddChanceLoot("aip_ice_houndfire",1)
inst.components.lootdropper:AddChanceLoot("aip_ice_houndfire",dev_mode and 1 or 0.8)
inst.components.lootdropper:AddChanceLoot("aip_ice_houndfire",dev_mode and 1 or 0.6)
end
end)


AddPrefabPostInit("monkey",function(inst)

if _G.TheWorld.ismastersim and inst.components.lootdropper~=nil then
inst.components.lootdropper:AddChanceLoot("aip_xiyou_card_monkey_king",dev_mode and 1 or 0.01)
end
end)


AddPrefabPostInit("stalker",function(inst)

if _G.TheWorld.ismastersim and inst.components.lootdropper~=nil then
inst.components.lootdropper:AddChanceLoot("aip_xiyou_card_white_bone",dev_mode and 1 or 0.1)
end
end)

AddPrefabPostInit("skeleton",function(inst)

if _G.TheWorld.ismastersim and inst.components.lootdropper~=nil then
inst.components.lootdropper:AddChanceLoot("aip_xiyou_card_white_bone",dev_mode and 1 or 0.01)
end
end)

AddPrefabPostInit("skeleton_player",function(inst)

if _G.TheWorld.ismastersim and inst.components.lootdropper~=nil then
inst.components.lootdropper:AddChanceLoot("aip_xiyou_card_white_bone",dev_mode and 1 or 0.01)
end
end)


AddPrefabPostInit("ghost",function(inst)

if _G.TheWorld.ismastersim then
if inst.components.lootdropper==nil then
inst:AddComponent("lootdropper")
end

inst.components.lootdropper:AddChanceLoot("aip_xiyou_card_yama_commissioners",dev_mode and 1 or 0.1)
end
end)


local function onMermDead(inst,data)
local chance=dev_mode and 1 or 0.01
local afflicter=_G.aipGet(data,"afflicter")

if _G.aipChance(chance,afflicter) then
_G.aipFlingItem(
_G.aipSpawnPrefab(inst,"aip_22_fish")
)
end
end

local function onMermPost(inst)
if _G.TheWorld.ismastersim then
inst:ListenForEvent("death",onMermDead)
end
end


AddPrefabPostInit("merm",onMermPost)


AddPrefabPostInit("mermguard",onMermPost)


AddPrefabPostInit("shark",function(inst)

if _G.TheWorld.ismastersim and inst.components.lootdropper~=nil then
inst.components.lootdropper:AddChanceLoot("aip_xiaoyu_hat",1)
end
end)



AddPrefabPostInit("beefalo",function(inst)

if _G.TheWorld.ismastersim and inst.components.periodicspawner~=nil then
local originOnSpawn=inst.components.periodicspawner.onspawn

inst.components.periodicspawner.onspawn=function(inst,prefab,...)
prefab:DoTaskInTime(dev_mode and 2 or 60,function()
local chance=dev_mode and 1 or 0.1
if
prefab:IsValid() and
prefab.prefab=="poop" and
math.random() <=chance and
(
prefab.components.inventoryitem==nil or
prefab.components.inventoryitem:GetContainer()==nil
) and
#_G.aipFindNearEnts(prefab,{ "aip_mud_crab" },20) <=2
then
_G.ReplacePrefab(prefab,"aip_mud_crab",nil,nil,nil,1)
end
end)

if originOnSpawn~=nil then
return originOnSpawn(inst,prefab,_G.unpack(arg))
end
end
end
end)


AddPrefabPostInit("messagebottle",function(inst)

if additional_food and _G.TheWorld.ismastersim and inst.components.mapspotrevealer~=nil then
local originPrereveal=inst.components.mapspotrevealer.prerevealfn

inst.components.mapspotrevealer.prerevealfn=function(inst,doer,...)
local chance=dev_mode and 0.5 or 0.05


if
doer~=nil and
doer.components.builder~=nil and
not doer.components.builder:KnowsRecipe("aip_olden_tea") and
_G.aipChance(chance,doer)
then
local blueprint=_G.aipSpawnPrefab(inst,"aip_olden_tea_blueprint")
local bottle=_G.aipSpawnPrefab(inst,"messagebottleempty")


local container=inst.components.inventoryitem:GetContainer()
inst:Remove()

if container~=nil then
container:GiveItem(bottle)
container:GiveItem(blueprint)
end

return false
end

return originPrereveal(inst,doer,_G.unpack(arg))
end
end
end)


local function getReskinToolTarget(doer,target)
if target==nil then
return nil
end

if target.reskin_tool_target_redirect~=nil and target.reskin_tool_target_redirect:IsValid() then
target=target.reskin_tool_target_redirect
end

if target._playerlink~=nil and target._playerlink~=doer then
return nil
end

if target.reskin_tool_cannot_target_this then
return nil
end

return target
end

local function getAipSkinTarget(target)
if target.prefab==nil or target.SetAipSkin==nil then
return nil,nil
end

local skinConfig=skinUtil.GetConfig(target.prefab)
if skinConfig==nil then
return nil,nil
end

return target,skinConfig
end

AddPrefabPostInit("reskin_tool",function(inst)
if inst.components.spellcaster~=nil then
local originCanCast=inst.components.spellcaster.can_cast_fn
local originSpell=inst.components.spellcaster.spell


if originCanCast and originSpell then
inst.components.spellcaster:SetCanCastFn(function(doer,target,pos,...)
if target==nil then
return originCanCast(doer,target,pos,...)
end

target=getReskinToolTarget(doer,target)
if target==nil then
return false
end

if
table.contains({
"aip_wheat",
"aip_ghost_fire",
"aip_star_fragment",
},target.prefab)
or getAipSkinTarget(target)~=nil
then
return true
end


if dev_mode and target:HasTag("farm_plant") then
return true
end


if dev_mode and target.components.aipc_quality then
return true
end

return originCanCast(doer,target,pos,...)
end)

inst.components.spellcaster:SetSpellFn(function(tool,target,pos,...)
local caster=...
local originalTarget=target
target=getReskinToolTarget(caster,target)

if originalTarget~=nil and target==nil then
return
end

if target then
local aipSkinTarget,aipSkinConfig=getAipSkinTarget(target)


if target.prefab=="aip_wheat" then
_G.aipSpawnPrefab(target,"explode_reskin")
_G.aipReplacePrefab(target,"grass")
return


elseif dev_mode and target:HasTag("farm_plant") then
target.force_oversized=true

if target.components.growable~=nil then
for i=1,100 do
if target.components.pickable~=nil and target.components.pickable:CanBePicked() then
break
end

local oldStage=target.components.growable.stage
if not target.components.growable:DoGrowth() then
break
end
if target.components.growable.stage==oldStage then
break
end
end
end

return


elseif dev_mode and target.components.aipc_quality then
target.components.aipc_quality:DoDelta(1)
return


elseif aipSkinTarget~=nil then
_G.aipSpawnPrefab(aipSkinTarget,"explode_reskin")
if aipSkinTarget.RandomAipSkin~=nil then

aipSkinTarget:RandomAipSkin()
else
local nextSkin=aipSkinConfig.GetNextBuildSkin(aipSkinTarget.skinname)
aipSkinTarget:SetAipSkin(nextSkin)
end
if aipSkinTarget.SoundEmitter~=nil then
aipSkinTarget.SoundEmitter:PlaySound("dontstarve/common/together/skin_change")
end
return


elseif target.prefab=="aip_ghost_fire" and target.RandomColor then
target.RandomColor(target)
return


elseif target.prefab=="aip_star_fragment" and target.RandomColor then
target.RandomColor(target)
return
end
end
return originSpell(tool,target,pos,...)
end)
end
end
end)


AddPrefabPostInit("flint",function(inst)
inst:AddTag("allow_action_on_impassable")

if inst.components.aipc_water_drift==nil then
inst:AddComponent("aipc_water_drift")
end
end)


local function onSquidDead(inst)
local chance=_G.aipBufferExist(inst,"oldonePoison") and 1 or 0.1

if math.random() <=chance then
_G.aipFlingItem(
_G.aipSpawnPrefab(inst,"aip_oldone_fisher")
)
end
end

AddPrefabPostInit("squid",function(inst)
inst:ListenForEvent("death",onSquidDead)
end)


local function onPigmanDead(inst)
local chance=dev_mode and 1 or 0.05

if math.random() <=chance then
_G.aipFlingItem(
_G.aipSpawnPrefab(inst,"aip_storybook")
)
end
end

AddPrefabPostInit("pigman",function(inst)
inst:ListenForEvent("death",onPigmanDead)
end)





























local function useDriftwood(inst)
inst.components.beard:Reset()
inst.components.beard.bits=3
_G.aipRemove(inst)
end

AddPrefabPostInit("driftwood_log",function(inst)
if not _G.TheWorld.ismastersim then
return inst
end


inst:AddComponent("beard")
inst.components.beard.bits=3
inst.components.beard.prize="aip_cold_skin"
inst:ListenForEvent("shaved",useDriftwood)
end)


local function bullkelpCanBeActOn(inst,doer)
return doer~=nil and doer:HasTag("aip_xiaoyu_picker")
end

local function bullkelpOnDoAction(inst,doer)
if doer~=nil and doer.components.inventory~=nil then
local root=_G.aipReplacePrefab(inst,"bullkelp_root")
doer.components.inventory:GiveItem(root)
end
end

AddPrefabPostInit("bullkelp_plant",function(inst)
inst:AddComponent("aipc_action_client")
inst.components.aipc_action_client.canBeTakeOn=bullkelpCanBeActOn

if not _G.TheWorld.ismastersim then
return inst
end

inst:AddComponent("aipc_action")
inst.components.aipc_action.onDoAction=bullkelpOnDoAction
end)


local function onSignTrigger(inst,trigger)
if inst~=nil and inst.components.inspectable~=nil then
local players=_G.aipFindNearPlayers(trigger,5)
local triggerPT=trigger:GetPosition()

for _,player in ipairs(players) do

if player:GetPosition().y < 1 then

if player.components.talker~=nil then
player.components.talker:Say(
inst.components.inspectable:GetDescription(player)
)
end


if player.components.timer~=nil then
player.components.timer:StartTimer("aip_reading_sign",2)
end
end
end
end
end

AddPrefabPostInit("homesign",function(inst)

inst:AddTag("aip_particles")

if not _G.TheWorld.ismastersim then
return inst
end

inst._aip_particles_trigger=onSignTrigger
end)


AddPrefabPostInit("pigking",function(inst)
if not _G.TheWorld.ismastersim then
return inst
end

inst:AddComponent("aipc_pig_king_train")
end)


AddPrefabPostInit("grass",function(inst)
if not _G.TheWorld.ismastersim then
return inst
end


if additional_food then
if inst.components.pickable~=nil then
local oriPickedFn=inst.components.pickable.onpickedfn

inst.components.pickable.onpickedfn=function(inst,picker,...)
oriPickedFn(inst,picker,...)

local PROBABILITY=dev_mode and 1 or 0.01


if math.random() <=PROBABILITY then
local wheat=_G.aipReplacePrefab(inst,"aip_wheat")
wheat.components.pickable:MakeEmpty()
end
end
end


if inst.components.halloweenmoonmutable==nil then
inst:AddComponent("halloweenmoonmutable")
inst.components.halloweenmoonmutable:SetPrefabMutated("aip_wheat")
end
end
end)

local function spawnNearBy(inst,prefabName,dist,maxCount)
dist=dist or 40
maxCount=maxCount or 999

local pos=_G.aipGetSecretSpawnPoint(inst:GetPosition(),dist,dist+5,5)
if pos~=nil then
local prefab=_G.SpawnPrefab(prefabName)
prefab.Transform:SetPosition(pos.x,pos.y,pos.z)


local ents=_G.aipFindNearEnts(prefab,{ prefabName },20)
if #ents > maxCount then
prefab:Remove()
return false
else
return true
end


local buildings=TheSim:FindEntities(
pos.x,pos.y,pos.z,
12,nil,nil,{ "structure","wall" }
)
if #buildings > 0 then
prefab:Remove()
return false
end
end

return false
end

local function spawnNearPlayer(prefabName,dist,maxCount)
for i,player in ipairs(_G.AllPlayers) do
if not player:HasTag("playerghost") and player.entity:IsVisible() then
spawnNearBy(player,prefabName,dist,maxCount)
end
end
end

local function randomFlower(pt)
if pt==nil then
return
end

local flowers={
"aip_four_flower",
"aip_watering_flower",
"aip_oldone_rock",
"aip_oldone_salt_hole",
"aip_oldone_lotus",
"aip_oldone_pot",
"aip_oldone_tree",
"aip_oldone_once",
"aip_oldone_black",
"aip_oldone_jellyfish",
"aip_oldone_rice",
}


if _G.TheWorld.state.isspring then
if dev_mode then
flowers={}
end

table.insert(flowers,"aip_oldone_plant_flower")
end


if _G.TheWorld.state.issummer then
if dev_mode then
flowers={}
end

table.insert(flowers,"aip_oldone_hot")
end


if _G.TheWorld.state.isautumn then
if dev_mode then
flowers={}
end

table.insert(flowers,"aip_oldone_leaves")
end


if _G.TheWorld.state.iswinter then
if dev_mode then
flowers={}
end

table.insert(flowers,"aip_oldone_snowman")
end


if dev_mode then
flowers={ "aip_oldone_rice" }
end

local flowerName=_G.aipRandomEnt(flowers)
local flower=_G.aipSpawnPrefab(nil,flowerName,pt.x,pt.y,pt.z)

if dev_mode then
_G.aipPrint("Create Puzzle:",flowerName)
end

flower:AddComponent("perishable")
flower.components.perishable:StartPerishing()
flower.components.perishable:SetPerishTime(TUNING.PERISH_MED)
flower.components.perishable.onperishreplacement="seeds"
end

if _G.TheNet:GetIsServer() or _G.TheNet:IsDedicated() then
AddPrefabPostInit("world",function (inst)

if additional_food then

inst:WatchWorldState("season",function ()
spawnNearPlayer("aip_sunflower")
end)
end


inst:WatchWorldState("isnight",function(_,isnight)
if isnight then

inst:DoTaskInTime(1,function()
local chance=dev_mode and 1 or 0.05

if math.random() < chance then
local spawnPoint=_G.aipFindRandomEnt("spawnpoint_multiplayer","spawnpoint_master")
spawnNearBy(spawnPoint,"aip_oldone_plant",120,3)
end
end)


inst:DoTaskInTime(0.5,function()
local chance=dev_mode and 1 or 0.3

if math.random() < chance then
local ent=TheSim:FindFirstEntityWithTag("aip_olden_flower")
if ent==nil then
local pt=_G.aipFindRandomPointInLand(5)


randomFlower(pt)
end
end


for _,player in pairs(_G.AllPlayers) do
if _G.aipChance(0,player,dev_mode and 1 or 0.05) then
local tgt=_G.aipGetSpawnPoint(
player:GetPosition(),
dev_mode and 5 or nil
)
randomFlower(tgt)
end
end
end)
end
end)



inst:WatchWorldState("season",function ()
inst:DoTaskInTime(1.5,function()
local pigking=_G.aipFindEnt("pigking")
if pigking then
local pos=pigking:GetPosition()
local ents=TheSim:FindEntities(pos.x,pos.y,pos.z,100,{ "aip_oldone_thestral" })

if #ents==0 then
_G.aipSpawnPrefab(pigking,"aip_oldone_thestral")
end
end
end)
end)



inst:ListenForEvent("entity_death",function (world,data)
local aipc_oldone=_G.aipGet(data,"afflicter|components|aipc_oldone")

if
data~=nil and data.inst~=nil and
aipc_oldone~=nil and
data.afflicter~=nil and data.afflicter:HasTag("player")
then

local chance=aipc_oldone:GetWorldDropTimes()==0 and .01 or .001

if math.random() <=(dev_mode and 1 or chance) then

aipc_oldone:DoWorldDropTimesDelta(1)

local itemList={
"aip_prosperity_seed",
"aip_bloodstone",
"aip_liver",
"aip_ockham_razor",
"aip_aztecs_coin",
"aip_steel_ball",
"structure",
"aip_glory_hand",
"aip_dream_stone",
"aip_stone_mask",
"aip_hearthstone",
"aip_armor_king",
"aip_travel_boots",
"aip_luna_watch",
"aip_doomsday_clock",
"aip_phoenix_feather",
"aip_ocean_tear",
}

local structureList={
"aip_forever",
"aip_oldone_thrower",
}


if dev_mode then
itemList={ itemList[#itemList] }
structureList={ structureList[#structureList] }
end


local rndPrefab=_G.aipRandomEnt(itemList)
if rndPrefab=="structure" then
rndPrefab=_G.aipRandomEnt(structureList)


local targetPT=_G.aipGetSpawnPoint(data.inst:GetPosition(),5)

local proj=_G.aipSpawnPrefab(data.inst,"aip_projectile")
proj.components.aipc_projectile:GoToPoint(targetPT,function()
_G.aipSpawnPrefab(proj,rndPrefab)
_G.aipSpawnPrefab(proj,"aip_shadow_wrapper").DoShow()

end)
else

_G.aipFlingItem(
_G.aipSpawnPrefab(data.inst,rndPrefab)
)
end


end
end
end)
end)
end

local cookbookAtlas={
"aip_oldone_plant_broken",
"aip_oldone_deer_eye_fruit",
}


local VEGGIES=_G.require('prefabs/aip_veggies_list')

for name,data in pairs(VEGGIES) do
local fullname="aip_veggie_"..name
table.insert(cookbookAtlas,fullname)
env.AddIngredientValues({fullname},data.tags or {},data.cancook or false,data.candry or false)
end


local LOTUS_FLOWER_PREFAB="aip_endless_lotus_flower"
local LOTUS_LEAF_PREFAB="aip_endless_lotus_leaf"
local LOTUS_ROOT_PREFAB="aip_endless_lotus_root"
env.AddIngredientValues({ LOTUS_FLOWER_PREFAB },{ veggie=.5 })
env.AddIngredientValues({ LOTUS_LEAF_PREFAB },{ inedible=1 })
env.AddIngredientValues({ LOTUS_ROOT_PREFAB },{ veggie=.5 })
env.RegisterInventoryItemAtlas(
"images/inventoryimages/"..LOTUS_FLOWER_PREFAB..".xml",
LOTUS_FLOWER_PREFAB..".tex"
)
env.RegisterInventoryItemAtlas(
"images/inventoryimages/"..LOTUS_LEAF_PREFAB..".xml",
LOTUS_LEAF_PREFAB..".tex"
)
env.RegisterInventoryItemAtlas(
"images/inventoryimages/"..LOTUS_ROOT_PREFAB..".xml",
LOTUS_ROOT_PREFAB..".tex"
)


local function PatchFlowerSaladRecipe(cooker)
local cooking=_G.require("cooking")
local recipes=cooking.recipes~=nil and cooking.recipes[cooker] or nil
local recipe=recipes~=nil and recipes.flowersalad or nil

if recipe==nil or recipe.aip_lotus_patched then
return
end

local oldTest=recipe.test
recipe.test=function(cooker,names,tags)
if names[LOTUS_FLOWER_PREFAB]~=nil then
local cactusFlower=names.cactus_flower
names.cactus_flower=(cactusFlower or 0)+names[LOTUS_FLOWER_PREFAB]

local result=oldTest(cooker,names,tags)
names.cactus_flower=cactusFlower

return result
end

return oldTest(cooker,names,tags)
end

recipe.aip_lotus_patched=true
end

for _,cooker in ipairs({ "cookpot","portablecookpot","archive_cookpot" }) do
PatchFlowerSaladRecipe(cooker)
end


env.AddIngredientValues(
{"aip_oldone_plant_broken"},
{ indescribable=2 },
false,
false
)

env.RegisterInventoryItemAtlas("images/inventoryimages/aip_oldone_plant_broken.xml","aip_oldone_plant_broken.tex")


env.AddIngredientValues(
{"aip_oldone_deer_eye_fruit"},
{ indescribable=1,fruit=.5 }
)


env.AddIngredientValues(
{"aip_cold_skin"},
{ starch=0.1 }
)


for _,atlas in ipairs(cookbookAtlas) do
env.RegisterInventoryItemAtlas(
"images/inventoryimages/"..atlas..".xml",
atlas..".tex"
)
end
