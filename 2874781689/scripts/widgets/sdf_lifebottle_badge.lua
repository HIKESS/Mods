local Badge = require "widgets/badge"
local UIAnim = require "widgets/uianim"
local Text = require "widgets/text"

local lifebottlebadge = Class(Badge, function(self, owner)
    Badge._ctor(self, "lifebottle", owner)

	local mainScale = 0.4 --0.7

	self.backing = self.underNumber:AddChild(UIAnim())
	self.backing:GetAnimState():SetBank("status_meter")
	self.backing:GetAnimState():SetBuild("status_meter")
	self.backing:GetAnimState():PlayAnimation("bg")
	self.backing:SetScale(mainScale, mainScale, mainScale)

	self.anim = self.underNumber:AddChild(UIAnim())
	self.anim:GetAnimState():SetBank("status_meter_lifebottle")
	self.anim:GetAnimState():SetBuild("status_meter_lifebottle")
	self.anim:GetAnimState():PlayAnimation("anim")
	self.anim:SetScale(mainScale, mainScale, mainScale)

	
	self.lifebottle = self.underNumber:AddChild(Image("images/lifebottle_fill/lifebottle_100.xml", "lifebottle_100.tex"))

	self.circleframe = self.underNumber:AddChild(UIAnim())
	self.circleframe:GetAnimState():SetBank("status_meter")
	self.circleframe:GetAnimState():SetBuild("status_meter")
	self.circleframe:GetAnimState():PlayAnimation("frame")
	self.circleframe:SetScale(mainScale, mainScale, mainScale)

	local lifebottle = 0 --0
	self.lifebottle:SetScale(lifebottle, lifebottle, lifebottle)
	self.lifebottle:SetPosition(0, 0, 0)

	self.num = self:AddChild(Text(BODYTEXTFONT, 33))
    	self.num:SetHAlign(ANCHOR_MIDDLE)
    	self.num:SetPosition(3, 0, 0)
    	self.num:Hide()
    	self:StartUpdating()
end)
function lifebottlebadge:SetPercent(val, max)
	max = TUNING.SDF_LIFEBOTTLE_HEALTH_MAX --max or 100
	val = val or 0
	self.anim:GetAnimState():SetPercent("anim", 1 - val)

	--local lifebottle = 0.5
	local lifebottle = 0.25
	if val >= 1 then
		self.lifebottle:SetTexture("images/lifebottle_fill/lifebottle_100.xml", "lifebottle_100.tex")
	elseif val >= 0.75 then
		self.lifebottle:SetTexture("images/lifebottle_fill/lifebottle_75.xml", "lifebottle_75.tex")	
	elseif val >= 0.50 then
		self.lifebottle:SetTexture("images/lifebottle_fill/lifebottle_50.xml", "lifebottle_50.tex")	
	elseif val > 0 then
		self.lifebottle:SetTexture("images/lifebottle_fill/lifebottle_25.xml", "lifebottle_25.tex")	
	else
		self.lifebottle:SetTexture("images/lifebottle_fill/lifebottle_0.xml", "lifebottle_0.tex")	
	end
	self.lifebottle:SetScale(lifebottle, lifebottle, lifebottle)

	self.num:SetString(tostring(math.ceil(val * max)))

	--Other Addon spacing Stuff
	--Combined Status Mod
	if KnownModIndex:IsModEnabled("workshop-376333686") then
	    local mainScale = 0.3 --0.4
	    self.backing:SetScale(mainScale, mainScale, mainScale)
	    self.anim:SetScale(mainScale, mainScale, mainScale)
	    self.circleframe:SetScale(mainScale, mainScale, mainScale)

	    self.num:Show()
	    self.num:SetPosition(35, 0)
	    self.num:SetScale(.48, .48, .48)

	    if self.bg then
		self.bg:SetScale(.37,.3, 1)
		self.bg:SetPosition(34.5, 0)
	    end

	else
	    self.num:SetPosition(3, 0, 0) --Default
	end
end
function lifebottlebadge:OnUpdate(dt)

end

return lifebottlebadge