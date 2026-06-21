

local function current_gw_Level(self, gw_Level)
    self.inst.replica.gwen_equip:Setgw_Level(gw_Level)
end

local function current_gw_refactor(self, gw_refactor)
    self.inst.replica.gwen_equip:Setgw_refactor(gw_refactor)
end

local function current_gw_alchemy(self, gw_alchemy)
    self.inst.replica.gwen_equip:Setgw_alchemy(gw_alchemy)
end
local gwen_equip = Class(function(self, inst)
    self.inst = inst
	self.gw_Level = 0
	self.gw_refactor = 0
	self.gw_alchemy = 0

end,nil,
{
	gw_Level = current_gw_Level,
	gw_refactor = current_gw_refactor,
	gw_alchemy = current_gw_alchemy,
})

function gwen_equip:Getgw_Level() return self.gw_Level end
function gwen_equip:Incrgw_Level(count) self.gw_Level = self.gw_Level + count end
function gwen_equip:Setgw_Level(count) self.gw_Level = count end

----重构
function gwen_equip:Getgw_refactor() return self.gw_refactor end
function gwen_equip:Setgw_refactor() self.gw_refactor = 1 self.gw_alchemy = 0 end

----炼金
function gwen_equip:Getgw_alchemy() return self.gw_alchemy end
function gwen_equip:Setgw_alchemy()	self.gw_alchemy = 1	self.gw_refactor = 0 end


function gwen_equip:OnSave() --保存
	local data = {
		gw_Level = self.gw_Level,
		gw_refactor = self.gw_refactor,
		gw_alchemy = self.gw_alchemy,
	}
	return data
end

function gwen_equip:OnLoad(data) --加载
	if data.gw_Level then
        self.gw_Level = data.gw_Level or 0
    end
	if data.gw_refactor then
        self.gw_refactor = data.gw_refactor or 0
    end
	if data.gw_alchemy then
        self.gw_alchemy = data.gw_alchemy or 0
    end
end

return gwen_equip
