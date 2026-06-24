local assets =
{
    Asset("ANIM", "anim/pocketwatch_portal_fx.zip"),
    Asset("ANIM", "anim/ui_board_5x3.zip"),
}

local _cancel_text = "Cancel"
local _ok_text = "OK"
if STRINGS ~= nil and STRINGS.UI ~= nil and STRINGS.UI.WRITEABLE ~= nil then
    _cancel_text = STRINGS.UI.WRITEABLE.CANCEL or _cancel_text
    _ok_text = STRINGS.UI.WRITEABLE.OK or _ok_text
end

require("writeables").AddLayout("npc_rift_portal",
{
    prompt = "Rename Rift",
    animbank = "ui_board_5x3",
    animbuild = "ui_board_5x3",
    menuoffset = Vector3(6, -70, 0),
    maxcharacters = 30,
    cancelbtn = {
        text = _cancel_text,
        cb = nil,
        control = CONTROL_CANCEL
    },
    acceptbtn = {
        text = _ok_text,
        cb = nil,
        control = CONTROL_ACCEPT
    },
})

local function onsave(inst, data)
    if inst.components.writeable ~= nil then
        local txt = inst.components.writeable:GetText()
        if txt ~= nil and txt ~= "" then
            data.rift_name = txt
        end
    end
end

local function onload(inst, data)
    if data ~= nil and data.rift_name ~= nil and data.rift_name ~= "" and inst.components.writeable ~= nil then
        inst.components.writeable:SetText(data.rift_name)
    end
    if inst.components.named ~= nil and inst.components.writeable ~= nil then
        local t = inst.components.writeable:GetText()
        inst.components.named:SetName((t ~= nil and t ~= "") and t or (STRINGS.NAMES.NPC_RIFT_PORTAL or "裂缝记忆点"))
    end
end

local function onwritten(inst, text, doer)
    if inst.components.writeable ~= nil and text ~= nil then
        local clean = string.gsub(text, "[\r\n\t|]", " ")
        inst.components.writeable:SetText(clean)
        if inst.components.named ~= nil then
            inst.components.named:SetName(clean)
        end
    end
end

local function getstatus(inst)
    if inst.components.writeable ~= nil then
        local txt = inst.components.writeable:GetText()
        if txt ~= nil and txt ~= "" then
            return txt
        end
    end
    return "RIFT"
end

local function fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()
    inst.entity:AddLight()
    inst.entity:AddNetwork()

    inst.AnimState:SetBank("pocketwatch_portal_fx")
    inst.AnimState:SetBuild("pocketwatch_portal_fx")
    inst.AnimState:PlayAnimation("portal_entrance_pre")
    inst.AnimState:PushAnimation("portal_entrance_loop", true)
    inst.AnimState:SetBloomEffectHandle("shaders/anim.ksh")
    inst.AnimState:SetSortOrder(-1)
    inst.AnimState:Hide("front")
    inst.AnimState:Hide("water_shadow")

    inst.Light:SetRadius(2.5)
    inst.Light:SetIntensity(0.6)
    inst.Light:SetFalloff(1.5)
    inst.Light:SetColour(1, 1, 1)
    inst.Light:Enable(true)
    inst.Light:EnableClientModulation(true)

    inst:AddTag("npc_rift_portal")
    inst:AddTag("scarytoprey")
    inst:AddTag("ignorewalkableplatforms")
    inst:AddTag("structure")
    inst:AddTag("_writeable")

    inst:SetPhysicsRadiusOverride(1)

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst:RemoveTag("_writeable")
    inst.persists = true

    inst:AddComponent("inspectable")
    inst.components.inspectable.getstatus = getstatus
    inst.displaynamefn = function(i)
        if i.components.writeable ~= nil then
            local t = i.components.writeable:GetText()
            if t ~= nil and t ~= "" then
                return t
            end
        end
        return STRINGS.NAMES.NPC_RIFT_PORTAL or "裂缝记忆点"
    end
    inst:AddComponent("named")
    inst.components.named:SetName(STRINGS.NAMES.NPC_RIFT_PORTAL or "裂缝记忆点")

    inst:AddComponent("writeable")
    
    inst.components.writeable:SetDefaultWriteable(false)
    inst.components.writeable:SetAutomaticDescriptionEnabled(false)
    inst.components.writeable:SetWriteableDistance(8)
    inst.components.writeable:SetOnWrittenFn(onwritten)

    inst:AddComponent("npcriftportal")

    inst.SoundEmitter:PlaySound("wanda2/characters/wanda/watch/portal_LP", "loop", 0.1)
    inst.OnSave = onsave
    inst.OnLoad = onload

    return inst
end

return Prefab("npc_rift_portal", fn, assets)
