local HGli = require "util/sdf_enchanted_earth_tomb_functions"

--Pumpkin Gorge Well
local R1FIoQI = {}
local function NsoTwDs(PlwhaRKJ)
    if PlwhaRKJ and PlwhaRKJ >= 1085 and PlwhaRKJ <= 2015 then
        return true
    end
    return false
end

AddPrefabPostInit("world",function(Caz4NM4Z)
    local XVxxx = getmetatable(Caz4NM4Z.Map).__index
    if XVxxx then
	XVxxx.CreateSDFEnchantedEarthTomb = function(T, WZs, ITdz, AjfoUo)
	    R1FIoQI[AjfoUo] = {WZs, ITdz}
	end
	XVxxx.RemoveSDFEnchantedEarthTomb = function(Er9zidsB, X)
	    if R1FIoQI[X] ~= nil then
		R1FIoQI[X] = nil
	    end
	end
	local hD = XVxxx.IsAboveGroundAtPoint
	XVxxx.IsAboveGroundAtPoint = function(dR, JFXtQwy, uMV17h0, E2NZK, ...)
	    if NsoTwDs(E2NZK) then
		for WNWWe, zMzjn3lk in pairs(R1FIoQI) do
		    if zMzjn3lk and E2NZK >= zMzjn3lk[2] - 13 and E2NZK <= zMzjn3lk[2] + 12 and
			JFXtQwy >= zMzjn3lk[1] - 8 and JFXtQwy <= zMzjn3lk[1] + 8 then
			if TheSim:WorldPointInPoly(JFXtQwy,E2NZK,
			    {
				{zMzjn3lk[1] - 6.2, zMzjn3lk[2] + 10},
				{zMzjn3lk[1] - 6.2, zMzjn3lk[2] - 10.6},
				{zMzjn3lk[1] + 7.8, zMzjn3lk[2] - 12},
				{zMzjn3lk[1] + 7.8, zMzjn3lk[2] + 12}
			    })
			    then
			    return true
			end
		    end
		end
	    end
	    return hD(dR, JFXtQwy, uMV17h0, E2NZK, ...)
	end
	local G5BuU5 = XVxxx.IsVisualGroundAtPoint
	XVxxx.IsVisualGroundAtPoint = function(Trkkpmd, L, GGv, ZIzh4Si, ...)
	    if NsoTwDs(ZIzh4Si) then
		for c8D4n81, cSjJHx in pairs(R1FIoQI) do
		    if cSjJHx and ZIzh4Si >= cSjJHx[2] - 13 and ZIzh4Si <= cSjJHx[2] + 12 and L >= cSjJHx[1] - 8 and L <= cSjJHx[1] + 8 then
			if TheSim:WorldPointInPoly(L,ZIzh4Si,
			    {
				{cSjJHx[1] - 6.2, cSjJHx[2] + 10},
				{cSjJHx[1] - 6.2, cSjJHx[2] - 10.6},
				{cSjJHx[1] + 7.8, cSjJHx[2] - 12},
				{cSjJHx[1] + 7.8, cSjJHx[2] + 12}
			    })
			    then
			    return true
			end
		    end
		end
	    end
	    return G5BuU5(Trkkpmd, L, GGv, ZIzh4Si, ...)
	end
	local AfwsY = XVxxx.GetTileCenterPoint
	XVxxx.GetTileCenterPoint = function(fa, M, dIZlrvD, jQgsATKd)
	    if jQgsATKd and jQgsATKd >= 900 and jQgsATKd <= 2200 then
		return math.floor(M / 4) * 4 + 2, 0, math.floor(jQgsATKd / 4) * 4 + 2
	    end
	    if jQgsATKd then
		return AfwsY(fa, M, dIZlrvD, jQgsATKd)
	    else
		return AfwsY(fa, M, dIZlrvD)
	    end
	end
    end
    if not TheWorld.ismastersim then
	return
    end
    Caz4NM4Z:AddComponent("sdf_enchanted_earth_tomb_limiter")
    Caz4NM4Z.components.sdf_enchanted_earth_tomb_limiter:SetName(modname)
    Caz4NM4Z:ListenForEvent("ms_playerdespawnanddelete",function(Caz4NM4Z, aBbGg)
	if aBbGg and aBbGg._insdfenchantedearthtombcamera then
	    aBbGg.spawnanddelete_sdfenchantedearthtomb = true
	    aBbGg._insdfenchantedearthtombcamera:set(nil)
	end
    end)
end)


AddPrefabPostInit("forest",function(D9)
    if not TheWorld.ismastersim then
	return
    end
    local G = HGli.GetWorldHandle(D9, "israining", "components/frograin")
    if G then
	local QgC = HGli.Get(G, "GetSpawnPoint")
	if QgC ~= nil then
	    local CYoa = QgC
	    local function K3ipRr(F2tY)
	    if NsoTwDs(F2tY.z) then
		return nil
	    end
		return CYoa(F2tY)
	    end
	    HGli.Set(G, "GetSpawnPoint", K3ipRr)
	end
    end
    local gE = HGli.GetEventHandle(TheWorld, "ms_lightwildfireforplayer", "components/wildfires")
    if gE then
	local rb21L2 = HGli.Get(gE, "LightFireForPlayer")
	if rb21L2 ~= nil then
	    local o_v255 = rb21L2
	    local function wUVm(VQ, oTYNsnP)
		if VQ ~= nil then
		    local I, L, mR5gwW = VQ.Transform:GetWorldPosition()
		    if NsoTwDs(mR5gwW) then
			return
		    end
		end
		o_v255(VQ, oTYNsnP)
	    end
	    HGli.Set(gE, "LightFireForPlayer", wUVm)
	end
    end
end)