local assets =
{
    Asset("ANIM", "anim/gw_yifu_zhandou2.zip"),
	Asset("ATLAS", "images/inventoryimages/gw_yifu_zhandou2.xml"),
    Asset("IMAGE", "images/inventoryimages/gw_yifu_zhandou2.tex"),

    Asset("ANIM", "anim/gw_maozi_zhandou2.zip"),
	Asset("ATLAS", "images/inventoryimages/gw_maozi_zhandou2.xml"),
    Asset("IMAGE", "images/inventoryimages/gw_maozi_zhandou2.tex"),
}
--[]--[]--[]--[]--[]--[]--[]--[]--[]--[]--[]--[]--[]--[]--[]--[]--[]--[]--[]--[]--
----光照配置
local LIGHT_COLOR = {197/255, 208/255, 230/255}  -- 淡蓝色
local LIGHT_RADIUS = 5.5        ---半径
local LIGHT_FALLOFF = 0.8       ---光线衰减
local LIGHT_INTENSITY = 0.6     ---强度

--[]--[]--[]--[]--[]--[]--[]--[]--[]--[]--[]--[]--[]--[]--[]--[]--[]--[]--[]--[]--
-- 头盔光效

local function UpdateHelmetLight(inst)
    if inst._light == nil then
        return
    end

    local has_items = false
    if inst.components.container ~= nil then
        for i = 1, inst.components.container:GetNumSlots() do
            local item = inst.components.container:GetItemInSlot(i)
            if item ~= nil then
                has_items = true
                break
            end
        end
    end

    if has_items then
        inst._light.Light:Enable(true)
        inst._light.Light:SetRadius(LIGHT_RADIUS)
        inst._light.Light:SetFalloff(LIGHT_FALLOFF)
        inst._light.Light:SetIntensity(LIGHT_INTENSITY)
        inst._light.Light:SetColour(unpack(LIGHT_COLOR))
    else
        inst._light.Light:Enable(false)
    end
end

local function OnContainerItemGet(inst, data)
    UpdateHelmetLight(inst)
end

local function OnContainerItemLose(inst, data)
    UpdateHelmetLight(inst)
end

--[]--[]--[]--[]--[]--[]--[]--[]--[]--[]--[]--[]--[]--[]--[]--[]--[]--[]--[]--[]--
----衣服
local function OnBlocked(owner, data) 
    owner.SoundEmitter:PlaySound("dontstarve/wilson/hit_armour")
end

local function onequip_yifu(inst, owner)
	owner.AnimState:OverrideSymbol("swap_body", "gw_yifu_zhandou2", "swap_body")
    inst:ListenForEvent("blocked", OnBlocked, owner)

    if not owner:HasTag("gw_cs_2") then
		owner:AddTag("gw_cs_2")
	end
    -- if not owner:HasTag("gw_tailor") then    ----裁缝服装测试功能
	-- 	owner:AddTag("gw_tailor")
	-- end

    if owner and owner.components.inventory then
        for k,v in pairs(owner.components.inventory.equipslots) do
            if v and v.prefab == "gw_maozi_zhandou2" then
                owner.gw_taozhuang_zhandou2_active = true
            end
        end
    end
end

local function onunequip_yifu(inst, owner)
    owner.AnimState:ClearOverrideSymbol("swap_body")
    inst:RemoveEventCallback("blocked", OnBlocked, owner)
    owner:RemoveTag("gw_cs_2")
    -- owner:RemoveTag("gw_tailor")

    if owner.gw_taozhuang_zhandou2_active ~= nil then
        owner.gw_taozhuang_zhandou2_active = nil
    end
end

--[]--[]--[]--[]--[]--[]--[]--[]--[]--[]--[]--[]--[]--[]--[]--[]--[]--[]--[]--[]--
----帽子
local function onequip_maozi(inst, owner) 
	owner.AnimState:OverrideSymbol("swap_hat", "gw_maozi_zhandou2", "swap_hat")
	owner.AnimState:Show("HAT")
	owner.AnimState:Hide("HAT_HAIR")
	owner.AnimState:Show("HAIR_NOHAT")
	owner.AnimState:Show("HAIR")

	owner.AnimState:Show("HEAD")
	owner.AnimState:Hide("HEAD_HAIR")

	-- if inst.components.fueled ~= nil then
	-- 	inst.components.fueled:StartConsuming()
	-- end	

    inst.onattach(owner)

	if not owner:HasTag("zhandoukin2") then
		owner:AddTag("zhandoukin2")
	end
    if owner.components.sanity ~= nil then
    owner.components.sanity.neg_aura_modifiers:SetModifier(inst, 0)
    end

    if owner and owner.components.inventory then
        for k,v in pairs(owner.components.inventory.equipslots) do
            if v and v.prefab == "gw_yifu_zhandou2" then
                owner.gw_taozhuang_zhandou2_active = true
            end
        end
    end

    if inst.components.container ~= nil then
        inst.components.container:Open(owner)
    end
    if inst._light == nil then
        inst._light = SpawnPrefab("minerhatlight")
    end
    if inst._light ~= nil then
        inst._light.entity:SetParent(owner.entity)
        UpdateHelmetLight(inst)
    end
end

local function onunequip_maozi(inst, owner)
	owner.AnimState:Hide("HAT")
	owner.AnimState:Hide("HAT_HAIR")
	owner.AnimState:Show("HAIR_NOHAT")
	owner.AnimState:Show("HAIR")

	owner:RemoveTag("zhandoukin2")

	if owner:HasTag("player") then
		owner.AnimState:Show("HEAD")
		owner.AnimState:Hide("HEAD_HAT")
	end

    if owner.gw_taozhuang_zhandou2_active ~= nil then
        owner.gw_taozhuang_zhandou2_active = nil
    end

    -- if inst.components.fueled ~= nil then
    --     inst.components.fueled:StopConsuming()
    -- end

    inst.ondetach()
    if owner.components.sanity ~= nil then
    owner.components.sanity.neg_aura_modifiers:RemoveModifier(inst)
    end
    if inst.components.container ~= nil then
        inst.components.container:Close()
    end
    if inst._light ~= nil then
        inst._light:Remove()
        inst._light = nil
    end
end


--[]--[]--[]--[]--[]--[]--[]--[]--[]--[]--[]--[]--[]--[]--[]--[]--[]--[]--[]--[]--
----损坏和修复函数（衣服）

local function OnBroken(inst)
    if inst.components.equippable and inst.components.equippable:IsEquipped() then
        local owner = inst.components.inventoryitem.owner
        if owner and owner.components.inventory then
            local item = owner.components.inventory:Unequip(EQUIPSLOTS.BODY)
            if item then
                owner.components.inventory:GiveItem(item)
            end
        end
    end
    inst:RemoveComponent("equippable")
    inst.components.inspectable.nameoverride = "BROKEN_FORGEDITEM" 
    inst:AddTag("broken")
end

local function OnRepaired(inst)
    if not inst.components.equippable then
        inst:AddComponent("equippable")
        inst.components.equippable.equipslot = EQUIPSLOTS.BODY
        inst.components.equippable.insulated = true
        inst.components.equippable:SetOnEquip(onequip_yifu)
        inst.components.equippable:SetOnUnequip(onunequip_yifu)
        inst.components.equippable.walkspeedmult = 1.1
        inst.components.inspectable.nameoverride = nil 
        inst.components.equippable.dapperness = TUNING.DAPPERNESS_MED
        inst:RemoveTag("broken")
    end
end

local function onpercent(inst, data)
    local percent = data and data.percent or inst.components.armor.condition
    if percent <= 0 then
        OnBroken(inst)
    else
        OnRepaired(inst)
    end
end

--[]--[]--[]--[]--[]--[]--[]--[]--[]--[]--[]--[]--[]--[]--[]--[]--[]--[]--[]--[]--
----损坏和修复函数（帽子）

local function OnBroken_maozi(inst)
    if inst.components.equippable and inst.components.equippable:IsEquipped() then
        local owner = inst.components.inventoryitem.owner
        if owner and owner.components.inventory then
            local item = owner.components.inventory:Unequip(EQUIPSLOTS.HEAD)
            if item then
                owner.components.inventory:GiveItem(item)
            end
        end
    end
    inst:RemoveComponent("equippable")
    inst:AddTag("broken")
    inst.components.inspectable.nameoverride = "BROKEN_FORGEDITEM"  
end

local function OnRepaired_maozi(inst)
    if not inst.components.equippable then
        inst:AddComponent("equippable")
        inst.components.equippable.equipslot = EQUIPSLOTS.HEAD
        inst.components.equippable:SetOnEquip(onequip_maozi)
        inst.components.equippable:SetOnUnequip(onunequip_maozi)
        inst.components.equippable.dapperness = TUNING.DAPPERNESS_MED
        inst.components.inspectable.nameoverride = nil  
        inst:RemoveTag("broken")
    end
end

local function onfuelchange_maozi(inst, data)
    local percent = data and data.percent or inst.components.armor.condition
    if percent <= 0 then
        OnBroken_maozi(inst)
    else
        OnRepaired_maozi(inst)
    end
end

---[]--[]--[]--[]--[]--[]--[]--[]--[]--[]--[]--[]--[]--[]--[]--[]--[]--[]--[]--[]--
-- 铥矿皇冠盾类似的力场系统函数 

local function ruinshat_fxanim(inst)
    if inst._fx ~= nil then
        inst._fx.AnimState:PlayAnimation("hit")
        inst._fx.AnimState:PushAnimation("idle_loop")
    end
end

local function ruinshat_oncooldown(inst)
    inst._task = nil
end

local function ruinshat_unproc(inst)
    if inst:HasTag("forcefield") then
        inst:RemoveTag("forcefield")
        if inst._fx ~= nil then
            inst._fx:kill_fx()
            inst._fx = nil
        end
        inst:RemoveEventCallback("armordamaged", ruinshat_fxanim)

 		-- if inst.components.armor ~= nil then
        --     inst:RemoveComponent("armor")
        -- end

        inst.components.armor:SetAbsorption(0.9)

        if inst._task ~= nil then
            inst._task:Cancel()
        end
        inst._task = inst:DoTaskInTime(TUNING.ARMOR_RUINSHAT_COOLDOWN or 10, ruinshat_oncooldown)
    end
end

local function ruinshat_proc(inst, owner)
    inst:AddTag("forcefield")
    if inst._fx ~= nil then
        inst._fx:kill_fx()
    end
    inst._fx = SpawnPrefab("gw_forcefieldfx")
    inst._fx.entity:SetParent(owner.entity)
    inst._fx.Transform:SetPosition(0, 0.2, 0)
    inst:ListenForEvent("armordamaged", ruinshat_fxanim)


	inst.components.armor:SetAbsorption(TUNING.FULL_ABSORPTION) 


    if inst._task ~= nil then
        inst._task:Cancel()
    end
    inst._task = inst:DoTaskInTime(TUNING.ARMOR_RUINSHAT_DURATION or 5, ruinshat_unproc)
end

local function tryproc(inst, owner, data)
    if owner.gw_taozhuang_zhandou2_active == true and 
        inst._task == nil and
        not data.redirected and
        math.random() < (0.3) then
        ruinshat_proc(inst, owner)
    end
end


--[]--[]--[]--[]--[]--[]--[]--[]--[]--[]--[]--[]--[]--[]--[]--[]--[]--[]--[]--[]--
----衣服

local function gw_yifufn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddNetwork()

    MakeInventoryPhysics(inst)
	MakeInventoryFloatable(inst, "med", .15, 0.71)

    inst.AnimState:SetBank("gw_yifu_zhandou2")
    inst.AnimState:SetBuild("gw_yifu_zhandou2")
    inst.AnimState:PlayAnimation("anim")

    inst:AddTag("gw_fuzhuang")
	inst:AddTag("show_broken_ui")
    inst:AddTag("waterproofer")

    inst.foleysound = "dontstarve/movement/foley/logarmour"

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst:AddComponent("inspectable")

    inst:AddComponent("inventoryitem")
    inst.components.inventoryitem.imagename = "gw_yifu_zhandou2"
	inst.components.inventoryitem.atlasname = "images/inventoryimages/gw_yifu_zhandou2.xml"
    
    MakeSmallBurnable(inst, TUNING.SMALL_BURNTIME)
    MakeSmallPropagator(inst)

	inst:AddComponent("armor")
    inst.components.armor:InitCondition(2000, 0.9)
    inst.components.armor.SetCondition = function(self, amount)
    if self.indestructible then
        return
    end
    self.condition = math.max(math.min(amount, self.maxcondition), 0)
    self.inst:PushEvent('percentusedchange', {percent = self:GetPercent()})
end

    inst:AddComponent("planardefense")
	inst.components.planardefense:SetBaseDefense(20)

    inst:AddComponent("equippable")
    inst.components.equippable.equipslot = EQUIPSLOTS.BODY
    inst.components.equippable.insulated = true
    inst.components.equippable:SetOnEquip(onequip_yifu)
    inst.components.equippable:SetOnUnequip(onunequip_yifu)
    inst.components.equippable.walkspeedmult = 1.1
    inst.components.equippable.dapperness = TUNING.DAPPERNESS_MED

	inst:AddComponent("insulator") 
    inst.components.insulator:SetInsulation(240)
	inst.components.insulator:SetWinter()

	inst:AddComponent("waterproofer")
    inst.components.waterproofer:SetEffectiveness(0.8)

    inst:ListenForEvent('percentusedchange', onpercent)
    onpercent(inst)



    MakeHauntableLaunch(inst)


    return inst
end

--[]--[]--[]--[]--[]--[]--[]--[]--[]--[]--[]--[]--[]--[]--[]--[]--[]--[]--[]--[]--
----帽子

local function gw_maozifn(Sim)
	local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddNetwork()

    MakeInventoryPhysics(inst)
	MakeInventoryFloatable(inst, "med", .15, 0.71)

    inst.AnimState:SetBank("gw_maozi_zhandou2")
    inst.AnimState:SetBuild("gw_maozi_zhandou2")
    inst.AnimState:PlayAnimation("anim")

	inst:AddTag("hat")
	inst:AddTag("hide")
	inst:AddTag("gw_fuzhuang")
	inst:AddTag("show_broken_ui")
    inst:AddTag("goggles")
    inst:AddTag("hardarmor")

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst:AddComponent("inspectable")

    inst:AddComponent("inventoryitem")
    inst.components.inventoryitem.imagename = "gw_maozi_zhandou2"
	inst.components.inventoryitem.atlasname = "images/inventoryimages/gw_maozi_zhandou2.xml"

    inst:AddComponent("container")
    inst.components.container:WidgetSetup("gw_maozi_zhandou2")


	inst:AddComponent("equippable")
	inst.components.equippable.equipslot = EQUIPSLOTS.HEAD
    inst.components.equippable:SetOnUnequip(onunequip_maozi)
	inst.components.equippable:SetOnEquip(onequip_maozi)
    inst.components.equippable.dapperness = TUNING.DAPPERNESS_MED

	-- inst:AddComponent("fueled")
	-- inst.components.fueled.fueltype = FUELTYPE.USAGE
	-- inst.components.fueled:InitializeFuelLevel(TUNING.BEEFALOHAT_PERISHTIME)
    -- inst.components.fueled:SetDepletedFn(function(inst) 
    --     onfuelchange_maozi(inst) 
    -- end)

    
	inst:AddComponent("armor")
    inst.components.armor:InitCondition(2000, 0.9)
    inst.components.armor.SetCondition = function(self, amount)
    if self.indestructible then
        return
    end
    self.condition = math.max(math.min(amount, self.maxcondition), 0)
    self.inst:PushEvent('percentusedchange', {percent = self:GetPercent()})
end


	inst:AddComponent("waterproofer")
    inst.components.waterproofer:SetEffectiveness(1)

    inst:AddComponent("insulator")
    inst.components.insulator:SetInsulation(TUNING.INSULATION_MED *2)
    inst.components.insulator:SetSummer()


    inst:ListenForEvent("itemget", OnContainerItemGet)
    inst:ListenForEvent("itemlose", OnContainerItemLose)

    inst:AddComponent("tradable")

	MakeHauntableLaunchAndPerish(inst)

    inst._fx = nil
    inst._task = nil
    inst._owner = nil
    inst.procfn = function(owner, data) tryproc(inst, owner, data) end
    inst.onattach = function(owner)
        if inst._owner ~= nil then
            inst:RemoveEventCallback("attacked", inst.procfn, inst._owner)
            inst:RemoveEventCallback("onremove", inst.ondetach, inst._owner)
        end
        inst:ListenForEvent("attacked", inst.procfn, owner)
        inst:ListenForEvent("onremove", inst.ondetach, owner)
        inst._owner = owner
        inst._fx = nil
    end
    inst.ondetach = function()
        ruinshat_unproc(inst)
        if inst._owner ~= nil then
            inst:RemoveEventCallback("attacked", inst.procfn, inst._owner)
            inst:RemoveEventCallback("onremove", inst.ondetach, inst._owner)
            inst._owner = nil
            inst._fx = nil
        end
    end

    -- inst:ListenForEvent("percentusedchange", onfuelchange_maozi)
    -- inst:ListenForEvent("fueldepleted", onfuelchange_maozi)
    -- onfuelchange_maozi(inst)

    inst:ListenForEvent('percentusedchange', onfuelchange_maozi)
    onfuelchange_maozi(inst)

    return inst
end 


----------------------------------------------------------------------
return Prefab("gw_yifu_zhandou2", gw_yifufn, assets),
		Prefab("gw_maozi_zhandou2", gw_maozifn, assets)