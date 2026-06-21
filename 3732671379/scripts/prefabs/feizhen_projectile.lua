local assets =
{   Asset("ANIM", "anim/feizhen_projectile.zip"),
}


local function OnAnimOver(inst)
    --inst:DoTaskInTime(9, inst.Remove)
end

local function OnThrown(inst)	    
   inst:ListenForEvent("animover", OnAnimOver) 
end

local function OnHit(inst, owner, target)

end

local NON_SMASHABLE_TAGS = { "INLIMBO", "playerghost", "player",'FX', 'NOCLICK', 'INLIMBO', 'DECOR', 'hiding', 'player','wall',"companion","abigail","spiderden","hive" }
local SMASHABLE_TAGS = {"_combat"}
local function onexplode(inst)
    local x, y, z = inst.Transform:GetWorldPosition()
	local ents = TheSim:FindEntities(x, y, z, 7, nil, NON_SMASHABLE_TAGS, SMASHABLE_TAGS)
	for i, v in ipairs(ents) do
		if v:IsValid() and not v:IsInLimbo() then
			if v.components.combat ~= nil then
				v.components.combat:GetAttacked(inst, 75)	
            end
        end
    end
	inst:DoTaskInTime(0.1, onexplode)	
end

local function fn()
	local inst = CreateEntity()

    local trans = inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()
    inst.entity:AddNetwork()
    inst.entity:AddLight()
	MakeInventoryPhysics(inst)
    RemovePhysicsColliders(inst)	
    RemovePhysicsColliders(inst)
	inst.entity:SetPristine()
	inst.AnimState:SetOrientation(ANIM_ORIENTATION.OnGround)
    local s = 1.2
    trans:SetScale(s,s,s)	 
	inst.AnimState:SetBank("feizhen_projectile")
    inst.AnimState:SetBuild("feizhen_projectile")
    inst.AnimState:PlayAnimation("idle",true)
	inst.AnimState:SetOrientation(ANIM_ORIENTATION.OnGround)
    --projectile (from projectile component) added to pristine state for optimization
    inst:AddTag("projectile")
	inst:AddTag("staff")
 
    inst:ListenForEvent("animover", inst.Remove)

    if not TheWorld.ismastersim then
        return inst
    end
	inst:AddComponent("combat")
    inst.components.combat:SetDefaultDamage(75)
    inst.components.combat.playerdamagepercent = 0
	
	inst:AddComponent("weapon")
    inst.components.weapon:SetDamage(75)
    inst.components.weapon:SetRange(8, 12)
	
    inst.persists = false
	
	inst.hittargets = {}
    inst:DoTaskInTime(0.05, onexplode)
    inst:AddComponent("projectile")
    inst.components.projectile:SetSpeed(15)
    inst.components.projectile:SetHitDist(0)
    inst.components.projectile:SetOnHitFn(OnHit)
    inst.components.projectile:SetOnMissFn(inst.Remove)
    inst.components.projectile:SetOnThrownFn(OnThrown)
    inst.components.projectile:SetCanCatch(true)
    --inst.components.projectile:SetOnCaughtFn(OnCaught)
    inst.components.projectile:SetLaunchOffset(Vector3(0, 1, 0))
	
	local light = inst.entity:AddLight()
	inst.Light:Enable(true)
    inst.Light:SetRadius(1)
    inst.Light:SetFalloff(0.5)
    inst.Light:SetIntensity(.75)
    light:SetColour(0/255, 255/255, 146/255)
	

    inst:AddTag("fx")

    return inst
end

return Prefab( "feizhen_projectile", fn, assets) 