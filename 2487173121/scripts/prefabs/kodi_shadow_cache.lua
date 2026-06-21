local assets = {}
local prefabs = {}
local function OnOpen(inst, data)
    inst._current_owner = data.doer
end
local function OnClose(inst)
    inst._current_owner = nil
end
local function fn()
    local inst = CreateEntity()
    inst.entity:AddTransform()
    inst.entity:AddNetwork()
    inst:AddTag("shadow_cache_container")
    inst:AddTag("NOCLICK")
    inst.name = " "
    inst.entity:SetPristine()
    if not TheWorld.ismastersim then
        return inst
    end
    inst._current_owner = nil
    inst:AddComponent("container")
    inst.components.container:WidgetSetup("kodi_shadow_cache")
    inst:ListenForEvent("onopen", OnOpen)
    inst:ListenForEvent("onclose", OnClose)
    inst.persists = false
    return inst
end
return Prefab("kodi_shadow_cache", fn, assets, prefabs)
