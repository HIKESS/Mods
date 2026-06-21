local Gewen_Chaijie = Class(function(self, inst)
    self.inst = inst
end)

function Gewen_Chaijie:CanDismantle(target, doer)
	if target.components.rechargeable ~= nil and not target.components.rechargeable:IsCharged() then
        return false, "ONCOOLDOWN"
    end

    return true
end

function Gewen_Chaijie:Dismantle(target, doer)
    if target.components.inventoryitem then

        -- 若配置为0时，则忽略是否有耐久度
        if TUNING.GWEN_CHAIJIEZHI ~= 0 then
        -- 判断物品是否具有耐久度
            if not (target.components.finiteuses or target.components.armor or target.components.fueled) then
                -- 如果没有耐久组件，则不能拆解，直接返回
                if doer.components.talker then
                    doer.components.talker:Say("这个物品不能拆解！") -- 提示玩家
                end
                return
            end
            if (target.components.finiteuses and target.components.finiteuses:GetPercent() < TUNING.GWEN_CHAIJIEZHI)
            or (target.components.fueled and target.components.fueled:GetPercent() < TUNING.GWEN_CHAIJIEZHI)
            or (target.components.armor and target.components.armor:GetPercent() < TUNING.GWEN_CHAIJIEZHI)
            then 
                if doer.components.talker then
                    doer.components.talker:Say("损坏成这样就不能拆了!") -- 提示玩家
                end
                return
            end
        end
		

        local recipe = AllRecipes[target.prefab]
        if recipe then
            local owner = target.components.inventoryitem:GetGrandOwner()
            local receiver = owner ~= nil and not owner:HasTag("pocketdimension_container") and (owner.components.inventory or owner.components.container) or nil
            local pt = receiver ~= nil and self.inst:GetPosition() or doer:GetPosition()

            -- 检查物品是否可以堆叠且堆叠数大于1，同时确认是否有合成表允许拆解
            if target.components.stackable and target.components.stackable:IsStack() and target.components.stackable:StackSize() > 1 then
                -- 从堆叠中移除一个物品
                local item = target.components.stackable:Get(1)
                item:Remove() -- 移除一个物品

                -- 获取拆解后的物品
                local loot = target.components.lootdropper:GetFullRecipeLoot(recipe)
                for _, prefab in ipairs(loot) do
                    if TUNING.GEIBUGEILVBAOSHI == false and prefab == "greengem" then
                        -- Skip greengem when GEIBUGEILVBAOSHI is false
                    else
                        if receiver ~= nil then
                            receiver:GiveItem(SpawnPrefab(prefab), nil, pt)
                        else
                            target.components.lootdropper:SpawnLootPrefab(prefab, pt)
                        end
                    end
                end
            else
                -- 如果不是堆叠物品或者只有一个，处理整个物品的拆解
                local loot = target.components.lootdropper:GetFullRecipeLoot(recipe)
                target:Remove() -- 移除目标物品

                for _, prefab in ipairs(loot) do
                    if TUNING.GEIBUGEILVBAOSHI == false and prefab == "greengem" then
                        -- Skip greengem when GEIBUGEILVBAOSHI is false
                    else
                        if receiver ~= nil then
                            receiver:GiveItem(SpawnPrefab(prefab), nil, pt)
                        else
                            target.components.lootdropper:SpawnLootPrefab(prefab, pt)
                        end
                    end
                end
            end

            -- 在拆解后生成破损工具特效
            SpawnPrefab("brokentool").Transform:SetPosition(doer.Transform:GetWorldPosition())
        end
    end
end





return Gewen_Chaijie
