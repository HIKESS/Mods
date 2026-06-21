
local assets =
{
    Asset("ANIM", "anim/gw_zhizhen.zip"),
    Asset("ATLAS","images/inventoryimages/gw_zhizhen.xml"),
	Asset("IMAGE","images/inventoryimages/gw_zhizhen.tex"),

}

local function ZhiZhenChuanSong(inst)
    if inst.components.rechargeable:IsCharged() then
        local owner = inst.components.inventoryitem.owner
		if owner == nil or not owner:IsValid() then
			return
		end

		if owner.gw_hunqian ~= nil then
			owner.gw_hunqian:Cancel()
			owner.gw_hunqian = nil
		end
		owner:AddTag("gw_hunqian")
		SpawnPrefab("cavehole_flick_warn").Transform:SetPosition(owner.Transform:GetWorldPosition())
		if owner.gw_hunqian == nil then
			owner.gw_hunqian = owner:DoPeriodicTask(30, function()
				owner:RemoveTag("gw_hunqian")
			end)
        end
		if inst.gw_hunqian ~= nil then
			inst.gw_hunqian:Cancel()
			inst.gw_hunqian = nil
		end
		inst:AddTag("gw_hunqian")
		SendModRPCToClient(CLIENT_MOD_RPC["LegionMsg"]["gw_UiRefresh"],inst.userid) ----客户端发送
		if inst.gw_hunqian == nil then
			inst.gw_hunqian = inst:DoPeriodicTask(30, function()
				inst:RemoveTag("gw_hunqian")
				SendModRPCToClient(CLIENT_MOD_RPC["LegionMsg"]["gw_UiRefresh"],inst.userid) ----客户端发送
			end)
        end
		inst.components.rechargeable:Discharge(240)
    end
    return true
end

local function OnCharged(inst)
    inst.components.spellcaster.canusefrominventory = true
	inst:RemoveTag("gw_hunqiancd")
	SendModRPCToClient(CLIENT_MOD_RPC["LegionMsg"]["gw_UiRefresh"],inst.userid) ----客户端发送
end

local function OnDischarged(inst)
    inst.components.spellcaster.canusefrominventory = false
	inst:AddTag("gw_hunqiancd")
	SendModRPCToClient(CLIENT_MOD_RPC["LegionMsg"]["gw_UiRefresh"],inst.userid) ----客户端发送
end


-- local function onputininventoryfn(inst, owner)
--     if owner then
--         owner:AddTag("gw_hunqian")
--     end
-- end

-- local function OnDropped(inst, owner)
--     if owner then
--         owner:RemoveTag("gw_hunqian")
--     end
-- end

--[]--[]--[]--[]--[]--[]--[]--[]--[]--[]--[]--[]--[]--[]--[]--[]--[]--[]--[]--[]--
local function fn()
	local inst = CreateEntity()
	local trans = inst.entity:AddTransform()
	local anim = inst.entity:AddAnimState()

	MakeInventoryPhysics(inst)
	MakeInventoryFloatable(inst, "med", .07, 0.71)

	inst.entity:AddSoundEmitter()
	inst.entity:AddTransform()
	inst.entity:AddLight()
	inst.entity:AddNetwork() 
	inst.entity:AddMiniMapEntity()

	inst.AnimState:SetBank("bank0")
	inst.AnimState:SetBuild("skeleton1")
	inst.AnimState:PlayAnimation("animation", true)
    inst.AnimState:SetScale(2.5, 2.5, 2.5)

	inst:AddTag("gw_zhizhen")
	
	inst.entity:SetPristine()

	if not TheWorld.ismastersim then
        return inst
    end

	inst:AddComponent("inspectable")

	inst:AddComponent("inventoryitem")
	-- inst.components.inventoryitem:SetOnPutInInventoryFn(onputininventoryfn)
    -- inst.components.inventoryitem:SetOnDroppedFn(OnDropped)
	inst.components.inventoryitem.atlasname = "images/inventoryimages/gw_zhizhen.xml"
	inst.components.inventoryitem.imagename = "gw_zhizhen"
	inst.components.inventoryitem.canonlygoinpocket = true

	inst:AddComponent("spellcaster")
    inst.components.spellcaster:SetSpellFn(ZhiZhenChuanSong)
    inst.components.spellcaster.canusefrominventory = true
    inst.components.spellcaster.veryquickcast = true

	inst:AddComponent("rechargeable")
    inst.components.rechargeable:SetOnDischargedFn(OnDischarged)
    inst.components.rechargeable:SetOnChargedFn(OnCharged)

    return inst
end

return Prefab("gw_zhizhen", fn, assets)