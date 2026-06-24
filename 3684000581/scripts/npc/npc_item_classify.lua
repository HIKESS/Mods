-- scripts/npc/npc_item_classify.lua
-- 物品分类判断函数（数据来自 npc_item_config.lua）
-- ────────────────────────────────────────────────────────────
-- 分类优先级（从高到低）：
--   1. NPC 工具          → "tool"   （不参与存储）
--   2. DELETE 白名单      → "delete" （直接删除）
--   3. GROUND 白名单      → "ground" （地面集中堆放）
--   4. CHEST  白名单      → "chest"  （存入箱子，优先于冰箱标签）
--   5. ICEBOX 白名单      → "icebox" （存入冰箱）
--   6. IGNORE 白名单      → "ignore" （显式忽略，拦截标签兜底）
--   7. ICEBOX_TAGS 标签   → "icebox" （标签兜底）
--   8. 其余非工具物品      → "ignore" （无视：不捡不删不管）
--
-- 修改物品分类请编辑 npc_item_config.lua，无需改本文件
-- ────────────────────────────────────────────────────────────

local NPC_TUNING = require("npc_tuning")
local Config     = require("npc/npc_item_config")

local ItemClassify = {}

local DEBUG_BEHAVIOR = NPC_TUNING.DEBUG_BEHAVIOR

-- 从配置文件加载分类表
local DELETE      = Config.DELETE      or {}
local GROUND      = Config.GROUND      or {}
local CHEST       = Config.CHEST       or {}
local ICEBOX      = Config.ICEBOX      or {}
local IGNORE      = Config.IGNORE      or {}
local ICEBOX_TAGS = Config.ICEBOX_TAGS or {}

-- ═══════════════════════════════════════════════════════════
--  分类判断
-- ═══════════════════════════════════════════════════════════

--- 获取物品的分类
--- @param item entity 物品实体
--- @param inst entity NPC 实体（用于工具判定）
--- @return string "tool" | "delete" | "ground" | "icebox" | "chest" | "ignore"
function ItemClassify.GetCategory(item, inst)
    if not item or not item:IsValid() then return "delete" end
    if NPC_TUNING.IsNPCTool(item, inst) then return "tool" end

    local prefab = item.prefab
    if DELETE[prefab] then
        if DEBUG_BEHAVIOR then print("[NPC_DEBUG] GetCategory -", prefab, "=> delete") end
        return "delete"
    end
    if GROUND[prefab] then
        if DEBUG_BEHAVIOR then print("[NPC_DEBUG] GetCategory -", prefab, "=> ground") end
        return "ground"
    end
    if CHEST[prefab]  then
        if DEBUG_BEHAVIOR then print("[NPC_DEBUG] GetCategory -", prefab, "=> chest",
            "backpack=", tostring(item:HasTag("backpack")),
            "container=", tostring(item.components.container ~= nil)) end
        return "chest"
    end
    if ICEBOX[prefab] then
        if DEBUG_BEHAVIOR then print("[NPC_DEBUG] GetCategory -", prefab, "=> icebox") end
        return "icebox"
    end
    if IGNORE[prefab] then
        if DEBUG_BEHAVIOR then print("[NPC_DEBUG] GetCategory -", prefab, "=> ignore (explicit)") end
        return "ignore"
    end

    -- 标签兆底：匹配任意冰箱标签 → icebox
    for _, tag in ipairs(ICEBOX_TAGS) do
        if item:HasTag(tag) then
            if DEBUG_BEHAVIOR then print("[NPC_DEBUG] GetCategory -", prefab, "=> icebox (tag:", tag, ")") end
            return "icebox"
        end
    end

    -- 兆底：无视（不捡不删不管，容器中可被交换腾位）
    if DEBUG_BEHAVIOR then print("[NPC_DEBUG] GetCategory -", prefab, "=> ignore",
        "backpack=", tostring(item:HasTag("backpack")),
        "container=", tostring(item.components.container ~= nil)) end
    return "ignore"
end

-- ═══════════════════════════════════════════════════════════
--  批量分类
-- ═══════════════════════════════════════════════════════════

--- 将背包物品按 4 类分组（倒序收集，方便安全移除）
--- @param inst entity NPC 实体
--- @return table { icebox={}, chest={}, ground={}, delete={} }
function ItemClassify.CategorizeInventory(inst)
    local result = { icebox = {}, chest = {}, ground = {}, delete = {} }
    local inv = inst.components.inventory
    if not inv then return result end

    local log_lines = {}
    for i = inv.maxslots, 1, -1 do
        local item = inv:GetItemInSlot(i)
        if item then
            local cat = ItemClassify.GetCategory(item, inst)
            if result[cat] then
                table.insert(result[cat], item)
            end
            local stack = (item.components.stackable and item.components.stackable:StackSize()) or 1
            table.insert(log_lines, string.format("  [%d] %s x%d → %s", i, item.prefab or "?", stack, cat))
        end
    end

    if DEBUG_BEHAVIOR and #log_lines > 0 then
        print("[NPC_DEBUG] CategorizeInventory - slots:")
        for _, line in ipairs(log_lines) do
            print("[NPC_DEBUG]  ", line)
        end
        print("[NPC_DEBUG]   icebox=", #result.icebox, "chest=", #result.chest,
              "ground=", #result.ground, "delete=", #result.delete)
    end

    return result
end

-- ═══════════════════════════════════════════════════════════
--  便捷函数（向后兼容 + 语义快捷）
-- ═══════════════════════════════════════════════════════════


function ItemClassify.IsIceboxItem(item)
    if not item or not item:IsValid() then return false end
    -- 遵循分类优先级：DELETE > GROUND > CHEST > ICEBOX > ICEBOX_TAGS
    -- 如果物品在更高优先级的表中，即使有冰箱标签也不算冰箱物品
    local prefab = item.prefab
    if DELETE[prefab] or GROUND[prefab] or CHEST[prefab] or IGNORE[prefab] then return false end
    if ICEBOX[prefab] then return true end
    for _, tag in ipairs(ICEBOX_TAGS) do
        if item:HasTag(tag) then return true end
    end
    return false
end

function ItemClassify.IsChestItem(item, inst)
    if not item or not item:IsValid() then return false end
    local cat = ItemClassify.GetCategory(item, inst)
    return cat == "chest"
end


-- ═══════════════════════════════════════════════════════════
--  导出表格引用（允许外部运行时扩展）
-- ═══════════════════════════════════════════════════════════

ItemClassify.DELETE      = DELETE
ItemClassify.GROUND      = GROUND
ItemClassify.CHEST       = CHEST
ItemClassify.ICEBOX      = ICEBOX
ItemClassify.IGNORE      = IGNORE
ItemClassify.ICEBOX_TAGS = ICEBOX_TAGS

return ItemClassify
