local function onison(self, ison)
    self.inst:AddOrRemoveTag("turnedon", ison)
end

local function onenabled(self, enabled)
    self.inst:AddOrRemoveTag("enabled", enabled)
end

local function ononcooldown(self, oncooldown)
    self.inst:AddOrRemoveTag("cooldown", oncooldown)
end

local function ongroundonly(self, groundonly)
    self.inst:AddOrRemoveTag("groundonlymachine", groundonly)
end

local SDFAsgard_Golem_Tactics = Class(function(self, inst)
    self.inst = inst
    self.turnonfn = nil
    self.turnofffn = nil
    self.ison = false
    self.cooldowntime = 3
    self.oncooldown = false
    self.enabled = true
    --self.groundonly = false
end,
nil,
{
    ison = onison,
    oncooldown = ononcooldown,
    groundonly = ongroundonly,
    enabled = onenabled,
})

function SDFAsgard_Golem_Tactics:OnRemoveFromEntity()
    self.inst:RemoveTag("turnedon")
    self.inst:RemoveTag("cooldown")
    self.inst:RemoveTag("groundonlymachine")
end

function SDFAsgard_Golem_Tactics:SetGroundOnlyMachine(groundonly)
    self.groundonly = groundonly
end

function SDFAsgard_Golem_Tactics:OnSave()
    local data = {}
    data.ison = self.ison
    return data
end

function SDFAsgard_Golem_Tactics:OnLoad(data)
    if data then
	self.ison = data.ison
	if self:IsOn() then self:TurnOn() else self:TurnOff() end
    end
end

function SDFAsgard_Golem_Tactics:TurnOn(ocarina)
    if self.cooldowntime > 0 then
	self.oncooldown = true
	self.inst:DoTaskInTime(self.cooldowntime, function() self.oncooldown = false end)
    end

    if self.inst.components.sdf_asgard_golem_command then
	self.inst.components.sdf_asgard_golem_command:Follow(ocarina)
    end

    self.ison = true
    self.inst:PushEvent("machineturnedon")
end

function SDFAsgard_Golem_Tactics:SummonTurnOn(soulbound)
    if self.cooldowntime > 0 then
	self.oncooldown = true
	self.inst:DoTaskInTime(self.cooldowntime, function() self.oncooldown = false end)
    end

    if self.inst.components.sdf_asgard_golem_command then
	self.inst.components.sdf_asgard_golem_command:SummonFollow(soulbound)
    end

    self.ison = true
    self.inst:PushEvent("machineturnedon")
end

function SDFAsgard_Golem_Tactics:CanInteract()
    return
	not self.inst:HasTag("fueldepleted") and
	not (self.inst.replica.equippable ~= nil and
	not self.inst.replica.equippable:IsEquipped() and
	self.inst.replica.inventoryitem ~= nil and
	self.inst.replica.inventoryitem:IsHeld()) and
	self.enabled == true
end

function SDFAsgard_Golem_Tactics:TurnOff()
    if self.cooldowntime > 0 then
	self.oncooldown = true
	self.inst:DoTaskInTime(self.cooldowntime, function() self.oncooldown = false end)
    end

    if self.turnofffn then
	self.turnofffn(self.inst)
    end
    self.ison = false
    self.inst:PushEvent("machineturnedoff")
end

function SDFAsgard_Golem_Tactics:IsOn()
    return self.ison
end

function SDFAsgard_Golem_Tactics:GetDebugString()
    return string.format(
	"on=%s, cooldowntime=%2.2f, oncooldown=%s",
	tostring(self.ison), self.cooldowntime, tostring(self.oncooldown)
    )
end

return SDFAsgard_Golem_Tactics