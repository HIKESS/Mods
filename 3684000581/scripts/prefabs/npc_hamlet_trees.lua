-- scripts/prefabs/npc_hamlet_trees.lua
-- Hamlet DLC 4 种树移植到 DST：丛林树 / 雨林树 / 茶树 / 爪棕榈树
-- ────────────────────────────────────────────────────────────
-- 设计：
--   · 走 vanilla DST evergreen.lua 的标准范式（短→中→大 三阶段 growable + workable CHOP
--     + burnable + 砍倒变 stump → 挖掉 stump 出 1 log）
--   · 每种树有「种子/树苗」prefab，可以右键拖到地面种植，延时长成对应的树
--   · 多人 / 服务端友好：完整 AddNetwork + SetPristine + ismastersim 守卫
--   · MakeInventoryFloatable 走 DST 新签名 (size, vert_offset, scale)
--   · loopstages = false（我们只有 3 阶段，没有 "old"，不希望 tall 后又缩回 short）
--   · 各 bank/build 对照 Hamlet 原版 DLC0003/scripts/prefabs/{jungletrees,rainforesttrees,
--     teatrees,clawpalmtrees,jungletreeseed,teatree_nut,clawpalmtree_sapling}.lua 校准过

-- ════════════════════════════════════════════════════════════
--  树/种子配置表
-- ════════════════════════════════════════════════════════════
local TREE_CONFIGS = {
    
    jungletree = {
        
        seed_prefab    = "jungletreeseed",
        seed_bank      = "jungletreeseed",
        seed_build     = "jungletreeseed",
        seed_anim_idle = "idle",            
        seed_anim_planted = "idle_planted", 
        
        seed_inv_atlas = "images/hamlet_inv1.xml",
        seed_inv_image = "jungleTreeSeed",
        seed_cn = "丛林树种子", seed_en = "Jungle Tree Seed",

        
        tree_prefab    = "jungletree",
        tree_bank      = "jungletree",
        tree_build     = "tree_jungle_build",
        tree_anim_zips = { "tree_jungle_short", "tree_jungle_normal", "tree_jungle_tall" },
        tree_cn = "丛林树", tree_en = "Jungle Tree",

        short_loot  = { "log" },
        normal_loot = { "log", "log", "jungletreeseed" },
        tall_loot   = { "log", "log", "log", "jungletreeseed", "jungletreeseed" },
    },

    
    
    
    
    rainforesttree = {
        no_seed        = true,

        tree_prefab    = "rainforesttree",
        tree_bank      = "rainforesttree",
        tree_build     = "tree_rainforest_build",
        tree_anim_zips = { "tree_rainforest_short", "tree_rainforest_normal", "tree_rainforest_tall" },
        tree_cn = "雨林树", tree_en = "Rainforest Tree",

        short_loot  = { "log" },
        normal_loot = { "log", "log" },
        tall_loot   = { "log", "log", "log" },
    },

    
    
    
    
    teatree = {
        seed_prefab    = "teatree_nut",
        seed_bank      = "teatree_nut",
        seed_build     = "teatree_nut",
        seed_anim_idle = "idle",
        seed_anim_planted = "idle_planted",
        seed_edible    = true,
        seed_perishable = true,
        seed_inv_atlas = "images/hamlet_inv1.xml",
        seed_inv_image = "teatree_nut",
        seed_cn = "茶树果", seed_en = "Tea Tree Nut",

        tree_prefab    = "teatree",
        tree_bank      = "tree_leaf",
        tree_build     = "teatree_trunk_build",
        tree_leaves_build = "teatree_build",   
        tree_anim_zips = { "tree_leaf_short", "tree_leaf_normal", "tree_leaf_tall" },
        tree_cn = "茶树", tree_en = "Tea Tree",

        short_loot  = { "log" },
        normal_loot = { "log", "twigs", "teatree_nut" },
        tall_loot   = { "log", "log", "twigs", "teatree_nut", "teatree_nut" },
    },

    
    
    clawpalmtree = {
        seed_prefab    = "clawpalmtree_sapling",
        seed_bank      = "clawling",
        seed_build     = "clawling",
        seed_anim_idle = "idle_planted",     
        seed_anim_planted = "idle_planted",
        seed_inv_atlas = "images/hamlet_inv1.xml",
        seed_inv_image = "clawpalmtree_sapling",
        seed_cn = "爪棕榈树苗", seed_en = "Claw Palm Tree Sapling",

        tree_prefab    = "clawpalmtree",
        tree_bank      = "clawtree",          
        tree_build     = "claw_tree_build",
        tree_anim_zips = { "claw_tree_short", "claw_tree_normal", "claw_tree_tall" },
        tree_cn = "爪棕榈树", tree_en = "Claw Palm Tree",

        short_loot  = { "log" },
        normal_loot = { "log", "log" },
        tall_loot   = { "log", "log", "log" },
    },
}





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


local function makeanims(stage)
    return {
        idle      = "idle_"..stage,
        sway1     = "sway1_loop_"..stage,
        sway2     = "sway2_loop_"..stage,
        chop      = "chop_"..stage,
        fallleft  = "fallleft_"..stage,
        fallright = "fallright_"..stage,
        stump     = "stump_"..stage,
        burning   = "burning_loop_"..stage,
        burnt     = "burnt_"..stage,
        chop_burnt    = "chop_burnt_"..stage,
        idle_chop_burnt = "idle_chop_burnt_"..stage,
    }
end

local SHORT_ANIMS  = makeanims("short")
local NORMAL_ANIMS = makeanims("normal")
local TALL_ANIMS   = makeanims("tall")


local GROW_TIME_FALLBACK = {
    { base = 30,  random = 5  },   
    { base = 80,  random = 20 },   
    { base = 200, random = 50 },   
}

local function GetGrowTime(stage_idx)
    local t = TUNING.EVERGREEN_GROW_TIME and TUNING.EVERGREEN_GROW_TIME[stage_idx]
    if t then return t end
    return GROW_TIME_FALLBACK[stage_idx]
end

local function GetSeedGrowTime()
    return TUNING.ACORN_GROWTIME or { base = 90, random = 30 }
end

local function GetChops(stage_name)
    if stage_name == "short"  then return TUNING.EVERGREEN_CHOPS_SMALL  or 5 end
    if stage_name == "normal" then return TUNING.EVERGREEN_CHOPS_NORMAL or 10 end
    return TUNING.EVERGREEN_CHOPS_TALL or 15
end


local function dig_up_stump(inst)
    inst.components.lootdropper:SpawnLootPrefab("log")
    inst:Remove()
end


local function chop_down_burnt_tree(inst, chopper)
    inst:RemoveComponent("workable")
    inst.SoundEmitter:PlaySound("dontstarve/forest/treeCrumble")
    if not (chopper ~= nil and chopper:HasTag("playerghost")) then
        inst.SoundEmitter:PlaySound("dontstarve/wilson/use_axe_tree")
    end
    if inst.anims and inst.anims.chop_burnt then
        inst.AnimState:PlayAnimation(inst.anims.chop_burnt)
    end
    RemovePhysicsColliders(inst)
    inst:ListenForEvent("animover", inst.Remove)
    inst.components.lootdropper:SpawnLootPrefab("charcoal")
    inst.components.lootdropper:DropLoot()
end





local function MakeSeed(cfg)
    local seed_name = cfg.seed_prefab
    local tree_name = cfg.tree_prefab

    
    local function growtree(inst)
        inst.growtask = nil
        inst.growtime = nil
        local tree = SpawnPrefab(tree_name)
        if tree ~= nil then
            tree.Transform:SetPosition(inst.Transform:GetWorldPosition())
            if tree.growfromseed ~= nil then
                tree:growfromseed()
            end
            inst:Remove()
        end
    end

    local function digup(inst)
        if inst.components.lootdropper ~= nil then
            inst.components.lootdropper:DropLoot()
        end
        inst:Remove()
    end

    
    local function plant(inst, growtime)
        inst:RemoveComponent("inventoryitem")
        RemovePhysicsColliders(inst)

        
        if inst.components.edible     then inst:RemoveComponent("edible")     end
        if inst.components.perishable then inst:RemoveComponent("perishable") end

        inst.AnimState:PlayAnimation(cfg.seed_anim_planted)
        if inst.SoundEmitter then
            inst.SoundEmitter:PlaySound("dontstarve/wilson/plant_tree")
        end

        inst.growtime = GetTime() + growtime

        if not inst.components.lootdropper then
            inst:AddComponent("lootdropper")
        end
        inst.components.lootdropper:SetLoot({ "twigs" })

        if inst.components.workable then inst:RemoveComponent("workable") end
        inst:AddComponent("workable")
        inst.components.workable:SetWorkAction(ACTIONS.DIG)
        inst.components.workable:SetOnFinishCallback(digup)
        inst.components.workable:SetWorkLeft(1)

        inst.growtask = inst:DoTaskInTime(growtime, growtree)
    end

    
    local function ondeploy(inst, pt)
        local seed = inst.components.stackable:Get()
        if seed == nil then return end
        if seed.components.inventoryitem then
            seed.components.inventoryitem:OnRemoved()
        end
        seed.Transform:SetPosition(pt:Get())
        local growtime = GetRandomWithVariance(GetSeedGrowTime().base, GetSeedGrowTime().random)
        plant(seed, growtime)
    end

    local function stop_growing(inst)
        if inst.growtask ~= nil then
            inst.growtask:Cancel()
            inst.growtask = nil
        end
        inst.growtime = nil
    end

    local function restart_growing(inst)
        if inst:IsValid() and inst.growtask == nil and inst.components.inventoryitem == nil then
            local growtime = GetRandomWithVariance(GetSeedGrowTime().base, GetSeedGrowTime().random)
            inst.growtime = GetTime() + growtime
            inst.growtask = inst:DoTaskInTime(growtime, growtree)
        end
    end

    local NOTAGS = { "NOBLOCK", "player", "FX" }
    local MIN_SPACING = 2
    local function test_ground(inst, pt)
        if not TheWorld.Map:IsPassableAtPoint(pt.x, pt.y, pt.z) then return false end
        if TheWorld.Map:IsOceanAtPoint(pt.x, pt.y, pt.z) then return false end
        local tile = TheWorld.Map:GetTileAtPoint(pt.x, pt.y, pt.z)
        if tile == nil
           or tile == GROUND.IMPASSABLE
           or tile == GROUND.ROCKY
           or tile == GROUND.ROAD
           or tile == GROUND.UNDERROCK
           or tile == GROUND.WOODFLOOR
           or tile == GROUND.CARPET
           or tile == GROUND.CHECKER then
            return false
        end
        local ents = TheSim:FindEntities(pt.x, pt.y, pt.z, 4, nil, NOTAGS)
        for _, v in ipairs(ents) do
            if v ~= inst and v:IsValid() and v.entity:IsVisible()
                and v.components.placer == nil and v.parent == nil then
                if distsq(Vector3(v.Transform:GetWorldPosition()), pt) < MIN_SPACING * MIN_SPACING then
                    return false
                end
            end
        end
        return true
    end

    local function getstatus(inst)
        return inst.growtime ~= nil and "PLANTED" or nil
    end

    local function displaynamefn(inst)
        if inst.growtime ~= nil then
            return STRINGS.NAMES[string.upper(seed_name .. "_PLANTED")]
                or STRINGS.NAMES[string.upper(seed_name)]
        end
        return STRINGS.NAMES[string.upper(seed_name)]
    end

    local function onsave(inst, data)
        if inst.growtime ~= nil then
            data.growtime = inst.growtime - GetTime()
        end
    end

    local function onload(inst, data)
        if data and data.growtime then
            
            plant(inst, math.max(0, data.growtime))
        end
    end

    local assets = {
        Asset("ANIM", "anim/" .. cfg.seed_bank .. ".zip"),
    }

    local function fn()
        local inst = CreateEntity()
        inst.entity:AddTransform()
        inst.entity:AddAnimState()
        inst.entity:AddSoundEmitter()
        inst.entity:AddNetwork()

        MakeInventoryPhysics(inst)

        inst.AnimState:SetBank(cfg.seed_bank)
        inst.AnimState:SetBuild(cfg.seed_build)
        inst.AnimState:PlayAnimation(cfg.seed_anim_idle)

        inst:AddTag("plant")
        inst:AddTag("cattoy")

        
        MakeInventoryFloatable(inst, "small", 0.05, 0.7)

        if cfg.seed_perishable then
            inst:AddTag("show_spoilage")
        end

        inst.entity:SetPristine()
        if not TheWorld.ismastersim then
            return inst
        end

        inst:AddComponent("inspectable")
        inst.components.inspectable.getstatus = getstatus

        inst:AddComponent("inventoryitem")
        if cfg.seed_inv_atlas and cfg.seed_inv_image then
            inst.components.inventoryitem.atlasname = cfg.seed_inv_atlas
            inst.components.inventoryitem.imagename = cfg.seed_inv_image
        end
        inst:AddComponent("tradable")
        inst:AddComponent("bait")

        inst:AddComponent("stackable")
        inst.components.stackable.maxsize = TUNING.STACK_SIZE_SMALLITEM

        inst:AddComponent("fuel")
        inst.components.fuel.fuelvalue = TUNING.SMALL_FUEL

        MakeSmallBurnable(inst, TUNING.SMALL_BURNTIME)
        inst:ListenForEvent("onignite",     stop_growing)
        inst:ListenForEvent("onextinguish", restart_growing)
        MakeSmallPropagator(inst)
        if inst.components.burnable.MakeDragonflyBait then
            inst.components.burnable:MakeDragonflyBait(3)
        end

        if cfg.seed_edible then
            inst:AddComponent("edible")
            inst.components.edible.hungervalue = TUNING.CALORIES_TINY
            inst.components.edible.healthvalue = TUNING.HEALING_TINY
            inst.components.edible.foodtype    = FOODTYPE.SEEDS
            inst.components.edible.foodstate   = "RAW"
        end

        if cfg.seed_perishable then
            inst:AddComponent("perishable")
            inst.components.perishable:SetPerishTime(TUNING.PERISH_PRESERVED)
            inst.components.perishable:StartPerishing()
            inst.components.perishable.onperishreplacement = "spoiled_food"
        end

        inst:AddComponent("deployable")
        inst.components.deployable.test     = test_ground
        inst.components.deployable.ondeploy = ondeploy

        inst.displaynamefn = displaynamefn
        inst.OnSave = onsave
        inst.OnLoad = onload

        return inst
    end

    return Prefab(seed_name, fn, assets)
end





local function MakeTree(cfg)
    local tree_name = cfg.tree_prefab

    local function PushSway(inst)
        inst.AnimState:PushAnimation(math.random() > 0.5 and inst.anims.sway1 or inst.anims.sway2, true)
    end

    local function Sway(inst)
        inst.AnimState:PlayAnimation(math.random() > 0.5 and inst.anims.sway1 or inst.anims.sway2, true)
        inst.AnimState:SetTime(math.random() * 2)
    end

    
    local function ApplyLeaves(inst)
        if cfg.tree_leaves_build then
            inst.AnimState:OverrideSymbol("swap_leaves", cfg.tree_leaves_build, "swap_leaves")
        end
    end

    
    local function SetShort(inst)
        inst.anims = SHORT_ANIMS
        if inst.components.workable then
            inst.components.workable:SetWorkLeft(GetChops("short"))
        end
        inst.components.lootdropper:SetLoot(cfg.short_loot)
        inst.Transform:SetScale(0.7, 0.7, 0.7)
        ApplyLeaves(inst)
        Sway(inst)
    end

    local function SetNormal(inst)
        inst.anims = NORMAL_ANIMS
        if inst.components.workable then
            inst.components.workable:SetWorkLeft(GetChops("normal"))
        end
        inst.components.lootdropper:SetLoot(cfg.normal_loot)
        inst.Transform:SetScale(0.85, 0.85, 0.85)
        ApplyLeaves(inst)
        Sway(inst)
    end

    local function SetTall(inst)
        inst.anims = TALL_ANIMS
        if inst.components.workable then
            inst.components.workable:SetWorkLeft(GetChops("tall"))
        end
        inst.components.lootdropper:SetLoot(cfg.tall_loot)
        inst.Transform:SetScale(1.0, 1.0, 1.0)
        ApplyLeaves(inst)
        Sway(inst)
    end

    local function GrowShort(inst)
        inst.AnimState:PlayAnimation("grow_tall_to_short")
        if inst.SoundEmitter then inst.SoundEmitter:PlaySound("dontstarve/forest/treeGrowFromWilt") end
        PushSway(inst)
    end

    local function GrowNormal(inst)
        inst.AnimState:PlayAnimation("grow_short_to_normal")
        if inst.SoundEmitter then inst.SoundEmitter:PlaySound("dontstarve/forest/treeGrow") end
        PushSway(inst)
    end

    local function GrowTall(inst)
        inst.AnimState:PlayAnimation("grow_normal_to_tall")
        if inst.SoundEmitter then inst.SoundEmitter:PlaySound("dontstarve/forest/treeGrow") end
        PushSway(inst)
    end

    local growth_stages = {
        { name = "short",  time = function() local t = GetGrowTime(1) return GetRandomWithVariance(t.base, t.random) end, fn = SetShort,  growfn = GrowShort  },
        { name = "normal", time = function() local t = GetGrowTime(2) return GetRandomWithVariance(t.base, t.random) end, fn = SetNormal, growfn = GrowNormal },
        { name = "tall",   time = function() local t = GetGrowTime(3) return GetRandomWithVariance(t.base, t.random) end, fn = SetTall,   growfn = GrowTall   },
    }

    
    local function chop_tree(inst, chopper)
        if inst.SoundEmitter and not (chopper ~= nil and chopper:HasTag("playerghost")) then
            inst.SoundEmitter:PlaySound("dontstarve/wilson/use_axe_tree")
        end
        inst.AnimState:PlayAnimation(inst.anims.chop)
        inst.AnimState:PushAnimation(inst.anims.sway1, true)
    end

    local function make_stump(inst)
        inst:RemoveComponent("burnable")
        MakeSmallBurnable(inst)
        inst:RemoveComponent("propagator")
        MakeSmallPropagator(inst)
        inst:RemoveComponent("workable")
        inst:RemoveTag("shelter")
        RemovePhysicsColliders(inst)
        inst:AddTag("stump")

        if inst.components.growable then
            inst.components.growable:StopGrowing()
        end

        if inst.MiniMapEntity then
            
            inst.MiniMapEntity:SetIcon("evergreen_stump.png")
        end

        inst:AddComponent("workable")
        inst.components.workable:SetWorkAction(ACTIONS.DIG)
        inst.components.workable:SetOnFinishCallback(dig_up_stump)
        inst.components.workable:SetWorkLeft(1)
    end

    local function chop_down_tree(inst, chopper)
        if inst.SoundEmitter then
            inst.SoundEmitter:PlaySound("dontstarve/forest/treefall")
        end
        local pt = inst:GetPosition()

        
        
        local right_vec
        if TheCamera and TheCamera.GetRightVec then
            right_vec = TheCamera:GetRightVec()
        else
            right_vec = Vector3(1, 0, 0)
        end

        local he_right = true
        if chopper then
            local hispos = chopper:GetPosition()
            he_right = (hispos - pt):Dot(right_vec) > 0
        else
            he_right = math.random() > 0.5
        end

        if he_right then
            inst.AnimState:PlayAnimation(inst.anims.fallleft)
            inst.components.lootdropper:DropLoot(pt - right_vec)
        else
            inst.AnimState:PlayAnimation(inst.anims.fallright)
            inst.components.lootdropper:DropLoot(pt + right_vec)
        end

        make_stump(inst)
        inst.AnimState:PushAnimation(inst.anims.stump, false)

        
        inst:AddTag("NOCLICK")
        inst:DoTaskInTime(2, function(i) if i:IsValid() then i:RemoveTag("NOCLICK") end end)
    end

    
    local function on_burnt(inst)
        if inst.components.burnable then inst.components.burnable:Extinguish() end
        inst:RemoveComponent("burnable")
        inst:RemoveComponent("propagator")
        inst:RemoveComponent("growable")
        inst:RemoveTag("shelter")
        inst:RemoveTag("fire")

        inst.components.lootdropper:SetLoot({})

        if inst.components.workable then
            inst.components.workable:SetWorkLeft(1)
            inst.components.workable:SetOnWorkCallback(nil)
            inst.components.workable:SetOnFinishCallback(chop_down_burnt_tree)
        end

        if inst.anims and inst.anims.burnt then
            inst.AnimState:PlayAnimation(inst.anims.burnt, true)
        end
        inst:AddTag("burnt")
    end

    
    local function inspect_tree(inst)
        if inst:HasTag("burnt") then return "BURNT" end
        if inst:HasTag("stump") then return "CHOPPED" end
    end

    
    local function handler_growfromseed(inst)
        inst.components.growable:SetStage(1)
        inst.AnimState:PlayAnimation("grow_seed_to_short")
        if inst.SoundEmitter then inst.SoundEmitter:PlaySound("dontstarve/forest/treeGrow") end
        PushSway(inst)
    end

    
    local function onsave(inst, data)
        if inst:HasTag("burnt") or
           (inst.components.burnable ~= nil and inst.components.burnable:IsBurning()) then
            data.burnt = true
        end
        if inst:HasTag("stump") then
            data.stump = true
        end
    end

    local function onload(inst, data)
        if data == nil then return end
        if data.burnt then
            on_burnt(inst)
        elseif data.stump then
            make_stump(inst)
            if inst.anims and inst.anims.stump then
                inst.AnimState:PlayAnimation(inst.anims.stump)
            end
        end
    end

    
    local tree_assets = {
        Asset("ANIM", "anim/" .. cfg.tree_build .. ".zip"),
    }
    for _, zip in ipairs(cfg.tree_anim_zips) do
        tree_assets[#tree_assets + 1] = Asset("ANIM", "anim/" .. zip .. ".zip")
    end
    if cfg.tree_leaves_build then
        tree_assets[#tree_assets + 1] = Asset("ANIM", "anim/" .. cfg.tree_leaves_build .. ".zip")
    end

    local function fn()
        local inst = CreateEntity()
        inst.entity:AddTransform()
        inst.entity:AddAnimState()
        inst.entity:AddSoundEmitter()
        inst.entity:AddMiniMapEntity()
        inst.entity:AddNetwork()

        MakeObstaclePhysics(inst, 0.25)

        inst.MiniMapEntity:SetIcon("evergreen.png")  
        inst.MiniMapEntity:SetPriority(-1)

        inst.AnimState:SetBank(cfg.tree_bank)
        inst.AnimState:SetBuild(cfg.tree_build)

        if cfg.tree_leaves_build then
            inst.AnimState:OverrideSymbol("swap_leaves", cfg.tree_leaves_build, "swap_leaves")
        end

        inst:AddTag("plant")
        inst:AddTag("tree")
        inst:AddTag("workable")
        inst:AddTag("shelter")

        inst.entity:SetPristine()

        if not TheWorld.ismastersim then
            return inst
        end

        local color = 0.5 + math.random() * 0.5
        inst.AnimState:SetMultColour(color, color, color, 1)

        MakeLargeBurnable(inst, TUNING.TREE_BURN_TIME)
        inst.components.burnable:SetFXLevel(5)
        inst.components.burnable:SetOnBurntFn(on_burnt)
        if inst.components.burnable.MakeDragonflyBait then
            inst.components.burnable:MakeDragonflyBait(1)
        end
        MakeMediumPropagator(inst)

        inst:AddComponent("inspectable")
        inst.components.inspectable.getstatus = inspect_tree

        inst:AddComponent("workable")
        inst.components.workable:SetWorkAction(ACTIONS.CHOP)
        inst.components.workable:SetOnWorkCallback(chop_tree)
        inst.components.workable:SetOnFinishCallback(chop_down_tree)

        inst:AddComponent("lootdropper")

        inst:AddComponent("growable")
        inst.components.growable.stages = growth_stages
        inst.components.growable:SetStage(1)
        inst.components.growable.loopstages = false   
        inst.components.growable.springgrowth = true
        inst.components.growable:StartGrowing()

        inst.growfromseed = handler_growfromseed

        inst.AnimState:SetTime(math.random() * 2)

        inst.OnSave = onsave
        inst.OnLoad = onload

        return inst
    end

    return Prefab(tree_name, fn, tree_assets)
end





STRINGS.NAMES = STRINGS.NAMES or {}

local ret = {}
for _, cfg in pairs(TREE_CONFIGS) do
    
    STRINGS.NAMES[string.upper(cfg.tree_prefab)] = L(cfg.tree_cn, cfg.tree_en)
    ret[#ret + 1] = MakeTree(cfg)

    
    if not cfg.no_seed and cfg.seed_prefab then
        STRINGS.NAMES[string.upper(cfg.seed_prefab)]              = L(cfg.seed_cn, cfg.seed_en)
        STRINGS.NAMES[string.upper(cfg.seed_prefab) .. "_PLANTED"] = L(cfg.seed_cn .. "（已种下）", cfg.seed_en .. " (Planted)")
        ret[#ret + 1] = MakeSeed(cfg)
    end
end

return unpack(ret)
