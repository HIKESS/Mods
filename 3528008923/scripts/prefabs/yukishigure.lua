local assets=
{
    Asset("ANIM", "anim/yukishigure.zip"),   
    Asset("ANIM", "anim/swap_yukishigure.zip"),
    Asset("ANIM", "anim/sc_yuki.zip"),
    
    Asset("ATLAS", "images/inventoryimages/yukishigure.xml"),
    Asset("IMAGE", "images/inventoryimages/yukishigure.tex"),	
}

local function ReticuleTargetFn()
    local player = ThePlayer
    local ground = TheWorld.Map
    local pos = Vector3()
    --Attack range is 8, leave room for error
    --Min range was chosen to not hit yourself (2 is the hit range)
    for r = 6.5, 3.5, -.25 do
        pos.x, pos.y, pos.z = player.entity:LocalToWorldSpace(r, 0, 0)
        if ground:IsPassableAtPoint(pos:Get()) and not ground:IsGroundTargetBlocked(pos) then
            return pos
        end
    end
    return pos
end

local function ReticuleShouldHideFn(inst)
	return not inst:HasTag("projectile")
end

local function HasFriendlyLeader(inst, target, attacker)
    local target_leader = target.components.follower and target.components.follower:GetLeader()
    
    if target_leader ~= nil then

        if target_leader.components.inventoryitem then
            target_leader = target_leader.components.inventoryitem:GetGrandOwner()
        end

        local PVP_enabled = TheNet:GetPVPEnabled()
        return (target_leader ~= nil 
                and (target_leader:HasTag("player") 
                and not PVP_enabled)) or
                (target.components.domesticatable and target.components.domesticatable:IsDomesticated() 
                and not PVP_enabled) or
                (target.components.saltlicker and target.components.saltlicker.salted
                and not PVP_enabled)
    end

    return false
end

local function CanDamage(inst, target, attacker)
    if target.components.minigame_participator ~= nil or target.components.combat == nil then
		return false
	end

    --if attacker == target then -- NOTES(JBK): Uncomment this to able to hit yourself with physical damage.
    --    return true
    --end

    if target:HasTag("player") and not TheNet:GetPVPEnabled() then
        return false
    end

    if target:HasTag("playerghost") and not target:HasTag("INLIMBO") then
        return false
    end

    local leader = target.components.follower and target.components.follower:GetLeader()
    if target:HasTag("monster") and not TheNet:GetPVPEnabled() and 
       ((leader and leader:HasTag("player")) or target.bedazzled) then
        return false
    end

    if HasFriendlyLeader(inst, target, attacker) then
        return false
    end

    return true
end

local function ResetPhysics(inst)
	inst.Physics:SetFriction(0.1)
	inst.Physics:SetRestitution(0.5)
	inst.Physics:SetCollisionGroup(COLLISION.ITEMS)
	inst.Physics:SetCollisionMask(
		COLLISION.WORLD,
		COLLISION.OBSTACLES,
		COLLISION.SMALLOBSTACLES
	)
end

local function onthrown(inst)
    inst:AddTag("NOCLICK")
    inst.persists = false
    
    inst.AnimState:PlayAnimation("spin_loop", true)	
    inst.SoundEmitter:PlaySound("wolfgang1/dumbbell/throw_twirl", "spin_loop")

    inst.Physics:SetMass(1)
    inst.Physics:SetFriction(0)
    inst.Physics:SetDamping(0)
    inst.Physics:SetCollisionGroup(COLLISION.CHARACTERS)
	inst.Physics:SetCollisionMask(
		COLLISION.GROUND,
		COLLISION.OBSTACLES,
		COLLISION.ITEMS
	)
end

local AOE_ATTACK_MUST_TAGS = {"_combat", "_health"}
local AOE_ATTACK_NO_TAGS = {"FX", "NOCLICK", "DECOR", "INLIMBO"}
local function OnThrownHit(inst, attacker, target)
   

	local x, y, z = inst.Transform:GetWorldPosition()
	local ents = TheSim:FindEntities(x, y, z, 2, AOE_ATTACK_MUST_TAGS, AOE_ATTACK_NO_TAGS)

	for i, ent in ipairs(ents) do
        
	    if CanDamage(inst, ent, attacker) then
			if attacker ~= nil and attacker:IsValid() then
				attacker.components.combat.ignorehitrange = true
				attacker.components.combat:DoAttack(ent, inst, inst)
				attacker.components.combat.ignorehitrange = false
			else
				ent.components.combat:GetAttacked(attacker, inst.components.weapon.damage(inst, inst.components.complexprojectile.attacker, ent) )
			end
		end
	end

    SpawnPrefab("round_puff_fx_sm").Transform:SetPosition(inst.Transform:GetWorldPosition())
    
	inst.AnimState:PlayAnimation("land")
    

    inst:RemoveTag("NOCLICK")
    inst.persists = true

    inst.SoundEmitter:KillSound("spin_loop")
    inst.SoundEmitter:PlaySound("wolfgang1/dumbbell/stone_impact")
	inst.components.finiteuses:Use(1 * TUNING.DUMBBELL_THROWN_CONSUMPTION_MULT) 
    if inst.components.finiteuses:GetUses() > 0 then
        ResetPhysics(inst) 
    end
end

local MAX_USES = 200
local REPAIR_PER = 2
local function TryRepair(inst)
	local owner = inst.components.inventoryitem:GetGrandOwner()
	local skilltreepoint = 0
	if owner then
		local skilltreeupdater = owner.components.skilltreeupdater		
			if skilltreeupdater and owner.components.skilltreeupdater:IsActivated("mevileyes_itemregen") then skilltreepoint = 2 end
	end
	
    if inst.components.finiteuses then
        local current = inst.components.finiteuses:GetUses()
        if current < MAX_USES then
            local missing = MAX_USES - current
            local repair_needed = math.min(REPAIR_PER, missing)
            inst.components.finiteuses:Repair(repair_needed  + skilltreepoint)           
        end
    end
end

local function MakeTossable(inst)
    if not inst.components.complexprojectile then
        inst:AddComponent("complexprojectile")
        inst.components.complexprojectile:SetHorizontalSpeed(15)
        inst.components.complexprojectile:SetGravity(-35)
        inst.components.complexprojectile:SetLaunchOffset(Vector3(1, 1, 0))
        inst.components.complexprojectile:SetOnLaunch(onthrown)
        inst.components.complexprojectile:SetOnHit(OnThrownHit)
		inst.components.complexprojectile.ismeleeweapon = true
    end
end

local function RemoveTossable(inst)
    if inst.components.complexprojectile ~= nil then
        inst:RemoveComponent("complexprojectile")
    end
end

local function bodycheckfn(inst)
local owner = inst.components.inventoryitem.owner
	if owner and owner:HasTag("player") then 
		local body = owner.components.inventory:GetEquippedItem(EQUIPSLOTS.BODY)	
		if body and body.AnimState:BuildHasSymbol("swap_body_tall") then 
			return true
		end
	end
end

local function OnEquip(inst, owner)	
    owner.AnimState:Show("ARM_carry")
    owner.AnimState:Hide("ARM_normal")
	owner.AnimState:OverrideSymbol("swap_object", "swap_yukishigure", "swap_object")
	
	local skilltreeupdater = owner.components.skilltreeupdater
	if skilltreeupdater and owner.components.skilltreeupdater:IsActivated("mevileyes_katana_mobility") then 
		inst.components.equippable.walkspeedmult = 1.2		
	end
	
	if owner and owner.katanauser then 
		MakeTossable(inst)			
		inst.repairtask = inst:DoPeriodicTask(20, function() TryRepair(inst) end)
	else 
		RemoveTossable(inst)	
	end
	
	if not bodycheckfn(inst) then owner.AnimState:OverrideSymbol("swap_body_tall", "sc_yuki", "tail")end
	if owner and owner.katanauser and not inst:HasTag("mtachi") then inst:AddTag("mtachi") end	
	
	if owner and owner.unlockdeathaura and inst.components.planardamage == nil then	
		inst:AddComponent("planardamage")
		inst.components.planardamage:SetBaseDamage(10)
	end
end
  
local function OnUnequip(inst, owner)
	owner.AnimState:Hide("ARM_carry")
    owner.AnimState:Show("ARM_normal")
	
	if inst.repairtask then inst.repairtask:Cancel() inst.repairtask = nil end
	
	if inst.components.planardamage ~= nil then	
		inst:RemoveComponent("planardamage")		
	end
	
	local skilltreeupdater = owner.components.skilltreeupdater
	if skilltreeupdater and owner.components.skilltreeupdater:IsActivated("mevileyes_katana_mobility") then 
		inst.components.equippable.walkspeedmult = 1 
	end
	if owner and not bodycheckfn(inst) then owner.AnimState:ClearOverrideSymbol("swap_body_tall")end
	if owner and owner.katanauser and inst:HasTag("mtachi") then inst:RemoveTag("mtachi") end
end

local function castFn(inst, target)

local owner = inst.components.inventoryitem.owner
local body = owner.components.inventory:GetEquippedItem(EQUIPSLOTS.BODY)
local head = owner.components.inventory:GetEquippedItem(EQUIPSLOTS.HEAD)

if body then owner.components.inventory:DropItem(body) end
if head then owner.components.inventory:DropItem(head) end

local x,y,z = owner.Transform:GetWorldPosition()	
	local fx = SpawnPrefab("impact")
		fx.Transform:SetPosition(x,1,z)
		
owner.components.combat:GetAttacked(owner, 99999)   

inst.AnimState:PlayAnimation("land")   

end

local function Onfinish(inst)
	inst:Remove()
end

local function topocket(inst)
   inst.AnimState:PlayAnimation("anim")
end

local function fn()  
    local inst = CreateEntity()
	
    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddNetwork()	
    inst.entity:AddSoundEmitter()
    
	inst.entity:AddMiniMapEntity()
	inst.MiniMapEntity:SetIcon("yukishigure.tex")
	
	MakeInventoryPhysics(inst)  
      
    inst.AnimState:SetBank("yukishigure")
    inst.AnimState:SetBuild("yukishigure")
    inst.AnimState:PlayAnimation("anim")
	
	--inst:AddTag("sharp")    
	--inst:AddTag("keep_equip_toss")
	
	inst.spelltype = "SCIENCE"   
    inst:AddTag("quickcast")
    inst:AddTag("netra_item")
    
	MakeInventoryFloatable(inst)
	inst.components.floater:SetSize("small")
    inst.components.floater:SetVerticalOffset(0.1)
	
	inst.entity:SetPristine()
	
	inst:AddComponent("reticule")
    inst.components.reticule.targetfn = ReticuleTargetFn
	inst.components.reticule.shouldhidefn = ReticuleShouldHideFn
	inst.components.reticule.twinstickcheckscheme = true
	inst.components.reticule.twinstickmode = 1
	inst.components.reticule.twinstickrange = 8
    inst.components.reticule.ease = true
	
    if not TheWorld.ismastersim then
        return inst
    end      

    inst:AddComponent("weapon")	
	inst.components.weapon:SetDamage(34)
	
	inst:AddComponent("finiteuses")
    inst.components.finiteuses:SetMaxUses(MAX_USES)
    inst.components.finiteuses:SetUses(MAX_USES)
    inst.components.finiteuses:SetOnFinished(Onfinish)
	
    inst:AddComponent("inspectable")    
    inst:AddComponent("inventoryitem")
	
	inst:AddComponent("spellcaster")
    inst.components.spellcaster:SetSpellFn(castFn)
	inst.components.spellcaster.veryquickcast = true
    inst.components.spellcaster.canusefrominventory = true
	
    inst.components.inventoryitem.imagename = "yukishigure"
    inst.components.inventoryitem.atlasname = "images/inventoryimages/yukishigure.xml"	
	
	inst:AddComponent("equippable")
	inst.components.equippable:SetOnEquip( OnEquip )
    inst.components.equippable:SetOnUnequip( OnUnequip )	
	
	MakeHauntableLaunch(inst)

	inst:ListenForEvent("onputininventory", topocket)
	
    return inst
end

return  Prefab("common/inventory/yukishigure", fn, assets) 