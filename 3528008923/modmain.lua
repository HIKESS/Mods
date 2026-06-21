-- Import the engine.
modimport("engine.lua")

-- Imports to keep the keyhandler from working while typing in chat.
Load "chatinputscreen"
Load "consolescreen"
Load "textedit"

PrefabFiles = {

"mevileyes",
"mevileyes_none",
"myoho",
"mevileyes_fx",
"mkogarasu",
"mevileyesfruit",
"black_electric_charged_fx",
"yukishigure",
"mevileyes_inner_armor",
"mevileyes_inner_head",
"mevileyes_helmet",
"nagarehime",
"mhamayumi",
"mbow_arrow",
"mbokken",
"netrajournal",
"m_katana",

}

Assets = {
    Asset( "IMAGE", "images/saveslot_portraits/mevileyes.tex" ),
    Asset( "ATLAS", "images/saveslot_portraits/mevileyes.xml" ),

    Asset( "IMAGE", "images/selectscreen_portraits/mevileyes.tex" ),
    Asset( "ATLAS", "images/selectscreen_portraits/mevileyes.xml" ),
	
    Asset( "IMAGE", "images/selectscreen_portraits/mevileyes_silho.tex" ),
    Asset( "ATLAS", "images/selectscreen_portraits/mevileyes_silho.xml" ),
	
	Asset( "IMAGE", "images/map_icons/mevileyes.tex" ),
	Asset( "ATLAS", "images/map_icons/mevileyes.xml" ),
	
	Asset( "IMAGE", "images/avatars/avatar_mevileyes.tex" ),
    Asset( "ATLAS", "images/avatars/avatar_mevileyes.xml" ),
	
	Asset( "IMAGE", "images/avatars/avatar_ghost_mevileyes.tex" ),
    Asset( "ATLAS", "images/avatars/avatar_ghost_mevileyes.xml" ),
	
	Asset( "IMAGE", "images/avatars/self_inspect_mevileyes.tex" ),
    Asset( "ATLAS", "images/avatars/self_inspect_mevileyes.xml" ),
	
	Asset( "IMAGE", "images/names_mevileyes.tex" ),
    Asset( "ATLAS", "images/names_mevileyes.xml" ),
	
	Asset( "IMAGE", "images/names_gold_mevileyes.tex" ),
    Asset( "ATLAS", "images/names_gold_mevileyes.xml" ),
	
----------------------------------------------------------------skin
		
    Asset( "IMAGE", "bigportraits/mevileyes.tex" ), --default
    Asset( "ATLAS", "bigportraits/mevileyes.xml" ), --default
	
    Asset( "IMAGE", "bigportraits/mevileyes_none.tex" ),
    Asset( "ATLAS", "bigportraits/mevileyes_none.xml" ),

	Asset( "IMAGE", "bigportraits/mevileyes_miko.tex" ),
    Asset( "ATLAS", "bigportraits/mevileyes_miko.xml" ),
	
	Asset( "IMAGE", "bigportraits/mevileyes_maid.tex" ),
    Asset( "ATLAS", "bigportraits/mevileyes_maid.xml" ),
	
	Asset( "IMAGE", "bigportraits/mevileyes_wafuku.tex" ),
    Asset( "ATLAS", "bigportraits/mevileyes_wafuku.xml" ),
	
	Asset( "IMAGE", "bigportraits/mevileyes_black.tex" ),
    Asset( "ATLAS", "bigportraits/mevileyes_black.xml" ),
	
	Asset( "IMAGE", "bigportraits/mevileyes_thai.tex" ),
	Asset( "ATLAS", "bigportraits/mevileyes_thai.xml" ),
	
    Asset( "IMAGE", "bigportraits/mevileyes_miburo.tex" ),
    Asset( "ATLAS", "bigportraits/mevileyes_miburo.xml" ),
	
	-----------------------------------------------------------skilltree
			
	Asset( "IMAGE", "images/mevileyes_skilltree.tex" ),
    Asset( "ATLAS", "images/mevileyes_skilltree.xml" ),
	
	-----------------------------------------------------------UI
	Asset( "IMAGE", "images/skill/evilwarp.tex" ),
    Asset( "ATLAS", "images/skill/evilwarp.xml" ),
	
	Asset( "IMAGE", "images/skill/evilwave.tex" ),
	Asset( "ATLAS", "images/skill/evilwave.xml" ),
	
    Asset( "IMAGE", "images/skill/evilcurse.tex" ),
    Asset( "ATLAS", "images/skill/evilcurse.xml" ),
	
	Asset( "IMAGE", "images/skill/evilskill1.tex" ),
    Asset( "ATLAS", "images/skill/evilskill1.xml" ),
	Asset( "IMAGE", "images/skill/evilskill2.tex" ),
    Asset( "ATLAS", "images/skill/evilskill2.xml" ),
	Asset( "IMAGE", "images/skill/evilskill3.tex" ),
    Asset( "ATLAS", "images/skill/evilskill3.xml" ),
	Asset( "IMAGE", "images/skill/evilskill4.tex" ),
    Asset( "ATLAS", "images/skill/evilskill4.xml" ),
	Asset( "IMAGE", "images/skill/evilskill5.tex" ),
    Asset( "ATLAS", "images/skill/evilskill5.xml" ),
	Asset( "IMAGE", "images/skill/evilskill6.tex" ),
    Asset( "ATLAS", "images/skill/evilskill6.xml" ),
	Asset( "IMAGE", "images/skill/evilskill7.tex" ),
    Asset( "ATLAS", "images/skill/evilskill7.xml" ),
	
    Asset( "IMAGE", "images/skill/evilskillsp.tex" ),
    Asset( "ATLAS", "images/skill/evilskillsp.xml" ),
	
	Asset("ANIM", "anim/player_lunge_basic.zip"), 
	Asset("ANIM", "anim/player_lunge_black.zip"), 
	Asset("ANIM", "anim/player_lunge_blue.zip"), 

}
AddMinimapAtlas("images/map_icons/mevileyes.xml")
AddMinimapAtlas("images/map_icons/myoho.xml")

AddMinimapAtlas("images/inventoryimages/mevileyesfruit.xml")
AddMinimapAtlas("images/inventoryimages/mevileyes_helmet.xml")
AddMinimapAtlas("images/inventoryimages/mkogarasu.xml")
AddMinimapAtlas("images/inventoryimages/mhamayumi.xml")
AddMinimapAtlas("images/inventoryimages/nagarehime.xml")
AddMinimapAtlas("images/inventoryimages/yukishigure.xml")
AddMinimapAtlas("images/inventoryimages/netrajournal.xml")

GLOBAL.TUNING.MEVILEYES = { --B
	STARTLEVEL = GetModConfigData("mevileyesstartlevel"),
	
	MINIONCOLOR = GetModConfigData("mevileyesminioncolor"),
	MINIONCOLOR2 = GetModConfigData("mevileyesminioncolor2"),
	
	MINIONWEAPON = GetModConfigData("mevileyes_minionwp"),
	
	KENJUTSU = GetModConfigData("mevileyes_kenjutsu"),
	SKILLTREE = GetModConfigData("mevileyes_skilltree"),
	ITEM = GetModConfigData("mevileyes_item"),	
	WARLY = GetModConfigData("mevileyeswarly"),
		
	KEYSKILL1 = GetModConfigData("mkeyskill1"),
	KEYSKILL2 = GetModConfigData("mkeyskill2"),
	KEYSKILL3 = GetModConfigData("mkeyskill3"),	
	KEYSQUICKSHEATH = GetModConfigData("mkeyquicksheath"),
	EVILWAVE = GetModConfigData("mevilwave"),
	EVILWARP = GetModConfigData("mevilwarp"),
		
	HUNGER = GetModConfigData("mevileyeshunger"),
	HEALTH = GetModConfigData("mevileyeshealth"),
	SANITY = GetModConfigData("mevileyessanity"),
	
	--weapon damage
	KATANADMG = GetModConfigData("mevileyeskatanadmg"),
	KATANAUSE = 250,
	STARTITEM = GetModConfigData("mevileyesstartitem"),
			
	MINDREGENRATE = 120, --120
	MINDHITCOUNT = 10, --10
	MAXMIND = 5, --5
	MAXEXP = 300, --300
	
	SKILLCOST_1 = 3, --3
	SKILLCOST_2 = 3, --3
	SKILLCOST_3 = 4, --4
	SKILLCOST_SP = 2, --1 Z skill
	SKILLCOST_WP = 1, --1 teleport
	
	SKILLCURSE_TIME_T1 = 15, --15
	SKILLCURSE_TIME_T2 = 60, --60
	SKILLCURSE_TIME_T3 = 120, --120
	
	SKILLCURSE_T1 = -(GetModConfigData("mevileyeshealth") * 0.25),
	SKILLCURSE_T2 = -(GetModConfigData("mevileyeshealth") * 0.50),
	SKILLCURSE_T3 = -(GetModConfigData("mevileyeshealth") * 0.80),
	
	SKILLCD_1 = 45, --45
	SKILLCD_2 = 45, --45
	SKILLCD_3 = 60, --60
	SKILLCD_4 = 180, --180
	SKILLCD_5 = 90, --90
	SKILLCD_6 = 110, --110
	SKILLCD_7 = 240, --240
	SKILLCD_TP = 30, --30
	SKILLCD_WAVE = 240, --240	
	SKILLSPCD = 30, --30	
	
	FOOD_MULTIPLIERS = {1, 1, .9, .8},
	FOOD_TIMES = TUNING.TOTAL_DAY_TIME*1.5,
}

GLOBAL.FOODTYPE.EVILEYESMEMO = "EVILEYESMEMO"

local require = GLOBAL.require
local STRINGS = GLOBAL.STRINGS

if TUNING.MEVILEYES.KENJUTSU then
local mUi = GLOBAL.require("widgets/mevileyes_hud")
GLOBAL.setmetatable(env,{__index=function(t,k) return GLOBAL.rawget(GLOBAL,k) end}) --TheWorld

local function addMevileyeHudWidget(self)
        local hudscale = self:GetScale()
        local screenw_full, screenh_full = GLOBAL.unpack({GLOBAL.TheSim:GetScreenSize()})
        local screenw = screenw_full/hudscale.x
        local screenh = screenh_full/hudscale.y
        self.mevileyes_hud = self:AddChild(mUi())   
        self.mevileyes_hud:SetHAnchor(0)
        self.mevileyes_hud:SetVAnchor(1) 
        self.mevileyes_hud:SetPosition((screenw/2)-(screenw/8), (-screenh/2)-(screenh/3)
             , 0)
        --self.hi:Hide()
    --print(test)
end
AddClassPostConstruct("widgets/controls", addMevileyeHudWidget)
end

--
TUNING.STARTING_ITEM_IMAGE_OVERRIDE["myoho"] = {atlas = "images/inventoryimages/myoho.xml", image = "myoho.tex"}
TUNING.STARTING_ITEM_IMAGE_OVERRIDE["m_katana"] = {atlas = "images/inventoryimages/m_katana.xml", image = "m_katana.tex"}
TUNING.STARTING_ITEM_IMAGE_OVERRIDE["netrajournal"] = {atlas = "images/inventoryimages/netrajournal.xml", image = "netrajournal.tex"}
TUNING.STARTING_ITEM_IMAGE_OVERRIDE["mbokken"] = {atlas = "images/inventoryimages/mbokken.xml", image = "mbokken.tex"}
TUNING.STARTING_ITEM_IMAGE_OVERRIDE["yukishigure"] = {atlas = "images/inventoryimages/yukishigure.xml", image = "yukishigure.tex"}

local chartextken = ""
local chartextcook = ""
if TUNING.MEVILEYES.KENJUTSU then chartextken = "\n*Trains hard to become a master of the sword" end
if TUNING.MEVILEYES.WARLY then chartextcook = "\n*Can cook special dishes" end

-- The character select screen lines
STRINGS.CHARACTER_TITLES.mevileyes = "The Sinister Glare"
STRINGS.CHARACTER_NAMES.mevileyes = "Netra Benyalohet"
STRINGS.CHARACTER_DESCRIPTIONS.mevileyes = chartextken..chartextcook.."\n*Hates crowded places\n*Is not a skilled worker\n*A picky eater who never eats spoiled food\n*Has a fast metabolism and burns more calories"
STRINGS.CHARACTER_QUOTES.mevileyes = "Some truths are best proven in silence."
STRINGS.CHARACTER_SURVIVABILITY.mevileyes = "Grim"

-- Custom speech strings
STRINGS.CHARACTERS.MEVILEYES = require "speech_mevileyes" --B

-- The character's name as appears in-game 
STRINGS.NAMES.MEVILEYES = "Netra" --B
STRINGS.SKIN_NAMES.mevileyes_none = "Netra_Default"

local skin_modes = {
    { 
        type = "ghost_skin",
        anim_bank = "ghost",
        idle_anim = "idle", 
        scale = 0.75, 
        offset = { 0, -25 } 
    },
}

AddModCharacter("mevileyes", "FEMALE", skin_modes)

modimport("scripts/mevileyes_skin") --skin

modimport("scripts/mevileyes_itemrecipe") --recipe
modimport("scripts/mevileyes_texts") --text explain

if TUNING.MEVILEYES.KENJUTSU then
modimport("scripts/mevileyes_skill") --skill
modimport("scripts/mevileyes_skill_active")
modimport("scripts/mevileyes_skill_handle")

modimport("scripts/style/mevileyes_action_atk")
modimport("scripts/style/mevileyes_atk")
modimport("scripts/style/mevileyes_atk_c")
end
----------------------------------
if TUNING.MEVILEYES.SKILLTREE then
-- Skilltree
local SkillTreeDefs = require("prefabs/skilltree_defs")

local OldGetSkilltreeBG = GLOBAL.GetSkilltreeBG
function GLOBAL.GetSkilltreeBG(imagename, ...)
    if imagename == "mevileyes_background.tex" then
        return "images/mevileyes_skilltree.xml"
    else
        return OldGetSkilltreeBG(imagename, ...)
    end
end

local CreateSkillTree = function()
	print("Creating a skilltree for mevileyes")
	local BuildSkillsData = require("prefabs/skilltree_mevileyes") -- Load in the skilltree

    if BuildSkillsData then
        local data = BuildSkillsData(SkillTreeDefs.FN)

        if data then
            SkillTreeDefs.CreateSkillTreeFor("mevileyes", data.SKILLS)
            SkillTreeDefs.SKILLTREE_ORDERS["mevileyes"] = data.ORDERS
			print("Created mevileyes skilltree")
        end
    end
end
CreateSkillTree();
-- Skilltree end
end
---------------------------------------------------------------------

local Vector3 = GLOBAL.Vector3
local containers = require("containers")

containers.params.mhamayumi = containers.params.mhamayumi
containers.params.mhamayumi =
{
    widget =
    {
        slotpos =	{},
        slotbg =
        {
            { image = "houndstooth_ammo_slot.tex", atlas = "images/hud2.xml" },
        },
        animbank = "ui_cookpot_1x2",
        animbuild = "ui_cookpot_1x2",
        pos = Vector3(0, 15, 0),
    },
    usespecificslotsforitems = true,
    type = "hand_inv",
}

function containers.params.mhamayumi.itemtestfn(container, item, slot)
	return item:HasTag("hamayumi_arrow") --or item:HasTag("blowpipeammo")
end
table.insert(containers.params.mhamayumi.widget.slotpos, Vector3(0,   32 + 4,  0))

---------------------------------------------------------------------
local function EndSpeedMult(inst)
	inst._evilspeed_task = nil
	
	if inst._evilspeed_fx then inst._evilspeed_fx:KillFX() end
	inst._evilspeed_fx = nil
	
	if inst.components.locomotor ~= nil then
		inst.components.locomotor:RemoveExternalSpeedMultiplier(inst, "evilwarp_speedbuff")	
	end
end

local  function mevileyes_warp(inst ,x , y, z) --T
if inst:HasTag("playerghost") or (inst.components.rider:IsRiding() or inst.components.inventory:IsHeavyLifting()) then return end
if not inst.components.timer:TimerExists("mevileyes_evilwarp") then
		if inst.mindpower < TUNING.MEVILEYES.SKILLCOST_WP then 	inst.components.talker:Say("I need more focus.", 2, true) return end	
		if inst.mindpower then inst.mindpower = (inst.mindpower - TUNING.MEVILEYES.SKILLCOST_WP) end

		local px, py, pz = inst.Transform:GetWorldPosition()
		local dx = x - px
		local dz = z - pz
		local distance = math.sqrt(dx * dx + dz * dz)
	
		if distance > 12 then
			local scale = 12 / distance
			dx = dx * scale
			dz = dz * scale
			x = px + dx
			z = pz + dz			
		end
       if inst.components.playeractionpicker.map:IsPassableAtPoint(x, y, z) then
           
        inst.components.locomotor:Stop()
        inst.components.health:SetInvincible(true)
        local fx = SpawnPrefab("abigail_shadow_buff_fx")
        fx.Transform:SetPosition(inst.Transform:GetWorldPosition())
		   
		local airfx = SpawnPrefab("shadow_bishop_fx")
        airfx.Transform:SetPosition(inst.Transform:GetWorldPosition())
		   
		local floorfx = SpawnPrefab("shadow_teleport_in")			
		floorfx.Transform:SetPosition(inst.Transform:GetWorldPosition())
		--floorfx.Transform:SetScale(2, 2, 2)
		
		local groundfx = SpawnPrefab("wanda_attack_shadowweapon_old_fx")			
		groundfx.Transform:SetPosition(inst.Transform:GetWorldPosition())
				
		--if inst.components.playercontroller ~= nil then inst.components.playercontroller:Enable(false) end	
		inst:Hide()
		inst.SoundEmitter:PlaySound("dontstarve/characters/wortox/soul/hop_out")
		inst.Transform:SetPosition(x, y, z)
		
		inst.components.sanity:DoDelta(-10)
		
		--inst.AnimState:SetErosionParams(0, -0.125, -1.0)		--noise effect
		--inst.AnimState:SetErosionParams(0, 0, 0)				--disable noise
		if inst.components.locomotor ~= nil then
			if inst._evilspeed_task ~= nil then
				inst._evilspeed_task:Cancel()
			else
				inst._evilspeed_fx = SpawnPrefab("shadow_trap_debuff_fx")
				inst._evilspeed_fx.entity:SetParent(inst.entity)
				inst._evilspeed_fx:OnSetTarget(inst)						
				inst._evilspeed_fx.Transform:SetScale(1, .3, 1)
			end		
			inst._evilspeed_task = inst:DoTaskInTime(12, EndSpeedMult)
			inst.components.locomotor:SetExternalSpeedMultiplier(inst, "evilwarp_speedbuff", 1.1)		
		end
		
		inst:DoTaskInTime(0.2, function()          
			inst.SoundEmitter:PlaySound("dontstarve/movement/bodyfall_dirt")
			inst:Show()
			
			local fx2 = SpawnPrefab("abigail_shadow_buff_fx")
			fx2.Transform:SetPosition(inst.Transform:GetWorldPosition())
			local floorfx2 = SpawnPrefab("shadow_teleport_out")			
			floorfx2.Transform:SetPosition(inst.Transform:GetWorldPosition())			
			local groundfx2 = SpawnPrefab("wanda_attack_shadowweapon_normal_fx")			
			groundfx2.Transform:SetPosition(inst.Transform:GetWorldPosition())

			--if inst.components.playercontroller ~= nil then	inst.components.playercontroller:Enable(true) end		
			inst.components.health:SetInvincible(false)

			inst.components.timer:StartTimer("mevileyes_evilwarp", TUNING.MEVILEYES.SKILLCD_TP) --SKILL CD
			inst.components.timer:StartTimer("mevileyes_evildodge", 2)
		end)                    
       end
end
end
AddModRPCHandler("evileyes", "mevileyes_warp", mevileyes_warp)

local function IsScreenClear(inst)
    return inst ~= nil and inst.HUD ~= nil
        and not inst.HUD:IsChatInputScreenOpen()
        and not inst.HUD:IsConsoleScreenOpen()
        and not inst.HUD:IsMapScreenOpen()        
        and not inst.HUD:IsPauseScreenOpen()    
        and not inst.HUD:HasInputFocus()    
end

if TUNING.MEVILEYES.KENJUTSU then
TheInput:AddKeyDownHandler(TUNING.MEVILEYES.EVILWARP, function()
    local inst = ThePlayer
    if inst and inst.prefab == "mevileyes" and IsScreenClear(inst) then
        local x, y, z = TheInput:GetWorldPosition():Get()
        SendModRPCToServer(MOD_RPC["evileyes"]["mevileyes_warp"], x, y, z)
    end
end)
end
