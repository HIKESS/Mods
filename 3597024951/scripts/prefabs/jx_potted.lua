local prefs = {}

local function onhammered(inst)
  local fx = SpawnPrefab("collapse_small")
  fx.Transform:SetPosition(inst.Transform:GetWorldPosition())
  fx:SetMaterial("pot")
  inst.components.lootdropper:DropLoot()
  inst:Remove()
end

local function onbuilt(inst)
  inst.AnimState:PlayAnimation("place")
  inst.AnimState:PushAnimation("idle", false)
  inst.SoundEmitter:PlaySound("dontstarve/common/together/succulent_craft")
end

local function GetDescription(inst)
  local now_time = GetTime()
  local last_time = inst.last_inspect_time
  inst.last_inspect_time = now_time
  local desc_list = 
  {
    STRINGS.CHARACTERS.GENERIC.DESCRIBE.JX_XUNCAT,
    STRINGS.JX_XUNCAT_CHECK,
  }
  if last_time == nil or now_time - last_time > 30 then
    return desc_list[1]
  else
    return desc_list[2]
  end
end

local function MakePotted(name, isflower)
    local assets =
    {
        Asset("ANIM", "anim/"..name..".zip"),
    }

    local function fn()
        local inst = CreateEntity()

        inst.entity:AddTransform()
        inst.entity:AddSoundEmitter()
        inst.entity:AddAnimState()
        inst.entity:AddNetwork()

        inst:SetDeploySmartRadius(0.45)

        inst.AnimState:SetBank(name)
        inst.AnimState:SetBuild(name)
        inst.AnimState:PlayAnimation("idle")

        inst:AddTag("cavedweller")
        if isflower then
          inst:AddTag("flower")
        end

        inst.entity:SetPristine()

        if not TheWorld.ismastersim then
            return inst
        end

        inst:AddComponent("inspectable")
        if name == "jx_xuncat" then
          inst.components.inspectable.descriptionfn = GetDescription
        end

        MakeSmallBurnable(inst)
        MakeSmallPropagator(inst)
        MakeHauntableWork(inst)

        inst:AddComponent("workable")
        inst.components.workable:SetWorkAction(ACTIONS.HAMMER)
        inst.components.workable:SetWorkLeft(1)
        inst.components.workable:SetOnFinishCallback(onhammered)

        inst:AddComponent("lootdropper")

        MakeHauntableWork(inst)

        inst:ListenForEvent("onbuilt", onbuilt)

        return inst
    end

    table.insert(prefs, Prefab(name, fn, assets))
    table.insert(prefs, MakePlacer(name.. "_placer", name, name, "idle"))
end

MakePotted("jx_potted")                  --巴西木
MakePotted("jx_potted_sunflower", true)  --向日葵
MakePotted("jx_potted_cherry", true)     --酢浆草
MakePotted("jx_potted_rose", true)       --白玫瑰
MakePotted("jx_potted_cactus")           --仙人球
MakePotted("jx_potted_anthurium", true)  --红掌
MakePotted("jx_potted_narcissus", true)  --水仙花
MakePotted("jx_potted_snakeplant")       --虎皮兰
MakePotted("jx_xuncat")                  --橘猫
MakePotted("jx_red_rose_potted", true)   --红玫瑰
MakePotted("jx_green_palm")              --绿豆瓣
MakePotted("jx_potted_gardenia", true)   --栀子花
MakePotted("jx_potted_monstera")         --龟背竹
MakePotted("jx_rose_big_potted", true)   --卡罗拉玫瑰白瓷盆栽
MakePotted("jx_perfume_potted", true)    --香水百合盆栽
MakePotted("jx_princess_potted")         --金钻绿公主盆栽
MakePotted("jx_potted_berry")            --欧式浆果盆栽
MakePotted("jx_potted_mexico")           --墨西哥仙人掌盆栽
MakePotted("jx_chlorophytum_comosum_potted", true) --欧式金边吊兰盆栽

return unpack(prefs)
