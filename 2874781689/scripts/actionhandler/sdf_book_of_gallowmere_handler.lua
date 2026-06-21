local unpack = unpack or table.unpack or GLOBAL.unpack
local Vector3 = GLOBAL.Vector3
local DEGREES = GLOBAL.DEGREES

local function results(data, ...)
    return type(data) == "function" and {data(...)}  
	or type(data) == "table" and data 
	or {data} 
end 

local function sandwich(func, ante, post)	
    return function(...)
	local results_ante = results(ante, ...)
	if #results_ante > 0 then
	    return unpack(results_ante)
	end 		
		
	local results_original = results(func, ...)
	local results_post = results(post, ...)

	if #results_post > 0 then
	    return unpack(results_post)
	end 
		
	return unpack(results_original)
    end 
end 

local function overwrite(tabula, name, ante, post, ifnil)
    if type(tabula) ~= "table" then
	return
    end 
    local old = tabula[name]
    if old == nil and ifnil ~= nil then
	old = ifnil
    end 
    tabula[name] = sandwich(old, ante, post)
end 

sdf_book_of_gallowmere_close = State({
    name = "sdf_book_of_gallowmere_close",
    tags = { "idle", "nodangle" },
   		

        onenter = function(inst)
            inst.components.locomotor:StopMoving()
            inst.AnimState:PlayAnimation("reading_pst")

	    local BookOfGallowmereItem = inst.components.inventory:GetEquippedItem(EQUIPSLOTS.HANDS)
	    if BookOfGallowmereItem then
		if BookOfGallowmereItem.prefab == "sdf_book_of_gallowmere" then
		    BookOfGallowmereItem:ModeReadingEndFn()
		end
	    end

	    --remove reader tags
	    if inst:HasTag("sdf_book_of_gallowmere_entries_inventory_read") then
		inst:RemoveTag("sdf_book_of_gallowmere_entries_inventory_read")
	    end
	    if inst:HasTag("sdf_book_of_gallowmere_entries_friendlies_read") then
		inst:RemoveTag("sdf_book_of_gallowmere_entries_friendlies_read")
	    end
	    if inst:HasTag("sdf_book_of_gallowmere_entries_enemies_read") then
		inst:RemoveTag("sdf_book_of_gallowmere_entries_enemies_read")
	    end
	    if inst:HasTag("sdf_book_of_gallowmere_entries_bosses_read") then
		inst:RemoveTag("sdf_book_of_gallowmere_entries_bosses_read")
	    end

        end,

        events =
        {
            EventHandler("animover", function(inst)
                if inst.AnimState:AnimDone() then
		    inst.sg:GoToState(inst.components.inventory:GetEquippedItem(EQUIPSLOTS.HANDS) ~= nil and "item_out" or "idle")
                end
            end),
        },
})

sdf_book_of_gallowmere_open = State({
    name = "sdf_book_of_gallowmere_open",
    tags = { "doing", "busy" },
   		

        onenter = function(inst)
            inst.components.locomotor:StopMoving()
            inst.AnimState:OverrideSymbol("book_cook", "sdf_book_of_gallowmere_read", "book_cook")
            inst.AnimState:PlayAnimation("action_uniqueitem_pre")
            inst.AnimState:PushAnimation("reading_in", false)
            inst.AnimState:PushAnimation("reading_loop", true)


	    local BookOfGallowmereItem = inst.components.inventory:GetEquippedItem(EQUIPSLOTS.HANDS)
	    if BookOfGallowmereItem then
		if BookOfGallowmereItem.prefab == "sdf_book_of_gallowmere" then
		    BookOfGallowmereItem:ModeReadingStartFn()
		end
	    end

	    --inst:ShowPopUp(POPUPS.SDFBOOKOFGALLOWMERE, true)

        end,

        timeline =
        {
            TimeEvent(8 * FRAMES, function(inst)
		inst.sg:RemoveStateTag("busy")
                inst:PerformBufferedAction()
            end),
        },

	    onupdate = function(inst)
		if not CanEntitySeeTarget(inst, inst) then
		    inst.sg:GoToState("sdf_book_of_gallowmere_close")
		end
	    end,

        events =
        {
            EventHandler("ms_closepopup", function(inst, data)
                if data.popup == POPUPS.SDFBOOKOFGALLOWMERE then
                    inst.sg:GoToState("sdf_book_of_gallowmere_close")
                end
            end),
        },

        onexit = function(inst)
	    inst:ShowPopUp(POPUPS.SDFBOOKOFGALLOWMERE, false)
        end,
})

sdf_book_of_gallowmere_open_client = State({
    name = "sdf_book_of_gallowmere_open",
    tags = { "doing", "busy" },
    server_states = { "sdf_book_of_gallowmere_open" },

    forward_server_states = true,
    onenter = function(inst) inst.sg:GoToState("action_uniqueitem_busy") end,
})


--------------------------------------------WILSON SG ACTIONHANDLER FOR ATTACK OVERRIDE---------------------------------------------------------------------------
AddStategraphState("wilson", sdf_book_of_gallowmere_open)
AddStategraphState("wilson", sdf_book_of_gallowmere_close)
AddStategraphState("wilson_client", sdf_book_of_gallowmere_open_client)

--------------------------------------------WILSON SG ACTIONHANDLER FOR ATTACK OVERRIDE---------------------------------------------------------------------------

AddStategraphPostInit('wilson', function(self)
    overwrite(self.actionhandlers[ACTIONS.READ], "deststate", function(inst, action)
    if action.invobject and (action.invobject.prefab == "sdf_book_of_gallowmere_entries_inventory" or action.invobject.prefab == "sdf_book_of_gallowmere_entries_friendlies" or
	action.invobject.prefab == "sdf_book_of_gallowmere_entries_enemies" or action.invobject.prefab == "sdf_book_of_gallowmere_entries_bosses") then 
	return "sdf_book_of_gallowmere_open"
    end 
    end)
end)

AddStategraphPostInit('wilson_client', function(self)
    overwrite(self.actionhandlers[ACTIONS.READ], "deststate", function(inst, action)
    if action.invobject and (action.invobject.prefab == "sdf_book_of_gallowmere_entries_inventory" or action.invobject.prefab == "sdf_book_of_gallowmere_entries_friendlies" or
	action.invobject.prefab == "sdf_book_of_gallowmere_entries_enemies" or action.invobject.prefab == "sdf_book_of_gallowmere_entries_bosses") then 
	return "sdf_book_of_gallowmere_open"
    end 
    end)
end)