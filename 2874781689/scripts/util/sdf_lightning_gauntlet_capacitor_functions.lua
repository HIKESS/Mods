--Make Lightning Gauntlet Container
local containers = require "containers"
local params = {}
local function MakeSdfLightningGauntletCapacitor2x1Chest()

    local capacitor = {
	widget = {
	    slotpos = {
		Vector3(0, -2, 0),
		Vector3(0, 74, 0),
	    },
        slotbg =
        {
            { image = "inv_slot_lightning.tex", atlas = "images/inv_slot/inv_slot_lightning.xml" },
            { image = "inv_slot_goodlightning.tex", atlas = "images/inv_slot/inv_slot_goodlightning.xml" },
        },
	    animbank = "ui_sdf_lightning_gauntlet_capacitor",
	    animbuild = "ui_sdf_lightning_gauntlet_capacitor",
	    pos = Vector3(0, 35, 0), --pos = Vector3(0, 0, 0),
	},
	issidewidget = false,
	type = "hand_inv" --sdf_lightning_gauntlet_capacitor"
    }
    return capacitor
end

local function ItemCheck(container, item, slot)
    if item == nil then
        return false
    elseif slot == 1 and item:HasTag("sdf_lightning_gauntlet_lightning_ammo") then
	return true
    elseif slot == 2 and item:HasTag("sdf_lightning_gauntlet_goodlightning_ammo") then
	return true
    end
    return false
end

local containers_widgetsetup_old = containers.widgetsetup

function containers.widgetsetup(container, prefab, data, ...)
    local tt = prefab or container.inst.prefab
    if tt == "sdf_lightning_gauntlet" then
	local t = params[tt]
	if t ~= nil then
	    for k, v in pairs(t) do
		container[k] = v
	    end
	    container:SetNumSlots(container.widget.slotpos ~= nil and #container.widget.slotpos or 0)
	end
    else
	return containers_widgetsetup_old(container, prefab, data, ...)
    end
end

params.sdf_lightning_gauntlet = MakeSdfLightningGauntletCapacitor2x1Chest()
function params.sdf_lightning_gauntlet.itemtestfn(container, item, slot)
    return ItemCheck(container, item, slot)
end