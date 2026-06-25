local STRINGS = GLOBAL.STRINGS
local require = GLOBAL.require


--------------------------------------------------------------------------------
-- [[set container]]
--------------------------------------------------------------------------------
local containers = GLOBAL.require "containers"
local cooking = GLOBAL.require "cooking"

local params = {}

params.williambutler =
{
    widget =
    {
        slotpos =
        {
            Vector3(-(64 + 12), 24, 0), 
            Vector3(0, 24, 0),
            Vector3(64 + 12, 24, 0), 
        },
        animbank = "ui_chest_3x2",
        animbuild = "ui_chest_3x2",
        pos = Vector3(200, 0, 0),
        side_align_tip = 100,
		buttoninfo =
		{
			text = "Cook",
			position = Vector3(0, -48, 0),
		}
    },
    acceptsstacks = false,
    type = "cooker",
}

function params.williambutler.itemtestfn(container, item, slot)
    return item:HasTag("cookable") and not container.inst:HasTag("burnt")
end

function params.williambutler.widget.buttoninfo.fn(inst, doer)
    if inst.components.container ~= nil then
       GLOBAL.BufferedAction(doer, inst, GLOBAL.ACTIONS.WILLIAM_ACTION):Do()
    elseif inst.replica.container ~= nil and not inst.replica.container:IsBusy() then
        GLOBAL.SendRPCToServer(GLOBAL.RPC.DoWidgetButtonAction, GLOBAL.ACTIONS.WILLIAM_ACTION.code, inst, GLOBAL.ACTIONS.WILLIAM_ACTION.mod_name)
    end
end

function params.williambutler.widget.buttoninfo.validfn(inst)
    return inst.replica.container ~= nil
end

containers.MAXITEMSLOTS = math.max(containers.MAXITEMSLOTS, params.williambutler.widget.slotpos ~= nil and #params.williambutler.widget.slotpos or 0)

local containers_widgetsetup = containers.widgetsetup

function containers.widgetsetup(container, prefab, data)
    local t = prefab or container.inst.prefab
    if t == "williambutler" then
        local t = params[t]
        if t ~= nil then
            for k, v in pairs(t) do
                container[k] = v
            end
            container:SetNumSlots(container.widget.slotpos ~= nil and #container.widget.slotpos or 0)
        end
    else
        return containers_widgetsetup(container, prefab)
    end
end

local _GetAdjectivedName = GLOBAL.EntityScript.GetAdjectivedName
function GLOBAL.EntityScript:GetAdjectivedName()
    local name = self:GetBasicDisplayName()
    if self:HasTag("willminion") then
	if self:HasTag("level3") then
        return GLOBAL.ConstructAdjectivedName(self, name, "Brilliant")
	elseif self:HasTag("level2") then
        return GLOBAL.ConstructAdjectivedName(self, name, "Boastful")
	elseif self:HasTag("level1") then
        return GLOBAL.ConstructAdjectivedName(self, name, "Bolstered")
	else
    return _GetAdjectivedName(self)
	end
	else
    return _GetAdjectivedName(self)
    end
end