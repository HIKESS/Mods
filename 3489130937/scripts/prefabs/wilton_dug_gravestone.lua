local assets =
{
    -- 复用官方 gravestones 动画与 dug_gravestone 系列物品图标。
    Asset("ANIM", "anim/gravestones.zip"),
    Asset("INV_IMAGE", "dug_gravestone"),
    Asset("INV_IMAGE", "dug_gravestone2"),
    Asset("INV_IMAGE", "dug_gravestone3"),
    Asset("INV_IMAGE", "dug_gravestone4"),
}

local function SetStoneType(inst, stone_type)
    -- stone_type 对应墓碑外观 1~4，只影响摆放时的世界模型；
    -- 背包图标统一使用 dug_gravestone，避免图标资源分裂。
    inst.random_stone_choice = tostring(stone_type or math.random(4))
    inst.AnimState:PlayAnimation("dug_grave" .. inst.random_stone_choice)
    if not inst:GetSkinBuild() and inst.components.inventoryitem ~= nil then
        inst.components.inventoryitem:ChangeImageName("dug_gravestone")
    end
end

local function SetDugEpitaph(inst, index, setstring)
    -- 记录并同步墓志铭，用于重新放置时还原描述文本。
    if setstring ~= nil then
        inst._epitaph = setstring
        if inst.components.inspectable ~= nil then
            inst.components.inspectable:SetDescription("'" .. setstring .. "'")
        end
    elseif index ~= nil then
        inst._epitaph = index
        if inst.components.inspectable ~= nil and STRINGS ~= nil and STRINGS.EPITAPHS ~= nil then
            inst.components.inspectable:SetDescription(STRINGS.EPITAPHS[index])
        end
    else
        if STRINGS ~= nil and STRINGS.EPITAPHS ~= nil then
            inst._epitaph = math.random(#STRINGS.EPITAPHS)
            if inst.components.inspectable ~= nil then
                inst.components.inspectable:SetDescription(STRINGS.EPITAPHS[inst._epitaph])
            end
        end
    end
end

local function OnDugDeployed(inst, pt, deployer)
    -- 将挖起的墓碑重新安放到地面，生成威尔顿专用复生墓碑。
    -- 若掉落物上记录了原墓碑的皮肤信息，则在重新生成墓碑时一起传入，
    -- 让 wilton_resurrectiongrave 走与原版 gravestone 相同的皮肤应用流程。
    local gravestone = SpawnPrefab("wilton_resurrectiongrave", inst._wilton_skinname, inst._wilton_skin_id)
    if gravestone == nil then
        inst:Remove()
        return
    end

    gravestone.Transform:SetPosition(pt:Get())

    -- 还原墓碑外观：沿用物品上记录的 stone_choice。
    if inst.random_stone_choice ~= nil then
        gravestone.random_stone_choice = tostring(inst.random_stone_choice)
        gravestone.AnimState:PlayAnimation("grave" .. gravestone.random_stone_choice .. "_place")
        gravestone.AnimState:PushAnimation("grave" .. gravestone.random_stone_choice)
    end

    -- 播放安放音效，参考 Wendy 装饰墓碑的放置音效。
    if deployer ~= nil and deployer.SoundEmitter ~= nil then
        deployer.SoundEmitter:PlaySound("meta5/wendy/place_gravestone")
    end

    -- 还原墓志铭：若掉落物记录了 _epitaph，则覆盖新墓碑的描述。
    if inst._epitaph ~= nil and gravestone.components ~= nil and gravestone.components.inspectable ~= nil then
        local epitaph_type = type(inst._epitaph)
        if epitaph_type == "number" and STRINGS ~= nil and STRINGS.EPITAPHS ~= nil then
            gravestone._epitaph_index = inst._epitaph
            gravestone.components.inspectable:SetDescription(STRINGS.EPITAPHS[inst._epitaph])
        elseif epitaph_type == "string" then
            gravestone.setepitaph = inst._epitaph
            gravestone.components.inspectable:SetDescription("'" .. inst._epitaph .. "'")
        end
    end

    -- 坟包逻辑：若 _mound_dug 为 true，则生成已被挖开的坟包并移除可工作组件，
    -- 防止通过反复栽种坟包刷取战利品。
    if gravestone.mound ~= nil and inst._mound_dug == true then
        gravestone.mound.AnimState:PlayAnimation("dug")
        if gravestone.mound.components ~= nil and gravestone.mound.components.workable ~= nil then
            gravestone.mound:RemoveComponent("workable")
        end
    end

    inst:Remove()
end

local function OnDugSave(inst, data)
    -- 保存墓碑外观与墓志铭标记，供读档与再次放置使用。
    data.stone_index = inst.random_stone_choice
    data.mound_dug = inst._mound_dug
    data.epitaph = inst._epitaph
    -- 同步保存从原墓碑继承的皮肤信息，避免存档/读档后丢失皮肤。
    data._wilton_skinname = inst._wilton_skinname
    data._wilton_skin_id = inst._wilton_skin_id
end

local function OnDugLoad(inst, data, newents)
    if data == nil then
        return
    end

    if data.stone_index ~= nil then
        inst.random_stone_choice = tostring(data.stone_index)
        inst.AnimState:PlayAnimation("dug_grave" .. data.stone_index)
        if not inst:GetSkinBuild() and inst.components.inventoryitem ~= nil then
            inst.components.inventoryitem:ChangeImageName("dug_gravestone")
        end
    end

    inst._mound_dug = data.mound_dug

    if data.epitaph ~= nil and inst.components.inspectable ~= nil then
        inst._epitaph = data.epitaph
        local epitaph_type = type(data.epitaph)
        if epitaph_type == "number" and STRINGS ~= nil and STRINGS.EPITAPHS ~= nil then
            inst.components.inspectable:SetDescription(STRINGS.EPITAPHS[data.epitaph])
        elseif epitaph_type == "string" then
            inst.components.inspectable:SetDescription("'" .. data.epitaph .. "'")
        end
    end

    -- 还原存档中记录的皮肤字段，供再次部署时传回 wilton_resurrectiongrave 使用。
    inst._wilton_skinname = data._wilton_skinname
    inst._wilton_skin_id = data._wilton_skin_id
end

local function fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddNetwork()

    MakeInventoryPhysics(inst)

    inst.AnimState:SetBank("gravestone")
    inst.AnimState:SetBuild("gravestones")
    inst.AnimState:Hide("flower")

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    -- 复生墓碑掉落物：只在图鉴中展示为 dug_gravestone 图标。
    inst.scrapbook_anim = "dug_grave1"
    inst.scrapbook_tex = "dug_gravestone"

    -- 默认随机一个外观，但背包图标统一为 dug_gravestone。
    inst.random_stone_choice = tostring(math.random(4))
    inst.SetStoneType = SetStoneType
    inst.SetEpitaph = SetDugEpitaph

    local deployable = inst:AddComponent("deployable")
    deployable.ondeploy = OnDugDeployed

    -- 初始墓志铭：随机选择一条并写入检查描述。
    if STRINGS ~= nil and STRINGS.EPITAPHS ~= nil then
        inst._epitaph = math.random(#STRINGS.EPITAPHS)
        inst:AddComponent("inspectable")
        inst.components.inspectable:SetDescription(STRINGS.EPITAPHS[inst._epitaph])
    else
        inst:AddComponent("inspectable")
    end

    local inventoryitem = inst:AddComponent("inventoryitem")
    inventoryitem:SetSinks(true)

    inst.AnimState:PlayAnimation("dug_grave" .. inst.random_stone_choice)
    inst.components.inventoryitem:ChangeImageName("dug_gravestone")

    inst.OnSave = OnDugSave
    inst.OnLoad = OnDugLoad

    -- 初始情况下视为“已挖开的坟包”，重新安放时不再产出新的坟包战利品。
    inst._mound_dug = true

    return inst
end

return Prefab("wilton_dug_gravestone", fn, assets)
