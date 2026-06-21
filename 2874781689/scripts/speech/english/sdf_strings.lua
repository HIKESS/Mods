local G	  = GLOBAL
local S   = G.STRINGS
local A	  = G.ACTIONS
local N   = S.NAMES
local C   = S.CHARACTERS
local R   = S.RECIPE_DESC
local T   = S.TABS
local CN  = S.CHARACTER_NAMES
local CT  = S.CHARACTER_TITLES
local CS  = S.CHARACTER_SURVIVABILITY
local CQ  = S.CHARACTER_QUOTES
local CD  = S.CHARACTER_DESCRIPTIONS
local SA  = S.ACTIONS

local Wilson  		= C.GENERIC.DESCRIBE
local Willow  		= C.WILLOW.DESCRIBE
local Wolfgang  	= C.WOLFGANG.DESCRIBE
local Wendy  		= C.WENDY.DESCRIBE
local WX78  		= C.WX78.DESCRIBE
local Wickerbottom      = C.WICKERBOTTOM.DESCRIBE
local Woodie  		= C.WOODIE.DESCRIBE
local Maxwell  		= C.WAXWELL.DESCRIBE
local Wigfrid 		= C.WATHGRITHR.DESCRIBE
local Webber 		= C.WEBBER.DESCRIBE
local require 		= G.require

--Character names, titles, survivability, quotes, etc.
CN.sdf = "Sdf"
CT.sdf = "Hero of Gallowmere"
CS.sdf = "Fell by the first arrow"
CQ.sdf = "\"Gulp!\""
CD.sdf = "*Seek out Chalice of Souls for Hall of Heroes rewards!\n*Find Life Bottles to increase health.\n*Equip many useful weapons, shields and armors."
C.SDF = require "speech/english/speech_sdf"


--Special Actions
SA.CASTAOE.SDF_DRAGON_POTION_DRAGONBREATH = "Breathe Fire"
SA.CASTAOE.SDF_HAMMER = "Shockwave"
SA.CASTAOE.SDF_CLUB = "Enflame"
SA.CASTAOE.SDF_LIGHTNING_GAUNTLET  = "Charged Overload"
SA.CASTAOE.SDF_BLUNDERBUSS = "Bombard"
SA.CASTAOE.SDF_ANUBIS_STONE  = "Reanimate"
SA.CASTAOE.SDF_ASGARD_GOLEM_GIANTS_OCARINA  = "Awaken Giant"
SA.CASTSPELL.SDF_ARM_THROW = "Throw Arm"
SA.CASTSPELL.SDF_AXE_THROW = "Throw Axe"
--SA.CASTSPELL.SDF_TRIDENT_THROW = "Impale"
SA.CASTSPELL.SDF_THROWING_DAGGERS_POWER_ATTACK = "Knife Juggle"
SA.CASTSPELL.SDF_CROSSBOW_POWER_ATTACK = "Rapid Fire"
SA.CASTSPELL.SDF_FLAMING_CROSSBOW_POWER_ATTACK = "Crossfire"
SA.CASTSPELL.SDF_LONGBOW_POWER_ATTACK = "Deadeye"
SA.CASTSPELL.SDF_FLAMING_LONGBOW_POWER_ATTACK = "Incendiary"
SA.CASTSPELL.SDF_MAGIC_LONGBOW_POWER_ATTACK = "Miasma"
SA.CASTSPELL.SDF_SPEAR_POWER_ATTACK = "Sunder Armor"
SA.CASTSPELL.SDF_PISTOL_POWER_ATTACK = "Quick Draw"
SA.CASTSPELL.SDF_KING_PEREGRINS_CROWN_CALLTOARMS = "Call To Arms"
SA.CASTSPELL.SDF_ANUBIS_STONE_NECROHEAL = "Necrotic Heal"

--ActionHandler Actions
S.ACTIONHANDLER_SDF_SHIELD_PARRY = "Guard"
S.ACTIONHANDLER_SDF_DARING_DASH = "Daring Dash"
S.ACTIONHANDLER_SDF_DRAGON_POTION_IMBUE = "Imbue"
S.ACTIONHANDLER_SDF_WODENS_BRAND_GORGE = "Gorge"
S.ACTIONHANDLER_SDF_GATLING_GUN_BARRAGE = "Barrage"
S.ACTIONHANDLER_SDF_GALLOWMERE_KNIGHT_COMMAND_STAY = "Order to Stand Guard"
S.ACTIONHANDLER_SDF_GALLOWMERE_KNIGHT_COMMAND_FOLLOW = "Order to Follow"
S.ACTIONHANDLER_SDF_LIGHTNING_GAUNTLET_TRANSFER = "Transfer"
S.ACTIONHANDLER_SDF_RUNESTONE_OFFERING = "Offer Chalice of Souls"
S.ACTIONHANDLER_SDF_SOUL_HELMET_OFFERING = "Ferry Lost Soul"
S.ACTIONHANDLER_SDF_SOUL_HELMET_OFFERING_GREED = "Greed"
S.ACTIONHANDLER_SDF_WITCH_TALISMAN_OFFERING_CHALICE_ALTAR = "Reconstitute Chalice Altar"
S.ACTIONHANDLER_SDF_WITCH_TALISMAN_OFFERING_GOLD_ARMOR = "Fabricate Golden Armor"
S.ACTIONHANDLER_SDF_WITCH_TALISMAN_OFFERING_GOLD_SHIELD = "Sticky Fingered Deal"
S.ACTIONHANDLER_SDF_WITCH_TALISMAN_OFFERING_HELMET = "Ruminate"
S.ACTIONHANDLER_SDF_WITCH_TALISMAN_OFFERING_KING_PEREGRINS_CROWN_LOST = "Ruminate"
S.ACTIONHANDLER_SDF_WITCH_TALISMAN_OFFERING_KING_PEREGRINS_CROWN = "Ruminate"
S.ACTIONHANDLER_SDF_WITCH_TALISMAN_OFFERING_SHADOW_TALISMAN = "Ruminate"
S.ACTIONHANDLER_SDF_WITCH_TALISMAN_OFFERING_DRAGON_POTION = "Ruminate"
S.ACTIONHANDLER_SDF_WITCH_TALISMAN_OFFERING_ANUBIS_STONE_PART1 = "Ruminate"
S.ACTIONHANDLER_SDF_WITCH_TALISMAN_OFFERING_ANUBIS_STONE_PART2 = "Ruminate"
S.ACTIONHANDLER_SDF_WITCH_TALISMAN_OFFERING_ANUBIS_STONE_PART3 = "Ruminate"
S.ACTIONHANDLER_SDF_WITCH_TALISMAN_OFFERING_ANUBIS_STONE_PART4 = "Ruminate"
S.ACTIONHANDLER_SDF_WITCH_TALISMAN_OFFERING_JACK_OF_THE_GREEN = "Bemuse"
S.ACTIONHANDLER_SDF_BOOK_OF_GALLOWMERE_DAMAGED_OFFERING_JACK_OF_THE_GREEN = "Offer Trampled Book of Gallowmere"
S.ACTIONHANDLER_SDF_BOOK_OF_GALLOWMERE_OFFERING_JACK_OF_THE_GREEN = "Offer Book of Gallowmere"
S.ACTIONHANDLER_SDF_BOOK_OF_GALLOWMERE_RESTORED_VELLUM_MEND = "Mend"
S.ACTIONHANDLER_SDF_KING_PEREGRINS_CROWN_LOST_OFFERING_KING_PEREGRIN = "Offer Lost Crown"
S.ACTIONHANDLER_SDF_KING_PEREGRINS_CROWN_OFFERING_KING_PEREGRIN = "Show Crown"
S.ACTIONHANDLER_SDF_SHADOW_ARTEFACT_OFFERING_KING_PEREGRIN = "Show Shadow Artefact"
S.ACTIONHANDLER_SDF_SHADOW_TALISMAN_OFFERING_KING_PEREGRIN = "Show Shadow Talisman"
S.ACTIONHANDLER_SDF_ASGARD_GOLEM_OPTIMIZE_DATA_INSTALL = "Install Data"
S.ACTIONHANDLER_SDF_PUMPKIN_GORGE_WELL_ENTER = "Traverse "
S.ACTIONHANDLER_SDF_ENCHANTED_EARTH_TOMB_ENTER = "Open Door"
S.ACTIONHANDLER_SDF_PROFESSORS_LAB_ENTER = "Enter Lab"

--Announcements
S.ANNOUNCE_SDF_PUMPKIN_GORGE_WELL_ACCESS_DENIED = "Does not seem safe..."
S.ANNOUNCE_SDF_ENCHANTED_EARTH_TOMB_ACCESS_DENIED = "Door is sealed!"
S.ANNOUNCE_SDF_PROFESSORS_LAB_ACCESS_DENIED = "The handle will not budge!"

--Morten
S.ANNOUNCE_SDF_MORTEN_MAD = "'Angry worm noises'"

--Chalice of Souls
S.ANNOUNCE_SDF_CHALICE_OF_SOULS_DESC = {
    [0] = "Empty... not a single soul.",
    [1] = "A cup that is filled with ones heroism!\n",
    [2] = "Many dispatched souls swirl about...\n Collected from the "
}

--Chalice Altars
S.ANNOUNCE_SDF_CHALICE_ALTAR_DESC = {
    [0] = "Seems to be an abandoned Chalice Altar, no Chalices to be found here.",
    [1] = "st Altar",
    [2] = "nd Altar",
    [3] = "rd Altar",
    [4] = "th Altar",
    [5] = "A cup that is filled with ones heroism!",
    [6] = "Chalice has already been Collected!"
}

--Chalice Rewards
S.ANNOUNCE_SDF_CHALICE_RUNESTONE_REWARDS = {
    [1] = "Canny Tim: How I wish I could fight at your side again, Sir. \nBut hold, you could take my Crossbow.",
    [2] = "Canny Tim: I have something that may help you on your quest, captain... \nI give it to you freely, though I have no idea what it is.",
    [3] = "Stanyer Iron Hewer: Here, take my warhammer, it'll smash anything and it won't fall apart like a Club. \nI only ever get to use it cracking walnuts around this place.",
    [4] = "Stanyer Iron Hewer: Here, I have a little extra something here I can give you. \nCould help the old quest, do you want it?",
    [5] = "Woden the Mighty: Still, I suppose it's not fair to take it out on them... \nTake my sword and do try not to stab yourself in the foot.",
    [6] = "Woden the Mighty: I have something here I can lend to you... take it or leave it... \nBut remember I'm only doing this for the sake of Gallowmere's doomed population and not for you... \nyou gangly buffoon!",
    [7] = "Ravenhooves the Archer: Do yourself a favour, Fortesque, take my Longbow... more powerful than a Crossbow.",
    [8] = "Imanzi Shongama: Your bow and arrows are fine for itty bitty jobs, \nbut if you wanna pack some serious heat you should take this Spear.",
    [9] = "Bloodmonath: Still, I lend you my Axe... \nYou swing her, you throw her, she thirsts for slaughter as much as I.",
    [10] = "Ravenhooves the Archer: Do yourself a favour, Fortesque, take my Flaming Longbow... the option of Flaming arrows.",
    [11] = "Karl Sturngard: Some say it is better to have a magic sword than a magic shield but I say to you that this is rubbish! \nI think maybe you should take my shield... yah? It is magic, Herr Fortesque.",
    [12] = "Bloodmonath: Hey, I have something here for you. You like it very much. You want?",
    [13] = "Dirk Steadfast: It's not enough just to have a magic shield, you know, no matter what that soft, thickie Sturnguard says. \nDaniel, man, y'cannat go into battle against an army of undead without a magic sword... Here take mine!",
    [14] = "Ravenhooves the Archer: Do yourself a favour, Fortesque, take my Magic Longbow... it is truly the weapon of noblemen.",
    [15] = "Megwynne Stormbinder: Would you like to take my magic Lightning bolts? \nI don't have many but they're very powerful.",
    [16] = "Ravenhooves the Archer: Oh, Daniel... I've got something here I can give you but I've no idea what it is. \nDo you fancy a little gamble, like?",
    [17] = "Imanzi Shongama: Well hello stranger. I've got a little present for you... \nWhy don't you shut your eye and hold out your hands?",
    [18] = "Karl Sturngard: I have something else I can give to you, something you may find verrrry interesting.",
    [19] = "Dirk Steadfast: I've got something here I can give you but I've no idea what it is. \nD'ya fancy your chances, like?",
    [20] = "Megwynne Stormbinder: I have a gift I can give to you but sadly I cannot say how useful you will find it."
}

S.ANNOUNCE_SDF_CHALICE_RUNESTONE_REWARDS_HERO = {
    [1] = "Infomation Gargoyle: You prove us all wrong! \nMaybe it is destined to be a Hero, maybe it can defeat Zarok!",
    [2] = "Infomation Gargoyle: The people of Gallowmere may never know of your past mistakes, \nand you will indeed be remembered as the peoples hero!",
    [3] = "Infomation Gargoyle: Your time in exile is over, welcome to your new home Sir Daniel Fortesque!",
    [4] = "Infomation Gargoyle: Now hurry along and view its True Heroic self."
}

S.ANNOUNCE_SDF_CHALICE_RUNESTONE_REWARDS_BONUS = {
    "Canny Tim: I have something that may help you on your quest, captain... \nI give it to you freely, though I have no idea what it is.",
    "Stanyer Iron Hewer: Here, I have a little extra something here I can give you. \nCould help the old quest, do you want it?",
    "Woden the Mighty: I have something here I can lend to you... take it or leave it... \nBut remember I'm only doing this for the sake of Gallowmere's doomed population and not for you... \nyou gangly buffoon!",
    "Bloodmonath: Hey, I have something here for you. You like it very much. You want?",
    "Ravenhooves the Archer: Oh, Daniel... I've got something here I can give you but I've no idea what it is. \nDo you fancy a little gamble, like?",
    "Imanzi Shongama: Well hello stranger. I've got a little present for you... \nWhy don't you shut your eye and hold out your hands?",
    "Karl Sturngard: I have something else I can give to you, something you may find verrrry interesting.",
    "Dirk Steadfast: I've got something here I can give you but I've no idea what it is. \nD'ya fancy your chances, like?",
    "Megwynne Stormbinder: I have a gift I can give to you but sadly I cannot say how useful you will find it."
}

S.ANNOUNCE_SDF_CHALICE_RUNESTONE_REWARDS_FAIL = {
    [1] =  "????: Chalice was empty... Offering refused... Do try filling it next time would yeah?",
    [2] =  "????: This Chalice was already Offered! Poor souls are now lost... But still the shattered bits are worth something to that greedy Merchant Gargoyle."
}


--Statue Interaction
S.ANNOUNCE_SDF_STATUE_QUOTES = {
    [0] = "Desecrated statue of legendary warriors of Gallowmere.",
    [1] = "Hero of Gallowmere... \nI'll show you!",
    [2] = "Captain Fortesque! It's me, Canny Tim. \nDoes the battle go well?",
    [3] = "Knock a few heads for old Stanyer Iron Hewer, eh?",
    [4] = "Fortesque, you jawless arrow magnet... \nWhat are you doing back here?",
    [5] = "Dan, Dan, Dan! Tell me, what's a warrior queen got to do to meet someone like you?",
    [6] = "Look at you running around in your bones, Fortesque! \nYou're so nouveau dead.",
    [7] = "If this Zorak so bad, why you get to go back? \nWhy you of all people, Fortisskay?",
    [8] = "Ah Herr Fortesque... \nYou are back on the battlefield, yah? \nZis is good.",
    [9] = "Aalreet Dan man, how ya doing?",
    [10] = "Daniel, there you are! I was so worried about you.",
    [11] = "The Hero of Gallowmere!"
}

--Information Gargoyle Talking
S.ANNOUNCE_SDF_INFORMATION_GARGOYLE_GREETINGS_SPAWN_SDF = {
"It has risen again... Sir Daniel Fortesque!",
"Let it alone! \nFate has given it a second chance!"
}

S.ANNOUNCE_SDF_INFORMATION_GARGOYLE_GREETINGS_SPAWN = {
"Hello there... This isn't quite Gallowmere!",
"Mind these lands! \nDark forces are abound!"
}

S.ANNOUNCE_SDF_INFORMATION_GARGOYLE_QUOTES_SPAWN_SDF = {
"See? \nThe Hero of Gallowmere who fell at the first charge!",
"The fog of war and the shrouds of time \nconspired to turn the arrow fodder into the saviour of the day. \nBut we knows better...",
"A chance to forget the ignoble truth, \na chance to defeat Zarok and live up to the legend. \nWe hopes it does well.",
"The stinking dead have risen up to dance with the lifeless living, \nand they want to do it over your dead body.",
"You must be out of shape after 100 years lying on your back.",
"Track down Zarok by retracing his diabolical odyssey through Gallowmere.",
"Loosen up those bone dry limbs and explore, \nyou never know what you may find."
}

S.ANNOUNCE_SDF_INFORMATION_GARGOYLE_QUOTES_SPAWN = {
"One as of you shouldn't dawdle!",
"Isn't there time better spent?..",
"Have you met the Boneheaded Champion?"
}


S.ANNOUNCE_SDF_INFORMATION_GARGOYLE_GREETINGS_HOH_SDF = {
"Back and forth like a supernatural yo yo! \nMaybe the Master will make it harder to find those magic egg cups!",
"Welcome to the Hall of Heroes, \nwhere the bravest warriors from history spend eternity, \nfeasting, singing and arm wrestling!",
"Back from the battles so soon?",
"It's the Hall of Heroes shopping Mall! \nBargain hunters should check out the ground floor. \nWell to do shoppers should check out the upper floor. \nThat's where it's at!",
"Wouldn't this make a wonderful tourist attraction!"
}

S.ANNOUNCE_SDF_INFORMATION_GARGOYLE_GREETINGS_HOH = {
"Welcome to the Hall of Heroes, \nwhere the bravest warriors from history spend eternity, \nfeasting, singing and arm wrestling!",
"Back from the battles so soon?",
"It's the Hall of Heroes shopping Mall! \nBargain hunters should check out the ground floor. \nWell to do shoppers should check out the upper floor. \nThat's where it's at!",
"Wouldn't this make a wonderful tourist attraction!"
}

S.ANNOUNCE_SDF_INFORMATION_GARGOYLE_QUOTES_HOH_SDF = {
"If they think you are worthy enough \nyou may be able to persuade them to give you a new weapon.",
"It must think it is a hero by now, \nbut only a true hero is worthy of a place in the Hall of Heroes.",
"See the Ghostly Statue of your fraudster self? \nWhen it is has turned solid a True Hero you will be.",
"Gaining allies in the Hall of the Heroes is the way forward!",
"Hack! Choppety chop! \nOff with a few zombies heads and it thinks it can redeem itself in battle!",
"You still have a long way to go to rank as the best!",
"Come see Sturnguard the Mighty! \nCome see the last of the Centaurs! \nOh and see that dork over there, that's Daniel Fortesque 'would be hero'! \nHa ha ha!",
"It is said that the King's Crown was lost in the Caves below, \nand that the ghost of the regent himself now haunts these cold stone passage ways. \nSpooky!",
"I have heard rumors of when, \nThe Chalice of Souls is completely filled... \nOne may harness its power to heal allies.",
"You will find Life Bottles throughout Gallowmere. \nThey contain the same magic that rose you from your slumber and will raise you from the dead once again.",
"Don't let zombies get you down. \nTend those wounds by stepping into this fountain of rejuvenation.",
"Hey dead man is that a bone in your pocket?!",
"Hey Book worm, \nYes: the one living in your empty eye socket, \nremember to keep up on your reading!",
"Some weapons contain powers and abilities beyond the ordinary.",
"Be sure to test every weapon to discover their secondary abilities.",
"During your travels through Gallowmere, you will collect many items.",
"If you have gold you can purchase items from the greedy Merchant Gargoyles. \nThe shameless profiteers can be recognised by their long blue stony faces.",
"Some obstructions can be smashed down with clubs and certain other weapons, \ntry experimenting.",
"The club is a crude, but effective weapon. \nBash with it! Burn with it! \nBut beware, one bash too many and it will break.",
"Witches have been known to offer help to the questing adventurer, \nyet they are a reclusive people and have to be summoned by the aid of mystic Charms or Talismans.",
"Let it be known that help from a Witch is rarely given freely, \nand the Witch will more often than not make a request of the adventurer before any such help is given.",
"If seeking to summon a Witch, \nremember that they are quite territorial.",
"The Adventurer would be wise to be thorough in the exploration of an area. \nHidden locations reap great rewards.",
"Kul Katura the Serpent Lord yearns to fight along side you, \nbut has been captured by Zarok and scaled within a Chest. \nFree this mighty Spirit and earn a powerful ally!",
"If it's beauty you are looking for, \nbe sure to check out the sights of the Enchanted Earth.",
"Pumpkin is Gallowmere's favourite dish, \nand about now the Pumpkin Gorge is... \njust bulging under the weight of young podlings awaiting harvest.",
"If it's mystery you're looking for, \nthen the seasoned adventurer should travel to The Haunted Ruins of King Peregrin's castle."
}

S.ANNOUNCE_SDF_INFORMATION_GARGOYLE_QUOTES_HOH = {
"If they think you are worthy enough \nyou may be able to persuade them to give you a new weapon.",
"Gaining allies in the Hall of the Heroes is the way forward!",
"Hack! Choppety chop! \nOff with a few zombies heads and it thinks it can redeem itself in battle!",
"Come see Sturnguard the Mighty! \nCome see the last of the Centaurs! \nOh and see that dork over there, that's Daniel Fortesque 'would be hero'! \nHa ha ha!",
"It is said that the King's Crown was lost in the Caves below, \nand that the ghost of the regent himself now haunts those cold stone passage ways. \nSpooky!",
"Some weapons contain powers and abilities beyond the ordinary.",
"Be sure to test every weapon to discover their secondary abilities.",
"During your travels through Gallowmere, you will collect many items.",
"If you have gold you can purchase items from the greedy Merchant Gargoyles. \nThe shameless profiteers can be recognised by their long blue stony faces.",
"Some obstructions can be smashed down with clubs and certain other weapons, \ntry experimenting.",
"The club is a crude, but effective weapon. \nBash with it! Burn with it! \nBut beware, one bash too many and it will break.",
"Witches have been known to offer help to the questing adventurer, \nyet they are a reclusive people and have to be summoned by the aid of mystic Charms or Talismans.",
"Let it be known that help from a Witch is rarely given freely, \nand the Witch will more often than not make a request of the adventurer before any such help is given.",
"If seeking to summon a Witch, \nremember that they are quite territorial.",
"The Adventurer would be wise to be thorough in the exploration of an area. \nHidden locations reap great rewards.",
"Kul Katura the Serpent Lord yearns to fight along side you, \nbut has been captured by Zarok and scaled within a Chest. \nFree this mighty Spirit and earn a powerful ally!",
"If it's beauty you are looking for, \nbe sure to check out the sights of the Enchanted Earth.",
"Pumpkin is Gallowmere's favourite dish, \nand about now the Pumpkin Gorge is... \njust bulging under the weight of young podlings awaiting harvest.",
"If it's mystery you're looking for, \nthen the seasoned adventurer should travel to The Haunted Ruins of King Peregrin's castle."
}

S.ANNOUNCE_SDF_INFORMATION_GARGOYLE_GREETINGS_JOTG = {
"This is the garden of Zarok, nothing here is as it first seems."
}

S.ANNOUNCE_SDF_INFORMATION_GARGOYLE_QUOTES_JOTG = {
"To leave this maze you must first seek out the one called Jack of the Green!"
}

S.ANNOUNCE_SDF_INFORMATION_GARGOYLE_GREETINGS_HG_SDF = {
"Sir Daniel Fortesque, it's been a long time. \nWelcome back to your home."
}

S.ANNOUNCE_SDF_INFORMATION_GARGOYLE_GREETINGS_HG = {
"Long ago this was once the majestic Throne room of King Peregrin."
}

S.ANNOUNCE_SDF_INFORMATION_GARGOYLE_QUOTES_HG_SDF = {
"It is sad that you should see it so - the jewel in Gallowmere's crown, \nhas become a corrupt haven for Zarok's Army of Shadow Demons!",
"The lava has been released Sir Dan, the Castle is collapsing!",
"Find King Peregrin's crown and perhaps you can summon him.",
"You will not have long to defeat the stone Golems and escape the ensuing inferno.",
"Now foul demons stalk the corridors.",
"The spirit of the King must be saddened indeed.",
"The castle was constructed on top of a dormant volcano.",
"The old castle of King Peregrin has fallen into the hands of the Shadow Demons."
}

S.ANNOUNCE_SDF_INFORMATION_GARGOYLE_QUOTES_HG = {
"You will not have long to defeat the stone Golems and escape the ensuing inferno.",
"Now foul demons stalk the corridors.",
"The spirit of the King must be saddened indeed.",
"The castle was constructed on top of a dormant volcano.",
"The old castle of King Peregrin has fallen into the hands of the Shadow Demons."
}

S.ANNOUNCE_SDF_INFORMATION_GARGOYLE_GREETINGS_MCM = {
"Here lies the mighty Cheiftain of the Mullocks!"
}

S.ANNOUNCE_SDF_INFORMATION_GARGOYLE_QUOTES_MCM = {
"Whom with the humans pushed back the forces of Zarok at the Battle of Gallowmere.",
"Once he passed away, \nhe was buried here in the Gallowmere graveyard \nalong with the stone piece...",
"One would be wise to not mess with his remains, \nbut if you do..."
}

S.ANNOUNCE_SDF_INFORMATION_GARGOYLE_GREETINGS_PG = {
"All bow down before the master of the vegetable patch!",
"Pumpkin Gorge dead ahead, \nthe nursery to Gallowmere's favourite side dish.",
"Step inside and understand the true horror of fruit gone bad!"
}

S.ANNOUNCE_SDF_INFORMATION_GARGOYLE_QUOTES_PG_SDF = {
"The prize winning plant who can summon an army of cabbage, \nwith a wave of his noble tendril.",
"He's delicious, \nhe nutritious, \nhe's Zarok's secret recipe - he's the Pumpkin King!",
"The King Pumpkin sleeps... \nif you want an audience with this regal plant you should mash all of his pod sacks!",
"It is rumored that the Pumpkin Witch is in possession of a much sought after Dragon Gem.",
"If you have a Witch Talisman you could summon this kindly Witch."
}

S.ANNOUNCE_SDF_INFORMATION_GARGOYLE_QUOTES_PG = {
"The prize winning plant who can summon an army of cabbage, \nwith a wave of his noble tendril.",
"He's delicious, \nhe nutritious, \nhe's Zarok's secret recipe - he's the Pumpkin King!",
"The King Pumpkin sleeps... \nif you want an audience with this regal plant you should mash all of his pod sacks!"
}

S.ANNOUNCE_SDF_INFORMATION_GARGOYLE_GREETINGS_EE = {
"None shall enter.",
"Keep out! \nThis gate leads to the tomb of the Shadow Demons."
}

S.ANNOUNCE_SDF_INFORMATION_GARGOYLE_QUOTES_EE_SDF = {
"The Shadow Demons are entombed within, \nseparated from the world of goodness and light until the earth cracks open.",
"No one, not even the dark lord Zarok, \ncan release them without the Shadow Artefact.",
"Leave now or share their doom.",
"There used to be a Coven of Witches in the caves beneath Cemetery Hill, \nthe whole forest's never smelt the same since."
}

S.ANNOUNCE_SDF_INFORMATION_GARGOYLE_QUOTES_EE = {
"The Shadow Demons are entombed within, \nseparated from the world of goodness and light until the earth cracks open.",
"No one, not even the dark lord Zarok, \ncan release them without the Shadow Artefact.",
"Leave now or share their doom."
}

S.ANNOUNCE_SDF_INFORMATION_GARGOYLE_GREETINGS_SDT = {
"What have you done?"
}

S.ANNOUNCE_SDF_INFORMATION_GARGOYLE_QUOTES_SDT_SDF = {
"The single most destructive and wretched creatures in the history of the world \nand you've given them an early parole.",
"Well about time too, \nthought I was going to be a permanent addition to this mossy hell hole!",
"Sir Dan you must take the Shadow Demon Talisman!",
"It is an unholy relic \nbut it may allow you to progress through the Shadow Demon territory."
}

S.ANNOUNCE_SDF_INFORMATION_GARGOYLE_QUOTES_SDT = {
"The single most destructive and wretched creatures in the history of the world \nand you've given them an early parole.",
"Well about time too, \nthought I was going to be a permanent addition to this mossy hell hole!"
}

S.ANNOUNCE_SDF_INFORMATION_GARGOYLE_GREETINGS_AC_SDF = {
"Run little man!",
"If the master found it now he would crush it like a bug! \nHa ha ha!"
}

S.ANNOUNCE_SDF_INFORMATION_GARGOYLE_QUOTES_AC_SDF = {
"Hark! We can hear the soldier ants approaching! \nonward and meet your tiny nemesis.",
"If you are brave enough to go beyond this point you will enter the chamber of the dreaded Queen Ant.",
"Be aware, \nonce you have encountered her six-legged regalness there will be no going back!"
}

S.ANNOUNCE_SDF_INFORMATION_GARGOYLE_GREETINGS_CC = {
"Tread softly in these caves for an ill tempered Dragon has a lair here."
}

S.ANNOUNCE_SDF_INFORMATION_GARGOYLE_QUOTES_CC = {
"The mean old Dragon can be summoned by inserting two Dragon Gems into the eye sockets of the relief.",
"The grouchy Dragon doesn't come out much as he is afraid of the roof collapsing over his head!",
"Be aware, \nonce you have encountered her six-legged regalness there will be no going back!"
}

S.ANNOUNCE_SDF_INFORMATION_GARGOYLE_GREETINGS_ZL_SDF = {
"We never thought you'd get this far",
"Your final encounter with Zarok awaits beyond this point."
}

S.ANNOUNCE_SDF_INFORMATION_GARGOYLE_QUOTES_ZL_SDF = {
"Zarok has surrounded himself with his unnatural bodyguards!",
"You may yet even the odds... \nby calling upon the lost Souls collected within your Anubis Stone.",
"Good luck Sir Daniel Fortesque."
}

--Health Fountain Status
S.ANNOUNCE_SDF_HEALTHFOUNTAIN_STATUS = {
    [0] = "Depleted Fountain of Rejuvenation",
    [1] = "Spring of life energy has been exhasusted!",
    [2] = "Trickling spring of life energy!",
    [3] = "Weeping spring of life energy!",
    [4] = "Flowing spring of life energy!",
    [5] = "Teeming spring of life energy!",
    [6] = "Spouting spring of life energy!",
    [7] = "Gushing spring of life energy!",
    [8] = "Fountain of Rejuvenation"
}

--Time Rune Status
S.ANNOUNCE_SDF_TIME_RUNE_STATUS = {
    [0] = "Perpetual Time Rune",
    [1] = "Time Rune",
    [2] = "Ephemeral Time Rune",
    [3] = "Temporal Time Rune",

}

--Dans Helmet
S.ANNOUNCE_SDF_HELMET_LEADER_SHOUT = "For Glory! For the Honor of Gallowmere!"
S.ANNOUNCE_SDF_HELMET_FOLLOWER_SHOUT = "For the Honor of Gallowmere!"

--Gallowmere Knight Talking
S.ANNOUNCE_SDF_GALLOWMERE_KNIGHT_GREETINGS = {
"This place is clear and secure Sir!",
"I'm always here, whenever you need me.",
"Glad to see you alive Sir!",
"There you are my Captain."
}

S.ANNOUNCE_SDF_GALLOWMERE_KNIGHT_GREETINGS_COMMON = {
"Well met!",
"Good morrow!",
"Our Kingdom shall not fall.",
"Everything is taken care of.",
"There are tons of weird animals here..."
}

S.ANNOUNCE_SDF_GALLOWMERE_KNIGHT_RECRUIT = "For the honor of Gallowmere!"

S.ANNOUNCE_SDF_GALLOWMERE_KNIGHT_VICTORY_EPIC = "This battle is ours!"

S.ANNOUNCE_SDF_GALLOWMERE_KNIGHT_VICTORY = {
"Glory to King Peregrin!",
"Away you foul fiend!",
"Foe has been slain!",
"Vanquished!",
"Well fought!",
"Rest in peace..."
}

S.ANNOUNCE_SDF_GALLOWMERE_KNIGHT_FOLLOW = {
"Lead the charge!",
"At your service my Captain.",
"Anything to fight? I can't wait."
}

S.ANNOUNCE_SDF_GALLOWMERE_KNIGHT_STAY = {
"It's been an honour serving with you.",
"Yes Sir, Guarding these grounds!",
"This place looks nice."
}

S.ANNOUNCE_SDF_GALLOWMERE_KNIGHT_CALLTOARMS = "To Arms! For the honor of Gallowmere!"

S.ANNOUNCE_SDF_KING_PEREGRIN_GREETING_SDF = {
    "Sir Fortesque...",
    "Noblest of my courtiers...",
    "Bravest of my captains!",
    "Clumsiest of my croquet team!"
}

S.ANNOUNCE_SDF_KING_PEREGRIN_TRADE_FOOD_SDF = {
    "Not a Brussles Sprout... but just as pungent, \nThank Sir Fortesque. Here...",
    "Hmm looks so familar... yet different! \nThank Sir Fortesque. Here...",
    "Can't possibly be as deadly. \n\Fortesque, take this as my thanks.",
    "Oh My Saints, gimme... in return."
}

S.ANNOUNCE_SDF_KING_PEREGRIN_TRADE_TRINKET_SDF = {
    "Found something on your travels? \nThank Sir Fortesque. Here...",
    "Simply fascination... \nHere you are Fortesque...",
    "Oh of what new tales?! \nThank Sir Fortesque. Here...",
    "How curious! \nThank Sir Fortesque. Here...",
    "Oh My Saints, gimme... in return."
}

S.ANNOUNCE_SDF_KING_PEREGRIN_GREETING_WENDY = {
    "The child that can conum with the dead...",
    "Hello there depressed child...",
    "You seem rather spirited today!",
    "Found anything interesting today?"
}

S.ANNOUNCE_SDF_KING_PEREGRIN_TRADE_WENDY = {
    "How interesting... here take this in return.",
    "Lovely...but what is it?! \nHere take this in return.",
    "How exotic... here take this in return.",
    "Oh my saints, how strange... in return."
}

S.ANNOUNCE_SDF_KING_PEREGRIN_TRADE_REFUSED = {
    "No thank you...",
    "I shall pass on this..."
}

S.ANNOUNCE_SDF_KING_PEREGRIN_QUOTES_PRE = {
"Ahem... pfft... ack!",
"ACK- HAUGHK- AUCKH!",
"ACAUGH- KKH- KACK- KACKH..."
}

S.ANNOUNCE_SDF_KING_PEREGRIN_QUOTES = {
"Now look, Zarok's army of Shadow Demons \nhide beneath us within this very mountain.",
"Those blasted Shadow Demons prepare as we speak to invade fair Gallowmere.",
"So Lord Kardok is back, and his damned Fazguls...",
"You would think there would be peace in death...  but no rest here.",
"I wonder how that impregnable box is holding up...",
"If only I could enjoy those little delicious morsels once more.",
"Ahem... pfft... ack!",
"ACK- HAUGHK- AUCKH!",
"ACAUGH- KKH- KACK- KACKH..."
}

S.ANNOUNCE_SDF_KING_PEREGRIN_OFFERED_CROWN_LOST_SDF = {
    [0] = "Sir Fortesque, \nnoblest of my courtiers, \nbravest of my captains!",
    [1] = "Oh that we should meet at such a dark hour, \nwith the fate of this realm lying once again in your hands.",
    [2] = "Good god, Fortesque... What's happened to your jaw?",
    [3] = "Bad luck old man.",
    [4] = "As for the Crown, I no longer have a kingdom.... \n nor do I rule these lands.",
    [5] = "Fortesque... \nYou hold onto it....",
    [6] = "Call upon to those still in service... \neven in death they will come to your aid!",
    [7] = "Those Shadow Demons be underfoot... \nDo tread lightly, clumsiest of my Croquet Team!"
}

S.ANNOUNCE_SDF_KING_PEREGRIN_HINT_CROWN_SDF = "My majestic throne overrun by Shadow Demons, dark times indeed..."

S.ANNOUNCE_SDF_KING_PEREGRIN_OFFERED_SHADOW_ARTEFACT_SDF = {
    [0] = "Oh it seems Zarok means to release the Demons, \nfrom their tomb under the Enchanted Earth.",
    [1] = "If we are to thwart his plans we must bring down the castle on top of them...",
    [2] = "Or in this case slay them while they are still imprisoned!",
    [3] = "Of course it's a highly dangerous mission - even for a dead man.",
    [4] = "Splendid! Good luck old friend!"
}

S.ANNOUNCE_SDF_KING_PEREGRIN_HINT_SHADOW_ARTEFACT_SDF = "Look for the Shadow Demons Tomb under the Enchanted Earth."

S.ANNOUNCE_SDF_KING_PEREGRIN_OFFERED_SHADOW_TALISMAN_SDF = {
    [0] = "I dare say that when that fiend sees what you've done.",
    [1] = "He'll make sure you spend eternity in the most unspeakable torment.",
    [2] = "But then I know these things mean nothing to a man of your iron will, \neh Fortesque?",
    [3] = "Oh of Course... \nMy Anubis Stone is yours.",
    [4] = "Can't think of a better chap to look after it.",
    [5] = "Now give old Lord Kardok and his Fazguls hell.",
    [6] = "Good luck, old bean. Break a leg."
}

S.ANNOUNCE_SDF_KING_PEREGRIN_HINT_SHADOW_TALISMAN_SDF = "Lord Kardok and his damned Fazguls... \nshould be found in Ruins Military Quarter."


S.ANNOUNCE_SDF_JACK_OF_THE_GREEN_GREETING_COMMON_LOOKINGFORSDF = {
    [0] = "Hello there my name is... Jack of the Green.",
    [1] = "I am the master of riddles... and this maze remains unseen.",
    [2] = "Seeking a Fallen Knight... whoses one-eyed skull is keen."
}

S.ANNOUNCE_SDF_JACK_OF_THE_GREEN_GREETING_SDF = {
    [0] = "Greetings Sir Fortesque, my name is... Jack of the Green.",
    [1] = "I am the master of riddles and this maze is my domain.",
    [2] = "You are free to leave but ONLY once you've answered four riddles.",
    [3] = "Puzzles so fiendishly difficult, \nso perplexingly complex that no man has ever solved them! \nHa, ha, ha"
}

S.ANNOUNCE_SDF_JACK_OF_THE_GREEN_GREETING_SDF_RIDDLE_ONE = {
    [0] = "Now try my first riddle...",
    [1] = "At night they come without being fetched; \nBy day they are lost without being stolen."
}

S.ANNOUNCE_SDF_JACK_OF_THE_GREEN_SOLVE_SDF_RIDDLE_ONE = {
    [0] = "Jack of the Green: Well done, Sir Knight.",
    [1] = "Jack of the Green: But my Star Riddle was but a trifle, \nI always like to begin with an easy one.",
    [2] = "Jack of the Green: Return hither, you will not find my next conundrum so simple!"
}

S.ANNOUNCE_SDF_JACK_OF_THE_GREEN_SDF_RIDDLE_ONE_STAR_FOUND = "Stars Found!"


S.ANNOUNCE_SDF_JACK_OF_THE_GREEN_GREETING_SDF_RIDDLE_TWO = "I live for laughter; \nI live for the crowd; \nWithout it I am nothing."

S.ANNOUNCE_SDF_JACK_OF_THE_GREEN_SOLVE_SDF_RIDDLE_TWO = {
    [0] = "Jack of the Green: All right, yes it was a clown... very clever I'm sure.",
    [1] = "Jack of the Green: Return in haste, Sir knight!",
    [2] = "Jack of the Green: For I wish to see the despair on your face when you hear my next cryptic puzzler."
}

S.ANNOUNCE_SDF_JACK_OF_THE_GREEN_SOLVE_SDF_RIDDLE_TWO_CLOWN_EMOTION = {
    [0] = "Lamenting Hedge",
    [1] = "Ecstatic Hedge"
}

S.ANNOUNCE_SDF_JACK_OF_THE_GREEN_GREETING_SDF_RIDDLE_THREE = "Face like a tree; \nSkin like the sea; \nA great beast I be; \nYet vermin frighten me!"

S.ANNOUNCE_SDF_JACK_OF_THE_GREEN_SOLVE_SDF_RIDDLE_THREE = {
    [0] = "Jack of the Green: Did you spot my bluff?",
    [1] = "Jack of the Green: I pretended that riddle was hard but in truth it was obviously an elephant.",
    [2] = "Jack of the Green: This time, however, I almost pity you...",
    [3] = "Jack of the Green: The answer to my next vexing enigma has eluded the finest minds of a whole generation.",
    [4] = "Jack of the Green: Come to me!"
}

S.ANNOUNCE_SDF_JACK_OF_THE_GREEN_RIDDLE_MOLEWORM_MOVING = "Creeping Brush"


S.ANNOUNCE_SDF_JACK_OF_THE_GREEN_GREETING_SDF_RIDDLE_FOUR = "I tolerate the moon and stars; \nI can't abide the sun; \nBanish me with torch light; \nAnd you'll see me turn and run."

S.ANNOUNCE_SDF_JACK_OF_THE_GREEN_SOLVE_SDF_RIDDLE_FOUR = {
    [0] = "Jack of the Green: Blast you! It took me ages to come up with that Darkness one!",
    [1] = "Jack of the Green: Very well, outrageous as it seems...",
    [2] = "Jack of the Green: My vast intellect has been matched by your badly decomposed brain.",
    [3] = "Jack of the Green: Return at once and I shall give you your prize."
}


S.ANNOUNCE_SDF_JACK_OF_THE_GREEN_GREETING_SDF_RIDDLE_FREE_PASSAGE = {
    [0] = "You think you're so clever, don't you?",
    [1] = "Here you are Sir Clever Clogs,\nI grant you free passage through my maze...",
    [2] = "Find your own way out!"
}


S.ANNOUNCE_SDF_JACK_OF_THE_GREEN_THINKING = {
    [0] = "...Musing the most sophisticated riddles, mind-boggling no doubt...",
    [1] = "...What a conundrum... distraction mixed with a charade...",
    [2] = "...Total bewilderment! Massive entanglement! This will be a stumper...",
    [3] = "...A paradox, wrapped in an enigma... Hmm yes, what a predicament...",
    [4] = "...The dilemma of a rebus puzzlement..."
}


S.ANNOUNCE_SDF_JACK_OF_THE_GREEN_BOOK_OF_GALLOWMERE_DAMAGED_FOUND = {
    [0] = "Sir Knight...\n What might those boney hands be holding?",
    [1] = "Found an object in my maze have you, do show and tell!"
}

S.ANNOUNCE_SDF_JACK_OF_THE_GREEN_BOOK_OF_GALLOWMERE_DAMAGED_OFFERING = {
    [0] = "Where did you find this?!\nStumbled upon it with one eye closed no doubt...",
    [1] = "The anticipation must be killing you, if you must know...",
    [2] = "It is Tome filled with Gallowmere's history,\nwhich allows one to read its knowledge on the pages within.",
    [3] = "Its condition looks quite poor,\nso who better else than I should aid in its restoration.",
    [4] = "Here take this for your discovery,\nits a fair trade I assure you...",
    [5] = "I found this exchange quite A-Musing Sir Knight",
    [6] = "How about we alter our pastime with a new quirk!",
    [7] = "Try to best me with objects for my riddles...\nIn return, I help you restore its pages and be rewarded.",
    [8] = "Now hurry along Sir Clever Clogs and gather your friends...\nlet the Cerebrum Games begin!"
}

S.ANNOUNCE_SDF_JACK_OF_THE_GREEN_BOOK_OF_GALLOWMERE_OFFERING = {
    "Sir Knight... Seems the book is still incomplete?",
    "The book is filling out quite nicely!",
    "Still more pages in need of mending.",
    "More riddles to solved, more vellums to be had...",
    "There is still more knowledge to be bound."
}

S.ANNOUNCE_SDF_JACK_OF_THE_GREEN_BOOK_OF_GALLOWMERE_RESTORED_OFFERING = {
    [0] = "Sir Knight...\n What do we have here?",
    [1] = "Yes... yes!\n The pages all have been mended.",
    [2] = "The Spine is straight...\n The luster of the Cover...",
    [3] = "Well done indeed...\n With my help of course...",
    [4] = "Here take this as a gift... Fortitude for your Persistence.",
    [5] = "You may now also craft a Restored Book of Gallowmere to share with others!",
    [6] = "As always... more Riddles await. Do come by and test your wit."
}

S.ANNOUNCE_SDF_JACK_OF_THE_GREEN_BOOK_OF_GALLOWMERE_RESTORED_REOFFERING = {
    "Sir Knight... Yes it is a glorious book.",
    "Better not bend the corners...",
    "Are you learning anything?",
    "Have you lent to others to read?"
}

S.ANNOUNCE_SDF_JACK_OF_THE_GREEN_BOOK_OF_GALLOWMERE_RIDDLES = {
    [0] = "Not Needed",
    [1] = "I'll Light the path along your way; \nWhile in the depths careful not to stray.",
    [2] = "A welcomed Snack, in case of an emergency; \nBetter to Plant me in the ground, and wait till I reach Maturity.",
    [3] = "While exploring the Depths, can be quite the thriller; \nMy Nutritional value is next to None, for I am but a Filler.",
    [4] = "I grow where its Dark, Cool, and wet; \nMy surroundings are Ancient, crumbling with neglect.",
    [5] = "I grow in Fields, with my Blades of Greenery; \nTo only be Cut down, by creatures and machinery.",
    [6] = "You Pluncked me from my body, soon I shall turn Brown; \nPicking gave you Happiness, so Wear me like a Crown.",
    [7] = "Stumble upon me Hoping, and feel overcomed with Dread; \nI am not one for Comfort, I mess with your Head.",
    [8] = "In the dry sand I do Bloom; \nHelping ease its desolate gloom.",
    [9] = "I welcome the Day, while the sun is most Bright; \nWatch your Health drop, when taking a Bite.",
    [10] = "Day is too vivid, and Night is too eerie; \nDon't Eat me raw, else your Mind will feel Weary.",
    [11] = "I come out at Night, to see the moon and stars; \nWith the price of Clarity , I'll help heal your scars.",
    [12] = "There is no Day or Night, which is due to Geologic; \nI'll fill your Wits and Belly, however you will feel Lethargic.",
    [13] = "I was once the Hunter, but now the Hunted; \nNo matter how I am Served, your Taste is Disgusted.",
    [14] = "With Shrieks of Terror, that go bump in the Night; \nI am not the monster, but I do give it Flight.",
    [15] = "Worry not, the place I come from is Gooey; \nI'll Treat all your Wounds, although I most likey taste Ewwy.",
    [16] = "I'll Tempt you over, into a Field that teems; \nWith all Eyes open, they will Devolur your screams.",
    [17] = "I am found where Water is Hard to find; \nCareful to not run your fingers down my Spine.",
    [18] = "Tread carefully when you Walk, for one misstep I'll Sting; \nVeins will feel as of Lava, curses out of Pain you will sing.",
    [19] = "Shaped like the Moon, I grow in Bunches; \nIn mischievous Creatures clutches, I am Eaten for their lunches.",
    [20] = "I am favored by the Gods, truely a tasty Divine gift; \nContaining numerous tiny Seeds, in your hand you shall Sift.",
    [21] = "Though Wrinkly in appearance, I do still Shine; \nAdd me with Fruit, discover a Dessert that is divine.",
    [22] = "Said to be used to keep the Creatures of the Night at bay; \nOthers use for simple Gourmet.",
    [23] = "I can make the Strongest of beings Cry; \nWith a single cut Tears form in your Eye.",
    [24] = "I have many Eyes, however no sight; \nEven when I am above the Ground, where it is bright.",
    [25] = "I Grow by Vine which keeps me in place; \nWhen ripen carve a Smile upon my Face.",
    [26] = "I have a Slippery Golden hue, which Spreads easy on toast; \nAdd me to all Cooking recipes, culinary Delights you shall boast.",
    [27] = "Crafted by the Busy, from Flowers that have bloomed; \nProtected by the Colony, in which I am entombed.",
    [28] = "I am handled with Care, from a Cage I was taken; \nI can be Perpared in many ways, but best Served with bacon",
    [29] = "Dead before living, my time has Passed; \nCareful not to Break me, else release my Foul gas.",
    [30] = "A Perishable not Consumed, some consider it a Waste; \nUsable for Gardening, and Transplants brought back to base.",
    [31] = "I am the Royal vault, safe keeping Liquid gold; \nUseful beyond my purpose, when Shapened in a Mold.",
    [32] = "I can Wrap up Items, that you wish not to Hold; \nGive it to an excited Friend, and watch as they Unfold.",
    [33] = "With a Quill in hand, your Memories I will Hold; \nRead upon my Flesh, and Visons will Unfold",
    [34] = "Carefree and Pleasant, I am seen not as a Threat; \nPlant to plant I fly, while others chase me with their Net.",
    [35] = "Native to the land all covered in Muck; \nI Swoop around in Stench, searching for Blood to Suck.",
    [36] = "I carry a Painful weapon, but I am Not mean; \nWe only live to Serve, all hail the Queen.",
    [37] = "I guard my fellow Sisters, with up most Protection; \nGet too Close, and you will feel my Aggression.",
    [38] = "Not afriad of the Dark, for I carry my own Light; \nGet too Close and I vanish from your Sight.",
    [39] = "I Soar in my environment, but not in the Sky; \nI can't survive on Land, for its too Dry.",
    [40] = "I am a Theif from Underfoot; \nMy nose will find Minerals that stay put.",
    [41] = "If you get Close, I'll run away in Horror; \nSo set down a Trap, and Catch me while I Explore.",
    [42] = "Songs I don't Sing, therefore I Caw; \nFashion me into an Utensil, so that you may Draw.",
    [43] = "Common to all Seasons, but never in the Winter; \nCraft me into a neat Cool vest, or set the world a Cinder.",
    [44] = "What was once the Color of Fire, is now of Ice; \nFor those in the Waters, I am used to Entice.",
    [45] = "Put in Cages, then taken down to the Mines; \nI am a Gift to my only Friend, in a Field it assigns.",
    [46] = "I am used for warmth on a cold chilly day; \nAt night you come to steal me away.",
    [47] = "Weaved to Slow and Trap their preys; \nYou tailor into Clothes and grand Tapestries.",
    [48] = "Slick in nature, Cold to the touch; \nPut me in your mouth, I end with a crunch.",
    [49] = "I survived through Flame, where others turned to Ash; \nWhile Valued worthless, you store me in your Stash.",
    [50] = "I Burn brightly as one expected; \but my fires Warmth is not as suspected.",
    [51] = "Look into the Night Sky and you'll see my flash; \nI fell from the Heavens with a deafing Crash.",
    [52] = "Not hard as a Rock, nor flashy as Gold; \nFashion me correctly, a new Tool you shall hold.",
    [53] = "Worth my Weight in value, hope your Pockets are deep; \nFor the Demand of this world, don't run Cheap.",
    [54] = "Weapons, armor and crafts, forged by the Ancient; \nAll this Technology in Ruins, for now I am merely a Reagent.",
    [55] = "In the Pocket do you keep; \nHot or Cold I will seep.",
    [56] = "Keeping in Rythm, a Blood price was Paid; \nA Phylactery for the Dead, call a Friend when you require Aid."
}

S.ANNOUNCE_SDF_JACK_OF_THE_GREEN_BOOK_OF_GALLOWMERE_RIDDLES_ANSWERS = {
    [0] = "Not Needed",
    [1] = "How brightly does the [Light Bulb] truely shine!",
    [2] = "[Seeds] what secrets can it hold... only the ground will uncover its mystery.",
    [3] = "[Foliage]... is the grotto vegetation of the subterrane.",
    [4] = "Ah yes [Lichen], the fungus without a cap.",
    [5] = "Nothing smells more pleasent than freshly [Cut Grass].",
    [6] = "Picking plentiful [Petals] promises postive perceptions!",
    [7] = "[Dark Petals] are useful for those with twisted grim desires.",
    [8] = "How wondrous a [Cactus Flower] could blossom in such heat.",
    [9] = "Toxin of the [Red Cap]... great for greedy gluttonous Gobblers!",
    [10] = "Bitterness of the [Green Cap]... wise to be cooked thoroughly!",
    [11] = "Miasma of the [Blue Cap]... wounds will vanish, so will your senses!",
    [12] = "Anesthetic of the [Moon Shroom]... too much and one could slip into a comatose!",
    [13] = "Unpalatable is that of [Monster Meat], unless you are a monster yourself.",
    [14] = "Such ominous cirles the [Batilisk Wing] carry their masters.",
    [15] = "As gross as the [Spider Gland] is, you can't deny its medicinal effects!",
    [16] = "[Leafy Meat] is a vegetarian option to eat what you slay!",
    [17] = "Prickly [Cactus Flesh]... must of been a delight gathering!",
    [18] = "[Fire Nettle Fronds] the prickliest of the garden plants!",
    [19] = "Did you know... [Banana] is a fruit commonly eaten backwards!",
    [20] = "Ah yes the [Pomegranate]... The fruit that promotes health and youth!",
    [21] = "[Lesser Glow Berry] is not really a berry... intriguing is it not?",
    [22] = "The bulbous [Garlic]... only for those with esquite tastes.",
    [23] = "The complexity of the [Onion], with all its layers.",
    [24] = "Ah yes the [Potato]... Bake em', mash em', stick em' in a stew.",
    [25] = "The versatile [Pumpkin], for both food and decoration.",
    [26] = "I can not believe its not [Butter]!",
    [27] = "A dabble of [Honey] goes great with tea.",
    [28] = "The unhatched potential of the [Egg].",
    [29] = "The [Rotten Egg], when a good yolk goes bad...",
    [30] = "[Rot]... what it was no longer matters.",
    [31] = "The duality of [Honeycomb], used for storage and protection.",
    [32] = "Simple [Wax Paper]... the luxurious way to make someones day!",
    [33] = "The written [Papyrus] will remain for long even when you are gone.",
    [34] = "The [Butterfly]... whom brings flowers to their own burial.",
    [35] = "How annoying is the [Mosquito], humming around ones ears is maddening!",
    [36] = "The [Bee] does in fact have knees.... Six to be precise!",
    [37] = "THe [Killer Bee] has a short fuse, but long stinger!",
    [38] = "Tiny [Fireflies] have such spectacular warm glows.",
    [39] = "[Freshwater Fish] swim with such grace.., put them on land and they flop in place.",
    [40] = "Nuisance is the [Moleworm], with their mounds and thievery!",
    [41] = "I once saw a hat trick... a [Rabbit] pulled from a Prestihatitator.",
    [42] = "Feeling inspiration from this [Jet Feather]",
    [43] = "Still can feel summer's heat on this [Crimson Feather].",
    [44] = "Still can feel winter's chill on this [Azure Feather].",
    [45] = "Shocking... Can still feel tingles on this [Saffron Feather]!",
    [46] = "No matter how much you wash [Beefalo Wool], you never get that smell out!",
    [47] = "[Silk] also known as posterior silly string!",
    [48] = "[Ice] is a great filler in meals don't you know?!",
    [49] = "Some say that [Charcoal] is a flame in solid form.",
    [50] = "[Nitre]... that cold burning fuel... Brrr.",
    [51] = "The [Moon Rock]... a mystery beyound our world.",
    [52] = "Yes [Flint] is fundamental for survival.",
    [53] = "The [Gold Nugget], the shiny currency for all belongings.",
    [54] = "[Thulecite Fragments] contain trace amounts of insanity, magic and abnormalities.",
    [55] = "A [Thermal Stone] is quite the loyal companion on long journeys.",
    [56] = "[Telltale Heart] is an anchor for lost souls adrift."
}

S.ANNOUNCE_SDF_JACK_OF_THE_GREEN_BOOK_OF_GALLOWMERE_RIDDLES_COUNTER_PRE = {
    [0] = "Now for my First Riddle...",
    [1] = "Here is the Second Riddle...",
    [2] = "The Third Riddle shall be...",
    [3] = "For the Fourth Riddle..."
}

S.ANNOUNCE_SDF_JACK_OF_THE_GREEN_BOOK_OF_GALLOWMERE_RIDDLES_BONUS_REMINDER = "A bonus reward for solving this cunning brain-twiser!"

S.ANNOUNCE_SDF_JACK_OF_THE_GREEN_BOOK_OF_GALLOWMERE_RIDDLES_CORRECT = {
    [0] = "CORRECT",
    [1] = "Most indeed you are correct...",
    [2] = "Figured it out did you...",
    [3] = "That was an easy one...",
    [4] = "Ok ok smarty pants...",
    [5] = "Right you are...",
    [6] = "Blast it... Surely thought I stumped you...",
    [7] = "The next one will be more of a challenge..."
}

S.ANNOUNCE_SDF_JACK_OF_THE_GREEN_BOOK_OF_GALLOWMERE_RIDDLES_WRONG = {
    [0] = "WRONG",
    [1] = "Not even close! Try again...",
    [2] = "Are you even trying?...",
    [3] = "Afraid not...",
    [4] = "Close... not really...",
    [5] = "Eh? No no that is not it...",
    [6] = "Simply...No...",
    [7] = "Good attempt, but poor answer..."
}

S.ANNOUNCE_SDF_JACK_OF_THE_GREEN_BOOK_OF_GALLOWMERE_RIDDLES_REWARD = {
    [0] = "Very well take your reward...",
    [1] = "Take this as your reward...",
    [2] = "As the deal, Riddle for Treasure...",
    [3] = "Take it, its yours...",
    [4] = "A deal is a deal...",
    [5] = "You bested me...Now take it...",
    [6] = "Go ahead and fill your pockets..."
}

S.ANNOUNCE_SDF_JACK_OF_THE_GREEN_BOOK_OF_GALLOWMERE_RIDDLES_REWARD_BONUS = {
    [0] = "Very well take your reward, and a little extra!",
    [1] = "Take this as your reward, as well as something special!",
    [2] = "As the deal, Riddle for Treasure... along with an added trinket!",
    [3] = "Take it, its yours... Oh and this too!",
    [4] = "A deal is a deal...Take this as well!",
    [5] = "You bested me...Now take it...and this!",
    [6] = "Go ahead and fill your pockets... This too if you have the space!"
}

S.ANNOUNCE_SDF_JACK_OF_THE_GREEN_BOOK_OF_GALLOWMERE_RIDDLES_RESET = "I was lost in thought...\nNow where were we?..."
S.ANNOUNCE_SDF_JACK_OF_THE_GREEN_BOOK_OF_GALLOWMERE_RIDDLES_BEMUSED = "What is that?...\nMy mind is a little fuzzy...\nNow where were we?..."


S.ANNOUNCE_SDF_ASGARD_GOLEM_ACTIVATE_PUNCH_SINGLE = {
"INITIATE: [Barrier Knuckle]",
"INITIATE: [Iron Fist]",
"INITIATE: [Barrier Fist]"
}

S.ANNOUNCE_SDF_ASGARD_GOLEM_ACTIVATE_MODE_CHANGE = "OPERATION: [Mode Change]"

S.ANNOUNCE_SDF_ASGARD_GOLEM_ACTIVATE_PUNCH_AOE = {
"INITIATE: [Barrier Storm]",
"INITIATE: [Spread Barrier]"
}

S.ANNOUNCE_SDF_ASGARD_GOLEM_ACTIVATE_TAUNT = "ENGAUGE: [Provoke]"
S.ANNOUNCE_SDF_ASGARD_GOLEM_ACTIVATE_TELEPORT = "ENGAUGE: [Relocation]"

S.ANNOUNCE_SDF_ASGARD_GOLEM_ACTIVATE_TYPE_B = "OPTIMIZE DATA: [High Powered Barrier]"
S.ANNOUNCE_SDF_ASGARD_GOLEM_ACTIVATE_TYPE_A = "OPTIMIZE DATA: [Friendly Fire]"
S.ANNOUNCE_SDF_ASGARD_GOLEM_ACTIVATE_TYPE_A_AND_TYPE_C = "OPTIMIZE DATA: [Friendly Fire And System Recovery]"
S.ANNOUNCE_SDF_ASGARD_GOLEM_ACTIVATE_TYPE_C = "OPTIMIZE DATA: [System Recovery]"

S.ANNOUNCE_SDF_ASGARD_GOLEM_OPTIMIZE_DATA_INSTALL = "OPTIMIZE DATA: [Installed]"

S.ANNOUNCE_SDF_ASGARD_GOLEM_SLEEP_START = "ENTERING: [Rest Mode]"
S.ANNOUNCE_SDF_ASGARD_GOLEM_SLEEP_END = "LEAVING: [Rest Mode]"

S.ANNOUNCE_SDF_PUMPKING_SEED_POD_NAME = {
    [0] = "Wilted Pumpking Seed Pod",
    [1] = "Flourishing Pumpking Seed Pod",
    [2] = "Frigid Pumpking Seed Pod"
}

S.ANNOUNCE_SDF_SHADOW_TALISMAN_NAME = {
    [0] = "Malevolent Shadow Talisman",
    [1] = "Benevolent Shadow Talisman",
}




S.ANNOUNCE_SDF_PROFESSORS_LAB_GENERATOR_NO_TRADE = "I need to remove the lid first."

--Professors Lab Projector Screen Locations
S.ANNOUNCE_SDF_PROFESSORS_LAB_PROJECTOR_SCREEN_GREETINGS = {
"Oh, seems a Chalice Altar can be found at...",
"A Chalice Altar can be found at...",
"If looking at this correctly, a Chalice Altar can be found at...",
"If I am here, a Chalice Altar can be found at..."
}

S.ANNOUNCE_SDF_PROFESSORS_LAB_PROJECTOR_SCREEN_CONTINUE = {
"Another Chalice Altar can be found at...",
"The next Chalice Altar can be found at...",
"Nextly a Chalice Altar can be found at..."
}

S.ANNOUNCE_SDF_PROFESSORS_LAB_PROJECTOR_SCREEN_LOCATIONS = {
    [0] = "I have already collected from all the Chalice Altars.",
    [1] = "'The Graveyard'",
    [2] = "'The Pumpkin Gorge'",
    [3] = "'The Pig Kingdom'",
    [4] = "'The Grasslands'",
    [5] = "'The Forest'",
    [6] = "'The Dragonfly Desert'",
    [7] = "'The Marsh'",
    [8] = "'The Desert Oasis'",
    [9] = "'The Asylum Grounds'",
    [10] = "'The Lunar Baths'",
    [11] = "'The Sinkhole Oasis'",
    [12] = "'The Red Mushtree Forest'",
    [13] = "'The Green Mushtree Forest'",
    [14] = "'The Blue Mushtree Forest'",
    [15] = "'The Lunar Grotto'",
    [16] = "'The Stalagmite Terrain'",
    [17] = "'The Bat Caves'",
    [18] = "'The Rabbit City'",
    [19] = "'The Labyrinth'",
    [20] = "'The Ruined City'"
}

S.ANNOUNCE_SDF_PROFESSORS_LAB_PILLAR_OFF = "Can hear a faint hum coming from its hollow piping."
S.ANNOUNCE_SDF_PROFESSORS_LAB_PILLAR_ON = "Pressured energy seems to surge through its pipes."

S.ANNOUNCE_SDF_PROFESSORS_LAB_PROJECTOR_SCREEN_OFF = "A map of no where."
S.ANNOUNCE_SDF_PROFESSORS_LAB_PROJECTOR_SCREEN_ON = "Shows the locations of Unclaimed Chalice Altars..."

--Tesla Transformer Status
S.ANNOUNCE_SDF_PROFESSORS_LAB_TESLA_STATUS = {
    [0] = "Concentrates energy into a shocking matter.",
    [1] = "Concentration levels at 20%.",
    [2] = "Concentration levels at 40%.",
    [3] = "Concentration levels at 60%.",
    [4] = "Concentration levels at 80%.",
    [5] = "Concentration levels at 100%. Max Power!"
}

S.ANNOUNCE_SDF_CANE_STICK_NAME = {
    ["empty"] = "Cane Stick",
    ["red"] = "Red Gem Cane Stick",
    ["blue"] = "Blue Gem Cane Stick",
    ["purple"] = "Purple Gem Cane Stick",
    ["yellow"] = "Yellow Gem Cane Stick",
    ["green"] = "Green Gem Cane Stick",
    ["orange"] = "Orange Gem Cane Stick",
    ["opal"] = "Opal Gem Cane Stick"
}

S.ANNOUNCE_SDF_CANE_STICK_DESC = {
    ["empty"] = "Depleted Fountain of Rejuvenation",
    ["red"] = "Spring of life energy has been exhasusted!",
    ["blue"] = "Trickling spring of life energy!",
    ["purple"] = "Weeping spring of life energy!",
    ["yellow"] = "Flowing spring of life energy!",
    ["green"] = "Teeming spring of life energy!",
    ["orange"] = "Spouting spring of life energy!",
    ["opal"] = "Gushing spring of life energy!"
}

--ANNOUNCE_NODANIELHELMET = announcement said when a character tries to put on Daniel's Helmet is forced to take it right back off.
C.GENERIC.ANNOUNCE_NODANIELHELMET = "Looks badly worn and used..." --generic = Wilson and mod characters with no quote written.

--ANNOUNCE_NODANIELARM = announcement said when a character tries to equip Daniel's Arm is forced to take it right back off.
C.GENERIC.ANNOUNCE_NODANIELARM = "No way I am touching that lost Arm..." --generic = Wilson and mod characters with no quote written.

--ANNOUNCE_NORUNEHOLDER = announcement said when a character tries to put on Daniel's Rune Holder is forced to take it right back off.
C.GENERIC.ANNOUNCE_NORUNEHOLDER = "No living mortal could carry this..." --generic = Wilson and mod characters with no quote written.

--ANNOUNCE_RESTOREDVELLUMNOMEND = announcement said when a character tries to use the restored vellum on completed entry.
C.GENERIC.ANNOUNCE_RESTOREDVELLUMNOMEND = "No more paper fits... Seems this Entry is completed."

--ANNOUNCE_ANUBISSTONENOENERGY = announcement said when a character tries to use the Anubis Stone at low energy.
C.GENERIC.ANNOUNCE_ANUBISSTONENOENERGY = "Not enough Energy..." --generic = Wilson and mod characters with no quote written.

--ANNOUNCE_ANUBISSTONENOTARGET = announcement said when a character tries to use the Anubis Stone at wrong target.
C.GENERIC.ANNOUNCE_ANUBISSTONENOTARGET = "No effect on the Living..." --generic = Wilson and mod characters with no quote written.

--ANNOUNCE_ASGARDGOLEMGIANTSOCARINAONSLEEPING = announcement said when a character tries to use the Asgard Golem Giants Ocarina while Asgard Golem sleeping.
C.GENERIC.ANNOUNCE_ASGARDGOLEMGIANTSOCARINAONSLEEPING = "Seems the giant is resting..." --generic = Wilson and mod characters with no quote written.

--ANNOUNCE_ASGARDGOLEMGIANTSOCARINAONTELEPORTCOOLDOWN = announcement said when a character tries to use the Asgard Golem Giants Ocarina on teleport cooldown.
C.GENERIC.ANNOUNCE_ASGARDGOLEMGIANTSOCARINAONTELEPORTCOOLDOWN = "Seems the giant needs more time before orders..." --generic = Wilson and mod characters with no quote written.

--ANNOUNCE_ASGARDGOLEMGIANTSOCARINAONSPAWNCOOLDOWN = announcement said when a character tries to use the Asgard Golem Giants Ocarina on respawn cooldown.
C.GENERIC.ANNOUNCE_ASGARDGOLEMGIANTSOCARINAONSPAWNCOOLDOWN = "Seems the giant continues to sleep..." --generic = Wilson and mod characters with no quote written.

--ANNOUNCE_ASGARDGOLEMGIANTSOCARINAINVALIDLAND = announcement said when a character tries to use the Asgard Golem Giants Ocarina on invalid land.
C.GENERIC.ANNOUNCE_ASGARDGOLEMGIANTSOCARINAINVALIDLAND = "Seems the giant can reach this area..." --generic = Wilson and mod characters with no quote written.

--ANNOUNCE_ASGARDGOLEMOPTIMIZEDATAINSTALLFAIL = announcement said when a character tries to use the Asgard Golem Optimize Data Install Fail.
C.GENERIC.ANNOUNCE_ASGARDGOLEMOPTIMIZEDATAINSTALLFAIL = "Already Installed!" --generic = Wilson and mod characters with no quote written.


--ANNOUNCE_NODANIELSUIT = announcement said when a character tries to put on Daniel's suit or armor and is forced to take it right back off.
C.GENERIC.ANNOUNCE_NODANIELSUIT = "It doesn't fit me quite right..." --generic = Wilson and mod characters with no quote written.
C.WILLOW.ANNOUNCE_NODANIELSUIT = "It looks too old-fashioned."
C.WOLFGANG.ANNOUNCE_NODANIELSUIT = "My muscles do not fit!"
C.WENDY.ANNOUNCE_NODANIELSUIT = "I can't wear that. Aura of these items is strange."
C.WX78.ANNOUNCE_NODANIELSUIT = "INADEQUATE ARMOR PARAMETERS"
C.WICKERBOTTOM.ANNOUNCE_NODANIELSUIT = "There's no way I'll wear these antiques!"
C.WOODIE.ANNOUNCE_NODANIELSUIT = "Uncomfortable for chopping things."
C.WAXWELL.ANNOUNCE_NODANIELSUIT = "I prefer my stylish clothing."
C.WATHGRITHR.ANNOUNCE_NODANIELSUIT = "Warrior like me doesn't need it!"
C.WEBBER.ANNOUNCE_NODANIELSUIT = "We don't like this. No can do."

--Mullock Cheif Memorial
--ANNOUNCE_MULLOCKCHEIFMEMORIALMOUNTNODIG = announcement said when a character tries to dig Mullock Cheif Memorial Mount with out Spade.
C.GENERIC.ANNOUNCE_MULLOCKCHEIFMEMORIALMOUNTNODIG1 = "This earth is pretty tough..." --generic = Wilson and mod characters with no quote written.
C.GENERIC.ANNOUNCE_MULLOCKCHEIFMEMORIALMOUNTNODIG2 = "The hole is not going deeper..." --generic = Wilson and mod characters with no quote written.
C.GENERIC.ANNOUNCE_MULLOCKCHEIFMEMORIALMOUNTNODIG3 = "I am going to need a bigger Shovel..." --generic = Wilson and mod characters with no quote written.

--Names
N.SDF_HELMET = "Dan's Helmet"
N.SDF_RUNE_HOLDER = "Rune Holder"
N.SDF_MORTEN = "Morten the Earthworm"
N.SDF_CHALICE_HALL_OF_HEROES = "Chalice of Souls"
N.SDF_CHALICE_RUNESTONE = "Runestone"
N.SDF_CHALICE_ALTAR = "Chalice of Souls Altar"
N.SDF_CHALICE_OF_SOULS = "Chalice of Souls"
N.SDF_SOUL_HELMET = "Soul Helmet"
N.SDF_WITCH_TALISMAN = "Witch Talisman"
N.SDF_WITCH_CAULDRON = "Witch Cauldron"
N.SDF_BOOK_OF_GALLOWMERE = "Book of Gallowmere"
N.SDF_BOOK_OF_GALLOWMERE_DAMAGED = "Trampled Book of Gallowmere"
N.SDF_BOOK_OF_GALLOWMERE_ENTRIES_INVENTORY = "Entry: Inventory"
N.SDF_BOOK_OF_GALLOWMERE_ENTRIES_FRIENDLIES = "Entry: Friendlies"
N.SDF_BOOK_OF_GALLOWMERE_ENTRIES_ENEMIES = "Entry: Enemies"
N.SDF_BOOK_OF_GALLOWMERE_ENTRIES_BOSSES = "Entry: Bosses"
N.SDF_BOOK_OF_GALLOWMERE_RESTORED_VELLUM = "Restored Vellum of The Book of Gallowmere"
N.SDF_CHEST_RUNESTONE = "Wooden Chest"
N.SDF_CHEST_WOODEN = "Wooden Chest"
N.SDF_CHEST_WOODEN_EMPTY = "Splintered Wooden Chest"
N.SDF_CHEST_SKULL = "Skull Chest"
N.SDF_CHEST_SKULL_EMPTY = "Crestfallen Skull Chest"
N.SDF_CHEST_PUMPKIN = "Wooden Chest"
N.SDF_CHEST_PUMPKIN_EMPTY = "Smashed Wooden Chest"
N.SDF_CHEST_LIFEBOTTLE1 = "Wooden Chest"
N.SDF_CHEST_LIFEBOTTLE1_EMPTY = "Discovered Wooden Chest"
N.SDF_CHEST_LIFEBOTTLE2 = "Wooden Chest"
N.SDF_CHEST_LIFEBOTTLE2_EMPTY = "Revealed Wooden Chest"
N.SDF_CHEST_RIDDLE = "Wooden Chest"
N.SDF_CHEST_MAZE = "Wooden Chest"
N.SDF_CHEST_MAZE_EMPTY = "Foliage Wooden Chest"
N.SDF_CHEST_HAUNTED = "Wooden Chest"
N.SDF_CHEST_HAUNTED_EMPTY = "Seized Wooden Chest"
N.SDF_CHEST_KINGDOM = "Wooden Chest"
N.SDF_CHEST_KINGDOM_EMPTY = "Ravaged Wooden Chest"
N.SDF_ROCK = "Boulder"
N.SDF_WALL_WOOD = "Wooden Wall"
N.SDF_WALL_STONE = "Stone Wall"
N.SDF_WALL_STONE_PILLAR = "Stone Wall Pillar"
N.SDF_WALL_HEDGE_BLOCK = "Hedge Wall"
N.SDF_WALL_HEDGE_DECOR = "Hedge Decor"
N.SDF_WALL_OVERGROWN = "Overgrown Wall"
N.SDF_MARBLE_PILLAR = "Marble Pillar"
N.SDF_SUPPORT_STONE_PILLAR = "Stone Support Pillar"
N.SDF_HAUNTED_RUINS_GATE = "Haunted Ruins Gate"
N.SDF_HAUNTED_RUINS_LAVA_POND = "Lava Pond"
N.SDF_HAUNTED_RUINS_LAVA_POND_ROCK = "Rock"
N.SDF_HAUNTED_RUINS_THRONE = "Throne of Gallowmere"
N.SDF_STATUE = "Hall of Heroes Statue"
N.SDF_INFORMATION_GARGOYLE = "Information Gargoyle"
N.SDF_MERCHANT_GARGOYLE = "Merchant Gargoyle"
N.SDF_SHOP_GARGOYLE = "Shop Gargoyle"
N.SDF_MULLOCK_CHIEF_MEMORIAL = "Mullock Chief's Memorial"
N.SDF_MULLOCK_CHIEF_MEMORIAL_GRAVE = "Freshly Dug Grave"
N.SDF_MULLOCK_CHIEF_MEMORIAL_MOUND = "Grave"
N.SDF_GALLOWMERE_KNIGHT = "Knight of Gallowmere"
N.SDF_GALLOWMERE_SQUIRE = "Squire of Gallowmere"
N.SDF_KING_PEREGRIN = "King Peregrin"
N.SDF_KING_PEREGRINS_CROWN = "King Peregrin's Crown"
N.SDF_KING_PEREGRINS_CROWN_LOST = "King Peregrin's Lost Crown"
N.SDF_STONE_GOLEM_ARMORED = "Armored Stone Golem"
N.SDF_STONE_GOLEM_CORE = "Core Stone Golem"
N.SDF_LAVA_GOLEM = "Lava Golem"
N.SDF_ASGARD_GOLEM = "Asgard"
N.SDF_ASGARD_GOLEM_LAVA_GOLEM = "Lava Golem"
N.SDF_ASGARD_GOLEM_GIANTS_OCARINA = "Giant's Ocarina"
N.SDF_ASGARD_GOLEM_OPTIMIZE_DATA_DAMAGED = "Optimize Data: Damaged"
N.SDF_ASGARD_GOLEM_OPTIMIZE_DATA_TYPE_A = "Optimize Data: Type-A"
N.SDF_ASGARD_GOLEM_OPTIMIZE_DATA_TYPE_C = "Optimize Data: Type-C"
N.SDF_ASGARD_GOLEM_GIANTS_OCARINA = "Giant's Ocarina"
N.SDF_PUMPKIN_KING = "Pumpkin King"
N.SDF_PUMPKIN_KING_PLANT = "Pumpkin King"
N.SDF_PUMPKIN_KING_VINE = "Pumpking Vine"
N.SDF_PUMPKIN_KING_VINE_END = "Pumpking Vine"
N.SDF_PUMPKING_CREEPER = "Pumpking Creeper"
N.SDF_PUMPKING_CREEPER_PLANT = "Pumpking Plant"
N.SDF_PUMPKING_CREEPER_PLANT_SPAWNER = "Pumpking Plant"
N.SDF_PUMPKING_BOMB = "Pumpking Bomb"
N.SDF_PUMPKING_BOMB_PLANT = "Pumpking Plant"
N.SDF_PUMPKING_BOMB_PLANT_SPAWNER = "Pumpking Plant"
N.SDF_PUMPKING_GOURD = "Pumpking Gourd"
N.SDF_PUMPKING_GOURD_VINE = "Pumpking Gourd Vine"
N.SDF_PUMPKING_GOURD_PLANT = "Pumpking Plant"
N.SDF_PUMPKING_GOURD_PLANT_SPAWNER = "Pumpking Plant"
N.SDF_PUMPKIN_CREEPER = "Pumpkin Creeper"
N.SDF_PUMPKIN_CREEPER_PLANT = "Skulking Pumpkin Plant"
N.SDF_PUMPKIN_BOMB = "Pumpkin Bomb"
N.SDF_PUMPKIN_BOMB_PLANT = "Unstable Pumpkin Plant"
N.SDF_PUMPKIN_GOURD = "Pumpkin Gourd"
N.SDF_PUMPKIN_GOURD_VINE = "Pumpkin Gourd Vine"
N.SDF_PUMPKIN_GOURD_PLANT = "Writhing Pumpkin Plant"
N.SDF_PUMPKIN_CREEPER_SEEDS = "Skulking Pumpkin Seeds"
N.SDF_PUMPKIN_BOMB_SEEDS = "Unstable Pumpkin Seeds"
N.SDF_PUMPKIN_GOURD_SEEDS = "Writhing Pumpkin Seeds"
N.SDF_PUMPKIN_GORGE_CREEPER = "Pumpkin Patch"
N.SDF_PUMPKIN_GORGE_BUSH = "Rasping Vines"
N.SDF_PUMPKIN_GORGE_ROOTS = "Stocky Roots"
N.SDF_PUMPKIN_GORGE_PLANT = "Pumpkin Plant"
N.SDF_PUMPKIN_GORGE_FARMLAND_DEBRIS = "Garden Detritus"
N.SDF_PUMPKIN_GORGE_PONDFISH = "Gasping Pond Fish"
N.SDF_PUMPKIN_GORGE_PONDFISH_DEAD = "Asphyxiated Pond Fish"
N.SDF_PUMPKIN_GORGE_PONDFISH_COOKED = "Smothered Pond Fish"
N.SDF_PUMPKIN_GORGE_POND = "Sunken Pond"
N.SDF_PUMPKIN_GORGE_WELL = "Dried Well"
N.SDF_PUMPKIN_GORGE_WELL_DOOR_EXIT = "Hanging Vine"
N.SDF_PUMPKIN_GORGE_WELL_GLOWSHROOM1 = "Glowshroom"
N.SDF_PUMPKIN_GORGE_WELL_GLOWSHROOM2 = "Glowshroom"
N.SDF_PUMPKIN_GORGE_WELL_MERCHANT_GARGOYLE = "Merchant Gargoyle"
N.SDF_PUMPKIN_GORGE_WELL_VINE = "Thwarting Vine"
N.SDF_KING_PEREGRINS_CROWN = "King Peregrin's Crown"
N.SDF_KING_PEREGRINS_CROWN_LOST = "King Peregrin's Lost Crown"
N.SDF_SHADOW_DEMON_TOMB_ALTARFX = "Shadow Demon Altar"
N.SDF_SHADOW_DEMONETTE_PENUMBRA = "Shadow Demonette Penumbra"
N.SDF_SHADOW_DEMONETTE_UMBRA = "Shadow Demonette Umbra"
N.SDF_SHADOW_ARTEFACT = "Shadow Artefact"
N.SDF_CARNIVAL_TOKEN = "Carnival Token"
N.SDF_TIME_RUNE_HALL_OF_HEROES = "Time Rune Ring"
N.SDF_TIME_RUNE = "Perpetual Time Rune"
N.SDF_MOON_RUNE = "Moon Rune"
N.SDF_EARTH_RUNE = "Earth Rune"
N.SDF_STAR_RUNE = "Star Rune"
N.SDF_CHAOS_RUNE = "Chaos Rune"
N.SDF_CHAOS_ROCK = "Anomalous Mass"
N.SDF_CHAOS_ROCK2 = "Peculiar Agglomeration"
N.SDF_JACK_OF_THE_GREEN = "Jack of the Green"
N.SDF_JACK_OF_THE_GREEN_FLOWER = "Quaint Flower"
N.SDF_JACK_OF_THE_GREEN_VASE = "Fancy Vase"
N.SDF_ASYLUM_GROUNDS_KEEPER_GRAVE = "Freshly Dug Grave"
N.SDF_ASYLUM_GROUNDS_KEEPER = "Mad Monk"
N.SDF_ASYLUM_GROUNDS_GATE = "Asylum Grounds Gate"
N.SDF_ASYLUM_GROUNDS_BARRIER = "Stone Wall"
N.SDF_JACK_OF_THE_GREEN_RIDDLE_STAR = "Twinkling Hedge"
N.SDF_JACK_OF_THE_GREEN_RIDDLE_FACE_SLAB = "Tragedy/Comedy Slab"
N.SDF_JACK_OF_THE_GREEN_RIDDLE_CLOWN = "Lamenting Hedge"
N.SDF_JACK_OF_THE_GREEN_RIDDLE_CHAOS_RUNE_CRUMBLED = "Chaos Rune Jumble"
N.SDF_JACK_OF_THE_GREEN_RIDDLE_CHAOS_RUNE_FRAGMENT = "Chaos Rune Fragment"
N.SDF_JACK_OF_THE_GREEN_RIDDLE_MOLEWORM = "Moleworm Hedge"
N.SDF_JACK_OF_THE_GREEN_RIDDLE_MOLEWORM_HILL = "Overgrown Heap"
N.SDF_JACK_OF_THE_GREEN_RIDDLE_KOALEFANT = "Timid Hedge"
N.SDF_JACK_OF_THE_GREEN_RIDDLE_FIREPIT = "Asylum Grounds Firepit"
N.SDF_JACK_OF_THE_GREEN_SHADOW_TALISMAN = "Shadow Talisman"
N.SDF_JACK_OF_THE_GREEN_CHESS_ROOK = "Overgrown Rook"
N.SDF_JACK_OF_THE_GREEN_CHESS_KNIGHT = "Overgrown Knight"
N.SDF_JACK_OF_THE_GREEN_CHESS_BISHOP = "Overgrown Bishop"
N.SDF_PROFESSORS_LAB = "Hatch"
N.SDF_PROFESSORS_LAB_DOOR_EXIT = "Hatch"
N.SDF_PROFESSORS_LAB_LIGHT = "Incandescent Illuminator"
N.SDF_PROFESSORS_LAB_WALL_PILLAR = "Pressure Gauged Pillar"
N.SDF_PROFESSORS_LAB_WALL_PILLAR_IN = "Pressure Gauged Pillar"
N.SDF_PROFESSORS_LAB_PROJECTOR_SCREEN = "Pinpoint Projector Screen"
N.SDF_PROFESSORS_LAB_PROJECTOR = "Pinpoint Projector"
N.SDF_PROFESSORS_LAB_GENERATOR = "Charcoal Converter"
N.SDF_PROFESSORS_LAB_TESLA = "Tesla Transformer"
N.SDF_SPIV = "The Spiv"

N.SDF_HEALTHFOUNTAIN = "Fountain of Rejuvenation"
N.SDF_LIFEBOTTLE = "Life Bottle"
N.SDF_ENERGYVIAL = "Energy Vial"
N.SDF_ACORN_CRACKED = "Cracked Birchnut"

N.SDF_ARM = "Dan's Arm"
N.SDF_ARM_THROWN = "Dan's Arm"
N.SDF_SMALL_SWORD = "Small Sword"
N.SDF_BROAD_SWORD = "Broad Sword"
N.SDF_ENCHANTED_SWORD = "Enchanted Sword"
N.SDF_MAGIC_SWORD = "Magic Sword"
N.SDF_WODENS_BRAND = "Woden's Brand"
N.SDF_CLUB = "Club"
N.SDF_HAMMER = "Hammer"
N.SDF_AXE = "Axe"
N.SDF_AXE_THROWN = "Axe"
N.SDF_SPADE = "Spade"
N.SDF_THROWING_DAGGERS = "Throwing Daggers"
N.SDF_CROSSBOW = "Crossbow"
N.SDF_STANDARD_BOLTS = "Standard Bolts"
N.SDF_LONGBOW = "Longbow"
N.SDF_STANDARD_ARROWS = "Standard Arrows"
N.SDF_FLAMING_LONGBOW = "Flaming Longbow"
N.SDF_FLAMING_ARROWS = "Flaming Arrows"
N.SDF_MAGIC_LONGBOW = "Magic Longbow"
N.SDF_MAGICAL_ARROWS = "Magical Arrows"
N.SDF_SPEAR = "Spear"
N.SDF_LIGHTNING_GAUNTLET = "Lightning Gauntlet"
N.SDF_LIGHTNING = "Lightning"
N.SDF_GOODLIGHTNING = "Good Lightning"
N.SDF_CHICKEN_DRUMSTICK = "Chicken Drumstick"
N.SDF_CANE_STICK = "Cane Stick"
N.SDF_FLAMING_CROSSBOW = "Flaming Crossbow"
N.SDF_FLAMING_BOLTS = "Flaming Bolts"
N.SDF_PISTOL = "Pistol"
N.SDF_STANDARD_BULLETS = "Standard Bullets"
N.SDF_BLUNDERBUSS = "Blunderbuss"
N.SDF_STANDARD_BUCKSHOTS = "Standard Buckshots"
N.SDF_BOMBS = "Bombs"
N.SDF_GATLING_GUN = "Gatling Gun"
N.SDF_STANDARD_MUNITIONS = "Standard Munitions"

N.SDF_COPPER_SHIELD = "Copper Shield"
N.SDF_SILVER_SHIELD = "Silver Shield"
N.SDF_GOLD_SHIELD = "Gold Shield"

N.SDF_VICTORIAN_SUIT = "Victorian Suit"
N.SDF_GOLD_ARMOR = "Golden Armor"
N.SDF_DRAGON_POTION = "Dragon Potion"
N.SDF_DRAGON_POTION_EMPTY = "Emptied Dragon Potion"
N.SDF_DRAGON_POTION_DRAGONBREATH = "Dragon Breath"
N.SDF_DRAGON_POTION_DRAGONFIRE = "Dragon Fire"
N.SDF_ANUBIS_STONE = "Anbuis Stone"
N.SDF_ANUBIS_STONE_NECROTIC_TOUCH = "Necrotic Touch"
N.SDF_ANUBIS_STONE_PART1 = "Anbuis Stone Piece"
N.SDF_ANUBIS_STONE_PART2 = "Anbuis Stone Piece"
N.SDF_ANUBIS_STONE_PART3 = "Anbuis Stone Piece"
N.SDF_ANUBIS_STONE_PART4 = "Anbuis Stone Piece"

--Recipe Descriptions
R.SDF_WITCH_TALISMAN = "An instrument used to reset a Chalice Altar which the Chalice has been lost or not offered, or restore other lost time sensitive items."
R.SDF_BOOK_OF_GALLOWMERE = "A bestiary for beasts and non-beasts alike."
R.SDF_SHOP_GARGOYLE = "The perfect adventure companion, providing various services."

R.SDF_SMALL_SWORD = "Nearly blunt. swing it hard!"
R.SDF_BROAD_SWORD = "All tho not very enchanting, it's enchantable!"
R.SDF_ENCHANTED_SWORD = "Just add magic!"
R.SDF_MAGIC_SWORD = "Carried by mighty warriors. And you."
R.SDF_WODENS_BRAND = "Even Woden's mighty grip is no match to the Merchants quick handed Imps."
R.SDF_CLUB = "Bash with it! Burn with it! But beware, one bash too many and it will break."
R.SDF_HAMMER = "Use to crack skulls or walnuts."
R.SDF_AXE = "Chops down trees and non-trees."
R.SDF_THROWING_DAGGERS = "Throw these away."
R.SDF_CROSSBOW = "It's got rapid fire, complicated parts, and a bolt decision."
R.SDF_STANDARD_BOLTS = "You could poke an eye out with this thing."
R.SDF_LONGBOW = "Long distance, but has its drawbacks."
R.SDF_STANDARD_ARROWS = "Worth a shot."
R.SDF_FLAMING_LONGBOW = "Ready... Aim.. Fire!"
R.SDF_FLAMING_ARROWS = "The perfect match!"
R.SDF_MAGIC_LONGBOW = "Best bow by a long shot."
R.SDF_MAGICAL_ARROWS = "Growing toxic by the day."
R.SDF_SPEAR = "Straight to the point."
R.SDF_LIGHTNING_GAUNTLET = "Great for networking!"
R.SDF_LIGHTNING = "Shocking isn't it?"
R.SDF_GOODLIGHTNING = "Feel good tingles!"
R.SDF_CANE_STICK = "No modern knight should be seen without one!"
R.SDF_FLAMING_CROSSBOW = "It's got rapid fire, and well... more fire!"
R.SDF_FLAMING_BOLTS = "Looks lit!"
R.SDF_PISTOL = "Locked and loaded!"
R.SDF_STANDARD_BULLETS = "Aim and seek!"
R.SDF_BLUNDERBUSS = "With knockout knockback action!"
R.SDF_STANDARD_BUCKSHOTS = "A blowout!"
R.SDF_BOMBS = "Bang for your buck!"
R.SDF_GATLING_GUN = "Awesome destructive power at the touch of a button!"
R.SDF_STANDARD_MUNITIONS = "Firing on all cylinders!"

R.SDF_COPPER_SHIELD = "Less protective plate, more dinner plate."
R.SDF_SILVER_SHIELD = "Penultimate protection."
R.SDF_GOLD_SHIELD = "Gold standard in self-defense."

R.SDF_VICTORIAN_SUIT = "Like a true gentleman!"
R.SDF_GOLD_ARMOR = "This armor is from the past and future! Time travel is so lucrative."
R.SDF_ANUBIS_STONE = "Mighty power of reanimation and healing pulse through its crystalline structure."

------------------------------------------
--Examinations (SDF's only quotes written for that prefab!)
STRINGS.CHARACTERS.SDF.DESCRIBE.SDF_HELMET = "Weak against arrows... And everything else."
STRINGS.CHARACTERS.SDF.DESCRIBE.SDF_RUNE_HOLDER = "A Hand that acts like a Lock..."
STRINGS.CHARACTERS.SDF.DESCRIBE.SDF_MORTEN = "Always willing to help and thinks my skull is cozy!"
STRINGS.CHARACTERS.SDF.DESCRIBE.SDF_CHALICE_HALL_OF_HEROES = "A massive Goblet filled with collection of all the gathered soul chalices."
STRINGS.CHARACTERS.SDF.DESCRIBE.SDF_CHALICE_RUNESTONE = "A large stone slab engraved with a cup, a showing of ones heroism is required!"
STRINGS.CHARACTERS.SDF.DESCRIBE.SDF_CHALICE_ALTAR = "Houses a cup that is filled with ones heroism!"
STRINGS.CHARACTERS.SDF.DESCRIBE.SDF_CHALICE_OF_SOULS = "Empty... not a single soul."
STRINGS.CHARACTERS.SDF.DESCRIBE.SDF_SOUL_HELMET = "A lost soul has lingered... Should I find its eternal rest?"
STRINGS.CHARACTERS.SDF.DESCRIBE.SDF_WITCH_TALISMAN = "Witches have been known to offer help to the questing adventurer."
STRINGS.CHARACTERS.SDF.DESCRIBE.SDF_WITCH_CAULDRON = "Often a sign that a witch resided nearby..."
STRINGS.CHARACTERS.SDF.DESCRIBE.SDF_BOOK_OF_GALLOWMERE = "Reading is a novel idea..."
STRINGS.CHARACTERS.SDF.DESCRIBE.SDF_BOOK_OF_GALLOWMERE_DAMAGED = "This is simply tear-rible!"
STRINGS.CHARACTERS.SDF.DESCRIBE.SDF_BOOK_OF_GALLOWMERE_ENTRIES_INVENTORY = "All things kept in your Pocket."
STRINGS.CHARACTERS.SDF.DESCRIBE.SDF_BOOK_OF_GALLOWMERE_ENTRIES_FRIENDLIES = "All things kept in your Heart."
STRINGS.CHARACTERS.SDF.DESCRIBE.SDF_BOOK_OF_GALLOWMERE_ENTRIES_ENEMIES = "All things kept at Swords length."
STRINGS.CHARACTERS.SDF.DESCRIBE.SDF_BOOK_OF_GALLOWMERE_ENTRIES_BOSSES = "All things kept Locked away."
STRINGS.CHARACTERS.SDF.DESCRIBE.SDF_BOOK_OF_GALLOWMERE_RESTORED_VELLUM = "Used to Mend a paper cut!"
STRINGS.CHARACTERS.SDF.DESCRIBE.SDF_CHEST_RUNESTONE = "Coffer of gifts from the Fallen Heroes!"
STRINGS.CHARACTERS.SDF.DESCRIBE.SDF_CHEST_WOODEN = "Spiked wooden box filled with spoils of war."
STRINGS.CHARACTERS.SDF.DESCRIBE.SDF_CHEST_WOODEN_EMPTY = "Smashed to smithereens..."
STRINGS.CHARACTERS.SDF.DESCRIBE.SDF_CHEST_SKULL = "Casket brimming with violence!"
STRINGS.CHARACTERS.SDF.DESCRIBE.SDF_CHEST_SKULL_EMPTY = "Woebegone!"
STRINGS.CHARACTERS.SDF.DESCRIBE.SDF_CHEST_LIFEBOTTLE1 = "A well hidden hoard."
STRINGS.CHARACTERS.SDF.DESCRIBE.SDF_CHEST_LIFEBOTTLE1_EMPTY = "Smashed to smithereens..."
STRINGS.CHARACTERS.SDF.DESCRIBE.SDF_CHEST_LIFEBOTTLE2 = "A concealed cache."
STRINGS.CHARACTERS.SDF.DESCRIBE.SDF_CHEST_LIFEBOTTLE2_EMPTY = "Smashed to smithereens..."
STRINGS.CHARACTERS.SDF.DESCRIBE.SDF_CHEST_PUMPKIN = "Crate with a collection of goods!"
STRINGS.CHARACTERS.SDF.DESCRIBE.SDF_CHEST_PUMPKIN_EMPTY = "Smashed to smithereens..."
STRINGS.CHARACTERS.SDF.DESCRIBE.SDF_CHEST_RIDDLE = "A paradox wrapped in an enigma!"
STRINGS.CHARACTERS.SDF.DESCRIBE.SDF_CHEST_MAZE = "Treasury of tangible things!"
STRINGS.CHARACTERS.SDF.DESCRIBE.SDF_CHEST_MAZE_EMPTY = "Leaf litter..."
STRINGS.CHARACTERS.SDF.DESCRIBE.SDF_CHEST_HAUNTED = "Coffer of curative stock."
STRINGS.CHARACTERS.SDF.DESCRIBE.SDF_CHEST_HAUNTED_EMPTY = "Ransacked... ruins of nevermore."
STRINGS.CHARACTERS.SDF.DESCRIBE.SDF_CHEST_KINGDOM = "Reserved royal reliquary!"
STRINGS.CHARACTERS.SDF.DESCRIBE.SDF_CHEST_KINGDOM_EMPTY = "Ransacked... ruins of nevermore."
STRINGS.CHARACTERS.SDF.DESCRIBE.SDF_ROCK = "Stubborn stone will not yield!"
STRINGS.CHARACTERS.SDF.DESCRIBE.SDF_WALL_WOOD = "Sturdy fireproof wood fortification!"
STRINGS.CHARACTERS.SDF.DESCRIBE.SDF_WALL_STONE = "Solid unyielding stone blockade!"
STRINGS.CHARACTERS.SDF.DESCRIBE.SDF_WALL_STONE_PILLAR = "Indomitable gaudy marble pilaster!"
STRINGS.CHARACTERS.SDF.DESCRIBE.SDF_WALL_HEDGE_BLOCK = "Leafy fire-resistant hurdle!"
STRINGS.CHARACTERS.SDF.DESCRIBE.SDF_WALL_HEDGE_DECOR = "Coiffed fireproof obstacle!"
STRINGS.CHARACTERS.SDF.DESCRIBE.SDF_WALL_OVERGROWN = "Dense unsquashable stone bar!"
STRINGS.CHARACTERS.SDF.DESCRIBE.SDF_MARBLE_PILLAR = "Stout embellished stone column!"
STRINGS.CHARACTERS.SDF.DESCRIBE.SDF_SUPPORT_STONE_PILLAR = "One of the quarter stones of this kingdom!"
STRINGS.CHARACTERS.SDF.DESCRIBE.SDF_HAUNTED_RUINS_GATE = "These heavy iron bars give way only for those seeking the King!"
STRINGS.CHARACTERS.SDF.DESCRIBE.SDF_HAUNTED_RUINS_LAVA_POND = "Don’t take the lava for granite..."
STRINGS.CHARACTERS.SDF.DESCRIBE.SDF_HAUNTED_RUINS_LAVA_POND_ROCK = "Lava-ing life on the edge..."
STRINGS.CHARACTERS.SDF.DESCRIBE.SDF_HAUNTED_RUINS_THRONE = "Now where did his royal majesty go..."
STRINGS.CHARACTERS.SDF.DESCRIBE.SDF_STATUE = "Desecrated statue of legendary warriors of Gallowmere."
STRINGS.CHARACTERS.SDF.DESCRIBE.SDF_INFORMATION_GARGOYLE = "Their clues will often be as cryptic as they are informative."
STRINGS.CHARACTERS.SDF.DESCRIBE.SDF_MERCHANT_GARGOYLE = "Services for gold! Known for dealing with the sticky-fingered Imps."
STRINGS.CHARACTERS.SDF.DESCRIBE.SDF_SHOP_GARGOYLE = "Services for gold on the go! Known for dealing with the sticky-fingered Imps."
STRINGS.CHARACTERS.SDF.DESCRIBE.SDF_MULLOCK_CHIEF_MEMORIAL = "By the sandals of the wandering hippy!"
STRINGS.CHARACTERS.SDF.DESCRIBE.SDF_MULLOCK_CHIEF_MEMORIAL_MOUND = "Here lies the famous Mullock Chief..."
STRINGS.CHARACTERS.SDF.DESCRIBE.SDF_GALLOWMERE_KNIGHT = "A fallen Knight in service to King Peregrin!"
STRINGS.CHARACTERS.SDF.DESCRIBE.SDF_GALLOWMERE_SQUIRE = "A fallen Squire in service to King Peregrin!"
STRINGS.CHARACTERS.SDF.DESCRIBE.SDF_KING_PEREGRIN = "The last monarch of Gallowmere..."
STRINGS.CHARACTERS.SDF.DESCRIBE.SDF_KING_PEREGRINS_CROWN = "A calling to those in service to the King..."
STRINGS.CHARACTERS.SDF.DESCRIBE.SDF_KING_PEREGRINS_CROWN_LOST = "Now where is his Majesty's head..."
STRINGS.CHARACTERS.SDF.DESCRIBE.SDF_STONE_GOLEM_ARMORED = "The latest in castle security!"
STRINGS.CHARACTERS.SDF.DESCRIBE.SDF_STONE_GOLEM_CORE = "The latest in castle security!"
STRINGS.CHARACTERS.SDF.DESCRIBE.SDF_LAVA_GOLEM = "Vengeful heated slag..."
STRINGS.CHARACTERS.SDF.DESCRIBE.SDF_ASGARD_GOLEM = "Fortress of the Gods..."
STRINGS.CHARACTERS.SDF.DESCRIBE.SDF_ASGARD_GOLEM_LAVA_GOLEM = "Vengeful heated slag..."
STRINGS.CHARACTERS.SDF.DESCRIBE.SDF_ASGARD_GOLEM_GIANTS_OCARINA = "Said to summon a gentle giant..."
STRINGS.CHARACTERS.SDF.DESCRIBE.SDF_ASGARD_GOLEM_OPTIMIZE_DATA_DAMAGED = "Chip off the old block..."
STRINGS.CHARACTERS.SDF.DESCRIBE.SDF_ASGARD_GOLEM_OPTIMIZE_DATA_TYPE_A = "Label reads [Emergency Mode: Friendly Fire]"
STRINGS.CHARACTERS.SDF.DESCRIBE.SDF_ASGARD_GOLEM_OPTIMIZE_DATA_TYPE_C = "Label reads [Emergency Mode: System Recovery]"
STRINGS.CHARACTERS.SDF.DESCRIBE.SDF_PUMPKIN_KING = "Is a bad influence on those young seedlings."
STRINGS.CHARACTERS.SDF.DESCRIBE.SDF_PUMPKIN_KING_PLANT = "Is a bad influence on those young seedlings."
STRINGS.CHARACTERS.SDF.DESCRIBE.SDF_PUMPKIN_KING_VINE_END = "A very painful ex-spear-ience."
STRINGS.CHARACTERS.SDF.DESCRIBE.SDF_PUMPKING_SEED_POD = "The root of the problem!"
STRINGS.CHARACTERS.SDF.DESCRIBE.SDF_PUMPKING_CREEPER = "The true horror of fruit gone bad!"
STRINGS.CHARACTERS.SDF.DESCRIBE.SDF_PUMPKING_CREEPER_PLANT = "Call to gourds!"
STRINGS.CHARACTERS.SDF.DESCRIBE.SDF_PUMPKING_CREEPER_PLANT_SPAWNER = "Once good-natured pumpkins..."
STRINGS.CHARACTERS.SDF.DESCRIBE.SDF_PUMPKING_BOMB = "The true horror of fruit gone bad!"
STRINGS.CHARACTERS.SDF.DESCRIBE.SDF_PUMPKING_BOMB_PLANT = "Call to gourds!"
STRINGS.CHARACTERS.SDF.DESCRIBE.SDF_PUMPKING_BOMB_PLANT_SPAWNER = "Once good-natured pumpkins..."
STRINGS.CHARACTERS.SDF.DESCRIBE.SDF_PUMPKING_GOURD = "The true horror of fruit gone bad!"
STRINGS.CHARACTERS.SDF.DESCRIBE.SDF_PUMPKING_GOURD_VINE = "Lashings of thrashings!"
STRINGS.CHARACTERS.SDF.DESCRIBE.SDF_PUMPKING_GOURD_PLANT = "Call to gourds!"
STRINGS.CHARACTERS.SDF.DESCRIBE.SDF_PUMPKING_GOURD_PLANT_SPAWNER = "Once good-natured pumpkins..."
STRINGS.CHARACTERS.SDF.DESCRIBE.SDF_PUMPKIN_CREEPER = "Fruits brought to life and corrupted by magic."
STRINGS.CHARACTERS.SDF.DESCRIBE.SDF_PUMPKIN_CREEPER_PLANT = "This patch is looking so gloomy."
STRINGS.CHARACTERS.SDF.DESCRIBE.SDF_PUMPKIN_BOMB = "Fruits brought to life and corrupted by magic."
STRINGS.CHARACTERS.SDF.DESCRIBE.SDF_PUMPKIN_BOMB_PLANT = "This patch is looking so gloomy."
STRINGS.CHARACTERS.SDF.DESCRIBE.SDF_PUMPKIN_GOURD = "Fruits brought to life and corrupted by magic."
STRINGS.CHARACTERS.SDF.DESCRIBE.SDF_PUMPKIN_GOURD_VINE = "Lashings of thrashings!"
STRINGS.CHARACTERS.SDF.DESCRIBE.SDF_PUMPKIN_GOURD_PLANT = "This patch is looking so gloomy."
STRINGS.CHARACTERS.SDF.DESCRIBE.SDF_PUMPKIN_CREEPER_SEEDS = "Sowing terror..."
STRINGS.CHARACTERS.SDF.DESCRIBE.SDF_PUMPKIN_BOMB_SEEDS = "Sowing anguish..."
STRINGS.CHARACTERS.SDF.DESCRIBE.SDF_PUMPKIN_GOURD_SEEDS = "Sowing woe..."
STRINGS.CHARACTERS.SDF.DESCRIBE.SDF_PUMPKIN_GORGE_CREEPER = "The seedy part of town!"
STRINGS.CHARACTERS.SDF.DESCRIBE.SDF_PUMPKIN_GORGE_BUSH = "Unyielding foliage!"
STRINGS.CHARACTERS.SDF.DESCRIBE.SDF_PUMPKIN_GORGE_ROOTS = "Parasitic radix..."
STRINGS.CHARACTERS.SDF.DESCRIBE.SDF_PUMPKIN_GORGE_PLANT = "Once good-natured pumpkins..."
STRINGS.CHARACTERS.SDF.DESCRIBE.SDF_PUMPKIN_GORGE_FARMLAND_DEBRIS = "Another one's treasure!"
STRINGS.CHARACTERS.SDF.DESCRIBE.SDF_PUMPKIN_GORGE_PONDFISH = "A lost sole."
STRINGS.CHARACTERS.SDF.DESCRIBE.SDF_PUMPKIN_GORGE_PONDFISH_DEAD = "Cod rest thy sole."
STRINGS.CHARACTERS.SDF.DESCRIBE.SDF_PUMPKIN_GORGE_PONDFISH_COOKED = "Carp-e diem!"
STRINGS.CHARACTERS.SDF.DESCRIBE.SDF_PUMPKIN_GORGE_POND = "This basin is well-grounded!"
STRINGS.CHARACTERS.SDF.DESCRIBE.SDF_PUMPKIN_GORGE_WELL = "Seems to be bone dry..."
STRINGS.CHARACTERS.SDF.DESCRIBE.SDF_PUMPKIN_GORGE_WELL_DOOR_EXIT = "A Grown life vine!"
STRINGS.CHARACTERS.SDF.DESCRIBE.SDF_PUMPKIN_GORGE_WELL_GLOWSHROOM1 = "A mushroom that helps you see things..."
STRINGS.CHARACTERS.SDF.DESCRIBE.SDF_PUMPKIN_GORGE_WELL_GLOWSHROOM2 = "A mushroom that helps you see things..."
STRINGS.CHARACTERS.SDF.DESCRIBE.SDF_PUMPKIN_GORGE_WELL_MERCHANT_GARGOYLE = "Services for gold! Known for dealing with the sticky-fingered Imps."
STRINGS.CHARACTERS.SDF.DESCRIBE.SDF_PUMPKIN_GORGE_WELL_VINE = "Lashings of thrashings!"
STRINGS.CHARACTERS.SDF.DESCRIBE.SDF_SHADOW_DEMON_ALTARFX = "An dreadful fetish which gives off feelings of doom."
STRINGS.CHARACTERS.SDF.DESCRIBE.SDF_SHADOW_DEMONETTE_PENUMBRA = "An dreadful fetish which gives off feelings of doom."
STRINGS.CHARACTERS.SDF.DESCRIBE.SDF_SHADOW_DEMONETTE_UMBRA = "An dreadful fetish which gives off feelings of doom."
STRINGS.CHARACTERS.SDF.DESCRIBE.SDF_SHADOW_ARTEFACT = "A handy key to their dank prison."
STRINGS.CHARACTERS.SDF.DESCRIBE.SDF_SHADOW_TALISMAN = "An dreadful fetish which gives off feelings of doom."
STRINGS.CHARACTERS.SDF.DESCRIBE.SDF_CARNIVAL_TOKEN = "Voucher of Carnage."
STRINGS.CHARACTERS.SDF.DESCRIBE.SDF_TIME_RUNE_HALL_OF_HEROES = "Delayed demise for those suffering with an untimely loss."
STRINGS.CHARACTERS.SDF.DESCRIBE.SDF_TIME_RUNE = "Took Time to forge!"
STRINGS.CHARACTERS.SDF.DESCRIBE.SDF_MOON_RUNE = "Forged with a hint of Moonshine!"
STRINGS.CHARACTERS.SDF.DESCRIBE.SDF_EARTH_RUNE = "Forged on Earth! Like most Runes..."
STRINGS.CHARACTERS.SDF.DESCRIBE.SDF_STAR_RUNE = "Famous Rune, forged with Star power."
STRINGS.CHARACTERS.SDF.DESCRIBE.SDF_CHAOS_RUNE = "Forged with left over Magic!"
STRINGS.CHARACTERS.SDF.DESCRIBE.SDF_CHAOS_ROCK = "Sowed by Chaos, discord was made..."
STRINGS.CHARACTERS.SDF.DESCRIBE.SDF_CHAOS_ROCK2 = "Surely just a pile of rocks of no importance..."
STRINGS.CHARACTERS.SDF.DESCRIBE.SDF_JACK_OF_THE_GREEN = "Is the master of riddles who claims the Asylum Grounds as his domain."
STRINGS.CHARACTERS.SDF.DESCRIBE.SDF_JACK_OF_THE_GREEN_FLOWER = "Its fragrance seems to dim the senses..."
STRINGS.CHARACTERS.SDF.DESCRIBE.SDF_JACK_OF_THE_GREEN_VASE = "Untouchable elegant pottery."
STRINGS.CHARACTERS.SDF.DESCRIBE.SDF_ASYLUM_GROUNDS_KEEPER_GRAVE = "What are they digging up... or placing in?"
STRINGS.CHARACTERS.SDF.DESCRIBE.SDF_ASYLUM_GROUNDS_KEEPER = "Local inhabitants of the Asylum Grounds... madden but kept both eyes."
STRINGS.CHARACTERS.SDF.DESCRIBE.SDF_ASYLUM_GROUNDS_GATE = "These heavy iron bars give way only for those entertaining Jack!"
STRINGS.CHARACTERS.SDF.DESCRIBE.SDF_ASYLUM_GROUNDS_BARRIER = "Discolored stone that blocks a path!"
STRINGS.CHARACTERS.SDF.DESCRIBE.SDF_JACK_OF_THE_GREEN_RIDDLE_STAR = "A star trimmed hedge, with all five points!"
STRINGS.CHARACTERS.SDF.DESCRIBE.SDF_JACK_OF_THE_GREEN_RIDDLE_FACE_SLAB = "Two faces, one purpose!"
STRINGS.CHARACTERS.SDF.DESCRIBE.SDF_JACK_OF_THE_GREEN_RIDDLE_CLOWN = "Ma-jest-ic!"
STRINGS.CHARACTERS.SDF.DESCRIBE.SDF_JACK_OF_THE_GREEN_RIDDLE_CHAOS_RUNE_CRUMBLED = "This rune is in ruins!"
STRINGS.CHARACTERS.SDF.DESCRIBE.SDF_JACK_OF_THE_GREEN_RIDDLE_CHAOS_RUNE_FRAGMENT = "Delectable discarded discord!"
STRINGS.CHARACTERS.SDF.DESCRIBE.SDF_JACK_OF_THE_GREEN_RIDDLE_MOLEWORM = "An insatiable scoundrel!"
STRINGS.CHARACTERS.SDF.DESCRIBE.SDF_JACK_OF_THE_GREEN_RIDDLE_MOLEWORM_HILL = "Squirmy den of wriggles!"
STRINGS.CHARACTERS.SDF.DESCRIBE.SDF_JACK_OF_THE_GREEN_RIDDLE_KOALEFANT = "Has a trunk is long as its memory!"
STRINGS.CHARACTERS.SDF.DESCRIBE.SDF_JACK_OF_THE_GREEN_RIDDLE_FIREPIT = "Stoked by burning questions!"
STRINGS.CHARACTERS.SDF.DESCRIBE.SDF_JACK_OF_THE_GREEN_CHESS_ROOK = "Perverse in nature... how unnatural!"
STRINGS.CHARACTERS.SDF.DESCRIBE.SDF_JACK_OF_THE_GREEN_CHESS_KNIGHT = "Perverse in nature... how unnatural!"
STRINGS.CHARACTERS.SDF.DESCRIBE.SDF_JACK_OF_THE_GREEN_CHESS_BISHOP = "Perverse in nature... how unnatural!"
STRINGS.CHARACTERS.SDF.DESCRIBE.SDF_PROFESSORS_LAB = "I can hear strange humming coming from below."
STRINGS.CHARACTERS.SDF.DESCRIBE.SDF_PROFESSORS_LAB_DOOR_EXIT = "Leads back to the surface."
STRINGS.CHARACTERS.SDF.DESCRIBE.SDF_PROFESSORS_LAB_LIGHT = "Powered by the Charcoal Converter."
STRINGS.CHARACTERS.SDF.DESCRIBE.SDF_PROFESSORS_LAB_WALL_PILLAR = "Can hear a faint hum from its hollow piping."
STRINGS.CHARACTERS.SDF.DESCRIBE.SDF_PROFESSORS_LAB_WALL_PILLAR_IN = "Can hear a faint hum from its hollow piping."
STRINGS.CHARACTERS.SDF.DESCRIBE.SDF_PROFESSORS_LAB_PROJECTOR_SCREEN = "A map of no where."
STRINGS.CHARACTERS.SDF.DESCRIBE.SDF_PROFESSORS_LAB_PROJECTOR = "A device that projects a map made of light!"
STRINGS.CHARACTERS.SDF.DESCRIBE.SDF_PROFESSORS_LAB_GENERATOR = "Burns Charcoal into combustion energy!"
STRINGS.CHARACTERS.SDF.DESCRIBE.SDF_PROFESSORS_LAB_TESLA = "Concentrates energy into a shocking matter."
STRINGS.CHARACTERS.SDF.DESCRIBE.SDF_SPIV = "Spiv Desc."

STRINGS.CHARACTERS.SDF.DESCRIBE.SDF_HEALTHFOUNTAIN = "Spring of life energy!"
STRINGS.CHARACTERS.SDF.DESCRIBE.SDF_LIFEBOTTLE = "The contents of this bottle reduces the yoke of death."
STRINGS.CHARACTERS.SDF.DESCRIBE.SDF_ENERGYVIAL = "A small dose of vitality in an elegant phial."
STRINGS.CHARACTERS.SDF.DESCRIBE.SDF_ACORN_CRACKED = "It's nut worth the hassle..."

STRINGS.CHARACTERS.SDF.DESCRIBE.SDF_ARM = "Handy when dis-armed."
STRINGS.CHARACTERS.SDF.DESCRIBE.SDF_SMALL_SWORD = "Small blade is a good start." 
STRINGS.CHARACTERS.SDF.DESCRIBE.SDF_BROAD_SWORD = "This sword is quite heavy!" 
STRINGS.CHARACTERS.SDF.DESCRIBE.SDF_ENCHANTED_SWORD = "A sharp and mighty sword." 
STRINGS.CHARACTERS.SDF.DESCRIBE.SDF_MAGIC_SWORD = "Never have to sharpen another blade!"
STRINGS.CHARACTERS.SDF.DESCRIBE.SDF_WODENS_BRAND = "It's blade seems to thirst for battle."
STRINGS.CHARACTERS.SDF.DESCRIBE.SDF_CLUB = "Can take some heat."
STRINGS.CHARACTERS.SDF.DESCRIBE.SDF_HAMMER = "It'll smash anything!"
STRINGS.CHARACTERS.SDF.DESCRIBE.SDF_AXE = "Drink deep of demon blood my proud beauty..."
STRINGS.CHARACTERS.SDF.DESCRIBE.SDF_SPADE = "A spade... in a cemetery! I sense great logic at work."
STRINGS.CHARACTERS.SDF.DESCRIBE.SDF_THROWING_DAGGERS = "Throw these away."
STRINGS.CHARACTERS.SDF.DESCRIBE.SDF_CROSSBOW = "Not that there's anything clever about shooting someone in the eye..."
STRINGS.CHARACTERS.SDF.DESCRIBE.SDF_STANDARD_BOLTS = "You could poke an eye out with this thing."
STRINGS.CHARACTERS.SDF.DESCRIBE.SDF_FLAMING_CROSSBOW = "Oh, this one comes with fire. Great..."
STRINGS.CHARACTERS.SDF.DESCRIBE.SDF_FLAMING_BOLTS = "Looks lit!"
STRINGS.CHARACTERS.SDF.DESCRIBE.SDF_LONGBOW = "For those on horseback, or those with horse backs."
STRINGS.CHARACTERS.SDF.DESCRIBE.SDF_STANDARD_ARROWS = "Worth a shot."
STRINGS.CHARACTERS.SDF.DESCRIBE.SDF_FLAMING_LONGBOW = "Never stops smoldering..."
STRINGS.CHARACTERS.SDF.DESCRIBE.SDF_FLAMING_ARROWS = "The perfect match!"
STRINGS.CHARACTERS.SDF.DESCRIBE.SDF_MAGIC_LONGBOW = "It will definitely grow on you!"
STRINGS.CHARACTERS.SDF.DESCRIBE.SDF_MAGICAL_ARROWS = "Growing toxic by the day."
STRINGS.CHARACTERS.SDF.DESCRIBE.SDF_SPEAR = "Spear today, gone tomorrow."
STRINGS.CHARACTERS.SDF.DESCRIBE.SDF_LIGHTNING_GAUNTLET = "I can feel the crackling at my finger tips!"
STRINGS.CHARACTERS.SDF.DESCRIBE.SDF_LIGHTNING = "Shocking isn't it?"
STRINGS.CHARACTERS.SDF.DESCRIBE.SDF_GOODLIGHTNING = "Feel good tingles!"
STRINGS.CHARACTERS.SDF.DESCRIBE.SDF_CHICKEN_DRUMSTICK = "You are what you eat."
STRINGS.CHARACTERS.SDF.DESCRIBE.SDF_CANE_STICK = "Cane stick Sir?"
STRINGS.CHARACTERS.SDF.DESCRIBE.SDF_PISTOL = "I’m feeling a bit triggered!"
STRINGS.CHARACTERS.SDF.DESCRIBE.SDF_STANDARD_BULLETS = "Aim and seek!"
STRINGS.CHARACTERS.SDF.DESCRIBE.SDF_BLUNDERBUSS = "Long barreled cannon!"
STRINGS.CHARACTERS.SDF.DESCRIBE.SDF_STANDARD_BUCKSHOTS = "A blowout!"
STRINGS.CHARACTERS.SDF.DESCRIBE.SDF_BOMBS = "Having a blast!"
STRINGS.CHARACTERS.SDF.DESCRIBE.SDF_GATLING_GUN = "The weapon of my dreams!"
STRINGS.CHARACTERS.SDF.DESCRIBE.SDF_STANDARD_MUNITIONS = "Firing on all cylinders!"

STRINGS.CHARACTERS.SDF.DESCRIBE.SDF_COPPER_SHIELD = "Something I can get behind."
STRINGS.CHARACTERS.SDF.DESCRIBE.SDF_SILVER_SHIELD = "Signature bulwark of a steward defender."
STRINGS.CHARACTERS.SDF.DESCRIBE.SDF_GOLD_SHIELD = "Used properly this shield will make me invincible!"

STRINGS.CHARACTERS.SDF.DESCRIBE.SDF_VICTORIAN_SUIT = "We've got standards."
STRINGS.CHARACTERS.SDF.DESCRIBE.SDF_GOLD_ARMOR = "Worth its weight in gold."
STRINGS.CHARACTERS.SDF.DESCRIBE.SDF_DRAGON_POTION = "It gives you armour that is impervious to heat, plus it lets you breathe fire."
STRINGS.CHARACTERS.SDF.DESCRIBE.SDF_DRAGON_POTION_EMPTY = "All of the dragon's serum has been slurped!"
STRINGS.CHARACTERS.SDF.DESCRIBE.SDF_DRAGON_POTION_DRAGONBREATH = "...it lets you breathe fire."
STRINGS.CHARACTERS.SDF.DESCRIBE.SDF_ANUBIS_STONE = "A sacred stone with powerful magical powers."
STRINGS.CHARACTERS.SDF.DESCRIBE.SDF_ANUBIS_STONE_NECROTIC_TOUCH = "Undeathly tingles..."
STRINGS.CHARACTERS.SDF.DESCRIBE.SDF_ANUBIS_STONE_PART1 = "Legend tells that if the stone were ever reassembled to its singular form..."
STRINGS.CHARACTERS.SDF.DESCRIBE.SDF_ANUBIS_STONE_PART2 = "Legend tells that if the stone were ever reassembled to its singular form..."
STRINGS.CHARACTERS.SDF.DESCRIBE.SDF_ANUBIS_STONE_PART3 = "Legend tells that if the stone were ever reassembled to its singular form..."
STRINGS.CHARACTERS.SDF.DESCRIBE.SDF_ANUBIS_STONE_PART4 = "Legend tells that if the stone were ever reassembled to its singular form..."

------------------------------------------
--Examinations (Wilson's also default to mod characters that do not have any quotes written for that prefab!)
Wilson.SDF_HELMET = "I am sure the owner survived..."
Wilson.SDF_RUNE_HOLDER = "A large stone grabby hand..."
Wilson.SDF_MORTEN = "An unusual purple worm..."
Wilson.SDF_CHALICE_HALL_OF_HEROES = "A massive Goblet floating on a table."
Wilson.SDF_CHALICE_RUNESTONE = "A large stone slab engraved with a cup."
Wilson.SDF_CHALICE_ALTAR = "A ghastly floating cup!"
Wilson.SDF_CHALICE_OF_SOULS = "Pretty fancy drinking cup."
Wilson.SDF_SOUL_HELMET = "Small murmurs can be heard coming from this."
Wilson.SDF_WITCH_TALISMAN = "Yuck... covered in pumpkin, mushrooms and... amber?"
Wilson.SDF_WITCH_CAULDRON = "Can smell the past foul workings from here!"
Wilson.SDF_BOOK_OF_GALLOWMERE = "A heavy dusty old tome!"
Wilson.SDF_BOOK_OF_GALLOWMERE_DAMAGED = "A heavy dusty damaged old tome!"
Wilson.SDF_BOOK_OF_GALLOWMERE_ENTRIES_INVENTORY = "Seems to be about Items of Gallowmere."
Wilson.SDF_BOOK_OF_GALLOWMERE_ENTRIES_FRIENDLIES = "Seems to be about good willed People of Gallowmere."
Wilson.SDF_BOOK_OF_GALLOWMERE_ENTRIES_ENEMIES = "Seems to be about ill willed People of Gallowmere."
Wilson.SDF_BOOK_OF_GALLOWMERE_ENTRIES_BOSSES = "Seems to be about foul willed People of Gallowmere."
Wilson.SDF_BOOK_OF_GALLOWMERE_RESTORED_VELLUM = "Just add more paper... surely that works."
Wilson.SDF_CHEST_RUNESTONE = "Odd looking chest..."
Wilson.SDF_CHEST_WOODEN = "Fragile wooden chest with Spikes."
Wilson.SDF_CHEST_WOODEN_EMPTY = "A pile broken wood..."
Wilson.SDF_CHEST_SKULL = "An uneasy looking chest with a crest."
Wilson.SDF_CHEST_SKULL_EMPTY = "A pile of skull, bones and wood..."
Wilson.SDF_CHEST_LIFEBOTTLE1 = "A chest thrown down a well..."
Wilson.SDF_CHEST_LIFEBOTTLE1_EMPTY = "A pile broken wood..."
Wilson.SDF_CHEST_LIFEBOTTLE2 = "A secret chest, hidden in a maze..."
Wilson.SDF_CHEST_LIFEBOTTLE2_EMPTY = "A pile broken wood..."
Wilson.SDF_CHEST_PUMPKIN = "Case with old farmers belongings."
Wilson.SDF_CHEST_PUMPKIN_EMPTY = "A pile broken wood..."
Wilson.SDF_CHEST_RIDDLE = "What is inside... is a riddle of itself!"
Wilson.SDF_CHEST_MAZE = "What Amazing things could be inside?"
Wilson.SDF_CHEST_MAZE_EMPTY = "A pile leaves and wood..."
Wilson.SDF_CHEST_HAUNTED = "Receptacle of relieving."
Wilson.SDF_CHEST_HAUNTED_EMPTY = "Has been despoiled..."
Wilson.SDF_CHEST_KINGDOM = "A regal box of royalities."
Wilson.SDF_CHEST_KINGDOM_EMPTY = "Has been despoiled..."
Wilson.SDF_ROCK = "This rock will not give!"
Wilson.SDF_WALL_WOOD = "It won't catch flame... fireproof wood?!"
Wilson.SDF_WALL_STONE = "This stone will not be chipped!"
Wilson.SDF_WALL_STONE_PILLAR = "A well-founded cornerstone!"
Wilson.SDF_WALL_HEDGE_BLOCK = "These leafs will not ignite!"
Wilson.SDF_WALL_HEDGE_DECOR = "Nonflammable greenry decoration..."
Wilson.SDF_WALL_OVERGROWN = "The growth is holding this stone together!"
Wilson.SDF_MARBLE_PILLAR = "A timeless stele!"
Wilson.SDF_SUPPORT_STONE_PILLAR = "We all could use a little support..."
Wilson.SDF_HAUNTED_RUINS_GATE = "These old irons look dated."
Wilson.SDF_HAUNTED_RUINS_LAVA_POND = "A unique hot stone massage experience."
Wilson.SDF_HAUNTED_RUINS_LAVA_POND_ROCK = "Those who were invited to the lava pool."
Wilson.SDF_HAUNTED_RUINS_THRONE = "A vacant seat..."
Wilson.SDF_STATUE = "Desecrated statue..."
Wilson.SDF_INFORMATION_GARGOYLE = "Seems like it wishes to talk, but won't say a word to me."
Wilson.SDF_MERCHANT_GARGOYLE = "Takes gold and gives items, where does it store it all?"
Wilson.SDF_SHOP_GARGOYLE = "A smaller gold hungry wall plaque."
Wilson.SDF_MULLOCK_CHIEF_MEMORIAL = "A weathered stone with a primal skull..."
Wilson.SDF_MULLOCK_CHIEF_MEMORIAL_MOUND = "A large grave, fitting for a leader."
Wilson.SDF_GALLOWMERE_KNIGHT = "A faintly glowing skeleton knight."
Wilson.SDF_GALLOWMERE_SQUIRE = "A faintly glowing skeleton squire."
Wilson.SDF_KING_PEREGRIN = "A crowned ghost!"
Wilson.SDF_KING_PEREGRINS_CROWN = "A crown that can't be worn... what a shame."
Wilson.SDF_KING_PEREGRINS_CROWN_LOST = "Is this even real?"
Wilson.SDF_STONE_GOLEM_ARMORED = "Considerable art of masonry."
Wilson.SDF_STONE_GOLEM_ARMORED = "Considerable art of masonry."
Wilson.SDF_LAVA_GOLEM = "Such a hot head..."
Wilson.SDF_ASGARD_GOLEM = "Fortress of the Gods..."
Wilson.SDF_ASGARD_GOLEM_LAVA_GOLEM = "Such a hot head..."
Wilson.SDF_ASGARD_GOLEM_GIANTS_OCARINA = "Said to summon a gentle giant..."
Wilson.SDF_ASGARD_GOLEM_OPTIMIZE_DATA_DAMAGED = "Seems to be beyond repair..."
Wilson.SDF_ASGARD_GOLEM_OPTIMIZE_DATA_TYPE_A = "Label reads [Emergency Mode: Friendly Fire]"
Wilson.SDF_ASGARD_GOLEM_OPTIMIZE_DATA_TYPE_C = "Label reads [Emergency Mode: System Recovery]"
Wilson.SDF_PUMPKIN_KING = "Rotten pick of the patch!"
Wilson.SDF_PUMPKIN_KING_PLANT = "Rotten pick of the patch!"
Wilson.SDF_PUMPKIN_KING_VINE_END = "A twisted barb."
Wilson.SDF_PUMPKING_SEED_POD = "These roots run deep."
Wilson.SDF_PUMPKING_CREEPER = "Pumpking plants are truly ferocious fruit."
Wilson.SDF_PUMPKING_CREEPER_PLANT = "To the kings aid!"
Wilson.SDF_PUMPKING_CREEPER_PLANT_SPAWNER = "I don’t have the stomach for it..."
Wilson.SDF_PUMPKING_BOMB = "Pumpking plants are truly ferocious fruit."
Wilson.SDF_PUMPKING_BOMB_PLANT = "To the kings aid!"
Wilson.SDF_PUMPKING_BOMB_PLANT_SPAWNER = "I don’t have the stomach for it..."
Wilson.SDF_PUMPKING_GOURD = "Pumpking plants are truly ferocious fruit."
Wilson.SDF_PUMPKING_GOURD_PLANT = "To the kings aid!"
Wilson.SDF_PUMPKING_GOURD_PLANT_SPAWNER = "I don’t have the stomach for it..."
Wilson.SDF_PUMPKING_GOURD_VINE = "A curious root?"
Wilson.SDF_PUMPKIN_CREEPER = "Drives fear into the heart of many a shrub gardener."
Wilson.SDF_PUMPKIN_CREEPER_PLANT = "What horror is growing?"
Wilson.SDF_PUMPKIN_BOMB = "Drives fear into the heart of many a shrub gardener."
Wilson.SDF_PUMPKIN_BOMB_PLANT = "What horror is growing?"
Wilson.SDF_PUMPKIN_GOURD = "Drives fear into the heart of many a shrub gardener."
Wilson.SDF_PUMPKIN_GOURD_VINE = "A curious root?"
Wilson.SDF_PUMPKIN_GOURD_PLANT = "What horror is growing?"
Wilson.SDF_PUMPKIN_CREEPER_SEEDS = "A sinster seed... how bad could it be?"
Wilson.SDF_PUMPKIN_BOMB_SEEDS = "A sinster seed... how bad could it be?"
Wilson.SDF_PUMPKIN_GOURD_SEEDS = "A sinster seed... how bad could it be?"
Wilson.SDF_PUMPKIN_GORGE_CREEPER = "A questionable fruit bearer..."
Wilson.SDF_PUMPKIN_GORGE_BUSH = "Will not be tamed!"
Wilson.SDF_PUMPKIN_GORGE_ROOTS = "How could they gotten so massive?"
Wilson.SDF_PUMPKIN_GORGE_PLANT = "I don’t have the stomach for it..."
Wilson.SDF_PUMPKIN_GORGE_FARMLAND_DEBRIS = "What good can come from that filth?"
Wilson.SDF_PUMPKIN_GORGE_PONDFISH = "Won't last much longer with out water."
Wilson.SDF_PUMPKIN_GORGE_PONDFISH_DEAD = "Has gone to the big fishbowl in the sky..."
Wilson.SDF_PUMPKIN_GORGE_PONDFISH_COOKED = "Simply breath taking!"
Wilson.SDF_PUMPKIN_GORGE_POND = "Quite shallow...is this normal?"
Wilson.SDF_PUMPKIN_GORGE_WELL = "Looks to have ran dry long ago..."
Wilson.SDF_PUMPKIN_GORGE_WELL_DOOR_EXIT = "Looks sturdy enough to climb!"
Wilson.SDF_PUMPKIN_GORGE_WELL_GLOWSHROOM1 = "A helpful night light!"
Wilson.SDF_PUMPKIN_GORGE_WELL_GLOWSHROOM2 = "A helpful night light!"
Wilson.SDF_PUMPKIN_GORGE_WELL_MERCHANT_GARGOYLE = "What a odd place to setup shop."
Wilson.SDF_PUMPKIN_GORGE_WELL_VINE = "A curious root?"
Wilson.SDF_SHADOW_DEMON_TOMB_ALTARFX = "A hand shaped vestige that yerns for freedom."
Wilson.SDF_SHADOW_DEMONETTE_PENUMBRA = "A hand shaped vestige that yerns for freedom."
Wilson.SDF_SHADOW_DEMONETTE_UMBRA = "A hand shaped vestige that yerns for freedom."
Wilson.SDF_SHADOW_ARTEFACT = "A hand shaped vestige that yerns for freedom."
Wilson.SDF_SHADOW_TALISMAN = "An ominous relic... I have bad feelings about this."
Wilson.SDF_CARNIVAL_TOKEN = "A high stakes coupon."
Wilson.SDF_TIME_RUNE_HALL_OF_HEROES = "Time moves differently here."
Wilson.SDF_TIME_RUNE = "A tablet etched with a hourglass shape."
Wilson.SDF_MOON_RUNE = "A tablet etched with a crescent moon shape."
Wilson.SDF_EARTH_RUNE = "A tablet etched with a cracked globe shape."
Wilson.SDF_STAR_RUNE = "A tablet etched with a star shape."
Wilson.SDF_CHAOS_RUNE = "A tablet etched with a indistinguishable shape."
Wilson.SDF_CHAOS_ROCK = "The eerie lump is now a chunk."
Wilson.SDF_CHAOS_ROCK2 = "Found on an island of riddles, what secret does it keep..."
Wilson.SDF_JACK_OF_THE_GREEN = "A large arrogant talking Stone Face."
Wilson.SDF_JACK_OF_THE_GREEN_FLOWER = "Their smell makes me feel a little dizzy..."
Wilson.SDF_JACK_OF_THE_GREEN_VASE = "Not a single crack can be found on this oversized pot!"
Wilson.SDF_ASYLUM_GROUNDS_KEEPER_GRAVE = "Best not to fall in!"
Wilson.SDF_ASYLUM_GROUNDS_KEEPER = "Local inhabitants of the Asylum Grounds..."
Wilson.SDF_ASYLUM_GROUNDS_GATE = "No hinges... how does it open?"
Wilson.SDF_ASYLUM_GROUNDS_BARRIER = "While made of stone... it seems different."
Wilson.SDF_JACK_OF_THE_GREEN_RIDDLE_STAR = "A shaped hedge in a form of a star."
Wilson.SDF_JACK_OF_THE_GREEN_RIDDLE_FACE_SLAB = "Golden faces imprinted with emotion."
Wilson.SDF_JACK_OF_THE_GREEN_RIDDLE_CLOWN = "A funny looking hedge."
Wilson.SDF_JACK_OF_THE_GREEN_RIDDLE_CHAOS_RUNE_CRUMBLED = "Worn tablet shattered across the ground."
Wilson.SDF_JACK_OF_THE_GREEN_RIDDLE_CHAOS_RUNE_FRAGMENT = "An eerie lump of stone."
Wilson.SDF_JACK_OF_THE_GREEN_RIDDLE_MOLEWORM = "Part plant, mole, and worm... puzzling!"
Wilson.SDF_JACK_OF_THE_GREEN_RIDDLE_MOLEWORM_HILL = "Can hear writhes from below!"
Wilson.SDF_JACK_OF_THE_GREEN_RIDDLE_KOALEFANT = "A gentle looking Hedge."
Wilson.SDF_JACK_OF_THE_GREEN_RIDDLE_FIREPIT = "Doesn't hold a flame well."
Wilson.SDF_JACK_OF_THE_GREEN_CHESS_ROOK = "Bad-tempered looking Hedge."
Wilson.SDF_JACK_OF_THE_GREEN_CHESS_KNIGHT = "Bad-tempered looking Hedge."
Wilson.SDF_JACK_OF_THE_GREEN_CHESS_BISHOP = "Bad-tempered looking Hedge."
Wilson.SDF_PROFESSORS_LAB = "Sealed tightly... Wonder what wonders are down below."
Wilson.SDF_PROFESSORS_LAB_DOOR_EXIT = "Leads back to the surface."
Wilson.SDF_PROFESSORS_LAB_LIGHT = "It's so bright."
Wilson.SDF_PROFESSORS_LAB_WALL_PILLAR = "Stable enough."
Wilson.SDF_PROFESSORS_LAB_WALL_PILLAR_IN = "Stable enough."
Wilson.SDF_PROFESSORS_LAB_PROJECTOR_SCREEN = "Its a map, but of where..."
Wilson.SDF_PROFESSORS_LAB_PROJECTOR = "Device that creates a map on a screen."
Wilson.SDF_PROFESSORS_LAB_GENERATOR = "Burns Charcoal into energy!"
Wilson.SDF_PROFESSORS_LAB_TESLA = "Stores energy!"
Wilson.SDF_SPIV = "Spiv Desc."

Wilson.SDF_HEALTHFOUNTAIN = "Strange fluid coming from the ground!"
Wilson.SDF_LIFEBOTTLE = "Not sure what that fluid inside is..."
Wilson.SDF_ENERGYVIAL = "I will not taste this strange liquid."
Wilson.SDF_ACORN_CRACKED = "You’re a tough nut to crack."

Wilson.SDF_ARM = "A helpful hand in hard to reach places!"
Wilson.SDF_SMALL_SWORD = "Long thin blade." 
Wilson.SDF_BROAD_SWORD = "Heavy sweeping strikes!" 
Wilson.SDF_ENCHANTED_SWORD = "Just as heavy but more sharp." 
Wilson.SDF_MAGIC_SWORD = "Seems to never dull!"
Wilson.SDF_WODENS_BRAND = "A large heavy bloodied sword."
Wilson.SDF_CLUB = "Useful for bashing and exploring."
Wilson.SDF_HAMMER = "So heavy!!"
Wilson.SDF_AXE = "Its like a bomerang, but deadly to both!"
Wilson.SDF_SPADE = "Seems worn from grave digging."
Wilson.SDF_THROWING_DAGGERS = "Its all in the wrist!"
Wilson.SDF_CROSSBOW = "Rapid firing mechanism."
Wilson.SDF_STANDARD_BOLTS = "Honed tipped!"
Wilson.SDF_FLAMING_CROSSBOW = "Rapid firing fire mechanism."
Wilson.SDF_FLAMING_BOLTS = "Lit tipped!"
Wilson.SDF_LONGBOW = "Peculiarly large bow."
Wilson.SDF_STANDARD_ARROWS = "Sharp tipped!"
Wilson.SDF_FLAMING_LONGBOW = "Flaky ash coated bow."
Wilson.SDF_FLAMING_ARROWS = "Heated tipped!"
Wilson.SDF_MAGIC_LONGBOW = "Erratic fungus ridden bow."
Wilson.SDF_MAGICAL_ARROWS = "Toxic tipped!"
Wilson.SDF_SPEAR = "An over sized javelin."
Wilson.SDF_LIGHTNING_GAUNTLET = "Never strike in the same place twice!"
Wilson.SDF_LIGHTNING = "Zap zap!"
Wilson.SDF_GOODLIGHTNING = "I am not sure about this... odd feeling."
Wilson.SDF_CANE_STICK = "A fancy stick with a socket."
Wilson.SDF_CHICKEN_DRUMSTICK = "...five second rule?"
Wilson.SDF_PISTOL = "Quick draw six-shooter."
Wilson.SDF_STANDARD_BULLETS = "Small rounds for a small gun."
Wilson.SDF_BLUNDERBUSS = "Classic rifle with a trumpet-shaped barrel."
Wilson.SDF_STANDARD_BUCKSHOTS = "Shot of optimism!"
Wilson.SDF_BOMBS = "Produces explosive results."
Wilson.SDF_GATLING_GUN = "Heavy metal shooting device."
Wilson.SDF_STANDARD_MUNITIONS = "Shoot the breeze!"

Wilson.SDF_COPPER_SHIELD = "Better than no protecton!"
Wilson.SDF_SILVER_SHIELD = "Easy wielding argent shield."
Wilson.SDF_GOLD_SHIELD = "Glorious shield that can take on a siege!"

Wilson.SDF_VICTORIAN_SUIT = "Too aristocratic for my taste."
Wilson.SDF_GOLD_ARMOR = "The way it shines... Something isn't right about it."
Wilson.SDF_DRAGON_POTION = "Seems to contain dragons breath... Not drinking. Nope."
Wilson.SDF_DRAGON_POTION_EMPTY = "Dry... All gone."
Wilson.SDF_DRAGON_POTION_DRAGONBREATH = "I don't even..."
Wilson.SDF_ANUBIS_STONE = "This gold encrusted gem is fashioned in the image of a Nubian sand beetle."
Wilson.SDF_ANUBIS_STONE_NECROTIC_TOUCH = "The touch of death that brings life..."
Wilson.SDF_ANUBIS_STONE_PART1 = "An ancient piece of a bygone era gem."
Wilson.SDF_ANUBIS_STONE_PART2 = "An ancient piece of a bygone era gem."
Wilson.SDF_ANUBIS_STONE_PART3 = "An ancient piece of a bygone era gem."
Wilson.SDF_ANUBIS_STONE_PART4 = "An ancient piece of a bygone era gem."

------------------------------------------
--Willow.SDF_HELMET = "I am sure the owner survived..."
--Willow.SDF_BOOK_OF_GOLLOWMERE = "Infomation gathered on all things Gallowmere!"
--Willow.SDF_CHALICE_HALL_OF_HEROES = "A massive Goblet floating on a table."
--Willow.SDF_CHALICE_RUNESTONE = "A large stone slab engraved with a cup."
--Willow.SDF_CHALICE_ALTAR = "A ghastly floating cup!"
--Willow.SDF_CHALICE_OF_SOULS = "Pretty fancy drinking cup."
--Willow.SDF_SOUL_HELMET = "Small murmurs can be heard coming from this."
--Willow.SDF_WITCH_TALISMAN = "Yuck... covered in pumpkin, mushrooms and... amber?"
--Willow.SDF_CHEST_RUNESTONE = "Odd looking chest..."
--Willow.SDF_CHEST_WOODEN = "Fragile wooden chest with Spikes."
--Willow.SDF_CHEST_SKULL = "An uneasy looking chest with a crest."
--Willow.SDF_STATUE = "Desecrated statue... Only the base remains."
--Willow.SDF_WALL_WOOD = "It won't catch flame... fireproof wood?!"
--Willow.SDF_WALL_STONE = "This stone will not be chipped!"
--Willow.SDF_INFORMATION_GARGOYLE = "Seems like it wishes to talk, but won't say a word to me."
--Willow.SDF_MERCHANT_GARGOYLE = "Takes gold and gives items, where does it store it all?"
--Willow.SDF_SHOP_GARGOYLE = "A smaller gold hungry wall plaque."
--Willow.SDF_GALLOWMERE_KNIGHT = "A faintly glowing skeleton knight."
--Willow.SDF_KING_PEREGRINS_CROWN = "A crown that can't be worn... what a shame."

--Willow.SDF_HEALTHFOUNTAIN = "Strange fluid coming from the ground!"
--Willow.SDF_LIFEBOTTLE = "Not sure what that fluid inside is..."
--Willow.SDF_ENERGYVIAL = "I will not taste this strange liquid."


Willow.SDF_SMALL_SWORD = "Short version of a sword."
Willow.SDF_BROAD_SWORD = "That sword can make a slice!"
Willow.SDF_ENCHANTED_SWORD = "That sword can make a slice!"
Willow.SDF_MAGIC_SWORD = "Magically sharp."
--Willow.SDF_CLUB = "Useful for bashing and exploring."
Willow.SDF_HAMMER = "Powerful, but clunky hammer."
Willow.SDF_AXE = "Sharp enough to kill!"

Willow.SDF_THROWING_DAGGERS = "These daggers may find useful."
--Willow.SDF_CROSSBOW = "Rapid firing mechanism."
--Willow.SDF_STANDARD_BOLTS = "Honed tipped!"
--Willow.SDF_LONGBOW = "Peculiarly large bow."
--Willow.SDF_STANDARD_ARROWS = "Sharp tipped!"
--Willow.SDF_FLAMING_LONGBOW = "Flaky ash coated bow."
--Willow.SDF_FLAMING_ARROWS = "Heated tipped!"
--Willow.SDF_MAGIC_LONGBOW = "Erratic fungus ridden bow."
--Willow.SDF_MAGICAL_ARROWS = "Toxic tipped!"
--Willow.SDF_SPEAR = "Wrappings for other spears"
--Willow.SDF_SPEARS = "An over sized javelin."
--Willow.SDF_LIGHTNING_GAUNTLET = "Never strike in the same place twice!"
--Willow.SDF_LIGHTNING = "Zap zap!"
--Willow.SDF_GOODLIGHTNING = "I am not sure about this... odd feeling."
--Willow.SDF_CHICKEN_DRUMSTICK = "...five second rule?"

--Willow.SDF_COPPER_SHIELD = "Better than no protecton!"
--Willow.SDF_SILVER_SHIELD = "Easy wielding argent shield."
--Willow.SDF_GOLD_SHIELD = "Glorious shield that can take on a siege!"

Willow.SDF_VICTORIAN_SUIT = "Like an very old lady. No way!"
Willow.SDF_GOLD_ARMOR = "Terribly old-fashioned."
--Willow.SDF_DRAGON_POTION = "Seems to contain dragons breath... Not drinking. Nope."
--Willow.SDF_DRAGON_POTION_EMPTY = "Dry... All gone."
--Willow.SDF_DRAGON_POTION_SKULLCAP = "I don't even..."

------------------------------------------
--Wolfgang.SDF_HELMET = "I am sure the owner survived..."
--Wolfgang.SDF_BOOK_OF_GOLLOWMERE = "Infomation gathered on all things Gallowmere!"
--Wolfgang.SDF_CHALICE_HALL_OF_HEROES = "A massive Goblet floating on a table."
--Wolfgang.SDF_CHALICE_RUNESTONE = "A large stone slab engraved with a cup."
--Wolfgang.SDF_CHALICE_ALTAR = "A ghastly floating cup!"
--Wolfgang.SDF_CHALICE_OF_SOULS = "Pretty fancy drinking cup."
--Wolfgang.SDF_SOUL_HELMET = "Small murmurs can be heard coming from this."
--Wolfgang.SDF_WITCH_TALISMAN = "Yuck... covered in pumpkin, mushrooms and... amber?"
--Wolfgang.SDF_CHEST_RUNESTONE = "Odd looking chest..."
--Wolfgang.SDF_CHEST_WOODEN = "Fragile wooden chest with Spikes."
--Wolfgang.SDF_CHEST_SKULL = "An uneasy looking chest with a crest."
--Wolfgang.SDF_STATUE = "Desecrated statue... Only the base remains."
--Wolfgang.SDF_WALL_WOOD = "It won't catch flame... fireproof wood?!"
--Wolfgang.SDF_WALL_STONE = "This stone will not be chipped!"
--Wolfgang.SDF_INFORMATION_GARGOYLE = "Seems like it wishes to talk, but won't say a word to me."
--Wolfgang.SDF_MERCHANT_GARGOYLE = "Takes gold and gives items, where does it store it all?"
--Wolfgang.SDF_SHOP_GARGOYLE = "A smaller gold hungry wall plaque."
--Wolfgang.SDF_GALLOWMERE_KNIGHT = "A faintly glowing skeleton knight."
--Wolfgang.SDF_KING_PEREGRINS_CROWN = "A crown that can't be worn... what a shame."

--Wolfgang.SDF_HEALTHFOUNTAIN = "Strange fluid coming from the ground!"
--Wolfgang.SDF_LIFEBOTTLE = "Not sure what that fluid inside is..."
--Wolfgang.SDF_ENERGYVIAL = "I will not taste this strange liquid."

Wolfgang.SDF_SMALL_SWORD = "This sword is too short!"
Wolfgang.SDF_BROAD_SWORD = "Long sword! I like it!"
Wolfgang.SDF_ENCHANTED_SWORD = "Long sword! I like it!"
Wolfgang.SDF_MAGIC_SWORD = "This sword is strange!"
--Wolfgang.SDF_CLUB = "Useful for bashing and exploring."
Wolfgang.SDF_HAMMER = "It's heavy, just like me!"
Wolfgang.SDF_AXE = "Strong axe for strong Wolfgang!"

Wolfgang.SDF_THROWING_DAGGERS = "Looks more like a toy. Ha!"
--Wolfgang.SDF_CROSSBOW = "Rapid firing mechanism."
--Wolfgang.SDF_STANDARD_BOLTS = "Honed tipped!"
--Wolfgang.SDF_LONGBOW = "Peculiarly large bow."
--Wolfgang.SDF_STANDARD_ARROWS = "Sharp tipped!"
--Wolfgang.SDF_FLAMING_LONGBOW = "Flaky ash coated bow."
--Wolfgang.SDF_FLAMING_ARROWS = "Heated tipped!"
--Wolfgang.SDF_MAGIC_LONGBOW = "Erratic fungus ridden bow."
--Wolfgang.SDF_MAGICAL_ARROWS = "Toxic tipped!"
--Wolfgang.SDF_SPEAR = "Wrappings for other spears"
--Wolfgang.SDF_SPEARS = "An over sized javelin."
--Wolfgang.SDF_LIGHTNING_GAUNTLET = "Never strike in the same place twice!"
--Wolfgang.SDF_LIGHTNING = "Zap zap!"
--Wolfgang.SDF_GOODLIGHTNING = "I am not sure about this... odd feeling."
--Wolfgang.SDF_CHICKEN_DRUMSTICK = "...five second rule?"

--Wolfgang.SDF_COPPER_SHIELD = "Better than no protecton!"
--Wolfgang.SDF_SILVER_SHIELD = "Easy wielding argent shield."
--Wolfgang.SDF_GOLD_SHIELD = "Glorious shield that can take on a siege!"

Wolfgang.SDF_VICTORIAN_SUIT = "Too fancy for Wolfgang!"
Wolfgang.SDF_GOLD_ARMOR = "Can't fit, this armor is too small!"
Wolfgang.SDF_DRAGON_POTION = "Seems to contain dragons breath... Not drinking. Nope."
Wolfgang.SDF_DRAGON_POTION_EMPTY = "Dry... All gone."
Wolfgang.SDF_DRAGON_POTION_SKULLCAP = "I don't even..."

------------------------------------------
--Wendy.SDF_HELMET = "I am sure the owner survived..."
--Wendy.SDF_BOOK_OF_GOLLOWMERE = "Infomation gathered on all things Gallowmere!"
--Wendy.SDF_CHALICE_HALL_OF_HEROES = "A massive Goblet floating on a table."
--Wendy.SDF_CHALICE_RUNESTONE = "A large stone slab engraved with a cup."
--Wendy.SDF_CHALICE_ALTAR = "A ghastly floating cup!"
--Wendy.SDF_CHALICE_OF_SOULS = "Pretty fancy drinking cup."
--Wendy.SDF_SOUL_HELMET = "Small murmurs can be heard coming from this."
--Wendy.SDF_WITCH_TALISMAN = "Yuck... covered in pumpkin, mushrooms and... amber?"
--Wendy.SDF_CHEST_RUNESTONE = "Odd looking chest..."
--Wendy.SDF_CHEST_WOODEN = "Fragile wooden chest with Spikes."
--Wendy.SDF_CHEST_SKULL = "An uneasy looking chest with a crest."
--Wendy.SDF_STATUE = "Desecrated statue... Only the base remains."
--Wendy.SDF_WALL_WOOD = "It won't catch flame... fireproof wood?!"
--Wendy.SDF_WALL_STONE = "This stone will not be chipped!"
--Wendy.SDF_INFORMATION_GARGOYLE = "Seems like it wishes to talk, but won't say a word to me."
--Wendy.SDF_MERCHANT_GARGOYLE = "Takes gold and gives items, where does it store it all?"
--Wendy.SDF_SHOP_GARGOYLE = "A smaller gold hungry wall plaque."
--Wendy.SDF_GALLOWMERE_KNIGHT = "A faintly glowing skeleton knight."
--Wendy.SDF_KING_PEREGRINS_CROWN = "A crown that can't be worn... what a shame."

--Wendy.SDF_HEALTHFOUNTAIN = "Strange fluid coming from the ground!"
--Wendy.SDF_LIFEBOTTLE = "Not sure what that fluid inside is..."
--Wendy.SDF_ENERGYVIAL = "I will not taste this strange liquid."

Wendy.SDF_SMALL_SWORD = "Short blade but deadly enough."
Wendy.SDF_BROAD_SWORD = "The heavier blade suitable for larger massacre."
Wendy.SDF_ENCHANTED_SWORD = "The heavier blade suitable for larger massacre."
Wendy.SDF_MAGIC_SWORD = "This weapon is filled with magic."
--Wendy.SDF_CLUB = "Useful for bashing and exploring."
Wendy.SDF_HAMMER = "It is easy to kill someone with such a hammer."
Wendy.SDF_AXE = "Great axe to inflict deep wounds."

Wendy.SDF_THROWING_DAGGERS = "Sharp and inconspicuous tool for carrying death."
--Wendy.SDF_CROSSBOW = "Rapid firing mechanism."
--Wendy.SDF_STANDARD_BOLTS = "Honed tipped!"
--Wendy.SDF_LONGBOW = "Peculiarly large bow."
--Wendy.SDF_STANDARD_ARROWS = "Sharp tipped!"
--Wendy.SDF_FLAMING_LONGBOW = "Flaky ash coated bow."
--Wendy.SDF_FLAMING_ARROWS = "Heated tipped!"
--Wendy.SDF_MAGIC_LONGBOW = "Erratic fungus ridden bow."
--Wendy.SDF_MAGICAL_ARROWS = "Toxic tipped!"
--Wendy.SDF_SPEAR = "Wrappings for other spears"
--Wendy.SDF_SPEARS = "An over sized javelin."
--Wendy.SDF_LIGHTNING_GAUNTLET = "Never strike in the same place twice!"
--Wendy.SDF_LIGHTNING = "Zap zap!"
--Wendy.SDF_GOODLIGHTNING = "I am not sure about this... odd feeling."
--Wendy.SDF_CHICKEN_DRUMSTICK = "...five second rule?"

--Wendy.SDF_COPPER_SHIELD = "Better than no protecton!"
--Wendy.SDF_SILVER_SHIELD = "Easy wielding argent shield."
--Wendy.SDF_GOLD_SHIELD = "Glorious shield that can take on a siege!"

Wendy.SDF_VICTORIAN_SUIT = "I doubt that this clothing was appropriate for me."
Wendy.SDF_GOLD_ARMOR = "I don't like the energy of the object."
Wendy.SDF_DRAGON_POTION = "Seems to contain dragons breath... Not drinking. Nope."
Wendy.SDF_DRAGON_POTION_EMPTY = "Dry... All gone."
Wendy.SDF_DRAGON_POTION_SKULLCAP = "I don't even..."

------------------------------------------
--WX78.SDF_HELMET = "I am sure the owner survived..."
--WX78.SDF_BOOK_OF_GOLLOWMERE = "Infomation gathered on all things Gallowmere!"
--WX78.SDF_CHALICE_HALL_OF_HEROES = "A massive Goblet floating on a table."
--WX78.SDF_CHALICE_RUNESTONE = "A large stone slab engraved with a cup."
--WX78.SDF_CHALICE_ALTAR = "A ghastly floating cup!"
--WX78.SDF_CHALICE_OF_SOULS = "Pretty fancy drinking cup."
--WX78.SDF_SOUL_HELMET = "Small murmurs can be heard coming from this."
--WX78.SDF_WITCH_TALISMAN = "Yuck... covered in pumpkin, mushrooms and... amber?"
--WX78.SDF_CHEST_RUNESTONE = "Odd looking chest..."
--WX78.SDF_CHEST_WOODEN = "Fragile wooden chest with Spikes."
--WX78.SDF_CHEST_SKULL = "An uneasy looking chest with a crest."
--WX78.SDF_STATUE = "Desecrated statue... Only the base remains."
--WX78.SDF_WALL_WOOD = "It won't catch flame... fireproof wood?!"
--WX78.SDF_WALL_STONE = "This stone will not be chipped!"
--WX78.SDF_INFORMATION_GARGOYLE = "Seems like it wishes to talk, but won't say a word to me."
--WX78.SDF_MERCHANT_GARGOYLE = "Takes gold and gives items, where does it store it all?"
--WX78.SDF_SHOP_GARGOYLE = "A smaller gold hungry wall plaque."
--WX78.SDF_GALLOWMERE_KNIGHT = "A faintly glowing skeleton knight."
--WX78.SDF_KING_PEREGRINS_CROWN = "A crown that can't be worn... what a shame."

--WX78.SDF_HEALTHFOUNTAIN = "Strange fluid coming from the ground!"
--WX78.SDF_LIFEBOTTLE = "Not sure what that fluid inside is..."
--WX78.SDF_ENERGYVIAL = "I will not taste this strange liquid."

WX78.SDF_SMALL_SWORD = "WEAPON GOOD FOR MODERATE BATTLES"
WX78.SDF_BROAD_SWORD = "LONGER SWORD VERSION"
WX78.SDF_ENCHANTED_SWORD = "LONGER SWORD VERSION"
WX78.SDF_MAGIC_SWORD = "POWERFUL SWORD. MAGIC DETECTED!"
--WX78.SDF_CLUB = "Useful for bashing and exploring."
WX78.SDF_HAMMER = "GREAT DECONSTRUCTION"
WX78.SDF_AXE = "STRONG CHOPPING TOOL"

WX78.THROWING_DAGGER = "DEADLY PROJECTILE"
--WX78.SDF_CROSSBOW = "Rapid firing mechanism."
--WX78.SDF_STANDARD_BOLTS = "Honed tipped!"
--WX78.SDF_LONGBOW = "Peculiarly large bow."
--WX78.SDF_STANDARD_ARROWS = "Sharp tipped!"
--WX78.SDF_FLAMING_LONGBOW = "Flaky ash coated bow."
--WX78.SDF_FLAMING_ARROWS = "Heated tipped!"
--WX78.SDF_MAGIC_LONGBOW = "Erratic fungus ridden bow."
--WX78.SDF_MAGICAL_ARROWS = "Toxic tipped!"
--WX78.SDF_SPEAR = "Wrappings for other spears"
--WX78.SDF_SPEARS = "An over sized javelin."
--WX78.SDF_LIGHTNING_GAUNTLET = "Never strike in the same place twice!"
--WX78.SDF_LIGHTNING = "Zap zap!"
--WX78.SDF_GOODLIGHTNING = "I am not sure about this... odd feeling."
--WX78.SDF_CHICKEN_DRUMSTICK = "...five second rule?"

--WX78.SDF_COPPER_SHIELD = "Better than no protecton!"
--WX78.SDF_SILVER_SHIELD = "Easy wielding argent shield."
--WX78.SDF_GOLD_SHIELD = "Glorious shield that can take on a siege!"

WX78.SDF_VICTORIAN_SUIT = "INADEQUATE CLOTHES PARAMETERS"
WX78.SDF_GOLD_ARMOR = "INADEQUATE ARMOR PARAMETERS"
WX78.SDF_DRAGON_POTION = "Seems to contain dragons breath... Not drinking. Nope."
WX78.SDF_DRAGON_POTION_EMPTY = "Dry... All gone."
WX78.SDF_DRAGON_POTION_SKULLCAP = "I don't even..."

------------------------------------------
--Wickerbottom.SDF_HELMET = "I am sure the owner survived..."
--Wickerbottom.SDF_BOOK_OF_GOLLOWMERE = "Infomation gathered on all things Gallowmere!"
--Wickerbottom.SDF_CHALICE_HALL_OF_HEROES = "A massive Goblet floating on a table."
--Wickerbottom.SDF_CHALICE_RUNESTONE = "A large stone slab engraved with a cup."
--Wickerbottom.SDF_CHALICE_ALTAR = "A ghastly floating cup!"
--Wickerbottom.SDF_CHALICE_OF_SOULS = "Pretty fancy drinking cup."
--Wickerbottom.SDF_SOUL_HELMET = "Small murmurs can be heard coming from this."
--Wickerbottom.SDF_WITCH_TALISMAN = "Yuck... covered in pumpkin, mushrooms and... amber?"
--Wickerbottom.SDF_CHEST_RUNESTONE = "Odd looking chest..."
--Wickerbottom.SDF_CHEST_WOODEN = "Fragile wooden chest with Spikes."
--Wickerbottom.SDF_CHEST_SKULL = "An uneasy looking chest with a crest."
--Wickerbottom.SDF_STATUE = "Desecrated statue... Only the base remains."
--Wickerbottom.SDF_WALL_WOOD = "It won't catch flame... fireproof wood?!"
--Wickerbottom.SDF_WALL_STONE = "This stone will not be chipped!"
--Wickerbottom.SDF_INFORMATION_GARGOYLE = "Seems like it wishes to talk, but won't say a word to me."
--Wickerbottom.SDF_MERCHANT_GARGOYLE = "Takes gold and gives items, where does it store it all?"
--Wickerbottom.SDF_SHOP_GARGOYLE = "A smaller gold hungry wall plaque."
--Wickerbottom.SDF_GALLOWMERE_KNIGHT = "A faintly glowing skeleton knight."
--Wickerbottom.SDF_KING_PEREGRINS_CROWN = "A crown that can't be worn... what a shame."

--Wickerbottom.SDF_HEALTHFOUNTAIN = "Strange fluid coming from the ground!"
--Wickerbottom.SDF_LIFEBOTTLE = "Not sure what that fluid inside is..."
--Wickerbottom.SDF_ENERGYVIAL = "I will not taste this strange liquid."

Wickerbottom.SDF_SMALL_SWORD = "It's short but it can deal a lot of damage."
Wickerbottom.SDF_BROAD_SWORD = "Such a blade could determine the fate."
Wickerbottom.SDF_ENCHANTED_SWORD = "Such a blade could determine the fate."
Wickerbottom.SDF_MAGIC_SWORD = "What could be better than great sword filled with magic?"
--Wickerbottom.SDF_CLUB = "Useful for bashing and exploring."
Wickerbottom.SDF_HAMMER = "This weapon has great potential."
Wickerbottom.SDF_AXE = "I can chop with this. Also it's a good weapon."

Wickerbottom.SDF_THROWING_DAGGERS = "It's wise to attack from a distance."
--Wickerbottom.SDF_CROSSBOW = "Rapid firing mechanism."
--Wickerbottom.SDF_STANDARD_BOLTS = "Honed tipped!"
--Wickerbottom.SDF_LONGBOW = "Peculiarly large bow."
--Wickerbottom.SDF_STANDARD_ARROWS = "Sharp tipped!"
--Wickerbottom.SDF_FLAMING_LONGBOW = "Flaky ash coated bow."
--Wickerbottom.SDF_FLAMING_ARROWS = "Heated tipped!"
--Wickerbottom.SDF_MAGIC_LONGBOW = "Erratic fungus ridden bow."
--Wickerbottom.SDF_MAGICAL_ARROWS = "Toxic tipped!"
--Wickerbottom.SDF_SPEAR = "Wrappings for other spears"
--Wickerbottom.SDF_SPEARS = "An over sized javelin."
--Wickerbottom.SDF_LIGHTNING_GAUNTLET = "Never strike in the same place twice!"
--Wickerbottom.SDF_LIGHTNING = "Zap zap!"
--Wickerbottom.SDF_GOODLIGHTNING = "I am not sure about this... odd feeling."
--Wickerbottom.SDF_CHICKEN_DRUMSTICK = "...five second rule?"

--Wickerbottom.SDF_COPPER_SHIELD = "Better than no protecton!"
--Wickerbottom.SDF_SILVER_SHIELD = "Easy wielding argent shield."
--Wickerbottom.SDF_GOLD_SHIELD = "Glorious shield that can take on a siege!"

Wickerbottom.SDF_VICTORIAN_SUIT = "Such an old suit should be in a museum."
Wickerbottom.SDF_GOLD_ARMOR = "Such an old item should be in a museum."
Wickerbottom.SDF_DRAGON_POTION = "Seems to contain dragons breath... Not drinking. Nope."
Wickerbottom.SDF_DRAGON_POTION_EMPTY = "Dry... All gone."
Wickerbottom.SDF_DRAGON_POTION_SKULLCAP = "I don't even..."

------------------------------------------
--Woodie.SDF_HELMET = "I am sure the owner survived..."
--Woodie.SDF_BOOK_OF_GOLLOWMERE = "Infomation gathered on all things Gallowmere!"
--Woodie.SDF_CHALICE_HALL_OF_HEROES = "A massive Goblet floating on a table."
--Woodie.SDF_CHALICE_RUNESTONE = "A large stone slab engraved with a cup."
--Woodie.SDF_CHALICE_ALTAR = "A ghastly floating cup!"
--Woodie.SDF_CHALICE_OF_SOULS = "Pretty fancy drinking cup."
--Woodie.SDF_SOUL_HELMET = "Small murmurs can be heard coming from this."
--Woodie.SDF_WITCH_TALISMAN = "Yuck... covered in pumpkin, mushrooms and... amber?"
--Woodie.SDF_CHEST_RUNESTONE = "Odd looking chest..."
--Woodie.SDF_CHEST_WOODEN = "Fragile wooden chest with Spikes."
--Woodie.SDF_CHEST_SKULL = "An uneasy looking chest with a crest."
--Woodie.SDF_STATUE = "Desecrated statue... Only the base remains."
--Woodie.SDF_WALL_WOOD = "It won't catch flame... fireproof wood?!"
--Woodie.SDF_WALL_STONE = "This stone will not be chipped!"
--Woodie.SDF_INFORMATION_GARGOYLE = "Seems like it wishes to talk, but won't say a word to me."
--Woodie.SDF_MERCHANT_GARGOYLE = "Takes gold and gives items, where does it store it all?"
--Woodie.SDF_SHOP_GARGOYLE = "A smaller gold hungry wall plaque."
--Woodie.SDF_GALLOWMERE_KNIGHT = "A faintly glowing skeleton knight."
--Woodie.SDF_KING_PEREGRINS_CROWN = "A crown that can't be worn... what a shame."

--Woodie.SDF_HEALTHFOUNTAIN = "Strange fluid coming from the ground!"
--Woodie.SDF_LIFEBOTTLE = "Not sure what that fluid inside is..."
--Woodie.SDF_ENERGYVIAL = "I will not taste this strange liquid."

Woodie.SDF_SMALL_SWORD = "Short gladiolus, should come in handy."
Woodie.SDF_BROAD_SWORD = "Now that's a sword!"
Woodie.SDF_ENCHANTED_SWORD = "Now that's a sword!"
Woodie.SDF_MAGIC_SWORD = "Blue sword that glows?"
--Woodie.SDF_CLUB = "Useful for bashing and exploring."
Woodie.SDF_HAMMER = "Not that good as an axe of course."
Woodie.SDF_AXE = "Lucy shouldn't be offended if I'll use it."

Woodie.SDF_THROWING_DAGGERS = "Small knives for throwing."
--Woodie.SDF_CROSSBOW = "Rapid firing mechanism."
--Woodie.SDF_STANDARD_BOLTS = "Honed tipped!"
--Woodie.SDF_LONGBOW = "Peculiarly large bow."
--Woodie.SDF_STANDARD_ARROWS = "Sharp tipped!"
--Woodie.SDF_FLAMING_LONGBOW = "Flaky ash coated bow."
--Woodie.SDF_FLAMING_ARROWS = "Heated tipped!"
--Woodie.SDF_MAGIC_LONGBOW = "Erratic fungus ridden bow."
--Woodie.SDF_MAGICAL_ARROWS = "Toxic tipped!"
--Woodie.SDF_SPEAR = "Wrappings for other spears"
--Woodie.SDF_SPEARS = "An over sized javelin."
--Woodie.SDF_LIGHTNING_GAUNTLET = "Never strike in the same place twice!"
--Woodie.SDF_LIGHTNING = "Zap zap!"
--Woodie.SDF_GOODLIGHTNING = "I am not sure about this... odd feeling."
--Woodie.SDF_CHICKEN_DRUMSTICK = "...five second rule?"

--Woodie.SDF_COPPER_SHIELD = "Better than no protecton!"
--Woodie.SDF_SILVER_SHIELD = "Easy wielding argent shield."
--Woodie.SDF_GOLD_SHIELD = "Glorious shield that can take on a siege!"

Woodie.SDF_VICTORIAN_SUIT = "My shirt is prettier!"
Woodie.SDF_GOLD_ARMOR = "Very uncomfortable armor."
Woodie.SDF_DRAGON_POTION = "Seems to contain dragons breath... Not drinking. Nope."
Woodie.SDF_DRAGON_POTION_EMPTY = "Dry... All gone."
Woodie.SDF_DRAGON_POTION_SKULLCAP = "I don't even..."

------------------------------------------
--Maxwell.SDF_HELMET = "I am sure the owner survived..."
--Maxwell.SDF_BOOK_OF_GOLLOWMERE = "Infomation gathered on all things Gallowmere!"
--Maxwell.SDF_CHALICE_HALL_OF_HEROES = "A massive Goblet floating on a table."
--Maxwell.SDF_CHALICE_RUNESTONE = "A large stone slab engraved with a cup."
--Maxwell.SDF_CHALICE_ALTAR = "A ghastly floating cup!"
--Maxwell.SDF_CHALICE_OF_SOULS = "Pretty fancy drinking cup."
--Maxwell.SDF_SOUL_HELMET = "Small murmurs can be heard coming from this."
--Maxwell.SDF_WITCH_TALISMAN = "Yuck... covered in pumpkin, mushrooms and... amber?"
--Maxwell.SDF_CHEST_RUNESTONE = "Odd looking chest..."
--Maxwell.SDF_CHEST_WOODEN = "Fragile wooden chest with Spikes."
--Maxwell.SDF_CHEST_SKULL = "An uneasy looking chest with a crest."
--Maxwell.SDF_STATUE = "Desecrated statue... Only the base remains."
--Maxwell.SDF_WALL_WOOD = "It won't catch flame... fireproof wood?!"
--Maxwell.SDF_WALL_STONE = "This stone will not be chipped!"
--Maxwell.SDF_INFORMATION_GARGOYLE = "Seems like it wishes to talk, but won't say a word to me."
--Maxwell.SDF_MERCHANT_GARGOYLE = "Takes gold and gives items, where does it store it all?"
--Maxwell.SDF_SHOP_GARGOYLE = "A smaller gold hungry wall plaque."
--Maxwell.SDF_GALLOWMERE_KNIGHT = "A faintly glowing skeleton knight."
--Maxwell.SDF_KING_PEREGRINS_CROWN = "A crown that can't be worn... what a shame."

--Maxwell.SDF_HEALTHFOUNTAIN = "Strange fluid coming from the ground!"
--Maxwell.SDF_LIFEBOTTLE = "Not sure what that fluid inside is..."
--Maxwell.SDF_ENERGYVIAL = "I will not taste this strange liquid."

Maxwell.SDF_SMALL_SWORD = "I prefer a more noble sword."
Maxwell.SDF_BROAD_SWORD = "With this blade I can have more fun."
Maxwell.SDF_ENCHANTED_SWORD = "With this blade I can have more fun."
Maxwell.SDF_MAGIC_SWORD = "Long sword upgraded with magic. Nice."
--Maxwell.SDF_CLUB = "Useful for bashing and exploring."
Maxwell.SDF_HAMMER = "I can destroy others work using it."
Maxwell.SDF_AXE = "Nice axe. I should use it."

Maxwell.SDF_THROWING_DAGGERS = "I can hurt others from a distance."
--Maxwell.SDF_CROSSBOW = "Rapid firing mechanism."
--Maxwell.SDF_STANDARD_BOLTS = "Honed tipped!"
--Maxwell.SDF_LONGBOW = "Peculiarly large bow."
--Maxwell.SDF_STANDARD_ARROWS = "Sharp tipped!"
--Maxwell.SDF_FLAMING_LONGBOW = "Flaky ash coated bow."
--Maxwell.SDF_FLAMING_ARROWS = "Heated tipped!"
--Maxwell.SDF_MAGIC_LONGBOW = "Erratic fungus ridden bow."
--Maxwell.SDF_MAGICAL_ARROWS = "Toxic tipped!"
--Maxwell.SDF_SPEAR = "Wrappings for other spears"
--Maxwell.SDF_SPEARS = "An over sized javelin."
--Maxwell.SDF_LIGHTNING_GAUNTLET = "Never strike in the same place twice!"
--Maxwell.SDF_LIGHTNING = "Zap zap!"
--Maxwell.SDF_GOODLIGHTNING = "I am not sure about this... odd feeling."
--Maxwell.SDF_CHICKEN_DRUMSTICK = "...five second rule?"

--Maxwell.SDF_COPPER_SHIELD = "Better than no protecton!"
--Maxwell.SDF_SILVER_SHIELD = "Easy wielding argent shield."
--Maxwell.SDF_GOLD_SHIELD = "Glorious shield that can take on a siege!"

Maxwell.SDF_VICTORIAN_SUIT = "Now that's a musty suit!"
Maxwell.SDF_GOLD_ARMOR = "This armor is terribly old-fashioned."
Maxwell.SDF_DRAGON_POTION = "Seems to contain dragons breath... Not drinking. Nope."
Maxwell.SDF_DRAGON_POTION_EMPTY = "Dry... All gone."
Maxwell.SDF_DRAGON_POTION_SKULLCAP = "I don't even..."

------------------------------------------
--Wigfrid.SDF_HELMET = "I am sure the owner survived..."
--Wigfrid.SDF_BOOK_OF_GOLLOWMERE = "Infomation gathered on all things Gallowmere!"
--Wigfrid.SDF_CHALICE_HALL_OF_HEROES = "A massive Goblet floating on a table."
--Wigfrid.SDF_CHALICE_RUNESTONE = "A large stone slab engraved with a cup."
--Wigfrid.SDF_CHALICE_ALTAR = "A ghastly floating cup!"
--Wigfrid.SDF_CHALICE_OF_SOULS = "Pretty fancy drinking cup."
--Wigfrid.SDF_SOUL_HELMET = "Small murmurs can be heard coming from this."
--Wigfrid.SDF_WITCH_TALISMAN = "Yuck... covered in pumpkin, mushrooms and... amber?"
--Wigfrid.SDF_CHEST_RUNESTONE = "Odd looking chest..."
--Wigfrid.SDF_CHEST_WOODEN = "Fragile wooden chest with Spikes."
--Wigfrid.SDF_CHEST_SKULL = "An uneasy looking chest with a crest."
--Wigfrid.SDF_STATUE = "Desecrated statue... Only the base remains."
--Wigfrid.SDF_WALL_WOOD = "It won't catch flame... fireproof wood?!"
--Wigfrid.SDF_WALL_STONE = "This stone will not be chipped!"
--Wigfrid.SDF_INFORMATION_GARGOYLE = "Seems like it wishes to talk, but won't say a word to me."
--Wigfrid.SDF_MERCHANT_GARGOYLE = "Takes gold and gives items, where does it store it all?"
--Wigfrid.SDF_SHOP_GARGOYLE = "A smaller gold hungry wall plaque."
--Wigfrid.SDF_GALLOWMERE_KNIGHT = "A faintly glowing skeleton knight."
--Wigfrid.SDF_KING_PEREGRINS_CROWN = "A crown that can't be worn... what a shame."

--Wigfrid.SDF_HEALTHFOUNTAIN = "Strange fluid coming from the ground!"
--Wigfrid.SDF_LIFEBOTTLE = "Not sure what that fluid inside is..."
--Wigfrid.SDF_ENERGYVIAL = "I will not taste this strange liquid."

Wigfrid.SDF_SMALL_SWORD = "It looks more like a toy!"
Wigfrid.SDF_BROAD_SWORD = "Now I can chop monsters!"
Wigfrid.SDF_ENCHANTED_SWORD = "Now I can chop monsters!"
Wigfrid.MAGIC_SWORD = "It's filled with magic, gross!"
--Wigfrid.SDF_CLUB = "Useful for bashing and exploring."
Wigfrid.SDF_HAMMER = "This is a heavy battle hammer!"
Wigfrid.SDF_AXE = "I can slice enemies!"

Wigfrid.SDF_THROWING_DAGGERS = "Too small for a real fight!"
--Wigfrid.SDF_CROSSBOW = "Rapid firing mechanism."
--Wigfrid.SDF_STANDARD_BOLTS = "Honed tipped!"
--Wigfrid.SDF_LONGBOW = "Peculiarly large bow."
--Wigfrid.SDF_STANDARD_ARROWS = "Sharp tipped!"
--Wigfrid.SDF_FLAMING_LONGBOW = "Flaky ash coated bow."
--Wigfrid.SDF_FLAMING_ARROWS = "Heated tipped!"
--Wigfrid.SDF_MAGIC_LONGBOW = "Erratic fungus ridden bow."
--Wigfrid.SDF_MAGICAL_ARROWS = "Toxic tipped!"
--Wigfrid.SDF_SPEAR = "Wrappings for other spears"
--Wigfrid.SDF_SPEARS = "An over sized javelin."
--Wigfrid.SDF_LIGHTNING_GAUNTLET = "Never strike in the same place twice!"
--Wigfrid.SDF_LIGHTNING = "Zap zap!"
--Wigfrid.SDF_GOODLIGHTNING = "I am not sure about this... odd feeling."
--Wigfrid.SDF_CHICKEN_DRUMSTICK = "...five second rule?"

--Wigfrid.SDF_COPPER_SHIELD = "Better than no protecton!"
--Wigfrid.SDF_SILVER_SHIELD = "Easy wielding argent shield."
--Wigfrid.SDF_GOLD_SHIELD = "Glorious shield that can take on a siege!"

Wigfrid.SDF_VICTORIAN_SUIT = "Too elegant. It doesn't fit into the hardships of battle!"
Wigfrid.SDF_GOLD_ARMOR = "Too fancy for a warrior!"
Wigfrid.SDF_DRAGON_POTION = "Seems to contain dragons breath... Not drinking. Nope."
Wigfrid.SDF_DRAGON_POTION_EMPTY = "Dry... All gone."
Wigfrid.SDF_DRAGON_POTION_SKULLCAP = "I don't even..."

------------------------------------------
--Webber.SDF_HELMET = "I am sure the owner survived..."
--Webber.SDF_BOOK_OF_GOLLOWMERE = "Infomation gathered on all things Gallowmere!"
--Webber.SDF_CHALICE_HALL_OF_HEROES = "A massive Goblet floating on a table."
--Webber.SDF_CHALICE_RUNESTONE = "A large stone slab engraved with a cup."
--Webber.SDF_CHALICE_ALTAR = "A ghastly floating cup!"
--Webber.SDF_CHALICE_OF_SOULS = "Pretty fancy drinking cup."
--Webber.SDF_SOUL_HELMET = "Small murmurs can be heard coming from this."
--Webber.SDF_WITCH_TALISMAN = "Yuck... covered in pumpkin, mushrooms and... amber?"
--Webber.SDF_CHEST_RUNESTONE = "Odd looking chest..."
--Webber.SDF_CHEST_WOODEN = "Fragile wooden chest with Spikes."
--Webber.SDF_CHEST_SKULL = "An uneasy looking chest with a crest."
--Webber.SDF_STATUE = "Desecrated statue... Only the base remains."
--Webber.SDF_WALL_WOOD = "It won't catch flame... fireproof wood?!"
--Webber.SDF_WALL_STONE = "This stone will not be chipped!"
--Webber.SDF_INFORMATION_GARGOYLE = "Seems like it wishes to talk, but won't say a word to me."
--Webber.SDF_MERCHANT_GARGOYLE = "Takes gold and gives items, where does it store it all?"
--Webber.SDF_SHOP_GARGOYLE = "A smaller gold hungry wall plaque."
--Webber.SDF_GALLOWMERE_KNIGHT = "A faintly glowing skeleton knight."
--Webber.SDF_KING_PEREGRINS_CROWN = "A crown that can't be worn... what a shame."

--Webber.SDF_HEALTHFOUNTAIN = "Strange fluid coming from the ground!"
--Webber.SDF_LIFEBOTTLE = "Not sure what that fluid inside is..."
--Webber.SDF_ENERGYVIAL = "I will not taste this strange liquid."

Webber.SDF_SMALL_SWORD = "This sword is small."
Webber.SDF_BROAD_SWORD = "Long sword can deal more damage."
Webber.SDF_ENCHANTED_SWORD = "Long sword can deal more damage."
Webber.MAGIC_SWORD = "Sword with magic!"
--Webber.SDF_CLUB = "Useful for bashing and exploring."
Webber.SDF_HAMMER = "We will smash things!"
Webber.SDF_AXE = "Good weapon for us."

Webber.SDF_THROWING_DAGGERS = "We can hit bugs with that."
--Webber.SDF_CROSSBOW = "Rapid firing mechanism."
--Webber.SDF_STANDARD_BOLTS = "Honed tipped!"
--Webber.SDF_LONGBOW = "Peculiarly large bow."
--Webber.SDF_STANDARD_ARROWS = "Sharp tipped!"
--Webber.SDF_FLAMING_LONGBOW = "Flaky ash coated bow."
--Webber.SDF_FLAMING_ARROWS = "Heated tipped!"
--Webber.SDF_MAGIC_LONGBOW = "Erratic fungus ridden bow."
--Webber.SDF_MAGICAL_ARROWS = "Toxic tipped!"
--Webber.SDF_SPEAR = "Wrappings for other spears"
--Webber.SDF_SPEARS = "An over sized javelin."
--Webber.SDF_LIGHTNING_GAUNTLET = "Never strike in the same place twice!"
--Webber.SDF_LIGHTNING = "Zap zap!"
--Webber.SDF_GOODLIGHTNING = "I am not sure about this... odd feeling."
--Webber.SDF_CHICKEN_DRUMSTICK = "...five second rule?"

--Webber.SDF_COPPER_SHIELD = "Better than no protecton!"
--Webber.SDF_SILVER_SHIELD = "Easy wielding argent shield."
--Webber.SDF_GOLD_SHIELD = "Glorious shield that can take on a siege!"

Webber.SDF_VICTORIAN_SUIT = "We don't like this."
Webber.SDF_GOLD_ARMOR = "We don't want this. Too shiny."
Webber.SDF_DRAGON_POTION = "Seems to contain dragons breath... Not drinking. Nope."
Webber.SDF_DRAGON_POTION_EMPTY = "Dry... All gone."
Webber.SDF_DRAGON_POTION_SKULLCAP = "I don't even..."
-------------------------------------------------------------------------Professors Lab Strings
    STRINGS.NOHOUSEPURPLESTAFF = "I can't use it here"
-------------------------------------------------------------------------------
modimport "scripts/speech/english/sdf_othermodquotes.lua"