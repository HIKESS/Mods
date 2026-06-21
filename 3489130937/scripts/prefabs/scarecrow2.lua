local PrefabUtil = require "prefabutil"

local assets = {
    Asset("ANIM", "anim/scarecrow2.zip"),
    Asset("ANIM", "anim/swap_scarecrow_face.zip"),
    Asset("ANIM", "anim/shadow_skinchangefx.zip"),
}

local prefabs = {
    "collapse_big",
}

local numfaces = {
    hit = 4,
    scary = 10,
    screaming = 3,
}

local function SetRandomPose(inst)
    inst.poseanim = "pose" .. tostring(math.random(1, 7))
end

local function PlayPose(inst)
    if inst.poseanim ~= nil then
        inst.AnimState:PlayAnimation(inst.poseanim)
    else
        inst.AnimState:PlayAnimation("idle")
    end
end

local function CancelDressup(inst)
    if inst._dressuptask ~= nil then
        inst._dressuptask:Cancel()
        inst._dressuptask = nil
        inst.components.wardrobe:Enable(true)
        inst:RemoveTag("NOCLICK")
    end
end

local function IsDressingUp(inst)
    return inst._dressuptask ~= nil
end

local function ChangeFace(inst, prefix)
    -- 始终使用同一张脸，不再根据前缀或随机数切换，保证稻草人表情固定。
    -- 为了避免调用游戏原版稻草人表情，这里从本模组的 scarecrow2 build 中覆盖 swap_scarecrow_face 符号。
    inst.face = 1
    inst.AnimState:OverrideSymbol("swap_scarecrow_face", "scarecrow2", "swap_scarecrow_face")
end

local function onhammered(inst)
    inst.components.lootdropper:DropLoot()
    local fx = SpawnPrefab("collapse_big")
    fx.Transform:SetPosition(inst.Transform:GetWorldPosition())
    fx:SetMaterial("wood")
    inst:Remove()
end

local function onhit(inst)
    if not (IsDressingUp(inst) or inst:HasTag("burnt")) then
        inst.AnimState:PlayAnimation("hit")
        local nextanim = inst.poseanim or "idle"
        inst.AnimState:PushAnimation(nextanim, false)
        ChangeFace(inst, "hit")
    end
end

local function onbuilt(inst)
    inst.AnimState:PlayAnimation("place")
    -- 仅使用 idle 动画，不再随机选择 poseX 动画，避免摆出各种姿势。
    inst.AnimState:PushAnimation("idle", false)
    inst.SoundEmitter:PlaySound("dontstarve/common/scarecrow_craft")
end

local function onburnt(inst)
    DefaultBurntStructureFn(inst)
    CancelDressup(inst)
    inst:RemoveTag("scarecrow")
    inst.components.playeravatardata:SetData(nil)
end

local function onignite(inst)
    DefaultBurnFn(inst)
    ChangeFace(inst)
end

local function ontransformend(inst)
    inst._dressuptask = nil
    inst.components.wardrobe:Enable(true)
    inst:RemoveTag("NOCLICK")
end

local function ontransform(inst, cb)
    -- 此时皮肤实际已经切换完成，在这里播放一次“完成变身”的FX，
    -- 保证特效与外观变更时机对齐；仅在服务器生成，由网络同步到所有客户端。
    if TheWorld ~= nil and TheWorld.ismastersim then
        local fx = SpawnPrefab("spawn_fx_medium")
        if fx ~= nil and fx.Transform ~= nil and inst.Transform ~= nil then
            fx.Transform:SetPosition(inst.Transform:GetWorldPosition())
        end
    end

    inst._dressuptask = inst:DoTaskInTime(6 * FRAMES, ontransformend)
    if cb ~= nil then
        cb()
    end
end

local function ondressup(inst, cb)
    if not inst:HasTag("burnt") then
        inst.AnimState:PlayAnimation("transform")
        inst.AnimState:PushAnimation("idle", false)
        inst.SoundEmitter:PlaySound("dontstarve/common/together/skin_change")
        CancelDressup(inst)
        inst._dressuptask = inst:DoTaskInTime(44 * FRAMES, ontransform, cb)
        inst.components.wardrobe:Enable(false)
        inst:AddTag("NOCLICK")
    end
end

local function ondressedup(inst, data)
    if not inst:HasTag("burnt") then
        local avatardata = {
            name = data.doer ~= nil and data.doer:GetBasicDisplayName() or nil,
            prefab = data.doer ~= nil and data.doer.prefab or nil,
        }
        if data.skins ~= nil then
            for k, v in pairs(data.skins) do
                avatardata[k .. "_skin"] = v
            end
        end
        inst.components.playeravatardata:SetData(avatardata)
    end
end

local function onsave(inst, data)
    if inst.components.burnable ~= nil and inst.components.burnable:IsBurning() or inst:HasTag("burnt") then
        data.burnt = true
    end
    if inst.poseanim ~= nil then
        data.poseanim = inst.poseanim
    end
    -- 记录是否为可被骨心复活的特殊稻草人（例如由骷髅宠物死亡生成）。
    if inst.wilton_bone_revive then
        data.wilton_bone_revive = true
    end
    -- 记录是否为威尔顿灵魂出窍专用稻草人锚点，供世界重载后做残留清理。
    if inst.wilton_soulanchor then
        data.wilton_soulanchor = true
    end
end

local function onload(inst, data)
    if data ~= nil then
        if data.burnt then
            inst.components.burnable.onburnt(inst)
        else
            local poseanim = data.poseanim

            local avatardata = inst.components.playeravatardata:GetData()
            avatardata = {
                name = avatardata ~= nil and avatardata.name or nil,
                prefab = avatardata ~= nil and avatardata.prefab or nil,
            }
            for k, v in pairs(inst.components.skinner:GetClothing()) do
                avatardata[k .. "_skin"] = v
            end
            inst.components.playeravatardata:SetData(avatardata)

            if poseanim ~= nil then
                -- 旧存档里可能带有 poseanim，这里统一恢复为 idle，避免重新播放 poseX 动画。
                inst.poseanim = nil
                inst.AnimState:PlayAnimation("idle")
            end

            -- 根据存档标记恢复可骨心复活能力和关联掉落表。
            if data.wilton_bone_revive then
                inst.wilton_bone_revive = true
                inst:AddTag("wiltonmod_scarecrow")
                if inst.components.lootdropper ~= nil then
                    inst.components.lootdropper:SetChanceLootTable('skeleton_cg')
                end
            end
            -- 从存档恢复灵魂出窍锚点标记，便于重连清理逻辑识别。
            if data.wilton_soulanchor then
                inst.wilton_soulanchor = true
            end
        end
    end
end

local function fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()
    inst.entity:AddMiniMapEntity()
    inst.entity:AddNetwork()

    inst:SetDeploySmartRadius(0.75)

    MakeObstaclePhysics(inst, 0.4)

    inst:AddTag("structure")
    inst:AddTag("scarecrow")

    inst.MiniMapEntity:SetIcon("scarecrow.png")

    -- 使用自定义的 scarecrow2 动画与贴图，而不是原版 scarecrow，确保场景中看到的就是模组稻草人骨架。
    inst.AnimState:SetBank("scarecrow2")
    inst.AnimState:SetBuild("scarecrow2")
    inst.AnimState:PlayAnimation("idle")

    inst.AnimState:OverrideSymbol("shadow_hands", "shadow_skinchangefx", "shadow_hands")
    inst.AnimState:OverrideSymbol("shadow_ball", "shadow_skinchangefx", "shadow_ball")
    inst.AnimState:OverrideSymbol("splode", "shadow_skinchangefx", "splode")

    MakeSnowCoveredPristine(inst)

    inst:AddComponent("playeravatardata")
    inst.components.playeravatardata:AddNameData(true)
    inst.components.playeravatardata:AddClothingData(false)
    inst.components.playeravatardata:SetAllowEmptyName(true)

    -- 保持稻草人检查名称与 STRINGS.NAMES.SCARECROW2 一致，避免出现 MISSING NAME 提示（需要在客户端与服务端都生效）。
    inst.displaynamefn = function()
        return (STRINGS and STRINGS.NAMES and STRINGS.NAMES.SCARECROW2) or "稻草人"
    end

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst.scrapbook_adddeps = { "canary" }

    inst:AddComponent("inspectable")

    inst:AddComponent("lootdropper")
    inst:AddComponent("workable")
    inst.components.workable:SetWorkAction(ACTIONS.HAMMER)
    inst.components.workable:SetWorkLeft(6)
    inst.components.workable:SetOnFinishCallback(onhammered)
    inst.components.workable:SetOnWorkCallback(onhit)

    inst:AddComponent("wardrobe")
    inst.components.wardrobe:SetCanBeDressed(true)
    inst.components.wardrobe.ondressupfn = ondressup

    MakeMediumBurnable(inst, nil, nil, true)
    inst.components.burnable.onburnt = onburnt
    inst.components.burnable:SetOnIgniteFn(onignite)
    MakeMediumPropagator(inst)

    MakeSnowCovered(inst)
    MakeHauntableWork(inst)

    inst:AddComponent("skinner")
    inst.components.skinner:SetupNonPlayerData()

    inst:ListenForEvent("onbuilt", onbuilt)
    inst:ListenForEvent("dressedup", ondressedup)

    inst.OnEntityWake = ChangeFace

    inst.OnSave = onsave
    inst.OnLoad = onload

    ChangeFace(inst)

    return inst
end

return Prefab("scarecrow2", fn, assets, prefabs),
    -- 这里的 bank/build 也统一改为 scarecrow2，确保建造预览使用模组自带贴图。
    MakePlacer("scarecrow2_placer", "scarecrow2", "scarecrow2", "idle")
