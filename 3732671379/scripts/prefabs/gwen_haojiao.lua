local assets = {
    Asset("ANIM", "anim/gwen_haojiao.zip"),
    Asset("SOUND", "sound/rifts4.fsb"),
    Asset("ATLAS","images/inventoryimages/gwen_haojiao.xml"),
	Asset("IMAGE","images/inventoryimages/gwen_haojiao.tex"),
}


local function DoNothing(inst, musician)
    if musician and musician.components.talker then
        musician.components.talker:Say("好像什么也没发生...")
    end

    local x, y, z = musician.Transform:GetWorldPosition()
    local listeners = TheSim:FindEntities(x, y, z, 15, nil, nil)
    for _, listener in ipairs(listeners) do
        if listener ~= inst then
            if listener.components.farmplanttendable then
                listener.components.farmplanttendable:TendTo(musician)
            end
        end
    end
    local play_fx = SpawnPrefab("mining_ice_fx")
    play_fx.Transform:SetPosition(x, y, z)
end

local function SummonDeerclops(inst, musician)
    local x, y, z = musician.Transform:GetWorldPosition()
    local play_fx = SpawnPrefab("mining_ice_fx")
    play_fx.Transform:SetPosition(x, y, z)
    local angle = math.random() * 2 * math.pi
    local offset_x = math.cos(angle) * 28
    local offset_z = math.sin(angle) * 28
    local pt = Vector3(x + offset_x, 0, z + offset_z)
    if TheWorld.Map:IsPassableAtPoint(pt.x, 0, pt.z, false, true) then
        local deerclops = SpawnPrefab("deerclops")
        if deerclops then
            deerclops.Transform:SetPosition(pt.x, 0, pt.z)
            local spawnfx = SpawnPrefab("spawn_fx_small_high")
            spawnfx.Transform:SetPosition(pt.x, 0, pt.z)
            if deerclops.components.combat then
                deerclops.components.combat:SetTarget(musician)
            end
        end
    end
end

local function SummonWalrusFamily(inst, musician)
    local x, y, z = musician.Transform:GetWorldPosition()
    local play_fx = SpawnPrefab("mining_ice_fx")
    play_fx.Transform:SetPosition(x, y, z)
    local angle = math.random() * 2 * math.pi
    local offset_x = math.cos(angle) * 28
    local offset_z = math.sin(angle) * 28
    local pt = Vector3(x + offset_x, 0, z + offset_z)
    if TheWorld.Map:IsPassableAtPoint(pt.x, 0, pt.z, false, true) then
        local walrus = SpawnPrefab("walrus")
        if walrus then
            walrus.Transform:SetPosition(pt.x, 0, pt.z)
            local spawnfx = SpawnPrefab("spawn_fx_small_high")
            spawnfx.Transform:SetPosition(pt.x, 0, pt.z)

            local little_walrus = SpawnPrefab("little_walrus")
            if little_walrus then
                little_walrus.Transform:SetPosition(pt.x + 1, 0, pt.z)
                spawnfx.Transform:SetPosition(pt.x + 1, 0, pt.z)
                if little_walrus.components.follower then
                    little_walrus.components.follower:SetLeader(walrus)
                end
            end
            for i = 1, 2 do
                local hound = SpawnPrefab("icehound")
                if hound then
                    hound.Transform:SetPosition(pt.x + (i == 1 and -1 or 2), 0, pt.z + (i == 1 and -1 or 1))
                    spawnfx.Transform:SetPosition(pt.x + (i == 1 and -1 or 2), 0, pt.z + (i == 1 and -1 or 1))
                    if hound.components.follower and little_walrus then
                        hound.components.follower:SetLeader(little_walrus)
                    end
                end
            end
            if walrus.components.combat then
                walrus.components.combat:SetTarget(musician)
            end
        end
    end
end

local function SummonKlausSack(inst, musician)
    local x, y, z = musician.Transform:GetWorldPosition()
    local play_fx = SpawnPrefab("mining_ice_fx")
    play_fx.Transform:SetPosition(x, y, z)
    local angle = math.random() * 2 * math.pi
    local offset_x = math.cos(angle) * 12
    local offset_z = math.sin(angle) * 12
    local pt = Vector3(x + offset_x, 0, z + offset_z)
    if TheWorld.Map:IsPassableAtPoint(pt.x, 0, pt.z, false, true) then
        local sack = SpawnPrefab("klaus_sack")
        if sack then
            sack.Transform:SetPosition(pt.x, 0, pt.z)
            local spawnfx = SpawnPrefab("spawn_fx_small_high")
            spawnfx.Transform:SetPosition(pt.x, 0, pt.z)

            if sack.components.klaussacklock and sack.components.klaussacklock.onusekeyfn then
                local fake_key = {
                    components = {
                        klaussackkey = {
                            truekey = false
                        }
                    }
                }
                sack.components.klaussacklock.onusekeyfn(sack, fake_key, musician)
            end
        end
    end
end



local SPELLS = {
    {
        label = "空响",
        tag = "gwen_haojiao_do_nothing",
        widget_scale = 0.65,
        bank = "spell_icons_gwen_haojiao",
        build = "spell_icons_gwen_haojiao",
        anims = {
            idle = { anim = "haojiao_spell_4" },
            focus = { anim = "haojiao_spell_4", loop = true },
            down = { anim = "haojiao_spell_4" },
            cooldown = { anim = "haojiao_spell_4" },
            disabled = { anim = "haojiao_spell_4" },
        },
        cooldowncolor = {0.5, 0.5, 0.5, 0.75},
        onselect = function(inst)
            inst.components.spellbook:SetSpellName("空响")
            inst.components.aoetargeting:SetDeployRadius(0)
            inst.components.aoetargeting.reticule.reticuleprefab = "reticulemultitarget"
            inst.components.aoetargeting.reticule.pingprefab = "reticulemultitargetping"
            inst.components.aoetargeting.reticule.mousetargetfn = function() return nil end
            inst.components.aoetargeting.reticule.targetfn = function()
                local owner = inst.components.inventoryitem and inst.components.inventoryitem.owner
                return owner and owner:GetPosition() or nil
            end
            inst.components.aoetargeting.reticule.updatepositionfn = function(inst, pos, reticule, ease, smoothing, dt)
                local owner = inst.components.inventoryitem and inst.components.inventoryitem.owner
                if owner then
                    reticule.Transform:SetPosition(owner:GetPosition():Get())
                    reticule.Transform:SetRotation(0)
                end
            end
            inst.components.aoetargeting.reticule.twinstickmode = 1
            inst.components.aoetargeting.reticule.twinstickrange = 0

            if TheWorld.ismastersim then
                inst.components.aoespell:SetSpellFn(function(inst, doer, pos)
                    if not (doer and doer:IsValid()) then
                        return false
                    end
                    DoNothing(inst, doer)
                    return true
                end)
            end
        end,
        execute = function(inst)
            local playercontroller = ThePlayer.components.playercontroller
            if playercontroller then
                playercontroller:StartAOETargetingUsing(inst)
            end
        end,
    },
    {
        label = "巨鹿",
        tag = "gwen_haojiao_deerclops",
        widget_scale = 0.65,
        bank = "spell_icons_gwen_haojiao",
        build = "spell_icons_gwen_haojiao",
        anims = {
            idle = { anim = "haojiao_spell_3" },
            focus = { anim = "haojiao_spell_3", loop = true },
            down = { anim = "haojiao_spell_3" },
            cooldown = { anim = "haojiao_spell_3" },
            disabled = { anim = "haojiao_spell_3" },
        },
        checkcooldown = function(user)
            return user
                and user.components.spellbookcooldowns
                and user.components.spellbookcooldowns:GetSpellCooldownPercent("gwen_haojiao_deerclops")
                or nil
        end,
        cooldowncolor = {0.5, 0.5, 0.5, 0.75},
        onselect = function(inst)
            inst.components.spellbook:SetSpellName("巨鹿")
            inst.components.aoetargeting:SetDeployRadius(0)
            inst.components.aoetargeting.reticule.reticuleprefab = "reticulemultitarget"
            inst.components.aoetargeting.reticule.pingprefab = "reticulemultitargetping"
            inst.components.aoetargeting.reticule.mousetargetfn = function() return nil end
            inst.components.aoetargeting.reticule.targetfn = function()
                local owner = inst.components.inventoryitem and inst.components.inventoryitem.owner
                return owner and owner:GetPosition() or nil
            end
            inst.components.aoetargeting.reticule.updatepositionfn = function(inst, pos, reticule, ease, smoothing, dt)
                local owner = inst.components.inventoryitem and inst.components.inventoryitem.owner
                if owner then
                    reticule.Transform:SetPosition(owner:GetPosition():Get())
                    reticule.Transform:SetRotation(0)
                end
            end
            inst.components.aoetargeting.reticule.twinstickmode = 1
            inst.components.aoetargeting.reticule.twinstickrange = 0

            if TheWorld.ismastersim then
                inst.components.aoespell:SetSpellFn(function(inst, doer, pos)
                    if not (doer and doer:IsValid()) then
                        return false
                    end

                    SummonDeerclops(inst, doer)
                    doer.components.spellbookcooldowns:RestartSpellCooldown("gwen_haojiao_deerclops", 480 * 15)
                    return true
                end)
            end
        end,
        execute = function(inst)
            local playercontroller = ThePlayer.components.playercontroller
            if playercontroller then
                playercontroller:StartAOETargetingUsing(inst)
            end
        end,
    },
    {
        label = "海象",
        tag = "gwen_haojiao_walrus",
        widget_scale = 0.65,
        bank = "spell_icons_gwen_haojiao",
        build = "spell_icons_gwen_haojiao",
        anims = {
            idle = { anim = "haojiao_spell_1" },
            focus = { anim = "haojiao_spell_1", loop = true },
            down = { anim = "haojiao_spell_1" },
            cooldown = { anim = "haojiao_spell_1" },
            disabled = { anim = "haojiao_spell_1" },
        },
        checkcooldown = function(user)
            return user
                and user.components.spellbookcooldowns
                and user.components.spellbookcooldowns:GetSpellCooldownPercent("gwen_haojiao_walrus")
                or nil
        end,
        cooldowncolor = {0.5, 0.5, 0.5, 0.75},
        onselect = function(inst)
            inst.components.spellbook:SetSpellName("海象")
            inst.components.aoetargeting:SetDeployRadius(0)
            inst.components.aoetargeting.reticule.reticuleprefab = "reticulemultitarget"
            inst.components.aoetargeting.reticule.pingprefab = "reticulemultitargetping"
            inst.components.aoetargeting.reticule.mousetargetfn = function() return nil end
            inst.components.aoetargeting.reticule.targetfn = function()
                local owner = inst.components.inventoryitem and inst.components.inventoryitem.owner
                return owner and owner:GetPosition() or nil
            end
            inst.components.aoetargeting.reticule.updatepositionfn = function(inst, pos, reticule, ease, smoothing, dt)
                local owner = inst.components.inventoryitem and inst.components.inventoryitem.owner
                if owner then
                    reticule.Transform:SetPosition(owner:GetPosition():Get())
                    reticule.Transform:SetRotation(0)
                end
            end
            inst.components.aoetargeting.reticule.twinstickmode = 1
            inst.components.aoetargeting.reticule.twinstickrange = 0

            if TheWorld.ismastersim then
                inst.components.aoespell:SetSpellFn(function(inst, doer, pos)
                    if not (doer and doer:IsValid()) then
                        return false
                    end

                    SummonWalrusFamily(inst, doer)
                    doer.components.spellbookcooldowns:RestartSpellCooldown("gwen_haojiao_walrus", 480 * 3)
                    return true
                end)
            end
        end,
        execute = function(inst)
            local playercontroller = ThePlayer.components.playercontroller
            if playercontroller then
                playercontroller:StartAOETargetingUsing(inst)
            end
        end,
    },
    {
        label = "赃物袋",
        tag = "gwen_haojiao_sack",
        widget_scale = 0.65,
        bank = "spell_icons_gwen_haojiao",
        build = "spell_icons_gwen_haojiao",
        anims = {
            idle = { anim = "haojiao_spell_2" },
            focus = { anim = "haojiao_spell_2", loop = true },
            down = { anim = "haojiao_spell_2" },
            cooldown = { anim = "haojiao_spell_2" },
            disabled = { anim = "haojiao_spell_2" },
        },
        checkcooldown = function(user)
            return user
                and user.components.spellbookcooldowns
                and user.components.spellbookcooldowns:GetSpellCooldownPercent("gwen_haojiao_sack")
                or nil
        end,
        cooldowncolor = {0.5, 0.5, 0.5, 0.75},
        onselect = function(inst)
            inst.components.spellbook:SetSpellName("赃物袋")
            inst.components.aoetargeting:SetDeployRadius(0)
            inst.components.aoetargeting.reticule.reticuleprefab = "reticulemultitarget"
            inst.components.aoetargeting.reticule.pingprefab = "reticulemultitargetping"
            inst.components.aoetargeting.reticule.mousetargetfn = function() return nil end
            inst.components.aoetargeting.reticule.targetfn = function()
                local owner = inst.components.inventoryitem and inst.components.inventoryitem.owner
                return owner and owner:GetPosition() or nil
            end
            inst.components.aoetargeting.reticule.updatepositionfn = function(inst, pos, reticule, ease, smoothing, dt)
                local owner = inst.components.inventoryitem and inst.components.inventoryitem.owner
                if owner then
                    reticule.Transform:SetPosition(owner:GetPosition():Get())
                    reticule.Transform:SetRotation(0)
                end
            end
            inst.components.aoetargeting.reticule.twinstickmode = 1
            inst.components.aoetargeting.reticule.twinstickrange = 0

            if TheWorld.ismastersim then
                inst.components.aoespell:SetSpellFn(function(inst, doer, pos)
                    if not (doer and doer:IsValid()) then
                        return false
                    end
                    SummonKlausSack(inst, doer)
                    doer.components.spellbookcooldowns:RestartSpellCooldown("gwen_haojiao_sack",   480 * 30)
                    return true
                end)
            end
        end,
        execute = function(inst)
            local playercontroller = ThePlayer.components.playercontroller
            if playercontroller then
                playercontroller:StartAOETargetingUsing(inst)
            end
        end,
    },
}

local function fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddNetwork()

    MakeInventoryPhysics(inst)

    inst:AddTag("horn")
    inst:AddTag("gwen_haojiao")

    inst.AnimState:SetBank("gwen_haojiao")
    inst.AnimState:SetBuild("gwen_haojiao")
    inst.AnimState:PlayAnimation("idle")
    inst:AddTag("tool")

    MakeInventoryFloatable(inst, "small", 0.3, 1.3)

    inst.entity:SetPristine()


    local SPELLBOOK_RADIUS = 100
    local SPELLBOOK_FOCUS_RADIUS = SPELLBOOK_RADIUS + 4

    inst:AddComponent("spellbook")
	inst.components.spellbook:SetRadius(SPELLBOOK_RADIUS)
	inst.components.spellbook:SetFocusRadius(SPELLBOOK_FOCUS_RADIUS)
    inst.components.spellbook:SetItems(SPELLS)
    inst.components.spellbook.opensound = "dontstarve/common/together/book_maxwell/use"
	inst.components.spellbook.closesound = "dontstarve/common/together/book_maxwell/close"


    inst:AddComponent("aoetargeting")
    inst.components.aoetargeting:SetAllowWater(true)
    inst.components.aoetargeting.reticule.validcolour = { 1, .75, 0, 1 }
    inst.components.aoetargeting.reticule.invalidcolour = { .5, 0, 0, 1 }
    inst.components.aoetargeting.reticule.ease = true
    inst.components.aoetargeting.reticule.mouseenabled = true
    inst.components.aoetargeting.reticule.twinstickmode = 1
    inst.components.aoetargeting.reticule.twinstickrange = 8
    inst.components.aoetargeting:SetRange(24)


    if not TheWorld.ismastersim then
        return inst
    end

    inst:AddComponent("inspectable")

    inst:AddTag("irreplaceable")
    
    local instrument = inst:AddComponent("instrument")
    instrument:SetAssetOverrides("gwen_haojiao", "haojiao01", "rifts4/rabbit_horn/call")

    -- inst:AddComponent("tool")
    -- inst.components.tool:SetAction(ACTIONS.PLAY)

    inst:AddComponent("aoespell")

    inst:AddComponent("inventoryitem")
    inst.components.inventoryitem.atlasname = "images/inventoryimages/gwen_haojiao.xml"
	inst.components.inventoryitem.imagename = "gwen_haojiao"


    -- inst:AddTag("rechargeable")
	-- inst:AddComponent("rechargeable")

    MakeHauntableLaunch(inst)


    return inst
end

return Prefab("gwen_haojiao", fn, assets)
