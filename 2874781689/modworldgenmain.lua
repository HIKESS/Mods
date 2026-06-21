--local require = GLOBAL.require
local SDF_HEALTHFOUNTAIN_PERCENT = GetModConfigData("sdf_healthfountain_percent")
local SDF_CHEST_WOODEN_PERCENT = GetModConfigData("sdf_chest_wooden_percent")
local SDF_CHEST_SKULL_PERCENT = GetModConfigData("sdf_chest_skull_percent")

local Layouts = GLOBAL.require("map/layouts").Layouts --this is where we add the setpiece
local StaticLayout = GLOBAL.require("map/static_layout") --this helps us load the setpiece

Layouts["Hall of Heroes Setpiece"] = StaticLayout.Get("map/static_layouts/sdf_hall_of_heroes_setpiece") --index your setpiece
Layouts["Chalice Altar 1"] = StaticLayout.Get("map/static_layouts/sdf_chalice_altar_1_setpiece")
Layouts["Chalice Altar 2"] = StaticLayout.Get("map/static_layouts/sdf_chalice_altar_2_setpiece")
Layouts["Chalice Altar 3"] = StaticLayout.Get("map/static_layouts/sdf_chalice_altar_3_setpiece")
Layouts["Chalice Altar 4"] = StaticLayout.Get("map/static_layouts/sdf_chalice_altar_4_setpiece")
Layouts["Chalice Altar 5"] = StaticLayout.Get("map/static_layouts/sdf_chalice_altar_5_setpiece")
Layouts["Chalice Altar 6"] = StaticLayout.Get("map/static_layouts/sdf_chalice_altar_6_setpiece")
Layouts["Chalice Altar 7"] = StaticLayout.Get("map/static_layouts/sdf_chalice_altar_7_setpiece")
Layouts["Chalice Altar 8"] = StaticLayout.Get("map/static_layouts/sdf_chalice_altar_8_setpiece")
Layouts["Chalice Altar 9"] = StaticLayout.Get("map/static_layouts/sdf_chalice_altar_9_setpiece")
Layouts["Chalice Altar 10"] = StaticLayout.Get("map/static_layouts/sdf_chalice_altar_10_setpiece")
Layouts["Chalice Altar 11"] = StaticLayout.Get("map/static_layouts/sdf_chalice_altar_11_setpiece")
Layouts["Chalice Altar 12"] = StaticLayout.Get("map/static_layouts/sdf_chalice_altar_12_setpiece")
Layouts["Chalice Altar 13"] = StaticLayout.Get("map/static_layouts/sdf_chalice_altar_13_setpiece")
Layouts["Chalice Altar 14"] = StaticLayout.Get("map/static_layouts/sdf_chalice_altar_14_setpiece")
Layouts["Chalice Altar 15"] = StaticLayout.Get("map/static_layouts/sdf_chalice_altar_15_setpiece")
Layouts["Chalice Altar 16"] = StaticLayout.Get("map/static_layouts/sdf_chalice_altar_16_setpiece")
Layouts["Chalice Altar 17"] = StaticLayout.Get("map/static_layouts/sdf_chalice_altar_17_setpiece")
Layouts["Chalice Altar 18"] = StaticLayout.Get("map/static_layouts/sdf_chalice_altar_18_setpiece")
Layouts["Chalice Altar 19"] = StaticLayout.Get("map/static_layouts/sdf_chalice_altar_19_setpiece")
Layouts["Chalice Altar 20"] = StaticLayout.Get("map/static_layouts/sdf_chalice_altar_20_setpiece")
Layouts["Jack of The Green Setpiece"] = StaticLayout.Get("map/static_layouts/sdf_jack_of_the_green_asylum_grounds_setpiece")
Layouts["Mullock Chief Memorial Setpiece"] = StaticLayout.Get("map/static_layouts/sdf_mullock_chief_memorial_setpiece")
Layouts["Haunted Ruins Setpiece"] = StaticLayout.Get("map/static_layouts/sdf_haunted_ruins_setpiece")
Layouts["Pumpkin Gorge Setpiece"] = StaticLayout.Get("map/static_layouts/sdf_pumpkin_gorge_setpiece")

local function healthFountain_Chest_Spawns(num)
	--Health Fountain and Chest Worldgen
	--Forest
	--Always Spawn Locations
	local function GraveyardPreInit(room)
		if not room.contents.countprefabs then
			room.contents.countprefabs = {}
		end
		room.contents.countprefabs.sdf_healthfountain = 1
		room.contents.countprefabs.sdf_chest_wooden = 1
	end
	AddRoomPreInit("Graveyard", GraveyardPreInit)


	local function MoonIsland_BathsPreInit(room)
		if not room.contents.countprefabs then
			room.contents.countprefabs = {}
		end
		room.contents.countprefabs.sdf_healthfountain = 1
		room.contents.countprefabs.sdf_chest_wooden = function() return (math.random() > SDF_CHEST_WOODEN_PERCENT and 1) or 0 end
		room.contents.countprefabs.sdf_chest_skull = function() return (math.random() > SDF_CHEST_SKULL_PERCENT and 1) or 0 end
	end
	AddRoomPreInit("MoonIsland_Baths", MoonIsland_BathsPreInit)



	--Boss Spawn Locations
	local function LightningBluffAntlionPreInit(room)
		if not room.contents.countprefabs then
			room.contents.countprefabs = {}
		end
		room.contents.countprefabs.sdf_healthfountain = 1
		room.contents.countprefabs.sdf_chest_wooden = function() return (math.random() > SDF_CHEST_WOODEN_PERCENT and 1) or 0 end
		room.contents.countprefabs.sdf_chest_skull = function() return (math.random() > SDF_CHEST_SKULL_PERCENT and 1) or 0 end
	end
	AddRoomPreInit("LightningBluffAntlion", LightningBluffAntlionPreInit)


	local function DragonflyArenaPreInit(room)
		if not room.contents.countprefabs then
			room.contents.countprefabs = {}
		end
		room.contents.countprefabs.sdf_healthfountain = 1
		room.contents.countprefabs.sdf_chest_wooden = function() return (math.random() > SDF_CHEST_WOODEN_PERCENT and 1) or 0 end
		room.contents.countprefabs.sdf_chest_skull = function() return (math.random() > SDF_CHEST_SKULL_PERCENT and 1) or 0 end
	end
	AddRoomPreInit("DragonflyArena", DragonflyArenaPreInit)


	local function BeeQueenBeePreInit(room)
		if not room.contents.countprefabs then
			room.contents.countprefabs = {}
		end
		room.contents.countprefabs.sdf_healthfountain = 1
		room.contents.countprefabs.sdf_chest_wooden = function() return (math.random() > SDF_CHEST_WOODEN_PERCENT and 1) or 0 end
		room.contents.countprefabs.sdf_chest_skull = function() return (math.random() > SDF_CHEST_SKULL_PERCENT and 1) or 0 end
	end
	AddRoomPreInit("BeeQueenBee", BeeQueenBeePreInit)


	local function MooseGooseBreedingGroundsPreInit(room)
		if not room.contents.countprefabs then
			room.contents.countprefabs = {}
		end
		room.contents.countprefabs.sdf_healthfountain = 1
		room.contents.countprefabs.sdf_chest_wooden = function() return (math.random() > SDF_CHEST_WOODEN_PERCENT and 1) or 0 end
		room.contents.countprefabs.sdf_chest_skull = 1
	end
	AddRoomPreInit("MooseGooseBreedingGrounds", MooseGooseBreedingGroundsPreInit)



	--Small Chance Spawn Locations
	local function BGForestPreInit(room)
		if not room.contents.countprefabs then
			room.contents.countprefabs = {}
		end
		room.contents.countprefabs.sdf_healthfountain = function() return (math.random() > SDF_HEALTHFOUNTAIN_PERCENT and 1) or 0 end
		room.contents.countprefabs.sdf_chest_wooden = function() return (math.random() > SDF_CHEST_WOODEN_PERCENT and 1) or 0 end
		room.contents.countprefabs.sdf_chest_skull = function() return (math.random() > SDF_CHEST_SKULL_PERCENT and 1) or 0 end
	end
	AddRoomPreInit("BGForest", BGForestPreInit)


	local function BGDeciduousPreInit(room)
		if not room.contents.countprefabs then
			room.contents.countprefabs = {}
		end
		room.contents.countprefabs.sdf_healthfountain = function() return (math.random() > SDF_HEALTHFOUNTAIN_PERCENT and 1) or 0 end
		room.contents.countprefabs.sdf_chest_wooden = function() return (math.random() > SDF_CHEST_WOODEN_PERCENT and 1) or 0 end
		room.contents.countprefabs.sdf_chest_skull = function() return (math.random() > SDF_CHEST_SKULL_PERCENT and 1) or 0 end
	end
	AddRoomPreInit("BGDeciduous", BGDeciduousPreInit)


	local function BGGrassPreInit(room)
		if not room.contents.countprefabs then
			room.contents.countprefabs = {}
		end
		room.contents.countprefabs.sdf_healthfountain = function() return (math.random() > SDF_HEALTHFOUNTAIN_PERCENT and 1) or 0 end
		room.contents.countprefabs.sdf_chest_wooden = function() return (math.random() > SDF_CHEST_WOODEN_PERCENT and 1) or 0 end
		room.contents.countprefabs.sdf_chest_skull = function() return (math.random() > SDF_CHEST_SKULL_PERCENT and 1) or 0 end
	end
	AddRoomPreInit("BGGrass", BGGrassPreInit)


	local function BGMarshPreInit(room)
		if not room.contents.countprefabs then
			room.contents.countprefabs = {}
		end
		room.contents.countprefabs.sdf_healthfountain = function() return (math.random() > SDF_HEALTHFOUNTAIN_PERCENT and 1) or 0 end
		room.contents.countprefabs.sdf_chest_wooden = function() return (math.random() > SDF_CHEST_WOODEN_PERCENT and 1) or 0 end
		room.contents.countprefabs.sdf_chest_skull = function() return (math.random() > SDF_CHEST_SKULL_PERCENT and 1) or 0 end
	end
	AddRoomPreInit("BGMarsh", BGMarshPreInit)


	local function BGRockyPreInit(room)
		if not room.contents.countprefabs then
			room.contents.countprefabs = {}
		end
		room.contents.countprefabs.sdf_healthfountain = function() return (math.random() > SDF_HEALTHFOUNTAIN_PERCENT and 1) or 0 end
		room.contents.countprefabs.sdf_chest_wooden = function() return (math.random() > SDF_CHEST_WOODEN_PERCENT and 1) or 0 end
		room.contents.countprefabs.sdf_chest_skull = function() return (math.random() > SDF_CHEST_SKULL_PERCENT and 1) or 0 end
	end
	AddRoomPreInit("BGRocky", BGRockyPreInit)


	local function BGDirtPreInit(room)
		if not room.contents.countprefabs then
			room.contents.countprefabs = {}
		end
		room.contents.countprefabs.sdf_healthfountain = function() return (math.random() > SDF_HEALTHFOUNTAIN_PERCENT and 1) or 0 end
		room.contents.countprefabs.sdf_chest_wooden = function() return (math.random() > SDF_CHEST_WOODEN_PERCENT and 1) or 0 end
		room.contents.countprefabs.sdf_chest_skull = function() return (math.random() > SDF_CHEST_SKULL_PERCENT and 1) or 0 end
	end
	AddRoomPreInit("BGDirt", BGDirtPreInit)


	--Chests only
	local function PigKingdomPreInit(room)
		if not room.contents.countprefabs then
			room.contents.countprefabs = {}
		end
		room.contents.countprefabs.sdf_chest_wooden = 1
	end
	AddRoomPreInit("PigKingdom", PigKingdomPreInit)

	local function BGSavannaPreInit(room)
		if not room.contents.countprefabs then
			room.contents.countprefabs = {}
		end
		room.contents.countprefabs.sdf_chest_wooden = function() return (math.random() > SDF_CHEST_WOODEN_PERCENT and 1) or 0 end
		room.contents.countprefabs.sdf_chest_skull = function() return (math.random() > SDF_CHEST_SKULL_PERCENT and 1) or 0 end
	end
	AddRoomPreInit("BGSavanna", BGSavannaPreInit)

	local function BGBadlandsPreInit(room)
		if not room.contents.countprefabs then
			room.contents.countprefabs = {}
		end
		room.contents.countprefabs.sdf_chest_wooden = function() return (math.random() > SDF_CHEST_WOODEN_PERCENT and 1) or 0 end
		room.contents.countprefabs.sdf_chest_skull = function() return (math.random() > SDF_CHEST_SKULL_PERCENT and 1) or 0 end
	end
	AddRoomPreInit("BGBadlands", BGBadlandsPreInit)

	local function BGLightningBluffPreInit(room)
		if not room.contents.countprefabs then
			room.contents.countprefabs = {}
		end
		room.contents.countprefabs.sdf_chest_wooden = function() return (math.random() > SDF_CHEST_WOODEN_PERCENT and 1) or 0 end
		room.contents.countprefabs.sdf_chest_skull = function() return (math.random() > SDF_CHEST_SKULL_PERCENT and 1) or 0 end
	end
	AddRoomPreInit("BGLightningBluff", BGLightningBluffPreInit)

	local function MoonIsland_IslandShardPreInit(room)
		if not room.contents.countprefabs then
			room.contents.countprefabs = {}
		end
		room.contents.countprefabs.sdf_chest_wooden = function() return (math.random() > SDF_CHEST_WOODEN_PERCENT and 1) or 0 end
	end
	AddRoomPreInit("MoonIsland_IslandShard", MoonIsland_IslandShardPreInit)


	--Caves
	--Always Spawn Locations
	local function RuinedCityEntrancePreInit(room)
		if not room.contents.countprefabs then
			room.contents.countprefabs = {}
		end
		room.contents.countprefabs.sdf_healthfountain = 1
	end
	AddRoomPreInit("RuinedCityEntrance", RuinedCityEntrancePreInit)


	local function LabyrinthEntrancePreInit(room)
		if not room.contents.countprefabs then
			room.contents.countprefabs = {}
		end
		room.contents.countprefabs.sdf_healthfountain = 1
	end
	AddRoomPreInit("LabyrinthEntrance", LabyrinthEntrancePreInit)

	local function BarracksPreInit(room)
		if not room.contents.countprefabs then
			room.contents.countprefabs = {}
		end
		room.contents.countprefabs.sdf_healthfountain = 1
	end
	AddRoomPreInit("Barracks", BarracksPreInit)

	local function ArchiveMazeEntrancePreInit(room)
		if not room.contents.countprefabs then
			room.contents.countprefabs = {}
		end
		room.contents.countprefabs.sdf_healthfountain = 1
	end
	AddRoomPreInit("ArchiveMazeEntrance", ArchiveMazeEntrancePreInit)


	local function SinkholeOasisPreInit(room)
		if not room.contents.countprefabs then
			room.contents.countprefabs = {}
		end
		room.contents.countprefabs.sdf_healthfountain = 1
		room.contents.countprefabs.sdf_chest_wooden = function() return (math.random() > SDF_CHEST_WOODEN_PERCENT and 1) or 0 end
		room.contents.countprefabs.sdf_chest_skull = function() return (math.random() > SDF_CHEST_SKULL_PERCENT and 1) or 0 end
	end
	AddRoomPreInit("SinkholeOasis", SinkholeOasisPreInit)



	--Boss Spawn Locations
	local function ToadstoolArenaMudPreInit(room)
		if not room.contents.countprefabs then
			room.contents.countprefabs = {}
		end
		room.contents.countprefabs.sdf_healthfountain = 1
		room.contents.countprefabs.sdf_chest_wooden = function() return (math.random() > SDF_CHEST_WOODEN_PERCENT and 1) or 0 end
		room.contents.countprefabs.sdf_chest_skull = function() return (math.random() > SDF_CHEST_SKULL_PERCENT and 1) or 0 end
	end
	AddRoomPreInit("ToadstoolArenaMud", ToadstoolArenaMudPreInit)


	local function ToadstoolArenaCaveMudPreInit(room)
		if not room.contents.countprefabs then
			room.contents.countprefabs = {}
		end
		room.contents.countprefabs.sdf_healthfountain = 1
		room.contents.countprefabs.sdf_chest_wooden = function() return (math.random() > SDF_CHEST_WOODEN_PERCENT and 1) or 0 end
		room.contents.countprefabs.sdf_chest_skull = function() return (math.random() > SDF_CHEST_SKULL_PERCENT and 1) or 0 end
	end
	AddRoomPreInit("ToadstoolArenaCave", ToadstoolArenaCavePreInit)


	local function RuinedGuardenPreInit(room)
		if not room.contents.countprefabs then
			room.contents.countprefabs = {}
		end
		room.contents.countprefabs.sdf_healthfountain = 1
		room.contents.countprefabs.sdf_chest_wooden = 1
		room.contents.countprefabs.sdf_chest_skull = 1
	end
	AddRoomPreInit("RuinedGuarden", RuinedGuardenPreInit)



	--Small Chance Spawn Locations
	local function SpillagmiteMeadowPreInit(room)
		if not room.contents.countprefabs then
			room.contents.countprefabs = {}
		end
		room.contents.countprefabs.sdf_healthfountain = function() return (math.random() > SDF_HEALTHFOUNTAIN_PERCENT and 1) or 0 end
		room.contents.countprefabs.sdf_chest_wooden = function() return (math.random() > SDF_CHEST_WOODEN_PERCENT and 1) or 0 end
		room.contents.countprefabs.sdf_chest_skull = function() return (math.random() > SDF_CHEST_SKULL_PERCENT and 1) or 0 end
	end
	AddRoomPreInit("SpillagmiteMeadow", SpillagmiteMeadowPreInit)


	local function GreenMushMeadowPreInit(room)
		if not room.contents.countprefabs then
			room.contents.countprefabs = {}
		end
		room.contents.countprefabs.sdf_healthfountain = function() return (math.random() > SDF_HEALTHFOUNTAIN_PERCENT and 1) or 0 end
		room.contents.countprefabs.sdf_chest_wooden = function() return (math.random() > SDF_CHEST_WOODEN_PERCENT and 1) or 0 end
		room.contents.countprefabs.sdf_chest_skull = function() return (math.random() > SDF_CHEST_SKULL_PERCENT and 1) or 0 end
	end
	AddRoomPreInit("GreenMushMeadow", GreenMushMeadowPreInit)


	local function BlueMushMeadowPreInit(room)
		if not room.contents.countprefabs then
			room.contents.countprefabs = {}
		end
		room.contents.countprefabs.sdf_healthfountain = function() return (math.random() > SDF_HEALTHFOUNTAIN_PERCENT and 1) or 0 end
		room.contents.countprefabs.sdf_chest_wooden = function() return (math.random() > SDF_CHEST_WOODEN_PERCENT and 1) or 0 end
		room.contents.countprefabs.sdf_chest_skull = function() return (math.random() > SDF_CHEST_SKULL_PERCENT and 1) or 0 end
	end
	AddRoomPreInit("BlueMushMeadow", BlueMushMeadowPreInit)


	local function FungusNoiseMeadowPreInit(room)
		if not room.contents.countprefabs then
			room.contents.countprefabs = {}
		end
		room.contents.countprefabs.sdf_healthfountain = function() return (math.random() > SDF_HEALTHFOUNTAIN_PERCENT and 1) or 0 end
		room.contents.countprefabs.sdf_chest_wooden = function() return (math.random() > SDF_CHEST_WOODEN_PERCENT and 1) or 0 end
		room.contents.countprefabs.sdf_chest_skull = function() return (math.random() > SDF_CHEST_SKULL_PERCENT and 1) or 0 end
	end
	AddRoomPreInit("FungusNoiseMeadow", FungusNoiseMeadowPreInit)


	local function DarkSwampPreInit(room)
		if not room.contents.countprefabs then
			room.contents.countprefabs = {}
		end
		room.contents.countprefabs.sdf_healthfountain = function() return (math.random() > SDF_HEALTHFOUNTAIN_PERCENT and 1) or 0 end
		room.contents.countprefabs.sdf_chest_wooden = function() return (math.random() > SDF_CHEST_WOODEN_PERCENT and 1) or 0 end
		room.contents.countprefabs.sdf_chest_skull = function() return (math.random() > SDF_CHEST_SKULL_PERCENT and 1) or 0 end
	end
	AddRoomPreInit("DarkSwamp", DarkSwampPreInit)


	local function SpiderSinkholeMarshPreInit(room)
		if not room.contents.countprefabs then
			room.contents.countprefabs = {}
		end
		room.contents.countprefabs.sdf_healthfountain = function() return (math.random() > SDF_HEALTHFOUNTAIN_PERCENT and 1) or 0 end
		room.contents.countprefabs.sdf_chest_wooden = function() return (math.random() > SDF_CHEST_WOODEN_PERCENT and 1) or 0 end
		room.contents.countprefabs.sdf_chest_skull = function() return (math.random() > SDF_CHEST_SKULL_PERCENT and 1) or 0 end
	end
	AddRoomPreInit("SpiderSinkholeMarsh", SpiderSinkholeMarshPreInit)


	local function GrasslandSinkholePreInit(room)
		if not room.contents.countprefabs then
			room.contents.countprefabs = {}
		end
		room.contents.countprefabs.sdf_healthfountain = function() return (math.random() > SDF_HEALTHFOUNTAIN_PERCENT and 1) or 0 end
		room.contents.countprefabs.sdf_chest_wooden = function() return (math.random() > SDF_CHEST_WOODEN_PERCENT and 1) or 0 end
		room.contents.countprefabs.sdf_chest_skull = function() return (math.random() > SDF_CHEST_SKULL_PERCENT and 1) or 0 end
	end
	AddRoomPreInit("GrasslandSinkhole", GrasslandSinkholePreInit)


	local function SinkholeCopsesPreInit(room)
		if not room.contents.countprefabs then
			room.contents.countprefabs = {}
		end
		room.contents.countprefabs.sdf_healthfountain = function() return (math.random() > SDF_HEALTHFOUNTAIN_PERCENT and 1) or 0 end
		room.contents.countprefabs.sdf_chest_wooden = function() return (math.random() > SDF_CHEST_WOODEN_PERCENT and 1) or 0 end
		room.contents.countprefabs.sdf_chest_skull = function() return (math.random() > SDF_CHEST_SKULL_PERCENT and 1) or 0 end
	end
	AddRoomPreInit("SinkholeCopses", SinkholeCopsesPreInit)


	local function WetWildsPreInit(room)
		if not room.contents.countprefabs then
			room.contents.countprefabs = {}
		end
		room.contents.countprefabs.sdf_healthfountain = function() return (math.random() > SDF_HEALTHFOUNTAIN_PERCENT and 1) or 0 end
		room.contents.countprefabs.sdf_chest_wooden = function() return (math.random() > SDF_CHEST_WOODEN_PERCENT and 1) or 0 end
		room.contents.countprefabs.sdf_chest_skull = function() return (math.random() > SDF_CHEST_SKULL_PERCENT and 1) or 0 end
	end
	AddRoomPreInit("WetWilds", WetWildsPreInit)


	--Chests only
	local function BarracksPreInit(room)
		if not room.contents.countprefabs then
			room.contents.countprefabs = {}
		end
		room.contents.countprefabs.sdf_chest_wooden = function() return (math.random() > SDF_CHEST_WOODEN_PERCENT and 1) or 0 end
		room.contents.countprefabs.sdf_chest_skull = function() return (math.random() > SDF_CHEST_SKULL_PERCENT and 1) or 0 end
	end
	AddRoomPreInit("Barracks", BarracksPreInit)

	local function RuinedCityPreInit(room)
		if not room.contents.countprefabs then
			room.contents.countprefabs = {}
		end
		room.contents.countprefabs.sdf_chest_wooden = function() return (math.random() > SDF_CHEST_WOODEN_PERCENT and 1) or 0 end
		room.contents.countprefabs.sdf_chest_skull = function() return (math.random() > SDF_CHEST_SKULL_PERCENT and 1) or 0 end
	end
	AddRoomPreInit("RuinedCity", RuinedCityPreInit)

	local function MoonMushForestPreInit(room)
		if not room.contents.countprefabs then
			room.contents.countprefabs = {}
		end
		room.contents.countprefabs.sdf_chest_wooden = function() return (math.random() > SDF_CHEST_WOODEN_PERCENT and 1) or 0 end
		room.contents.countprefabs.sdf_chest_skull = function() return (math.random() > SDF_CHEST_SKULL_PERCENT and 1) or 0 end
	end
	AddRoomPreInit("MoonMushForest", MoonMushForestPreInit)

	local function SpillagmiteForestPreInit(room)
		if not room.contents.countprefabs then
			room.contents.countprefabs = {}
		end
		room.contents.countprefabs.sdf_chest_wooden = function() return (math.random() > SDF_CHEST_WOODEN_PERCENT and 1) or 0 end
		room.contents.countprefabs.sdf_chest_skull = function() return (math.random() > SDF_CHEST_SKULL_PERCENT and 1) or 0 end
	end
	AddRoomPreInit("SpillagmiteForest", SpillagmiteForestPreInit)

	local function BatCavePreInit(room)
		if not room.contents.countprefabs then
			room.contents.countprefabs = {}
		end
		room.contents.countprefabs.sdf_chest_wooden = function() return (math.random() > SDF_CHEST_WOODEN_PERCENT and 1) or 0 end
		room.contents.countprefabs.sdf_chest_skull = function() return (math.random() > SDF_CHEST_SKULL_PERCENT and 1) or 0 end
	end
	AddRoomPreInit("BatCave", BatCavePreInit)

	local function RabbitTownPreInit(room)
		if not room.contents.countprefabs then
			room.contents.countprefabs = {}
		end
		room.contents.countprefabs.sdf_chest_wooden = function() return (math.random() > SDF_CHEST_WOODEN_PERCENT and 1) or 0 end
		room.contents.countprefabs.sdf_chest_skull = function() return (math.random() > SDF_CHEST_SKULL_PERCENT and 1) or 0 end
	end
	AddRoomPreInit("RabbitTown", RabbitTownPreInit)
end


local function chaliceAltarLocations(num)
	local SDF_CHALICE_ID = {false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false}
	local SDF_JACKOFTHEGREEN_ID = false
	local SDF_MULLOCKCHIEFMEMORIAL_ID = false
	local SDF_HAUNTEDRUINS_ID = false
	local SDF_PUMPKINGORGE_ID = false

	--Forest
	AddRoomPreInit("Graveyard", function(room)
		Layouts["Chalice Altar 1"].fill_mask = GLOBAL.PLACE_MASK.IGNORE_IMPASSABLE_BARREN
		Layouts["Mullock Chief Memorial Setpiece"].fill_mask = GLOBAL.PLACE_MASK.IGNORE_IMPASSABLE_BARREN
		--Layouts["Haunted Ruins Setpiece"].fill_mask = GLOBAL.PLACE_MASK.IGNORE_IMPASSABLE_BARREN

		if room.contents.countstaticlayouts == nil then
		    room.contents.countstaticlayouts = {}
		end
		room.contents.countstaticlayouts["Chalice Altar 1"] = function() 
		    if not SDF_CHALICE_ID[1] then 
			SDF_CHALICE_ID[1] = true 
			return 1 
		    else 
			return 0 
		    end
		end
		room.contents.countstaticlayouts["Mullock Chief Memorial Setpiece"] = function() 
		    if not SDF_MULLOCKCHIEFMEMORIAL_ID then 
			SDF_MULLOCKCHIEFMEMORIAL_ID = true 
			return 1 
		    else 
			return 0 
		    end
		end
	end)

	AddRoomPreInit("BGSavanna", function(room)
		Layouts["Pumpkin Gorge Setpiece"].fill_mask = GLOBAL.PLACE_MASK.IGNORE_IMPASSABLE_BARREN
		if room.contents.countstaticlayouts == nil then
		    room.contents.countstaticlayouts = {}
		end
		room.contents.countstaticlayouts["Pumpkin Gorge Setpiece"] = function() 
		    if not SDF_PUMPKINGORGE_ID then 
			SDF_PUMPKINGORGE_ID = true 
			return 1 
		    else 
			return 0 
		    end
		end
	end)

	AddRoomPreInit("PigKingdom", function(room)
		Layouts["Chalice Altar 3"].fill_mask = GLOBAL.PLACE_MASK.IGNORE_IMPASSABLE_BARREN
		if room.contents.countstaticlayouts == nil then
		    room.contents.countstaticlayouts = {}
		end
		room.contents.countstaticlayouts["Chalice Altar 3"] = function() 
		    if not SDF_CHALICE_ID[3] then 
			SDF_CHALICE_ID[3] = true 
			return 1 
		    else 
			return 0 
		    end
		end
	end)

	AddRoomPreInit("BGGrass", function(room)
		Layouts["Chalice Altar 4"].fill_mask = GLOBAL.PLACE_MASK.IGNORE_IMPASSABLE_BARREN
		if room.contents.countstaticlayouts == nil then
		    room.contents.countstaticlayouts = {}
		end
		room.contents.countstaticlayouts["Chalice Altar 4"] = function() 
		    if not SDF_CHALICE_ID[4] then 
			SDF_CHALICE_ID[4] = true 
			return 1 
		    else 
			return 0 
		    end
		end
	end)

	AddRoomPreInit("BGForest", function(room)
		Layouts["Chalice Altar 5"].fill_mask = GLOBAL.PLACE_MASK.IGNORE_IMPASSABLE_BARREN
		if room.contents.countstaticlayouts == nil then
		    room.contents.countstaticlayouts = {}
		end
		room.contents.countstaticlayouts["Chalice Altar 5"] = function() 
		    if not SDF_CHALICE_ID[5] then 
			SDF_CHALICE_ID[5] = true 
			return 1 
		    else 
			return 0 
		    end
		end
	end)

	AddRoomPreInit("BGBadlands", function(room)
		Layouts["Chalice Altar 6"].fill_mask = GLOBAL.PLACE_MASK.IGNORE_IMPASSABLE_BARREN
		if room.contents.countstaticlayouts == nil then
		    room.contents.countstaticlayouts = {}
		end
		room.contents.countstaticlayouts["Chalice Altar 6"] = function() 
		    if not SDF_CHALICE_ID[6] then 
			SDF_CHALICE_ID[6] = true 
			return 1 
		    else 
			return 0 
		    end
		end
	end)

	AddRoomPreInit("BGMarsh", function(room)
		Layouts["Chalice Altar 7"].fill_mask = GLOBAL.PLACE_MASK.IGNORE_IMPASSABLE_BARREN
		if room.contents.countstaticlayouts == nil then
		    room.contents.countstaticlayouts = {}
		end
		room.contents.countstaticlayouts["Chalice Altar 7"] = function() 
		    if not SDF_CHALICE_ID[7] then 
			SDF_CHALICE_ID[7] = true 
			return 1 
		    else 
			return 0 
		    end
		end
	end)

	AddRoomPreInit("LightningBluffOasis", function(room)
		Layouts["Chalice Altar 8"].fill_mask = GLOBAL.PLACE_MASK.IGNORE_IMPASSABLE_BARREN
		if room.contents.countstaticlayouts == nil then
		    room.contents.countstaticlayouts = {}
		end
		room.contents.countstaticlayouts["Chalice Altar 8"] = function() 
		    if not SDF_CHALICE_ID[8] then 
			SDF_CHALICE_ID[8] = true 
			return 1 
		    else 
			return 0 
		    end
		end
	end)

	AddRoomPreInit("OceanRough", function(room)
		Layouts["Jack of The Green Setpiece"].fill_mask = GLOBAL.PLACE_MASK.IGNORE_IMPASSABLE_BARREN
		if room.contents.countstaticlayouts == nil then
		    room.contents.countstaticlayouts = {}
		end
		room.contents.countstaticlayouts["Jack of The Green Setpiece"] = function() 
		    if not SDF_JACKOFTHEGREEN_ID then 
			SDF_JACKOFTHEGREEN_ID = true 
			return 1 
		    else 
			return 0 
		    end
		end
	end)

	AddRoomPreInit("MoonIsland_Baths", function(room)
		Layouts["Chalice Altar 10"].fill_mask = GLOBAL.PLACE_MASK.IGNORE_IMPASSABLE_BARREN
		if room.contents.countstaticlayouts == nil then
		    room.contents.countstaticlayouts = {}
		end
		room.contents.countstaticlayouts["Chalice Altar 10"] = function() 
		    if not SDF_CHALICE_ID[10] then 
			SDF_CHALICE_ID[10] = true 
			return 1 
		    else 
			return 0 
		    end
		end
	end)

	--Caves
	AddRoomPreInit("SinkholeOasis", function(room)
		Layouts["Chalice Altar 11"].fill_mask = GLOBAL.PLACE_MASK.IGNORE_IMPASSABLE_BARREN
		if room.contents.countstaticlayouts == nil then
		    room.contents.countstaticlayouts = {}
		end
		room.contents.countstaticlayouts["Chalice Altar 11"] = function() 
		    if not SDF_CHALICE_ID[11] then 
			SDF_CHALICE_ID[11] = true 
			return 1 
		    else 
			return 0 
		    end
		end
	end)

	AddRoomPreInit("RedMushForest", function(room)
		Layouts["Chalice Altar 12"].fill_mask = GLOBAL.PLACE_MASK.IGNORE_IMPASSABLE_BARREN
		if room.contents.countstaticlayouts == nil then
		    room.contents.countstaticlayouts = {}
		end
		room.contents.countstaticlayouts["Chalice Altar 12"] = function() 
		    if not SDF_CHALICE_ID[12] then 
			SDF_CHALICE_ID[12] = true 
			return 1 
		    else 
			return 0 
		    end
		end
	end)

	AddRoomPreInit("GreenMushForest", function(room)
		Layouts["Chalice Altar 13"].fill_mask = GLOBAL.PLACE_MASK.IGNORE_IMPASSABLE_BARREN
		if room.contents.countstaticlayouts == nil then
		    room.contents.countstaticlayouts = {}
		end
		room.contents.countstaticlayouts["Chalice Altar 13"] = function() 
		    if not SDF_CHALICE_ID[13] then 
			SDF_CHALICE_ID[13] = true 
			return 1 
		    else 
			return 0 
		    end
		end
	end)

	AddRoomPreInit("BlueMushForest", function(room)
		Layouts["Chalice Altar 14"].fill_mask = GLOBAL.PLACE_MASK.IGNORE_IMPASSABLE_BARREN
		if room.contents.countstaticlayouts == nil then
		    room.contents.countstaticlayouts = {}
		end
		room.contents.countstaticlayouts["Chalice Altar 14"] = function() 
		    if not SDF_CHALICE_ID[14] then 
			SDF_CHALICE_ID[14] = true 
			return 1 
		    else 
			return 0 
		    end
		end
	end)

	AddRoomPreInit("MoonMushForest", function(room)
		Layouts["Chalice Altar 15"].fill_mask = GLOBAL.PLACE_MASK.IGNORE_IMPASSABLE_BARREN
		if room.contents.countstaticlayouts == nil then
		    room.contents.countstaticlayouts = {}
		end
		room.contents.countstaticlayouts["Chalice Altar 15"] = function() 
		    if not SDF_CHALICE_ID[15] then 
			SDF_CHALICE_ID[15] = true 
			return 1 
		    else 
			return 0 
		    end
		end
	end)

	AddRoomPreInit("SpillagmiteForest", function(room)
		Layouts["Chalice Altar 16"].fill_mask = GLOBAL.PLACE_MASK.IGNORE_IMPASSABLE_BARREN
		if room.contents.countstaticlayouts == nil then
		    room.contents.countstaticlayouts = {}
		end
		room.contents.countstaticlayouts["Chalice Altar 16"] = function() 
		    if not SDF_CHALICE_ID[16] then 
			SDF_CHALICE_ID[16] = true 
			return 1 
		    else 
			return 0 
		    end
		end
	end)

	AddRoomPreInit("BatCave", function(room)
		Layouts["Chalice Altar 17"].fill_mask = GLOBAL.PLACE_MASK.IGNORE_IMPASSABLE_BARREN
		if room.contents.countstaticlayouts == nil then
		    room.contents.countstaticlayouts = {}
		end
		room.contents.countstaticlayouts["Chalice Altar 17"] = function() 
		    if not SDF_CHALICE_ID[17] then 
			SDF_CHALICE_ID[17] = true 
			return 1 
		    else 
			return 0 
		    end
		end
	end)


	AddRoomPreInit("RabbitCity", function(room)
		Layouts["Chalice Altar 18"].fill_mask = GLOBAL.PLACE_MASK.IGNORE_IMPASSABLE_BARREN
		if room.contents.countstaticlayouts == nil then
		    room.contents.countstaticlayouts = {}
		end
		room.contents.countstaticlayouts["Chalice Altar 18"] = function() 
		    if not SDF_CHALICE_ID[18] then 
			SDF_CHALICE_ID[18] = true 
			return 1 
		    else 
			return 0 
		    end
		end
	end)

	if SDF_CHALICE_ID[18] == false then
	AddRoomPreInit("RabbitTown", function(room)
		Layouts["Chalice Altar 18"].fill_mask = GLOBAL.PLACE_MASK.IGNORE_IMPASSABLE_BARREN
		if room.contents.countstaticlayouts == nil then
		    room.contents.countstaticlayouts = {}
		end
		room.contents.countstaticlayouts["Chalice Altar 18"] = function() 
		    if not SDF_CHALICE_ID[18] then 
			SDF_CHALICE_ID[18] = true 
			return 1 
		    else 
			return 0 
		    end
		end
	end)
	end

	AddRoomPreInit("RuinedGuarden", function(room)
		Layouts["Chalice Altar 19"].fill_mask = GLOBAL.PLACE_MASK.IGNORE_IMPASSABLE_BARREN
		if room.contents.countstaticlayouts == nil then
		    room.contents.countstaticlayouts = {}
		end
		room.contents.countstaticlayouts["Chalice Altar 19"] = function() 
		    if not SDF_CHALICE_ID[19] then 
			SDF_CHALICE_ID[19] = true 
			return 1 
		    else 
			return 0 
		    end
		end
	end)

	AddRoomPreInit("RuinedCity", function(room)
		Layouts["Chalice Altar 20"].fill_mask = GLOBAL.PLACE_MASK.IGNORE_IMPASSABLE_BARREN
		if room.contents.countstaticlayouts == nil then
		    room.contents.countstaticlayouts = {}
		end
		room.contents.countstaticlayouts["Chalice Altar 20"] = function() 
		    if not SDF_CHALICE_ID[20] then 
			SDF_CHALICE_ID[20] = true 
			return 1 
		    else 
			return 0 
		    end
		end
	end)

	AddRoomPreInit("BGSacred", function(room)
		Layouts["Haunted Ruins Setpiece"].fill_mask = GLOBAL.PLACE_MASK.IGNORE_IMPASSABLE_BARREN
		if room.contents.countstaticlayouts == nil then
		    room.contents.countstaticlayouts = {}
		end
		room.contents.countstaticlayouts["Haunted Ruins Setpiece"] = function() 
		    if not SDF_HAUNTEDRUINS_ID then 
			SDF_HAUNTEDRUINS_ID = true 
			return 1 
		    else 
			return 0 
		    end
		end
	end)

	--[[AddRoomPreInit("Barracks", function(room) --boss room
		Layouts["Chalice Altar 19"].fill_mask = GLOBAL.PLACE_MASK.IGNORE_IMPASSABLE_BARREN
		if room.contents.countstaticlayouts == nil then
		    room.contents.countstaticlayouts = {}
		end
		room.contents.countstaticlayouts["Chalice Altar 19"] = function() 
		    if not SDF_CHALICE_ID[19] then 
			SDF_CHALICE_ID[19] = true 
			return 1 
		    else 
			return 0 
		    end
		end
	end)]]
end



--Chalice Altar World Gen -Quest
	AddLevelPreInitAny(function(level)
		Layouts["Hall of Heroes Setpiece"].fill_mask = GLOBAL.PLACE_MASK.IGNORE_IMPASSABLE_BARREN
		if level.location == "forest" then -- only in overworld
		    if level.required_setpieces == nil then -- if required_setpieces does not exist already, create it
			level.required_setpieces = {}
		    end
		    if level.required_prefabs == nil then
			level.required_prefabs = {}
		    end
		    table.insert(level.required_setpieces, "Hall of Heroes Setpiece")
		    table.insert(level.required_prefabs, "sdf_chalice_altar")
		    table.insert(level.required_prefabs, "sdf_jack_of_the_green")
		    table.insert(level.required_prefabs, "sdf_mullock_chief_memorial_mound")
		    table.insert(level.required_prefabs, "sdf_pumpkin_gorge_well")
		end
	end)

	AddLevelPreInitAny(function(level)

		if level.location == "cave" then -- only in overworld
		    if level.required_prefabs == nil then
			level.required_prefabs = {}
		    end
		    table.insert(level.required_prefabs, "sdf_chalice_altar")
		    table.insert(level.required_prefabs, "sdf_chest_kingdom")
		end
	end)

	--Extra Worldgen
	chaliceAltarLocations(2)
	healthFountain_Chest_Spawns(2)