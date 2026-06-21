local assets =
{
    Asset("ANIM", "anim/mevileyes_atk_fx1.zip"),
    Asset("ANIM", "anim/mevileyes_atk_fx2.zip"),
    Asset("ANIM", "anim/mevileyes_atk_fx3.zip"),
	Asset("ANIM", "anim/iaislash_fx.zip"),
	Asset("ANIM", "anim/mevileyes_skill7_fx.zip"),
}

local function fn1()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddNetwork()
	inst.entity:AddSoundEmitter()
	
    inst.Transform:SetScale(2, 2, 2)

    inst.AnimState:SetBank("mevileyes_atk_fx1")
    inst.AnimState:SetBuild("mevileyes_atk_fx1")
    inst.AnimState:PlayAnimation("anim", false)
    inst.AnimState:SetMultColour(255/255, 25/255, 25/255, .7)
    inst.AnimState:SetBloomEffectHandle("shaders/anim.ksh") 

    inst:AddTag("FX")
    inst:AddTag("NOBLOCK")

    inst.entity:SetPristine()

    inst.persists = false

    if not TheWorld.ismastersim then
        return inst
    end
	
	inst.SoundEmitter:PlaySound("dontstarve/tentacle/tentacle_attack")
	
    inst:ListenForEvent("animover", function(inst) inst:Remove() end)

    return inst
end

local function fn2()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddNetwork()
	inst.entity:AddSoundEmitter()

    inst.Transform:SetScale(1, 1, 1)

    inst.AnimState:SetBank("mevileyes_atk_fx2")
    inst.AnimState:SetBuild("mevileyes_atk_fx2")
    inst.AnimState:PlayAnimation("anim", false)
    inst.AnimState:SetMultColour(255/255, 25/255, 25/255, .7)
    inst.AnimState:SetBloomEffectHandle("shaders/anim.ksh")
	inst.AnimState:SetDeltaTimeMultiplier(2)

    inst:AddTag("FX")
    inst:AddTag("NOBLOCK")

    inst.entity:SetPristine()

    inst.persists = false

    if not TheWorld.ismastersim then 
        return inst
    end
	inst.SoundEmitter:PlaySound("dontstarve/creatures/spiderqueen/swipe")	
    inst:ListenForEvent("animover", function(inst) inst:Remove() end)

    return inst
end

local function fn3()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddNetwork()
	inst.entity:AddSoundEmitter()

    inst.Transform:SetScale(2.5, 2.5, 2.5)

    inst.AnimState:SetBank("mevileyes_atk_fx3")
    inst.AnimState:SetBuild("mevileyes_atk_fx3")
    inst.AnimState:PlayAnimation("anim", false)
    inst.AnimState:SetMultColour(255/255, 25/255, 25/255, .7)
    inst.AnimState:SetBloomEffectHandle("shaders/anim.ksh")
	inst.AnimState:SetDeltaTimeMultiplier(1.2)

    inst:AddTag("FX")
    inst:AddTag("NOBLOCK")

    inst.entity:SetPristine()

    inst.persists = false

    if not TheWorld.ismastersim then
        return inst
    end
	inst.SoundEmitter:PlaySound("dontstarve/tentacle/tentacle_attack")
	--inst:DoTaskInTime(.1, function(inst) inst.SoundEmitter:PlaySound("dontstarve/tentacle/tentacle_attack")  end)	
	inst:DoTaskInTime(.2, function(inst) inst.SoundEmitter:PlaySound("dontstarve/tentacle/tentacle_attack")  end)
	inst:DoTaskInTime(.3, function(inst) inst.SoundEmitter:PlaySound("dontstarve/creatures/spiderqueen/swipe") end)
	
    inst:ListenForEvent("animover", function(inst) inst:Remove() end)

    return inst
end

local function ontornadolifetime(inst)
    inst.task = nil
    inst.AnimState:PlayAnimation("tornado_pst")
	inst:ListenForEvent("animover", function(inst) inst:Remove() end)
end

local function SetDuration(inst, duration)
    if inst.task ~= nil then
        inst.task:Cancel()
    end
    inst.task = inst:DoTaskInTime(duration, ontornadolifetime)
end

local function tornadofx_fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddNetwork()
	inst.entity:AddSoundEmitter()

    inst.Transform:SetScale(2.5, 2.5, 2.5)

    inst.AnimState:SetFinalOffset(2)
    inst.AnimState:SetBank("tornado")
    inst.AnimState:SetBuild("tornado")
    inst.AnimState:PlayAnimation("tornado_pre")
    inst.AnimState:PushAnimation("tornado_loop")
	inst.AnimState:SetMultColour(.1, .1, 0, 1)

    inst.SoundEmitter:PlaySound("dontstarve_DLC001/common/tornado", "spinLoop")
   
    inst:AddTag("FX")
    inst:AddTag("NOBLOCK")
		
    inst.entity:SetPristine()
	
    if not TheWorld.ismastersim then
        return inst
    end
	
	inst.persists = false
	
	inst.SetDuration = SetDuration
    inst:SetDuration(1)
	
    return inst
end

local function OnShockwave()
	local inst = CreateEntity()

	inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddNetwork()
	inst.entity:AddSoundEmitter()

	inst.AnimState:SetBank("mushroombomb_base")
	inst.AnimState:SetBuild("mushroombomb_base")
	inst.AnimState:PlayAnimation("idle")
	inst.AnimState:SetOrientation(ANIM_ORIENTATION.OnGround)
	inst.AnimState:SetLayer(LAYER_BACKGROUND)
	inst.AnimState:SetSortOrder(3)
	inst.AnimState:SetFinalOffset(3)
	--inst.AnimState:SetScale(5, 5)
	inst.AnimState:SetMultColour(0, 0, 0, .5)
	
	inst:AddTag("FX")
	inst:AddTag("NOBLOCK")
	
	inst.entity:SetPristine()
	inst.persists = false
	
	if not TheWorld.ismastersim then
        return inst
    end
	inst.SoundEmitter:PlaySound("dontstarve/common/ghost_spawn")
	inst.SoundEmitter:PlaySound("maxwell_rework/shadow_trap/explode")
	inst.SoundEmitter:PlaySound("maxwell_rework/shadow_trap/trigger_out")
	
    inst:ListenForEvent("animover", function(inst) inst:Remove() end)
	--inst.entity:SetParent(inst.entity)    
	return inst	
end

local sounds = {   
	"rifts2/thrall_generic/vocalization_big",
	"rifts2/thrall_generic/vocalization_small"    
}
	
local function DoTalk(inst, side)	
	
	if inst.talktask ~= nil then
		inst.talktask:Cancel()
		inst.talktask = nil
	end
	local voice = side and TUNING.MEVILEYES_ITEM_VOICE_GOOD or TUNING.MEVILEYES_ITEM_VOICE_BAD
	local delay = side and TUNING.VOIDCLOTH_SCYTHE_TALK_INTERVAL*1.5 or (TUNING.VOIDCLOTH_SCYTHE_TALK_INTERVAL/2)
	local text = voice[math.random(#voice)]
	local _sound = sounds[math.random(#sounds)]
	
	inst.components.talker:Say(text,3, true)  
	inst.SoundEmitter:PlaySound(_sound)
	inst.talktask = inst:DoTaskInTime(delay, inst.DoTalk, inst.side) --loop
end

local function DoSmallTalk(inst)	
	
	local voice = TUNING.MEVILEYES_ITEM_VOICE_SMALLTALK
	local text = voice[math.random(#voice)]
	local _sound = sounds[math.random(#sounds)]
	
	inst.components.talker:Say(text,3, true)  
	inst.SoundEmitter:PlaySound(_sound)	
end

local function DoWord(inst, word, sec)	
	--local _sound = sounds[math.random(#sounds)]
	
	inst.components.talker:Say(word, sec or 1, true)  
	--inst.SoundEmitter:PlaySound(_sound)	
end

local function ToggleTalking(inst, turnon)
    if inst.talktask ~= nil then
        inst.talktask:Cancel()
        inst.talktask = nil
    end

    if turnon then       
        DoTalk(inst, inst.side)
    end
end

local function voicefn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddNetwork()
	inst.entity:AddSoundEmitter()
	
    inst:AddTag("FX")
	
    inst.entity:SetPristine()
	
	local talker = inst:AddComponent("talker")
    talker.fontsize = 28
    talker.font = TALKINGFONT_WORMWOOD
    talker.colour = Vector3(143/255, 41/255, 41/255)
    talker.offset = Vector3(0, 0, 0)

    if not TheWorld.ismastersim then
        return inst
    end
	
	inst.side = true
	inst.DoTalk = DoTalk
	inst.ToggleTalking = ToggleTalking
	inst.DoSmallTalk = DoSmallTalk
	inst.DoWord = DoWord
    return inst
end

local function blackvoicefn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddNetwork()
	inst.entity:AddSoundEmitter()
	
    inst:AddTag("FX")
	
    inst.entity:SetPristine()
	
	local talker = inst:AddComponent("talker")
    talker.fontsize = 32
    talker.font = TALKINGFONT
    talker.colour = Vector3(1, 1, 1)
    talker.offset = Vector3(0, 0, 0)

    if not TheWorld.ismastersim then
        return inst
    end
	
	inst.DoWord = DoWord
    return inst
end

local function iaislashfn()
	local inst = CreateEntity()

	inst.entity:AddTransform()
	inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()	
	inst.entity:AddNetwork()

	inst:AddTag("FX")
	inst:AddTag("NOCLICK")
	
	inst.AnimState:SetBank("iaislash_fx")
	inst.AnimState:SetBuild("iaislash_fx")
	inst.AnimState:PlayAnimation("idle_"..math.random(1,3))
	--inst.AnimState:PlayAnimation("idle_3")
	inst.AnimState:SetOrientation(ANIM_ORIENTATION.OnGround)
	inst.AnimState:SetFinalOffset(7)
	inst.AnimState:SetScale(1.5,1.5)
	inst.AnimState:SetMultColour(1, 1, 1, .8) 
	inst.entity:SetPristine()

	if not TheWorld.ismastersim then
		return inst
	end
	
	inst:ListenForEvent("animover", inst.Remove)
	inst.persists = false
	
	return inst
end

local function iaislashfn2()
	local inst = CreateEntity()

	inst.entity:AddTransform()
	inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()	
	inst.entity:AddNetwork()

	inst:AddTag("FX")
	inst:AddTag("NOCLICK")
	
	inst.AnimState:SetBank("iaislash_fx")
	inst.AnimState:SetBuild("iaislash_fx")
	--inst.AnimState:PlayAnimation("idle_"..math.random(1,3))
	inst.AnimState:PlayAnimation("idle_4")
	inst.AnimState:SetOrientation(ANIM_ORIENTATION.OnGround)
	inst.AnimState:SetFinalOffset(7)
	inst.AnimState:SetScale(1.5,1.5)
	inst.AnimState:SetMultColour(1, 1, 1, .8) 
	inst.entity:SetPristine()

	if not TheWorld.ismastersim then
		return inst
	end
	
	inst:ListenForEvent("animover", inst.Remove)
	inst.persists = false
	
	return inst
end

local function skill7fxfn()    
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddNetwork()
	inst.entity:AddSoundEmitter()
	
    inst.entity:AddFollower()

    inst.Transform:SetNoFaced() 
    inst.Transform:SetScale(2, 2, 2) 
    inst.AnimState:SetBank("mevileyes_skill7_fx")
	inst.AnimState:SetBuild("mevileyes_skill7_fx")
    inst.AnimState:PlayAnimation("idle")
	inst.AnimState:SetDeltaTimeMultiplier(1.2)
    inst:AddTag("FX")

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

	inst.SoundEmitter:PlaySound("dontstarve/tentacle/tentacle_attack")
	inst.SoundEmitter:PlaySound("turnoftides/common/together/moon_glass/mine")
	inst:DoTaskInTime(.1, function(inst) inst.SoundEmitter:PlaySound("dontstarve/tentacle/tentacle_attack") inst.SoundEmitter:PlaySound("turnoftides/common/together/moon_glass/mine") end)
	inst:DoTaskInTime(.3, function(inst) inst.SoundEmitter:PlaySound("dontstarve/tentacle/tentacle_attack") inst.SoundEmitter:PlaySound("turnoftides/common/together/moon_glass/mine") end)
	inst:DoTaskInTime(.5, function(inst) inst.SoundEmitter:PlaySound("dontstarve/tentacle/tentacle_attack") inst.SoundEmitter:PlaySound("turnoftides/common/together/moon_glass/mine") end)
	inst:DoTaskInTime(.6, function(inst) inst.SoundEmitter:PlaySound("dontstarve/tentacle/tentacle_attack") inst.SoundEmitter:PlaySound("turnoftides/common/together/moon_glass/mine") end)
	inst:DoTaskInTime(.9, function(inst) inst.SoundEmitter:PlaySound("dontstarve/tentacle/tentacle_attack") inst.SoundEmitter:PlaySound("turnoftides/common/together/moon_glass/mine")end)
	inst:DoTaskInTime(1, function(inst)  inst.AnimState:SetDeltaTimeMultiplier(1) inst.SoundEmitter:PlaySound("dontstarve/tentacle/tentacle_attack") inst.SoundEmitter:PlaySound("turnoftides/common/together/moon_glass/mine")end)
	inst:DoTaskInTime(1.2, function(inst) inst.SoundEmitter:PlaySound("dontstarve/tentacle/tentacle_attack") inst.SoundEmitter:PlaySound("turnoftides/common/together/moon_glass/mine")end)
	inst:DoTaskInTime(1.5, function(inst) inst.SoundEmitter:PlaySound("dontstarve/tentacle/tentacle_attack") inst.SoundEmitter:PlaySound("turnoftides/common/together/moon_glass/mine")end)
	inst:DoTaskInTime(1.8, function(inst) inst.SoundEmitter:PlaySound("dontstarve/tentacle/tentacle_attack") inst.SoundEmitter:PlaySound("turnoftides/common/together/moon_glass/mine") end)
	
    inst:ListenForEvent("animover", inst.Remove)

    return inst
end

local function blackpulsefxfn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()
    inst.entity:AddNetwork()

    inst:AddTag("FX")
    inst:AddTag("NOCLICK")

    inst.AnimState:SetBank("moon_altar_geyser")
    inst.AnimState:SetBuild("moon_geyser")
    inst.AnimState:PlayAnimation("moonpulse")
    inst.AnimState:SetBloomEffectHandle("shaders/anim.ksh")
    inst.AnimState:SetMultColour(0, 0, 0, 1)

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst:ListenForEvent("animover", inst.Remove)

    return inst
end

local function blackbreakfxfn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()
    inst.entity:AddNetwork()

    inst:AddTag("FX")
    inst:AddTag("NOCLICK")

    inst.AnimState:SetBank("crabking_ring_fx")
    inst.AnimState:SetBuild("crabking_ring_fx")
    inst.AnimState:PlayAnimation("idle")
    inst.AnimState:SetOrientation(ANIM_ORIENTATION.OnGround)
    inst.AnimState:SetLayer(LAYER_BACKGROUND)
    inst.AnimState:SetMultColour(0, 0, 0, .7)

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst:ListenForEvent("animover", inst.Remove)

    return inst
end

return 	Prefab("mevileyes_atk_fx1", fn1, assets),
    Prefab("mevileyes_atk_fx2", fn2, assets),    
    Prefab("mevileyes_atk_fx3", fn3, assets),
    Prefab("mevileyes_spin_fx", tornadofx_fn),
    Prefab("mevileyes_shockwave_fx", OnShockwave),
	Prefab("mevileyes_whisper", voicefn),
	Prefab("mevileyes_whisper2", blackvoicefn),
	Prefab("mevileyes_iaislash_fx", iaislashfn, assets),
	Prefab("mevileyes_iaislash_fx2", iaislashfn2, assets),
	Prefab("mevileyes_skill7_fx", skill7fxfn, assets),
	Prefab("mevileyes_black_pulse", blackpulsefxfn, assets),
	Prefab("mevileyes_black_break", blackbreakfxfn, assets)