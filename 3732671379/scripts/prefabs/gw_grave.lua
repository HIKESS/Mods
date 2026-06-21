local assets =
{
    Asset("ANIM", "anim/gw_grave.zip"),
    Asset("ANIM", "anim/gravestones.zip"),
}

----[]----[]----[]----[]----[]----[]----[]----[]----[]----[]----[]----[]----[]----[]----
----坟堆的挖掘时效果
local function OnDig(inst)
    SpawnAt("fallingswish_clouds", inst)
end

----[]----[]----[]----[]----[]----[]----[]----[]----[]----[]----[]----[]----[]----[]----
----墓穴箱子被挖没时
local function OnDiged(inst, worker, workleft)
    SpawnAt("mole_move_fx", inst)
    SpawnAt("carnival_unwrap_fx", inst)

    if inst.components.container ~= nil then
        inst.components.container:DropEverything()
        inst.components.container:Close()
    end

    inst:Remove()
end

----[]----[]----[]----[]----[]----[]----[]----[]----[]----[]----[]----[]----[]----[]----
----生成前辈
local function SpawnQianBei(inst)
    --- 前辈
    SpawnAt("skeleton", inst)
    --- 前辈的一！五！
    local loot_table = {
        { {item = "cutstone", count = 3} },
        { {item = "rope", count = 4} },
        { {item = "boards", count = 4} },
        { {item = "spear", count = 1}, {item = "armorwood", count = 1} },
        { {item = "cane", count = 1}, {item = "goldnugget", count = 2} },
        { {item = "backpack", count = 1}, {item = "bandage", count = 2} },
        { {item = "strawhat", count = 1}, {item = "bugnet", count = 1} },
        { {item = "strawhat", count = 1}, {item = "fishingrod", count = 1} },
    }

    local choice = math.random(1, #loot_table)
    local items = loot_table[choice]
    local x, y, z = inst.Transform:GetWorldPosition()
    for _, entry in ipairs(items) do
        local prefab = entry.item
        local count = tonumber(entry.count) or 1
        for i = 1, count do
            local loot = SpawnPrefab(prefab)
            if loot then
                local offset_x = math.random(-100, 100) / 100
                local offset_z = math.random(-100, 100) / 100
                local start_pos = Vector3(x + offset_x, y + 2.5, z + offset_z)
                loot.Transform:SetPosition(start_pos:Get())
                inst.components.lootdropper:FlingItem(loot, start_pos)
            end
        end
    end
end

----[]----[]----[]----[]----[]----[]----[]----[]----[]----[]----[]----[]----[]----[]----
----生成宝藏箱子时的权重物品
local CATEGORY_WEIGHTS = {
    resource = 25,
    gem = 12,
    equipment = 10,
    rare = 3,
}

local CATEGORY_ITEMS = {
    resource = {
        {prefab = "cutstone", weight = 1},
        {prefab = "boards", weight = 1},
        {prefab = "rope", weight = 1},
        {prefab = "gears", weight = 1},
        {prefab = "boneshard", weight = 1},
        {prefab = "goldnugget", weight = 1},
        {prefab = "thulecite", weight = 1},
        {prefab = "livinglog", weight = 1},
        {prefab = "trinket_6", weight = 1},
        {prefab = "moonglass", weight = 1},
    },
    gem = {
        {prefab = "redgem", weight = 1},
        {prefab = "bluegem", weight = 1},
        {prefab = "orangegem", weight = 1},
        {prefab = "yellowgem", weight = 1},
        {prefab = "greengem", weight = 1},
        {prefab = "purplegem", weight = 1},
    },
    equipment = {
        {prefab = "tentaclespike", weight = 1},
        {prefab = "glasscutter", weight = 1},
        {prefab = "nightsword", weight = 1},
        {prefab = "slurtlehat", weight = 1},
        {prefab = "beehat", weight = 1},
        {prefab = "armor_sanity", weight = 1},
        {prefab = "minerhat", weight = 1},
        -- 分季节
        {prefab = "winterhat",     weight = 1, seasonal = "winter"},
        {prefab = "watermelonhat", weight = 1, seasonal = "summer"},
        {prefab = "rainhat",       weight = 1, seasonal = "spring"},
    },
    rare = {
        {prefab = "walrus_tusk", weight = 1},
        {prefab = "gnarwail_horn", weight = 1},
        {prefab = "lightninggoathorn", weight = 1},
        {prefab = "steelwool", weight = 1},
        {prefab = "opalpreciousgem", weight = 1},
    },
}

-- 获取当前季节然后添加
local function GetCurrentEquipmentItems()
    local items = {}
    for _, entry in ipairs(CATEGORY_ITEMS.equipment) do
        if not entry.seasonal then
            table.insert(items, entry)
        else
            if entry.seasonal == "winter" and TheWorld.state.iswinter then
                table.insert(items, entry)
            elseif entry.seasonal == "summer" and TheWorld.state.issummer then
                table.insert(items, entry)
            elseif entry.seasonal == "spring" and TheWorld.state.isspring then
                table.insert(items, entry)
            end
        end
    end
    return items
end

---计算权重然后放入物品
local function ChooseCategory()
    local total = 0
    for _, weight in pairs(CATEGORY_WEIGHTS) do
        total = total + weight
    end
    local roll = math.random() * total
    local accum = 0
    for category, weight in pairs(CATEGORY_WEIGHTS) do
        accum = accum + weight
        if roll <= accum then
            return category
        end
    end
    return "resource"
end

local function ChooseItemFromCategory(category)
    local items_list
    if category == "equipment" then
        items_list = GetCurrentEquipmentItems()
    else
        items_list = CATEGORY_ITEMS[category]
    end
    if not items_list or #items_list == 0 then
        return nil
    end
    local total_weight = 0
    for _, entry in ipairs(items_list) do
        total_weight = total_weight + entry.weight
    end
    local roll = math.random() * total_weight
    local accum = 0
    for _, entry in ipairs(items_list) do
        accum = accum + entry.weight
        if roll <= accum then
            return entry.prefab
        end
    end
    return items_list[1].prefab
end

local function FillTreasureChest(chest)
    if not chest.components.container then
        return
    end
    local num_items = math.random(1, 3)
    for i = 1, num_items do
        local category = ChooseCategory()
        local prefab = ChooseItemFromCategory(category)
        if prefab then
            local item = SpawnPrefab(prefab)
            if item then
                chest.components.container:GiveItem(item)
            end
        end
    end
end

----[]----[]----[]----[]----[]----[]----[]----[]----[]----[]----[]----[]----[]----[]----
----生成怪物惩罚
local MONSTER_LIST = {
    "hound", "spider_warrior", "knight_nightmare", "bishop_nightmare",
    "merm", "frog", "beeguard", "nightmarebeak", "crawlingnightmare",
}

local function SpawnMonsterAtPoint(center_x, center_z, radius, target)
    local angle = math.random() * 2 * math.pi
    local dist = math.random() * radius
    local offset_x = math.cos(angle) * dist
    local offset_z = math.sin(angle) * dist
    local pt = Vector3(center_x + offset_x, 0, center_z + offset_z)

    if not TheWorld.Map:IsPassableAtPoint(pt.x, 0, pt.z, false, true) then
        return false
    end

    local monster_prefab = MONSTER_LIST[math.random(1, #MONSTER_LIST)]
    local monster = SpawnPrefab(monster_prefab)
    if monster then
        monster.Transform:SetPosition(pt.x, 0, pt.z)
        local spawnfx = SpawnPrefab("spawn_fx_small_high")
        if spawnfx then
            spawnfx.Transform:SetPosition(pt.x, 0, pt.z)
        end
        if target and monster.components.combat then
            monster.components.combat:SetTarget(target)
        end
        return true
    end
    return false
end

-- 在坟墓位置周围生成怪物
local function SpawnMonstersAround(inst, worker)
    if not inst or not inst.Transform then return end
    local x, y, z = inst.Transform:GetWorldPosition()
    local num_monsters = math.random(2, 4)

    for i = 1, num_monsters do
        local success = false
        for attempt = 1, 4 do
            if SpawnMonsterAtPoint(x, z, 8, worker) then
                success = true
                break
            end
        end
    end
end

----[]----[]----[]----[]----[]----[]----[]----[]----[]----[]----[]----[]----[]----[]----
----检查号角是否唯一
local function IsHaoJiaoExists()
    local entities = TheSim:FindEntities(0,0,0, 10000, {"gwen_haojiao"})
    for _, ent in ipairs(entities) do
        if ent.prefab == "gwen_haojiao" then
            return true
        end
    end
    return false
end

local function IsHunDengExists()
    local entities = TheSim:FindEntities(0,0,0, 10000, {"gwen_hudeng"})
    for _, ent in ipairs(entities) do
        if ent.prefab == "gw_hundeng" then
            return true
        end
    end
    return false
end

----[]----[]----[]----[]----[]----[]----[]----[]----[]----[]----[]----[]----[]----[]----
----生成5条冰狗
local function SpawnIceHoundAndPenguinPack(inst, worker)
    if not inst or not inst.Transform then return end
    local x, y, z = inst.Transform:GetWorldPosition()
    local radius = 8
    for i = 1, 5 do
        for attempt = 1, 5 do
            local angle = math.random() * 2 * math.pi
            local dist = math.random() * radius
            local offset_x = math.cos(angle) * dist
            local offset_z = math.sin(angle) * dist
            local pt = Vector3(x + offset_x, 0, z + offset_z)

            if TheWorld.Map:IsPassableAtPoint(pt.x, 0, pt.z, false, true) then
                local monster = SpawnPrefab("icehound")
                if monster then
                    monster.Transform:SetPosition(pt.x, 0, pt.z)
                    local spawnfx = SpawnPrefab("spawn_fx_small_high")
                    if spawnfx then
                        spawnfx.Transform:SetPosition(pt.x, 0, pt.z)
                    end
                    if worker and monster.components.combat then
                        monster.components.combat:SetTarget(worker)
                    end
                end
                break
            end
        end
    end
end


----[]----[]----[]----[]----[]----[]----[]----[]----[]----[]----[]----[]----[]----[]----
----坟堆被挖没时
local function onfinishcallback(inst, worker)
    SpawnAt("maxwell_smoke", inst)
    SpawnAt("mole_move_fx", inst)
    inst:Remove()


    if not IsHunDengExists() then
        SpawnAt("gw_hundeng", inst)
    end

    local rand = math.random()
    if not IsHaoJiaoExists() then
        if rand <= 0.5 then
                SpawnQianBei(inst)
        elseif rand <= 0.9 then
            local chest = SpawnAt("treasurechest", inst)
            if chest then
                FillTreasureChest(chest)
            end
        else
            local grave = SpawnAt("gw_grave_chest", inst)
            SpawnAt("crabking_ring_fx", inst)
            SpawnAt("icespike_fx_3", inst)
            if grave then
                local yiwu = SpawnPrefab("gwen_haojiao")
                if yiwu then
                    grave.components.container:GiveItem(yiwu)
                end
                SpawnIceHoundAndPenguinPack(inst, worker)
            end
        end
    else
        if math.random() <= 0.3 then
            SpawnMonstersAround(inst, worker)
        end
        if rand <= 0.7 then
            SpawnQianBei(inst)
        else
            local chest = SpawnAt("treasurechest", inst)
            if chest then
                FillTreasureChest(chest)
            end
        end
    end
end


----[]----[]----[]----[]----[]----[]----[]----[]----[]----[]----[]----[]----[]----[]----
----坟堆本体
local function fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddNetwork()

    inst.AnimState:SetBank("gw_grave")
    inst.AnimState:SetBuild("gw_grave")
    inst.AnimState:PlayAnimation("idle")
    inst.Transform:SetScale(2.25, 2.25, 2.25)
    inst.AnimState:SetMultColour(1, 1, 1, 0)

    inst:AddTag("gw_grave")

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst:AddComponent("inspectable")

    inst:AddComponent("workable")
    inst.components.workable:SetWorkAction(ACTIONS.DIG)
    inst.components.workable:SetWorkLeft(7)
    inst.components.workable:SetOnWorkCallback(OnDig)
    inst.components.workable:SetOnFinishCallback(onfinishcallback)

    inst:AddComponent("lootdropper")


    return inst
end


----[]----[]----[]----[]----[]----[]----[]----[]----[]----[]----[]----[]----[]----[]----
----遗物的墓穴
local function chest_fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddNetwork()

    inst.AnimState:SetBank("gravestone")
    inst.AnimState:SetBuild("gravestones")
    inst.AnimState:PlayAnimation("gravedirt")

    inst:AddTag("gw_grave_chest")

    inst.entity:SetPristine()


    if not TheWorld.ismastersim then
        return inst
    end

    inst:AddComponent("inspectable")

    inst:AddComponent("container")
    inst.components.container:WidgetSetup("gw_grave_chest")
    inst.components.container.onopenfn = function ()
        inst.AnimState:PlayAnimation("dug")
    end
    inst.components.container.onclosefn = function ()
        inst.AnimState:PlayAnimation("gravedirt")
    end

    inst:AddComponent("workable")
    inst.components.workable:SetWorkAction(ACTIONS.DIG)
    inst.components.workable:SetWorkLeft(1)
    inst.components.workable:SetOnFinishCallback(OnDiged)


    return inst
end

return Prefab("gw_grave", fn, assets),
    Prefab("gw_grave_chest", chest_fn, assets)