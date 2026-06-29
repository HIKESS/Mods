local foldername=KnownModIndex:GetModActualName(TUNING.ZOMBIEJ_ADDTIONAL_PACKAGE)


local dress_uses=aipGetModConfig("dress_uses")
local language=aipGetModConfig("language")


local PERISH_MAP={
["less"]=0.5,
["normal"]=1,
["much"]=2,
}

local LANG_MAP={
["english"]={
["NAME"]="Horse Head",
["REC_DESC"]="It makes you faster",
["DESC"]="I have 4 legs",
},
["russian"]={
["NAME"]="Голова Лошади",
["REC_DESC"]="Это сделает тебя быстрее",
["DESC"]="Теперь у меня 4 ноги.",
},
["chinese"]={
["NAME"]="马头",
["REC_DESC"]="让你跑的更快",
["DESC"]="我感觉长了4条腿",
},
}

local LANG=LANG_MAP[language] or LANG_MAP.english

TUNING.AIP_HORSE_HEAD_FUEL=TUNING.YELLOWAMULET_FUEL*PERISH_MAP[dress_uses]


STRINGS.NAMES.AIP_HORSE_HEAD=LANG.NAME
STRINGS.RECIPE_DESC.AIP_HORSE_HEAD=LANG.REC_DESC
STRINGS.CHARACTERS.GENERIC.DESCRIBE.AIP_HORSE_HEAD=LANG.DESC

local tempalte=require("prefabs/aip_dress_template")
return tempalte("aip_horse_head",{
hideHead=true,
walkspeedmult=TUNING.CANE_SPEED_MULT,
fueled={
level=TUNING.AIP_HORSE_HEAD_FUEL,
},
waterproofer=true,
luck=0.1,
})




















































































