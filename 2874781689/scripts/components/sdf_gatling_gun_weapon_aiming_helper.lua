-- Clientside component for storing cached Vector3 aiming point of Gatling Gun

local SDFGatling_Gun_Weapon_Aiming_Helper = Class(function(self, inst)
    self.inst = inst
    self.vector3_point = nil
    self.minigun_aim_task_client = nil
	
    if self.minigun_aim_task_client == nil then
	self.minigun_aim_task_client = self.inst:DoPeriodicTask(.1, function(inst)
	    local using_mouse = inst.components.playercontroller ~= nil and inst.components.playercontroller:UsingMouse()
			
	    if inst == nil or not inst:HasTag("has_sdf_gatling_gun") or not inst:HasTag("sdf_gatling_gun_shooting") or not using_mouse then
	    if inst ~= nil and inst.components.sdf_gatling_gun_weapon_aiming_helper ~= nil and inst.components.sdf_gatling_gun_weapon_aiming_helper.vector3_point ~= nil then
		inst.components.sdf_gatling_gun_weapon_aiming_helper.vector3_point = nil
	    end
	    return
	end
		
	local left_click_action = inst.components.playercontroller:GetLeftMouseAction()
	if left_click_action ~= nil then
	    if left_click_action.target ~= nil and left_click_action.target.Transform ~= nil then
		local input_pos = Vector3(left_click_action.target.Transform:GetWorldPosition())
		    if input_pos ~= nil and input_pos.x ~= nil and input_pos.y ~= nil and input_pos.z ~= nil then
			self.vector3_point = input_pos
			SendModRPCToServer(GetModRPC("SDFGatlingGun", "GatlingGunAiming_RPC"), input_pos.x, input_pos.y, input_pos.z)
		    end
		else
		    local input_pos = left_click_action:GetActionPoint()
		    if input_pos ~= nil and input_pos.x ~= nil and input_pos.y ~= nil and input_pos.z ~= nil then
			self.vector3_point = input_pos
			SendModRPCToServer(GetModRPC("SDFGatlingGun", "GatlingGunAiming_RPC"), input_pos.x, input_pos.y, input_pos.z)
		    end
		end
	    end
			
	end)
    end
end)

return SDFGatling_Gun_Weapon_Aiming_Helper
