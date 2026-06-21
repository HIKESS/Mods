-- 威尔顿 PlayerController Hook：用于在灵魂出窍期间拦截右键为回魂

local function Wilton_PlayerController_PostInit(self)
    -- 只在服务器上处理右键回魂逻辑（客户端只负责发 RPC，不改动）
    if not TheWorld.ismastersim then
        return
    end

    -- 缓存原始 OnRemoteRightClick / OnRightClick
    local _OldOnRemoteRightClick = self.OnRemoteRightClick
    local _OldOnRightClick = self.OnRightClick

    -- 远程客户端右键：由服务器收到 RPC 后走这里
    function self:OnRemoteRightClick(actioncode, position, target, rotation, isreleased, controlmodscode, noforce, mod_name)
        local inst = self.inst
        -- 威尔顿灵魂出窍专用：当玩家是威尔顿幽灵且处于灵魂出窍中时，任何右键都优先触发回魂
        if inst ~= nil
            and inst.prefab == "wiltonmod"
            and inst:HasTag("playerghost")
            and inst.wilton_soul_out_active then
            print("[Wilton][SoulOut][PlayerController] OnRemoteRightClick -> wilton_soul_return")
            inst:PushEvent("wilton_soul_return", { source = inst, from = "OnRemoteRightClick" })
            return
        end

        if _OldOnRemoteRightClick ~= nil then
            return _OldOnRemoteRightClick(self, actioncode, position, target, rotation, isreleased, controlmodscode, noforce, mod_name)
        end
    end

    -- 主机本地玩家右键：直接在 mastersim 上调用 OnRightClick
    function self:OnRightClick(down)
        local inst = self.inst
        -- down 为 true 代表按下时刻；只在按下瞬间拦截
        if down
            and inst ~= nil
            and inst.prefab == "wiltonmod"
            and inst:HasTag("playerghost")
            and inst.wilton_soul_out_active then
            print("[Wilton][SoulOut][PlayerController] OnRightClick -> wilton_soul_return")
            inst:PushEvent("wilton_soul_return", { source = inst, from = "OnRightClick" })
            return
        end

        if _OldOnRightClick ~= nil then
            return _OldOnRightClick(self, down)
        end
    end
end

AddComponentPostInit("playercontroller", Wilton_PlayerController_PostInit)
