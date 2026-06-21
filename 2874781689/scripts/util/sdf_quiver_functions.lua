--Make Quiver Container
local containers = require "containers"
local params = {}

------------------------------------------------------------------------
local function MakeSDFCrossbowQuiver1x1Chest()

    local quiver = {
	widget = {
	    slotpos = {
		Vector3(0, -2, 0),
	    },
        slotbg =
        {
            { image = "inv_slot_standard_bolts.tex", atlas = "images/inv_slot/inv_slot_standard_bolts.xml" },
        },
	    animbank = "ui_sdf_quiver",
	    animbuild = "ui_sdf_quiver",
	    pos = Vector3(0, 35, 0), --pos = Vector3(0, 0, 0),
	},
	issidewidget = false,
	type = "hand_inv" --sdf_quiver"
    }
    return quiver
end

local function CrossbowItemCheck(container, item, slot)
    if item == nil then
        return false
    elseif item:HasTag("sdf_crossbow_ammo") then
	return true
    end
    return false
end
------------------------------------------------------------------------
local function MakeSDFFlamingCrossbowQuiver1x1Chest()

    local quiver = {
	widget = {
	    slotpos = {
		Vector3(0, -2, 0),
	    },
        slotbg =
        {
            { image = "inv_slot_flaming_bolts.tex", atlas = "images/inv_slot/inv_slot_flaming_bolts.xml" },
        },
	    animbank = "ui_sdf_quiver",
	    animbuild = "ui_sdf_quiver",
	    pos = Vector3(0, 35, 0), --pos = Vector3(0, 0, 0),
	},
	issidewidget = false,
	type = "hand_inv" --sdf_quiver"
    }
    return quiver
end

local function FlamingCrossbowItemCheck(container, item, slot)
    if item == nil then
        return false
    elseif item:HasTag("sdf_crossbow_ammo") then
	return true
    end
    return false
end
------------------------------------------------------------------------
local function MakeSDFLongbowQuiver1x1Chest()

    local quiver = {
	widget = {
	    slotpos = {
		Vector3(0, -2, 0),
	    },
        slotbg =
        {
            { image = "inv_slot_standard_arrows.tex", atlas = "images/inv_slot/inv_slot_standard_arrows.xml" },
        },
	    animbank = "ui_sdf_quiver",
	    animbuild = "ui_sdf_quiver",
	    pos = Vector3(0, 35, 0), --pos = Vector3(0, 0, 0),
	},
	issidewidget = false,
	type = "hand_inv" --sdf_quiver"
    }
    return quiver
end

local function LongbowItemCheck(container, item, slot)
    if item == nil then
        return false
    elseif item:HasTag("sdf_longbow_ammo") then
	return true
    end
    return false
end
------------------------------------------------------------------------
local function MakeSDFFlamingLongbowQuiver1x1Chest()

    local quiver = {
	widget = {
	    slotpos = {
		Vector3(0, -2, 0),
	    },
        slotbg =
        {
            { image = "inv_slot_flaming_arrows.tex", atlas = "images/inv_slot/inv_slot_flaming_arrows.xml" },
        },
	    animbank = "ui_sdf_quiver",
	    animbuild = "ui_sdf_quiver",
	    pos = Vector3(0, 35, 0), --pos = Vector3(0, 0, 0),
	},
	issidewidget = false,
	type = "hand_inv" --sdf_quiver"
    }
    return quiver
end

local function FlamingLongbowItemCheck(container, item, slot)
    if item == nil then
        return false
    elseif item:HasTag("sdf_longbow_ammo") then
	return true
    end
    return false
end
------------------------------------------------------------------------
local function MakeSDFMagicLongbowQuiver1x1Chest()

    local quiver = {
	widget = {
	    slotpos = {
		Vector3(0, -2, 0),
	    },
        slotbg =
        {
            { image = "inv_slot_magical_arrows.tex", atlas = "images/inv_slot/inv_slot_magical_arrows.xml" },
        },
	    animbank = "ui_sdf_quiver",
	    animbuild = "ui_sdf_quiver",
	    pos = Vector3(0, 35, 0), --pos = Vector3(0, 0, 0),
	},
	issidewidget = false,
	type = "hand_inv" --sdf_quiver"
    }
    return quiver
end

local function MagicLongbowItemCheck(container, item, slot)
    if item == nil then
        return false
    elseif item:HasTag("sdf_longbow_ammo") then
	return true
    end
    return false
end
------------------------------------------------------------------------
local function MakeSDFPistolQuiver1x1Chest()

    local quiver = {
	widget = {
	    slotpos = {
		Vector3(0, -2, 0),
	    },
        slotbg =
        {
            { image = "inv_slot_standard_bullets.tex", atlas = "images/inv_slot/inv_slot_standard_bullets.xml" },
        },
	    animbank = "ui_sdf_quiver",
	    animbuild = "ui_sdf_quiver",
	    pos = Vector3(0, 35, 0), --pos = Vector3(0, 0, 0),
	},
	issidewidget = false,
	type = "hand_inv" --sdf_quiver"
    }
    return quiver
end

local function PistolItemCheck(container, item, slot)
    if item == nil then
        return false
    elseif item:HasTag("sdf_pistol_ammo") then
	return true
    end
    return false
end
------------------------------------------------------------------------
local function MakeSDFBlunderbussQuiver1x1Chest()

    local quiver = {
	widget = {
	    slotpos = {
		Vector3(0, -2, 0),
	    },
        slotbg =
        {
            { image = "inv_slot_standard_buckshots.tex", atlas = "images/inv_slot/inv_slot_standard_buckshots.xml" },
        },
	    animbank = "ui_sdf_quiver",
	    animbuild = "ui_sdf_quiver",
	    pos = Vector3(0, 35, 0), --pos = Vector3(0, 0, 0),
	},
	issidewidget = false,
	type = "hand_inv" --sdf_quiver"
    }
    return quiver
end

local function BlunderbussItemCheck(container, item, slot)
    if item == nil then
        return false
    elseif item:HasTag("sdf_blunderbuss_ammo") then
	return true
    end
    return false
end
------------------------------------------------------------------------
local function MakeSDFGatlingGunQuiver1x1Chest()

    local quiver = {
	widget = {
	    slotpos = {
		Vector3(0, -2, 0),
	    },
        slotbg =
        {
            { image = "inv_slot_standard_munitions.tex", atlas = "images/inv_slot/inv_slot_standard_munitions.xml" },
        },
	    animbank = "ui_sdf_quiver",
	    animbuild = "ui_sdf_quiver",
	    pos = Vector3(0, 35, 0), --pos = Vector3(0, 0, 0),
	},
	issidewidget = false,
	type = "hand_inv" --sdf_quiver"
    }
    return quiver
end

local function GatlingGunItemCheck(container, item, slot)
    if item == nil then
        return false
    elseif item:HasTag("sdf_gatling_gun_ammo") then
	return true
    end
    return false
end
------------------------------------------------------------------------

local containers_widgetsetup_old = containers.widgetsetup

function containers.widgetsetup(container, prefab, data, ...)
    local tt = prefab or container.inst.prefab
    if tt == "sdf_crossbow" or tt == "sdf_flaming_crossbow" 
	or tt == "sdf_longbow" or tt == "sdf_flaming_longbow" or tt == "sdf_magic_longbow" 
	or tt == "sdf_pistol" or tt == "sdf_blunderbuss" or tt == "sdf_gatling_gun" then
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

------------------------------------------------------------------------
params.sdf_crossbow = MakeSDFCrossbowQuiver1x1Chest()
function params.sdf_crossbow.itemtestfn(container, item, slot)
    return CrossbowItemCheck(container, item, slot)
end

params.sdf_flaming_crossbow = MakeSDFFlamingCrossbowQuiver1x1Chest()
function params.sdf_flaming_crossbow.itemtestfn(container, item, slot)
    return FlamingCrossbowItemCheck(container, item, slot)
end

params.sdf_longbow = MakeSDFLongbowQuiver1x1Chest()
function params.sdf_longbow.itemtestfn(container, item, slot)
    return LongbowItemCheck(container, item, slot)
end

params.sdf_flaming_longbow = MakeSDFFlamingLongbowQuiver1x1Chest()
function params.sdf_flaming_longbow.itemtestfn(container, item, slot)
    return FlamingLongbowItemCheck(container, item, slot)
end

params.sdf_magic_longbow = MakeSDFMagicLongbowQuiver1x1Chest()
function params.sdf_magic_longbow.itemtestfn(container, item, slot)
    return MagicLongbowItemCheck(container, item, slot)
end

params.sdf_pistol = MakeSDFPistolQuiver1x1Chest()
function params.sdf_pistol.itemtestfn(container, item, slot)
    return PistolItemCheck(container, item, slot)
end

params.sdf_blunderbuss = MakeSDFBlunderbussQuiver1x1Chest()
function params.sdf_blunderbuss.itemtestfn(container, item, slot)
    return BlunderbussItemCheck(container, item, slot)
end

params.sdf_gatling_gun = MakeSDFGatlingGunQuiver1x1Chest()
function params.sdf_gatling_gun.itemtestfn(container, item, slot)
    return GatlingGunItemCheck(container, item, slot)
end