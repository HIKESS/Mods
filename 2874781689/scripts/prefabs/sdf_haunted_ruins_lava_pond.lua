local assets =
{
    Asset("ATLAS", "images/map_icons/sdf_haunted_ruins_lava_pond_mm.xml"),
    Asset("IMAGE", "images/map_icons/sdf_haunted_ruins_lava_pond_mm.tex"),

    Asset("ANIM", "anim/sdf_haunted_ruins_lava_pond.zip"),
}

local rock_assets =
{
    Asset("ANIM", "anim/sdf_haunted_ruins_lava_pond_rock.zip"),
}

local NUM_ROCK_TYPES = 7

local function makerock(rocktype)
    local function fn()
        local inst = CreateEntity()

        inst.entity:AddTransform()
        inst.entity:AddAnimState()
        inst.entity:AddNetwork()

        inst.AnimState:SetBank("sdf_haunted_ruins_lava_pond_rock")
        inst.AnimState:SetBuild("sdf_haunted_ruins_lava_pond_rock")
        inst.AnimState:PlayAnimation("idle"..rocktype)

        if rocktype:len() > 0 then
            inst:SetPrefabNameOverride("sdf_haunted_ruins_lava_pond_rock")
        end

        inst.entity:SetPristine()

        if not TheWorld.ismastersim then
            return inst
        end

        inst:AddComponent("inspectable")

        inst:AddComponent("hauntable")
        inst.components.hauntable:SetHauntValue(TUNING.HAUNT_TINY)

        return inst
    end
    return Prefab("sdf_haunted_ruins_lava_pond_rock"..rocktype, fn, rock_assets)
end

local function SpawnRocks(inst)
    inst.task = nil
    if inst.rocks == nil then
        inst.rocks = {}
        for i = 1, math.random(2, 4) do
            local theta = math.random() * TWOPI
            local rocktype = math.random(NUM_ROCK_TYPES)
            table.insert(inst.rocks,
            {
                rocktype = rocktype > 1 and tostring(rocktype) or "",
                offset =
                {
                    math.sin(theta) * 2.8 + math.random() * .3, --2.1
                    0,
                    math.cos(theta) * 2.8 + math.random() * .3, --2.1
                },
            })
        end
    end
    for i, v in ipairs(inst.rocks) do
        if type(v.rocktype) == "string" and type(v.offset) == "table" and #v.offset == 3 then
            local rock = SpawnPrefab("sdf_haunted_ruins_lava_pond_rock"..v.rocktype)
            if rock ~= nil then
                rock.entity:SetParent(inst.entity)
                rock.Transform:SetPosition(unpack(v.offset))
                rock.persists = false
            end
        end
    end
end

--------------------------------------------------------------------------

--------------------------------------------------------------------------

local function lavabathe(inst, target)
    if target ~= nil and target:IsValid() then
	--lava bathe debuff
	if target._sdf_haunted_ruins_lava_pond_lavabathe_debufftask ~= nil then
	    target._sdf_haunted_ruins_lava_pond_lavabathe_debufftask:Cancel()
	end
	--lava bathe anim
	if target._sdf_haunted_ruins_lava_pond_lavabathe_debuffFXtask ~= nil then
	    target._sdf_haunted_ruins_lava_pond_lavabathe_debuffFXtask:Cancel()
	end

	--Remove debuff and anim
	target._sdf_haunted_ruins_lava_pond_lavabathe_debufftask = target:DoTaskInTime(TUNING.SDF_HAUNTED_RUINS_LAVA_POND_LAVABATHE_DEBUFF_DURATION, function(i)
	    i._sdf_haunted_ruins_lava_pond_lavabathe_debufftask = nil
	    i._sdf_haunted_ruins_lava_pond_lavabathe_debuffFXtask:Cancel() i._sdf_haunted_ruins_lava_pond_lavabathe_debuffFXtask = nil
	end)

	--Add debuff and anim
	target._sdf_haunted_ruins_lava_pond_lavabathe_debuffFXtask = target:DoPeriodicTask(TUNING.SDF_HAUNTED_RUINS_LAVA_POND_LAVABATHE_DEBUFF_TICK, function(i)
	    if target ~= nil and not target.components.health:IsDead() then
		local targetMaxHealth = target.components.health:GetMaxWithPenalty()

		target.components.health:DoDelta(-((targetMaxHealth * TUNING.SDF_HAUNTED_RUINS_LAVA_POND_LAVABATHE_DEBUFF_DAMAGE_PERCENT) / (TUNING.SDF_HAUNTED_RUINS_LAVA_POND_LAVABATHE_DEBUFF_DURATION / TUNING.SDF_HAUNTED_RUINS_LAVA_POND_LAVABATHE_DEBUFF_TICK)), false, "lavabathe")
		local lavabatheFX = SpawnPrefab("firesplash_fx")
		if lavabatheFX then
		    local x,_,z = target.Transform:GetWorldPosition()
		    lavabatheFX.Transform:SetPosition(x,_,z)
		end
	    end
	end)
    end
end

local function OnCollide(inst, other)
    if other ~= nil and other:IsValid() and inst:IsValid() then

	--lite on fire
	if not other:HasTag("sdf_haunted_ruins_lava_pond_immune") then
	    --lite on fire
	    if other.components.burnable ~= nil then
		other.components.burnable:Ignite(true, inst)
	    end 
	end

	--special traits
	if other:HasTag("sdf_haunted_ruins_lava_pond_weakness") then
	    --stone golem weakness -Break Shield-
	    if other:HasTag("sdf_stone_golem") and other:HasTag("sdf_stone_golem_shielded") then
		
		if not other:HasTag("sdf_stone_golem_shielded_broken") then
		    other:AddTag("sdf_stone_golem_shielded_broken")
		end

		--lite on fire
		lavabathe(inst, other)
	    end
	end
    end
end

local function OnSave(inst, data)
    data.rocks = inst.rocks
end

local function OnLoad(inst, data)
    if data ~= nil and data.rocks ~= nil and inst.rocks == nil and inst.task ~= nil then
        inst.task:Cancel()
        inst.task = nil
        inst.rocks = data.rocks
        SpawnRocks(inst)
    end
end

local function fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()
    inst.entity:AddLight()
    inst.entity:AddMiniMapEntity()
    inst.entity:AddNetwork()

    inst.MiniMapEntity:SetIcon("sdf_haunted_ruins_lava_pond_mm.tex")
    inst.MiniMapEntity:SetPriority(1)

    MakePondPhysics(inst, 3.5) --3

    local s = 1.5 --1.5
    inst.Transform:SetScale(s,s,s)

    inst.AnimState:SetBuild("sdf_haunted_ruins_lava_pond")
    inst.AnimState:SetBank("sdf_haunted_ruins_lava_pond")
    inst.AnimState:PlayAnimation("bubble_lava", true)

    inst.AnimState:SetBloomEffectHandle("shaders/anim.ksh")
    inst.AnimState:SetOrientation(ANIM_ORIENTATION.OnGround)
    inst.AnimState:SetLayer(LAYER_WORLD_BACKGROUND)
    inst.AnimState:SetSortOrder(0)

    inst:AddTag("lava")
    inst:AddTag("antlion_sinkhole_blocker")
    inst:AddTag("birdblocker")
    inst:AddTag("cooker")

    inst.Light:Enable(true)
    inst.Light:EnableClientModulation(true)
    inst.Light:SetRadius(Lerp(6, 7, 0.4)) --1.5
    inst.Light:SetFalloff(Lerp(0.8, 0.7, 0.4)) --0.66
    inst.Light:SetIntensity(Lerp(0.8, 0.7, 0.4)) --0.66
    inst.Light:SetColour(235 / 255, 121 / 255, 12 / 255)

    inst.no_wet_prefix = true

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst.Physics:SetCollisionCallback(OnCollide)

    inst:AddComponent("inspectable")

    inst:AddComponent("heater")
    inst.components.heater.heat = 500

    inst:AddComponent("cooker")

    inst.rocks = nil
    inst.task = inst:DoTaskInTime(0, SpawnRocks)

    inst.OnSave = OnSave
    inst.OnLoad = OnLoad

    return inst
end

local ret = { makerock("") }
local prefabs = { "sdf_haunted_ruins_lava_pond_rock" }
for i = 2, NUM_ROCK_TYPES do
    table.insert(ret, makerock(tostring(i)))
    table.insert(prefabs, "sdf_haunted_ruins_lava_pond_rock"..tostring(i))
end
table.insert(ret, Prefab("sdf_haunted_ruins_lava_pond", fn, assets, prefabs))
prefabs = nil
return unpack(ret)
