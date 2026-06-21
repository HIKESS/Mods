local ThePlayer = GLOBAL.ThePlayer
local TheInput = GLOBAL.TheInput
local SpawnPrefab = GLOBAL.SpawnPrefab

GLOBAL.setmetatable(env,{__index=function(t,k) return GLOBAL.rawget(GLOBAL,k) end})

----[]----[]----[]----[]----[]----[]----[]----[]----[]----[]----[]----[]----[]----[]----[]----
local containers = require('containers')
local cooking = require("cooking")
local params = containers.params

params.gwen_back =
{
    widget =
    {
        slotpos = {},
        -- animbank = "ui_piggyback_2x6",
        -- animbuild = "ui_piggyback_2x6",

		animbank = "ui_krampusbag_2x8",
        animbuild = "ui_krampusbag_2x8",
        slotbg = {
            { image = "xiufugezi.tex", atlas = "images/inventoryimages/xiufugezi.xml" },
            { image = "xiufugezi.tex", atlas = "images/inventoryimages/xiufugezi.xml" },
            { image = nil, atlas = nil },
            { image = nil, atlas = nil },
            { image = nil, atlas = nil },
            { image = nil, atlas = nil },
            { image = nil, atlas = nil },
            { image = nil, atlas = nil },
            { image = nil, atlas = nil },
            { image = nil, atlas = nil },
            { image = nil, atlas = nil },
            { image = nil, atlas = nil },
            { image = "gw_guajian.tex", atlas = "images/inventoryimages/gw_guajian.xml" },
        },		

        pos = Vector3(600, 10, 0),

		----新增按钮
		buttoninfo = {
			position = Vector3(-122, 294, 0),
		},
		gwen_back = "gwen_back_chest",--拖拽标签，有则可拖拽
    },
--    issidewidget = true,

    type = "gwen_back",
    openlimit = 1,
}

STRINGS.GWEN_XIUFU = "修理"
params.gwen_back.widget.buttoninfo.text = STRINGS.GWEN_XIUFU
function params.gwen_back.widget.buttoninfo.fn(inst)
    SendModRPCToServer(GetModRPC("gwenr", "gw_xiufu"))
end

function params.gwen_back.itemtestfn(container, item, slot)
	if slot == 13 then
		return item:HasTag("gw_guajian")
	else
		return true
	end
end

for y = 0, 5 do
    table.insert(params.gwen_back.widget.slotpos, Vector3(-162, -75 * y +240 , 0))
    table.insert(params.gwen_back.widget.slotpos, Vector3(-162 + 75, -75 * y +240, 0))
end

table.insert(params.gwen_back.widget.slotpos, Vector3(-122, -212, 0))

----[]----[]----[]----[]----[]----[]----[]----[]----[]----[]----[]----[]----[]----[]----[]----
----新增的格温衣服盒
params.gwen_box =
{
    widget =
    {
        slotpos = {},
        animbank = "ui_chester_upgraded_3x4",
        animbuild = "ui_chester_upgraded_3x4",
        slotbg = {}, 
        
        pos = Vector3(420, -80, 0),  -- 默认位置

        gwen_back = "gwen_box_chest",  -- 拖拽标签，用于UI拖拽
    },

    type = "gwen_box",
    openlimit = 1,
}

for y = 0, 3 do
    for x = 0, 2 do
        table.insert(params.gwen_box.widget.slotpos, Vector3(80 * x - 80, -80 * y + 120, 0))
    end
end

for i = 1, 12 do
    params.gwen_box.widget.slotbg[i] = { image = nil, atlas = nil }
end


function params.gwen_box.itemtestfn(container, item, slot)
    if item:HasTag("gw_fuzhuang") then
        return true
    end
    local crafting_filters = CRAFTING_FILTERS
    if crafting_filters and crafting_filters.CLOTHING and crafting_filters.CLOTHING.recipes then
        for _, recipe_name in ipairs(crafting_filters.CLOTHING.recipes) do
            if item.prefab == recipe_name then
                return true
            end
        end
    end
    return false
end

----[]----[]----[]----[]----[]----[]----[]----[]----[]----[]----[]----[]----[]----[]----[]----
---蘸豆帽子1容器
params.gw_maozi_zhandou =
{
    widget =
    {
        slotpos =
        {
			Vector3(-4, -15, 0)
		},
	    animbank = "gw_maozi_badge",
        animbuild = "gw_maozi_badge",
        slotbg = { image = nil, atlas = nil },
       	pos = Vector3(106, 35, 0),
    },
    type = "hand_inv",
}

function params.gw_maozi_zhandou.itemtestfn(container, item, slot)
    return (item:HasTag("lightbattery") or item:HasTag("lightcontainer")) and not container.inst:HasTag("burnt")
end

----[]----[]----[]----[]----[]----[]----[]----[]----[]----[]----[]----[]----[]----[]----[]----
---
---
----[]----[]----[]----[]----[]----[]----[]----[]----[]----[]----[]----[]----[]----[]----[]----
---蘸豆帽子2容器
params.gw_maozi_zhandou2 =
{
    widget =
    {
        slotpos =
        {
			Vector3(-4, -15, 0)
		},
	    animbank = "gw_maozi_badge",
        animbuild = "gw_maozi_badge",
        slotbg = { image = nil, atlas = nil },
       	pos = Vector3(106, 35, 0),
    },
    type = "hand_inv",
}

function params.gw_maozi_zhandou2.itemtestfn(container, item, slot)
    return (item:HasTag("lightbattery") or item:HasTag("lightcontainer")) and not container.inst:HasTag("burnt")
end

----[]----[]----[]----[]----[]----[]----[]----[]----[]----[]----[]----[]----[]----[]----[]----

----模组容器UI拖拽----[]----[]----[]----[]----[]----[]----[]----[]----[]----[]----
----代码来自能力勋章
----这里和能力勋章已确定兼容,但和本地模组冲突
local gwen_ui_list = {}--UI列表，方便重置
--拖拽坐标，局部变量存储，减少io操作
local gwen_dragpos = {}
--更新同步拖拽坐标(如果容器没打开过，那么存储的坐标信息就没被赋值到gwen_dragpos里，这时候直接去存储就会导致之前存储的数据缺失，所以要主动取一下数据存到gwen_dragpos里)
local function loadgwen_dragpos()
	TheSim:GetPersistentString("gwen_drag_pos", function(load_success, data)
		if load_success and data ~= nil then
            local success, allpos = RunInSandbox(data)
		    if success and allpos then
				for k, v in pairs(allpos) do
					if gwen_dragpos[k] == nil then
						gwen_dragpos[k] = Vector3(v.x or 0, v.y or 0, v.z or 0)
					end
				end
			end
		end
	end)
end

--存储拖拽后坐标
local function savegwen_dragpos(gwen_back,pos)
   if gwen_back and pos then
      gwen_dragpos[gwen_back] = pos
   end
   if next(gwen_dragpos) then
	  local str = DataDumper(gwen_dragpos, nil, true)
      TheSim:SetPersistentString("gwen_drag_pos", str, false)
   end
end

--获取拖拽坐标
local function GetMedalgwen_dragpos_gwen(gwen_back)
	if gwen_dragpos[gwen_back] == nil then
		loadgwen_dragpos()
	end
	return gwen_dragpos[gwen_back]
end

--设置UI可拖拽(self,拖拽目标,拖拽标签,拖拽信息)
local function MakeMedalDragableUI_gwen(self,dragtarget,gwen_back,dragdata)
	self.candrag = true                --可拖拽标识(防止重复添加拖拽功能)
	gwen_ui_list[self] = self:GetPosition()  --存储UI默认坐标
	--给拖拽目标添加拖拽提示
	if dragtarget then
		dragtarget:SetTooltip("按住右键可拖拽\n中键恢复默认")
		local oldOnControl = dragtarget.OnControl
		dragtarget.OnControl = function (self,control, down)
            local parentwidget = self:GetParent() --控制它爹的坐标,而不是它自己
			--按下右键可拖动
			if parentwidget and parentwidget.Passive_OnControl then
				parentwidget:Passive_OnControl(control, down)
			end
			return oldOnControl(self,control,down)
		end
	end

	--被控制(控制状态，是否按下)
	function self:Passive_OnControl(control, down)
		if self.focus and control == CONTROL_SECONDARY then  --按下右键
			if down then
				self:StartDrag()
			else
				self:EndDrag()
			end
        end
	end
	--设置拖拽坐标
	function self:Setgwen_dragposition(x, y, z)
		local pos
		if type(x) == "number" then
			pos = Vector3(x, y, z)
		else
			pos = x
		end
		
		local self_scale = self:GetScale()
		local offset = dragdata and dragdata.drag_offset or 1--偏移修正(容器是0.6)
		local newpos = self.p_startpos + (pos-self.m_startpos)/(self_scale.x/offset)--修正偏移值
		self:SetPosition(newpos)--设定新坐标
	end

	--开始拖动
	function self:StartDrag()
		if not self.followhandler then
			local mousepos = TheInput:GetScreenPosition()
			self.m_startpos = mousepos--鼠标初始坐标
			self.p_startpos = self:GetPosition()--面板初始坐标
			self.followhandler = TheInput:AddMoveHandler(function(x,y)
				self:Setgwen_dragposition(x,y,0)
				if not Input:IsMouseDown(MOUSEBUTTON_RIGHT) then
					self:EndDrag()
				end
			end)
			self:Setgwen_dragposition(mousepos)
		end
	end
	
	--停止拖动
	function self:EndDrag()
		if self.followhandler then
			self.followhandler:Remove()
		end
		self.followhandler = nil
		self.m_startpos = nil
		self.p_startpos = nil
		local newpos = self:GetPosition()
		if gwen_back then
			gwen_dragpos[gwen_back] = newpos--记录拖拽后坐标
		end
		savegwen_dragpos()--存储坐标
	end
end

--按下中键重置对应容器的坐标
local function ResetMoranUIPosByType_gwen(_self,dragtarget,gwen_back)
	if gwen_back then
		local oldOnMouseButton = dragtarget.OnMouseButton
		dragtarget.OnMouseButton = function(self, button, down, ...)
			if button == MOUSEBUTTON_MIDDLE and down and not TheInput:IsMouseDown(MOUSEBUTTON_RIGHT) then
				-- ResetMedalUIPos() -- 重置所有坐标
				gwen_dragpos[gwen_back] = nil -- 重置拖拽坐标
				local str = DataDumper(gwen_dragpos, nil, true)
				TheSim:SetPersistentString("moran_drag_pos", str, false)
				_self:SetPosition(gwen_ui_list[_self]) -- 重设坐标

				if self.followhandler then
					self.followhandler:Remove()
				end
				self.followhandler = nil
				self.m_startpos = nil
				self.p_startpos = nil
				if gwen_back then
					gwen_dragpos[gwen_back] = Vector3(600, -130, 0)
				end
				savegwen_dragpos()--存储坐标
			end
			return oldOnMouseButton(self, button, down, ...)
		end
	end
end


local function gwennewcontainerwidgetbutton(self)

    local Widget = require "widgets/widget"
    local TEMPLATES = require "widgets/redux/templates"

    local oldOpen = self.Open                       --保存原来的打开函数
    self.Open = function(self, container, doer)     --定义自己的打开函数
        local widget = container.replica.container:GetWidget()

    oldOpen(self, container, doer)


        --模组容器UI拖拽,来自勋章.
        if self.container and self.container.replica.container then
			if widget then	
				--拖拽坐标标签，有则用标签，无则用容器名
				if widget.gwen_back then 
					--设置可拖拽
					if not self.candrag then
						MakeMedalDragableUI_gwen(self,self.bgimage,widget.gwen_back,{drag_offset=0.6})
						MakeMedalDragableUI_gwen(self,self.bganim,widget.gwen_back,{drag_offset=0.6})
                        ResetMoranUIPosByType_gwen(self,self.bganim,widget.gwen_back)
					end
					--设置容器坐标(可装备的容器第一次打开做个延迟，不然加载游戏进来位置读不到)
					local newpos = GetMedalgwen_dragpos_gwen(widget.gwen_back) or Vector3(600, -130, 0)


					if newpos then
						if self.container:HasTag("_equippable") and not self.container.isopended then
							self.container:DoTaskInTime(0, function()
								self:SetPosition(newpos)
							end)
							self.container.isopended = true
						else
							self:SetPosition(newpos)
						end
					end
				end
			end
		end
    end
end


AddClassPostConstruct("widgets/containerwidget", gwennewcontainerwidgetbutton)



----[]----[]----[]----[]----[]----[]----[]----[]----[]----[]----[]----[]----[]----[]----[]----
---魂灯容器
params.gw_hundeng =
{
    widget =
    {
        slotpos =
        {
            Vector3(0, 32, 0),
        },
        slotbg =
        {
            { image = "soul_slot.tex", atlas = "images/hud2.xml"},
        },
        animbank = "ui_cookpot_1x2",
        animbuild = "ui_cookpot_1x2",
        pos = Vector3(0, 25, 0),
    },
    type = "hand_inv",
}

function params.gw_hundeng.itemtestfn(container, item, slot)
    return item:HasTag("gw_soul") and not item:HasTag("nosouljar")
end


----[]----[]----[]----[]----[]----[]----[]----[]----[]----[]----[]----[]----[]----[]----[]----
---格温的旅行背包（未升级）
params.gwen_backpack =
{
    widget =
    {
        slotpos = {},
        animbank = "ui_krampusbag_2x10",
        animbuild = "ui_krampusbag_2x10",
        pos = Vector3(-5, -80, 0),
        slotbg = {},	
    },
    issidewidget = true,
    type = "pack",
    openlimit = 1,
}

local start_x = -162
local start_y = 312
for row = 0, 7 do
    local y = start_y - 75 * row
    table.insert(params.gwen_backpack.widget.slotpos, Vector3(start_x, y, 0))
    table.insert(params.gwen_backpack.widget.slotpos, Vector3(start_x + 75, y, 0))
end

local hanger_y = start_y - 75 * 8
local hanger_x = start_x + 75 / 2
table.insert(params.gwen_backpack.widget.slotpos, Vector3(hanger_x, hanger_y, 0))

for i = 1, 10 do
    params.gwen_backpack.widget.slotbg[i] = { image = nil, atlas = nil }
end

for i = 13, 16 do
    params.gwen_backpack.widget.slotbg[i] = { image = "gw_lock.tex", atlas = "images/inventoryimages/gw_lock.xml" }
end

params.gwen_backpack.widget.slotbg[17] = {
    image = "gw_guajian.tex",
    atlas = "images/inventoryimages/gw_guajian.xml"
}


function params.gwen_backpack.itemtestfn(container, item, slot)
    if slot == nil then
        return true
    end
	if slot == 17 then
		return item:HasTag("gw_guajian")
	elseif slot >= 13 and slot <= 16 then
		return false
	else
		return true
	end
end


----[]----[]----[]----[]----[]----[]----[]----[]----[]----[]----[]----[]----[]----[]----[]----
---格温的旅行背包（白银）
params.gwen_backpack_1 =
{
    widget =
    {
        slotpos = {},
        animbank = "ui_krampusbag_2x10",
        animbuild = "ui_krampusbag_2x10",
        pos = Vector3(-5, -80, 0),
        slotbg = {},	
    },
    issidewidget = true,
    type = "pack",
    openlimit = 1,
}

for row = 0, 7 do
    local y = start_y - 75 * row
    table.insert(params.gwen_backpack_1.widget.slotpos, Vector3(start_x, y, 0))
    table.insert(params.gwen_backpack_1.widget.slotpos, Vector3(start_x + 75, y, 0))
end

table.insert(params.gwen_backpack_1.widget.slotpos, Vector3(hanger_x, hanger_y, 0))

for i = 1, 12 do
    params.gwen_backpack_1.widget.slotbg[i] = { image = nil, atlas = nil }
end

for i = 13, 16 do
    params.gwen_backpack_1.widget.slotbg[i] = { image = "gw_lock.tex", atlas = "images/inventoryimages/gw_lock.xml" }
end

params.gwen_backpack_1.widget.slotbg[17] = {
    image = "gw_guajian.tex",
    atlas = "images/inventoryimages/gw_guajian.xml"
}


function params.gwen_backpack_1.itemtestfn(container, item, slot)
    if slot == nil then
        return true
    end
	if slot == 17 then
		return item:HasTag("gw_guajian")
	elseif slot >= 13 and slot <= 16 then
		return false
	else
		return true
	end
end


----[]----[]----[]----[]----[]----[]----[]----[]----[]----[]----[]----[]----[]----[]----[]----
---格温的旅行背包（黄金）
params.gwen_backpack_2 =
{
    widget =
    {
        slotpos = {},
        animbank = "ui_krampusbag_2x10",
        animbuild = "ui_krampusbag_2x10",
        pos = Vector3(-5, -80, 0),
        slotbg = {},	
    },
    issidewidget = true,
    type = "pack",
    openlimit = 1,
}

for row = 0, 7 do
    local y = start_y - 75 * row
    table.insert(params.gwen_backpack_2.widget.slotpos, Vector3(start_x, y, 0))
    table.insert(params.gwen_backpack_2.widget.slotpos, Vector3(start_x + 75, y, 0))
end
table.insert(params.gwen_backpack_2.widget.slotpos, Vector3(hanger_x, hanger_y, 0))

for i = 1, 14 do
    params.gwen_backpack_2.widget.slotbg[i] = { image = nil, atlas = nil }
end

for i = 13, 16 do
    params.gwen_backpack_2.widget.slotbg[i] = { image = "gw_lock.tex", atlas = "images/inventoryimages/gw_lock.xml" }
end

params.gwen_backpack_2.widget.slotbg[17] = {
    image = "gw_guajian.tex",
    atlas = "images/inventoryimages/gw_guajian.xml"
}


function params.gwen_backpack_2.itemtestfn(container, item, slot)
    if slot == nil then
        return true
    end
	if slot == 17 then
		return item:HasTag("gw_guajian")
	elseif slot >= 13 and slot <= 16 then
		return false
	else
		return true
	end
end


----[]----[]----[]----[]----[]----[]----[]----[]----[]----[]----[]----[]----[]----[]----[]----
---格温的旅行背包（棱彩）
params.gwen_backpack_3 =
{
    widget =
    {
        slotpos = {},
        animbank = "ui_krampusbag_2x10",
        animbuild = "ui_krampusbag_2x10",
        pos = Vector3(-5, -80, 0),
        slotbg = {},	
    },
    issidewidget = true,
    type = "pack",
    openlimit = 1,
}

for row = 0, 7 do
    local y = start_y - 75 * row
    table.insert(params.gwen_backpack_3.widget.slotpos, Vector3(start_x, y, 0))
    table.insert(params.gwen_backpack_3.widget.slotpos, Vector3(start_x + 75, y, 0))
end
table.insert(params.gwen_backpack_3.widget.slotpos, Vector3(hanger_x, hanger_y, 0))

for i = 1, 16 do
    params.gwen_backpack_3.widget.slotbg[i] = { image = nil, atlas = nil }
end

params.gwen_backpack_3.widget.slotbg[17] = {
    image = "gw_guajian.tex",
    atlas = "images/inventoryimages/gw_guajian.xml"
}

function params.gwen_backpack_3.itemtestfn(container, item, slot)
    if slot == nil then
        return true
    end
	if slot == 17 then
		return item:HasTag("gw_guajian")
	else
		return true
	end
end



----[]----[]----[]----[]----[]----[]----[]----[]----[]----[]----[]----[]----[]----[]----[]----
---存放遗物的坟
params.gw_grave_chest =
{
     widget =
    {
        slotpos =
        {
            Vector3(-3, 15, 0),
        },
        slotbg = { { image = nil, atlas = nil },},
        animbank = "ui_chest_1x1",
        animbuild = "ui_chest_1x1",
        pos = Vector3(0, 150, 0),
    },
    type = "gw_grave_chest",
    openlimit = 1,
	acceptsstacks = false,
}
