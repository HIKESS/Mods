GLOBAL.setmetatable(GLOBAL.getfenv(1), {__index = function(self, index)
	return GLOBAL.rawget(GLOBAL, index)
end})-- ty penguin

local unpack = unpack or table.unpack or GLOBAL.unpack

local function results(data, ...)
	return type(data) == "function" and {data(...)}  
		or type(data) == "table" and data 
		or {data} 
end 

local function sandwich(func, ante, post)	
	return function(...)
		local results_ante = results(ante, ...)
		if #results_ante > 0 then return unpack(results_ante) end 		
		
		local results_original = results(func, ...)
		
		local results_post = results(post, ...)
		if #results_post > 0 then return unpack(results_post) end 
		
		return unpack(results_original)
	end 
end 

local function overwrite(tabula, name, ante, post, ifnil)
	if type(tabula) ~= "table" then return end 
	local old = tabula[name]
	if old == nil and ifnil ~= nil then old = ifnil end 
	tabula[name] = sandwich(old, ante, post)
end 

if not GLOBAL.TheNet:GetIsMasterSimulation() then return end

AddPrefabPostInit("armorskeleton", function(inst)
	overwrite(inst.components.equippable, "onequipfn", nil, function(inst, owner)
	
		if inst.components.fueled and inst.components.fueled:IsEmpty() then 
			return 
		end 
		
		overwrite(inst.components.cooldown, "onchargedfn", function(inst)
			if inst.forcefieldfx then 
				inst.forcefieldfx = inst.forcefieldfx:Remove()
			end 
			
			if inst.components.fueled and inst.components.fueled:IsEmpty() then 
				return 
			end 
			
			inst.forcefieldfx = SpawnPrefab"forcefieldfx"
			inst.forcefieldfx.Light:Enable(false)
			inst.forcefieldfx.entity:SetParent(owner.entity)
			inst.forcefieldfx.AnimState:SetMultColour(0, 0, 0, 0.35)
		end)
	end)
	
	overwrite(inst.components.equippable, "onunequipfn", function(inst, owner)
		if inst.forcefieldfx then 
			inst.forcefieldfx = inst.forcefieldfx:Remove()
		end 
	end)
	
	overwrite(inst.components.cooldown, "startchargingfn", function(inst)
		if inst.forcefieldfx then 
			inst.forcefieldfx = inst.forcefieldfx:Remove()
		end 
	end)
end)
