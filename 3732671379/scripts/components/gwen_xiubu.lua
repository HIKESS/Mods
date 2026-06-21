local function oninuse(self, inuse)
    if inuse then
        self.inst:AddTag("inuse")
    else
        self.inst:RemoveTag("inuse")
    end
end



local gwen_xiubu = Class(function(self, inst)
	self.inst = inst
	self.onusefn = nil
	self.onstopusefn = nil
	self.inuse = false
	self.stopuseevents = nil
end,
nil,
{
    inuse = oninuse,
})

function gwen_xiubu:OnRemoveFromEntity()
    self.inst:RemoveTag("inuse")
end

function gwen_xiubu:SetOnUseFn(fn)
	self.onusefn = fn
end

function gwen_xiubu:SetOnStopUseFn(fn)
	self.onstopusefn = fn
end

function gwen_xiubu:CanInteract()
    return not self.inuse
end

function gwen_xiubu:StartUsingItem()
		self.inuse = true
		if self.onusefn then
			self.inuse = self.onusefn(self.inst) ~= false
		end

		if self.stopuseevents then
			self.stopuseevents(self.inst)
		end
	return self.inuse
end

function gwen_xiubu:StopUsingItem()
	self.inuse = false
	if self.onstopusefn then
		self.onstopusefn(self.inst)
	end
end

return gwen_xiubu