
--Create Enchanted Earth Tomb Area
local function XpkjA(XL_, WYdR, QKKks_zt, Are7xU, yxjl, ZG)
    if type(XL_) ~= "function" then
        return
    end
    local QKKks_zt = QKKks_zt or 5
    local yxjl = yxjl or 0
    local Are7xU = Are7xU or 20
    for Vu0cCAf = 1, Are7xU, 1 do
        local q, kP7O5 = debug.getupvalue(XL_, Vu0cCAf)
        if q and q == WYdR then
            if ZG and type(ZG) == "string" then
                local lqT = debug.getinfo(XL_)
                if lqT.source and lqT.source:match(ZG) then
                    return kP7O5
                end
            else
                return kP7O5
            end
        end
        if yxjl < QKKks_zt and kP7O5 and type(kP7O5) == "function" then
            local mP3mlD = XpkjA(kP7O5, WYdR, QKKks_zt, Are7xU, yxjl + 1, ZG)
            if mP3mlD then
                return mP3mlD
            end
        end
    end
end

local function pVRj(PrPyxMK, tczrIB, a, wqU76o, LB1Z, N9L, hDc_M)
    if type(PrPyxMK) ~= "function" then
        return
    end
    local wqU76o = wqU76o or 5
    local N9L = N9L or 0
    local LB1Z = LB1Z or 20
    for qW0lRiD1 = 1, LB1Z, 1 do
        local iD1IUx, JLCOx_ak = debug.getupvalue(PrPyxMK, qW0lRiD1)
        if iD1IUx and iD1IUx == tczrIB then
            if hDc_M and type(hDc_M) == "string" then
                local hPQ = debug.getinfo(PrPyxMK)
                if hPQ.source and hPQ.source:match(hDc_M) then
                    return debug.setupvalue(PrPyxMK, qW0lRiD1, a)
                end
            else
                return debug.setupvalue(PrPyxMK, qW0lRiD1, a)
            end
        end
        if N9L < wqU76o and JLCOx_ak and type(JLCOx_ak) == "function" then
            local R1FIoQI = pVRj(JLCOx_ak, tczrIB, a, wqU76o, LB1Z, N9L + 1, hDc_M)
            if R1FIoQI then
                return R1FIoQI
            end
        end
    end
end

local function fuZ3z86(NsoTwDs, HGli, iy, m6SCS0, NUhYw6R4)
    if NsoTwDs and type(NsoTwDs) ~= "function" then
        return false
    end
    local Hv = debug.getinfo(NsoTwDs)
    if HGli and type(HGli) == "string" then
        local Ch = "/" .. HGli .. ".lua"
        if not Hv.source or not Hv.source:match(Ch) then
            return false
        end
    end
    if iy and type(iy) == "function" and not iy(Hv, m6SCS0, NUhYw6R4) then
        return false
    end
    return true
end

local function er(urkh, zhzpBSx, rHSjalVy, TjhsnP)
    if type(urkh) == "table" then
        if urkh.event_listening and urkh.event_listening[zhzpBSx] then
            local t5jzEd9 = urkh.event_listening[zhzpBSx]
            for JZAU2, zPXTTg in pairs(t5jzEd9) do
                if zPXTTg and type(zPXTTg) == "table" then
                    for seMLr, qX in pairs(zPXTTg) do
                        if fuZ3z86(qX, rHSjalVy, TjhsnP, JZAU2, urkh) then
                            return qX
                        end
                    end
                end
            end
        end
        if urkh.event_listeners and urkh.event_listeners[zhzpBSx] then
            local h_8 = urkh.event_listeners[zhzpBSx]
            for xL7OTb, w8T3f in pairs(h_8) do
                if w8T3f and type(w8T3f) == "table" then
                    for K, qL in pairs(w8T3f) do
                        if fuZ3z86(qL, rHSjalVy, TjhsnP, urkh, xL7OTb) then
                            return qL
                        end
                    end
                end
            end
        end
    end
end

local function DFb100j(vfIyB, quNsijN, QUh2tc)
    if type(vfIyB) == "table" then
        local qboV = vfIyB.worldstatewatching and vfIyB.worldstatewatching[quNsijN] or nil
        if qboV then
            for nSBOx7, u in pairs(qboV) do
                if fuZ3z86(u, QUh2tc) then
                    return u
                end
            end
        end
    end
end

return {Get = XpkjA, Set = pVRj, GetEventHandle = er, GetWorldHandle = DFb100j}