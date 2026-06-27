local Jx_Refresh = Class(function(self, inst)
    self.inst = inst
    self.perrefreshpercent = .1
end)

function Jx_Refresh:SetPerRefrshPercent(percent)
  self.perrefreshpercent = percent
end

return Jx_Refresh