
local function current_gw_Permanent(self, gw_Permanent)
    self.inst.replica.gwen_refactor:Setgw_Permanent(gw_Permanent)
end

local function gw_onPermanent(self,On_Permanent)
	if self.gw_Permanent >= 1 then
		----移除耐久显示
		self.inst:AddTag("hide_percentage")
		self.inst:RemoveTag("show_broken_ui")
		self.inst:RemoveTag("show_spoilage")

		if self.inst.components.perishable then
			self.inst.components.perishable:StopPerishing()
			self.inst.components.perishable:SetPercent(1)
		end

		----满级后耐久消耗为0
		if self.inst.components.finiteuses then
			self.inst.components.finiteuses:SetPercent(1)
			function self.inst.components.finiteuses:Use(num)
				return true
			end
			function self.inst.components.finiteuses:SetConsumption(action, uses)
				self[action] = 0
			end
		end

		if self.inst.components.fueled then
			self.inst.components.fueled:SetPercent(1)
			self.inst.components.fueled.rate = 0
			function self.inst.components.fueled:StartConsuming()
				return true
			end
			function self.inst.components.fueled:DoDelta(amount, doer)
				return true
			end
		end

		if self.inst.components.armor then
			self.inst.components.armor:SetPercent(1)
			self.inst.components.armor.condition = self.inst.components.armor.maxcondition
			self.inst.components.armor.indestructible = true
		end

	end
end

local gwen_refactor = Class(function(self, inst)
    self.inst = inst
	self.gw_Permanent = 0
	self.On_Permanent = false

end,nil,
{
	gw_Permanent = current_gw_Permanent,
	On_Permanent = gw_onPermanent,
})

function gwen_refactor:Getgw_Permanent() return self.gw_Permanent end
function gwen_refactor:Resetgw_Permanent() self.gw_Permanent = 0 self.On_Permanent = false end
function gwen_refactor:Refactor()
	self.gw_Permanent = 1
	self.On_Permanent = true
end

function gwen_refactor:Firstgw_Permanent(inst, target, doer)
	if self.inst == target then
		self:Refactor()
		--if doer and doer.components.talker then
		--	doer.components.talker:Say("棱彩重构！")
		--end
		SendModRPCToClient(CLIENT_MOD_RPC["LegionMsg"]["gw_UiRefresh"],self.inst.userid)
		inst:Remove()

		local pos = Vector3(self.inst.Transform:GetWorldPosition())
		local fx = SpawnPrefab("crab_king_shine")
		fx.Transform:SetPosition(pos.x, pos.y + 2, pos.z)
		fx:ListenForEvent("animover", fx.Remove)
	end
end


function gwen_refactor:OnSave() --保存
	local data = {
		gw_Permanent = self.gw_Permanent,
		On_Permanent = self.On_Permanent,
	}
	return data
end

function gwen_refactor:OnLoad(data) --加载
	if data.gw_Permanent then
		self.gw_Permanent = data.gw_Permanent or 0
	end
	if data.On_Permanent then
		self.On_Permanent = true
	end
end

return gwen_refactor
