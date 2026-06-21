local assets =
{
    Asset("ANIM", "anim/bonepaste.zip"),
	Asset("ATLAS", "images/inventoryimages/wiltonmod_bonepaste.xml"),
    Asset("IMAGE", "images/inventoryimages/wiltonmod_bonepaste.tex"),
}

local function GetFertilizerKey(inst)
    return inst.prefab
end

local function fertilizerresearchfn(inst)
    return inst:GetFertilizerKey()
end

local function fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddNetwork()

    inst:AddTag("wiltonmod_item") 
    inst:AddTag("fertilizerresearchable")
    inst.GetFertilizerKey = GetFertilizerKey

    MakeInventoryPhysics(inst)
    MakeInventoryFloatable(inst, "small")
    MakeDeployableFertilizerPristine(inst)

    inst.AnimState:SetBank("bonepaste")
    inst.AnimState:SetBuild("bonepaste")
    inst.AnimState:PlayAnimation("idle")

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst:AddComponent("stackable")
    inst.components.stackable.maxsize = TUNING.STACK_SIZE_SMALLITEM

    inst:AddComponent("inspectable")

    inst:AddComponent("inventoryitem")
    inst.components.inventoryitem.imagename = "wiltonmod_bonepaste"    
	inst.components.inventoryitem.atlasname = "images/inventoryimages/wiltonmod_bonepaste.xml"

    inst:AddComponent("fertilizerresearchable")
    inst.components.fertilizerresearchable:SetResearchFn(fertilizerresearchfn)

    inst:AddComponent("fertilizer")
    inst.components.fertilizer.fertilizervalue = TUNING.POOP_FERTILIZE
    inst.components.fertilizer.soil_cycles = TUNING.POOP_SOILCYCLES
    inst.components.fertilizer.withered_cycles = TUNING.POOP_WITHEREDCYCLES
    inst.components.fertilizer:SetNutrients({  12,  12,  12 })
    
    inst:AddComponent("healer")
    local OldHeal = inst.components.healer.Heal 
    inst.components.healer.Heal = function(self, target, doer, ...)
        if target and (target.prefab == "wormwood" or target.prefab == "wiltonmod" or target.prefab == "wiltonmod_pet") then
            if target.prefab == "wormwood" then
                self.health = 20

            elseif target.prefab == "wiltonmod" then
                self.health = 40 
                target.components.health:DeltaPenalty(-0.25) 
            else
                self.health = 100               
            end
            return OldHeal(self, target, doer, ...)
        else
            return false     
        end    
    end

    MakeHauntableLaunch(inst)  --ThePlayer.components.health:DoDelta(-50)
    MakeDeployableFertilizer(inst)

    return inst
end

return Prefab("wiltonmod_bonepaste", fn, assets)