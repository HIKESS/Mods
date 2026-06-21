require "prefabutil"

--- 威尔顿专用复生墓碑（wilton_resurrectiongrave）。
-- 设计目标：
-- * 基于原版 gravestone：保留墓碑的随机 4 外观、随机墓志铭、坟包、小鬼生成、装饰花等全部功能；
-- * 额外挂载 attunable + resurrector：行为上等同于官方的 wendy_resurrectiongrave，可作为复活点；
-- * 仅通过威尔顿的配方建造，用于“乱葬岗”技能线。

local assets =
{
    Asset("ANIM", "anim/gravestones.zip"),
    Asset("MINIMAP_IMAGE", "gravestones"),
}

local prefabs =
{
    "mound",
    "smallghost",
    -- 挖起威尔顿复生墓碑后掉落的墓碑物品。
    "wilton_dug_gravestone",
}

-- 坟碑装饰花的生成节奏，沿用原版墓碑配置。
local DECORATED_GRAVESTONE_EVILFLOWER_TIME = (TUNING.WENDYSKILL_GRAVESTONE_DECORATETIME / TUNING.WENDYSKILL_GRAVESTONE_EVILFLOWERCOUNT)

-- Ghosts on a quest (following someone) shouldn't block other ghost spawns!
local CANTHAVE_GHOST_TAGS = { "questing" }
local MUSTHAVE_GHOST_TAGS = { "ghostkid" }

local function on_day_change(inst)
    if #AllPlayers > 0 and (not inst.ghost or not inst.ghost:IsValid()) then
        local ghost_spawn_chance = TUNING.GHOST_GRAVESTONE_CHANCE
        for _, v in ipairs(AllPlayers) do
            if v:HasTag("ghostlyfriend") then
                ghost_spawn_chance = ghost_spawn_chance + TUNING.GHOST_GRAVESTONE_CHANCE

                if v.components.skilltreeupdater and v.components.skilltreeupdater:IsActivated("wendy_smallghost_1") then
                    ghost_spawn_chance = ghost_spawn_chance + TUNING.WENDYSKILL_SMALLGHOST_EXTRACHANCE
                end
            end
        end

        if math.random() < ghost_spawn_chance then
            local gx, gy, gz = inst.Transform:GetWorldPosition()
            local nearby_ghosts = TheSim:FindEntities(gx, gy, gz, TUNING.UNIQUE_SMALLGHOST_DISTANCE, MUSTHAVE_GHOST_TAGS, CANTHAVE_GHOST_TAGS)
            if #nearby_ghosts == 0 then
                inst.ghost = SpawnPrefab("smallghost")
                inst.ghost.Transform:SetPosition(gx + 0.3, gy, gz + 0.3)
                inst.ghost:LinkToHome(inst)
            end
        end
    end
end

local function OnHaunt(inst)
    if not inst.setepitaph and #STRINGS.EPITAPHS > 1 then
        -- 更换墓志铭（前提是没有自定义 epitaph），保证不会重复原文。
        local oldepitaph = inst.components.inspectable.description
        inst._epitaph_index = math.random(#STRINGS.EPITAPHS - 1)
        local newepitaph = STRINGS.EPITAPHS[inst._epitaph_index]
        if newepitaph == oldepitaph then
            newepitaph = STRINGS.EPITAPHS[#STRINGS.EPITAPHS]
        end
        inst.components.inspectable:SetDescription(newepitaph)
        inst.components.hauntable.hauntvalue = TUNING.HAUNT_SMALL
    else
        inst.components.hauntable.hauntvalue = TUNING.HAUNT_TINY
    end
    return true
end

-- 挖出墓碑的回调：播放滑出动画并移除坟包与实体。
local function OnDugUp(inst, tool, worker)
    SpawnPrefab("attune_out_fx").Transform:SetPosition(inst.Transform:GetWorldPosition())

    inst:RemoveComponent("gravediggable")

    -- 挖起时掉落威尔顿专用挖出墓碑物品，复用 dug_gravestone 图标。
    if inst.components.lootdropper ~= nil then
        local loot = inst.components.lootdropper:SpawnLootPrefab("wilton_dug_gravestone")
        if loot ~= nil then
            -- 记录当前墓碑所使用的官方皮肤 ID，作为掉落物的临时字段，方便重新安放时还原同一皮肤。
            loot._wilton_skinname = inst.skinname
            loot._wilton_skin_id = inst.skin_id

            -- 将当前墓碑的外观 index 传递给掉落物，用于重新安放时还原墓碑造型。
            if loot.SetStoneType ~= nil then
                local stone_index = tonumber(inst.random_stone_choice)
                loot:SetStoneType(stone_index)
            else
                loot.random_stone_choice = inst.random_stone_choice
            end

            -- 传递墓志铭：优先保留自定义 epitaph，其次保留随机 epitaph 索引。
            if loot.SetEpitaph ~= nil then
                if inst.setepitaph ~= nil then
                    loot:SetEpitaph(nil, inst.setepitaph)
                elseif inst._epitaph_index ~= nil then
                    loot:SetEpitaph(inst._epitaph_index, nil)
                end
            else
                if inst.setepitaph ~= nil and loot.components ~= nil and loot.components.inspectable ~= nil then
                    loot._epitaph = inst.setepitaph
                    loot.components.inspectable:SetDescription("'" .. inst.setepitaph .. "'")
                elseif inst._epitaph_index ~= nil and loot.components ~= nil and loot.components.inspectable ~= nil and STRINGS ~= nil and STRINGS.EPITAPHS ~= nil then
                    loot._epitaph = inst._epitaph_index
                    loot.components.inspectable:SetDescription(STRINGS.EPITAPHS[inst._epitaph_index])
                end
            end

            -- 坟包标记：视为已被挖掘，重新安放时直接生成“已挖开”的坟包，避免重复刷取战利品。
            loot._mound_dug = true
        end
    end

    inst.AnimState:PlayAnimation("grave" .. inst.random_stone_choice .. "_slide")

    local animlength = inst.AnimState:GetCurrentAnimationLength()

    inst.persists = false
    inst:DoTaskInTime(animlength, inst.Remove)

    if inst.mound ~= nil then
        ErodeAway(inst.mound, animlength)
    end

    return true
end

-- 使用普通 DIG 动作（铲子）挖掘时的回调：
-- 将 workable 的完成事件转发到 gravediggable:DigUp，统一从 OnDugUp 流程处理逻辑。
local function OnDugWorkFinished(inst, worker)
    if inst.components.gravediggable ~= nil then
        local tool
        if worker ~= nil and worker.components ~= nil and worker.components.inventory ~= nil then
            tool = worker.components.inventory:GetEquippedItem(EQUIPSLOTS.HANDS)
        end
        inst.components.gravediggable:DigUp(tool, worker)
    end
end

-- Upgrade (decorate)
local FLOWER_TAG = { "flower" }
local FLOWER_SPAWN_RADIUS = 1.5
local function try_evil_flower(inst)
    if TheWorld.state.iswinter then return end

    local ix, iy, iz = inst.Transform:GetWorldPosition()
    if TheSim:CountEntities(ix, iy, iz, 2 * FLOWER_SPAWN_RADIUS, FLOWER_TAG) < TUNING.WENDYSKILL_GRAVESTONE_EVILFLOWERCOUNT then
        local random_angle = PI2 * math.random()
        ix = ix + (FLOWER_SPAWN_RADIUS * math.cos(random_angle))
        iz = iz - (FLOWER_SPAWN_RADIUS * math.sin(random_angle))

        local evil_flower = SpawnPrefab("flower_evil")
        evil_flower.Transform:SetPosition(ix, iy, iz)
        SpawnPrefab("attune_out_fx").Transform:SetPosition(ix, iy, iz)
    end
end

local function initiate_flower_state(inst)
    inst.AnimState:Show("flower")

    -- onload 时计时器可能已经由存档还原，这里只在不存在时重新启动。
    if not inst.components.timer:TimerExists("petal_decay") then
        inst.components.timer:StartTimer("petal_decay", TUNING.PERISH_FAST)
    end

    if not inst.components.timer:TimerExists("try_evil_flower") then
        inst.components.timer:StartTimer(
            "try_evil_flower", DECORATED_GRAVESTONE_EVILFLOWER_TIME * (1 + 0.5 * math.random())
        )
    end

    if TheWorld.components.decoratedgrave_ghostmanager ~= nil then
        TheWorld.components.decoratedgrave_ghostmanager:RegisterDecoratedGrave(inst)
    end
end

local function OnDecorated(inst)
    local ix, iy, iz = inst.Transform:GetWorldPosition()
    SpawnPrefab("attune_out_fx").Transform:SetPosition(ix, iy, iz)

    initiate_flower_state(inst)
end

local function OnPetalAdded(inst)
    local ix, iy, iz = inst.Transform:GetWorldPosition()
    SpawnPrefab("ghostflower_spirit1_fx").Transform:SetPosition(ix, iy, iz)
end

-- Timer
local function OnTimerDone(inst, data)
    if data.name == "petal_decay" then
        inst.AnimState:Hide("flower")
        inst.components.upgradeable:SetStage(1)
        inst.components.timer:StopTimer("try_evil_flower")
    elseif data.name == "try_evil_flower" then
        try_evil_flower(inst)
        inst.components.timer:StartTimer(
            "try_evil_flower", DECORATED_GRAVESTONE_EVILFLOWER_TIME * (1 + 0.5 * math.random())
        )
    end
end

-- Save/Load
local function onload(inst, data, newents)
    if data then
        if inst.mound and data.mounddata then
            if newents and data.mounddata.id then
                newents[data.mounddata.id] = { entity = inst.mound, data = data.mounddata }
            end
            inst.mound:SetPersistData(data.mounddata.data, newents)
        end

        if data.stone_index then
            if not inst:GetSkinBuild() then
                inst.AnimState:PlayAnimation("grave" .. data.stone_index)
            end
            inst.random_stone_choice = tostring(data.stone_index)
        end

        if data.setepitaph then
            -- 处理在地编中设置的自定义墓志铭。
            inst.components.inspectable:SetDescription("'" .. data.setepitaph .. "'")
            inst.setepitaph = data.setepitaph
        elseif data.epitaph_index then
            inst._epitaph_index = data.epitaph_index
            inst.components.inspectable:SetDescription(STRINGS.EPITAPHS[inst._epitaph_index])
        end

        if inst.components.upgradeable.stage > 1 then
            initiate_flower_state(inst)
        end
    end
end

local function onsave(inst, data)
    if inst.mound then
        data.mounddata = inst.mound:GetSaveRecord()
    end
    data.setepitaph = inst.setepitaph
    data.epitaph_index = (data.setepitaph == nil and inst._epitaph_index) or nil
    data.stone_index = inst.random_stone_choice

    local ents = {}
    if inst.ghost ~= nil and inst.ghost.persists then
        data.ghost_id = inst.ghost.GUID
        table.insert(ents, data.ghost_id)
    end

    return ents
end

local function onloadpostpass(inst, newents, savedata)
    inst.ghost = nil
    if savedata and savedata.ghost_id and newents[savedata.ghost_id] then
        inst.ghost = newents[savedata.ghost_id].entity
        inst.ghost:LinkToHome(inst)
    end
end

local GRAVESTONE_SCRAPBOOK_HIDE = { "flower" }

-- 与原版墓碑相同的坟包偏移。
local MOUND_POSITION_OFFSET = { 0.35355339059327, 0, 0.35355339059327 }

--------------------------------------------------------------------------
-- 复生相关逻辑（已移除）：仿照 wendy_resurrectiongrave，但适配墓碑动画。
--------------------------------------------------------------------------

-- 早期版本中，该墓碑曾经挂载 attunable + resurrector，用于非威尔顿角色的复活。
-- 现在根据设计需求，wilton_resurrectiongrave 仅作为“可检查的装饰墓碑”存在，
-- 不再提供任何附身/连接/复活能力，避免与原版及其他 MOD 的复活体系产生耦合。
--
-- 这里仅保留一个简化的建造回调，用于播放放置动画与音效，使手感与原版墓碑一致。
local function onbuilt(inst, data)
    if data == nil or data.builder == nil then
        return
    end

    local stone = inst.random_stone_choice or "1"

    -- 若建造时选择了官方墓碑皮肤（gravestone_*），根据皮肤名尾号锁定墓碑造型，保持与 gravestone_init_fn 的行为一致。
    if inst.skinname ~= nil then
        local skin_build = inst:GetSkinBuild()
        if skin_build ~= nil then
            local num = tonumber(skin_build:sub(-1)) or tonumber(stone) or 1
            stone = tostring(num)
            inst.random_stone_choice = stone
        end
    end

    inst.AnimState:PlayAnimation("grave" .. stone .. "_place")
    inst.AnimState:PushAnimation("grave" .. stone)

    if inst.SoundEmitter ~= nil then
        inst.SoundEmitter:PlaySound("meta5/wendy/tombstone_place")
    end
end

--------------------------------------------------------------------------
-- 实例构造：在原版墓碑基础上叠加装饰功能。
--------------------------------------------------------------------------

local function fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddMiniMapEntity()
    inst.entity:AddNetwork()
    inst.entity:AddSoundEmitter()
    inst.entity:AddLight()

    inst.MiniMapEntity:SetIcon("gravestones.png")

    inst:AddTag("grave")
    inst:AddTag("gravediggable")
    inst:AddTag("structure")

    inst.AnimState:SetBank("gravestone")
    inst.AnimState:SetBuild("gravestones")
    inst.AnimState:Hide("flower")

    inst.Light:SetIntensity(0)
    inst.Light:SetRadius(0)
    inst.Light:SetFalloff(0)
    inst.Light:SetColour(0.01, 0.35, 1)

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst.scrapbook_anim = "grave1"
    inst.scrapbook_hide = GRAVESTONE_SCRAPBOOK_HIDE

    -- 随机 4 种墓碑外观。
    inst.random_stone_choice = tostring(math.random(4))
    inst.AnimState:PlayAnimation("grave" .. inst.random_stone_choice)

    -- 随机墓志铭，并写入检查描述。
    inst._epitaph_index = math.random(#STRINGS.EPITAPHS)

    inst.mound = inst:SpawnChild("mound")
    inst.mound.ghost_of_a_chance = 0.0
    inst.mound.Transform:SetPosition(unpack(MOUND_POSITION_OFFSET))

    local gravediggable = inst:AddComponent("gravediggable")
    gravediggable.ondug = OnDugUp

    -- 允许使用普通铲子（DIG 动作）挖起威尔顿复生墓碑。
    -- 挖掘完成时转发到 OnDugUp，复用统一的掉落与动画逻辑。
    local workable = inst:AddComponent("workable")
    workable:SetWorkAction(ACTIONS.DIG)
    workable:SetWorkLeft(1)
    workable:SetOnFinishCallback(OnDugWorkFinished)

    local hauntable = inst:AddComponent("hauntable")
    hauntable:SetOnHauntFn(OnHaunt)

    local inspectable = inst:AddComponent("inspectable")
    inspectable:SetDescription(STRINGS.EPITAPHS[inst._epitaph_index])

    inst:AddComponent("timer")

    local upgradeable = inst:AddComponent("upgradeable")
    upgradeable.numstages = 2
    upgradeable.upgradesperstage = TUNING.WENDYSKILL_GRAVESTONE_DECORATECOUNT
    upgradeable.upgradetype = UPGRADETYPES.GRAVESTONE
    upgradeable.onstageadvancefn = OnDecorated
    upgradeable:SetOnUpgradeFn(OnPetalAdded)

    inst:ListenForEvent("timerdone", OnTimerDone)

    inst:WatchWorldState("cycles", on_day_change)

    inst.OnLoad = onload
    inst.OnSave = onsave
    inst.OnLoadPostPass = onloadpostpass

    -- 原本这里会挂载 attunable 组件并作为复活点使用，
    -- 现已按设计移除，仅保留 fader/named 以便后续若需要做纯视觉效果时复用。
    inst:AddComponent("fader")
    inst:AddComponent("named")

    inst:AddComponent("lootdropper")

    inst:ListenForEvent("onbuilt", onbuilt)

    return inst
end

-- 建造预览，只需要隐藏花朵图层以贴合实体外观。
local function placer_postinit(inst)
    inst.AnimState:Hide("flower")
end

return Prefab("wilton_resurrectiongrave", fn, assets, prefabs),
    MakePlacer(
        "wilton_resurrectiongrave_placer", "gravestone", "gravestones", "grave1",
        nil, nil, nil, nil, nil, nil, placer_postinit
    )
