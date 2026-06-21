--- 威尔顿动作 Hook 脚本。
-- 通过 AddComponentAction / AddAction / AddStategraphActionHandler 扩展或限制动作系统：
-- * 为威尔顿开放额外交互（喝山羊奶、土堆睡觉、徒手挖坟、拾取骷髅宠物等）
-- * 自定义 RUMMAGE_WILTON / PICK_WILTON_PET 动作
-- * 限制非威尔顿在坟墓睡觉，并调整部分交互优先级
local function HasSkill(inst, name)
    -- 统一的技能判定：优先使用服务端 components.skilltreeupdater，其次使用客户端 replica.skilltreeupdater
    if inst == nil or name == nil then
        return false
    end

    if inst.components ~= nil and inst.components.skilltreeupdater ~= nil then
        return inst.components.skilltreeupdater:IsActivated(name)
    end

    if inst.replica ~= nil and inst.replica.skilltreeupdater ~= nil then
        return inst.replica.skilltreeupdater:IsActivated(name)
    end

    return false
end

-- 允许威尔顿把山羊奶(goatmilk)视作可食用物，给其添加 EAT 动作。
AddComponentAction("INVENTORY", "edible", function(inst, doer, actions, right)
    -- 当玩家拥有“wiltonmod”标签且物品为山羊奶时，添加 EAT 动作
    if doer:HasTag("wiltonmod") and inst.prefab == "goatmilk" then
        table.insert(actions, ACTIONS.EAT)
    end    
end)

-- 允许威尔顿对“坟墓(mound)”使用睡袋交互，进入自定义睡眠逻辑。
AddComponentAction("SCENE", "sleepingbag", function(inst, doer, actions, right)
    -- 当玩家拥有“wiltonmod”标签且目标为坟墓且没有睡眠标签且没有挖掘标签时，添加 SLEEPIN 动作
    if doer:HasTag("wiltonmod") and inst.prefab == "mound" and not inst:HasTag("hassleeper")
    and not inst:HasTag(ACTIONS.DIG.id.."_workable") then
        table.insert(actions, ACTIONS.SLEEPIN)
    end    
end) 

-- 解锁威尔顿“掘墓者”技能后，允许对坟墓直接使用 DIG 行为（徒手挖坟）。
AddComponentAction("SCENE", "workable", function(inst, doer, actions, right)
    -- 当玩家拥有“wiltonmod”标签且拥有“掘墓者”技能且目标为坟墓且有挖掘标签时，添加 DIG 动作
    if doer:HasTag("wiltonmod") and HasSkill(doer, "wiltonmod_skill2_1") and inst.prefab == "mound"
    and inst:HasTag(ACTIONS.DIG.id.."_workable") then
        table.insert(actions, ACTIONS.DIG)
    end    
end) 

-- 当目标是骷髅宠物时，为威尔顿添加 PICK_WILTON_PET 动作（拾起随从）。
AddComponentAction("SCENE", "combat", function(inst, doer, actions, right)
    -- 当目标为骷髅宠物且玩家拥有“wiltonmod”标签且右键点击时，添加 PICK_WILTON_PET 动作
    if inst.prefab == "wiltonmod_pet" and doer:HasTag("wiltonmod") and right then  
        table.insert(actions, ACTIONS.PICK_WILTON_PET)
    end    
end) 

-- 为威尔顿添加“灵魂出窍”右键自身动作：
-- 仅当
--  * 施法者是威尔顿本体
--  * 目标就是自己
--  * 已解锁正式技能节点 wiltonmod_skill2_18（通过巫术锁节点解锁）
--  * 当前不是幽灵/骷髅
-- 且 right 为 true 时，才在动作列表末尾插入自定义动作，避免抢占工具/武器的右键优先级.
AddComponentAction("SCENE", "inspectable", function(inst, doer, actions, right)
    -- 入口日志：用于确认客户端是否有调用到本 AddComponentAction
    print("[Wilton][SoulOut][AddComponentAction] SCENE inspectable called right=", right,
        " inst=", inst, " doer=", doer,
        " ismastersim=", TheWorld and TheWorld.ismastersim)

    if not right then
        -- 非右键调用时直接返回，避免噪音
        return
    end

    if doer == nil then
        print("[Wilton][SoulOut][AddComponentAction] doer is nil, skip")
        return
    end

    if inst ~= doer then
        -- 只关心“鼠标目标就是自己”的情况，其它目标直接返回
        return
    end

    if doer.prefab ~= "wiltonmod" then
        print("[Wilton][SoulOut][AddComponentAction] doer.prefab~=wiltonmod, prefab=", doer.prefab)
        return
    end

    if doer:HasTag("is_skel") then
        print("[Wilton][SoulOut][AddComponentAction] doer has tag is_skel, skip")
        return
    end

    local hasskill = HasSkill(doer, "wiltonmod_skill2_18")

    print("[Wilton][SoulOut][AddComponentAction] HasSkill(SoulOut)=", hasskill)

    if not hasskill then
        print("[Wilton][SoulOut][AddComponentAction] soulout skill not activated, do not add action")
        return
    end

    if ACTIONS.WILTON_SOUL_OUT == nil then
        print("[Wilton][SoulOut][AddComponentAction] ACTIONS.WILTON_SOUL_OUT is nil, cannot insert action")
        return
    end

    print("[Wilton][SoulOut][AddComponentAction] insert ACTIONS.WILTON_SOUL_OUT into actions")
    table.insert(actions, ACTIONS.WILTON_SOUL_OUT)
end)

-- 允许威尔顿对幽灵玩家使用骨心(wiltonmod_boneheart)，以 GIVETOPLAYER 动作触发复活逻辑。
AddComponentAction("USEITEM", "inventoryitem", function(inst, doer, target, actions, right)
    -- 当玩家拥有“wiltonmod”标签且目标为幽灵玩家且物品为骨心时，添加 GIVETOPLAYER 动作
    if doer:HasTag("wiltonmod") and target:HasTag("playerghost")
    and inst ~= nil and inst:HasTag("wiltonmod_boneheart") then 
        table.insert(actions, ACTIONS.GIVETOPLAYER)
    end    
end) 

-- 自定义“翻找(RUMMAGE_WILTON)”动作，用于威尔顿专属背包在身上时也能打开。
local RUMMAGE_WILTON = Action({priority = 20 , mount_valid = false})
      RUMMAGE_WILTON.id = "RUMMAGE_WILTON"    
      RUMMAGE_WILTON.strfn = ACTIONS.RUMMAGE.strfn  
      RUMMAGE_WILTON.fn = ACTIONS.RUMMAGE.fn
AddAction(RUMMAGE_WILTON)
-- 威尔顿手持或身上有带 wiltonmod_equippable 组件且是“死人宝箱”时，添加专属翻找动作。
AddComponentAction("INVENTORY", "wiltonmod_equippable", function(inst, doer, actions)
    -- 当玩家拥有“wiltonmod”标签且物品为“死人宝箱”且没有骑乘标签时，添加 RUMMAGE_WILTON 动作
    if doer:HasTag("wiltonmod") and not (doer.replica.rider ~= nil and doer.replica.rider:IsRiding())
    and inst.prefab == "wiltonmod_pack" then --and inst.replica.container:CanBeOpened() and right then
        table.insert(actions, ACTIONS.RUMMAGE_WILTON)
    end    
end) 

-- 绑定到 wilson / wilson_client 状态机，复用通用的 doshortaction 动画。
AddStategraphActionHandler("wilson", ActionHandler(ACTIONS.RUMMAGE_WILTON, "doshortaction"))
AddStategraphActionHandler("wilson_client", ActionHandler(ACTIONS.RUMMAGE_WILTON, "doshortaction"))

STRINGS.ACTIONS.RUMMAGE_WILTON = STRINGS.ACTIONS.RUMMAGE

-- 自定义“拾取骷髅宠物(PICK_WILTON_PET)”动作：
-- 用于把正在场上的骷髅宠物收回背包，方便携带与转移。
local PICK_WILTON_PET = Action({priority = 5, mount_valid = false})
      PICK_WILTON_PET.id = "PICK_WILTON_PET" 
      PICK_WILTON_PET.str = STRINGS.ACTIONS.PICK_WILTON_PET or STRINGS.ACTIONS.PICKUP
      PICK_WILTON_PET.fn = function(act)
      -- 当玩家和目标都存在时，停止目标跟随并将其添加到玩家背包
      if act.doer and act.target then -- and act.target.components.follower.leader then
      --and act.target.components.follower.leader == act.doer then 
          if act.target.components.combat.target then
              act.target.components.combat:DropTarget()
          end 

          act.target:StopFollow()
          act.doer.components.inventory:GiveItem(act.target)
      end     
end

AddAction(PICK_WILTON_PET)
AddStategraphActionHandler("wilson", ActionHandler(ACTIONS.PICK_WILTON_PET, "doshortaction"))
AddStategraphActionHandler("wilson_client", ActionHandler(ACTIONS.PICK_WILTON_PET, "doshortaction"))

-- 自定义“灵魂出窍”动作：右键自身触发，切换为官方幽灵形态或从灵魂状态返回。
-- 实际逻辑在 wiltonmod prefab 中实现，这里只负责把动作转换成事件调用。
local WILTON_SOUL_OUT = Action({ priority = 1, mount_valid = false })
WILTON_SOUL_OUT.id = "WILTON_SOUL_OUT"
WILTON_SOUL_OUT.str = STRINGS.ACTIONS.WILTON_SOUL_OUT or "灵魂出窍"
WILTON_SOUL_OUT.fn = function(act)
    local doer = act.doer
    print("[Wilton][SoulOut][ActionFn] called, doer=", doer, " prefab=", doer and doer.prefab,
        " ismastersim=", TheWorld and TheWorld.ismastersim,
        " playerghost=", doer and doer:HasTag("playerghost"),
        " is_skel=", doer and doer:HasTag("is_skel"))
    if doer ~= nil and doer.prefab == "wiltonmod" then
        -- 在这里做一次统一的“忙碌状态”保护，避免在复杂动作中途强行切换生死形态。
        if doer.sg ~= nil and doer.sg:HasStateTag("busy") then
            print("[Wilton][SoulOut][ActionFn] doer is busy, cancel")
            return false
        end

        -- 兼容旧存档 / 旧版本：
        -- 当威尔顿已经是幽灵时，直接推送回魂事件，不依赖任何 SG "doshortaction" 的后续动画，
        -- 这样即使旧存档中还有残留的 ActionHandler 指向 doshortaction，也不会在 ghost bank 上继续播放 pickup/pickup_pst。
        if doer:HasTag("playerghost") then
            print("[Wilton][SoulOut][ActionFn] doer is ghost, push wilton_soul_return (safe path)")
            doer:PushEvent("wilton_soul_return", { source = act.invobject or doer })
            return true
        end

        -- 活人状态下才允许进入灵魂出窍流程，并且只在服务端组件完整时触发，
        -- 避免在尚未完整初始化的旧存档里出现 nil 访问。
        if not doer:HasTag("is_skel")
            and doer.components ~= nil
            and doer.components.health ~= nil
            and not doer.components.health:IsDead() then
            print("[Wilton][SoulOut][ActionFn] push wilton_soul_out event")
            doer:PushEvent("wilton_soul_out", { source = act.invobject or doer })
            return true
        end
    end
    print("[Wilton][SoulOut][ActionFn] failed, return false")
    return false
end

AddAction(WILTON_SOUL_OUT)

-- 兼容性说明：
-- * 人形状态下仍然复用通用的 "doshortaction"，保持与原版短动作体验一致；
-- * 幽灵状态下不再绑定到 "doshortaction"，而是完全依赖 PlayerController / RPC 触发的
--   "wilton_soul_return" 事件来回魂，避免在 ghost bank 上继续播放 pickup/pickup_pst 之类的人形动画。
AddStategraphActionHandler("wilson", ActionHandler(ACTIONS.WILTON_SOUL_OUT, "doshortaction"))
AddStategraphActionHandler("wilson_client", ActionHandler(ACTIONS.WILTON_SOUL_OUT, "doshortaction"))

-- 删除对 wilsonghost / wilsonghost_client 的 doshortaction 绑定，
-- 旧世界中如果已经加载过旧版本的绑定，由于 ActionFn 中对 playerghost 分支进行了安全处理，
-- 也不会再在幽灵 SG 的短动作动画序列中强行切换 bank 导致 pickup_pst 报错。

-- 提升 HEAL 行为的优先级，使其在部分情况下优先于施肥等动作。
ACTIONS.HEAL.priority = ACTIONS.FERTILIZE.priority + 1

-- 覆写 INTERACT_WITH：
-- 对威尔顿直接返回 false，避免与自定义交互产生冲突。
local Old_Interact_withFn = ACTIONS.INTERACT_WITH.fn
ACTIONS.INTERACT_WITH.fn = function(act)
    -- 当玩家拥有“wiltonmod”标签时，直接返回 false
    if act.doer:HasTag("wiltonmod") then
        return false
    end
    return Old_Interact_withFn(act)
end
--[[ ... ]]

-- 禁止非威尔顿在坟墓(mound)睡觉：
-- 通过拦截 locomotor 的 PushAction / PreviewAction，过滤掉针对坟墓的 SLEEPIN 行为.
AddComponentPostInit("locomotor", function(self)
    -- 保存原始 PushAction 和 PreviewAction
    local _OldPushAction = self.PushAction
    local _OldPreviewAction = self.PreviewAction

    -- 覆写 PushAction
    function self:PushAction(bufferedaction, run, try_instant, ...)
        -- 当玩家没有“wiltonmod”标签且目标为坟墓且行为为 SLEEPIN 时，直接返回
        if not self.inst:HasTag("wiltonmod") and bufferedaction and bufferedaction.target and bufferedaction.target.prefab == "mound"
        and bufferedaction.action and bufferedaction.action == ACTIONS.SLEEPIN then
            if self.inst.components.talker then
                local msg = (STRINGS.WILTONMOD_MESSAGES and STRINGS.WILTONMOD_MESSAGES.DENY_SLEEP) or "绝对不行！！"
                self.inst.components.talker:Say(msg)
            end
            return
        else 
            -- 否则调用原始 PushAction
            return _OldPushAction(self, bufferedaction, run, try_instant, ...)            
        end
    end

    -- 覆写 PreviewAction
    function self:PreviewAction(bufferedaction, run, try_instant, ...)
        -- 当玩家没有“wiltonmod”标签且目标为坟墓且行为为 SLEEPIN 时，直接返回
        if not self.inst:HasTag("wiltonmod") and bufferedaction and bufferedaction.target and bufferedaction.target.prefab == "mound"
        and bufferedaction.action and bufferedaction.action == ACTIONS.SLEEPIN then
            return
        else
            -- 否则调用原始 PreviewAction
            return _OldPreviewAction(self, bufferedaction, run, try_instant, ...)  
        end  
    end
end)