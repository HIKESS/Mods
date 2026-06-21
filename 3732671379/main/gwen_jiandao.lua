STRINGS = GLOBAL.STRINGS
TECH = GLOBAL.TECH
RECIPETABS = GLOBAL.RECIPETABS
Recipe = GLOBAL.Recipe
Ingredient = GLOBAL.Ingredient
TheWorld = GLOBAL.TheWorld
TUNING = GLOBAL.TUNING
GLOBAL.setmetatable(env, {__index = function(t, k)return GLOBAL.rawget(GLOBAL, k)end})

----[]----[]----[]----[]----[]----[]----[]----[]----[]----[]----[]----[]----[]----
GLOBAL.isModEnableById = isModEnableById
local KMI = GLOBAL.KnownModIndex
local modDir = KMI:GetModsToLoad(true)
local enableMods = {}

for k, dir in pairs(modDir) do
	local info = KMI:GetModInfo(dir)
	local name = info and info.name or "unknown"
	enableMods[dir] = name
end

function isModEnableById(Id)
	for k, dir in pairs(modDir) do
		if dir and (dir:match(Id)) then
			return true
		end
	end
	return false
end
----[]----[]----[]----[]----[]----[]----[]----[]----[]----[]----[]----[]----[]----

local Text = require "widgets/text"
local Image = require "widgets/image"
local Widget = require "widgets/widget"
local UIAnim = require "widgets/uianim"
AddClassPostConstruct("widgets/itemtile",function(self,invitem)
	

	if self.start_gwxiufu == nil then
		self.start_gwxiufu = self:AddChild(UIAnim())
		self.start_gwxiufu:GetAnimState():SetBank("fx_wathgrithr_buff")
		self.start_gwxiufu:GetAnimState():SetBuild("fx_wathgrithr_buff")
		self.start_gwxiufu:GetAnimState():AnimateWhilePaused(false)----暂停时停止播放动画
		self.start_gwxiufu:GetAnimState():SetDeltaTimeMultiplier(1.5)
		self.start_gwxiufu:SetPosition(0, -110, 0)
		self.start_gwxiufu:SetScale(.33)
		self.start_gwxiufu:SetClickable(false)
	elseif self.start_gwxiufu ~= nil then
		self.start_gwxiufu:Kill()
		self.start_gwxiufu = nil
	end
	
	if (self.item.prefab == "gwen_jiandao" or  self.item:HasTag("gw_backpack")) and self.item.replica.gwen_equip then
		----炼金
		self.gw_alchemy1 = self:AddChild(Image("images/inventoryimages/gw_alchemy1.xml", "gw_alchemy1.tex"))
		self.gw_alchemy1:SetClickable(false)
		self.gw_alchemy2 = self:AddChild(Image("images/inventoryimages/gw_alchemy2.xml", "gw_alchemy2.tex"))
		self.gw_alchemy2:SetClickable(false)
		self.gw_alchemy3 = self:AddChild(Image("images/inventoryimages/gw_alchemy3.xml", "gw_alchemy3.tex"))
		self.gw_alchemy3:SetClickable(false)
		self.gw_alchemy4 = self:AddChild(Image("images/inventoryimages/gw_alchemy4.xml", "gw_alchemy4.tex"))
		self.gw_alchemy4:SetClickable(false)

		----重构
		self.gw_refactor1 = self:AddChild(Image("images/inventoryimages/gw_refactor1.xml", "gw_refactor1.tex"))
		self.gw_refactor1:SetClickable(false)
		self.gw_refactor2 = self:AddChild(Image("images/inventoryimages/gw_refactor2.xml", "gw_refactor2.tex"))
		self.gw_refactor2:SetClickable(false)
		
		
		self.gw_refactor1:Hide()
		self.gw_refactor2:Hide()
		self.gw_alchemy1:Hide()
		self.gw_alchemy2:Hide()
		self.gw_alchemy3:Hide()
		self.gw_alchemy4:Hide()

	end

	if self.gw_zhizhen == nil and self.item:HasTag("gw_zhizhen") then
		self.gw_zhizhen = self:AddChild(UIAnim())
		self.gw_zhizhen:GetAnimState():SetBank("bank0")
		self.gw_zhizhen:GetAnimState():SetBuild("skeleton1")
		self.gw_zhizhen:GetAnimState():PlayAnimation("animation", true)
		self.gw_zhizhen:SetScale(1)
		self.gw_zhizhen:SetPosition(-4, -17, 0)
		self.gw_zhizhen:SetClickable(false)
	end


	if self.item.replica.gwen_refactor
	or ((self.item.prefab == "gwen_jiandao" or  self.item:HasTag("gw_backpack")) and self.item.replica.gwen_equip)
	then
		self.gw_refactor3 = self:AddChild(Image("images/inventoryimages/gw_refactor3.xml", "gw_refactor3.tex"))
		self.gw_refactor3:SetClickable(false)
		self.gw_refactor3:Hide()
	end

	function self:gw_UiRefresh()
		if self.start_gwxiufu ~= nil then
			if self.item:HasTag("start_gwxiufu") then
				self.start_gwxiufu:Show()
				local battlesong_fx = {
					fx_durability = .25,
					fx_healthgain = .25,
					fx_sanitygain = .25,
					fx_sanityaura = .25,
					fx_fireresistance = .25,
				}
				self.start_gwxiufu:GetAnimState():PlayAnimation(weighted_random_choice(battlesong_fx))
			else
				self.start_gwxiufu:Hide()
			end
		end
		if self.gw_zhizhen ~= nil then 
			if self.item:HasTag("gw_hunqiancd") then
				if self.item:HasTag("gw_hunqian") then
					self.gw_zhizhen:GetAnimState():SetDeltaTimeMultiplier(-4)
				else
					self.gw_zhizhen:GetAnimState():SetDeltaTimeMultiplier(.3)
				end
			else
				self.gw_zhizhen:GetAnimState():SetDeltaTimeMultiplier(1.3)
			end
		end
		if self.item.replica.gwen_equip then
			----重构

			if self.gw_refactor1 ~= nil then 
				if self.item.replica.gwen_equip:Getgw_Level() == 1 and self.item.replica.gwen_equip:Getgw_refactor() ~= 0 then
					self.gw_refactor1:Show()
				else
					self.gw_refactor1:Hide()
				end
			end

			if self.gw_refactor2 ~= nil then 
				if self.item.replica.gwen_equip:Getgw_Level() == 2 and self.item.replica.gwen_equip:Getgw_refactor() ~= 0 then
					self.gw_refactor2:Show()
				else
					self.gw_refactor2:Hide()
				end
			end

			if self.gw_refactor3 ~= nil then 
				if self.item.replica.gwen_equip:Getgw_Level() == 3 and self.item.replica.gwen_equip:Getgw_refactor() ~= 0 then
					self.gw_refactor3:Show()
				else
					self.gw_refactor3:Hide()
				end
			end

			----炼金
			if self.gw_alchemy1 ~= nil then 
				if self.item.replica.gwen_equip:Getgw_Level() == 1 and self.item.replica.gwen_equip:Getgw_alchemy() ~= 0 then
					self.gw_alchemy1:Show()
				else
					self.gw_alchemy1:Hide()
				end
			end
			if self.gw_alchemy2 ~= nil then 
				if self.item.replica.gwen_equip:Getgw_Level() == 2 and self.item.replica.gwen_equip:Getgw_alchemy() ~= 0 then
					self.gw_alchemy2:Show()
				else
					self.gw_alchemy2:Hide()
				end
			end
			if self.gw_alchemy3 ~= nil then 
				if self.item.replica.gwen_equip:Getgw_Level() == 3 and self.item.replica.gwen_equip:Getgw_alchemy() ~= 0 then
					self.gw_alchemy3:Show()
				else
					self.gw_alchemy3:Hide()
				end
			end
			if self.gw_alchemy4 ~= nil then 
				if self.item.replica.gwen_equip:Getgw_Level() == 4 and self.item.replica.gwen_equip:Getgw_alchemy() ~= 0 then
					self.gw_alchemy4:Show()
				else
					self.gw_alchemy4:Hide()
				end
			end
		end

		if self.item.replica.gwen_refactor then
			if self.gw_refactor3 ~= nil then
				if self.item.replica.gwen_refactor:Getgw_Permanent() == 1
				and self.item:HasTag("hide_percentage")
				then
					self.gw_refactor3:Show()
				else
					self.gw_refactor3:Hide()
				end
			end
		end

		----去耐久文字
		if self.item.replica.gwen_refactor
		and self.item:HasTag("hide_percentage")
		and self.percent ~= nil then
            self.percent:Hide()
        end
		
		----去新鲜度背景
		if self.item.replica.gwen_refactor
		and not self.item:HasTag("show_spoilage")
		and self.item:HasTag("hide_percentage")
		and self.spoilage ~= nil and self.bg ~= nil
		then
			self.bg:Hide()
            self.spoilage:Hide()
        end
	end

	self:gw_UiRefresh()
	self.inst:ListenForEvent("gw_UiRefresh",function()
		self:gw_UiRefresh()
	end, ThePlayer)
end)

AddClientModRPCHandler("LegionMsg", "gw_UiRefresh", function(inst) ----客户端触发
	if ThePlayer ~= nil and ThePlayer:IsValid() then
		ThePlayer:DoTaskInTime(.3, function()
			ThePlayer:PushEvent("gw_UiRefresh")
		end)
	end
end)

AddPrefabPostInit("gwen_jiandao", function(inst)
	local OldGetDisplayName = inst.GetDisplayName
	inst.GetDisplayName = function(self, ...)
		local str = ""
		if inst.replica.gwen_equip then
			if inst.replica.gwen_equip:Getgw_refactor() ~= 0 then
				if inst.replica.gwen_equip:Getgw_Level() == 1 then
					str = str.."-白银级"
				elseif inst.replica.gwen_equip:Getgw_Level() == 2 then
					str = str.."-黄金级"
				elseif inst.replica.gwen_equip:Getgw_Level() == 3 then
					str = str.."-棱彩级"
				end
			end
			if inst.replica.gwen_equip:Getgw_alchemy() ~= 0 then
				if inst.replica.gwen_equip:Getgw_Level() == 1 then
					str = str.."-废品炼金"
				elseif inst.replica.gwen_equip:Getgw_Level() == 2 then
					str = str.."-失调炼金"
				elseif inst.replica.gwen_equip:Getgw_Level() == 3 then
					str = str.."-优质炼金"
				elseif inst.replica.gwen_equip:Getgw_Level() == 4 then
					str = str.."-完美炼金"
				end
			end
		end
		return OldGetDisplayName(self, ...)..str
	end
end)
