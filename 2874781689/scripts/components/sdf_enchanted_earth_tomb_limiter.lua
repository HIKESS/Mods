local SDFEnchanted_Earth_Tomb_Limiter = Class(function(self, inst)
    self.inst = inst
    self.num = 1
    self.maxnum = 400
    inst:DoTaskInTime(1,function()self:MyName()end)
end)

function SDFEnchanted_Earth_Tomb_Limiter:BuildHouse()
    self.num = self.num + 1
end
function SDFEnchanted_Earth_Tomb_Limiter:IsMax()
    return self.num >= self.maxnum
end
function SDFEnchanted_Earth_Tomb_Limiter:GetPosition()
    if self:IsMax() then
        return
    end
    for pVRj = 1, 400 - self.num do
        local fuZ3z86, er = 2000, 2000
        local DFb100j = math.ceil(self.num / 10) - 1
        fuZ3z86 = fuZ3z86 + -100 * DFb100j
        er = -100 * ((self.num - 10 * DFb100j) - 1) + er
        local XL_ = TheSim:FindEntities(fuZ3z86, 0, er, 15)
        if #(XL_) > 1 then
            self:BuildHouse()
        else
            return fuZ3z86, er
        end
    end
end

function SDFEnchanted_Earth_Tomb_Limiter:SetName(WYdR)
    self.name = WYdR
end

local function ZA()
end

function SDFEnchanted_Earth_Tomb_Limiter:MyName(kP7O5)
end

function SDFEnchanted_Earth_Tomb_Limiter:OnSave()
    return {num = self.num}
end

function SDFEnchanted_Earth_Tomb_Limiter:OnLoad(mP3mlD)
    if mP3mlD.num ~= nil then
        self.num = mP3mlD.num
    end
end

return SDFEnchanted_Earth_Tomb_Limiter