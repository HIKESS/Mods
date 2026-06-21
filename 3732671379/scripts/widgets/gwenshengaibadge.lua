local Badge = require "widgets/badge"
local UIAnim = require "widgets/uianim"

local Gwen_Shengai_Badge = Class(Badge, function(self, owner, art)
    Badge._ctor(self, "new_hunger", owner)
end)

function Gwen_Shengai_Badge:SetPercent(val, max)
    Badge.SetPercent(self, val, max)
end

return Gwen_Shengai_Badge
