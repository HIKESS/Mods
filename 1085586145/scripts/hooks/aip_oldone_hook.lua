local _G=GLOBAL

local function onEyeDiff(inst)
local seeEyes=inst.aip_see_eyes:value()

inst._parent.AnimState:SetClientSideBuildOverrideFlag("aip_see_eyes",seeEyes)
end


AddPrefabPostInit("player_classified",function(inst)
inst.aip_see_eyes=_G.net_bool(inst.GUID,"aip_see_eyes","aip_see_eyes_dirty")

inst:ListenForEvent("aip_see_eyes_dirty",onEyeDiff)
end)
