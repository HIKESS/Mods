local function onsave(inst, data)
    data.animname = inst.animname
    -- 记录是否为威尔顿灵魂出窍专用锚点，供世界重载后做残留清理。
    if inst.wilton_soulanchor then
        data.wilton_soulanchor = true
    end
end

local function onload(inst, data)
    inst.animname = data ~= nil and data.animname or nil
    if inst.animname ~= nil then 
    inst.AnimState:PlayAnimation(inst.animname)
    end    
    -- 从存档恢复灵魂出窍锚点标记，便于重连清理逻辑识别。
    if data ~= nil and data.wilton_soulanchor then
        inst.wilton_soulanchor = true
    end
end

local function fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()
    inst.entity:AddNetwork()

    inst:AddTag("wiltonmod_skeleton")

    inst.nameoverride = "skeleton"

    inst.AnimState:SetBank("skeleton")
    inst.AnimState:SetBuild("skeletons")
    --inst.AnimState:PlayAnimation("idle1")

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst.animname = "idle"..math.random(1, 6)
    inst.AnimState:PlayAnimation(inst.animname)

    inst:AddComponent("inspectable")
    inst.components.inspectable.nameoverride = "skeleton"

    inst.OnSave = onsave
    inst.OnLoad = onload

    return inst
end

return Prefab("wiltonmod_skeleton", fn), 
       MakePlacer("skeleton_placer", "skeleton", "skeletons", "idle1")
