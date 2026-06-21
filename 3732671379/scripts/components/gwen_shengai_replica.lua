local Gwen_Shengai = Class(function(self, inst)
    self.inst = inst

    --官方的关于人物net的部分其实都放到了 player_classified.lua 里面 不过mod偷懒的话可以直接写 只是不太正规而已

    self.current_gwen_shengai = net_ushortint(inst.GUID, "gwen_shengai.current", "gwen_shengaidirty") --第三个是事件名字 注意这个和界面监听的是同一个名字
    self.max_gwen_shengai = net_ushortint(inst.GUID, "gwen_shengai.max", "gwen_shengaidirty")
    
    self.inst:DoTaskInTime(0, function()
        self.inst:ListenForEvent("gwen_shengaidirty", function()
            self.inst:PushEvent("gwenshengaidelta", self:GetPercent())
        end)
        self.inst:PushEvent("gwenshengaidelta", self:GetPercent())
    end)

    self.current_gwen_shengai:set(100)
    self.max_gwen_shengai:set(100)
end)

function Gwen_Shengai:SetCurrent(current)
    if self.current_gwen_shengai ~= nil then
        self.current_gwen_shengai:set(current)
    end
end

function Gwen_Shengai:SetMax(max)
    if self.max_gwen_shengai ~= nil then
        self.max_gwen_shengai:set(max)
    end
end

function Gwen_Shengai:Max()
    if self.inst.components.gwen_shengai ~= nil then
        return self.inst.components.gwen_shengai.max
    elseif self.max_gwen_shengai ~= nil then
        return self.max_gwen_shengai:value()
    else
        return 100
    end
end

function Gwen_Shengai:GetPercent()
    if self.inst.components.gwen_shengai ~= nil then
        return self.inst.components.gwen_shengai:GetPercent()
    elseif self.current_gwen_shengai ~= nil and self.max_gwen_shengai ~= nil then
        return self.current_gwen_shengai:value() / self.max_gwen_shengai:value()
    else
        return 1
    end
end

function Gwen_Shengai:GetCurrent()
    if self.inst.components.gwen_shengai ~= nil then
        return self.inst.components.gwen_shengai.current
    elseif self.current_gwen_shengai ~= nil then
        return self.current_gwen_shengai:value()
    else
        return 100
    end
end

--别的方法不想写了有需要的自己补充吧

return Gwen_Shengai