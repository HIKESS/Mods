--Allows Prop, jab, and toolpunch Animations to do damage for SDF items.
AddStategraphPostInit("wilson", function(self)
    local old_ATTACK_deststate = self.actionhandlers[ACTIONS.ATTACK].deststate
    self.actionhandlers[ACTIONS.ATTACK].deststate = function(inst, action, ...)
        local weapon = inst.components.combat ~= nil and inst.components.combat:GetWeapon() or nil
        if weapon ~= nil and weapon:HasTag("sdf_propweapon") then
            weapon:AddTag("propweapon")
            local state = old_ATTACK_deststate(inst, action, ...)
            weapon:RemoveTag("propweapon")
            return state
        end
        return old_ATTACK_deststate(inst, action, ...)
    end
end)
AddStategraphPostInit("wilson_client", function(self)
    local old_ATTACK_deststate = self.actionhandlers[ACTIONS.ATTACK].deststate
    self.actionhandlers[ACTIONS.ATTACK].deststate = function(inst, action, ...)
        local equip = inst.replica.inventory:GetEquippedItem(EQUIPSLOTS.HANDS)
        if equip ~= nil and equip:HasTag("sdf_propweapon") then
            equip:AddTag("propweapon")
            local state = old_ATTACK_deststate(inst, action, ...)
            equip:RemoveTag("propweapon")
            return state
        end
        return old_ATTACK_deststate(inst, action, ...)
    end
end)

local old_ACTIONS_ATTACK_fn = ACTIONS.ATTACK.fn
ACTIONS.ATTACK.fn = function(act, ...)
    local weapon = act.doer.components.combat:GetWeapon()
    if weapon ~= nil and weapon:HasTag("sdf_propweapon") then
        if act.doer.sg ~= nil and act.doer.sg:HasStateTag("propattack") then
            act.doer.components.combat:DoAttack(act.target)
            return true
        end
    end
    return old_ACTIONS_ATTACK_fn(act, ...)
end
AddClassPostConstruct("components/combat_replica", function(self)
    local old_IsValidTarget = self.IsValidTarget
    self.IsValidTarget = function(self, target, ...)
        local weapon = self:GetWeapon()
        if weapon ~= nil and weapon:HasTag("sdf_propweapon") then
            weapon:AddTag("propweapon")
            local ret = old_IsValidTarget(self, target, ...)
            weapon:RemoveTag("propweapon")
            return ret
        end
        return old_IsValidTarget(self, target, ...)
    end

    local old_CanBeAttacked = self.CanBeAttacked
    self.CanBeAttacked = function(self, attacker, ...)
        if attacker ~= nil and attacker ~= self.inst then
            local combat = attacker.replica.combat
            local weapon = combat ~= nil and combat:GetWeapon() or nil
            if weapon ~= nil and weapon:HasTag("sdf_propweapon") then
                weapon:AddTag("propweapon")
                local ret = old_CanBeAttacked(self, attacker, ...)
                weapon:RemoveTag("propweapon")
                return ret
            end
        end
        return old_CanBeAttacked(self, attacker, ...)
    end
end)

AddStategraphPostInit("wilson", function(self)
    local old_attack_onenter = self.states.attack.onenter
    self.states.attack.onenter = function(inst, ...)
        local equip = inst.components.inventory:GetEquippedItem(EQUIPSLOTS.HANDS)
        if equip ~= nil then
            if equip:HasTag("sdf_jabweapon") then
                equip:AddTag("jab")
                old_attack_onenter(inst, ...)
                equip:RemoveTag("jab")
                return
            end
            if equip:HasTag("sdf_toolpunch") then
                equip:AddTag("toolpunch")
                old_attack_onenter(inst, ...)
                equip:RemoveTag("toolpunch")
                return
            end
        end
        old_attack_onenter(inst, ...)
    end
end)
AddStategraphPostInit("wilson_client", function(self)
    local old_attack_onenter = self.states.attack.onenter
    self.states.attack.onenter = function(inst, ...)
        local equip = inst.replica.inventory:GetEquippedItem(EQUIPSLOTS.HANDS)
        if equip ~= nil then
            if equip:HasTag("sdf_jabweapon") then
                equip:AddTag("jab")
                old_attack_onenter(inst, ...)
                equip:RemoveTag("jab")
                return
            end
            if equip:HasTag("sdf_toolpunch") then
                equip:AddTag("toolpunch")
                old_attack_onenter(inst, ...)
                equip:RemoveTag("toolpunch")
                return
            end
        end
        old_attack_onenter(inst, ...)
    end
end)