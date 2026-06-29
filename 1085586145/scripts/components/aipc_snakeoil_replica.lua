local language=aipGetModConfig("language")

local aip_nectar_config=require("prefabs/aip_nectar_config")
local NEC_COLORS=aip_nectar_config.QUALITY_COLORS


local LANG_MAP={
english={
vampire="Vampire",
blood="Blood",
week="Week",
repair="Repair",
free="Flash",
back="Back",
slow="Obtuse",
painful="Pain",
},
chinese={
vampire="吸血",
blood="流血",
week="虚弱",
repair="复苏",
free="游侠",
back="击退",
slow="断筋",
painful="痛击",
},
}
local LANG=LANG_MAP[language] or LANG_MAP.english


local abilities={
vampire={
color=NEC_COLORS.quality_2,
},
blood={
color=NEC_COLORS.quality_2,
},
week={
color=NEC_COLORS.quality_3,
},
repair={
color=NEC_COLORS.quality_3,
},
free={
color=NEC_COLORS.quality_2,
},
back={
color=NEC_COLORS.quality_3,
},
slow={
color=NEC_COLORS.quality_2,
},
painful={
color=NEC_COLORS.quality_2,
},
}


local SnakeOilReplica=Class(function(self,inst)
self.inst=inst


if inst.replica.aipc_snakeoil~=nil then

self._ability=inst.replica.aipc_snakeoil._ability
else
self._ability=net_string(inst.GUID,"aipSnakeOil._ability","aipSnakeOil._abilityDirty")
end
end)

function SnakeOilReplica:Sync(ability)
self._ability:set(ability)
end

function SnakeOilReplica:GetAbility()
return self._ability:value() or ""
end


function SnakeOilReplica:GetInfo()
local ability=self:GetAbility()

if ability and ability~="" then
local infoName=LANG[ability] or "???"
local infoColor=abilities[ability] and abilities[ability].color or NEC_COLORS.quality_1

return infoName,infoColor
end
end

return SnakeOilReplica