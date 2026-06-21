local Badge = require "widgets/badge"
local UIAnim = require "widgets/uianim"
local Text = require "widgets/text"

local soulbadge = Class(Badge, function(self, owner)
    Badge._ctor(self, "soul", owner)

	self.backing = self.underNumber:AddChild(UIAnim())
	self.backing:GetAnimState():SetBank("status_meter")
	self.backing:GetAnimState():SetBuild("status_meter")
	self.backing:GetAnimState():PlayAnimation("bg")

    if TUNING.SDF_FATES_ARROW == true then
	self.anim = self.underNumber:AddChild(UIAnim())
	self.anim:GetAnimState():SetBank("status_meter_soul_fatesarrow")
	self.anim:GetAnimState():SetBuild("status_meter_soul_fatesarrow")
	self.anim:GetAnimState():PlayAnimation("anim")
    else
	self.anim = self.underNumber:AddChild(UIAnim())
	self.anim:GetAnimState():SetBank("status_meter_soul")
	self.anim:GetAnimState():SetBuild("status_meter_soul")
	self.anim:GetAnimState():PlayAnimation("anim")
    end

	
	self.chalicesoul = self.underNumber:AddChild(Image("images/chalice_souls/chalice_soul_100.xml", "chalice_soul_100.tex"))

	self.circleframe = self.underNumber:AddChild(UIAnim())
	self.circleframe:GetAnimState():SetBank("status_meter")
	self.circleframe:GetAnimState():SetBuild("status_meter")
	self.circleframe:GetAnimState():PlayAnimation("frame")

	local chalicesoul = 0
	self.chalicesoul:SetScale(chalicesoul, chalicesoul, chalicesoul)
	self.chalicesoul:SetPosition(0, 0, 0)

	self.num = self:AddChild(Text(BODYTEXTFONT, 33))
    	self.num:SetHAlign(ANCHOR_MIDDLE)
    	self.num:SetPosition(3, 0, 0)
    	self.num:Hide()
    	self:StartUpdating()
end)
function soulbadge:SetPercent(val, max)
	max = max or 100
	val = val or 0
	self.anim:GetAnimState():SetPercent("anim", 1 - val)

	--local chalicesoul = 0.65
	local chalicesoul = 0.2
	if val >= 1 then
		self.chalicesoul:SetTexture("images/chalice_souls/chalice_soul_100.xml", "chalice_soul_100.tex")
	elseif val >= 0.75 then
		self.chalicesoul:SetTexture("images/chalice_souls/chalice_soul_75.xml", "chalice_soul_75.tex")	
	elseif val >= 0.5 then
		self.chalicesoul:SetTexture("images/chalice_souls/chalice_soul_50.xml", "chalice_soul_50.tex")	
	elseif val >= 0.25 then
		self.chalicesoul:SetTexture("images/chalice_souls/chalice_soul_25.xml", "chalice_soul_25.tex")	
	else
		self.chalicesoul:SetTexture("images/chalice_souls/chalice_soul_0.xml", "chalice_soul_0.tex")	
	end
	self.chalicesoul:SetScale(chalicesoul, chalicesoul, chalicesoul)

	self.num:SetString(tostring(math.ceil(val * max)))
	
	--Other Addon spacing Stuff
	--Combined Status Mod
	if KnownModIndex:IsModEnabled("workshop-376333686") then
	    self.num:Show()
	    self.num:SetPosition(1, -40, 0)
	    self.num:SetScale(.75, .75, .75)
	    if self.show_progress then
		if self.show_remaining then
		    self.maxnum:SetString(tostring(math.floor(val * max)))
		end
	    else
		--self.maxnum:SetString(tostring(max))
	    end
	else
	    self.num:SetPosition(3, 0, 0) --Default
	end
end
function soulbadge:OnUpdate(dt)

end

return soulbadge