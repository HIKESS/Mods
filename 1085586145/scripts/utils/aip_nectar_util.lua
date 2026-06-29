local cooking=require("cooking")

local function extends(origin,target)
for k,v in pairs(target) do
origin[k]=v
end

return origin
end

local function getNectarValues(item)
local values={}

if not item then
return values
end

local prefab=item.prefab


if item:HasTag("aip_nectar_material") then

if item:HasTag("frozen") then
values.frozen=2
end
if item:HasTag("honeyed") then
values.sweetener=2
end
if item:HasTag("aip_exquisite") then
values.exquisite=1
end
if item:HasTag("aip_nectar") then
values.nectar=1


for nectarTag,nectarTagVal in pairs (item.nectarValues or {}) do
local cloneTagVal=nectarTagVal

if nectarTag=="exquisite" then

cloneTagVal=0

elseif nectarTag=="frozen" then

cloneTagVal=math.ceil(nectarTagVal/2)
end
values[nectarTag]=(values[nectarTag] or 0)+cloneTagVal
end
end
end


if prefab=="petals" then

values.flower=1
elseif prefab=="petals_evil" then

values.flower=1
values.terrible=0.5
elseif prefab=="moon_tree_blossom" or prefab=="cactus_flower" then

values.flower=2
end



if prefab=="lightbulb" then
values.light=1


elseif prefab=="wormlight" then
values.light=2


elseif prefab=="wormlight_lesser" then
values.light=1


elseif prefab=="poop" or prefab=="guano" then
values.terrible=2


elseif prefab=="spoiled_food" or prefab=="ash" or prefab=="beardhair" then
values.terrible=1


elseif prefab=="lureplantbulb" then
values.vampire=1


elseif prefab=="stinger" then
values.damage=1


elseif prefab=="spidereggsack" or prefab=="walrus_tusk" then
values.damage=2
end


local ingredient=cooking.ingredients[prefab]
if ingredient and ingredient.tags then

if
ingredient.tags.fruit or
ingredient.tags.sweetener or
ingredient.tags.frozen or
ingredient.tags.starch
then
values=extends(values,ingredient.tags)
end
end

return values
end

return getNectarValues