local UIAnim = require "widgets/uianim"

local PRE = 1
local LOOP = 2
local PST = 3

local PRE_SPEED = 5 -- units per second.
local PST_SPEED = 0.5
local LOOPTIME = 2

local SDFPumpkingGuttedOverSplat =  Class(UIAnim, function(self, owner)
    self.owner = owner
    UIAnim._ctor(self, "SDFPumpkingGuttedOverSplat")

    self.time = GetTime()

    self:SetClickable(false)

    self:SetHAnchor(ANCHOR_MIDDLE)
    self:SetVAnchor(ANCHOR_MIDDLE)
    self:SetScaleMode(SCALEMODE_FIXEDSCREEN_NONDYNAMIC)

    self:GetAnimState():SetBank("sdf_pumpking_guttedover")
    self:GetAnimState():SetBuild("sdf_pumpking_guttedover")
    self:GetAnimState():PlayAnimation("ink")
    self:GetAnimState():AnimateWhilePaused(false)

    self:Hide()

end)

function SDFPumpkingGuttedOverSplat:Flash(anim)
    self.time = GetTime()
    self:Show()
    anim = anim or "ink"

    self:GetAnimState():PlayAnimation(anim)
end

return SDFPumpkingGuttedOverSplat
