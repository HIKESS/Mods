-- Items skins (original code by Ysovuka/Kzisor)
-- Updated by <default> on 29.01.2023 to support new crafting menu (redux)

local RedItem = {
    --wiltonmod_shoot = true,
}

-- 自定义物品皮肤名字颜色映射表
-- key 为皮肤 prefab 名（去掉 _none 后），value 为 {r, g, b, a}
-- 仅用于合成界面皮肤选择下拉的文字颜色显示，不影响实际稀有度
local SkinNameColors = {
    wiltonmod_sharpbone_stonesword = {1, 0, 0, 1},     -- 石剑（尖骨头皮肤）：红色
    wiltonmod_bonehammer_skin      = {1, 0, 0, 1},     -- 化石骨棒 fossil_bone_rod（大骨棒皮肤）：红色
    wiltonmod_staff3_skin          = {0, 0.5, 1, 1},   -- sushengscepter（苏生权杖皮肤）：蓝色
    wiltonmod_staff1_skin          = {0.6, 0, 0.8, 1}, -- despair_stone_wand（骨杖皮肤）：紫色
    wiltonmod_staff2_skin          = {0.6, 0, 0.8, 1}, -- despair_stone_wand1（死亡权杖皮肤）：紫色
    scarecrow2                     = {0, 1, 0, 1},     -- 骨架配方用的稻草人皮肤：绿色
}

local function RecipePopupPostConstruct( widget )
    local _GetSkinsList = widget.GetSkinsList
    widget.GetSkinsList = function(self, ...)
        if self.recipe.skinnable == nil then
            return _GetSkinsList(self, ...)
        end
        
        self.skins_list = {}
        if self.recipe and GLOBAL.PREFAB_SKINS[self.recipe.name] then
            for _,item_type in pairs(GLOBAL.PREFAB_SKINS[self.recipe.name]) do
                local data  = {}
                data.type = type
                data.item = item_type
                data.timestamp = nil
                table.insert(self.skins_list, data)
            end
        end
        
        return self.skins_list
    end
    
    local _GetSkinOptions = widget.GetSkinOptions
    widget.GetSkinOptions = function(self, ...)
        if self.recipe.skinnable == nil then
            return _GetSkinOptions(self, ...)
        end
        
        local skin_options = {}

        table.insert(skin_options, 
        {
            text = GLOBAL.STRINGS.UI.CRAFTING.DEFAULT,
            data = nil, 
            colour = GLOBAL.SKIN_RARITY_COLORS["Common"],
            new_indicator = false,
            image = {self.recipe:GetAtlas() or "images/inventoryimages.xml", self.recipe.image or self.recipe.name .. ".tex", "default.tex"},
        })

        local recipe_timestamp = GLOBAL.Profile:GetRecipeTimestamp(self.recipe.name)
        
        if self.skins_list then 
            for which = 1, #self.skins_list do
                local image_name = self.skins_list[which].item
                if image_name == "" then 
                    image_name = "default"
                else
                    image_name = string.gsub(image_name, "_none", "")
                end
            
                local colour = GLOBAL.SKIN_RARITY_COLORS["Timeless"]
                if SkinNameColors[image_name] then
                    colour = SkinNameColors[image_name]
                elseif RedItem[image_name] then
                    colour = GLOBAL.SKIN_RARITY_COLORS["Elegant"]
                end
                local text_name = GLOBAL.STRINGS.SKIN_NAMES[image_name] or GLOBAL.STRINGS.SKIN_NAMES["missing"]
                local new_indicator = not self.skins_list[which].timestamp or (self.skins_list[which].timestamp > recipe_timestamp)
                
                --print("GetSkinOptions: " .. text_name .. ", " .. image_name)
                -- 优先使用本模组或其它 mod 提供的专用 atlas（images/inventoryimages/<name>.xml），
                -- 对于骷髅稻草人皮肤（scarecrow2），强制使用 images/scarecrow2.xml + scarecrow2.tex。
                local atlas
                if image_name == "scarecrow2" then
                    atlas = "images/scarecrow2.xml"
                else
                    atlas = "images/inventoryimages/"..image_name..".xml"
                    if GLOBAL.softresolvefilepath == nil or GLOBAL.softresolvefilepath(atlas) == nil then
                        local found = GLOBAL.GetInventoryItemAtlas and GLOBAL.GetInventoryItemAtlas(image_name..".tex") or nil
                        atlas = found or "images/inventoryimages.xml"
                    end
                end
                
                table.insert(skin_options,  
                {
                    text = text_name, 
                    data = image_name, -- data 字段需要携带实际皮肤 prefab 名（例如 "scarecrow2"），这样 builder:MakeRecipeFromMenu 才能收到 skin 参数，进而在 DoBuild 里切换配方产物。
                    colour = colour,
                    --new_indicator = new_indicator,
                    image = {atlas, image_name..".tex" or "default.tex", "default.tex"},
                })
            end
			
	    else 
    		self.spinner_empty = true
	    end
		
	    return skin_options
    end
	
	widget.skins_list = widget:GetSkinsList()
    widget.skins_options = widget:GetSkinOptions()
	
	widget.spinner:SetWrapEnabled(#widget.skins_options > 1)
	widget.spinner:SetOptions(widget.skins_options)
	
	if #widget.skins_options == 1 then
		widget.spinner.fgimage:SetPosition(0, 0)
		widget.spinner.fgimage:SetScale(1.2)
		widget.spinner.text:Hide()
	else
		widget.spinner.fgimage:SetPosition(0, 15)
		widget.spinner.fgimage:SetScale(1)
		widget.spinner.text:Show()
	end
	
	widget.spinner:SetOnChangedFn(widget.spinner.onchangedfn)
end
--AddClassPostConstruct("widgets/recipepopup", RecipePopupPostConstruct)
AddClassPostConstruct("widgets/redux/craftingmenu_skinselector", RecipePopupPostConstruct)


	local function BuilderSkinPostInit( builder )
    local _MakeRecipeFromMenu = builder.MakeRecipeFromMenu
    builder.MakeRecipeFromMenu = function( self, recipe, skin )
        if recipe.skinnable == nil then
            _MakeRecipeFromMenu( self, recipe, skin )
		else
			if recipe.placer == nil then
				if self:KnowsRecipe(recipe.name) then
					if self:IsBuildBuffered(recipe.name) or self:CanBuild(recipe.name) then
						--print("make1")
						self:MakeRecipe(recipe, nil, nil, skin)
					end

				elseif GLOBAL.CanPrototypeRecipe(recipe.level, self.accessible_tech_trees) and
					self:CanLearn(recipe.name) and
					self:CanBuild(recipe.name) then
					--print("make2")	
					self:MakeRecipe(recipe, nil, nil, skin, function()
						self:ActivateCurrentResearchMachine()
						self:UnlockRecipe(recipe.name)
					end)
				end
			end
        end     
    		end

		local _DoBuild = builder.DoBuild
		builder.DoBuild = function( self, recname, pt, rotation, skin )
			local recipe = GLOBAL.GetValidRecipe(recname)
			local is_skeleton = recname == "skeleton"

			-- 针对一般可皮肤物品：用 skin 临时替换配方产物。
			-- skeleton 使用自定义逻辑，不走这里的产物切换。
			if recipe ~= nil and recipe.skinnable and not is_skeleton then
				if skin ~= nil then
					if GLOBAL.AllRecipes[recname]._oldproduct == nil then
						GLOBAL.AllRecipes[recname]._oldproduct = GLOBAL.AllRecipes[recname].product
					end
					GLOBAL.AllRecipes[recname].product = skin
				else
					if GLOBAL.AllRecipes[recname]._oldproduct ~= nil then
						GLOBAL.AllRecipes[recname].product = GLOBAL.AllRecipes[recname]._oldproduct
					end
				end
			end

			-- skeleton 配方的“皮肤”只是用来切换产物（骨架 -> 稻草人），
			-- 不需要也不应该把该字符串当作真正的官方皮肤 ID 传进原版 DoBuild。
			local build_skin = skin
			if is_skeleton then
				build_skin = nil
			end

			return _DoBuild( self, recname, pt, rotation, build_skin )
		end

		-- 记录建造 skeleton 时玩家选择的皮肤，在 prefab 的 onbuilt 里根据该信息把 skeleton 换成 scarecrow2。
		local _MakeRecipeAtPoint = builder.MakeRecipeAtPoint
		builder.MakeRecipeAtPoint = function(self, recipe, pt, rot, skin)
			if recipe ~= nil and recipe.name == "skeleton" then
				self._wilton_skeleton_skin = skin
			end
			return _MakeRecipeAtPoint(self, recipe, pt, rot, skin)
		end
	end

AddComponentPostInit("builder", BuilderSkinPostInit)
