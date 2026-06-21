
----等级数据
local gw_Level_Info_list = {
	{gw_Up_Level = 18, gw_Up_ExpDemand = 2000 },
	{gw_Up_Level = 17, gw_Up_ExpDemand = 1090 },
	{gw_Up_Level = 16, gw_Up_ExpDemand = 1000 },
	{gw_Up_Level = 15, gw_Up_ExpDemand = 780  },
	{gw_Up_Level = 14, gw_Up_ExpDemand = 690  },
	{gw_Up_Level = 13, gw_Up_ExpDemand = 600  },
	{gw_Up_Level = 12, gw_Up_ExpDemand = 510  },
	{gw_Up_Level = 11, gw_Up_ExpDemand = 420  },
	{gw_Up_Level = 10, gw_Up_ExpDemand = 360  },
	{gw_Up_Level = 9,  gw_Up_ExpDemand = 320  },
	{gw_Up_Level = 8,  gw_Up_ExpDemand = 260  },
	{gw_Up_Level = 7,  gw_Up_ExpDemand = 200  },
	{gw_Up_Level = 6,  gw_Up_ExpDemand = 170  },
	{gw_Up_Level = 5,  gw_Up_ExpDemand = 140  },
	{gw_Up_Level = 4,  gw_Up_ExpDemand = 110  },
	{gw_Up_Level = 3,  gw_Up_ExpDemand = 80   },
	{gw_Up_Level = 2,  gw_Up_ExpDemand = 50   },
	{gw_Up_Level = 1,  gw_Up_ExpDemand = 20   },
}    ----等级         ----所需经验         

local function gw_Level_Info(inst_level, gw_Level_Info_name)
	for _, v in pairs(gw_Level_Info_list) do
		if inst_level >= v.gw_Up_Level then
			return v[gw_Level_Info_name] 
		end
	end
end

local function current_gwen_Level(self, gwen_Level)
    self.inst.replica.gwen_competence:Setgwen_Level(gwen_Level)
end

local function current_gwen_Exp(self, gwen_Exp)
    self.inst.replica.gwen_competence:Setgwen_Exp(gwen_Exp)
end

local function current_UIswitch(self,UIswitch)
	self.inst.current_UIswitch:set(UIswitch)
end

local function currentfeizhen(self,feizhen)
	self.inst.currentfeizhen:set(feizhen)
end

local function currentcengshu(self,cengshu)
	self.inst.currentcengshu:set(cengshu)
end

local function currentmianxiang(self,mianxiang)
	self.inst.currentmianxiang:set(mianxiang)
end

local function currentVkeepmianxiang(self,Vkeepmianxiang)
	self.inst.currentVkeepmianxiang:set(Vkeepmianxiang)
end

local function currentZkeepmianxiang(self,Zkeepmianxiang)
	self.inst.currentZkeepmianxiang:set(Zkeepmianxiang)
end

local function currentgwen_chengfa(self,gwen_chengfa)
	self.inst.currentgwen_chengfa:set(gwen_chengfa)
end

local function currentgwen_equip(self,gwen_equip)
	self.inst.currentgwen_equip:set(gwen_equip)
end

local function gwen_Refresh(inst, self)
	local gw_ExpDemand = gw_Level_Info(self.gwen_Level, "gw_Up_ExpDemand") or 0
	----满级前设定
	if self.gwen_Exp >= gw_ExpDemand then
		self.gwen_Exp = self.gwen_Exp - gw_ExpDemand
		self.gwen_Level = self.gwen_Level + 1
		self.inst:PushEvent("gw_level")
		local fx = SpawnPrefab("fx_book_light_upgraded")
		fx.entity:SetParent(self.inst.entity)
		fx.Transform:SetPosition(0, 0, 0)
		fx:ListenForEvent("animover", fx.Remove)
	end
end

local gwen_competence = Class(function(self, inst)
    self.inst = inst

	self.gwen_Level = 1
	self.gwen_Exp = 0

    self.Vkeepmianxiang = 0
    self.Zkeepmianxiang = 0
    self.UIswitch = 0
    self.feizhen = 0
    self.cengshu = 1
    self.mianxiang = 0
    self.gwen_chengfa = 0

	self.level_up_granted = 0


	self.inst:DoPeriodicTask(0, gwen_Refresh, nil, self)
end,
nil,
{
    gwen_Level = current_gwen_Level,
    gwen_Exp = current_gwen_Exp,

    UIswitch = current_UIswitch,
    feizhen = currentfeizhen,
    cengshu = currentcengshu,
    mianxiang = currentmianxiang,
	Vkeepmianxiang = currentVkeepmianxiang,
	Zkeepmianxiang = currentZkeepmianxiang,
	gwen_chengfa = currentgwen_chengfa,
	gwen_equip = currentgwen_equip,
})

function gwen_competence:Reset_gwen_Level() self.gwen_Level = 1 end
function gwen_competence:Incr_gwen_Level(count) self.gwen_Level = self.gwen_Level + count end
function gwen_competence:Get_gwen_Level() return self.gwen_Level end
function gwen_competence:Set_gwen_Level(count) self.gwen_Level = count end

function gwen_competence:Reset_gwen_Exp() self.gwen_Exp = 0 end
function gwen_competence:Incr_gwen_Exp(count) self.gwen_Exp = self.gwen_Exp + count end
function gwen_competence:Get_gwen_Exp() return self.gwen_Exp end
function gwen_competence:Set_gwen_Exp(count) self.gwen_Exp = count end

function gwen_competence:Vkeepmianxiang_1() self.Vkeepmianxiang = 1 end
function gwen_competence:Vkeepmianxiang_0() self.Vkeepmianxiang = 0 end
function gwen_competence:Get_Vkeepmianxiang() return self.Vkeepmianxiang end

function gwen_competence:Zkeepmianxiang_1() self.Zkeepmianxiang = 1 end
function gwen_competence:Zkeepmianxiang_0() self.Zkeepmianxiang = 0 end
function gwen_competence:Get_Zkeepmianxiang() return self.Zkeepmianxiang end


function gwen_competence:UIswitch_1() self.UIswitch = 1 end
function gwen_competence:UIswitch_0() self.UIswitch = 0 end
function gwen_competence:Get_UIswitch() return self.UIswitch end

function gwen_competence:mianxiang_1() self.mianxiang = 1 end
function gwen_competence:mianxiang_0() self.mianxiang = 0 end
function gwen_competence:Get_mianxiang() return self.mianxiang end

function gwen_competence:feizhen_1() self.feizhen = 1 end
function gwen_competence:feizhen_0() self.feizhen = 0 end
function gwen_competence:Get_feizhen() return self.feizhen end

function gwen_competence:Reset_cengshu() self.cengshu = 1 end
function gwen_competence:Incr_cengshu(count) self.cengshu = self.cengshu + count end
function gwen_competence:Get_cengshu() return self.cengshu end


function gwen_competence:Reset_gwen_chengfa() self.gwen_chengfa = 0 end
function gwen_competence:Incr_gwen_chengfa(count)
	self.gwen_chengfa = self.gwen_chengfa + count
	if self.gwen_chengfa <= 0 then
		self.gwen_chengfa = 0
	elseif self.gwen_chengfa >= 4 then
		self.gwen_chengfa = 4
	end
end
function gwen_competence:Get_gwen_chengfa() return self.gwen_chengfa end
function gwen_competence:Set_gwen_chengfa(count) self.gwen_chengfa = count end

function gwen_competence:OnGwen_equip() self.gwen_equip = 1 end
function gwen_competence:OffGwen_equip() self.gwen_equip = 0 end
function gwen_competence:Get_gwen_equip() return self.gwen_equip end


function gwen_competence:OnSave() --保存
	local data = { --保存当前值

	gwen_Level = self.gwen_Level,
	gwen_Exp = self.gwen_Exp,
	UIswitch = self.UIswitch,
	feizhen = self.feizhen,
	cengshu = self.cengshu,
	mianxiang = self.mianxiang,
	Vkeepmianxiang = self.Vkeepmianxiang,----保持面向
	Zkeepmianxiang = self.Zkeepmianxiang,----保持面向
	gwen_chengfa = self.gwen_chengfa,----死亡惩罚
	gwen_equip = self.gwen_equip,----隐藏外观

	level_up_granted = self.level_up_granted,

	}
	return data
end

function gwen_competence:OnLoad(data) --加载
	if data ~= nil then
		if data.gwen_Level then
			self.gwen_Level = data.gwen_Level or 1
		end
		if data.gwen_Exp then
			self.gwen_Exp = data.gwen_Exp or 0
		end

		if data.UIswitch then
			self.UIswitch = data.UIswitch or 0
		end
		if data.Vkeepmianxiang then
			self.Vkeepmianxiang = data.Vkeepmianxiang or 0
		end
		if data.Zkeepmianxiang then
			self.Zkeepmianxiang = data.Zkeepmianxiang or 0
		end
		if data.gwen_chengfa then
			self.gwen_chengfa = data.gwen_chengfa or 0
		end
		if data.gwen_equip then
			self.gwen_equip = data.gwen_equip or 0
		end

		if data.level_up_granted then
			self.level_up_granted = data.level_up_granted or 0
		end
	end
end

function gwen_competence:GetLevelUpGranted() return self.level_up_granted end
function gwen_competence:IncrLevelUpGranted()
    if self.level_up_granted < 15 then
        self.level_up_granted = self.level_up_granted + 1
        return true
    end
    return false
end


return gwen_competence
