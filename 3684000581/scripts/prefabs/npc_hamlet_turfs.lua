-- scripts/prefabs/npc_hamlet_turfs.lua
-- Hamlet DLC 13 种猪镇地皮移植到 DST
-- ────────────────────────────────────────────────────────────
-- 设计：
--   · 走 vanilla DST turfs.lua 的标准范式（deployable + DEPLOYMODE.TURF + gridplacer）
--   · 使用 Hamlet 原版 turf.zip / turf_1.zip 作为道具 inv 外观
--   · 铺到地面用 modmain 注册的 HAMLET_xxx 自定义 tile（纹理是猪镇原版）；
--     如果由于某种原因新 tile 未被识别，落回到最接近的 DST vanilla tile
--     作为兜底以保证不会崩溃。

-- tile_name 对应 modmain.lua 里 AddTile 注册的 tile 名（全大写）
-- fallback_tile 是 WORLD_TILES.HAMLET_xxx 失败时的兜底 vanilla tile
local TURF_DATA = {
    { name = "pigruins",                anim = "pig_ruins",     tile_name = "HAMLET_PIGRUINS",                fallback_tile = GROUND.BRICK,        cn = "猪人遗迹地皮",       en = "Pig Ruins Turf" },
    { name = "rainforest",              anim = "rainforest",    tile_name = "HAMLET_RAINFOREST",              fallback_tile = GROUND.FOREST,       cn = "雨林地皮",           en = "Rainforest Turf" },
    { name = "deeprainforest",          anim = "deepjungle",    tile_name = "HAMLET_DEEPRAINFOREST",          fallback_tile = GROUND.FOREST,       cn = "深雨林地皮",         en = "Deep Rainforest Turf" },
    { name = "lawn",                    anim = "checkeredlawn", tile_name = "HAMLET_LAWN",                    fallback_tile = GROUND.CHECKER,      cn = "草坪地皮",           en = "Lawn Turf" },
    { name = "gasjungle",               anim = "gasjungle",     tile_name = "HAMLET_GASJUNGLE",               fallback_tile = GROUND.MARSH,        cn = "毒气丛林地皮",       en = "Gas Jungle Turf" },
    { name = "moss",                    anim = "mossy_blossom", tile_name = "HAMLET_MOSS",                    fallback_tile = GROUND.GRASS,        cn = "苔藓地皮",           en = "Moss Turf" },
    { name = "fields",                  anim = "farmland",      tile_name = "HAMLET_FIELDS",                  fallback_tile = GROUND.FARMING_SOIL, cn = "农田地皮",           en = "Fields Turf" },
    { name = "foundation",              anim = "fanstone",      tile_name = "HAMLET_FOUNDATION",              fallback_tile = GROUND.WOODFLOOR,    cn = "基石地皮",           en = "Foundation Turf" },
    { name = "cobbleroad",              anim = "cobbleroad",    tile_name = "HAMLET_COBBLEROAD",              fallback_tile = GROUND.ROAD,         cn = "鹅卵石路地皮",       en = "Cobblestone Road Turf" },
    { name = "painted",                 anim = "bog",           tile_name = "HAMLET_PAINTED",                 fallback_tile = GROUND.MARSH,        cn = "彩绘地皮",           en = "Painted Turf" },
    { name = "plains",                  anim = "plains",        tile_name = "HAMLET_PLAINS",                  fallback_tile = GROUND.SAVANNA,      cn = "平原地皮",           en = "Plains Turf" },
    { name = "beard_hair",              anim = "beard_hair",    tile_name = "HAMLET_BEARDRUG",                fallback_tile = GROUND.CARPET,       cn = "胡须地毯地皮",       en = "Beard Hair Rug Turf" },
    { name = "deeprainforest_nocanopy", anim = "deepjungle",    tile_name = "HAMLET_DEEPRAINFOREST_NOCANOPY", fallback_tile = GROUND.FOREST,       cn = "深雨林(无树冠)地皮", en = "Deep Rainforest (No Canopy) Turf" },
}

local prefabs_shared = { "gridplacer" }


local function L(zh, en)
    local ok, play = pcall(function() return STRINGS.UI.MAINSCREEN.PLAY end)
    if ok and play and play:match("[\228-\233]") then
        return zh
    end
    local ok2, lt = pcall(function() return LanguageTranslator end)
    if ok2 and lt and lt.defaultlanguage then
        local lang = tostring(lt.defaultlanguage)
        if lang:find("zh") or lang == "schinese" or lang == "tchinese" then
            return zh
        end
    end
    return en
end

local function MakeTurf(data)
    local turf_name = "turf_" .. data.name

    
    
    local function ondeploy(inst, pt, deployer)
        if deployer ~= nil and deployer.SoundEmitter ~= nil then
            deployer.SoundEmitter:PlaySound("dontstarve/wilson/dig")
        end
        local map = TheWorld.Map
        local x, y = map:GetTileCoordsAtPoint(pt:Get())
        if x ~= nil and y ~= nil then
            local tile_id = (WORLD_TILES and WORLD_TILES[data.tile_name]) or data.fallback_tile
            map:SetTile(x, y, tile_id)
        end
        inst.components.stackable:Get():Remove()
    end

    local assets = {
        Asset("ANIM", "anim/turf.zip"),
        Asset("ANIM", "anim/turf_1.zip"),
    }

    local function fn()
        local inst = CreateEntity()

        inst.entity:AddTransform()
        inst.entity:AddAnimState()
        inst.entity:AddNetwork()

        MakeInventoryPhysics(inst)

        inst.AnimState:SetBank("turf")
        inst.AnimState:SetBuild("turf")
        inst.AnimState:AddOverrideBuild("turf_1")
        inst.AnimState:PlayAnimation(data.anim)

        inst:AddTag("groundtile")
        inst:AddTag("molebait")

        
        MakeInventoryFloatable(inst, "med", nil, 0.65)

        inst.scrapbook_anim = data.anim
        inst.scrapbook_specialinfo = "TURF"
        inst.scrapbook_deps = {}

        inst.entity:SetPristine()

        
        if not TheWorld.ismastersim then
            return inst
        end

        inst:AddComponent("stackable")
        inst.components.stackable.maxsize = TUNING.STACK_SIZE_MEDITEM

        inst:AddComponent("inspectable")
        inst:AddComponent("inventoryitem")
        
        inst.components.inventoryitem.atlasname = "images/hamlet_inv2.xml"
        inst.components.inventoryitem.imagename = "turf_" .. data.name
        inst:AddComponent("bait")

        inst:AddComponent("fuel")
        inst.components.fuel.fuelvalue = TUNING.TINY_FUEL
        MakeMediumBurnable(inst, TUNING.MED_BURNTIME)
        MakeSmallPropagator(inst)
        MakeHauntableLaunchAndIgnite(inst)

        inst:AddComponent("deployable")
        inst.components.deployable:SetDeployMode(DEPLOYMODE.TURF)
        inst.components.deployable.ondeploy = ondeploy
        inst.components.deployable:SetUseGridPlacer(true)

        return inst
    end

    return Prefab(turf_name, fn, assets, prefabs_shared)
end


STRINGS.NAMES = STRINGS.NAMES or {}
for _, data in ipairs(TURF_DATA) do
    STRINGS.NAMES[string.upper("turf_" .. data.name)] = L(data.cn, data.en)
end


local ret = {}
for _, data in ipairs(TURF_DATA) do
    ret[#ret + 1] = MakeTurf(data)
end
return unpack(ret)
