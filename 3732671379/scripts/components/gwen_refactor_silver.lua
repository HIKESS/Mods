local function current_gw_Silver(self, gw_Silver)
    self.inst.replica.gwen_refactor_silver:Setgw_Silver(gw_Silver)
end

local function gw_onSilver(self, On_Silver)
    if self.gw_Silver >= 1 then
        -- 增加耐久上限至150%
        if self.inst.components.finiteuses then
            local old_max = self.inst.components.finiteuses.total or 100
            local new_max = math.floor(old_max * 1.5)
            self.inst.components.finiteuses:SetMaxUses(new_max)
            self.inst.components.finiteuses:SetPercent(1) -- 重置为满耐久
        end

        if self.inst.components.fueled then
            local old_max = self.inst.components.fueled.maxfuel or 100
            local new_max = math.floor(old_max * 1.5)
            self.inst.components.fueled:InitializeFuelLevel(new_max)
            self.inst.components.fueled:SetPercent(1) -- 重置为满耐久
        end

        if self.inst.components.armor then
            local old_max = self.inst.components.armor.maxcondition or 100
            local new_max = math.floor(old_max * 1.5)
            self.inst.components.armor.maxcondition = new_max
            self.inst.components.armor.condition = new_max -- 重置为满耐久
        end
    end
end

local gwen_refactor_silver = Class(function(self, inst)
    self.inst = inst
    self.gw_Silver = 0
    self.On_Silver = false

end, nil,
{
    gw_Silver = current_gw_Silver,
    On_Silver = gw_onSilver,
})

function gwen_refactor_silver:Getgw_Silver() return self.gw_Silver end
function gwen_refactor_silver:Resetgw_Silver() self.gw_Silver = 0 self.On_Silver = false end
function gwen_refactor_silver:Refactor()
    self.gw_Silver = 1
    self.On_Silver = true
end

function gwen_refactor_silver:Firstgw_Silver(inst, target, doer)
    if self.inst == target then
        self:Refactor()
        SendModRPCToClient(CLIENT_MOD_RPC["LegionMsg"]["gw_UiRefresh"], self.inst.userid)
        inst:Remove()

        local pos = Vector3(self.inst.Transform:GetWorldPosition())
        local fx = SpawnPrefab("crab_king_shine")
        fx.Transform:SetPosition(pos.x, pos.y + 2, pos.z)
        fx:ListenForEvent("animover", fx.Remove)
    end
end

function gwen_refactor_silver:OnSave()
    local data = {
        gw_Silver = self.gw_Silver,
        On_Silver = self.On_Silver,
    }
    return data
end

function gwen_refactor_silver:OnLoad(data)
    if data.gw_Silver then
        self.gw_Silver = data.gw_Silver or 0
    end
    if data.On_Silver then
        self.On_Silver = true
    end
end

return gwen_refactor_silver