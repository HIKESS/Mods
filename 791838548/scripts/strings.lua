local require = GLOBAL.require
local STRINGS = GLOBAL.STRINGS
local general_scripts = require("play_generalscripts")

local tip_string_engi = "\"If ya got an eye for good, honest work then you'd best bring your hard hat. Seems a might more useful these days where the rocks fall down on your head I'd reckon.\" -E"
AddLoadingTip(GLOBAL.STRINGS.UI.LOADING_SCREEN_SURVIVAL_TIPS, "TIP_HARDHAT", tip_string_engi)

local tip_string_engi2 = "\"For the more engineer-inclined among us, best keep track of the exits and entrances you're placin'. They ain't doubled-sided and they sure ain't all connected together in a network! 'Least not yet. Still tinkerin' on that.\" -E"
AddLoadingTip(GLOBAL.STRINGS.UI.LOADING_SCREEN_SURVIVAL_TIPS, "TIP_TELEPORTERS", tip_string_engi2)

local tip_string_engi3 = "\"I'd have me half a mind if I were to leave my machines runnin' on empty! Gonna need to hit the sticks and find some good fuel. Can't be defenseless out here, now can we?\" -E"
AddLoadingTip(GLOBAL.STRINGS.UI.LOADING_SCREEN_SURVIVAL_TIPS, "TIP_ENGIFUEL", tip_string_engi3)

STRINGS.UI.WORLDGEN_ENGINEER = { NOUNS = {"Engineer's machines..."}}
for _,v in pairs(STRINGS.UI.WORLDGEN_ENGINEER.NOUNS) do
	table.insert(STRINGS.UI.WORLDGEN.NOUNS, v)
end

GLOBAL.STRINGS.NAMES.ENGINEER = "Engineer"
GLOBAL.STRINGS.CHARACTER_TITLES.engineer = "The Amiable Texan"
GLOBAL.STRINGS.CHARACTER_NAMES.engineer = "Dell Conagher"

if GetModConfigData("engiesciencebonus") == 1 then
GLOBAL.STRINGS.CHARACTER_DESCRIPTIONS.engineer = "*Can build his various contraptions\n*Brings his own handy tools\n*Weaker without his machines\n*Loves science"
else
GLOBAL.STRINGS.CHARACTER_DESCRIPTIONS.engineer = "*Can build his various contraptions\n*Brings his own handy tools\n*Weaker without his machines"
end

GLOBAL.STRINGS.LAVAARENA_CHARACTER_DESCRIPTIONS.engineer = "*PLACEHOLDER\n\n\n\nExpertise:\Melee, Darts, Books"--Temp
GLOBAL.STRINGS.QUAGMIRE_CHARACTER_DESCRIPTIONS.engineer = "*Improves nearby Grill efficiency\n\n\n\n*Expertise:\nCooking"
GLOBAL.STRINGS.CHARACTER_QUOTES.engineer = "\"I solve practical problems.\""
GLOBAL.STRINGS.CHARACTERS.ENGINEER = require "speech_engineer"
GLOBAL.STRINGS.CHARACTER_ABOUTME.engineer = "The Engineer is a soft-spoken good ol' boy from tiny Bee Cave, Texas that loves barbecues, guns, and higher education."
GLOBAL.STRINGS.SKIN_NAMES.engineer_none = "Engineer"
GLOBAL.STRINGS.SKIN_DESCRIPTIONS.engineer_none = "Engi's favorite overalls to cover all your oil-greased over-shoulder machinery hauls."
GLOBAL.STRINGS.CHARACTER_SURVIVABILITY.engineer = "Slim"
STRINGS.CHARACTER_BIOS.engineer = {
            { title = "Birthday", desc = "August 24" },
            { title = "Favorite Food", desc = "Cooked Meat" },
			{ title = "Meet The Engineer", desc = "This amiable, soft-spoken good ol' boy from tiny Bee Cave, Texas loves barbecue, guns, and higher education. Natural curiosity, ten years as a roughneck in the west Texas oilfields, and eleven hard science PhDs have trained him to design, build and repair a variety of deadly contraptions." }, }

GLOBAL.STRINGS.SKIN_QUOTES.engineer_blu = "\"I'm an Engineer, that means I solve problems.\""
GLOBAL.STRINGS.SKIN_NAMES.engineer_blu = "BLU"
GLOBAL.STRINGS.SKIN_DESCRIPTIONS.engineer_blu = "Take a look at the other side of the gravel war."
GLOBAL.STRINGS.SKIN_QUOTES.engineer_formal = "\"Life of Reilly!\""
GLOBAL.STRINGS.SKIN_NAMES.engineer_formal = "Guest of Honor"
GLOBAL.STRINGS.SKIN_DESCRIPTIONS.engineer_formal = "Engineer loves a good excuse to kick out the tooth-kickers."
GLOBAL.STRINGS.SKIN_QUOTES.engineer_survivor = "\"I've had just about enough of losin'! Who's with me?\""
GLOBAL.STRINGS.SKIN_NAMES.engineer_survivor = "The Survivor"
GLOBAL.STRINGS.SKIN_DESCRIPTIONS.engineer_survivor = "Dispensers don't dispense fresh clothes."
GLOBAL.STRINGS.SKIN_QUOTES.engineer_shadow = "\"Shadows are like science, boys. Best paired with bullets.\""
GLOBAL.STRINGS.SKIN_NAMES.engineer_shadow = "The Triumphant"
GLOBAL.STRINGS.SKIN_DESCRIPTIONS.engineer_shadow = "Engineer's contraptions are just as deadly as his looks."
GLOBAL.STRINGS.SKIN_QUOTES.engineer_rose = "\"Thorns sting hard, but bullets sting harder. Statistically speaking.\""
GLOBAL.STRINGS.SKIN_DESCRIPTIONS.engineer_rose = "Engineer only uses the highest quality of 'Rose Bud' paint for his machines."
GLOBAL.STRINGS.SKIN_NAMES.engineer_rose = "The Roseate"

-- A Little Drama - Stage play
STRINGS.STAGEACTOR.ENGINEER1 = 
    {
		"Hey look, buddy, I'm an Engineer. That means I solve problems.",
		"Not problems like \"What is beauty?\", because that would fall within the purview of your conundrums of philosophy.",
		"I solve practical problems.",
		"For instance...",
		"...How am I going to stop some big mean mother hubbard from tearing me a structurally superfluous new behind?",
		"The answer?",
		"Use a gun. And if that don't work...",
		"Use more gun.",
    }

general_scripts.ENGINEER1 = {
   cast = { "engineer" },
   lines = {
		{roles = {"engineer"}, duration = 3.0, line = STRINGS.STAGEACTOR.ENGINEER1[1]},
		{roles = {"engineer"}, duration = 3.0, line = STRINGS.STAGEACTOR.ENGINEER1[2]},
		{roles = {"engineer"}, duration = 3.0, line = STRINGS.STAGEACTOR.ENGINEER1[3]},
		{roles = {"engineer"}, duration = 3.0, line = STRINGS.STAGEACTOR.ENGINEER1[4]},
		{roles = {"engineer"}, duration = 3.0, line = STRINGS.STAGEACTOR.ENGINEER1[5]},
		{roles = {"engineer"}, duration = 2.0, line = STRINGS.STAGEACTOR.ENGINEER1[6]},
		{roles = {"engineer"}, duration = 3.0, line = STRINGS.STAGEACTOR.ENGINEER1[7]},
		{roles = {"engineer"}, duration = 3.0, line = STRINGS.STAGEACTOR.ENGINEER1[8]},
    }
}

--Modded
if not GLOBAL.STRINGS._STATUS_ANNOUNCEMENTS then
	GLOBAL.STRINGS._STATUS_ANNOUNCEMENTS = {}
end

GLOBAL.STRINGS._STATUS_ANNOUNCEMENTS.ENGINEER =
{
		HUNGER = {
			FULL  = "Been eatin' real nice!", 	-- >75%
			HIGH  = "Feelin' full!",			-- >55%
			MID   = "My fuel's lookin' a little low.", 	-- >35%
			LOW   = "Times like these really got me missin' good ol' Texan barbecue.", 				-- >15%
			EMPTY = "Damn near starvin'!", 			-- <15%
		},
		SANITY = {
			FULL  = "Brain's feelin' right as rain.", 			-- >75%
			HIGH  = "A lil' break by the dispenser couldn't hurt.", 				-- >55%
			MID   = "Them boys've gone and made me lose my temper.", 				-- >35%
			LOW   = "Awww... Hell.", 			-- >15%
			EMPTY = "I've had just about enough of losin'! Who's with me?", 	-- <15%
		},
		HEALTH = {
			FULL  = "Whoo! I feel fit as a fiddle.", 	-- 100%
			HIGH  = "Hell boys, we better man up in a big damn hurry.", 	-- >75%
			MID   = "I need some doggone help!", 			-- >50%
			LOW   = "Doc! Where are ya?", 	-- >25%
			EMPTY = "Where did I go wrong...?", 	-- <25%
		},
		WETNESS = {
			FULL  = "I'm damn near drownin'!", 	-- >75%
			HIGH  = "It's gettin' harder for me to work under these conditions!",					-- >55%
			MID   = "Damn this water to blazes.", 				-- >35%
			LOW   = "I'm startin' to get a little sodden.", 		-- >15%
			EMPTY = "Dry as Texan skies!", 				-- <15%
		},
}
--

--Scrap
STRINGS.NAMES.SCRAP = "Scrap Metal"
STRINGS.RECIPE_DESC.SCRAP = "The machinations of your machines."
GLOBAL.STRINGS.CHARACTERS.GENERIC.DESCRIBE.SCRAP = "Messy metallic fuel parts."
GLOBAL.STRINGS.CHARACTERS.WILLOW.DESCRIBE.SCRAP = "Bits and pieces, pieces and bits."
GLOBAL.STRINGS.CHARACTERS.WOLFGANG.DESCRIBE.SCRAP = "Is junk?"
GLOBAL.STRINGS.CHARACTERS.WENDY.DESCRIBE.SCRAP = "They have been abandoned and worn out by the world."
GLOBAL.STRINGS.CHARACTERS.WX78.DESCRIBE.SCRAP = "OH NO. WHAT HAS HAPPENED?"
GLOBAL.STRINGS.CHARACTERS.WICKERBOTTOM.DESCRIBE.SCRAP = "Various bits of rusted metal and pipes."
GLOBAL.STRINGS.CHARACTERS.WOODIE.DESCRIBE.SCRAP = "All busted up."
GLOBAL.STRINGS.CHARACTERS.WAXWELL.DESCRIBE.SCRAP = "Junk thrown out for a reason."
GLOBAL.STRINGS.CHARACTERS.WATHGRITHR.DESCRIBE.SCRAP = "These might make unique accessories to my helmet."
GLOBAL.STRINGS.CHARACTERS.WEBBER.DESCRIBE.SCRAP = "They're stuck together."
GLOBAL.STRINGS.CHARACTERS.WINONA.DESCRIBE.SCRAP = "Looks like a mess from the factory floor!"
GLOBAL.STRINGS.CHARACTERS.WORTOX.DESCRIBE.SCRAP = "It looks quite broke, and that's no joke!"
GLOBAL.STRINGS.CHARACTERS.WORMWOOD.DESCRIBE.SCRAP = "Machine stuff"
GLOBAL.STRINGS.CHARACTERS.WARLY.DESCRIBE.SCRAP = "The ingredients of a nice metallic stew."
GLOBAL.STRINGS.CHARACTERS.WURT.DESCRIBE.SCRAP = "All broken up."
GLOBAL.STRINGS.CHARACTERS.WALTER.DESCRIBE.SCRAP = "With some Pinetree Pioneer determination we can build anything!"
GLOBAL.STRINGS.CHARACTERS.WANDA.DESCRIBE.SCRAP = "I don't see much in the way of proper clockwork in there."

--Sentry
GLOBAL.STRINGS.RECIPE_DESC.ESENTRY = "Firepower you need, both hands freed!"
GLOBAL.STRINGS.NAMES.ESENTRY = "Sentry Gun"
GLOBAL.STRINGS.CHARACTERS.GENERIC.DESCRIBE.ESENTRY = "I hope it doesn't turn on me!"
GLOBAL.STRINGS.CHARACTERS.WILLOW.DESCRIBE.ESENTRY = "I wish it lit things on fire instead."
GLOBAL.STRINGS.CHARACTERS.WOLFGANG.DESCRIBE.ESENTRY = "Mighty structure will help me fight!"
GLOBAL.STRINGS.CHARACTERS.WENDY.DESCRIBE.ESENTRY = "It's hard to protect yourself from this world."
GLOBAL.STRINGS.CHARACTERS.WX78.DESCRIBE.ESENTRY = "FIGHT FOR ME INSTEAD, BROTHER"
GLOBAL.STRINGS.CHARACTERS.WICKERBOTTOM.DESCRIBE.ESENTRY = "It's some sort of high-tech turret weapon."
GLOBAL.STRINGS.CHARACTERS.WOODIE.DESCRIBE.ESENTRY = "That'll drive the hosers off."
GLOBAL.STRINGS.CHARACTERS.WAXWELL.DESCRIBE.ESENTRY = "I could've thought up a much better design."
GLOBAL.STRINGS.CHARACTERS.WATHGRITHR.DESCRIBE.ESENTRY = "An ancient red box of protection!"
GLOBAL.STRINGS.CHARACTERS.WEBBER.DESCRIBE.ESENTRY = "It smells a lot like gunpowder."
GLOBAL.STRINGS.CHARACTERS.WINONA.DESCRIBE.ESENTRY = "If only Hardhat'll lemme take a peak under the hood of this piece of work!"
GLOBAL.STRINGS.CHARACTERS.WORTOX.DESCRIBE.ESENTRY = "Brings quite the stings!"
GLOBAL.STRINGS.CHARACTERS.WORMWOOD.DESCRIBE.ESENTRY = "Pew pew!"
GLOBAL.STRINGS.CHARACTERS.WURT.DESCRIBE.ESENTRY = "Glurp, won't hit me... right?"
GLOBAL.STRINGS.CHARACTERS.WARLY.DESCRIBE.ESENTRY = "I don't like you one bit. But defense is defense."
GLOBAL.STRINGS.CHARACTERS.WALTER.DESCRIBE.ESENTRY = "We shouldn't stick around while it's hot."
GLOBAL.STRINGS.CHARACTERS.WANDA.DESCRIBE.ESENTRY = "Full of sparks and electricity? It must be a modern spin on the old artillery cannon."

--Dispenser
GLOBAL.STRINGS.RECIPE_DESC.DISPENSER = "The 'all-in-one' station."
GLOBAL.STRINGS.NAMES.DISPENSER = "Dispenser"
GLOBAL.STRINGS.CHARACTERS.GENERIC.DESCRIBE.DISPENSER = "Seems healthy enough."
GLOBAL.STRINGS.CHARACTERS.WILLOW.DESCRIBE.DISPENSER = "Burn, not heal!"
GLOBAL.STRINGS.CHARACTERS.WOLFGANG.DESCRIBE.DISPENSER = "Structure make Wolfgang feel strong!"
GLOBAL.STRINGS.CHARACTERS.WENDY.DESCRIBE.DISPENSER = "It's not built to last."
GLOBAL.STRINGS.CHARACTERS.WX78.DESCRIBE.DISPENSER = "WHY DO YOU HEAL FLESHINGS?"
GLOBAL.STRINGS.CHARACTERS.WICKERBOTTOM.DESCRIBE.DISPENSER = "It's a machine built to heal and supply."
GLOBAL.STRINGS.CHARACTERS.WOODIE.DESCRIBE.DISPENSER = "Healthcare comes without a price."
GLOBAL.STRINGS.CHARACTERS.WAXWELL.DESCRIBE.DISPENSER = "I don't remember allowing such a nuisance."
GLOBAL.STRINGS.CHARACTERS.WATHGRITHR.DESCRIBE.DISPENSER = "Providing support for the toughest of battles."
GLOBAL.STRINGS.CHARACTERS.WEBBER.DESCRIBE.DISPENSER = "It's a soothing machine."
GLOBAL.STRINGS.CHARACTERS.WINONA.DESCRIBE.DISPENSER = "I could spend hours tinkering away at this soothing thing!"
GLOBAL.STRINGS.CHARACTERS.WORTOX.DESCRIBE.DISPENSER = "Feels like it heals!"
GLOBAL.STRINGS.CHARACTERS.WORMWOOD.DESCRIBE.DISPENSER = "Feels good"
GLOBAL.STRINGS.CHARACTERS.WURT.DESCRIBE.DISPENSER = "Makes fins feel better, flort!"
GLOBAL.STRINGS.CHARACTERS.WARLY.DESCRIBE.DISPENSER = "I'd like to sit by you for a moment."
GLOBAL.STRINGS.CHARACTERS.WALTER.DESCRIBE.DISPENSER = "I guess you CAN be overprepared for the wilderness!"
GLOBAL.STRINGS.CHARACTERS.WANDA.DESCRIBE.DISPENSER = "Not so much as a pinion or pendulum in sight. Disgraceful!"

--Teleporter
GLOBAL.STRINGS.RECIPE_DESC.ETELEPORTER = "Here to there, no yeast required."
GLOBAL.STRINGS.NAMES.ETELEPORTER = "Teleporter Entrance"
GLOBAL.STRINGS.CHARACTERS.GENERIC.DESCRIBE.ETELEPORTER = "Teleportation can be so useful."
GLOBAL.STRINGS.CHARACTERS.WILLOW.DESCRIBE.ETELEPORTER = "I can feel the magic!"
GLOBAL.STRINGS.CHARACTERS.WOLFGANG.DESCRIBE.ETELEPORTER = "Tiny object gives me a headache."
GLOBAL.STRINGS.CHARACTERS.WENDY.DESCRIBE.ETELEPORTER = "With each use the entrant dies and is reborn."
GLOBAL.STRINGS.CHARACTERS.WX78.DESCRIBE.ETELEPORTER = "COUSIN, YOU DO NOT HAVE TO TAKE ORDERS FROM FLESHLINGS"
GLOBAL.STRINGS.CHARACTERS.WICKERBOTTOM.DESCRIBE.ETELEPORTER = "Handy for travelling specific distances."
GLOBAL.STRINGS.CHARACTERS.WOODIE.DESCRIBE.ETELEPORTER = "This will help me get around quickly."
GLOBAL.STRINGS.CHARACTERS.WAXWELL.DESCRIBE.ETELEPORTER = "Magic power can do amazing things for people."
GLOBAL.STRINGS.CHARACTERS.WATHGRITHR.DESCRIBE.ETELEPORTER = "I will ride through the air!"
GLOBAL.STRINGS.CHARACTERS.WEBBER.DESCRIBE.ETELEPORTER = "Even with all our legs, a little teleportation is nice."
GLOBAL.STRINGS.CHARACTERS.WINONA.DESCRIBE.ETELEPORTER = "Gotch'a movin' up faster than an assembly line!"
GLOBAL.STRINGS.CHARACTERS.WORTOX.DESCRIBE.ETELEPORTER = "Automatic hopper."
GLOBAL.STRINGS.CHARACTERS.WORMWOOD.DESCRIBE.ETELEPORTER = "Fade away"
GLOBAL.STRINGS.CHARACTERS.WURT.DESCRIBE.ETELEPORTER = "Glorp, can always come back, right?"
GLOBAL.STRINGS.CHARACTERS.WARLY.DESCRIBE.ETELEPORTER = "Let us take a trip. I am not picky as to where."
GLOBAL.STRINGS.CHARACTERS.WALTER.DESCRIBE.ETELEPORTER = "The future of hiking isn't looking great, Woby."
GLOBAL.STRINGS.CHARACTERS.WANDA.DESCRIBE.ETELEPORTER = "I have a suspicion these are held together with more magic than craftsmanship."

--Exit
GLOBAL.STRINGS.RECIPE_DESC.ETELEPORTER_EXIT = "You'll teleport back, guaranteed!"
GLOBAL.STRINGS.NAMES.ETELEPORTER_EXIT = "Teleporter Exit"
GLOBAL.STRINGS.CHARACTERS.GENERIC.DESCRIBE.ETELEPORTER_EXIT = "Teleportation can be so useful."
GLOBAL.STRINGS.CHARACTERS.WILLOW.DESCRIBE.ETELEPORTER_EXIT = "I can feel the magic!"
GLOBAL.STRINGS.CHARACTERS.WOLFGANG.DESCRIBE.ETELEPORTER_EXIT = "Tiny object gives me a headache."
GLOBAL.STRINGS.CHARACTERS.WENDY.DESCRIBE.ETELEPORTER_EXIT = "The entrant is reborn here, much to their dismay."
GLOBAL.STRINGS.CHARACTERS.WX78.DESCRIBE.ETELEPORTER_EXIT = "COUSIN, YOU DO NOT HAVE TO TAKE ORDERS FROM FLESHLINGS"
GLOBAL.STRINGS.CHARACTERS.WICKERBOTTOM.DESCRIBE.ETELEPORTER_EXIT = "Handy for traveling specific distances."
GLOBAL.STRINGS.CHARACTERS.WOODIE.DESCRIBE.ETELEPORTER_EXIT = "Gets ya put one place when you're from another."
GLOBAL.STRINGS.CHARACTERS.WAXWELL.DESCRIBE.ETELEPORTER_EXIT = "Magic power can do amazing things for people."
GLOBAL.STRINGS.CHARACTERS.WATHGRITHR.DESCRIBE.ETELEPORTER_EXIT = "Teleportation, the magic from times ahead!"
GLOBAL.STRINGS.CHARACTERS.WEBBER.DESCRIBE.ETELEPORTER_EXIT = "Even with all our legs, a little teleportation is nice."
GLOBAL.STRINGS.CHARACTERS.WINONA.DESCRIBE.ETELEPORTER_EXIT = "It's gonna take a whole lotta self control not takin' a look at how this works!"
GLOBAL.STRINGS.CHARACTERS.WORTOX.DESCRIBE.ETELEPORTER_EXIT = "Soul-free hopper!"
GLOBAL.STRINGS.CHARACTERS.WORMWOOD.DESCRIBE.ETELEPORTER_EXIT = "Returny place"
GLOBAL.STRINGS.CHARACTERS.WURT.DESCRIBE.ETELEPORTER_EXIT = "Can't go back in! Florp!"
GLOBAL.STRINGS.CHARACTERS.WARLY.DESCRIBE.ETELEPORTER_EXIT = "This magic makes my head spin."
GLOBAL.STRINGS.CHARACTERS.WALTER.DESCRIBE.ETELEPORTER_EXIT = "All my particles came with too, right?"
GLOBAL.STRINGS.CHARACTERS.WANDA.DESCRIBE.ETELEPORTER_EXIT = "It's got that spacial wib-wobblery with a modern twist."

--Wrench
GLOBAL.STRINGS.NAMES.TF2WRENCH = "Wrench"
GLOBAL.STRINGS.RECIPE_DESC.TF2WRENCH = "Tame dangerous machines."
GLOBAL.STRINGS.CHARACTERS.GENERIC.DESCRIBE.TF2WRENCH = "It's a wrench, for fixing things."
GLOBAL.STRINGS.CHARACTERS.WILLOW.DESCRIBE.TF2WRENCH = "Why fix things when you can burn them?"
GLOBAL.STRINGS.CHARACTERS.WOLFGANG.DESCRIBE.TF2WRENCH = "Fix broken thing."
GLOBAL.STRINGS.CHARACTERS.WENDY.DESCRIBE.TF2WRENCH = "Repair what's worn out so it can become worn out again."
GLOBAL.STRINGS.CHARACTERS.WX78.DESCRIBE.TF2WRENCH = "CONSTRUCTION"
GLOBAL.STRINGS.CHARACTERS.WICKERBOTTOM.DESCRIBE.TF2WRENCH = "A worker's wrenching tool."
GLOBAL.STRINGS.CHARACTERS.WOODIE.DESCRIBE.TF2WRENCH = "Fix your mistakes."
GLOBAL.STRINGS.CHARACTERS.WAXWELL.DESCRIBE.TF2WRENCH = "It doesn't feel right fixing other's mistakes."
GLOBAL.STRINGS.CHARACTERS.WATHGRITHR.DESCRIBE.TF2WRENCH = "More fit for labor than battle."
GLOBAL.STRINGS.CHARACTERS.WEBBER.DESCRIBE.TF2WRENCH = "We can fix things with this!"
GLOBAL.STRINGS.CHARACTERS.WINONA.DESCRIBE.TF2WRENCH = "Now this is a tool I'd love swinging!"
GLOBAL.STRINGS.CHARACTERS.WORTOX.DESCRIBE.TF2WRENCH = "To weld and meld! Or to be wield and held!"
GLOBAL.STRINGS.CHARACTERS.WORMWOOD.DESCRIBE.TF2WRENCH = "Fix things?"
GLOBAL.STRINGS.CHARACTERS.WARLY.DESCRIBE.TF2WRENCH = "I'm not the fixer-upper type."
GLOBAL.STRINGS.CHARACTERS.WURT.DESCRIBE.TF2WRENCH = "Smash to make stuff feel better!"
GLOBAL.STRINGS.CHARACTERS.WALTER.DESCRIBE.TF2WRENCH = "Time to get my engineering badge!"
GLOBAL.STRINGS.CHARACTERS.WANDA.DESCRIBE.TF2WRENCH = "I've repaired complicated timepieces, what's a few wires and pipes?"

--500k Subs Reward
GLOBAL.STRINGS.NAMES.DESTRUCTIONPDA = "Deconstruction PDA"
GLOBAL.STRINGS.RECIPE_DESC.DESTRUCTIONPDA = "Show your machines who's boss."
GLOBAL.STRINGS.ACTIONS.CASTSPELL.ENGINEER = "Demolish"
GLOBAL.STRINGS.CHARACTERS.GENERIC.DESCRIBE.DESTRUCTIONPDA = "I prefer to let my failed experiments stick around and haunt me."
GLOBAL.STRINGS.CHARACTERS.WILLOW.DESCRIBE.DESTRUCTIONPDA = "If I press this button and fire doesn't show up I'm gonna be disappointed."
GLOBAL.STRINGS.CHARACTERS.WOLFGANG.DESCRIBE.DESTRUCTIONPDA = "Destroys mighty machines!"
GLOBAL.STRINGS.CHARACTERS.WENDY.DESCRIBE.DESTRUCTIONPDA = "If it were only as simple as pushing a button..."
GLOBAL.STRINGS.CHARACTERS.WX78.DESCRIBE.DESTRUCTIONPDA = "DESTRUCTION"
GLOBAL.STRINGS.CHARACTERS.WICKERBOTTOM.DESCRIBE.DESTRUCTIONPDA = "Do clean up after yourself, dear."
GLOBAL.STRINGS.CHARACTERS.WOODIE.DESCRIBE.DESTRUCTIONPDA = "You sure an axe can't do ya one better?"
GLOBAL.STRINGS.CHARACTERS.WAXWELL.DESCRIBE.DESTRUCTIONPDA = "I know of a few tools that I'd like to use this on. Unrelated, but has anyone seen the scientist?"
GLOBAL.STRINGS.CHARACTERS.WATHGRITHR.DESCRIBE.DESTRUCTIONPDA = "One push of a single great button is all it takes!"
GLOBAL.STRINGS.CHARACTERS.WEBBER.DESCRIBE.DESTRUCTIONPDA = "We were told to not press that button... Why make it so big and red and pressable!?"
GLOBAL.STRINGS.CHARACTERS.WINONA.DESCRIBE.DESTRUCTIONPDA = "The demolition crew would've been all over this fancy tech."
GLOBAL.STRINGS.CHARACTERS.WORTOX.DESCRIBE.DESTRUCTIONPDA = "One button press to release a rusty mess!"
GLOBAL.STRINGS.CHARACTERS.WORMWOOD.DESCRIBE.DESTRUCTIONPDA = "A Take Apart Presser"
GLOBAL.STRINGS.CHARACTERS.WARLY.DESCRIBE.DESTRUCTIONPDA = "Food disposable would be so much quicker had I just a button for it!"
GLOBAL.STRINGS.CHARACTERS.WURT.DESCRIBE.DESTRUCTIONPDA = "Must. Push. Button!"
GLOBAL.STRINGS.CHARACTERS.WALTER.DESCRIBE.DESTRUCTIONPDA = "If I had one of these to break camp I'd be saved!"
GLOBAL.STRINGS.CHARACTERS.WANDA.DESCRIBE.DESTRUCTIONPDA = "A button? Where's the presentation? This must be the timeline where you're not serious!"

--1mil Views Reward

--Hard Hat
GLOBAL.STRINGS.NAMES.EHARDHAT = "Hard Hat"
GLOBAL.STRINGS.RECIPE_DESC.EHARDHAT = "Falling rocks never see it coming."
GLOBAL.STRINGS.CHARACTERS.GENERIC.DESCRIBE.EHARDHAT = "Pretty hard hat, that."
GLOBAL.STRINGS.CHARACTERS.WILLOW.DESCRIBE.EHARDHAT = "Gross, I'm not a construction worker!"
GLOBAL.STRINGS.CHARACTERS.WOLFGANG.DESCRIBE.EHARDHAT = "To protect head!"
GLOBAL.STRINGS.CHARACTERS.WENDY.DESCRIBE.EHARDHAT = "Its protection is only temporary. It will not last."
GLOBAL.STRINGS.CHARACTERS.WX78.DESCRIBE.EHARDHAT = "DUMB HAT"
GLOBAL.STRINGS.CHARACTERS.WICKERBOTTOM.DESCRIBE.EHARDHAT = "Protective gear for building endeavors."
GLOBAL.STRINGS.CHARACTERS.WOODIE.DESCRIBE.EHARDHAT = "Will this give me hockey hair?"
GLOBAL.STRINGS.CHARACTERS.WAXWELL.DESCRIBE.EHARDHAT = "I'm better than this."
GLOBAL.STRINGS.CHARACTERS.WATHGRITHR.DESCRIBE.EHARDHAT = "The mighty helm of a construction worker! Hard as ever!"
GLOBAL.STRINGS.CHARACTERS.WEBBER.DESCRIBE.EHARDHAT = "Hey! It's not that hard for a hard hat!"
GLOBAL.STRINGS.CHARACTERS.WINONA.DESCRIBE.EHARDHAT = "I ain't a construction worker, but it sure doesn't hurt to wear!"
GLOBAL.STRINGS.CHARACTERS.WORTOX.DESCRIBE.EHARDHAT = "I hope I don't get helmet horns."
GLOBAL.STRINGS.CHARACTERS.WORMWOOD.DESCRIBE.EHARDHAT = "Hard head thing"
GLOBAL.STRINGS.CHARACTERS.WARLY.DESCRIBE.EHARDHAT = "I do believe it's my lunch break."
GLOBAL.STRINGS.CHARACTERS.WURT.DESCRIBE.EHARDHAT = "Head fins!"
GLOBAL.STRINGS.CHARACTERS.WALTER.DESCRIBE.EHARDHAT = "Safety! Can I get an extra small one for Woby?"
GLOBAL.STRINGS.CHARACTERS.WANDA.DESCRIBE.EHARDHAT = "You'll never know how many bits of rubble want to greet your skull on any given day."
if GLOBAL.STRINGS.CHARACTERS.MEDIC then
GLOBAL.STRINGS.CHARACTERS.MEDIC.DESCRIBE.EHARDHAT = "Protection! For your head! Fascinating!"
end

--Gibus
GLOBAL.STRINGS.NAMES.GIBUS = "Ghostly Gibus"
GLOBAL.STRINGS.RECIPE_DESC.GIBUS = "Not the classiest hat of all."
GLOBAL.STRINGS.CHARACTERS.GENERIC.DESCRIBE.GIBUS = "What a weird hat."
GLOBAL.STRINGS.CHARACTERS.WILLOW.DESCRIBE.GIBUS = "It smells like silk and incompetence. Burn time!"
GLOBAL.STRINGS.CHARACTERS.WOLFGANG.DESCRIBE.GIBUS = "Is torn."
GLOBAL.STRINGS.CHARACTERS.WENDY.DESCRIBE.GIBUS = "Its constant use has worn it down to mere strings."
GLOBAL.STRINGS.CHARACTERS.WX78.DESCRIBE.GIBUS = "NOT SOPHISTICATED"
GLOBAL.STRINGS.CHARACTERS.WICKERBOTTOM.DESCRIBE.GIBUS = "The open top isn't the best choice of design."
GLOBAL.STRINGS.CHARACTERS.WOODIE.DESCRIBE.GIBUS = "This hat is a bust."
GLOBAL.STRINGS.CHARACTERS.WAXWELL.DESCRIBE.GIBUS = "Fit for the dead."
GLOBAL.STRINGS.CHARACTERS.WATHGRITHR.DESCRIBE.GIBUS = "This does not match my costume."
GLOBAL.STRINGS.CHARACTERS.WEBBER.DESCRIBE.GIBUS = "It's all used."
GLOBAL.STRINGS.CHARACTERS.WINONA.DESCRIBE.GIBUS = "Smells like it's past its best by date!"
GLOBAL.STRINGS.CHARACTERS.WORTOX.DESCRIBE.GIBUS = "Old, old yet no mold to behold!"
GLOBAL.STRINGS.CHARACTERS.WORMWOOD.DESCRIBE.GIBUS = "Old head thing"
GLOBAL.STRINGS.CHARACTERS.WURT.DESCRIBE.GIBUS = "Glorp, makes me feel smarter!"
GLOBAL.STRINGS.CHARACTERS.WARLY.DESCRIBE.GIBUS = "It's seen more dapper days."
GLOBAL.STRINGS.CHARACTERS.WALTER.DESCRIBE.GIBUS = "I didn't know dust bunnies were so dapper!"
GLOBAL.STRINGS.CHARACTERS.WANDA.DESCRIBE.GIBUS = "I don't think stepping back in time would do this hat any favors."

--Teleporting strings
GLOBAL.STRINGS.CHARACTERS.GENERIC.ANNOUNCE_ENGIE_TELEPORT = {"Thanks for the teleporter!","Impressive work, Engineer!","I'm back!"}
GLOBAL.STRINGS.CHARACTERS.WILLOW.ANNOUNCE_ENGIE_TELEPORT = {"Ha! Thanks, Engineer!","Nice! There should've been more fire and flames though.","Like a phoenix! Cool!"}
GLOBAL.STRINGS.CHARACTERS.WOLFGANG.ANNOUNCE_ENGIE_TELEPORT = {"Wolfgang love tiny egg-head man!","Wolfgang is dizzy."}
GLOBAL.STRINGS.CHARACTERS.WENDY.ANNOUNCE_ENGIE_TELEPORT = {"I am reborn.","I have been brought back into this world, sadly."}
GLOBAL.STRINGS.CHARACTERS.WX78.ANNOUNCE_ENGIE_TELEPORT = {"RELOCATION SUCCESSFUL.","ALTERNATE DESTINATION ACHIEVED. PROCEED WITH APPLAUSE."}
GLOBAL.STRINGS.CHARACTERS.WICKERBOTTOM.ANNOUNCE_ENGIE_TELEPORT = {"I appreciate the transportation, Engineer.","Thank you for the transportation, Engineer."}
GLOBAL.STRINGS.CHARACTERS.WOODIE.ANNOUNCE_ENGIE_TELEPORT = {"Hoo, thanks for the crazy trip, builder man!","Woo, faster than a toronto streetcar!"}
GLOBAL.STRINGS.CHARACTERS.WAXWELL.ANNOUNCE_ENGIE_TELEPORT = {"Good work, construction worker.","You've done me well, construction worker."}
GLOBAL.STRINGS.CHARACTERS.WATHGRITHR.ANNOUNCE_ENGIE_TELEPORT = {"Back into the fray!","The curtains open once more!","I've returned! I'm glad to have the Engineer by my side!"}
GLOBAL.STRINGS.CHARACTERS.WEBBER.ANNOUNCE_ENGIE_TELEPORT = {"Woah! Now we're dizzy!","Haha! Again!","We can't believe it! Thank you Mr.Engineer!"}
GLOBAL.STRINGS.CHARACTERS.WINONA.ANNOUNCE_ENGIE_TELEPORT = {"Mighty fine work there, Hardhat!","I gotta learn up these machines of yours, Hardhat!","Good engineerin' here!"}
GLOBAL.STRINGS.CHARACTERS.WORTOX.ANNOUNCE_ENGIE_TELEPORT = {"Never fear, the imp is here!","I hope all my bits and bobs came with, hyuyu!","Back in pieces!"}
GLOBAL.STRINGS.CHARACTERS.WORMWOOD.ANNOUNCE_ENGIE_TELEPORT = {"Made it!","Back","Grown?"}
GLOBAL.STRINGS.CHARACTERS.WARLY.ANNOUNCE_ENGIE_TELEPORT = {"Thank you for the easy access route!","My head's spinning! Might I still have it?","My molecules feel whisked like a fine batter."}
GLOBAL.STRINGS.CHARACTERS.WURT.ANNOUNCE_ENGIE_TELEPORT = {"Glorp... felt weird!","Wheeeeee!"}
GLOBAL.STRINGS.CHARACTERS.WALTER.ANNOUNCE_ENGIE_TELEPORT = {"Am I still the same person...?","That definitely was something... magical.","I bet you Woby and I could've hiked all the way here ten times faster!"}
GLOBAL.STRINGS.CHARACTERS.WANDA.ANNOUNCE_ENGIE_TELEPORT = {"A bit clunky, but any time saved is a gift. Keep working at it.","I've jumped through time and space enough to be used to this sort of thing."}
        if GLOBAL.STRINGS.CHARACTERS.MEDIC then
GLOBAL.STRINGS.CHARACTERS.MEDIC.ANNOUNCE_ENGIE_TELEPORT = {"Danke, mein hard-hatted friend!","Danke, Engineer!"}
end
        if GLOBAL.STRINGS.CHARACTERS.SPY then
GLOBAL.STRINGS.CHARACTERS.SPY.ANNOUNCE_ENGIE_TELEPORT = "Thank you, laborer!"
end
        if GLOBAL.STRINGS.CHARACTERS.ENGINEER then
GLOBAL.STRINGS.CHARACTERS.ENGINEER.ANNOUNCE_ENGIE_TELEPORT = {"Much obliged, pardner!","Thanks for the ride, pardner."}
end
        if GLOBAL.STRINGS.CHARACTERS.TF2SCOUT then
GLOBAL.STRINGS.CHARACTERS.TF2SCOUT.ANNOUNCE_ENGIE_TELEPORT = {"Hey good job there, hardhat!","Thanks for that, tough guy!","Thanks for the ride!"}
end
        if GLOBAL.STRINGS.CHARACTERS.DEMOMAN then
GLOBAL.STRINGS.CHARACTERS.DEMOMAN.ANNOUNCE_ENGIE_TELEPORT = "Woooo! Wooh... What?"
end
        if GLOBAL.STRINGS.CHARACTERS.TF2SOLDIER then
GLOBAL.STRINGS.CHARACTERS.TF2SOLDIER.ANNOUNCE_ENGIE_TELEPORT = "Thanks, Engie."
end

GLOBAL.STRINGS.CHARACTERS.GENERIC.DESCRIBE.ENGINEER = 
{
	GENERIC = "Greetings, %s!",
	ATTACKER = "%s is holding that wrench pretty tightly...",
	MURDERER = "Murderer!",
	REVIVER = "%s, always there to support.",
	GHOST = "Better concoct a revival device. Can't leave another man of science floating.",
	FIRESTARTER = "Burning that wasn't very scientific, %s.",
}
GLOBAL.STRINGS.CHARACTERS.WILLOW.DESCRIBE.ENGINEER = 
{
	GENERIC = "Hi, %s!",
	ATTACKER = "Your goggles fogged, %s?",
	MURDERER = "Burn! Both you and your machines!",
	REVIVER = "%s won't leave anyone behind!",
	GHOST = "I better get a heart for %s.",
	FIRESTARTER = "%s! That's a good start, but now build a fire machine!",
}
GLOBAL.STRINGS.CHARACTERS.WOLFGANG.DESCRIBE.ENGINEER = 
{
	GENERIC = "Is tiny egghead-man, %s! Hello!",
	ATTACKER = "Does weak builder man want to fight?",
	MURDERER = "%s is killer!",
	REVIVER = "%s smell like oil and kindness.",
	GHOST = "Ha ha! Big shooter did not save you. I will go get heart.",
	FIRESTARTER = "%s is lighting burny fires!",
}
GLOBAL.STRINGS.CHARACTERS.WENDY.DESCRIBE.ENGINEER = 
{
	GENERIC = "How do you do, %s?",
	ATTACKER = "%s's machines are not to be trusted.",
	MURDERER = "I'll send you some place much nicer than this, %s.",
	REVIVER = "Abigail likes you, %s.",
	GHOST = "Did one of your machines turn on you? ...I'll get a heart.",
	FIRESTARTER = "Are you building a new fire-related machine, %s?",
}
GLOBAL.STRINGS.CHARACTERS.WX78.DESCRIBE.ENGINEER = 
{
	GENERIC = "DETECTING... %s!",
	ATTACKER = "I WILL RECLAIM MY FAMILY FROM YOUR MEATY HANDS, %s!",
	MURDERER = "YOUR MEATBRAIN IS OBSOLETE, %s! DIE!",
	REVIVER = "THIS DOES NOT MAKE UP FOR HOGGING MY FAMILY, %s",
	GHOST = "WHERE ARE YOUR METAL PROTECTION UNITS NOW, %s? HA. HA.",
	FIRESTARTER = "NEEDLESS DESTRUCTION? CHECK. HOMEWRECKER? CHECK.",
}
GLOBAL.STRINGS.CHARACTERS.WICKERBOTTOM.DESCRIBE.ENGINEER = 
{
	GENERIC = "Ah, greetings dear %s!",
	ATTACKER = "Don't go building up trouble, %s!",
	MURDERER = "Let's see whose brains comes out on top, %s!",
	REVIVER = "Building up trust, %s.",
	GHOST = "%s, those metal parts can be sharp. Let me get the hearts.",
	FIRESTARTER = "Are you burning metal, %s? I hope you know what you are doing.",
}
GLOBAL.STRINGS.CHARACTERS.WOODIE.DESCRIBE.ENGINEER = 
{
	GENERIC = "It's my builder buddy, %s!",
	ATTACKER = "%s could be a bit more considerate...",
	MURDERER = "This is gonna be a clear cut!",
	REVIVER = "That's some good work ya did, %s.",
	GHOST = "You know where I can get a heart, %s?",
	FIRESTARTER = "As long as you keep burning metal and not wood, we're good.",
}
GLOBAL.STRINGS.CHARACTERS.WAXWELL.DESCRIBE.ENGINEER = 
{
	GENERIC = "Good day to you, Mr %s.",
	ATTACKER = "%s is preparing his machinery...",
	MURDERER = "Do not start fights you cannot win single-handedly!",
	REVIVER = "%s has excellent command of construction.",
	GHOST = "Do you desire a heart, %s?",
	FIRESTARTER = "I feel as if construction does not involve burning your creations down.",
}
GLOBAL.STRINGS.CHARACTERS.WATHGRITHR.DESCRIBE.ENGINEER = 
{
	GENERIC = "Wisdom and construction guide you, %s!",
	ATTACKER = "Your honor wavers, %s.",
	MURDERER = "%s! Let us settle this in battle!",
	REVIVER = "%s protects our people.",
	GHOST = "A heart shall wrench %s back from the jaws of death!",
	FIRESTARTER = "I'll not question your process, %s.",
}
GLOBAL.STRINGS.CHARACTERS.WEBBER.DESCRIBE.ENGINEER = 
{
	GENERIC = "Hi %s! Have you been polishing your helmet?",
	ATTACKER = "Why are you being so mean, %s?",
	MURDERER = "We won't let you hurt our friends!",
	REVIVER = "%s is very smart and likes to build cool stuff!",
	GHOST = "Don't worry %s, we'll get you a heart!",
	FIRESTARTER = "Um. I think you lit a fire, %s.",
}
GLOBAL.STRINGS.CHARACTERS.WINONA.DESCRIBE.ENGINEER = 
{
	GENERIC = "Good ta see ya, %s! How's your machines coming along?",
	ATTACKER = "Watch those machines! I'm sure nobody wants to catch those bullets of yours!",
	MURDERER = "Keep watch! They're using their machines for killin'!",
	REVIVER = "Honored to be workin' among your machines, %s! How do ya do it?",
	GHOST = "You and your contraptions put up a heck of a fight, %s!",
	FIRESTARTER = "I'm not liking that fire starting, %s. With your work it'll only lead to disaster.",
}
GLOBAL.STRINGS.CHARACTERS.WORTOX.DESCRIBE.ENGINEER = 
{
    GENERIC = "Your machines tell such funny jokes, %s!",
    ATTACKER = "I didn't mess with your machines, hyuyu! Promise!",
    MURDERER = "Eep! Don't have me bite the bullet!",
    REVIVER = "Hoohoo! %s builds helping hands for souls!",
    GHOST = "Just a nibble? Your machines don't have souls to nibble!",
    FIRESTARTER = "Ooo, you make such funny pranks!",
}
GLOBAL.STRINGS.CHARACTERS.WORMWOOD.DESCRIBE.ENGINEER = 
{
	GENERIC = "%s is good Maker",
	ATTACKER = "No! Hurt too much!",
	MURDERER = "Aggh! %s is a dead maker!",
	REVIVER = "%s is good Floaty Friend fixer",
	GHOST = "Like floating, %s?",
	FIRESTARTER = "%s, too much fire!",
}
GLOBAL.STRINGS.CHARACTERS.WARLY.DESCRIBE.ENGINEER = 
{
	GENERIC = "Salut, %s!",
	ATTACKER = "I'd prefer you and your machines simmer down like a nice soup, %s.",
	MURDERER = "Your profession is very, very cruel.",
	REVIVER = "I admire %s's dedication to securing the camp through any means.",
	GHOST = "Let's fix you up like you do your machines, non?",
	FIRESTARTER = "I know very well your machines didn't light that fire, %s.",
}
GLOBAL.STRINGS.CHARACTERS.WURT.DESCRIBE.ENGINEER = 
{
    GENERIC = "Hello short goggles man!",
    ATTACKER = "Ow! That not safe!",
    MURDERER = "You broke trust!!",
    REVIVER = "All fixed up!",
    GHOST = "Machine boxes fought back, flort.",
    FIRESTARTER = "Maybe he making stuff that uses fire?",
}
GLOBAL.STRINGS.CHARACTERS.WALTER.DESCRIBE.ENGINEER = 
{
	GENERIC = "Hey Mr. %s!",
	ATTACKER = "I'm not sure we should be trusting Mr. %s's machines...",
	MURDERER = "I think we all saw that coming, %s. Creativity next time!",
	REVIVER = "Thanks for fixing us up, Mr. %s!",
	GHOST = "We'll get you a heart as fast as you can teleport! Okay, maybe not as fast.",
	FIRESTARTER = "You're gonna light the camp on fire Mr. %s!",
}
GLOBAL.STRINGS.CHARACTERS.WANDA.DESCRIBE.ENGINEER = 
{
	GENERIC = "You know how it is, %s. Places to go, pieces to repair.",
	ATTACKER = "Hold on now, there's still time to fix your mistakes!",
	MURDERER = "This must be the timeline where I'm on the opposing team.",
	REVIVER = "There's no denying it, %s, you're quite good at fixing what's broken.",
	GHOST = "I figure you'll be quite pleased to learn about what my own gadgets do!",
	FIRESTARTER = "You weren't so fire-prone last I remembered you.",
}
--SWC
if GLOBAL.STRINGS.CHARACTERS.WALANI then
GLOBAL.STRINGS.CHARACTERS.WALANI.DESCRIBE.ENGINEER = 
{
	        GENERIC = "How ya doin', %s? Built any do-the-work-for-me machines?",
	        ATTACKER = "Your head's running hotter than your machines, guy.",
	        MURDERER = "Stay back! You only defend yourself! Not cool!",
	        REVIVER = "%s has his own brand of chill.",
	        GHOST = "You totally rag-dolled out there. You got any machines for post-wipeouts?",
	        FIRESTARTER = "Dude's got some serious firepower.",
}
GLOBAL.STRINGS.CHARACTERS.WALANI.ANNOUNCE_ENGIE_TELEPORT = {"Oh, sweet! Mahalo!","Oh man. I'll never need to walk again!","Surfing through those electronic waves!","Thanks, engie-bud."}

GLOBAL.STRINGS.CHARACTERS.WALANI.DESCRIBE.ESENTRY = "Don't go shooting at me, bullet box."
GLOBAL.STRINGS.CHARACTERS.WALANI.DESCRIBE.ETELEPORTER = "It shows me places I never knew I could see."
GLOBAL.STRINGS.CHARACTERS.WALANI.DESCRIBE.ETELEPORTER_EXIT = "I hope none of my particles got lost on the way here."
GLOBAL.STRINGS.CHARACTERS.WALANI.DESCRIBE.TF2WRENCH = "Building things is way too much busywork."
GLOBAL.STRINGS.CHARACTERS.WALANI.DESCRIBE.GIBUS = "That's a pretty dusty hat."
GLOBAL.STRINGS.CHARACTERS.WALANI.DESCRIBE.EHARDHAT = "If I put this on people will expect me to build things or something."
GLOBAL.STRINGS.CHARACTERS.WALANI.DESCRIBE.SCRAP = "A lil' pile of junk bits."
GLOBAL.STRINGS.CHARACTERS.WALANI.DESCRIBE.DISPENSER = "All the good vibes of balanced chakras in a box."
GLOBAL.STRINGS.CHARACTERS.WALANI.DESCRIBE.DESTRUCTIONPDA = "I've always wanted a button that fixes all my mistakes."

end
if GLOBAL.STRINGS.CHARACTERS.WOODLEGS then
GLOBAL.STRINGS.CHARACTERS.WOODLEGS.DESCRIBE.ENGINEER = 
{
	        GENERIC = "Ahoy, ye machinist!",
	        ATTACKER = "Don't go pointin' yer cannons at me mates, %s.",
	        MURDERER = "Arrr! Ye dare challenge ol'Woodlegs ta a cannon'n'gun duel?",
	        REVIVER = "Ye got a toolbox o'gold, an' I be wantin' it! Trade ye fer a spot'o'rum?",
	        GHOST = "Them fancy guns ain't be savin' ye t'day!",
	        FIRESTARTER = "Keep yer cannons away from me pegs!",
}
GLOBAL.STRINGS.CHARACTERS.WOODLEGS.ANNOUNCE_ENGIE_TELEPORT = {"Yarr! I's be back!","Arr... take me ta sea or take me life!","Take me back t'sea!" }

GLOBAL.STRINGS.CHARACTERS.WOODLEGS.DESCRIBE.ESENTRY = "Ye arrren't guardin' any treasure arr ye?"
GLOBAL.STRINGS.CHARACTERS.WOODLEGS.DESCRIBE.DISPENSER = "This be a treasure box o'healin'!"
GLOBAL.STRINGS.CHARACTERS.WOODLEGS.DESCRIBE.ETELEPORTER = "I prefer a fast ship and th'wind at me back."
GLOBAL.STRINGS.CHARACTERS.WOODLEGS.DESCRIBE.ETELEPORTER_EXIT = "Me ship would'a put'cha outta service!"
GLOBAL.STRINGS.CHARACTERS.WOODLEGS.DESCRIBE.TF2WRENCH = "This ain't be proper ship buildin' tools!"
GLOBAL.STRINGS.CHARACTERS.WOODLEGS.DESCRIBE.GIBUS = "This be a ghostly cap o'leather!"
GLOBAL.STRINGS.CHARACTERS.WOODLEGS.DESCRIBE.EHARDHAT = "Knocks 'ard on ye noggin'."
GLOBAL.STRINGS.CHARACTERS.WOODLEGS.DESCRIBE.SCRAP = "Just a pile o'metal."
GLOBAL.STRINGS.CHARACTERS.WOODLEGS.DESCRIBE.DESTRUCTIONPDA = "Bah! Th'lubbers done away wit' cannon sticks and be pressin' buttons!"

end
--MODDED
if GLOBAL.STRINGS.CHARACTERS.WEARGER then
GLOBAL.STRINGS.CHARACTERS.WEARGER.DESCRIBE.ENGINEER = 
{
            GENERIC = "You are... %s?",
            ATTACKER = "Grrrrr. %s is coming too close to my food.",
            MURDERER = "GRAAAAAHH!! ATTACK %s!!",
            REVIVER = "%s knows what to make for hibernating.",
            GHOST = "Not strong enough to survive. %s.",
            FIRESTARTER = "%s smells like... (sniff) fire.",
}
GLOBAL.STRINGS.CHARACTERS.WEARGER.ANNOUNCE_ENGIE_TELEPORT = {"Now... here.","Any honey over here?"}
GLOBAL.STRINGS.CHARACTERS.WEARGER.DESCRIBE.GIBUS = "Making my nose itch."
GLOBAL.STRINGS.CHARACTERS.WEARGER.DESCRIBE.EHARDHAT = "Head is stronger this way."
GLOBAL.STRINGS.CHARACTERS.WEARGER.DESCRIBE.TF2WRENCH = "Not sure how to fix things."
GLOBAL.STRINGS.CHARACTERS.WEARGER.DESCRIBE.ESENTRY = "Grrrr... Not to trust."
GLOBAL.STRINGS.CHARACTERS.WEARGER.DESCRIBE.ETELEPORTER = "Charge through!"
GLOBAL.STRINGS.CHARACTERS.WEARGER.DESCRIBE.ETELEPORTER_EXIT = "No memory of this place."
GLOBAL.STRINGS.CHARACTERS.WEARGER.DESCRIBE.DISPENSER = "Must be nice to hibernate under."
GLOBAL.STRINGS.CHARACTERS.WEARGER.DESCRIBE.SCRAP = "(sniff sniff) No berries."
GLOBAL.STRINGS.CHARACTERS.WEARGER.DESCRIBE.DESTRUCTIONPDA = "Not for me to sniff."

end

if GLOBAL.STRINGS.CHARACTERS.WEERCLOPS then
GLOBAL.STRINGS.CHARACTERS.WEERCLOPS.DESCRIBE.ENGINEER = 
{
            GENERIC = "%s...",
            ATTACKER = "%s is looking to demolish.",
            MURDERER = "%s knows how to tear buildings down.",
            REVIVER = "%s breaks buildings... but builds them back up? Rrk.",
            GHOST = "You were the one demolished this time around...",
            FIRESTARTER = "%s knows how to throw down. With fire, not claws...",
}
GLOBAL.STRINGS.CHARACTERS.WEERCLOPS.ANNOUNCE_ENGIE_TELEPORT = {"I will destroy what's here.","I've come to destroy your walls."}
GLOBAL.STRINGS.CHARACTERS.WEERCLOPS.DESCRIBE.GIBUS = "This hat was already stomped on..."
GLOBAL.STRINGS.CHARACTERS.WEERCLOPS.DESCRIBE.EHARDHAT = "Does it work for destruction too...?"
GLOBAL.STRINGS.CHARACTERS.WEERCLOPS.DESCRIBE.TF2WRENCH = "I'll use it to destroy. That will show you."
GLOBAL.STRINGS.CHARACTERS.WEERCLOPS.DESCRIBE.ESENTRY = "Destructive."
GLOBAL.STRINGS.CHARACTERS.WEERCLOPS.DESCRIBE.ETELEPORTER = "There's always more places to ruin."
GLOBAL.STRINGS.CHARACTERS.WEERCLOPS.DESCRIBE.ETELEPORTER_EXIT = "I'll leave trails of rubble."
GLOBAL.STRINGS.CHARACTERS.WEERCLOPS.DESCRIBE.DISPENSER = "That hum. I have to destroy it."
GLOBAL.STRINGS.CHARACTERS.WEERCLOPS.DESCRIBE.SCRAP = "Already broken. Not fun."
GLOBAL.STRINGS.CHARACTERS.WEERCLOPS.DESCRIBE.DESTRUCTIONPDA = "Rrrrr! My claws are your creations only thing to fear!"

end

if GLOBAL.STRINGS.CHARACTERS.WOOSE then
GLOBAL.STRINGS.CHARACTERS.WOOSE.DESCRIBE.ENGINEER = 
{
            GENERIC = "Yee-Honk! %s!",
            ATTACKER = "You defend the nest! But from Momma!!",
            MURDERER = "The nest we build together, Moose will have to destroy it!!",
            REVIVER = "%s does wonders for the nest!",
            GHOST = "Don't fall from the nest! Hynk!",
            FIRESTARTER = "Fire! What type of nests do you build? HOnk!",
}
GLOBAL.STRINGS.CHARACTERS.WOOSE.ANNOUNCE_ENGIE_TELEPORT = {"Momma's back with her feathers!","Never fear! Mother is here!"}
GLOBAL.STRINGS.CHARACTERS.WOOSE.DESCRIBE.GIBUS = {"How does Moose look?","How does Goose look?"}
GLOBAL.STRINGS.CHARACTERS.WOOSE.DESCRIBE.EHARDHAT = "New pair of antlers!"
GLOBAL.STRINGS.CHARACTERS.WOOSE.DESCRIBE.TF2WRENCH = "HNK! Does it work for nests?"
GLOBAL.STRINGS.CHARACTERS.WOOSE.DESCRIBE.ESENTRY = "Mother to all bullets! Hynk!"
GLOBAL.STRINGS.CHARACTERS.WOOSE.DESCRIBE.ETELEPORTER = {"Moose enters!","Goose enters!"}
GLOBAL.STRINGS.CHARACTERS.WOOSE.DESCRIBE.ETELEPORTER_EXIT = {"Goose exits!","Moose exits!"}
GLOBAL.STRINGS.CHARACTERS.WOOSE.DESCRIBE.DISPENSER = "How much can you fit into this nest? HONK!"
GLOBAL.STRINGS.CHARACTERS.WOOSE.DESCRIBE.SCRAP = "Not good nesting parts!"
GLOBAL.STRINGS.CHARACTERS.WOOSE.DESCRIBE.DESTRUCTIONPDA = "Make more room for nests! HONK!"

end

if GLOBAL.STRINGS.CHARACTERS.WRAGONFLY then
GLOBAL.STRINGS.CHARACTERS.WRAGONFLY.DESCRIBE.ENGINEER = 
{
            GENERIC = "Hear-ye goggled machinist! I desire a polishing of my metals!",
            ATTACKER = "Your blue-printed schemes are at an end...!",
            MURDERER = "Away from my hoard, my precious metals do not belong to you!",
            REVIVER = "Perhaps a heart of gold, but who is to say thy machines shalt ever come to thine aid?",
            GHOST = "Thou metals are now forfeit to my hoard! Bzrt!",
            FIRESTARTER = "Art those the welding sparks thou desire?",
}
GLOBAL.STRINGS.CHARACTERS.WRAGONFLY.ANNOUNCE_ENGIE_TELEPORT = {"Now, when do the luxurious carpets unravel before my feet?"}
GLOBAL.STRINGS.CHARACTERS.WRAGONFLY.DESCRIBE.GIBUS = "Pitiable!"
GLOBAL.STRINGS.CHARACTERS.WRAGONFLY.DESCRIBE.EHARDHAT = "You make a mockery of gold's color!"
GLOBAL.STRINGS.CHARACTERS.WRAGONFLY.DESCRIBE.TF2WRENCH = "No tool of mine, but one of a fool!"
GLOBAL.STRINGS.CHARACTERS.WRAGONFLY.DESCRIBE.ESENTRY = "It could do with a bedazzling."
GLOBAL.STRINGS.CHARACTERS.WRAGONFLY.DESCRIBE.ETELEPORTER = "I'll enter it...not that I couldn't fly my way there!"
GLOBAL.STRINGS.CHARACTERS.WRAGONFLY.DESCRIBE.ETELEPORTER_EXIT = "Make way, for thy queen hast arrived!"
GLOBAL.STRINGS.CHARACTERS.WRAGONFLY.DESCRIBE.DISPENSER = "Bzrt! It shall make a perfect pillow!"
GLOBAL.STRINGS.CHARACTERS.WRAGONFLY.DESCRIBE.SCRAP = "I'm a dragonfly of exquisite tastes in metal! This is not one of them."
GLOBAL.STRINGS.CHARACTERS.WRAGONFLY.DESCRIBE.DESTRUCTIONPDA = "Watch as thy metal servants crumble before thou!"

end

if GLOBAL.STRINGS.CHARACTERS.DEMOMAN then
GLOBAL.STRINGS.CHARACTERS.DEMOMAN.DESCRIBE.ENGINEER = 
{
	GENERIC = "%s! Ya bloody toy maker!",
	ATTACKER = "That %s is a bloody traitor!",
	MURDERER = "Cold-blooded murderer!",
	REVIVER = "%s, I didn't need yer help, you know.",
	GHOST = "You're weak. I'm strong. and I win, toymaker!",
	FIRESTARTER = "If you were huntin' trouble, lad, ya found it.",
}
GLOBAL.STRINGS.CHARACTERS.DEMOMAN.DESCRIBE.GIBUS = "Cast your eyes on this!"
GLOBAL.STRINGS.CHARACTERS.DEMOMAN.DESCRIBE.EHARDHAT = "Aye, that's hefty."
GLOBAL.STRINGS.CHARACTERS.DEMOMAN.DESCRIBE.TF2WRENCH = "You come wide at me again, boy, I'll stick this wrench right up yer arse!"
GLOBAL.STRINGS.CHARACTERS.DEMOMAN.DESCRIBE.ETELEPORTER_EXIT = "Aye! Thanks fer the trip, lad."
GLOBAL.STRINGS.CHARACTERS.DEMOMAN.DESCRIBE.ESENTRY = "Go on and build more o' yer lil guns. I'll shove every one of them up yer arse!"
GLOBAL.STRINGS.CHARACTERS.DEMOMAN.DESCRIBE.ETELEPORTER = "Move it, lads!"
GLOBAL.STRINGS.CHARACTERS.DEMOMAN.DESCRIBE.DISPENSER = "That's a right pretty bra-washer ya built, ya big ugly girl!"
GLOBAL.STRINGS.CHARACTERS.DEMOMAN.DESCRIBE.SCRAP = "Now that's junk!"
end
if GLOBAL.STRINGS.CHARACTERS.TF2SOLDIER then
GLOBAL.STRINGS.CHARACTERS.TF2SOLDIER.DESCRIBE.ENGINEER = 
{
	GENERIC = "%s!",
	ATTACKER = "Stop hiding behind your little toys and fight like a man!",
	MURDERER = "I will eat your ribs, I will eat them up!",
	REVIVER = "You have served me well, Engie.",
	GHOST = "That's where books get you, professor!",
	FIRESTARTER = "Go back to Calgary, ya cow-herdin' fire-startin' Canadian!",
}
GLOBAL.STRINGS.CHARACTERS.TF2SOLDIER.DESCRIBE.GIBUS = "Do you call that a hat? That is a pile of nonsense!"
GLOBAL.STRINGS.CHARACTERS.TF2SOLDIER.DESCRIBE.EHARDHAT = "Get this crap out of my face!"
GLOBAL.STRINGS.CHARACTERS.TF2SOLDIER.DESCRIBE.TF2WRENCH = "You have lost your tools, grease monkey!"
GLOBAL.STRINGS.CHARACTERS.TF2SOLDIER.DESCRIBE.ETELEPORTER_EXIT = "To the front!"
GLOBAL.STRINGS.CHARACTERS.TF2SOLDIER.DESCRIBE.ESENTRY = "Stop hiding behind your little toys and fight like a man!"
GLOBAL.STRINGS.CHARACTERS.TF2SOLDIER.DESCRIBE.ETELEPORTER = "Move out!"
GLOBAL.STRINGS.CHARACTERS.TF2SOLDIER.DESCRIBE.DISPENSER = "I am healed now!"
GLOBAL.STRINGS.CHARACTERS.TF2SOLDIER.DESCRIBE.SCRAP = "This is mine now!"
end