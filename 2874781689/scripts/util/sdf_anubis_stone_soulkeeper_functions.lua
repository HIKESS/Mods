--Make Anubis Stone Container
local containers = require "containers"
local params = {}
local function MakeSdfAnubisStoneSoulkeeper4x2Chest()

    local soulkeeper = {
	widget = {
	    slotpos = {
		Vector3(-37, -150, 0), Vector3(37, -150, 0),
		Vector3(-37, -74, 0), Vector3(37, -74, 0),
		Vector3(-37, 2, 0), Vector3(37, 2, 0),
		Vector3(-37, 78, 0), Vector3(37, 78, 0),
	    },
        slotbg =
        {
            { image = "inv_slot_soul_helmet.tex", atlas = "images/inv_slot/inv_slot_soul_helmet.xml" },
            { image = "inv_slot_soul_helmet.tex", atlas = "images/inv_slot/inv_slot_soul_helmet.xml" },
            { image = "inv_slot_soul_helmet.tex", atlas = "images/inv_slot/inv_slot_soul_helmet.xml" },
            { image = "inv_slot_soul_helmet.tex", atlas = "images/inv_slot/inv_slot_soul_helmet.xml" },
            { image = "inv_slot_soul_helmet.tex", atlas = "images/inv_slot/inv_slot_soul_helmet.xml" },
            { image = "inv_slot_soul_helmet.tex", atlas = "images/inv_slot/inv_slot_soul_helmet.xml" },
            { image = "inv_slot_soul_helmet.tex", atlas = "images/inv_slot/inv_slot_soul_helmet.xml" },
            { image = "inv_slot_soul_helmet.tex", atlas = "images/inv_slot/inv_slot_soul_helmet.xml" },
        },
	    animbank = "ui_sdf_anubis_stone_soulkeeper",
	    animbuild = "ui_sdf_anubis_stone_soulkeeper",
	    pos = Vector3(106, 125, 0), --pos = Vector3(0, 0, 0),
	},
	issidewidget = false,
	type = "hand_inv" --sdf_anubis_stone_soulkeeper"
    }
    return soulkeeper
end

local function ItemCheck(container, item, slot)
    if item == nil then
        return false
    elseif item.prefab ~= "sdf_soul_helmet" then
        return false
    end
    return true
end

local containers_widgetsetup_old = containers.widgetsetup

function containers.widgetsetup(container, prefab, data, ...)
    local tt = prefab or container.inst.prefab
    if tt == "sdf_anubis_stone" then
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

params.sdf_anubis_stone = MakeSdfAnubisStoneSoulkeeper4x2Chest()
function params.sdf_anubis_stone.itemtestfn(container, item, slot)
    return ItemCheck(container, item, slot)
end