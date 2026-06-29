
local dress_uses=aipGetModConfig("dress_uses")
local language=aipGetModConfig("language")


local PERISH_MAP={
["less"]=0.5,
["normal"]=1,
["much"]=2,
}

local LANG_MAP={
english={
NAME="Haunted Wizard Hat",
DESC="Ghosts can't scare me anymore",
},
chinese={
NAME="闹鬼巫师帽",
DESC="鬼已经吓不到我了",
},
}

TUNING.AIP_WIZARD_FUEL=TUNING.YELLOWAMULET_FUEL*PERISH_MAP[dress_uses]

local LANG=LANG_MAP[language] or LANG_MAP.english


STRINGS.NAMES.AIP_WIZARD_HAT=LANG.NAME
STRINGS.CHARACTERS.GENERIC.DESCRIBE.AIP_WIZARD_HAT=LANG.DESC

local function onremovebody(body)
body._aipHat._aipEye=nil
end


local tempalte=require("prefabs/aip_dress_template")


return tempalte("aip_wizard_hat",{
rad=0,
dapperness=TUNING.DAPPERNESS_LARGE,
fueled={
level=TUNING.AIP_WIZARD_FUEL,
},
waterproofer=true,
onEquip=function(inst,owner)
if inst._aipAura~=nil then
inst._aipAura:Remove()
end

inst._aipAura=SpawnPrefab("aip_aura_see")
inst:AddChild(inst._aipAura)










end,
onUnequip=function(inst,owner)
if inst._aipAura~=nil then
inst._aipAura:Remove()
end
inst._aipAura=nil
end,
preInst=function(inst)
inst:AddTag("aip_no_shadow_stun")
end,
})
