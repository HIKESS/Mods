local STRINGS = GLOBAL.STRINGS

STRINGS.CHARACTER_TITLES.william = "The Toy Maker"
STRINGS.CHARACTER_NAMES.william = "William"
STRINGS.CHARACTER_DESCRIPTIONS.william = "*Brains over brawn \n*Invents wondrous animatronics \n*Likes to stay proper"
STRINGS.CHARACTER_QUOTES.william = "\"Creativity is the key to success! \""

STRINGS.SKIN_NAMES.william_none = "William"
STRINGS.SKIN_DESCRIPTIONS.william_none = "Olive green is a very relaxing colour."

-- The character's name as appears in-game 
STRINGS.NAMES.WILLIAM = "William"

STRINGS.CHARACTERS.WILLIAM = require "speech_william"



STRINGS.CHARACTER_SURVIVABILITY.william = "Grim"

STRINGS.NAMES.WILLIAMGADGET = "Heart of Invention"
STRINGS.RECIPE_DESC.WILLIAMGADGET = "The foundations of something great."
STRINGS.CHARACTERS.WILLIAM.DESCRIBE.WILLIAMGADGET = "The possibilities are endless!"

STRINGS.CHARACTERS.GENERIC.DESCRIBE.WILLIAMGADGET = "It's vibrating with potential."


STRINGS.NAMES.WILLIAMBUTLER = "Butler Bot"
STRINGS.NAMES.WILLIAMBUTLER_BUILDER = "Butler Bot"
STRINGS.RECIPE_DESC.WILLIAMBUTLER_BUILDER = "Make yourself a friend."
STRINGS.CHARACTERS.WILLIAM.DESCRIBE.WILLIAMBUTLER = {
							FINE = "One of my finer works, if I do say so myself.",
							LOWFUEL = "It's looking a bit low on fuel.",
							CRITICALFUEL = "I should fetch some fuel for that!",
							EMPTY = "The poor thing needs fuel!",
							}
STRINGS.CHARACTERS.GENERIC.DESCRIBE.WILLIAMBUTLER = "I should get one for myself!"
STRINGS.CHARACTERS.WAXWELL.DESCRIBE.WILLIAMBUTLER = "How did I never think of that..."


STRINGS.NAMES.WILLIAMBUSTER = "Buster Bot"
STRINGS.NAMES.WILLIAMBUSTER_BUILDER = "Buster Bot"
STRINGS.RECIPE_DESC.WILLIAMBUSTER_BUILDER = "Packs a punch!"
STRINGS.CHARACTERS.WILLIAM.DESCRIBE.WILLIAMBUSTER = {
							FINE = "I'm not one to throw down, myself.",
							LOWFUEL = "It's looking a bit low on fuel.",
							CRITICALFUEL = "I should fetch some fuel for that!",
							EMPTY = "The poor thing needs fuel!",
							}
STRINGS.CHARACTERS.GENERIC.DESCRIBE.WILLIAMBUSTER = "Ready to knock something's block off!"
STRINGS.CHARACTERS.WAXWELL.DESCRIBE.WILLIAMBUSTER = "A rather crude contraption."

STRINGS.NAMES.WILLIAMBRUTE = "Bouncer Bot"
STRINGS.NAMES.WILLIAMBRUTE_BUILDER = "Bouncer Bot"
STRINGS.RECIPE_DESC.WILLIAMBRUTE_BUILDER = "Keeps threats out of the door."
STRINGS.CHARACTERS.WILLIAM.DESCRIBE.WILLIAMBRUTE =  {
							FINE = "A peaceful laboratory is a productive laboratory!",
							LOWFUEL = "It's looking a bit low on fuel.",
							CRITICALFUEL = "I should fetch some fuel for that!",
							EMPTY = "The poor thing needs fuel!",
							}
STRINGS.CHARACTERS.GENERIC.DESCRIBE.WILLIAMBRUTE =  "Keep up the big work, good guy."
STRINGS.CHARACTERS.WAXWELL.DESCRIBE.WILLIAMBRUTE =  "Keep up the big work, good guy."

STRINGS.NAMES.WILLIAMBALLISTIC = "Battery Hat"
STRINGS.NAMES.WILLIAMBALLISTIC_EMPTY = "Battery Hat"
STRINGS.RECIPE_DESC.WILLIAMBALLISTIC_EMPTY = "A shocking fashion statement!"
STRINGS.CHARACTERS.WILLIAM.DESCRIBE.WILLIAMBALLISTIC =  {
							FINE = "Eureka! I've tamed the power of lightning!",
							LOWFUEL = "It's looking a bit low on fuel.",
							CRITICALFUEL = "I should fetch some fuel for that!",
							EMPTY = "The poor thing needs fuel!",
							}
STRINGS.CHARACTERS.GENERIC.DESCRIBE.WILLIAMBALLISTIC = "It's making my hair stand up."


STRINGS.NAMES.TIDDLESTRANGER_WILLIAM = "Kind Stranger"
STRINGS.CHARACTERS.GENERIC.DESCRIBE.TIDDLESTRANGER_WILLIAM = "He says a lot of nothing."
STRINGS.CHARACTERS.WX78.DESCRIBE.TIDDLESTRANGER_WILLIAM = "ERROR: UNKNOWN ENTITY"
STRINGS.CHARACTERS.WICKERBOTTOM.DESCRIBE.TIDDLESTRANGER_WILLIAM = "I wonder what lies beneath that mysterious garb."
STRINGS.CHARACTERS.WAXWELL.DESCRIBE.TIDDLESTRANGER_WILLIAM = "I don't remember that one."
STRINGS.CHARACTERS.WENDY.DESCRIBE.TIDDLESTRANGER_WILLIAM = "A guardian angel?"
STRINGS.CHARACTERS.WILLOW.DESCRIBE.TIDDLESTRANGER_WILLIAM = "Who the heck are you?"
STRINGS.CHARACTERS.WOLFGANG.DESCRIBE.TIDDLESTRANGER_WILLIAM = "Is creepy strange man."
STRINGS.CHARACTERS.WATHGRITHR.DESCRIBE.TIDDLESTRANGER_WILLIAM = "An eerie prophet!"
STRINGS.CHARACTERS.WORMWOOD.DESCRIBE.TIDDLESTRANGER_WILLIAM = "Helpy friend"
STRINGS.CHARACTERS.WURT.DESCRIBE.TIDDLESTRANGER_WILLIAM = "Flort. Stranger danger."
STRINGS.CHARACTERS.WARLY.DESCRIBE.TIDDLESTRANGER_WILLIAM = "Greetings, uh... I didn't get your name?"
STRINGS.CHARACTERS.WORTOX.DESCRIBE.TIDDLESTRANGER_WILLIAM = "Hyuyuyu! A trickster after my own heart!"
STRINGS.CHARACTERS.WINONA.DESCRIBE.TIDDLESTRANGER_WILLIAM = "Those shoulders don't seem practical."
STRINGS.CHARACTERS.WOODIE.DESCRIBE.TIDDLESTRANGER_WILLIAM = "I like your funny words, magic man."

STRINGS.TIDDLESTRANGER_WILLIAM_GREETING = {"Hey there, friend!", "Oh, hello there!", "Hey, friend!"}
STRINGS.TIDDLESTRANGER_WILLIAM_FAREWELL = {"Take care, friend!", "I'm with ya every step of the way!", "Don't die out there!"}
STRINGS.TIDDLESTRANGER_WILLIAM_ENDSPEECH = {"But I think I've said enough for now.", "But I won't spoil that surprise!", "But you'll have to figure that out!", "But that's all I can say for today!"}
STRINGS.TIDDLESTRANGER_WILLIAM_SCENARIO = {
	LIGHTNING = {
	"Your robo-buddies are lookin' a bit low on juice.", "Allow me to help with that!"
	},
	SPIDERS = {
	"How 'bout a little game?", "I got a nice little prize in it for ya.", "The rules are simple:", "You beat my pet, you get the prize!"
	},
	WILLIAMCLONE = {
	"The world really needs more people like you.", "That's why I decided to make one!", "Wanna see?"
	},
	WILLIAMBOT = {
	"I made something for you!", "Somethin' real special...", "It's an automaton!", "Take a look!"
	},
	LIGHT = {
	"Allow me to shed some light on the situation!"
	},
}
STRINGS.TIDDLESTRANGER_WILLIAM_SCENARIO_END = {
	LIGHTNING = {
	"Sorry 'bout that.", "Guess I got a little excited."
	},
	SPIDERS = {
	"Oh. Ya did it.", "Well! Fair's fair.", "Hope ya enjoy it!", "Now I need to find a new pet..."
	},
	WILLIAMCLONE = {
	"...", "I'm still workin' out some of the kinks.", "Perfection takes time, y'know?"
	},
	WILLIAMBOT = {
	"Well, I made the blueprint. Thought you'd like to piece it together.", "It's fueled with rabbits!", "You go have fun with that now."
	},
	LIGHT = {
	"That's the best I got.", "Hope that helped, now."
	},
}
STRINGS.TIDDLESTRANGER_VIRUS_SPIDERWON = {"Guess ya didn't have it in ya after all.", "Oops. I didn't think ya'd DIE.", "Now ain't that a darn shame."}

STRINGS.TIDDLESTRANGER_WILLIAM_DEFAULT = {
	{
        "Lovely weather we're having, huh?",
	"It only goes down from here..."
	},
	{
        "Ever wonder where those frogs came from?",
	"I hear they came from the sky...",
	"Almost like there's someplace over the clouds...",
	},
	{
        "You don't look so good.", 
	"You better find something to eat before night comes!",
	"How was that?",
	"I'm practicin' for whenever I get to be a villain..."
	},
	{
	"Have ya been under the ground?",
	"Seen what's left of the ancients' world?",
	"Treasures and horrors abound down there...",
	},
}

STRINGS.TIDDLESTRANGER_WILLIAM_BANTER = {
	{
        "I should be on that throne right now... oh, the things I'd make."
	},
	{
        "Don't ya have... things you need to do, friend?",
	},
	{
        "I appreciate the company an all, but this is gettin' a bit awkward.",
	},
	{
        "You just gonna stand there all day, friend?",
	},
	{
        "You just gonna stand there all day, friend?",
	},
	{
        "You're still here. Why are you still here?",
	},
	{
        "Wanna hear a joke?",
	"...",
        "Ah...I forgot what it was.",
	},
	{
        "Me? I'm quite old, ya'know.",
        "Not, like, ancient or anything. But... old.",
	},
	{
        "So... ya like jazz?",
        "Been too long since I seen a gig.",
	},
	{
        "I know many things, ya'know. Learned so much.",
        "Understand how this world works...",
	"...but I can't understand why you're still here.",
	},
	{
        "Pst... can I interest you in some forbidden knowledge?",
	"I'm just kiddin' ya. That's MY knowledge.",
	},
}

STRINGS.TIDDLESTRANGER_WILLIAM_ADVICE = {
	BUSY = {
        "Oh. I see you're busy.",
        "I'll just come back later.",
    	},
	LOWSANITY = {
        "You doin' alright there, friend?",
        "You're lookin' a little rough around the edges.",
        "Maybe ya should take a day off? A nice cup of tea?",
	"Wouldn't want Them gettin' a whiff of ya. Not like this.",
    	},
	KILLED = {
        "You did it! You put them pests right in their place!",
        "But they'll be back...",
        "I'm sure you can handle 'em, though.",
	"Anyways, I just came around to congratulate you."
	},
	REVIVER = {
        "Look at you!",
        "A real asset to the team!",
        "They'd all be dead without you, ya'know.",
	"Keep up the good work!",
	"And don't let no one tell you what's what.",
	"You're better than those slackers."
	},
	MURDERER = {
        "You're rackin' up quite the headcount!",
        "I ain't judgin' none. Honest.",
        "Strong feasting on the weak;",
	"Dog eat dog world;",
	"Survival of the fittest;",
	"All that good stuff."
	},
	DAPPER = {
        "Lookin' snazzy!",
        "Even that fop in the suit oughta envy you.",
        "But remember to kick off those shoes once in a while.",
	"Relax and unwind-like."
	},
	RABBIT = {
        "I've been thinkin'...",
        "These rabbits, right? They're smarter than you'd think.",
        "What if we made us a robot...",
	"...and fueled it with rabbits!",
	"Oh, the things we could make together..."
	},
	WILLIAM = {
        "How's the toymaking business?",
        "Them contraptions must be a hot commodity 'round these parts.",
        "Maybe one day we could come up with something together...",
	"...The ultimate invention."
	},
	WARFARIN = {
        "I spoke to that girl.",
        "She seems to be doin' just fine.",
        "Tried to take somethin' from my robes, though.",
	"You'd oughta teach her some manners!",
	},
}