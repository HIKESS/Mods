local function wilton_enable(self)
    if self.name == "LoadoutSelect" then
        if not table.contains(DST_CHARACTERLIST, "wiltonmod") then
           table.insert(DST_CHARACTERLIST, "wiltonmod")
        end        
   elseif  self.name == "LoadoutRoot" then
        if table.contains(DST_CHARACTERLIST, "wiltonmod") then
            RemoveByValue(DST_CHARACTERLIST, "wiltonmod")
        end        
    end
end

AddClassPostConstruct("widgets/widget", wilton_enable)

local function removeStomachWilton(self, inst)
	if inst and inst.prefab == "wiltonmod" then
		self.brain:SetPosition(self.stomach:GetPosition()) --moves brain to where stomach was
		self.stomach:SetPosition(self.heart:GetPosition()) --moves stomach behind heart, JUST in case?
		inst:DoTaskInTime(0.5, function() self.stomach:Hide() end)	
		inst:ListenForEvent("ms_playerspawn", function()
			self.stomach:Hide()
		end)
		
		inst:ListenForEvent("playeractivated", function()
			self.stomach:Hide()
		end)
		
		inst:ListenForEvent("ms_respawnedfromghost", function()
			self.stomach:Hide()
		end)
		
		inst:ListenForEvent("hungerdelta", function()
			self.stomach:Hide()
		end)

		inst:ListenForEvent("is_skel_dirty", function()
			if inst._is_skel:value() == true then
			    self.brain:Hide()
			    --self.heart:Hide()
			else
			    self.brain:Show()
			    --self.heart:Show()			
			end    
		end)					
	end
end



AddClassPostConstruct("widgets/statusdisplays", removeStomachWilton)

local containers = require "containers"
local params = containers.params



params.wiltonmod_pack =
{
    widget =
    {
        slotpos = {},
        animbank = "ui_chester_shadow_3x4",
        animbuild = "ui_chester_shadow_3x4",
        pos = Vector3(0, 220, 0),
        side_align_tip = 160,
    },
    type = "wilton_chest",
    openlimit = 1,
}

for y = 2.5, -0.5, -1 do
    for x = 0, 2 do
        table.insert(params.wiltonmod_pack.widget.slotpos, Vector3(75 * x - 75 * 2 + 75, 75 * y - 75 * 2 + 75, 0))
    end
end

local test_table = {
	boneshard = true,
	fossil_piece = true
}

function params.wiltonmod_pack.itemtestfn(container, item, slot)
    return item:HasTag("wiltonmod_item") or test_table[item.prefab] ~= nil
end

--[[
params.kui_l_pack =
{
    widget =
    {
        slotpos = {},
        animbank = "ui_chest_3x3",
        animbuild = "klein_ui_5x5",
        pos = Vector3(0, 200, 0),
        side_align_tip = 160, 
    },
    issidewidget = true,
    type = "pack",
    openlimit = 1,
    itemtestfn = function(inst, item, slot)
        return not item:HasTag("_container") and not item:HasTag("bundle")
    end,
}

for y = 4, 0, 0 do
    for x = 0, 4 do
        table.insert(params.kui_l_pack.widget.slotpos, Vector3(80 * (x - 3) + 80, 80 * (y - 3) + 80, 0))
    end
end
]]
params.undead_armory =
{
    widget =
    {
        slotpos =
        {
            Vector3(0, 35, 0),
            Vector3(0, -35, 0),
        },
        animbank = "ui_chest_1x2",
        animbuild = "ui_chest_1x2",
        pos = Vector3(0, 200, 0),
        side_align_tip = 160,
    },
    type = "chest",
    itemtestfn = function(container, item, slot)
        if item.prefab == "flint" or item.prefab == "log" then
            return true
        end
        if item.prefab == "nightmarefuel" then
            local x, y, z = container.inst.Transform:GetWorldPosition()
            local players = TheSim:FindEntities(x, y, z, 20, {"player"}, {"INLIMBO"})
            for _, player in ipairs(players) do
                if player.components.skilltreeupdater
                    and player.components.skilltreeupdater:IsActivated("wiltonmod_skill2_9") then
                    return true
                end
            end
        end
        return false
    end,
}

for k, v in pairs(params) do
    containers.MAXITEMSLOTS = math.max(containers.MAXITEMSLOTS,
                                       v.widget.slotpos ~= nil and
                                           #v.widget.slotpos or 0)
end


--[[
local function changegoggle(self)
    local OldMakeUIStatusBadge = self.MakeUIStatusBadge
    function self:MakeUIStatusBadges(_status_name, c, ...)
    	print("_status_name = ".._status_name)
    	print("c = "..c)
        OldMakeUIStatusBadge(self, _status_name, c, ...)
    end
end

AddClassPostConstruct("widgets/redux/templates", HideHungerState)

local function HookRedux(name, fn)
    fn(require("widgets/redux/"..name))
end

HookRedux("templates", function(Templates)
	local OldMakeUIStatusBadge = Templates.MakeUIStatusBadge
    Templates.MakeUIStatusBadge = function(self, _status_name, c, ...)
        if _status_name and _status_name == "hunger" then
            print(_status_name)
            return
        end
        if c then
            print(c)
        end
        return OldMakeUIStatusBadge(self, _status_name, c, ...)	        	
    end
end)
]]