

local _G=GLOBAL

local dev_mode=_G.aipGetModConfig("dev_mode")=="enabled"

if not dev_mode then
return
end











local RANGE=1900


local function inPlace(x,z,offset)
offset=offset or 50
return x >=RANGE-offset and x <=RANGE+offset and
z >=RANGE-offset and z <=RANGE+offset
end

AddPrefabPostInit("world",function(inst)
local map=_G.getmetatable(inst.Map).__index
if map then
local old_IsAboveGroundAtPoint=map.IsAboveGroundAtPoint
map.IsAboveGroundAtPoint=function(self,x,y,z,...)
if inPlace(x,z) then

















return true
end
return old_IsAboveGroundAtPoint(self,x,y,z,...)
end

local old_IsVisualGroundAtPoint=map.IsVisualGroundAtPoint
map.IsVisualGroundAtPoint=function(self,x,y,z,...)
if inPlace(x,z) then

















return true
end
return old_IsVisualGroundAtPoint(self,x,y,z,...)
end

local old_GetTileCenterPoint=map.GetTileCenterPoint
map.GetTileCenterPoint=function(self,x,y,z)
if inPlace(x,z,0) then
return math.floor(x/4)*4+2,0,math.floor(z/4)*4+2
end
if z then
return old_GetTileCenterPoint(self,x,y,z)
else
return old_GetTileCenterPoint(self,x,y)
end
end
end
end)
