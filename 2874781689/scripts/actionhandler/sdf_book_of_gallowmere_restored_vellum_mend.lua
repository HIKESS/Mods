GLOBAL.setmetatable(env,{__index=function(a,b)return GLOBAL.rawget(GLOBAL,b)end})

--Repair Book of Gallowmere Entries
local ACTIONS = GLOBAL.ACTIONS
local ActionHandler = GLOBAL.ActionHandler

local id = "SDF_BOOK_OF_GALLOWMERE_RESTORED_VELLUM_MEND"
local name = STRINGS.ACTIONHANDLER_SDF_BOOK_OF_GALLOWMERE_RESTORED_VELLUM_MEND


local fn = function(act)

    if act.target.prefab == "sdf_book_of_gallowmere_entries_inventory" or act.target.prefab == "sdf_book_of_gallowmere_entries_friendlies" or act.target.prefab == "sdf_book_of_gallowmere_entries_enemies" or act.target.prefab == "sdf_book_of_gallowmere_entries_bosses" then

	if act.target.components.finiteuses then
	    if act.invobject.components.sdf_book_of_gallowmere_restored_vellum_mend then
		local currentPercent = act.target.components.finiteuses:GetPercent()
		if currentPercent < 1 then	

		    --Repair Entries
		    act.target.components.finiteuses:Repair(TUNING.SDF_BOOK_OF_GALLOWMERE_RESTORED_VELLUM_MEND)

		    --Repair Sound
		    act.doer.SoundEmitter:PlaySound("wickerbottom_rework/book_spells/upgraded_horticulture")

		    --Remove restored vellum item
		    local num=act.invobject.components.stackable and
		    act.invobject.components.stackable:StackSize() or 1
		    if num>1 then
			act.invobject.components.stackable:SetStackSize(num-1)
		    else
			act.invobject:Remove()
		    end

		    return true
		else
		    if act.doer.components.talker then
			act.doer.components.talker:Say(GetString(act.doer, "ANNOUNCE_RESTOREDVELLUMNOMEND"))
			return true
		    end
		end
	    end
	end
    end
    return false
end

AddAction(id,name,fn)

local type = "USEITEM"
local component = "sdf_book_of_gallowmere_restored_vellum_mend"
local testfn = function(inst, doer, target, actions)
    if target:HasTag("sdf_book_of_gallowmere_restored_vellum_mend") then
	table.insert(actions, ACTIONS.SDF_BOOK_OF_GALLOWMERE_RESTORED_VELLUM_MEND)
    end
end

AddComponentAction(type, component, testfn)

local state = "dolongaction"
AddStategraphActionHandler("wilson",ActionHandler(ACTIONS.SDF_BOOK_OF_GALLOWMERE_RESTORED_VELLUM_MEND, state))
AddStategraphActionHandler("wilson_client",ActionHandler(ACTIONS.SDF_BOOK_OF_GALLOWMERE_RESTORED_VELLUM_MEND,state))