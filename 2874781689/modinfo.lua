--Mod Bio Will add langue support later
MODBIO_MEDIEVIL_REANIMATED_ENG = "Sir Daniel Wigginbottom Fortesque IV (1254 – 1286), was a knight of Gallowmere whos life was cut short in the Battle of Gallowmere against the evil sorcerer Zarok, where he was killed by the first volley of arrows.\nA hundred years later, Sir Dan was mistakenly resurrected by Zarok's magic. Dan used this opportunity to live up to his legend and defeated the sorcerer once and for all.\nBy 1886, Dan's skeletal remains were moved into the British Museum in London, where he was once again resurrected, this time by the ruthless Lord Palethorn. After Palethorn's defeat, Sir Dan and his newfound love chose to travel back in time using Kift's time machine, but they were tragically separated.\nDan was returned to his own lifetime to help preserve the flow of history. Swapping bodies with his still living self in order to boost the morale of Gallowmere's army and to die as he once had, thus condemning himself to an eternity of reliving his undead adventures.\n*This is a tale in the wilderness lands of Don't Starve Together!*"

-----------------------------------------------------------------
name = "Medievil Reanimated"
description = MODBIO_MEDIEVIL_REANIMATED_ENG

author = "Jade Knightblazer"
version = "3.0.5"
forumthread = ""
icon_atlas = "modicon.xml"
icon = "modicon.tex"

--Don't Starve

--Don't Starve Together
api_version = 10
dont_starve_compatible = false
reign_of_giants_compatible = false
dst_compatible = true
all_clients_require_mod = true
clients_only_mod = false
server_filter_tags = {"Sir Daniel Fortesque", "Medievil"}

local keys = {
    "None",
    "A","B","C","D","E","F","G","H","I","J","K","L","M","N","O","P","Q","R","S","T","U","V","W","X","Y","Z",
    "LSHIFT","LALT","LCTRL","TAB","BACKSPACE","PERIOD","SLASH","TILDE",
}

configuration_options = {
	{
		name = "sdf_fates_arrow",
		label = "Fate's Arrow Mode",
		hover = "For only true Heroes of Gallowmere!",
		options = {
			{description="Enable",data=true},
			{description="Disable",data=false},
		},
		default = false,
	},
	{
		name = "sdf_dans_arm_keybind",
		label = "Dan's Arm Keybind",
		hover = "Toggle Dan's Arm.",
		options = {
			--fill later
		},
		default = "R",
	},
	{
		name = "sdf_action_input_style",
		label = "Action Input Style",
		hover = "Daring Dash and Shield Guard Input Interaction",
		options = {
			{description="Dynamic Style",data=true},
			{description="Toggle Style",data=false},
		},
		default = true,
	},
	{
		name = "sdf_daring_dash_keybind",
		label = "Daring Dash Keybind",
		hover = "Perfrom the Daring Dash.",
		options = {
			--fill later
		},
		default = "LSHIFT",
	},
	{
		name = "sdf_time_rune_hall_of_heroes_revive_cooldown",
		label= "Time Rune Ring",
		hover = "Revival Cooldown",
		options = {
			{description = "6 Days", data = 6},
			{description = "12 Days", data = 12},
			{description = "24 Days", data = 24},
        	},
		default = 12
	},
	{
		name = "sdf_book_of_gallowmere_hud_resolution",
		label= "Book of Gallowmere HUD Resolution",
		hover = "HUD Resolution Setting",
		options = {
			{description = "720 X 360", data = 0},
			{description = "760 X 380", data = 1},
			{description = "850 X 425", data = 2},
        	},
		default = 1
	},
	{
		name= "sdf_jack_of_the_green_4th_riddle_rarity",
		label= "Jack of the Green Riddle Rarity",
		hover = "Rarity of The Reward of Jack of the Green's 4th Riddle Solved.",
		options= {
			{description="Rare",data=true},
			{description="Common",data=false},
        	},
		default=true
	},
	{
		name= "sdf_lifebottle_boss_drops",
		label= "Life Bottle Acquiring",
		hover = "Bosses drop a Life Bottle upon defeat.",
		options= {
			{description="Enable",data=true},
			{description="Disable",data=false},
        	},
		default=false
	},
	{
		name = "sdf_healthfountain_percent",
		label= "Fountain of Rejuvenation",
		hover = "Spawning rate",
		options = {
			{description = "Trickling", data = 0.9},
			{description = "Weeping", data = 0.86},
			{description = "Flowing", data = 0.82},
			{description = "Teeming", data = 0.78},
			{description = "Spouting", data = 0.74},
			{description = "Gushing", data = 0.70},
        	},
		default = 0.86
	},
	{
		name = "sdf_chest_wooden_percent",
		label= "Wooden Chest",
		hover = "Spawning rate",
		options = {
			{description = "Very Rare", data = 0.995},
			{description = "Rare", data = 0.985},
			{description = "Uncommon", data = 0.975},
        	},
		default = 0.985
	},
	{
		name = "sdf_chest_skull_percent",
		label= "Skull Chest",
		hover = "Spawning rate",
		options = {
			{description = "Very Rare", data = 0.995},
			{description = "Rare", data = 0.985},
			{description = "Uncommon", data = 0.975},
        	},
		default = 0.985
	},
	{
		name = "sdf_gallowmere_knight_weapon",
		label = "Knights of Gallowmere Weaponry",
		hover = "Offensive Damage Dealing",
		options = {
			{description="Small Sword",data="sdf_small_sword"},
			{description="Broad Sword",data="sdf_broad_sword"},
		},
		default = "sdf_small_sword",
	},
	{
		name = "sdf_gallowmere_knight_shield",
		label = "Knights of Gallowmere Bulwark",
		hover = "Defensive Protection",
		options = {
			{description="Copper Shield",data="sdf_copper_shield"},
			{description="Silver Shield",data="sdf_silver_shield"},
		},
		default = "sdf_silver_shield",
	},
}

local function filltable(tbl)
    for i=1, #keys do
	tbl[i] = {description = keys[i], data = keys[i]}
    end
end
filltable(configuration_options[2].options) --Keybind
filltable(configuration_options[4].options) --Keybind