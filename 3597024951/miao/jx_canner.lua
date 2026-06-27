AddClientModRPCHandler("JX", "JX_OpenCan", function()
    GLOBAL.TheFocalPoint.SoundEmitter:PlaySound("jx_canner/jx_canner/open_can")
end)

AddComponentPostInit("stackable",function(self)
    local old_Put = self.Put
    function self:Put(item, source_pos, ...)
      if item:HasTag("jx_can") and self:CanStackWith(item) then
        local newtotal = self.stacksize + item.components.stackable.stacksize
        local newsize = math.min(self.maxsize, newtotal)
        local numberadded = newsize - self.stacksize
        self.inst.product_percent = (self.stacksize * self.inst.product_percent + numberadded * item.product_percent) / ( numberadded + self.stacksize )
      end
      return old_Put(self, item, source_pos, ...)
    end
end)