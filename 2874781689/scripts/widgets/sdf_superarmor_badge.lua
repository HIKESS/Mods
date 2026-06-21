local Badge = require "widgets/badge"
local UIAnim = require "widgets/uianim"
local Text = require "widgets/text"

local superarmorbadge = Class(Badge, function(self, owner)
    Badge._ctor(self, "superarmor", owner)

	self.backing = self.underNumber:AddChild(UIAnim())
	self.backing:GetAnimState():SetBank("status_meter_superarmor")
	self.backing:GetAnimState():SetBuild("status_meter_superarmor")
	self.backing:GetAnimState():PlayAnimation("bg")

	self.anim = self.underNumber:AddChild(UIAnim())
	self.anim:GetAnimState():SetBank("status_meter_superarmor")
	self.anim:GetAnimState():SetBuild("status_meter_superarmor")
	self.anim:GetAnimState():PlayAnimation("anim")
	
	self.superarmor = self.underNumber:AddChild(Image("images/superarmor_icon/superarmor_icon.xml", "superarmor_icon.tex"))

	self.circleframe = self.underNumber:AddChild(UIAnim())
	self.circleframe:GetAnimState():SetBank("status_meter_superarmor")
	self.circleframe:GetAnimState():SetBuild("status_meter_superarmor")
	self.circleframe:GetAnimState():PlayAnimation("frame")

	local superarmor = 0
	self.superarmor:SetScale(superarmor, superarmor, superarmor)
	self.superarmor:SetPosition(0, 0, 0)

	self.num = self:AddChild(Text(BODYTEXTFONT, 33))
    	self.num:SetHAlign(ANCHOR_MIDDLE)
    	self.num:SetPosition(3, 0, 0)
    	self.num:Hide()
    	self:StartUpdating()
end)
function superarmorbadge:SetPercent(val, max)
	max = max or 100
	val = val or 0
	self.anim:GetAnimState():SetPercent("anim", 1 - val)

	local superarmor = 0.2

	self.superarmor:SetScale(superarmor, superarmor, superarmor)

	self.num:SetString(tostring(math.ceil(val * max)))
	
	--Other Addon spacing Stuff
	--Combined Status Mod
	if KnownModIndex:IsModEnabled("workshop-376333686") then

	    if self.bg then
		self.bg:Hide()
	    end

	    self.num:Hide()
	    self.active = false

	else
	    self.num:SetPosition(3, 0, 0) --Default
	end
	
end
function superarmorbadge:OnUpdate(dt)

end

return superarmorbadge