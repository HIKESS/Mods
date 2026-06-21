name = "Netra Benyalohet"
version = "0.0.6.6"
description = "Version: "..version.." Not allow to Edit or Reupload".."\n"
.."\n*****Recommand to play with default setting*****\n Hunger:150 Health:75 Sanity:200"
author = "#ffffff"
forumthread = ""

api_version = 10
priority = -1

dst_compatible = true

dont_starve_compatible = false
reign_of_giants_compatible = false
shipwrecked_compatible = false

all_clients_require_mod = true 

icon_atlas = "modicon.xml"
icon = "modicon.tex"

server_filter_tags = {
"character",
}

mod_dependencies = {
    --{ workshop = "workshop-2812783478",},  --[API] Modded Skins  
}

local KeyOptions = {	 
			{description="TAB", data = 9},
            {description="KP_PERIOD", data = 266},
            {description="KP_DIVIDE", data = 267},
            {description="KP_MULTIPLY", data = 268},
            {description="KP_MINUS", data = 269},
            {description="KP_PLUS", data = 270},
            {description="KP_ENTER", data = 271},
            {description="KP_EQUALS", data = 272},
            {description="MINUS", data = 45},
            {description="EQUALS", data = 61},
            {description="SPACE", data = 32},
            {description="ENTER", data = 13},
            {description="ESCAPE", data = 27},
            {description="HOME", data = 278},
            {description="INSERT", data = 277},
            {description="DELETE", data = 127},
            {description="END", data   = 279},
            {description="PAUSE", data = 19},
            {description="PRINT", data = 316},
            {description="CAPSLOCK", data = 301},
            {description="SCROLLOCK", data = 302},
            {description="RSHIFT", data = 303}, -- use SHIFT instead
            {description="LSHIFT", data = 304}, -- use SHIFT instead
            {description="RCTRL", data = 305}, -- use CTRL instead
            {description="LCTRL", data = 306}, -- use CTRL instead
            {description="RALT", data = 307}, -- use ALT instead
            {description="LALT", data = 308}, -- use ALT instead
            {description="ALT", data = 400},
            {description="CTRL", data = 401},
            {description="SHIFT", data = 402},
            {description="BACKSPACE", data = 8},
            {description="PERIOD", data = 46},
            {description="SLASH", data = 47},
            {description="LEFTBRACKET", data     = 91},
            {description="BACKSLASH", data     = 92},
            {description="RIGHTBRACKET", data = 93},
            {description="TILDE", data = 96},
            {description="A", data = 97},
            {description="B", data = 98},
            {description="C", data = 99},
            {description="D", data = 100},
            {description="E", data = 101},
            {description="F", data = 102},
            {description="G", data = 103},
            {description="H", data = 104},
            {description="I", data = 105},
            {description="J", data = 106},
            {description="K", data = 107},
            {description="L", data = 108},
            {description="M", data = 109},
            {description="N", data = 110},
            {description="O", data = 111},
            {description="P", data = 112},
            {description="Q", data = 113},
            {description="R", data = 114},
            {description="S", data = 115},
            {description="T", data = 116},
            {description="U", data = 117},
            {description="V", data = 118},
            {description="W", data = 119},
            {description="X", data = 120},
            {description="Y", data = 121},
            {description="Z", data = 122},
            {description="F1", data = 282},
            {description="F2", data = 283},
            {description="F3", data = 284},
            {description="F4", data = 285},
            {description="F5", data = 286},
            {description="F6", data = 287},
            {description="F7", data = 288},
            {description="F8", data = 289},
            {description="F9", data = 290},
            {description="F10", data = 291},
            {description="F11", data = 292},
            {description="F12", data = 293},
 
            {description="UP", data = 273},
            {description="DOWN", data = 274},
            {description="RIGHT", data = 275},
            {description="LEFT", data = 276},
            {description="PAGEUP", data = 280},
            {description="PAGEDOWN", data = 281},
 
            {description="0", data = 48},
            {description="1", data = 49},
            {description="2", data = 50},
            {description="3", data = 51},
            {description="4", data = 52},
            {description="5", data = 53},
            {description="6", data = 54},
            {description="7", data = 55},
            {description="8", data = 56},
            {description="9", data = 57},
}

local StatOptions = {
			{description="75", data = 75},
            {description="100", data = 100},
            {description="120", data = 120},
            {description="125", data = 125},
            {description="150", data = 150},
            {description="175", data = 175},
            {description="200", data = 200},
            {description="225", data = 225},
            {description="250", data = 250},
            {description="275", data = 275},
            {description="300", data = 300},
}

local checkOptions = {
			{description="Off", data = false},
			{description="On", data = true},
}

local function Header(title)
	return { name = "", label = title, hover = "", options = { {description = "", data = false}, }, default = false, }
end

local function Space()
	return { name = "", label = "", hover = "", options = { {description = "", data = false}, }, default = false, }
end


configuration_options = {

		Header("Character Level"),
	{
        name = "mevileyesstartlevel",
        label = "Start Level",
        hover = "",
        options =
        {
			{description="default(1)", data = false},
			{description="2", data = 2},
			{description="3", data = 3},
            {description="4", data = 4},
            {description="5", data = 5},
            {description="6", data = 6},
            {description="7", data = 7},
            {description="8", data = 8},
            {description="9", data = 9},
            {description="10", data = 10},
        },
        default = false,
    },
		Header("Character stat"),
	{
        name = "mevileyeshunger",
        label = "Set Hunger 󰀎",
        hover = "",
        options = StatOptions,
        default = 150,
    },
	{
        name = "mevileyeshealth",
        label = "Set Health 󰀍",
        hover = "",
        options = StatOptions,
        default = 75,
    },
	{
        name = "mevileyessanity",
        label = "Set Sanity 󰀓",
        hover = "",
        options = StatOptions,
        default = 200,
    },
	
-----------------------------------------------------------------------------
		Space(),
	{
        name = "mevileyes_item",
        label = "Item",
        hover = "Netra's item craft recipes",
        options = checkOptions,
        default = true,
    },
	{
        name = "mevileyes_kenjutsu",
        label = "Kenjutsu",
        hover = "Netra's Sword Skill",
        options = checkOptions,
        
        default = true,
    },
	{
        name = "mevileyes_skilltree",
        label = "Skilltree",
        hover = "Netra's Skilltree",
		options = checkOptions,
        
        default = true,
    },
	{
        name = "mevileyeswarly",
        label = "Warly Item",
        hover = "",
        options = checkOptions,
        
        default = true,
    },	
		Space(),
	{
        name = "mevileyesminioncolor",
        label = "Cute Minions Worker",
        hover = "Shadow minion more look like Netra",
        options = checkOptions,
        
        default = true,
    },
	{
        name = "mevileyesminioncolor2",
        label = "Cute Minions Figther",
        hover = "Shadow minion more look like Netra",
        options = checkOptions,
        
        default = true,
    },
	{
        name = "mevileyes_minionwp",
        label = "Minions Weapon",
        hover = "Shadow minion random use netra's weapon",
        options = checkOptions,
        
        default = true,
    },
	
		Space(),
		Header("Custom Weapon Damage"),
	{
        name = "mevileyeskatanadmg",
        label = "Set Katana Damage",
        hover = "",
        options =
        {
			{description="42", data = 42},
			{description="45", data = 45},
			{description="50", data = 50},
			{description="default(55)", data = 55},
			{description="60", data = 60},
			{description="68", data = 68},
			{description="75", data = 75},
            {description="82", data = 82},
            {description="90", data = 90},
            {description="100", data = 100},            
            {description="120", data = 120},
            {description="150", data = 150},
            {description="200", data = 200},
            {description="300", data = 300},
            {description="500", data = 500},
            {description="1000", data = 1000},       
        },
        default = 55,
    },
	{
        name = "mevileyesstartitem",
        label = "Start with Myoho muramasa",
        hover = "",
        options = checkOptions,
        
        default = false,
    },
	
-----------------------------------------------------------------------------

		Space(),
		Header("Skill Keys "),
	{
        name = "mevilwave",
        label = "Evil wave",
        hover = "",
        options = KeyOptions,
        default = 114,
    },
	{
        name = "mevilwarp",
        label = "Evil warp",
        hover = "",
        options = KeyOptions,
        default = 116,
    },
	{
        name = "mkeyskill1",
        label = "Skill1:Button",
        hover = "Skill1",
        options = KeyOptions,
		default = 120,
    },
	{
        name = "mkeyskill2",
        label = "Skill2:Button",
        hover = "Skill2",
        options = KeyOptions,
		default = 99,
    },	
	
	{
        name = "mkeyskill3",
        label = "Skill3:Button",
        hover = "Skill3",
       options = KeyOptions,
	   default = 118,
    },		
	{
        name = "mkeyquicksheath",
        label = "Quick Sheath Katana",
        hover = "Quick Sheath Katana",
        options = KeyOptions,
		default = 122,
    },
}