SDF_RUNE_HOLDERFUNCS = {}

local function mywidgetsetup(container, prefab, data)
    local t = data
    if t ~= nil then
        for k, v in pairs(t) do
            container[k] = v
        end
        container:SetNumSlots(container.widget.slotpos ~= nil and #container.widget.slotpos or 0)
    end
end

local widgetprops =
{
    "numslots",
    "acceptsstacks",
    "issidewidget",
    "type",
    "widget",
    "itemtestfn",
}

function SDF_RUNE_HOLDERFUNCS.MyWidgetSetup(self, prefab, data)
    for i, v in ipairs(widgetprops) do
	removesetter(self, v)
    end

    mywidgetsetup(self, prefab, data)
    self.inst.replica.container:WidgetSetup(prefab, data)

    for i, v in ipairs(widgetprops) do
        makereadonly(self, v)
    end
end

function SDF_RUNE_HOLDERFUNCS.MyWidgetSetup_replica(self, prefab, data)
    mywidgetsetup(self, prefab, data)
    if self.classified ~= nil then
        self.classified:InitializeSlots(self:GetNumSlots())
    end
    if self.issidewidget then
        if self._onputininventory == nil then
            self._owner = nil
            self._ondropped = function(inst)
                if self._owner ~= nil then
                    local owner = self._owner
                    self._owner = nil
                    if owner.HUD ~= nil then
                        owner:PushEvent("refreshcrafting")
                    end
                end
            end
            self._onputininventory = function(inst, owner)
                self._ondropped(inst)
                self._owner = owner
                if owner ~= nil and owner.HUD ~= nil then
                    owner:PushEvent("refreshcrafting")
                end
            end
        end
    end
end