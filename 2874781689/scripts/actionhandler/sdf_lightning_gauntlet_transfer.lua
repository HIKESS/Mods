GLOBAL.setmetatable(env,{__index=function(a,b)return GLOBAL.rawget(GLOBAL,b)end})

local SDF_LIGHTNING_GAUNTLET_TRANSFER =
    AddAction("SDF_LIGHTNING_GAUNTLET_TRANSFER",STRINGS.ACTIONHANDLER_SDF_LIGHTNING_GAUNTLET_TRANSFER,function(act)

	--Transfer
	local lightningGauntletItem = act.doer.replica.inventory:GetEquippedItem(EQUIPSLOTS.HANDS)	
	if lightningGauntletItem then
	    if lightningGauntletItem.components.container ~= nil then
		local itemSlot1 = lightningGauntletItem.components.container:GetItemInSlot(1)
		if (lightningGauntletItem.ModeState == "LIGHTNING" or lightningGauntletItem.ModeState == "PUNCH") then --and itemSlot1 ~= nil and itemSlot1.prefab == "sdf_lightning" then

		    --Lightning Rods
		    if act.target:HasTag("lightningrod") then
			if act.target.charged and act.target.charged == true then

			    --Professors Lab Tesla Transer
			    if act.target:HasTag("sdf_professors_lab_generator_powered") then

				--Discharge
				act.target:SdfProfessorsLabDischargeFn()

				--Create Anim
				local electricutefx = SpawnPrefab("sdf_lightning_charged_electricute_fx")
				if electricutefx then
				    local follower = electricutefx.entity:AddFollower()
				    follower:FollowSymbol(act.doer.GUID, act.doer.components.combat.hiteffectsymbol, 0, 0, 0)
				    electricutefx:FacePoint(act.doer.Transform:GetWorldPosition())
				end

				--Create sound fx
				act.doer.SoundEmitter:PlaySound("dontstarve/common/lightningrod")

				--Transer Process
				if itemSlot1 ~= nil and itemSlot1.prefab == "sdf_lightning" then
				    --Recharge lightning item
				    local lightningCurrentPercent = itemSlot1.components.finiteuses:GetPercent()
				    local lightningAdjustPercent = lightningCurrentPercent + TUNING.SDF_LIGHTNING_GAUNTLET_TRANSFER_PROFESSORS_LAB_RECHARGE_TESLA_PERCENT
				    if lightningAdjustPercent > 1 then
					lightningAdjustPercent = 1
				    end
				    itemSlot1.components.finiteuses:SetPercent(lightningAdjustPercent)
				else
				    local lightningItem = SpawnPrefab("sdf_lightning")
				    lightningItem.components.finiteuses:SetPercent(TUNING.SDF_LIGHTNING_GAUNTLET_TRANSFER_PROFESSORS_LAB_NEW_TESLA_PERCENT)
				    lightningGauntletItem.components.container:GiveItem(lightningItem, 1)
				end

				--Cooldown
				lightningGauntletItem.components.rechargeable:Discharge(TUNING.SDF_LIGHTNING_GAUNTLET_TRANSFER_COOLDOWN)

				return true
			    end

			    --Lightning Rod Transfer

			    --Discharge
			    act.target:StopWatchingWorldState("cycles", ondaycomplete)
			    act.target.AnimState:ClearBloomEffectHandle()
			    act.target.AnimState:SetLightOverride(0)
			    if act.target._top ~= nil then
				act.target._top.AnimState:ClearBloomEffectHandle()
				act.target._top.AnimState:SetLightOverride(0)
			    end
			    act.target.charged = false
			    act.target.chargeleft = nil
			    if act.target.Light ~= nil then
				act.target.Light:Enable(false)
			    end
			    if act.target.zaptask ~= nil then
				act.target.zaptask:Cancel()
				act.target.zaptask = nil
			    end

			    --Create Anim
			    local electricutefx = SpawnPrefab("sdf_lightning_charged_electricute_fx")
			    if electricutefx then
				local follower = electricutefx.entity:AddFollower()
				follower:FollowSymbol(act.doer.GUID, act.doer.components.combat.hiteffectsymbol, 0, 0, 0)
				electricutefx:FacePoint(act.doer.Transform:GetWorldPosition())
			    end

			    --Create sound fx
			    act.doer.SoundEmitter:PlaySound("dontstarve/common/lightningrod")

			    --Transer Process
			    if itemSlot1 ~= nil and itemSlot1.prefab == "sdf_lightning" then
				--Recharge lightning item
				local lightningCurrentPercent = itemSlot1.components.finiteuses:GetPercent()
				local lightningAdjustPercent = lightningCurrentPercent + TUNING.SDF_LIGHTNING_GAUNTLET_TRANSFER_LIGHTNING_ROD_RECHARGE_PERCENT
				if lightningAdjustPercent > 1 then
				    lightningAdjustPercent = 1
				end
				itemSlot1.components.finiteuses:SetPercent(lightningAdjustPercent)
			    else
				local lightningItem = SpawnPrefab("sdf_lightning")
				lightningItem.components.finiteuses:SetPercent(TUNING.SDF_LIGHTNING_GAUNTLET_TRANSFER_LIGHTNING_ROD_NEW_PERCENT)
				lightningGauntletItem.components.container:GiveItem(lightningItem, 1)
			    end

			    --Cooldown
			    lightningGauntletItem.components.rechargeable:Discharge(TUNING.SDF_LIGHTNING_GAUNTLET_TRANSFER_COOLDOWN)

			    return true
			else
			    if act.doer.components.talker then
				act.doer.components.talker:Say(GetString(act.doer, "ANNOUNCE_SDF_LIGHTNING_MORE_CHARGE"))
				return true
			    end
			end
		    end
		end

		--Chalice HoH
		if act.doer.prefab == "sdf" and act.target.GOODLIGHTNINGREADY == true then
		    local itemSlot2 = lightningGauntletItem.components.container:GetItemInSlot(2)
		    --local hero_Enabled = act.doer.components.sdf_chalice_id_lock:CheckHeroStatus()
		    local goodLightningSample = act.doer.components.sdf_chalice_id_lock:HasGoodLightningSample()
		    local chaliceFilledPercent = act.doer.components.sdf_souls:GetPercent()

		    --Goodlightning Reward
		    if (lightningGauntletItem.ModeState == "GOODLIGHTNING" or lightningGauntletItem.ModeState == "PUNCH") and goodLightningSample == true then

			--play offering FX
			local x,_,z = act.target.Transform:GetWorldPosition()
			SpawnPrefab("spore_moon_coughout").Transform:SetPosition(x,_,z)
			act.target.SoundEmitter:PlaySound("dontstarve/maxwell/shadowmax_despawn")
			act.target.goodlightningtask:Cancel()

			--Create Anim
			local electricutefx = SpawnPrefab("sdf_goodlightning_charged_electricute_fx")
			if electricutefx then
			    local follower = electricutefx.entity:AddFollower()
			    follower:FollowSymbol(act.doer.GUID, act.doer.components.combat.hiteffectsymbol, 0, 0, 0)
			    electricutefx:FacePoint(act.doer.Transform:GetWorldPosition())
			end


			--Create new Goodlightning item
			act.target:DoTaskInTime(0.9, function()
			    if act.target.GOODLIGHTNINGREADY == true then
				act.target.GOODLIGHTNINGREADY = false
				local x,_,z = act.doer.Transform:GetWorldPosition()
				SpawnPrefab("mastupgrade_lightningrod_fx").Transform:SetPosition(x,_,z)
				SpawnPrefab("moonstorm_spark_shock_fx").Transform:SetPosition(x,_,z)

				--Unlock trade at vender
				act.doer.components.sdf_chalice_id_lock:EnableTrade("sdf_goodlightning")
				act.doer.components.sdf_chalice_id_lock:CreateTradeTags(act.doer)


				--Transer Process
				if itemSlot2 ~= nil and itemSlot2.prefab == "sdf_goodlightning" then
				    --Recharge goodlightning item
				    local goodlightningCurrentPercent = itemSlot2.components.finiteuses:GetPercent()
				    local goodlightningAdjustPercent = goodlightningCurrentPercent + TUNING.SDF_LIGHTNING_GAUNTLET_TRANSFER_HOH_CHALICE_SAMPLE_PERCENT
				    if goodlightningAdjustPercent > 1 then
					goodlightningAdjustPercent = 1
				    end
				    itemSlot2.components.finiteuses:SetPercent(goodlightningAdjustPercent)
				else
				    local goodlightningItem = SpawnPrefab("sdf_goodlightning")
				    goodlightningItem.components.finiteuses:SetPercent(TUNING.SDF_LIGHTNING_GAUNTLET_TRANSFER_HOH_CHALICE_SAMPLE_PERCENT)
				    lightningGauntletItem.components.container:GiveItem(goodlightningItem, 2)
				end

				--remove sample
				act.doer.components.sdf_chalice_id_lock:RemoveGoodLightningSample()

				--Cooldown
				lightningGauntletItem.components.rechargeable:Discharge(TUNING.SDF_LIGHTNING_GAUNTLET_TRANSFER_COOLDOWN)

			    end
			end)
			return true
		    end

		    --Transfer Goodlightning
		    if (lightningGauntletItem.ModeState == "GOODLIGHTNING" or lightningGauntletItem.ModeState == "PUNCH") then
			if act.doer:HasTag("sdf_goodlightning_builder") and chaliceFilledPercent > 0 then

			    --play offering FX
			    local x,_,z = act.target.Transform:GetWorldPosition()
			    SpawnPrefab("spore_moon_coughout").Transform:SetPosition(x,_,z)
			    act.target.SoundEmitter:PlaySound("dontstarve/maxwell/shadowmax_despawn")

			    act.target.goodlightningtask:Cancel()

			    --Create new Goodlightning item
			    act.target:DoTaskInTime(0.9, function()
				if act.target.GOODLIGHTNINGREADY == true then
				    act.target.GOODLIGHTNINGREADY = false
				    local totalSoulCost = chaliceFilledPercent
				    local x,_,z = act.doer.Transform:GetWorldPosition()
				    SpawnPrefab("mastupgrade_lightningrod_fx").Transform:SetPosition(x,_,z)
				    SpawnPrefab("moonstorm_spark_shock_fx").Transform:SetPosition(x,_,z)

				    --Transer Process
				    if itemSlot2 ~= nil and itemSlot2.prefab == "sdf_goodlightning" then
					--Recharge goodlightning item
					local goodlightningCurrentPercent = itemSlot2.components.finiteuses:GetPercent()
					local goodlightningAdjustPercent = 1 - goodlightningCurrentPercent

					if goodlightningAdjustPercent > 0 then
					    if chaliceFilledPercent > goodlightningAdjustPercent then
						totalSoulCost = goodlightningAdjustPercent
					    end
					    itemSlot2.components.finiteuses:SetPercent(goodlightningCurrentPercent + totalSoulCost)
					else
					    totalSoulCost = 0
					end
					
				    else
					local goodlightningItem = SpawnPrefab("sdf_goodlightning")
					goodlightningItem.components.finiteuses:SetPercent(totalSoulCost)
					lightningGauntletItem.components.container:GiveItem(goodlightningItem, 2)
				    end

				    --Update player chalice souls
				    act.doer.components.sdf_souls:DoDelta(-(totalSoulCost * 100))

				    --Cooldown
				    lightningGauntletItem.components.rechargeable:Discharge(TUNING.SDF_LIGHTNING_GAUNTLET_TRANSFER_COOLDOWN)

				end
			    end)
			    return true
			end
		    end
		elseif act.doer.prefab == "sdf" then

		    --Not enough souls
		    --local hero_Enabled = act.doer.components.sdf_chalice_id_lock:CheckHeroStatus()
		    local chaliceFilledPercent = act.doer.components.sdf_souls:GetPercent()

		    --if hero_Enabled == true and chaliceFilledPercent < 1 then
		    if act.doer:HasTag("sdf_goodlightning_builder") and chaliceFilledPercent <= 0 then

			if act.doer.components.talker then
			    act.doer.components.talker:Say(GetString(act.doer, "ANNOUNCE_SDF_GOODLIGHTNING_MORE_SOULS"))
			    return true
			end
		    end
		end
	    end
	end

        return false
    end)

SDF_LIGHTNING_GAUNTLET_TRANSFER.rmb = true
SDF_LIGHTNING_GAUNTLET_TRANSFER.distance = 1.5

AddStategraphActionHandler('wilson', GLOBAL.ActionHandler(GLOBAL.ACTIONS.SDF_LIGHTNING_GAUNTLET_TRANSFER, 'doshortaction'))
AddStategraphActionHandler('wilson_client', GLOBAL.ActionHandler(GLOBAL.ACTIONS.SDF_LIGHTNING_GAUNTLET_TRANSFER, 'doshortaction'))