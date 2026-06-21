local Multithruster = Class(function(self, inst)
    self.inst = inst
	self.rustfn = nil
end)

function Multithruster:SetThrustfn(fn)
	self.rustfn = fn
end		

function Multithruster:DoThrust(doer, target)
	if self.rustfn ~= nil then
		self.rustfn(self.inst ,doer, target)
		return true
	end
end

function Multithruster:StartThrusting()
	if self.inst:HasTag("wiltonmod_sharpbone_weapon") then
        self.inst.thrust_time = 0
	end	
	return true
end

function Multithruster:StopThrusting()
	if self.inst:HasTag("wiltonmod_sharpbone_weapon") then
        self.inst.thrust_time = 0
	end
	return true
end


return Multithruster
