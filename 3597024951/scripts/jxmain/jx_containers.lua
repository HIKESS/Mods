local containers = require "containers"
local params = containers.params
local cooking = require("cooking")

------------------------------------------------------------------------------
---[[复古枫叶木盒]]
------------------------------------------------------------------------------
if TUNING.JX_TUNING.jx_chest_containerslot == 12 then
  params.jx_chest =
  {
    widget =
    {
        slotpos = {},
        animbank = "ui_chester_upgraded_3x4",
        animbuild = "ui_chester_upgraded_3x4",
        pos = Vector3(0, 220, 0),
        side_align_tip = 160,
    },
    type = "chest",
  }

  for y = 2.5, -0.5, -1 do
    for x = 0, 2 do
        table.insert(params.jx_chest.widget.slotpos, Vector3(75 * x - 75 * 2 + 75, 75 * y - 75 * 2 + 75, 0))
    end
  end
else
  params.jx_chest =
  {
    widget =
    {
        slotpos = {},
        animbank = "ui_chest_3x3",
        animbuild = "ui_chest_3x3",
        pos = Vector3(0, 200, 0),
        side_align_tip = 160,
    },
    type = "chest",
  }
  
  for y = 2, 0, -1 do
    for x = 0, 2 do
        table.insert(params.jx_chest.widget.slotpos, Vector3(80 * x - 80 * 2 + 80, 80 * y - 80 * 2 + 80, 0))
    end
  end
end
------------------------------------------------------------------------------
---[[祖母绿宝石箱]]
------------------------------------------------------------------------------
if TUNING.JX_TUNING.jx_chest_2_containerslot == 12 then
  params.jx_chest_2 =
  {
    widget =
    {
        slotpos = {},
        animbank = "ui_chester_upgraded_3x4",
        animbuild = "ui_chester_upgraded_3x4",
        pos = Vector3(0, 220, 0),
        side_align_tip = 160,
    },
    type = "chest",
  }

  for y = 2.5, -0.5, -1 do
    for x = 0, 2 do
        table.insert(params.jx_chest_2.widget.slotpos, Vector3(75 * x - 75 * 2 + 75, 75 * y - 75 * 2 + 75, 0))
    end
  end
else
  params.jx_chest_2 =
  {
    widget =
    {
        slotpos = {},
        animbank = "ui_chest_3x3",
        animbuild = "ui_chest_3x3",
        pos = Vector3(0, 200, 0),
        side_align_tip = 160,
    },
    type = "chest",
  }
  
  for y = 2, 0, -1 do
    for x = 0, 2 do
        table.insert(params.jx_chest_2.widget.slotpos, Vector3(80 * x - 80 * 2 + 80, 80 * y - 80 * 2 + 80, 0))
    end
  end
end
------------------------------------------------------------------------------
---[[电煮锅]]
------------------------------------------------------------------------------
params.jx_cookpot = params.cookpot
params.jx_cookpot_2 = params.cookpot

------------------------------------------------------------------------------
---[[复古电冰箱]]
------------------------------------------------------------------------------
local jx_icebox_containerslot = TUNING.JX_TUNING.jx_icebox_containerslot
if jx_icebox_containerslot == 9 then
  params.jx_icebox =
  {
    widget =
    {
        slotpos = {},
        animbank = "ui_chest_3x3",
        animbuild = "ui_chest_3x3",
        pos = Vector3(0, 200, 0),
        side_align_tip = 160,
    },
    type = "chest",
  }
  for y = 2, 0, -1 do
    for x = 0, 2 do
        table.insert(params.jx_icebox.widget.slotpos, Vector3(80 * x - 80 * 2 + 80, 80 * y - 80 * 2 + 80, 0))
    end
  end
else
  params.jx_icebox =
  {
    widget =
    {
        slotpos = {},
        animbank = "ui_boat_ancient_4x4",
        animbuild = "ui_boat_ancient_4x4",
        pos = Vector3(0, 200, 0),
        side_align_tip = 160,
    },
    type = "chest",
  }
  for y = 3, 0, -1 do
    for x = 0, 3 do
        table.insert(params.jx_icebox.widget.slotpos, Vector3(80 * x - 80 * 2.5 + 80, 80 * y - 80 * 2.5 + 80, 0))
    end
  end
end
function params.jx_icebox.itemtestfn(container, item, slot)
  if item:HasTag("icebox_valid") then
    return true
  end
  if not (item:HasTag("fresh") or item:HasTag("stale") or item:HasTag("spoiled")) then
    return false
  end
	if item:HasTag("smallcreature") then
		return false
	end
  for k, v in pairs(FOODTYPE) do
    if item:HasTag("edible_"..v) then
      return true
    end
  end
  return false
end
------------------------------------------------------------------------------
---[[沉睡熊小冰箱]]
------------------------------------------------------------------------------
params.jx_icebox_2 =
{
    widget =
    {
        slotpos = {},
        animbank = "ui_jx_icebox_2_3x3",
        animbuild = "ui_jx_icebox_2_3x3",
        pos = Vector3(0, 200, 0),
        side_align_tip = 160,
    },
    type = "chest",
}

for y = 2, 0, -1 do
    for x = 0, 2 do
        table.insert(params.jx_icebox_2.widget.slotpos, Vector3(80 * x - 80 * 2 + 80, 80 * y - 80 * 2 + 60, 0))
    end
end

function params.jx_icebox_2.itemtestfn(container, item, slot)
    if item:HasTag("icebox_valid") then
        return true
    end

    --Perishable
    if not (item:HasTag("fresh") or item:HasTag("stale") or item:HasTag("spoiled")) then
        return false
    end

	if item:HasTag("smallcreature") then
		return false
	end

    --Edible
    for k, v in pairs(FOODTYPE) do
        if item:HasTag("edible_"..v) then
            return true
        end
    end

    return false
end
------------------------------------------------------------------------------
---[[北极熊冰柜]]
------------------------------------------------------------------------------
params.jx_icebox_big =
{
    widget =
    {
        slotpos = {},
        animbank = "ui_jx_icebox_big_5x4",
        animbuild = "ui_jx_icebox_big_5x4",
        pos = Vector3(0, 220, 0),
        side_align_tip = 160,
    },
    type = "chest",
}
for y = 2.5, -0.5, -1 do
    for x = -1, 3 do
        table.insert(params.jx_icebox_big.widget.slotpos, Vector3(86 * x - 84, 75 * y - 97, 0))
    end
end
function params.jx_icebox_big.itemtestfn(container, item, slot)
    if item:HasTag("icebox_valid") then
        return true
    end

    --Perishable
    if not (item:HasTag("fresh") or item:HasTag("stale") or item:HasTag("spoiled")) then
        return false
    end

	if item:HasTag("smallcreature") then
		return false
	end

    --Edible
    for k, v in pairs(FOODTYPE) do
        if item:HasTag("edible_"..v) then
            return true
        end
    end

    return false
end
------------------------------------------------------------------------------
---[[洛可可海缸柜]]
------------------------------------------------------------------------------
params.jx_fish_tank =
{
    widget =
    {
        slotpos = {},
        animbank = "ui_chester_upgraded_3x4",
        animbuild = "ui_chester_upgraded_3x4",
        pos = Vector3(0, 220, 0),
        side_align_tip = 160,
    },
    type = "chest",
}

for y = 2.5, -0.5, -1 do
    for x = 0, 2 do
        table.insert(params.jx_fish_tank.widget.slotpos, Vector3(75 * x - 75 * 2 + 75, 75 * y - 75 * 2 + 75, 0))
    end
end
------------------------------------------------------------------------------
---[[复古电视机]]
------------------------------------------------------------------------------
params.jx_tv = params.yots_lantern_post

------------------------------------------------------------------------------
---[[洗衣机]]
------------------------------------------------------------------------------
params.jx_washer = {
    widget =
    {
        slotpos =
        {
             Vector3(-2, 38, 0),
        },
        animbank = "ui_chest_1x2",
        animbuild = "ui_chest_1x2",
        pos = Vector3(0, 160, 0),
        side_align_tip = 100,
        buttoninfo =
        {
            text = STRINGS.ACTIONS.GIVE.WASH,
            position = Vector3(0, -50, 0),
        }
    },
    acceptsstacks = false,
    type = "chest",
}
function params.jx_washer.itemtestfn(container, item, slot)
    return item:HasTag("_equippable") and not item:HasAnyTag("tool", "weapon", "pocketwatch", "icebox_valid")
end

function params.jx_washer.widget.buttoninfo.fn(inst, doer)
    if inst.components.container ~= nil then
        BufferedAction(doer, inst, ACTIONS.INCINERATE):Do()
    elseif inst.replica.container ~= nil and not inst.replica.container:IsBusy() then
        SendRPCToServer(RPC.DoWidgetButtonAction, ACTIONS.INCINERATE.code, inst, ACTIONS.INCINERATE.mod_name)
    end
end

function params.jx_washer.widget.buttoninfo.validfn(inst)
    return inst.replica.container ~= nil and not inst.replica.container:IsEmpty()
end
------------------------------------------------------------------------------
---[[乌尔诺斯的拆解机]]
------------------------------------------------------------------------------
params.jx_disassembler = {
    widget =
    {
        slotpos =
        {
             Vector3(-2, 38, 0),
        },
        animbank = "ui_chest_1x2",
        animbuild = "ui_chest_1x2",
        pos = Vector3(0, 160, 0),
        side_align_tip = 100,
        buttoninfo =
        {
            text = STRINGS.ACTIONS.GIVE.DISMANTLE,
            position = Vector3(0, -50, 0),
        }
    },
    acceptsstacks = false,
    type = "chest",
}

function params.jx_disassembler.widget.buttoninfo.fn(inst, doer)
    if inst.components.container ~= nil then
        BufferedAction(doer, inst, ACTIONS.INCINERATE):Do()
    elseif inst.replica.container ~= nil and not inst.replica.container:IsBusy() then
        SendRPCToServer(RPC.DoWidgetButtonAction, ACTIONS.INCINERATE.code, inst, ACTIONS.INCINERATE.mod_name)
    end
end

function params.jx_disassembler.widget.buttoninfo.validfn(inst)
    return inst.replica.container ~= nil and not inst.replica.container:IsEmpty()
end
------------------------------------------------------------------------------
---[[诺伊堡绿色煤油暖炉]]
------------------------------------------------------------------------------
params.jx_furnace = 
{
    widget =
    {
        slotpos =
        {
            Vector3(-159.5, 106, 0),
            Vector3(-84.5, 106, 0),
            Vector3(-159.5, 34, 0),
            Vector3(-84.5, 34, 0),
            Vector3(-159.5, -38, 0),
            Vector3(-84.5, -38, 0),
        },
        animbank = "ui_backpack_2x4",
        animbuild = "ui_backpack_2x4",
        pos = Vector3(300, 0, 0),
        side_align_tip = 120,
        buttoninfo =
        {
            text = STRINGS.ACTIONS.INCINERATE,
            position = Vector3(-122, -102, 0),
        }
    },
    type = "cooker",
}

function params.jx_furnace.itemtestfn(container, item, slot)
    return not item:HasTag("irreplaceable")
end

function params.jx_furnace.widget.buttoninfo.fn(inst, doer)
    if inst.components.container ~= nil then
        BufferedAction(doer, inst, ACTIONS.INCINERATE):Do()
    elseif inst.replica.container ~= nil and not inst.replica.container:IsBusy() then
        SendRPCToServer(RPC.DoWidgetButtonAction, ACTIONS.INCINERATE.code, inst, ACTIONS.INCINERATE.mod_name)
    end
end

function params.jx_furnace.widget.buttoninfo.validfn(inst)
    return inst.replica.container ~= nil and not inst.replica.container:IsEmpty()
end
------------------------------------------------------------------------------
--衣柜
------------------------------------------------------------------------------

local wardrobe_tags = {
    "_equippable",
    "reloaditem_ammo",
    "tool",
    "weapon",
    "heatrock",
    "fan",
    "pocketwatch",
    "trap",
    "mine",
    "broken",
}

local wardrobe_prefabs = {
    "razor",
    "beef_bell",
    "pocketwatch_parts",
    "pocketwatch_dismantler",
    "sewing_tape",
    "sewing_kit",
    "lunarplant_kit",
    "voidcloth_kit",
    "wagpunkbits_kit",
	  "spiderden_bedazzler",
	  "spider_whistle",
  	"spider_repellent",
    "sludge_oil",
    "saddle_basic",
    "saddle_race",
    "saddle_war",
    "saddle_wathgrithr",
    "saddle_shadow",
}

local function CheckWardrobeItem(container, item, slot)
    if item:HasOneOfTags(wardrobe_tags) then
        return true
    end
    for _, prefab in pairs(wardrobe_prefabs) do
        if item.prefab == prefab then
            return true
        end
    end

    return string.match(item.prefab, "wx78module_") ~= nil
end

params.jx_wardrobe =
{
    widget =
    {
        slotpos = {},
        animbank = nil,
        animbuild = nil,
        bgatlas = "images/jx_wardrobe_container.xml",
        bgimage = "jx_wardrobe_container.tex",
        pos = Vector3(0, 220, 0),
        side_align_tip = 160,
    },
    type = "chest",
    itemtestfn = CheckWardrobeItem,
}

for y = 2.5, -1.5, -1 do
    for x = 0, 4 do
        table.insert(params.jx_wardrobe.widget.slotpos, Vector3(80 * x - 80 * 2, 80 * y - 85 * 2 + 120, 0))
    end
end
------------------------------------------------------------------------------
--甲壳虫车
------------------------------------------------------------------------------
params.jx_car =
{
    widget =
    {
        slotpos = {},
        slotbg = {},
        animbank = "ui_jx_car_5x5",
        animbuild = "ui_jx_car_5x5",
        pos = Vector3(400, -70, 0),
        side_align_tip = 160,
    },
    type = "chest",
}

for y = 1.5, -2.5, -1 do
    for x = -1, 4 do
        table.insert(params.jx_car.widget.slotpos, Vector3(80 * x - 120, 80 * y - 15, 0))
        table.insert(params.jx_car.widget.slotbg, {})
    end
end
for x = -1, 4 do
  table.insert(params.jx_car.widget.slotpos, Vector3(80 * x - 120, 80 * 2.5, 0))
  table.insert(params.jx_car.widget.slotbg, {image = "jx_car_slot.tex", atlas = "images/jx_slots/jx_car_slot.xml"})
end

function params.jx_car.itemtestfn(container, item, slot)
    if slot and slot >= 31 then
      if item:HasTag("jx_parts") then
        return true
      else
        return false
      end
    end
    return true
end
------------------------------------------------------------------------------
--复古亚历山大地窖
------------------------------------------------------------------------------
params.jx_cellar =
{
    widget =
    {
        slotpos = {},
        slotbg = {},
        animbank = "ui_jx_cellar_5x5",
        animbuild = "ui_jx_cellar_5x5",
        pos = Vector3(400, -70, 0),
        side_align_tip = 160,
    },
    type = "chest",
}

for y = 2.5, -2.5, -1 do
    for x = -1, 4 do
        table.insert(params.jx_cellar.widget.slotpos, Vector3(80 * x - 120, 80 * y - 8, 0))
    end
end

function params.jx_cellar.itemtestfn(container, item, slot)
	return (
           (
             item:HasTag("fresh") or
             item:HasTag("stale") or
             item:HasTag("spoiled")
            )
		        and item:HasTag("cookable")
	         	and not item:HasTag("deployable")
		        and not item:HasTag("smallcreature")
		        and item.replica.health == nil
          )
		      or item:HasTag("saltbox_valid")
          or item.prefab == "saltrock"
          or item.prefab == "coral" -- 海难珊瑚
end
------------------------------------------------------------------------------
--田园干草车
------------------------------------------------------------------------------
params.jx_hay_cart =
{
    widget =
    {
        slotpos = {},
        slotbg = {},
        animbank = "ui_jx_hay_cart_5x5",
        animbuild = "ui_jx_hay_cart_5x5",
        pos = Vector3(400, -70, 0),
        side_align_tip = 160,
    },
    type = "chest",
}

for y = 2.5, -2.5, -1 do
    for x = -1, 4 do
        table.insert(params.jx_hay_cart.widget.slotpos, Vector3(80 * x - 120, 80 * y, 0))
    end
end

function params.jx_hay_cart.itemtestfn(container, item, slot)
  return item.prefab == "cutgrass" or item.prefab == "rope" or item:HasTag("jx_hay_cart_valid")
end
------------------------------------------------------------------------------
--庄园手推车
------------------------------------------------------------------------------
params.jx_handcart =
{
    widget =
    {
        slotpos = {},
        slotbg = {},
        animbank = "ui_jx_hay_cart_5x5",
        animbuild = "ui_jx_hay_cart_5x5",
        pos = Vector3(400, -70, 0),
        side_align_tip = 160,
    },
    type = "chest",
}

for y = 2.5, -2.5, -1 do
    for x = -1, 4 do
        table.insert(params.jx_handcart.widget.slotpos, Vector3(80 * x - 120, 80 * y, 0))
    end
end

function params.jx_handcart.itemtestfn(container, item, slot)
  return item.prefab == "twigs" or item:HasTag("jx_handcart_valid")
end
------------------------------------------------------------------------------
--庄园木柴箱
------------------------------------------------------------------------------
params.jx_wood_bin =
{
    widget =
    {
        slotpos = {},
        slotbg = {},
        animbank = "ui_jx_hay_cart_5x5",
        animbuild = "ui_jx_hay_cart_5x5",
        pos = Vector3(400, -70, 0),
        side_align_tip = 160,
    },
    type = "chest",
}

for y = 2.5, -2.5, -1 do
    for x = -1, 4 do
        table.insert(params.jx_wood_bin.widget.slotpos, Vector3(80 * x - 120, 80 * y, 0))
    end
end

function params.jx_wood_bin.itemtestfn(container, item, slot)
  return item.prefab == "boards" or item.prefab == "log" or item.prefab == "livinglog" or item:HasTag("jx_wood_bin_valid")
end
------------------------------------------------------------------------------
--庄园石料箱
------------------------------------------------------------------------------
params.jx_rock_bin =
{
    widget =
    {
        slotpos = {},
        slotbg = {},
        animbank = "ui_jx_rock_bin_5x5",
        animbuild = "ui_jx_rock_bin_5x5",
        pos = Vector3(400, -70, 0),
        side_align_tip = 160,
    },
    type = "chest",
}

for y = 2.5, -2.5, -1 do
    for x = -1, 4 do
        table.insert(params.jx_rock_bin.widget.slotpos, Vector3(80 * x - 120, 80 * y, 0))
    end
end

function params.jx_rock_bin.itemtestfn(container, item, slot)
  return item.prefab == "rocks"
    or item.prefab == "cutstone" 
    or item.prefab == "flint"
    or item.prefab == "nitre"
    or item:HasTag("jx_rock_bin_valid")
end
------------------------------------------------------------------------------
--野餐系列背包
------------------------------------------------------------------------------
local jx_backpack_containerslot = TUNING.JX_TUNING.jx_backpack_containerslot
if jx_backpack_containerslot > 8 then
  params.jx_backpack =
  {
    widget =
    {
        slotpos = {},
        animbank = "ui_piggyback_2x6",
        animbuild = "ui_piggyback_2x6",
        pos = Vector3(-5, -90, 0),
    },
    issidewidget = true,
    type = "pack",
    openlimit = 1,
  }
  local pos_list = {}
  for y = 0, 5 do
    table.insert(pos_list, Vector3(-162, -75 * y + 170, 0))
    table.insert(pos_list, Vector3(-162 + 75, -75 * y + 170, 0))
  end
  for i = 1, jx_backpack_containerslot do
    table.insert(params.jx_backpack.widget.slotpos, pos_list[i])
  end
else
  params.jx_backpack =
  {
    widget =
    {
        slotpos = {},
        animbank = "ui_backpack_2x4",
        animbuild = "ui_backpack_2x4",
        pos = Vector3(-5, -80, 0),        
    },
    issidewidget = true,
    type = "pack",
    openlimit = 1,
  }
  for y = 0, 3 do
    table.insert(params.jx_backpack.widget.slotpos, Vector3(-162, -75 * y + 114, 0))
    table.insert(params.jx_backpack.widget.slotpos, Vector3(-162 + 75, -75 * y + 114, 0))
  end
end
---
local jx_backpack_2_containerslot = TUNING.JX_TUNING.jx_backpack_2_containerslot
if jx_backpack_2_containerslot > 8 then
  params.jx_backpack_2 =
  {
    widget =
    {
        slotpos = {},
        animbank = "ui_piggyback_2x6",
        animbuild = "ui_piggyback_2x6",
        pos = Vector3(-5, -90, 0),
    },
    issidewidget = true,
    type = "pack",
    openlimit = 1,
  }
  local pos_list = {}
  for y = 0, 5 do
    table.insert(pos_list, Vector3(-162, -75 * y + 170, 0))
    table.insert(pos_list, Vector3(-162 + 75, -75 * y + 170, 0))
  end
  for i = 1, jx_backpack_2_containerslot do
    table.insert(params.jx_backpack_2.widget.slotpos, pos_list[i])
  end
else
  params.jx_backpack_2 =
  {
    widget =
    {
        slotpos = {},
        animbank = "ui_backpack_2x4",
        animbuild = "ui_backpack_2x4",
        pos = Vector3(-5, -80, 0),        
    },
    issidewidget = true,
    type = "pack",
    openlimit = 1,
  }
  local pos_list = {}
  for y = 0, 3 do
    table.insert(params.jx_backpack_2.widget.slotpos, Vector3(-162, -75 * y + 114, 0))
    table.insert(params.jx_backpack_2.widget.slotpos, Vector3(-162 + 75, -75 * y + 114, 0))
  end
end
---
local jx_backpack_3_containerslot = TUNING.JX_TUNING.jx_backpack_3_containerslot
if jx_backpack_3_containerslot > 8 then
  params.jx_backpack_3 =
  {
    widget =
    {
        slotpos = {},
        animbank = "ui_piggyback_2x6",
        animbuild = "ui_piggyback_2x6",
        pos = Vector3(-5, -90, 0),
    },
    issidewidget = true,
    type = "pack",
    openlimit = 1,
  }
  local pos_list = {}
  for y = 0, 5 do
    table.insert(pos_list, Vector3(-162, -75 * y + 170, 0))
    table.insert(pos_list, Vector3(-162 + 75, -75 * y + 170, 0))
  end
  for i = 1, jx_backpack_3_containerslot do
    table.insert(params.jx_backpack_3.widget.slotpos, pos_list[i])
  end
else
  params.jx_backpack_3 =
  {
    widget =
    {
        slotpos = {},
        animbank = "ui_backpack_2x4",
        animbuild = "ui_backpack_2x4",
        pos = Vector3(-5, -80, 0),        
    },
    issidewidget = true,
    type = "pack",
    openlimit = 1,
  }
  local pos_list = {}
  for y = 0, 3 do
    table.insert(params.jx_backpack_3.widget.slotpos, Vector3(-162, -75 * y + 114, 0))
    table.insert(params.jx_backpack_3.widget.slotpos, Vector3(-162 + 75, -75 * y + 114, 0))
  end
end
---
local jx_backpack_4_containerslot = TUNING.JX_TUNING.jx_backpack_4_containerslot
if jx_backpack_4_containerslot > 8 then
  params.jx_backpack_4 =
  {
    widget =
    {
        slotpos = {},
        animbank = "ui_piggyback_2x6",
        animbuild = "ui_piggyback_2x6",
        pos = Vector3(-5, -90, 0),
    },
    issidewidget = true,
    type = "pack",
    openlimit = 1,
  }
  local pos_list = {}
  for y = 0, 5 do
    table.insert(pos_list, Vector3(-162, -75 * y + 170, 0))
    table.insert(pos_list, Vector3(-162 + 75, -75 * y + 170, 0))
  end
  for i = 1, jx_backpack_4_containerslot do
    table.insert(params.jx_backpack_4.widget.slotpos, pos_list[i])
  end
else
  params.jx_backpack_4 =
  {
    widget =
    {
        slotpos = {},
        animbank = "ui_backpack_2x4",
        animbuild = "ui_backpack_2x4",
        pos = Vector3(-5, -80, 0),        
    },
    issidewidget = true,
    type = "pack",
    openlimit = 1,
  }
  local pos_list = {}
  for y = 0, 3 do
    table.insert(params.jx_backpack_4.widget.slotpos, Vector3(-162, -75 * y + 114, 0))
    table.insert(params.jx_backpack_4.widget.slotpos, Vector3(-162 + 75, -75 * y + 114, 0))
  end
end
---
local jx_backpack_5_containerslot = TUNING.JX_TUNING.jx_backpack_5_containerslot
if jx_backpack_5_containerslot > 8 then
  params.jx_backpack_5 =
  {
    widget =
    {
        slotpos = {},
        animbank = "ui_piggyback_2x6",
        animbuild = "ui_piggyback_2x6",
        pos = Vector3(-5, -90, 0),
    },
    issidewidget = true,
    type = "pack",
    openlimit = 1,
  }
  local pos_list = {}
  for y = 0, 5 do
    table.insert(pos_list, Vector3(-162, -75 * y + 170, 0))
    table.insert(pos_list, Vector3(-162 + 75, -75 * y + 170, 0))
  end
  for i = 1, jx_backpack_5_containerslot do
    table.insert(params.jx_backpack_5.widget.slotpos, pos_list[i])
  end
else
  params.jx_backpack_5 =
  {
    widget =
    {
        slotpos = {},
        animbank = "ui_backpack_2x4",
        animbuild = "ui_backpack_2x4",
        pos = Vector3(-5, -80, 0),        
    },
    issidewidget = true,
    type = "pack",
    openlimit = 1,
  }
  local pos_list = {}
  for y = 0, 3 do
    table.insert(params.jx_backpack_5.widget.slotpos, Vector3(-162, -75 * y + 114, 0))
    table.insert(params.jx_backpack_5.widget.slotpos, Vector3(-162 + 75, -75 * y + 114, 0))
  end
end
------------------------------------------------------------------------------
--熊熊野餐盒
------------------------------------------------------------------------------
params.jx_pack =
{
    widget =
    {
        slotpos = 
        {
          Vector3(38, 38, 0),
          Vector3(38, -38, 0),
          Vector3(-38, -38, 0),
          Vector3(-38, 38, 0),
        },
        animbank = "ui_chest_2x2",
        animbuild = "ui_chest_2x2",
        pos = Vector3(160, 20, 0),
    },
    type = "chest",
    openlimit = 1,
}

function params.jx_pack.itemtestfn(container, item, slot)
    if item:HasAnyTag("icebox_valid", "beargerfur_sack_valid", "preparedfood", "fooddrink") then
        return true
    end

    --Perishable
    if not (item:HasTag("fresh") or item:HasTag("stale") or item:HasTag("spoiled")) then
        return false
    end

	if item:HasTag("smallcreature") then
		return false
	end

    --Edible
    for k, v in pairs(FOODTYPE) do
        if item:HasTag("edible_"..v) then
            return true
        end
    end

    return false
end
------------------------------------------------------------------------------
--手工菜篮
------------------------------------------------------------------------------
local jx_basket_containerslot = TUNING.JX_TUNING.jx_basket_containerslot
if jx_basket_containerslot == 9 then
  params.jx_basket =
  {
    widget =
    {
        slotpos = {},
        animbank  = "ui_jx_basket_3x3",
        animbuild = "ui_jx_basket_3x3",
        pos = Vector3(0, 200, 0),
        side_align_tip = 160,
    },
    type = "chest",
  }
  
  for y = 2, 0, -1 do
    for x = 0, 2 do
        table.insert(params.jx_basket.widget.slotpos, Vector3(80 * x - 80 * 2 + 80, 80 * y - 80 * 2 + 80, 0))
    end
  end
else
  params.jx_basket =
  {
    widget =
    {
        slotpos =
        {
          Vector3(-37.5, 32 + 4, 0),
          Vector3(37.5, 32 + 4, 0),
          Vector3(-37.5, -(32 + 4), 0),
          Vector3(37.5, -(32 + 4), 0),
        },
        animbank  = "ui_jx_basket_2x2",
        animbuild = "ui_jx_basket_2x2",
        pos = Vector3(200, 0, 0),
        side_align_tip = 120,
    },
    type = "chest",
  }
end

function params.jx_basket.itemtestfn(container, item, slot)
  if item:HasAnyTag("icebox_valid", "beargerfur_sack_valid", "preparedfood", "fooddrink") then
    return true
  end
  if not (item:HasTag("fresh") or item:HasTag("stale") or item:HasTag("spoiled")) then
    return false
  end
  if item:HasTag("smallcreature") then
    return false
  end
  for k, v in pairs(FOODTYPE) do
    if item:HasTag("edible_"..v) then
      return true
    end
  end
  return false
end
------------------------------------------------------------------------------
--展示柜
------------------------------------------------------------------------------
params.jx_bookcase = 
{
    widget =
    {
        slotpos =
        {
            Vector3(-159.5, -86, 0),
            Vector3(-84.5,  -86, 0),
            Vector3(-159.5, 0,   0),
            Vector3(-84.5,  0,   0),
            Vector3(-159.5, 86,  0),
            Vector3(-84.5,  86,  0),
        },
        animbank = "ui_backpack_2x4",
        animbuild = "ui_backpack_2x4",
        pos = Vector3(300, 0, 0),
        side_align_tip = 120,
    },
    acceptsstacks = false,
    type = "cooker",
}

function params.jx_bookcase.itemtestfn(container, item, slot)
  return item:HasTag("preparedfood")
end
-------------------------------------------------------------------------------
--制冰机
--------------------------------------------------------------------------------
params.jx_icemaker =
{
    widget =
    {
        slotpos =
        {
            Vector3(-37.5, 32 + 4, 0),
            Vector3(37.5, 32 + 4, 0),
            Vector3(-37.5, -(32 + 4), 0),
            Vector3(37.5, -(32 + 4), 0),
        },
        animbank = "ui_bundle_2x2",
        animbuild = "ui_bundle_2x2",
        pos = Vector3(200, 0, 0),
        side_align_tip = 120,
        buttoninfo =
        {
            text = STRINGS.JX_MAKE_ICE,
            position = Vector3(0, -100, 0),
        }
    },
    type = "cooker",
}

function params.jx_icemaker.itemtestfn(container, item, slot)
    return item:HasAnyTag("ice", "rocks")
end

function params.jx_icemaker.widget.buttoninfo.fn(inst, doer)
    if inst.components.container ~= nil then
        BufferedAction(doer, inst, ACTIONS.INCINERATE):Do()--(偷懒)
    elseif inst.replica.container ~= nil and not inst.replica.container:IsBusy() then
        SendRPCToServer(RPC.DoWidgetButtonAction, ACTIONS.INCINERATE.code, inst, ACTIONS.INCINERATE.mod_name)
    end
end

function params.jx_icemaker.widget.buttoninfo.validfn(inst)
    return inst.replica.container ~= nil and inst.replica.container:HasItemWithTag("rocks", 1)--至少一个
end
-------------------------------------------------------------------------------
--地毯包
--------------------------------------------------------------------------------
params.jx_rug_bag =
{
    widget =
    {
        slotpos = {},
        animbank  = "ui_jx_rug_bag_5x5",
        animbuild = "ui_jx_rug_bag_5x5",
        pos = Vector3(0, 200, 0),
        side_align_tip = 160,
    },
    type = "chest",
}

for y = 2.5, -2.5, -1 do
    for x = -1, 4 do
        table.insert(params.jx_rug_bag.widget.slotpos, Vector3(80 * x - 120, 80 * y - 5, 0))
    end
end

function params.jx_rug_bag.itemtestfn(container, item, slot)
    return item:HasTag("jx_rug_item") or item:HasTag("groundtile") and item.tile
end
------------------------------------------------------------------------------
--人台
------------------------------------------------------------------------------
if TUNING.JX_TUNING.jx_dress_form_containerslot == 9 then
  params.jx_dress_form_m =
  {
    widget =
    {
      slotpos = {},
      animbank = "ui_chest_3x3",
      animbuild = "ui_chest_3x3",
      pos = Vector3(0, 200, 0),
      side_align_tip = 160,
    },
    type = "chest",
  }
  
  for y = 2, 0, -1 do
    for x = 0, 2 do
        table.insert(params.jx_dress_form_m.widget.slotpos, Vector3(80 * x - 80 * 2 + 80, 80 * y - 80 * 2 + 80, 0))
    end
  end
else
  params.jx_dress_form_m =
  {
    widget =
    {
      slotpos = {Vector3(0, 0, 0)},
      animbank = "ui_chest_1x1",
      animbuild = "ui_chest_1x1",
      pos = Vector3(0, 160, 0),
      side_align_tip = 100,
    },
    type = "chest",
  }
end

function params.jx_dress_form_m.itemtestfn(container, item, slot)
    return item:HasTag("_equippable")
end

params.jx_dress_form_w = params.jx_dress_form_m
------------------------------------------------------------------------------
--复古橡木腌制桶
------------------------------------------------------------------------------
params.jx_pickling_barrel =
{
    widget =
    {
        slotpos = {},
        animbank = "ui_backpack_2x4",
        animbuild = "ui_backpack_2x4",
        pos = Vector3(275, 0, 0),
        side_align_tip = 100,
    },
    acceptsstacks = false,
    type = "cooker",
}

for y = 0, 3 do
    table.insert(params.jx_pickling_barrel.widget.slotpos, Vector3(-162, -75 * y + 114, 0))
    table.insert(params.jx_pickling_barrel.widget.slotpos, Vector3(-162 + 75, -75 * y + 114, 0))
end

function params.jx_pickling_barrel.itemtestfn(container, item, slot)
	return item:HasTag("dryable")
		or (TheWorld.ismastersim and (
				item:GetTimeAlive() == 0 or
				(	item.dryingrack_lastinfo and
					item.dryingrack_lastinfo.container == container and
					item.dryingrack_lastinfo.slot == slot
				)
			))
end
-----------------------------------------------------------------------------
--米勒的手电筒
------------------------------------------------------------------------------
params.jx_flashlight =
{
    widget =
    {
        slotpos = 
        {
          Vector3(0, 36, 0),
        },
        animbank = "ui_cookpot_1x2",
        animbuild = "ui_cookpot_1x2",
        pos = Vector3(0, 15, 0),
    },
    type = "hand_inv",
    excludefromcrafting = true,
    acceptsstacks = false,
}

function params.jx_flashlight.itemtestfn(container, item, slot)
    return item:HasTag("jx_battery")
end
-----------------------------------------------------------------------------
--田园藤编收纳筐
------------------------------------------------------------------------------
params.jx_storage_basket =
{
    widget =
    {
        slotpos = {},
        animbank = "ui_jx_storage_basket_4x4",
        animbuild = "ui_jx_storage_basket_4x4",
        pos = Vector3(0, 200, 0),
        side_align_tip = 160,
    },
    type = "chest",
}
for y = 3, 0, -1 do
  for x = 0, 3 do
    table.insert(params.jx_storage_basket.widget.slotpos, Vector3(80 * x - 120, 80 * y - 110, 0))
  end
end
-----------------------------------------------------------------------------
--庄园琥珀蜜箱
------------------------------------------------------------------------------
params.jx_honey_box =
{
    widget =
    {
        slotpos = {},
        animbank = "ui_jx_storage_basket_4x4",
        animbuild = "ui_jx_storage_basket_4x4",
        pos = Vector3(0, 200, 0),
        side_align_tip = 160,
    },
    type = "chest",
}
for y = 3, 0, -1 do
  for x = 0, 3 do
    table.insert(params.jx_honey_box.widget.slotpos, Vector3(80 * x - 120, 80 * y - 110, 0))
  end
end
function params.jx_honey_box.itemtestfn(container, item, slot)
    return item.prefab == "honey" or item.prefab == "royal_jelly"
      or item.prefab == "medal_withered_royaljelly" -- 勋章的凋零蜂王浆
      or item:HasTag("jx_honey_box_vaild")
end
------------------------------------------------------------------------------
---[[洛可可雕花玻璃柜]]
------------------------------------------------------------------------------
params.jx_cabinet = 
{
    widget =
    {
        slotpos =
        {
            Vector3(-2, 38 - 72, 0),
            Vector3(-2, 38, 0),
        },
        animbank = "ui_chest_1x2",
        animbuild = "ui_chest_1x2",
        pos = Vector3(0, 160, 0),
        side_align_tip = 100,
    },
    acceptsstacks = false,
    type = "chest",
}
-------------------------------------------------------------------------------
--罐头机
--------------------------------------------------------------------------------
params.jx_canner =
{
    widget =
    {
        slotpos =
        {
            Vector3(-37.5, 16, 0),
            Vector3(37.5, 16, 0),
        },
        slotbg =
        {
          { image = "jx_meat_dried_slot.tex", atlas = "images/jx_slots/jx_meat_dried_slot.xml" },
          { image = "jx_rocks_slot.tex", atlas = "images/jx_slots/jx_rocks_slot.xml" },
        },
        animbank = "ui_bundle_2x2",
        animbuild = "ui_bundle_2x2",
        pos = Vector3(200, 0, 0),
        side_align_tip = 120,
        buttoninfo =
        {
            text = STRINGS.JX_MAKE_CAN,
            position = Vector3(0, -100, 0),
        }
    },
    --acceptsstacks = false,
    type = "cooker",
}

local jx_canner_validitem =
{
  "rocks", -- 石头
  
  "kelp_dried", -- 干海带叶
  
  --"monstermeat_dried", -- 怪物肉干
  --"monstersmallmeat_dried", -- 小怪物肉干（永不妥协）
  "meat_dried", -- 肉干
  --"smallmeat_dried", -- 小肉干
  
  --"fishmeat_small_dried", -- 小鱼干
  "fishmeat_dried", -- 鱼干
}
      
function params.jx_canner.itemtestfn(container, item, slot)
    return item.prefab and table.contains(jx_canner_validitem, item.prefab) or false
end

function params.jx_canner.widget.buttoninfo.fn(inst, doer)
    if inst.components.container ~= nil then
        BufferedAction(doer, inst, ACTIONS.INCINERATE):Do() -- (偷懒)
    elseif inst.replica.container ~= nil and not inst.replica.container:IsBusy() then
        SendRPCToServer(RPC.DoWidgetButtonAction, ACTIONS.INCINERATE.code, inst, ACTIONS.INCINERATE.mod_name)
    end
end

function params.jx_canner.widget.buttoninfo.validfn(inst)
    local rocks = inst.replica.container ~= nil and inst.replica.container:FindItem(function(v) return v.prefab == "rocks" end)
    local others = inst.replica.container ~= nil and inst.replica.container:FindItem(function(v) return v.prefab ~= "rocks" end)
    return (rocks ~= nil and others ~= nil) or false
end
-------------------------------------------------------------------------------
--欧式铸铁炭炉
--------------------------------------------------------------------------------
params.jx_charcoal_stove =
{
  widget =
  {
      slotpos = {},
      animbank = "ui_chest_3x3",
      animbuild = "ui_chest_3x3",
      pos = Vector3(0, 200, 0),
      side_align_tip = 160,
      buttoninfo =
      {
        text = STRINGS.JX_MAKE_CHARCOAL,
        position = Vector3(0, -145, 0),
      }
  },
  type = "chest",
}
for y = 2, 0, -1 do
  for x = 0, 2 do
    table.insert(params.jx_charcoal_stove.widget.slotpos, Vector3(80 * x - 80 * 2 + 80, 80 * y - 80 * 2 + 80, 0))
  end
end

function params.jx_charcoal_stove.itemtestfn(container, item, slot)
    return item.prefab == "charcoal" or item.prefab == "log"
end

function params.jx_charcoal_stove.widget.buttoninfo.fn(inst, doer)
    if inst.components.container ~= nil then
        BufferedAction(doer, inst, ACTIONS.INCINERATE):Do() -- (偷懒)
    elseif inst.replica.container ~= nil and not inst.replica.container:IsBusy() then
        SendRPCToServer(RPC.DoWidgetButtonAction, ACTIONS.INCINERATE.code, inst, ACTIONS.INCINERATE.mod_name)
    end
end

function params.jx_charcoal_stove.widget.buttoninfo.validfn(inst)
    local log = inst.replica.container ~= nil and inst.replica.container:FindItem(function(v) return v.prefab == "log" end)
    return log ~= nil
end
-------------------------------------------------------------------------------
--切斯特狗屋
--------------------------------------------------------------------------------
params.jx_chester_house =
{
  widget =
  {
    slotpos = { Vector3(0, 0, 0) },
    slotbg = { { image = "jx_eyebone_slot.tex", atlas = "images/jx_slots/jx_eyebone_slot.xml" } },
    animbank = "ui_chest_1x1",
    animbuild = "ui_chest_1x1",
    pos = Vector3(0, 160, 0),
    side_align_tip = 100,
  },
  type = "chest",
}
function params.jx_chester_house.itemtestfn(container, item, slot)
    --旧存档可能已经放入了星空和鱼骨，暂时不改这个地方
    return item:HasAnyTag("chester_eyebone", "hutch_fishbowl", "packim_fishbone") -- 眼骨、星空、鱼骨
end
-------------------------------------------------------------------------------
--格鲁姆树屋
--------------------------------------------------------------------------------
params.jx_glommer_house =
{
  widget =
  {
    slotpos = { Vector3(0, 0, 0) },
    animbank = "ui_chest_1x1",
    animbuild = "ui_chest_1x1",
    pos = Vector3(0, 160, 0),
    side_align_tip = 100,
  },
  type = "chest",
}
function params.jx_glommer_house.itemtestfn(container, item, slot)
    return item:HasTag("glommerflower") -- 格鲁姆之花
end
-------------------------------------------------------------------------------
--野营锅具
--------------------------------------------------------------------------------
params.jx_portable_cook_pot = params.portablecookpot
-------------------------------------------------------------------------------
--狸猫陶土砂锅
--------------------------------------------------------------------------------
params.jx_portable_cook_pot_2 = params.portablecookpot
-------------------------------------------------------------------------------
--垃圾桶
--------------------------------------------------------------------------------
params.jx_trash_can =
{
  widget =
  {
    slotpos = {},
    animbank = "ui_boat_ancient_4x4",
    animbuild = "ui_boat_ancient_4x4",
    pos = Vector3(0, 200, 0),
    side_align_tip = 100,
  },
  type = "chest",
}
for y = 3, 0, -1 do
  for x = 0, 3 do
    table.insert(params.jx_trash_can.widget.slotpos, Vector3(80 * x - 80 * 2.5 + 80, 80 * y - 80 * 2.5 + 80, 0))
  end
end
function params.jx_trash_can.itemtestfn(container, item, slot)
    return item:HasAnyTag("fresh", "stale", "spoiled", "spoiledfood")
end
params.jx_trash_can_container =
{
  widget =
  {
    slotpos = {},
    animbank = "ui_boat_ancient_4x4",
    animbuild = "ui_boat_ancient_4x4",
    pos = Vector3(0, 200, 0),
    side_align_tip = 100,
  },
  type = "chest",
}
for y = 3, 0, -1 do
  for x = 0, 3 do
    table.insert(params.jx_trash_can_container.widget.slotpos, Vector3(80 * x - 80 * 2.5 + 80, 80 * y - 80 * 2.5 + 80, 0))
  end
end
--[[function params.jx_trash_can_container.itemtestfn(container, item, slot)
    return item:HasAnyTag("fresh", "stale", "spoiled")
end]]
-------------------------------------------------------------------------------
--猫猫币提款机
--------------------------------------------------------------------------------
params.jx_bankatm =
{
    widget =
    {
        slotpos = {},
        animbank = "ui_krampusbag_2x8",
        animbuild = "ui_krampusbag_2x8",
        pos = Vector3(380, 0, 0),
        buttoninfo =
        {
          text = STRINGS.ACTIONS.GIVE.EXCHANGE,
          position = Vector3(-120, -210, 0),
        }
    },
    type = "chest",
}
for y = 0, 5 do
    table.insert(params.jx_bankatm.widget.slotpos, Vector3(-162, -75 * y + 240, 0))
    table.insert(params.jx_bankatm.widget.slotpos, Vector3(-162 + 75, -75 * y + 240, 0))
end

function params.jx_bankatm.itemtestfn(container, item, slot)
    return item.prefab == "goldnugget" or item:HasTag("jx_catcoin")
end

function params.jx_bankatm.widget.buttoninfo.fn(inst, doer)
    if inst.components.container ~= nil then
        BufferedAction(doer, inst, ACTIONS.INCINERATE):Do()
    elseif inst.replica.container ~= nil and not inst.replica.container:IsBusy() then
        SendRPCToServer(RPC.DoWidgetButtonAction, ACTIONS.INCINERATE.code, inst, ACTIONS.INCINERATE.mod_name)
    end
end

function params.jx_bankatm.widget.buttoninfo.validfn(inst)
    return inst.replica.container ~= nil and inst.replica.container:Has("goldnugget", 5)
end
-------------------------------------------------------------------------------
--洗碗台
--------------------------------------------------------------------------------
params.jx_table_9 =
{
    widget =
    {
      slotpos = {},
      animbank = "ui_chest_3x3",
      animbuild = "ui_chest_3x3",
      pos = Vector3(0, 200, 0),
      side_align_tip = 160,
    },
    type = "chest",
}
for y = 2, 0, -1 do
    for x = 0, 2 do
        table.insert(params.jx_table_9.widget.slotpos, Vector3(80 * x - 80 * 2 + 80, 80 * y - 80 * 2 + 80, 0))
    end
end
-------------------------------------------------------------------------------
--农具架
--------------------------------------------------------------------------------
params.jx_farm_tools_container =
{
    widget =
    {
        slotpos = {},
        slotbg = {},
        animbank = "ui_jx_hay_cart_4x4",
        animbuild = "ui_jx_hay_cart_4x4",
        pos = Vector3(400, -70, 0),
        side_align_tip = 160,
    },
    type = "chest",
}
for y = 1.5, -1.5, -1 do
    for x = 0, 3 do
        table.insert(params.jx_farm_tools_container.widget.slotpos, Vector3(80 * x - 120, 80 * y, 0))
    end
end

function params.jx_farm_tools_container.itemtestfn(container, item, slot)
    return item:HasTag("jx_farm_tools_container_valid")
end
------------------------------------------------------------------------------
--更新最大插槽
for k, v in pairs(params) do
    containers.MAXITEMSLOTS = math.max(containers.MAXITEMSLOTS, v.widget.slotpos ~= nil and #v.widget.slotpos or 0)
end