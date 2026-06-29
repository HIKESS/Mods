local PigKingTrain=Class(function(self,inst)
self.inst=inst


self.inst:ListenForEvent("trade",function(inst,data)
if data.giver and data.item and data.item.prefab=="aip_train_ticket" then
self:StartTrain(data.giver)
end
end)
end)


function PigKingTrain:StartTrain(doer)
end

return PigKingTrain














