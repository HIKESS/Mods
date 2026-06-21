name = "Kodi"
description = "Kodi is a small fox character who has quite an interesting story, you can read about it on the mod page in the discussion section. I hope you like my mod and rate it in the steam workshop.\n*Українською\n*Коді це невеликий персонаж лис, який має доволі цікаву історію, ознайомитись можна на сторінці модифікації в розділі обговорень. Сподіваюся вам сподобається моя модифікація і ви оціните її в майстерні стім."
author = "Exorciamus"
version = "1.7.3"
api_version = 10
dst_compatible = true
dont_starve_compatible = false
reign_of_giants_compatible = true
shipwrecked_compatible = false
all_clients_require_mod = true 
icon_atlas = "modicon.xml"
icon = "modicon.tex"
server_filter_tags = {"character", "Kodi",}
local opt_Empty = {{description = "", data = 0}}
local function Title(title,hover) return {	name=title,
			hover=hover,
			options=opt_Empty,
			default=0, } end
local SEPARATOR = Title("")
configuration_options =
{
	Title("Character localization."),
	SEPARATOR,
    {
		name = "kodilanguage",
		label = "Language",
		hover = "Customize the text settings used by the character!\n Налаштуйте параметри тексту, що використовується персонажем!",
		options =
		{
			{description = "English Default", data = "ENGLISH", hover = "Англійська за замовчуванням"},
			{description = "Ukrainian", data = "UKRAINIAN", hover = "Українська"},
		},
		default = "ENGLISH",
	},
	SEPARATOR,
	Title("Parameters in transformation.\n Параметри трансформації."),
	SEPARATOR,
	{
		name = "demonicfuel_count",
		label = "Nightmare fuel for transform",
		hover = "How many nightmare fuel needed for transformation.\n Скільки палива кошмарів потрібно для трансформації.",
		options = {
			{description = "3", data = 3, hover = "3"},
			{description = "4", data = 4, hover = "4"},
			{description = "5", data = 5, hover = "5"},
			{description = "6 Default", data = 6, hover = "6 За замовчуванням"},
			{description = "8", data = 8, hover = "8"},
			{description = "10", data = 10, hover = "10"},
		},
		default = 6,
	},
	{
		name = "transform_duration",
		label = "Transform duration (sec)",
		hover = "How long the transformation lasts.\n Скільки секунд триває трансформація.",
		options = {
			{description = "30s", data = 30, hover = "30 сек"},
			{description = "45s", data = 45, hover = "45 сек"},
			{description = "60s", data = 60, hover = "60 сек"},
			{description = "70s Default", data = 70, hover = "70 сек За замовчуванням"},
			{description = "90s", data = 90, hover = "90 сек"},
			{description = "120s", data = 120, hover = "120 сек"},
		},
		default = 70,
	},
	SEPARATOR,
	Title("Demonic Badge Position.\n Позиція демонічного значка."),
	SEPARATOR,
	{
		name = "badge_pos_x",
		label = "Badge X position",
		hover = "Horizontal position of demonic badge.\n Горизонтальна позиція демонічного значка.",
		options = {
			{description = "-200", data = -200, hover = "Далеко зліва"},
			{description = "-160", data = -160, hover = "Зліва"},
			{description = "-120 Default", data = -120, hover = "За замовчуванням"},
			{description = "-80", data = -80, hover = "Ближче до центру"},
			{description = "-40", data = -40, hover = "Біля центру"},
			{description = "0", data = 0, hover = "Центр"},
			{description = "40", data = 40, hover = "Справа від центру"},
			{description = "80", data = 80, hover = "Справа"},
			{description = "120", data = 120, hover = "Далеко справа"},
		},
		default = -120,
	},
	{
		name = "badge_pos_y",
		label = "Badge Y position",
		hover = "Vertical position of demonic badge.\n Вертикальна позиція демонічного значка.",
		options = {
			{description = "-120", data = -120, hover = "Нижче"},
			{description = "-80", data = -80, hover = "Трохи нижче"},
			{description = "-40 Default", data = -40, hover = "За замовчуванням"},
			{description = "0", data = 0, hover = "На рівні"},
			{description = "20", data = 20, hover = "Вище"},
			{description = "60", data = 60, hover = "Набагато вище"},
			{description = "-160", data = -160, hover = "Дуже низько"},
		},
		default = -40,
	},
	{
		name = "kill_energy_bonus",
		label = "Kill energy bonus (%)",
		hover = "Energy gained per kill in demon form.\n Енергія за вбивство в демон-формі.",
		options = {
			{description = "0 (off)", data = 0, hover = "Вимкнено"},
			{description = "3%", data = 3, hover = "3%"},
			{description = "5% Default", data = 5, hover = "5% За замовчуванням"},
			{description = "7%", data = 7, hover = "7%"},
			{description = "10%", data = 10, hover = "10%"},
			{description = "15%", data = 15, hover = "15%"},
		},
		default = 5,
	},
	{
		name = "shadow_dash_cost",
		label = "Shadow Dash energy cost (%)",
		hover = "Energy cost for Shadow Dash ability.\n Вартість енергії для Shadow Dash.",
		options = {
			{description = "5%", data = 5, hover = "5%"},
			{description = "10% Default", data = 10, hover = "10% За замовчуванням"},
			{description = "15%", data = 15, hover = "15%"},
			{description = "20%", data = 20, hover = "20%"},
			{description = "25%", data = 25, hover = "25%"},
		},
		default = 10,
	},
	{
		default = 120,
		hover = "Key to transformation Kodi.\n Виберіть клавішу трансформації Коді.",
		label   = "Transform Key",
		name    = "key_kodi",
		options = (function()
			local KEY_A  = 97
			local values = {}
			local chars  = {
				"A","B","C","D","E","F","G","H","I","J","K","L","M",
				"N","O","P","Q","R","S","T","U","V","W","X Default","Y","Z"
			}
			for i = 1, #chars do
				values[#values + 1] = { description = chars[i], data = i + KEY_A - 1 }
			end
			return values
		end)()
	},
	SEPARATOR,
	Title("Kitsune mask.\n Маска Кіцуне."),
	SEPARATOR,
	{
		name    = "cooldown",
		label   = "Cooldown Time",
		hover	= "Cooldown Time. Default: 5s.\n Час відновлення. За замовчуванням: 5 секунд.",
		options =
		{
			{description = "1s", data = 1, hover = "1сек"},
			{description = "2s", data = 2, hover = "2сек"},
			{description = "3s", data = 3, hover = "3сек"},
			{description = "4s", data = 4, hover = "4сек"},
			{description = "5s", data = 5, hover = "5сек"},
			{description = "6s", data = 6, hover = "6сек"},
			{description = "7s", data = 7, hover = "7сек"},
			{description = "8s", data = 8, hover = "8сек"},
			{description = "9s", data = 9, hover = "9сек"},
			{description = "10s", data = 10, hover = "10сек"},
		},
		default = 5,
	},
	{
        name = "cooldownColor",
        label = "Cooldown color",
		hover	= "Cooldown color setings.\n Вкажіть колір ефекту.",
        options =
        {
            {description = "Black", data = 0.0, hover = "Чорний"},
            {description = "Blue", data = 0.4, hover = "Блакитний"},
        },
        default = 0.0,
    },
	{
		name    = "attacknumber",
		label   = "Maximum number of attacks",
		hover	= "Maximum number of attacks. Default: 16.\n Максимальна кількість поглинених атак. За замовчуванням 16.",
		options =
		{
			{description = "x16", data = 6},
			{description = "x32", data = 3},
			{description = "x48", data = 2},
			{description = "x96", data = 1},
		},
		default = 6,
	},
	{
		name    = "freeze",
		label   = "Chance of freezing",
		hover	= "Specify a percentage for the probability of the attacker freezing.\n Вкажіть у відсотках ймовірність заморожування нападника.",
		options =
		{
			{description = "1%", data = 0.01},
			{description = "2%", data = 0.02},
			{description = "3%", data = 0.03},
			{description = "4%", data = 0.04},
			{description = "5%", data = 0.05},
			{description = "10%", data = 0.10},
			{description = "15%", data = 0.15},
			{description = "20% Default", data = 0.20},
			{description = "25%", data = 0.25},
			{description = "30%", data = 0.30},
			{description = "35%", data = 0.35},
			{description = "40%", data = 0.40},
			{description = "45%", data = 0.45},
			{description = "50%", data = 0.50},
			{description = "55%", data = 0.55},
			{description = "60%", data = 0.60},
			{description = "65%", data = 0.65},
			{description = "70%", data = 0.70},
			{description = "75%", data = 0.75},
			{description = "80%", data = 0.80},
			{description = "85%", data = 0.85},
			{description = "90%", data = 0.90},
			{description = "95%", data = 0.95},
			{description = "100%", data = 1},
		},
		default = 0.20,
	},
	{
        name = "damagefreeze",
        label = "Damage freeze",
		hover	= "The attacker was damage by freezing.\n Нападник отримав пошкодження від замерзання.",
        options =
        {
            {description = "50 Default", data = 50, hover = "50 За замовчуванням"},
            {description = "100", data = 100, hover = "100"},
			{description = "150", data = 150, hover = "150"},
			{description = "200", data = 200, hover = "200"},
			{description = "250", data = 250, hover = "250"},
			{description = "300", data = 300, hover = "300"},
			{description = "350", data = 350, hover = "350"},
			{description = "400", data = 400, hover = "400"},
        },
        default = 50,
    },
	{
        name = "freezetime",
        label = "Freeze Time",
		hover	= "Set how many seconds the attacker will be frozen.\n Встановіть, на скільки секунд нападника буде заморожено.",
        options =
        {
            {description = "2 Default", data = 2, hover = "2 За замовчуванням"},
            {description = "3", data = 3, hover = "3"},
			{description = "4", data = 4, hover = "4"},
			{description = "5", data = 5, hover = "5"},
			{description = "6", data = 6, hover = "6"},
			{description = "7", data = 7, hover = "7"},
			{description = "8", data = 8, hover = "8"},
			{description = "9", data = 9, hover = "9"},
			{description = "10", data = 10, hover = "10"},
        },
        default = 2,
    },
}