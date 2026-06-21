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

local SDFGallowmere_Knight_Tactics = Class(function(self, inst)
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

function SDFGallowmere_Knight_Tactics:OnRemoveFromEntity()
    self.inst:RemoveTag("turnedon")
    self.inst:RemoveTag("cooldown")
    self.inst:RemoveTag("groundonlymachine")
end

function SDFGallowmere_Knight_Tactics:SetGroundOnlyMachine(groundonly)
    self.groundonly = groundonly
end

function SDFGallowmere_Knight_Tactics:OnSave()
    local data = {}
    data.ison = self.ison
    return data
end

function SDFGallowmere_Knight_Tactics:OnLoad(data)
    if data then
	self.ison = data.ison
	if self:IsOn() then self:TurnOn() else self:TurnOff() end
    end
end

function SDFGallowmere_Knight_Tactics:TurnOn(sdf)
    if self.cooldowntime > 0 then
	self.oncooldown = true
	self.inst:DoTaskInTime(self.cooldowntime, function() self.oncooldown = false end)
    end

    if self.inst.components.sdf_gallowmere_knight_command then
	self.inst.components.sdf_gallowmere_knight_command:Follow(sdf)
    end

    self.ison = true
    self.inst:PushEvent("machineturnedon")
end

function SDFGallowmere_Knight_Tactics:AnubisStoneTurnOn(player)
    if self.cooldowntime > 0 then
	self.oncooldown = true
	self.inst:DoTaskInTime(self.cooldowntime, function() self.oncooldown = false end)
    end

    if self.inst.components.sdf_gallowmere_knight_command then
	self.inst.components.sdf_gallowmere_knight_command:AnubisStoneFollow(player)
    end

    self.ison = true
    self.inst:PushEvent("machineturnedon")
end

function SDFGallowmere_Knight_Tactics:CanInteract()
    return
	not self.inst:HasTag("fueldepleted") and
	not (self.inst.replica.equippable ~= nil and
	not self.inst.replica.equippable:IsEquipped() and
	self.inst.replica.inventoryitem ~= nil and
	self.inst.replica.inventoryitem:IsHeld()) and
	self.enabled == true
end

function SDFGallowmere_Knight_Tactics:TurnOff()
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

function SDFGallowmere_Knight_Tactics:IsOn()
    return self.ison
end

function SDFGallowmere_Knight_Tactics:GetDebugString()
    return string.format(
	"on=%s, cooldowntime=%2.2f, oncooldown=%s",
	tostring(self.ison), self.cooldowntime, tostring(self.oncooldown)
    )
end

return SDFGallowmere_Knight_Tactics