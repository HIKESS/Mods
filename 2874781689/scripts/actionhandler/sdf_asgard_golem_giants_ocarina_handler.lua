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

local function HandleInstrumentAssets(inst, build, symbol)
    local inv_obj = inst.bufferedaction ~= nil and inst.bufferedaction.invobject or nil
    local override_build, override_symbol, override_sound
    if inv_obj and inv_obj.components.instrument then
        override_build, override_symbol, override_sound = inv_obj.components.instrument:GetAssetOverrides()
        inst.sg.statemem.sound = override_sound
    end

    inst.AnimState:OverrideSymbol(symbol, build, symbol)
    return inv_obj
end

sdf_asgard_golem_giants_ocarina_castaoe = State({
    name = "sdf_asgard_golem_giants_ocarina_castaoe",
    tags = { "doing", "busy", "canrotate" },
   		

        onenter = function(inst)

	    --animation
	    --inst.AnimState:OverrideSymbol("swap_object", "swap_sdf_anubis_stone", "swap_sdf_anubis_stone")

	    inst.sg:GoToState("castspell")
        end,

        timeline =
        {
        },

        events =
        {
        },

        onexit = function(inst)
        end,
})

sdf_asgard_golem_giants_ocarina_castaoe_client = State({
    name = "sdf_asgard_golem_giants_ocarina_castaoe",
    tags = { "doing", "busy", "canrotate" },
    server_states = { "castspell" },

        onenter = function(inst)
	    inst.sg:GoToState("castspell")
        end,

        onupdate = function(inst)
        end,

        ontimeout = function(inst)
        end,
})

sdf_asgard_golem_giants_ocarina_play = State({
    name = "sdf_asgard_golem_giants_ocarina_play",
    tags = { "doing", "busy", "playing" },
   		

        onenter = function(inst)
            inst.components.locomotor:Stop()
            inst.AnimState:PlayAnimation("action_uniqueitem_pre")
            inst.AnimState:PushAnimation("flute", false)
            local inv_obj = HandleInstrumentAssets(inst, "sdf_asgard_golem_giants_ocarina", "pan_flute01")
            inst.components.inventory:ReturnActiveActionItem(inv_obj)
        end,

        timeline =
        {
            TimeEvent(30 * FRAMES, function(inst)
                if inst:PerformBufferedAction() then
                    inst.SoundEmitter:PlaySound(inst.sg.statemem.sound or "dontstarve/wilson/flute_LP", "flute")
                else
		    inst.sg.statemem.action_failed = true
		    inst.AnimState:SetFrame(94)
                end
            end),
	    TimeEvent(36 * FRAMES, function(inst)
		if inst.sg.statemem.action_failed then
		    inst.sg:RemoveStateTag("busy")
		end
	    end),
	    TimeEvent(52 * FRAMES, function(inst) -- NOTES(JBK): Keep FRAMES in sync with panflute. [PFSSTS]
		if not inst.sg.statemem.action_failed then
		    inst.sg:RemoveStateTag("busy")
		end
	    end),
            TimeEvent(85 * FRAMES, function(inst)
		if not inst.sg.statemem.action_failed then
		    inst.SoundEmitter:KillSound("flute")
		end
            end),
        },

        events =
        {
            EventHandler("animqueueover", function(inst)
                if inst.AnimState:AnimDone() then
                    inst.sg:GoToState("idle")
                end
            end),
        },

        onexit = function(inst)
            inst.SoundEmitter:KillSound("flute")
	    inst.AnimState:ClearOverrideSymbol("sdf_asgard_golem_giants_ocarina") --pan_flute01")
        end,
})

sdf_asgard_golem_giants_ocarina_play_client = State({
    name = "sdf_asgard_golem_giants_ocarina_play",
    tags = { "play_flute" },
    server_states = { "sdf_asgard_golem_giants_ocarina_play" },

    forward_server_states = true,
    onenter = function(inst) inst.sg:GoToState("action_uniqueitem_busy") end,

})

--------------------------------------------WILSON SG ACTIONHANDLER FOR ATTACK OVERRIDE---------------------------------------------------------------------------
AddStategraphState("wilson", sdf_asgard_golem_giants_ocarina_castaoe)
AddStategraphState("wilson_client", sdf_asgard_golem_giants_ocarina_castaoe_client)
AddStategraphState("wilson", sdf_asgard_golem_giants_ocarina_play)
AddStategraphState("wilson_client", sdf_asgard_golem_giants_ocarina_play_client)

--------------------------------------------WILSON SG ACTIONHANDLER FOR ATTACK OVERRIDE---------------------------------------------------------------------------

AddStategraphPostInit('wilson', function(self)
    overwrite(self.actionhandlers[ACTIONS.CASTAOE], "deststate", function(inst, action)
    if action.invobject and action.invobject.prefab == "sdf_asgard_golem_giants_ocarina" then 
	return "sdf_asgard_golem_giants_ocarina_castaoe"
    end 
    end)
end)

AddStategraphPostInit('wilson_client', function(self)
    overwrite(self.actionhandlers[ACTIONS.CASTAOE], "deststate", function(inst, action)
    if action.invobject and action.invobject.prefab == "sdf_asgard_golem_giants_ocarina" then 
	return "sdf_asgard_golem_giants_ocarina_castaoe"
    end 
    end)
end)

AddStategraphPostInit('wilson', function(self)
    overwrite(self.actionhandlers[ACTIONS.PLAY], "deststate", function(inst, action)
    if action.invobject and action.invobject.prefab == "sdf_asgard_golem_giants_ocarina" then 
	return "sdf_asgard_golem_giants_ocarina_play"
    end 
    end)
end)

AddStategraphPostInit('wilson_client', function(self)
    overwrite(self.actionhandlers[ACTIONS.PLAY], "deststate", function(inst, action)
    if action.invobject and action.invobject.prefab == "sdf_asgard_golem_giants_ocarina" then 
	return "sdf_asgard_golem_giants_ocarina_play"
    end 
    end)
end)
---------------------------------------------------------------------------------------------------------------------------------

---------------------------------------------------------------------------------------------------------------------------------

--Explores Caves
local function SDFAsgardGolemExploreSinkhole(inst)
    if not GLOBAL.TheWorld.ismastersim then
	return
    end   

    if not inst.components.sdf_asgard_golem_beckon then
	inst:AddComponent("sdf_asgard_golem_beckon")
    end
    inst.components.sdf_asgard_golem_beckon:AddPrefabToList("sdf_asgard_golem")
end
AddPlayerPostInit(SDFAsgardGolemExploreSinkhole)