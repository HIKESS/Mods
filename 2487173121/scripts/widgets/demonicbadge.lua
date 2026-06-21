local Widget = require "widgets/widget"
local UIAnim = require "widgets/uianim"
local Text = require "widgets/text"
local DEMONIC_TINT = {148/255, 0/255, 211/255, 1}
local PULSE_INTERVAL = 1.2
local DemonicBadge = Class(Widget, function(self, owner)
    Widget._ctor(self, "DemonicBadge")
    self.owner = owner
    self.percent = 0
    self.pulse_time = 0
    self.is_full = false
    self.backing = self:AddChild(UIAnim())
    self.backing:GetAnimState():SetBank("status_meter")
    self.backing:GetAnimState():SetBuild("status_meter")
    self.backing:GetAnimState():PlayAnimation("bg")
    self.backing:GetAnimState():AnimateWhilePaused(false)
    self.pulse = self:AddChild(UIAnim())
    self.pulse:GetAnimState():SetBank("pulse")
    self.pulse:GetAnimState():SetBuild("hunger_health_pulse")
    self.pulse:GetAnimState():AnimateWhilePaused(false)
    self.anim = self:AddChild(UIAnim())
    self.anim:GetAnimState():SetBank("status_meter")
    self.anim:GetAnimState():SetBuild("status_meter")
    self.anim:GetAnimState():PlayAnimation("anim")
    self.anim:GetAnimState():SetMultColour(unpack(DEMONIC_TINT))
    self.anim:GetAnimState():AnimateWhilePaused(false)
    self.circleframe = self:AddChild(UIAnim())
    self.circleframe:GetAnimState():SetBank("status_meter")
    self.circleframe:GetAnimState():SetBuild("status_meter")
    self.circleframe:GetAnimState():PlayAnimation("frame")
    self.circleframe:GetAnimState():AnimateWhilePaused(false)
    self.circleframe:GetAnimState():OverrideSymbol("icon", "status_health", "icon")
    self.circleframe:GetAnimState():SetMultColour(unpack(DEMONIC_TINT))
    self.num = self:AddChild(Text(BODYTEXTFONT, 33))
    self.num:SetHAlign(ANCHOR_MIDDLE)
    self.num:SetPosition(3, 0, 0)
    self.num:SetString("0")
    self:SetPercent(0)
    if self.owner then
        self.inst:ListenForEvent("demonic_energy_changed", function(owner, data)
            if data and data.percent then
                self:SetPercent(data.percent)
            end
        end, self.owner)
    end
    self:StartUpdating()
end)
function DemonicBadge:SetPercent(val)
    val = val or 0
    val = math.max(0, math.min(1, val))
    self.percent = val
    self.anim:GetAnimState():SetPercent("anim", 1 - val)
    self.circleframe:GetAnimState():SetPercent("frame", 1 - val)
    self.num:SetString(tostring(math.floor(val * 100)))
end
function DemonicBadge:PulseGreen()
    self.pulse:GetAnimState():SetMultColour(0, 1, 0, 1)
    self.pulse:GetAnimState():PlayAnimation("pulse")
end
function DemonicBadge:PulseRed()
    self.pulse:GetAnimState():SetMultColour(1, 0, 0, 1)
    self.pulse:GetAnimState():PlayAnimation("pulse")
end
function DemonicBadge:PulsePurple()
    self.pulse:GetAnimState():SetMultColour(148/255, 0/255, 211/255, 1)
    self.pulse:GetAnimState():PlayAnimation("pulse")
end
function DemonicBadge:OnUpdate(dt)
    if self.owner and self.owner.GetDemonicPercent then
        local pct = self.owner:GetDemonicPercent()
        if math.abs(pct - self.percent) > 0.001 then
            self:SetPercent(pct)
        end
        local was_full = self.is_full
        self.is_full = pct >= 0.99
        if self.is_full then
            self.pulse_time = self.pulse_time + dt
            if self.pulse_time >= PULSE_INTERVAL then
                self.pulse_time = 0
                self:PulsePurple()
            end
        else
            self.pulse_time = 0
        end
        if self.is_full and not was_full then
            self:PulsePurple()
        end
    end
end
return DemonicBadge
