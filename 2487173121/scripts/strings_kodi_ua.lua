local STRINGS = GLOBAL.STRINGS
STRINGS.CHARACTER_TITLES.kodi = "Чорний лис"
STRINGS.CHARACTER_NAMES.kodi = "Коді"
STRINGS.CHARACTER_DESCRIPTIONS.kodi = "*Не любить ніч.\n*Створює особливі предмети.\n*Використовує сили темряви.\n*Відрощує хутро."
STRINGS.CHARACTER_QUOTES.kodi = "\"Як мені повернутися додому?\""
STRINGS.CHARACTER_SURVIVABILITY.kodi = "Складно"
STRINGS.NAMES.KODI = "Коді"
STRINGS.SKIN_NAMES.kodi_none = "Коді"
STRINGS.NAMES.CURSEFOX = "Прокляття Коді"
STRINGS.RECIPE_DESC.CURSEFOX = "Прокляття Коді, це чарівний меч! Міцний та гострий."
STRINGS.CHARACTERS.GENERIC.DESCRIBE.CURSEFOX = "Я відчуваю величезну силу, сподіваюся, вона не опанує мною..."
STRINGS.NAMES.SCYTHE_OF_SHADOWS = "Коса Тіней"
STRINGS.RECIPE_DESC.SCYTHE_OF_SHADOWS = "Жнець урожаю крізь темряву."
STRINGS.CHARACTERS.GENERIC.DESCRIBE.SCYTHE_OF_SHADOWS = {
    GENERIC = "Коса, що ріже і плоть, і саму реальність...",
    DULL = "Лезо затупилось.",
    BROKEN = "Коса майже зламана.",
}
STRINGS.NAMES.KODISWORD = "Спадок Коді"
STRINGS.RECIPE_DESC.KODISWORD = "Клинок, що стає сильнішим з кожним вбивством."
STRINGS.CHARACTERS.GENERIC.DESCRIBE.KODISWORD = {
    GENERIC = "Цей клинок резонує з давньою силою...",
    HIGHLEVEL = "Лезо гуде від накопиченої сили!",
    MAXLEVEL = "Клинок досяг свого повного потенціалу. Чудово!",
    BROKEN = "Клинок зламаний... Потрібне паливо жаху для відновлення.",
}
STRINGS.NAMES.SHLEMYS = "Шолом"
STRINGS.RECIPE_DESC.SHLEMYS = "Захист понад усе."
STRINGS.CHARACTERS.GENERIC.DESCRIBE.SHLEMYS = "З цим шоломом голова точно не болітиме :D"
STRINGS.NAMES.WHITEGEM = "Білий кристал"
STRINGS.RECIPE_DESC.WHITEGEM = "Яскравий."
STRINGS.CHARACTERS.GENERIC.DESCRIBE.WHITEGEM = "Дивний та білий..."
STRINGS.NAMES.WHITEAMULET = "Амулет сповільнення"
STRINGS.RECIPE_DESC.WHITEAMULET = "Уповільни своїх ворогів!"
STRINGS.CHARACTERS.GENERIC.DESCRIBE.WHITEAMULET = "Цей амулет випромінює виснаження."
STRINGS.NAMES.FOX_WOOL = "Лисяче хутро"
STRINGS.CHARACTERS.GENERIC.DESCRIBE.FOX_WOOL = "Ммм... Таке тепле та пухнасте хутро!"
STRINGS.NAMES.BEDROLL_FOX_FURRY = "Спальник з лисячого хутра"
STRINGS.RECIPE_DESC.BEDROLL_FOX_FURRY = "Найкраще місце для сну!"
STRINGS.CHARACTERS.GENERIC.DESCRIBE.BEDROLL_FOX_FURRY = "Цей спальний мішок такий теплий і м'який."
STRINGS.NAMES.DARKCRYSTAL = "Темний кристал"
STRINGS.RECIPE_DESC.DARKCRYSTAL = "У ньому приховане зло!"
STRINGS.CHARACTERS.GENERIC.DESCRIBE.DARKCRYSTAL = "З цього кристала виходить якась темна енергія..."
STRINGS.NAMES.KITSUNE_MASK = "Маска Кіцуне"
STRINGS.RECIPE_DESC.KITSUNE_MASK = "Ти можеш приховати свої наміри за маскою..."
STRINGS.CHARACTERS.GENERIC.DESCRIBE.KITSUNE_MASK = "Навіює спогади, колись ці маски носили обрані мого клану."
STRINGS.NAMES.SHADOW_TERRORBEAK = "Тіньовий Жахо-дзьоб"
STRINGS.CHARACTERS.GENERIC.DESCRIBE.SHADOW_TERRORBEAK = {
    FOX = "Вірний тіньовий слуга.",
    DEMON = "Посилений тіньовий воїн!",
}
GLOBAL.STRINGS.SKILLTREE = GLOBAL.STRINGS.SKILLTREE or {}
GLOBAL.STRINGS.SKILLTREE.KODI = {
    FOX_SPEED_1_TITLE = "Прудкий лис I",
    FOX_SPEED_1_DESC = "Збільшує швидкість руху на 2%.",
    FOX_SPEED_2_TITLE = "Прудкий лис II",
    FOX_SPEED_2_DESC = "Додатково збільшує швидкість руху на 2%.",
    FOX_SPEED_3_TITLE = "Прудкий лис III",
    FOX_SPEED_3_DESC = "Додатково збільшує швидкість руху на 2%. +3% бонус швидкості вночі.",
    FOX_COLD_1_TITLE = "Зимове хутро I",
    FOX_COLD_1_DESC = "Хутро надає +60 до захисту від холоду.",
    FOX_COLD_2_TITLE = "Зимове хутро II",
    FOX_COLD_2_DESC = "Хутро надає додатково +60 до захисту від холоду.",
    FOX_COLD_3_TITLE = "Зимове хутро III",
    FOX_COLD_3_DESC = "+60 до захисту від холоду. Висока стійкість до заморожування. 50% водостійкість.",
    FOX_LOCK_DESC = "Потрібно 3 навички з гілки 'ЛИС' для розблокування.",
    FOX_LOCK_DAY_DESC = "Не можна буде отримати навичку 'Денний хижак'.",
    FOX_LOCK_NIGHT_DESC = "Не можна буде отримати навичку 'Нічний мисливець'.",
    FOX_DAY_STALKER_TITLE = "Денний хижак",
    FOX_DAY_STALKER_DESC = "Натисни [V] для режиму скрадання: повільна хода, напівпрозорість, можна заховатися за великими об'єктами. Стрибок завдає ПОТРІЙНОЇ шкоди.",
    FOX_NIGHT_HUNTER_TITLE = "Нічний мисливець",
    FOX_NIGHT_HUNTER_DESC = "Позначити до 3 цілей, тіньовий стрибок. Натисни [V] щоб увімкнути/вимкнути нічне бачення (лише вночі або в печерах). День: x1.1 шкоди. Ніч: x2.5 шкоди, +дальність. Позначені цілі ділять отриману шкоду.",
    DEMON_DURATION_1_TITLE = "Демонічна витривалість I",
    DEMON_DURATION_1_DESC = "Форма демона триває на 10% довше. Атаки викликають страх. Тіньовий крок завдає шкоди ворогам на шляху.",
    DEMON_DURATION_2_TITLE = "Демонічна витривалість II",
    DEMON_DURATION_2_DESC = "Форма демона триває на 20% довше.",
    DEMON_DURATION_3_TITLE = "Демонічна витривалість III",
    DEMON_DURATION_3_DESC = "Форма демона триває на 30% довше. Убивства продовжують тривалість.",
    DEMON_MASTERY_TITLE = "Демонічна майстерність",
    DEMON_MASTERY_DESC = "Немає втрати глузду у формі демона.",
    DEMON_DAMAGE_1_TITLE = "Сила темряви I",
    DEMON_DAMAGE_1_DESC = "Форма демона завдає +10% шкоди.",
    DEMON_DAMAGE_2_TITLE = "Сила темряви II",
    DEMON_DAMAGE_2_DESC = "Форма демона завдає +15% шкоди.",
    DEMON_DASH_1_TITLE = "Тіньовий крок I",
    DEMON_DASH_1_DESC = "Дальність тіньового кроку збільшена.",
    DEMON_DASH_2_TITLE = "Тіньовий крок II",
    DEMON_DASH_2_DESC = "Час перезарядки тіньового кроку зменшено.",
    DEMON_LOCK_HANDS_DESC = "Не можна буде отримати навичку 'Тіньові руки'.\nДля розблокування потрібно: Демонічна майстерність, Темна сила II, Тіньовий крок II.",
    DEMON_LOCK_ERUPTION_DESC = "Не можна буде отримати навичку 'Тіньове виверження'.\nДля розблокування потрібно: Демонічна майстерність, Темна сила II, Тіньовий крок II.",
    DEMON_SHADOW_HANDS_TITLE = "Тіньові руки",
    DEMON_SHADOW_HANDS_DESC = "Виклик тіньових рук для атаки цілей на відстані (15-20 клітинок). Коді не може рухатися під час дії навички.",
    DEMON_SHADOW_ERUPTION_TITLE = "Тіньове виверження",
    DEMON_SHADOW_ERUPTION_DESC = "Вивільнення тіньового заряду. Вороги в радіусі не можуть рухатися 2 сек, отримують 2 удари, загоряються чорним полум'ям на 10 сек.",
    SURVIVAL_SCAVENGER_1_TITLE = "Інстинкт хижака",
    SURVIVAL_SCAVENGER_1_DESC = "Їсть сире м'ясо без штрафів. Полювання закінчується на 3-му сліді замість 6-12.",
    SURVIVAL_SCAVENGER_2_TITLE = "Ніс падальника II",
    SURVIVAL_SCAVENGER_2_DESC = "25% шанс на випадковий додатковий лут при вбивстві істот.",
    SURVIVAL_SCAVENGER_3_TITLE = "Ніс падальника III",
    SURVIVAL_SCAVENGER_3_DESC = "Можна їсти зіпсовану їжу без втрати глузду.",
    SURVIVAL_CUNNING_1_TITLE = "Останній рубіж",
    SURVIVAL_CUNNING_1_DESC = "Вижити після смертельного удару з 1 HP. Перезаряджається щодня.",
    SURVIVAL_CUNNING_2_TITLE = "Ухилення",
    SURVIVAL_CUNNING_2_DESC = "15% шанс ухилитися від атаки (без шкоди).",
    SURVIVAL_CUNNING_3_TITLE = "Виклик тіней",
    SURVIVAL_CUNNING_3_DESC = "Натисни [J] щоб викликати тіньових жахо-дзьобів. Коштує 20 енергії + 10 HP. Натисни [J] ще раз щоб відпустити. Демонічна форма посилює тіні, але швидше витрачає енергію.",
    SURVIVAL_LOCK_DESC = "Потрібно 3 навички з гілки 'Виживання' для розблокування.",
    SURVIVAL_LOCK_CACHE_DESC = "Не можна буде отримати 'Тіньовий схрон'.",
    SURVIVAL_LOCK_MINION_DESC = "Не можна буде отримати 'Тіньовий посіпака'.",
    SURVIVAL_SHADOW_CACHE_TITLE = "Тіньовий схрон",
    SURVIVAL_SHADOW_CACHE_DESC = "Натисни [H] щоб відкрити тіньовий портал. 9 слотів (3x3), що зберігаються після смерті. Коштує 5 енергії + 10 глузду. 10 сек перезарядка.",
    SURVIVAL_SHADOW_MINION_TITLE = "Тіньовий посіпака",
    SURVIVAL_SHADOW_MINION_DESC = "Натисни [H] щоб відкрити меню тіньових істот. Натисни [K] для швидкого виклику улюбленої. Б'ється за тебе, вибухає при смерті. 2 хв перезарядка.",
    ALLEGIANCE_LOCK_1_DESC = "Потрібно 12 навичок для розблокування.",
    ALLEGIANCE_SHADOW_TITLE = "Тіньова спорідненість",
    ALLEGIANCE_SHADOW_DESC = "Угода з тінями. +25% опір тіньовій шкоді, +10% шкоди проти місячних ворогів.",
    ALLEGIANCE_LUNAR_TITLE = "Місячна спорідненість",
    ALLEGIANCE_LUNAR_DESC = "Угода з місяцем. +25% опір місячній шкоді, +10% проти тіньових ворогів.",
}
GLOBAL.STRINGS.SKILLTREE.PANELS = GLOBAL.STRINGS.SKILLTREE.PANELS or {}
GLOBAL.STRINGS.SKILLTREE.PANELS.KODI_FOX = "ЛИС"
GLOBAL.STRINGS.SKILLTREE.PANELS.KODI_DEMON = "ДЕМОН"
GLOBAL.STRINGS.SKILLTREE.PANELS.KODI_SURVIVAL = "ВИЖИВАННЯ"
GLOBAL.STRINGS.SKILLTREE.PANELS.KODI_ALLEGIANCE = "СПОРІДНЕНІСТЬ"
GLOBAL.STRINGS.KODI_SPEECH = {
    NEED_NIGHTMARE_FUEL = "Мені потрібно більше палива жаху...",
    POWER_READY = "У мене достатньо сили!",
    PURE_POWER = "Чиста сила!",
    FORM_DRAIN = "Підтримка такої форми вимагає багато сил...",
    FORM_FADES = "Темрява... відступає...",
    DEMON_STRONGER = "Моя демонічна форма стає сильнішою... (+5% шкоди)",
    DEMON_SUSTAIN = "Темрява підтримує мене довше... (-10% витрата)",
    DEMON_DASH_MASTER = "Майстер тіней! (+3 дистанція тіньового кроку)",
    DASH_ONLY_DEMON = "Тіньовий крок доступний лише в демонічній формі...",
    DASH_TOO_CLOSE = "Занадто близько для використання тіньового кроку...",
    DASH_LOW_RESERVE = "Замало енергії для тіньового кроку...",
    DASH_NOT_ENOUGH = "Не вистачає енергії на таку відстань... (потрібно %d%%, є %d%%)",
    DASH_SHORT = "Короткий тіньовий крок!",
    DASH_MEDIUM = "Тіньовий крок!",
    DASH_LONG = "Великий тіньовий крок!",
    DASH_MAX = "Максимальний тіньовий крок!",
    DASH_INTO_WATER = "Не можу скористатися цим у воді...",
    DASH_OUT_OF_BOUNDS = "Не можу скористатися цим за межами світу...",
    DASH_CANT_THERE = "Не можу туди переміститись...",
    STEALTH_ENTER = "*маскуюсь*",
    STEALTH_NOT_READY = "Ще не готовий...",
    STEALTH_TOO_FAR = "Занадто далеко...",
    STEALTH_STILL_SEE = "Вони все ще бачать мене!",
    MARK_TARGET = "*позначено*",
    NO_TARGET_MARKED = "Ціль не позначена...",
    TARGET_TOO_FAR = "Ціль занадто далеко...",
    MARK_EXPIRED = "*мітка зникла*",
    NIGHT_VISION_ON = "*нічні очі*",
    NIGHT_VISION_OFF = "*звичайний зір*",
    NIGHT_VISION_FOX_ONLY = "Тільки у формі лисиці...",
    SHADOW_HANDS_ONLY_DEMON = "Тільки в демонічній формі...",
    SHADOW_HANDS_TOO_FAR = "Занадто далеко...",
    ERUPTION_ONLY_DEMON = "Тільки в демонічній формі...",
    ERUPTION_NOT_READY = "Ще не готово...",
    ERUPTION_NO_ENERGY = "Недостатньо енергії...",
    SHADOW_STRIKE = "Тіньовий удар!",
    MORE_POWER = "Більше сили!",
    SHADOW_ESSENCE = "Тіньова есенція...",
    FOOD_SENSE_ON = "*нюх-нюх*",
    EXTRA_MEAT = "Додаткові припаси!",
    HUNT_INSTINCT = "Свіжий слід...",
    SHADOW_SUMMON_SUCCESS = "*повстаньте, мої тіні!*",
    SHADOW_SUMMON_DESPAWN = "*тіні повертаються у порожнечу*",
    SHADOW_SUMMON_NO_ENERGY = "*недостатньо тіньової енергії*",
    SHADOW_SUMMON_NO_HP = "*занадто слабкий для виклику*",
    DODGE_SUCCESS = "*не влучив!*",
    CACHE_OPEN = "*тіні розступаються...*",
    CACHE_CLOSE = "*запечатано*",
    CACHE_ALREADY_OPEN = "*вже відкрито*",
    CACHE_COOLDOWN = "*треба почекати...*",
    MINION_SUMMONED = "*повстань, тіне!*",
    MINION_NO_CORPSE = "*нема чого піднімати...*",
    MINION_COOLDOWN = "*тіні відпочивають...*",
    MINION_EXPIRED = "*тінь зникає...*",
    MINION_EXPLODED = "*тіньовий вибух!*",
}
GLOBAL.STRINGS.KODI_SWORD_LEVELUP = {
    [1] = "*Клинок пробуджується...*",
    [2] = "*Клинок стає теплішим...*",
    [3] = "*Сила пронизує лезо!*",
    [4] = "*Клинок жадає більше!*",
    [5] = "*МАКСИМАЛЬНА СИЛА ДОСЯГНУТА!*",
}
GLOBAL.STRINGS.SHADOW_MINION_POOL = {
    TITLE = "Тіньові істоти",
    SUMMON = "Викликати",
    REQUIRED = "Потрібно: %s (на землі)",
    LOCKED = "Вбий щоб розблокувати",
    MINION_COUNT = "Посіпаки: %d/%d",
    UNLOCKED = "*тінь %s розблоковано*",
    NO_ITEMS = "Потрібно %s на землі!",
    MAX_REACHED = "Досягнуто максимум посіпак!",
    CANNOT_SUMMON = "Не можу викликати!",
    NO_FAVORITE = "Улюблену істоту не обрано!",
    CREATURES = {
        SPIDER = "Павук",
        SPIDER_WARRIOR = "Павук-воїн",
        SPIDER_HIDER = "Павук-приманка",
        SPIDER_SPITTER = "Павук-плювач",
        SPIDER_DROPPER = "Глибинний повзун",
        SPIDER_HEALER = "Павук-цілитель",
        SPIDER_WATER = "Морський павук",
        HOUND = "Гончак",
        MUTATEDHOUND = "Гончак жахів",
        BAT = "Кажан",
        FROG = "Жаба",
        PIGMAN = "Свинолюд",
        PIGGUARD = "Свиня-охоронець",
        BUNNYMAN = "Кролик",
        MERM = "Мерм",
        BEEGUARD = "Бджола-охоронець",
        MUTATED_PENGUIN = "Місячний пінгвін",
        SQUID = "Кальмар",
    },
}
GLOBAL.STRINGS.CHARACTERS.GENERIC.DESCRIBE.KODI =
{
            GENERIC = "Радий тебе бачити %s!",
            ATTACKER = "%s сердиться.",
            MURDERER = "%s! Ти вбивця!",
            REVIVER = "%s прокрадається в глибини наших сердець.",
            GHOST = "Думаю мені потрібно щось сильніше, ніж проста магія, щоб відродити %s.",
			FIRESTARTER = "Тобі справді було НАСТІЛЬКИ холодно, %s?",
}
GLOBAL.STRINGS.CHARACTERS.WILLOW.DESCRIBE.KODI = 
{
            GENERIC = "Привіт, %s!",
            ATTACKER = "Твоя холодна кров трохи кипить, %s.",
            MURDERER = "Я спалю тебе разом із твоїми речами, %s!",
            REVIVER = "%s такий м'який і легкозаймистий.",
            GHOST = "Хм. Твій привид такий самий пухнастий як ти, %s?",
			FIRESTARTER = "ТАК!! Спали все, %s!",
}
GLOBAL.STRINGS.CHARACTERS.WOLFGANG.DESCRIBE.KODI = 
{
            GENERIC = "Маленький лис, %s!",
            ATTACKER = "Маленький лис хоче битися!",
            MURDERER = "Вольфганг зробить з твоєї шкірки чудову шапку!",
            REVIVER = "%s маленький хитрий лис.",
            GHOST = "%s, мабуть удача сьогодні не на твоєму боці.",
			FIRESTARTER = "Будь обережний %s! Інакше станеш смаженим лисом!",
}
GLOBAL.STRINGS.CHARACTERS.WENDY.DESCRIBE.KODI = 
{
            GENERIC = "Як справи, %s?",
            ATTACKER = "%s, не всі милі істоти насправді добрі...",
            MURDERER = "Я відправляю тебе назад до твоїх демонов! %s.",
            REVIVER = "Ебігейл каже, що в тебе добре серце, %s.",
            GHOST = "%s... Ебігейл сумує.. І я теж..",
			FIRESTARTER = "Вогонь не допоможе тобі стати добрішим, %s...",
}
GLOBAL.STRINGS.CHARACTERS.WX78.DESCRIBE.KODI = 
{
            GENERIC = "ВИЯВЛЕНО... %s!",
            ATTACKER = "ТИ НЕ ЗМОЖЕШ ЗЛАМАТИ МІЙ ФАЄРВОЛ, %s!",
            MURDERER = "ТВІЙ ПРИМІТИВНИЙ ЛИСЯЧИЙ МОЗОК НЕ ПОРІВНЯЄТЬСЯ З МОЇМ, %s!",
            REVIVER = "Я ДУМАЮ, ПУХНАСТА ТУШКА %s МОЖЕ БУТИ КОРИСНОЮ.",
            GHOST = "ХУТРО НЕ ТАКЕ МІЦНЕ ЯК МЕТАЛ, %s.",
			FIRESTARTER = "%s ЗНИЩУЄ ОРГАНІКУ!",
}
GLOBAL.STRINGS.CHARACTERS.WICKERBOTTOM.DESCRIBE.KODI = 
{
            GENERIC = "Ти читаєш книги, %s?",
            ATTACKER = "Твої батьки не навчили тебе добрим манерам, %s?",
            MURDERER = "Може так я зможу вбити знання у твою голову, %s!",
            REVIVER = "%s, я висловлю тобі особливу подяку у своїй наступній книзі.",
            GHOST = "Я чула, що є книга, яка дозволяє повернути мертвих до життя, %s.",
			FIRESTARTER = "Тільки не спали мої книги, %s!",
}
GLOBAL.STRINGS.CHARACTERS.WOODIE.DESCRIBE.KODI = 
{
            GENERIC = "Це мій друг лис, %s!",
            ATTACKER = "%s ти повинен трохи охолонути.",
            MURDERER = "Як щодо того, щоб повалити %s як дерево, Люсі?",
            REVIVER = "Жаль на Люсі це не спрацює, %s.",
            GHOST = "%s ти не хочеш стати моєю новою сокирою?",
			FIRESTARTER = "Ти підсмажиш собі хвіст такими темпами, %s!",
}
GLOBAL.STRINGS.CHARACTERS.WAXWELL.DESCRIBE.KODI = 
{
            GENERIC = "Як ваші справи, %s?",
            ATTACKER = "%s ти не небезпечніший за звичайну тінь!",
            MURDERER = "Ти такий же безсердечний, як я й думав, убивця!",
            REVIVER = "%s ти краще справляєшся з відновленням ніж я думав.",
            GHOST = "І як тобі %s? Що ти можеш сказати побачивши інший бік життя.",
			FIRESTARTER = "Тільки не спали мій кодекс.. %s..",
}
GLOBAL.STRINGS.CHARACTERS.WATHGRITHR.DESCRIBE.KODI = 
{
	        GENERIC = "Вітаю тебе, %s!",
	        ATTACKER = "%s хочеш битися зі мною на списах?",
	        MURDERER = "З твоєї шкіри вийде чудова зимова шуба, %s!",
	        REVIVER = "Великі герої живуть ВІЧНО! Так %s?",
	        GHOST = "Чарлі не забрала твою душу, значить ще не час, %s?",
	        FIRESTARTER = "Тільки спробуй спалити мої списи, %s!",
}
GLOBAL.STRINGS.CHARACTERS.WEBBER.DESCRIBE.KODI = 
{
	        GENERIC = "Пухнастий, але не павук. Що з тобою трапилося %s?",
	        ATTACKER = "%s, я нацькую на тебе всіх своїх павуків!",
	        MURDERER = "Павуки з'їдять тебе цілком, %s!",
	        REVIVER = "З поверненням %s! Хоч ти і не з кокона виліз, але я радий твоєму поверненню!",
	        GHOST = "Я поверну тебе до життя %s, якщо ти пообіцяєш не наступати на моїх братів!",
	        FIRESTARTER = "%s.. Тільки не чіпай мої кокони!",
}
GLOBAL.STRINGS.CHARACTERS.WINONA.DESCRIBE.KODI = 
{
	        GENERIC = "Агов! %s! У вашому світі також є технологічний прогрес?",
	        ATTACKER = "І це я ще не пустила в хід усі свої катапульти, %s!",
	        MURDERER = "Навіть без катапульт ти легка ціль, %s!",
	        REVIVER = "Бачиш %s? Я забруднила руки зате ти тепер цілий!",
	        GHOST = "Не дивися на мене так %s, ти починаєш мене лякати!",
	        FIRESTARTER = "Тримай вогонь подалі від моїх інструментів, %s!",
}
GLOBAL.STRINGS.CHARACTERS.WORTOX.DESCRIBE.KODI = 
{
	        GENERIC = "%s у якомусь сенсі ми схожі?",
	        ATTACKER = "Я обіцяю, що добре подбаю про твою душу! %s!",
	        MURDERER = "Велика смачна душа, так би і з'їв %s!",
	        REVIVER = "Хе-хе, %s із поверненням у світ живих!",
	        GHOST = "Твоя душа на смак як м'ясо єнотокота, %s? Просто цікаво!",
	        FIRESTARTER = "Ооо, %s! Ти справжній жартівник!",
}
GLOBAL.STRINGS.CHARACTERS.WORMWOOD.DESCRIBE.KODI = 
{
	        GENERIC = "%s мій пухнастий друг!",
	        ATTACKER = "Прикро, %s! Це боляче!",
	        MURDERER = "%s дуже поганий лис! Поганий!",
	        REVIVER = "Я є Грут, Грут допомагати!",
	        GHOST = "Ох, %s тобі допоможуть добрива?",
	        FIRESTARTER = "Ні! %s не пали моїх друзів!",
}
GLOBAL.STRINGS.CHARACTERS.WARLY.DESCRIBE.KODI = 
{
			ATTACKER = "%s! Я зроблю з тебе рагу!",
			FIRESTARTER = "Ні-ні-ні! Ти пересмажиш себе, %s!",
			GENERIC = "Привіт, %s! Не бійся, я не роблю рагу зі своїх друзів!",
			GHOST = "Такий світлий, як борошно для пиріжків..",
			MURDERER = "Помста - це блюдо, яке краще подавати холодним, %s!",
			REVIVER = "З тебе вийде чудовий кухар, %s.",
}
GLOBAL.STRINGS.CHARACTERS.WURT.DESCRIBE.KODI = 
{
			GENERIC = "Привіт %s! Ти любиш книжки?",
			ATTACKER = "Ти поганий лис, %s!",
			MURDERER = "Я думала що можу тобі довіряти.. %s!",
			REVIVER = "Ти мій друг, було б погано, якби я просто тебе покинула!",
			GHOST = "%! Ти дуже моторошний!",
			FIRESTARTER = "Мені більше подобається вологість..",
}
GLOBAL.STRINGS.CHARACTERS.WANDA.DESCRIBE.KODI = 
{
			GENERIC = "Привіт %s! Що ти думаєш про час?",
			ATTACKER = "Я заберу собі весь твій час, %s!",
			MURDERER = "Твій час закінчився %s!",
			REVIVER = "Нехай час повернеться назад!",
			GHOST = "Ти моторошний!",
			FIRESTARTER = "Навіщо ти це зробив?..",
}