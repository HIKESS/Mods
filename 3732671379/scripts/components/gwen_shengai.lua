
local function onmax(self, max)
    self.inst.replica.gwen_shengai:SetMax(max)
end

local function oncurrent(self, current)
    self.inst.replica.gwen_shengai:SetCurrent(current)
end

local Gwen_Shengai = Class(function(self, inst)
    self.inst = inst
    self.max = 100 --最大值
    self.current = self.max --当前值

end,
nil,
{
    max = onmax,
    current = oncurrent,
})

function Gwen_Shengai:OnSave() --保存
	local data = { --保存当前值
	current = self.current,
	}
	return data
end

function Gwen_Shengai:OnLoad(data) --加载
    -- if data.current ~= nil  then
        -- self.current = data.current
        -- self:DoDelta(0)
    -- end
end

function Gwen_Shengai:SetMax(amount) --设置最大值
    self.max = amount
    self.current = amount
end

function Gwen_Shengai:DoDelta(delta) --改变的函数

    local old = self.current
    self.current = math.clamp(self.current + delta, 0, self.max)

    --其实改变的时候事件和需要传的参数都是随自己看需求写的
    self.inst:PushEvent("gwen_shengaidelta", { oldpercent = old / self.max, newpercent = self.current / self.max })

end

function Gwen_Shengai:GetPercent() --获取百分比
    return self.current / self.max
end

function Gwen_Shengai:GetCurrent() --获取当前值
    return self.current
end

function Gwen_Shengai:SetPercent(p) --设置百分比
    local old = self.current
    self.current  = p * self.max
    self.inst:PushEvent("gwen_shengaidelta", { oldpercent = old / self.max, newpercent = p})
end

--[[
    如果需要别的变量 和方法 看自己需求自己加吧
    ThePlayer.components.Gwen_Shengai:SetPercent(0.8)
]]

return Gwen_Shengai
