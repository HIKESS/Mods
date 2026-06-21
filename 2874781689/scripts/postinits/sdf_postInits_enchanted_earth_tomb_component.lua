local HGli = require "util/sdf_enchanted_earth_tomb_functions"

--Enchanted Earth Tomb
local function NsoTwDs(PlwhaRKJ)
    if PlwhaRKJ and PlwhaRKJ >= 1085 and PlwhaRKJ <= 2015 then
        return true
    end
    return false
end

AddComponentPostInit("witherable",function(EEpoeR)
    if EEpoeR.inst then
	EEpoeR.inst:DoTaskInTime(0.1,function(_k)
	    local Ef, KfM, Vd = _k.Transform:GetWorldPosition()
	    if NsoTwDs(Vd) then
		EEpoeR:Enable(false)
	    end
	end)
    end
end)

AddComponentPostInit("sinkholespawner",function(s4)
    local FFG = s4.SpawnSinkhole
    function s4:SpawnSinkhole(a31jEAS)
	if NsoTwDs(a31jEAS.z) then
	    return false
	end
	return FFG(s4, a31jEAS)
    end
end)

local Ch = {
    day = "images/colour_cubes/identity_colourcube.tex",
    dusk = "images/colour_cubes/identity_colourcube.tex",
    night = "images/colour_cubes/identity_colourcube.tex",
    full_moon = "images/colour_cubes/identity_colourcube.tex"
}

AddComponentPostInit("playervision",function(LS4h)
    local eux092_P = LS4h.UpdateCCTable
    function LS4h:UpdateCCTable()
	eux092_P(LS4h)
	if LS4h.currentcctable == nil then
	    --Enchanted Earth Tomb
	    if LS4h.inst._insdfenchantedearthtombcamera ~= nil and LS4h.inst._insdfenchantedearthtombcamera:value() ~= nil then
		LS4h.currentcctable = Ch
		LS4h.inst:PushEvent("ccoverrides", Ch)
	    else
		LS4h.inst:PushEvent("ccoverrides", nil)
	    end
	end
    end
end)

AddComponentPostInit("moisture",function(ZA9)
    local hWgmxm = ZA9.GetMoistureRate
    function ZA9:GetMoistureRate()
	if not TheWorld.state.israining then
	    return 0
	end
	--Pumpkin Gorge Well
	if ZA9.inst._insdfenchantedearthtombcamera ~= nil and ZA9.inst._insdfenchantedearthtombcamera:value() ~= nil then
	    return 0
	end
	return hWgmxm(ZA9)
    end
end)

AddComponentPostInit("areaaware",function(_gGmBBE)
    local rIX4 = _gGmBBE.UpdatePosition
    function _gGmBBE:UpdatePosition(AI14eFhp, iW2O, Gdp, ...)
	if NsoTwDs(Gdp) then
	    _gGmBBE.lastpt.x, _gGmBBE.lastpt.z = AI14eFhp, Gdp
	    if _gGmBBE.current_area_data ~= nil then
		_gGmBBE.current_area = -1
		_gGmBBE.current_area_data = nil
		_gGmBBE.inst:PushEvent("changearea", _gGmBBE:GetCurrentArea())
	    end
	    return
	end
	return rIX4(_gGmBBE, AI14eFhp, iW2O, Gdp, ...)
    end
end)

AddComponentPostInit("birdspawner",function(nbqmx)
    local IWQcC = nbqmx.GetSpawnPoint
    function nbqmx:GetSpawnPoint(W9yaJm)
	if NsoTwDs(W9yaJm.z) then
	    return nil
	else
	    return IWQcC(nbqmx, W9yaJm)
	end
    end
    local cvRh = HGli.Get(nbqmx.SpawnBird, "PickBird")
    if cvRh ~= nil then
	local oJ1ec = cvRh
	local function L(MMNWLk)
	local x6Ni = oJ1ec(MMNWLk)
	local Q2waXkyp, EG72, mlTMZ = MMNWLk:Get()
	local pumpkinGorgeWell = TheSim:FindEntities(Q2waXkyp, EG72, mlTMZ, TUNING.BIRD_CANARY_LURE_DISTANCE, {"sdf_enchanted_earth_tomb_door"})
	if #pumpkinGorgeWell ~= 0 and math.random() < 0.5 then
	    return "quagmire_pigeon"
	else
	    return x6Ni
	end
    end
    HGli.Set(nbqmx.SpawnBird, "PickBird", L)
    end
end)