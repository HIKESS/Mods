local prefabs =
{
    "gridplacer",
}

local function make_turf(tile, data)
    local function ondeploy(inst, pt, deployer)
        if deployer ~= nil and deployer.SoundEmitter ~= nil then
            deployer.SoundEmitter:PlaySound("dontstarve/wilson/dig")
        end
        local map = TheWorld.Map
        local x, y = map:GetTileCoordsAtPoint(pt:Get())
        map:SetTile(x, y, tile)
        inst.components.stackable:Get():Remove()
    end

    local function fn()
        local inst = CreateEntity()

        inst.entity:AddTransform()
        inst.entity:AddAnimState()
        inst.entity:AddNetwork()

        inst.scrapbook_deps = {}

        MakeInventoryPhysics(inst)

        inst.pickupsound = data.pickupsound or nil

        inst.AnimState:SetBank(data.bank_override or data.bank_build)
        inst.AnimState:SetBuild(data.build_override or data.bank_build)
        inst.AnimState:PlayAnimation(data.anim)
        inst.scrapbook_anim = data.anim

        inst.tile = tile

        inst:AddTag("groundtile")
        inst:AddTag("molebait")

        MakeInventoryFloatable(inst, "med", nil, 0.65)

        inst.scrapbook_specialinfo = "TURF"

        inst.entity:SetPristine()

        if not TheWorld.ismastersim then
            return inst
        end

        inst:AddComponent("stackable")
        inst.components.stackable.maxsize = TUNING.STACK_SIZE_MEDITEM

        inst:AddComponent("inspectable")
        inst:AddComponent("inventoryitem")

        inst:AddComponent("bait")

        inst:AddComponent("fuel")
        inst.components.fuel.fuelvalue = TUNING.TINY_FUEL
        MakeMediumBurnable(inst, TUNING.MED_BURNTIME)
        MakeSmallPropagator(inst)
        MakeHauntableLaunchAndIgnite(inst)

        inst:AddComponent("deployable")
        inst.components.deployable:SetDeployMode(DEPLOYMODE.TURF)
        inst.components.deployable.ondeploy = ondeploy
        inst.components.deployable:SetUseGridPlacer(true)

        ---------------------
        return inst
    end

    local assets =
    {
        Asset("ANIM", "anim/"..(data.animzip_override or data.bank_build)..".zip"),
    }
    return Prefab("turf_"..data.name, fn, assets, prefabs)
end

local ret = {}

local Turf_defs = {
    [WORLD_TILES.GRANITE] = {
        name = "granite",
        pickupsound = "cloth",
        anim = "jx_turf_granite",
        bank_build = "jx_turfs",
    },
    [WORLD_TILES.REDDISH_BROWN] = {
        name = "reddish_brown",
        pickupsound = "cloth",
        anim = "jx_turf_reddish_brown",
        bank_build = "jx_turfs",
    },
    [WORLD_TILES.CORRIDOR] = {
        name = "corridor",
        anim = "jx_turf_corridor",
        bank_build = "jx_turfs",
    },
    [WORLD_TILES.JX_BATH] = {
        name = "bath",
        anim = "jx_turf_bath",
        bank_build = "jx_turfs",
    },
    [WORLD_TILES.JX_WOOD] = {
        name = "jx_wood",
        anim = "jx_turf_wood",
        bank_build = "jx_turfs",
    },
    [WORLD_TILES.JX_COURTYARD] = {
        name = "jx_courtyard",
        anim = "jx_turf_courtyard",
        bank_build = "jx_turfs",
    },
}

for k, v in pairs(Turf_defs) do
    table.insert(ret, make_turf(k, v))
end
return unpack(ret)
