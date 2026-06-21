local SDFKey_Item = Class(function (self,inst)
    self.inst=inst
    self.keyItem_ID = nil

    self.cached_player_join_fn = function(world, player) OnPlayerJoined(self, player) end
    self.cached_new_player_spawned_fn = function(world, player) OnNewPlayerSpawned(self, player) end

    self.inst:ListenForEvent("ms_playerjoined", self.cached_player_join_fn, TheWorld)
    self.inst:ListenForEvent("ms_newplayerspawned", self.cached_new_player_spawned_fn, TheWorld)
end)

OnPlayerJoined = function(self, player)
    if player ~= nil and player.prefab == "sdf" then
	if self.keyItem_ID == player.userid then
	    player.components.sdf_key_item_inventory:SetKeyItem(self.inst, player)
	end
    end
end

OnNewPlayerSpawned = function(self, player)
    if player ~= nil and player.prefab == "sdf" then
	if self.keyItem_ID == player.userid then
	    player.components.sdf_key_item_inventory:SetKeyItem(self.inst, player)
	end
    end
end

function SDFKey_Item:GetKeyItemID()
    return self.keyItem_ID
end

function SDFKey_Item:SetKeyItemID(num)
    self.keyItem_ID = num
end

function SDFKey_Item:OnSave()
    return{
	    keyItem_ID =self.keyItem_ID,
    }
end

function SDFKey_Item:OnLoad(data)
    if data.keyItem_ID ~= nil and self.keyItem_ID ~= data.keyItem_ID then
	self.keyItem_ID = data.keyItem_ID or nil
    end
end

return SDFKey_Item