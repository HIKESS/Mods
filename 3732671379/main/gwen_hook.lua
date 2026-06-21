local ThePlayer = GLOBAL.ThePlayer
local TheInput = GLOBAL.TheInput
local SpawnPrefab = GLOBAL.SpawnPrefab

GLOBAL.setmetatable(env,{__index=function(t,k) return GLOBAL.rawget(GLOBAL,k) end})

----[]----[]----[]----[]----[]----[]----[]----[]----[]----[]----[]----[]----[]----[]----[]----
----飞行能力
local h = 1
AddComponentPostInit("locomotor",function(self)
	local oldRunForward = self.RunForward
	function self:RunForward(direct, ...)
		oldRunForward(self, direct, ...)
		if self.inst:HasTag("gwen_flying") then
            local a,b,c = self.inst.Physics:GetMotorVel()
            local y = self.inst:GetPosition().y
            if y and h then
                self.inst.Physics:SetMotorVelOverride(a, (h - y)*32, c)
			end
		end
    end
end)

--------------------------------------------------------------------------------------------------------------------------------
----格温在学习了暗影的飞行技能后飞行过程中会被无视
AddComponentPostInit("combat", function(self)
    local old_GetTarget = self.GetTarget or function(self)
        return self.target
    end
    
    self.GetTarget = function(self)
        local target = old_GetTarget(self)
        if target and target:IsValid() and target.components.skilltreeupdater and target.components.skilltreeupdater:IsActivated("gwen_fly_shadow_1") and target:HasTag("gwen_flying")then
            self.target = nil
            return nil
        end
        return target
    end
    local old_SetTarget = self.SetTarget
    self.SetTarget = function(self, target, ...)
        if target and target:IsValid() and target.components.skilltreeupdater and target.components.skilltreeupdater:IsActivated("gwen_fly_shadow_1") and target:HasTag("gwen_flying") then
            target = nil
        end
        return old_SetTarget(self, target, ...)
    end
end)

----飞行过程中免疫地面减速
AddComponentPostInit("locomotor", function(self)
    local oldSetExternalSpeedMultiplier = self.SetExternalSpeedMultiplier
    function self:SetExternalSpeedMultiplier(source, key, m, ...)
        if m ~= nil and m < 1 and self.inst:HasTag("gwen") and self.inst:HasTag("gwen_flying") then
            return
        end
        return oldSetExternalSpeedMultiplier(self, source, key, m, ...)
    end

    local PushTempGroundSpeedMultiplier = self.PushTempGroundSpeedMultiplier
    function self:PushTempGroundSpeedMultiplier(mult, ...)
        if mult ~= nil and mult < 1 and self.inst:HasTag("gwen") and self.inst:HasTag("gwen_flying") then
            return
        end
        PushTempGroundSpeedMultiplier(self, mult, ...)
    end

    local oldUpdateGroundSpeedMultiplier = self.UpdateGroundSpeedMultiplier
    function self:UpdateGroundSpeedMultiplier(...)
        if self.inst:HasTag("gwen") and self.inst:HasTag("gwen_flying") then
            local x, y, z = self.inst.Transform:GetWorldPosition()
            local oncreep = TheWorld.GroundCreep:OnCreep(x, y, z)
            self.wasoncreep = false
            local current_ground_tile = TheWorld.Map:GetTileAtPoint(x, 0, z)
            self.groundspeedmultiplier =
                (self:IsFasterOnGroundTile(current_ground_tile) or oncreep) and 1
                or
                (self:FasterOnRoad() and ((RoadManager ~= nil and RoadManager:IsOnRoad(x, 0, z)) or current_ground_tile == GROUND.ROAD)) and
                self.fastmultiplier
                or 1
        else
            return oldUpdateGroundSpeedMultiplier(self, ...)
        end
    end
end)

----格温不会滑倒
AddStategraphPostInit(
    'wilson',
    function(sg)
        if sg.events and sg.events.feetslipped then
			local oldfeetslippedfn = sg.events.feetslipped.fn
			sg.events.feetslipped.fn = function(inst)
				if inst:HasTag("gwen") then
					return
				elseif oldfeetslippedfn then
					return oldfeetslippedfn(inst)
				end        
			end
		end
    end
)

AddComponentPostInit("combat", function(self)
    local old_GetAttacked = self.GetAttacked
    function self:GetAttacked(attacker, damage, weapon, stimuli, spdamage)
        local target = self.inst
		local owner = attacker
		if owner and owner.prefab == "gwen" and owner:HasTag("gwen_flying") then
			return
		end
		return old_GetAttacked(self, attacker, damage, weapon, stimuli, spdamage)
	end
end)


local function gwen_flying(inst)
	inst:DoPeriodicTask(0,function()
		if inst:HasTag("gwen_flying") then
			if inst.Physics then
				local x,y,z = inst.Physics:GetMotorVel()
				local pt = inst:GetPosition()
				inst.Physics:SetMotorVelOverride(x, (h - pt.y) * 32, z)
			end
			if inst.components.gwen_shengai then
				local shengai_current = inst.components.gwen_shengai.current or 1
				if shengai_current < 1 then
					inst:PushEvent("gw_fly")
				end
			end
			if inst.components.rider and inst.components.rider:IsRiding() then
				inst:PushEvent("gw_fly")
			end
		end
	end)
end

AddPrefabPostInit("gwen", gwen_flying)

local function runfnhook(self)

	local talk = self.states.talk
    if talk then
        local old_enter = talk.onenter
        function talk.onenter(inst, ...)
			if old_enter then
				old_enter(inst, ...)
			end
			if inst:HasTag("gw_xiufu") then
				if not inst.AnimState:IsCurrentAnimation("build_loop") then
					inst.AnimState:PlayAnimation("build_loop", true)
				end
            end
			local rider = inst.replica.rider
			if inst:HasTag("gwen_flying")
			and (rider == nil or (rider ~= nil and not rider:IsRiding()))
			then
				if not inst.AnimState:IsCurrentAnimation("emote_loop_sit4") then
					inst.AnimState:PlayAnimation("emote_loop_sit4",true)
				end
			end
        end
    end

	local funnyidle = self.states.funnyidle
    if funnyidle then
        local old_enter = funnyidle.onenter
        function funnyidle.onenter(inst, ...)
			if inst:HasTag("gw_xiufu") then
				if not inst.AnimState:IsCurrentAnimation("build_loop") then
					inst.AnimState:PlayAnimation("build_loop",true)
				else
					return
				end
			end
			if old_enter then
				old_enter(inst, ...)
			end
			local rider = inst.replica.rider
			if inst:HasTag("gwen_flying")
			and (rider == nil or (rider ~= nil and not rider:IsRiding()))
			then
				if not inst.AnimState:IsCurrentAnimation("emote_loop_sit4") then
					inst.AnimState:PlayAnimation("emote_loop_sit4",true)
				end
			end
        end
    end

    local run = self.states.run
    if run then
        local old_enter = run.onenter
        function run.onenter(inst, ...)
            if old_enter then
                old_enter(inst, ...)
            end
            if inst:HasTag("gwen_flying") then
                if not inst.AnimState:IsCurrentAnimation("emote_loop_sit4") then
                    inst.AnimState:PlayAnimation("emote_loop_sit4", true)
                end
                inst.sg:SetTimeout(inst.AnimState:GetCurrentAnimationLength() + 0.01)
            end
        end
    end

    local run_start = self.states.run_start
    if run_start then
        local old_enter = run_start.onenter
        function run_start.onenter(inst, ...)
            if old_enter then
                old_enter(inst, ...)
            end
            if inst:HasTag("gwen_flying") then
                inst.AnimState:PlayAnimation("emote_loop_sit4")
            end
        end
    end

    local run_stop = self.states.run_stop
    if run_stop then
        local old_enter = run_stop.onenter
        function run_stop.onenter(inst, ...)
            if old_enter then
                old_enter(inst, ...)
            end
            if inst:HasTag("gwen_flying") then
                inst.AnimState:PlayAnimation("emote_loop_sit4")
            end
        end
    end

    local attack = self.states.attack
    if attack then
        local old_enter = attack.onenter
        function attack.onenter(inst, ...)
            if inst:HasTag("gwen_flying") then
				return
            else
				if old_enter then
					old_enter(inst, ...)
				end
			end
        end
    end

    local idle = self.states.idle
    if idle then
        local old_enter = idle.onenter
        function idle.onenter(inst, ...)
            if old_enter then
                old_enter(inst, ...)
            end
            if inst:HasTag("gwen_flying") then
                if inst.AnimState:IsCurrentAnimation("idle_loop") then
                    inst.AnimState:PlayAnimation("emote_loop_sit4", true)
                end
            end
			if inst:HasTag("gw_xiufu") then
				if not inst.AnimState:IsCurrentAnimation("build_loop") then
					inst.AnimState:PlayAnimation("build_loop",true)
				end
			end
        end
    end

end

AddStategraphPostInit("wilson", runfnhook)
AddStategraphPostInit("wilson_client", runfnhook)
----[]----[]----[]----[]----[]----[]----[]----[]----[]----[]----[]----[]----[]----[]----[]----

-- 有圣蔼的时候霸体
AddStategraphPostInit("wilson", function(sg)
    -- 玩家拥有免僵直标签时被攻击不会僵直
    if sg.events and sg.events.attacked then
        local oldattackedfn = sg.events.attacked.fn
        sg.events.attacked.fn = function(inst, data)
            -- 这里顺便加个playerghost的判断，免得玩家濒死的时候又挨了一下揍报错
            if inst.components.gwen_shengai and inst:HasTag("shengaifanwei") or inst:HasTag("playerghost") then
                return
            elseif oldattackedfn then
                return oldattackedfn(inst, data)
            end
        end
    end
end)

AddComponentPostInit("health", function(self)
    local oldDoDelta = self.DoDelta
    function self:DoDelta(amount, overtime, cause, ignore_invincible, afflicter, ignore_absorb, ...)
        local old_absorb = self.inst.components.health.absorb

        -- 处理环境伤害，不做额外调整
        if cause and (cause == "cold" or cause == "hot" or cause == "hunger") then
            amount = amount
        else
            -- 处理 **远程攻击减伤**
            if afflicter and afflicter:IsValid() and self.inst:HasTag("shengaifanwei") then
                local x1, y1, z1 = self.inst.Transform:GetWorldPosition()
                local x2, y2, z2 = afflicter.Transform:GetWorldPosition()
                local dist = math.sqrt((x1 - x2) ^ 2 + (z1 - z2) ^ 2) -- 计算攻击者距离

                if dist >= 3 then
                    amount = 0 -- 远程攻击伤害设为 0
                end
            end

            -- 处理 **生命值护盾**
            -- if self.inst.gwen_shengai and self.inst.gwen_shengai >= 1 and amount < 0 then
            --     if amount < -self.inst.components.gwen_shengai.max then
            --         -- 最多抵消 100 伤害
            --         amount = amount + self.inst.components.gwen_shengai.max
            --         self.inst.components.gwen_shengai:DoDelta(-self.inst.components.gwen_shengai.max)
            --         SpawnPrefab("moon_altar_link_fx").Transform:SetPosition(self.inst.Transform:GetWorldPosition())
            --     elseif -amount <= self.inst.gwen_shengai then
            --         -- 完全抵消伤害
            --         self.inst.components.gwen_shengai:DoDelta(amount)
            --         amount = 0
            --         SpawnPrefab("moon_altar_link_fx").Transform:SetPosition(self.inst.Transform:GetWorldPosition())
            --     elseif -amount > self.inst.gwen_shengai then
            --         -- 部分抵消
            --         amount = amount + self.inst.gwen_shengai
            --         self.inst.components.gwen_shengai:DoDelta(amount)
            --     end
            -- end


            -- **半数伤害转圣蔼护盾**
            if self.inst.gwen_shengai and self.inst.gwen_shengai >= 1 and amount < 0 then
                local original_damage = -amount
                local extra_percentage = 0
                if self.inst.gw_taozhuang_zhandou_active ~= nil then
                    extra_percentage = extra_percentage + 0.10
                end
                
                if self.inst.gw_taozhuang_zhandou2_active ~= nil then
                    extra_percentage = extra_percentage + 0.20
                end

                local shengai_percentage = TUNING.SHENGAIJIANMIAN + extra_percentage
                if shengai_percentage > 1.0 then
                    shengai_percentage = 1.0
                end

                -- 实际上圣爱承受的伤害值部分
                local half_damage = original_damage * shengai_percentage
                
                -- 圣蔼上限获取一下
                local shengai_max = self.inst.components.gwen_shengai.max or 100
    
                -- 半数伤害超过圣蔼最大值
                if half_damage > shengai_max then
                    -- 圣蔼来承担最大上限值
                    self.inst.components.gwen_shengai:DoDelta(-shengai_max)
                    -- 然后剩下的部分扣血
                    amount = amount + shengai_max
                    SpawnPrefab("moon_altar_link_fx").Transform:SetPosition(self.inst.Transform:GetWorldPosition())

                -- 半数伤害小于等于当前圣蔼值
                elseif half_damage <= self.inst.gwen_shengai then
                    -- 圣蔼承担一半
                    self.inst.components.gwen_shengai:DoDelta(-half_damage)
                    -- 血量承受另一半
                    amount = amount + half_damage
                    SpawnPrefab("moon_altar_link_fx").Transform:SetPosition(self.inst.Transform:GetWorldPosition())
                -- 半数伤害大于当前圣蔼值但不超过最大值

                else
                    local remaining_shengai = self.inst.gwen_shengai
                    self.inst.components.gwen_shengai:DoDelta(-remaining_shengai)
                    amount = amount + remaining_shengai
                    SpawnPrefab("moon_altar_link_fx").Transform:SetPosition(self.inst.Transform:GetWorldPosition())
                end
            end
        end

        -- 调用原始的 `DoDelta` 方法
        local result = oldDoDelta(self, amount, overtime, cause, ignore_invincible, afflicter, ignore_absorb, ...)
        self.inst.components.health.absorb = old_absorb
        return result
    end
end)


---免疫冰冻和睡眠
AddComponentPostInit("grogginess", function(self)
    local oldAddGrogginess = self.AddGrogginess
    function self:AddGrogginess(...)
        if self.inst:HasTag('shengaifanwei') then
            return
        end
        return oldAddGrogginess(self, ...)
    end
end)

AddComponentPostInit("freezable", function(self)
    local oldAddColdness = self.AddColdness
    function self:AddColdness(...)
        if self.inst:HasTag('shengaifanwei') then
            return
        end
        return oldAddColdness(self, ...)
    end
    local oldFreeze = self.Freeze
    function self:Freeze(...)
        if self.inst:HasTag('shengaifanwei') then
            return
        end
        return oldFreeze(self, ...)
    end
end)

--免疫沙尘暴
AddClassPostConstruct("widgets/gogglesover", function(self)
    local oldToggleGoggles = self.ToggleGoggles
    function self:ToggleGoggles(show, ...)
        oldToggleGoggles(self, show, ...)
        if self.owner
		and (
		((self.owner.replica.inventory and self.owner:HasTag('shengaifanwei')))
		or (self.owner.replica.inventory and self.owner.replica.inventory:HasItemWithTag("dust_resistant_pill", 1) or self.owner:HasTag('mythpill_forcegoggles'))
		or (self.owner.replica.inventory and self.owner.replica.inventory:HasItemWithTag("gollum", 1))
		or (self.owner.replica.inventory and self.owner.replica.inventory:HasItemWithTag("gollum_shadun", 1))
		or (self.owner.replica.inventory and self.owner.replica.inventory:HasItemWithTag("klein_goggle", 1))
		)then
            self:Hide()
        end
    end
end)

AddComponentPostInit("playervision", function(self)
    self.inst:StartUpdatingComponent(self)
    function self:OnUpdate(dt)
        if (self.inst.replica.inventory and self.inst:HasTag('shengaifanwei'))
		or (self.inst.replica.inventory and self.inst.replica.inventory:HasItemWithTag("dust_resistant_pill", 1) or self.inst:HasTag('mythpill_forcegoggles'))
		or (self.inst.replica.inventory and self.inst.replica.inventory:HasItemWithTag("gollum", 1))
		or (self.inst.replica.inventory and self.inst.replica.inventory:HasItemWithTag("gollum_shadun", 1))
		or (self.inst.replica.inventory and self.inst.replica.inventory:HasItemWithTag("klein_goggle", 1))
		then
            self:ForceGoggleVision(true)
        else
            self:ForceGoggleVision(false)
        end
    end
end)

----结界减伤
AddComponentPostInit("health", function(self)
    local old_DoDelta = self.DoDelta
    function self:DoDelta(amount, ...)
        local owner = self.inst
		if owner and owner.prefab == "gwen"
		and owner:HasTag('shengaifanwei')
		and amount < 0
		and owner.components.gwen_competence and owner.components.gwen_competence:Get_gwen_Level() >= 5
		and math.random() < .4
		then
			amount = 0
			owner.components.colourtweener:StartTween({.6, .6, .6, .5}, 0)
			owner:DoTaskInTime(.5, function(owner)
				owner.components.colourtweener:StartTween({1, 1, 1, 1}, 0)
			end)
        end
		return old_DoDelta(self, amount, ...)
	end
end)

----等级减伤
AddComponentPostInit("health", function(self)
    local old_DoDelta = self.DoDelta
    function self:DoDelta(amount, ...)
        local owner = self.inst
		if owner and owner.prefab == "gwen"
		and owner.components.gwen_competence
		and amount < 0
		then
			local gw_Level = (owner.components.gwen_competence and owner.components.gwen_competence:Get_gwen_Level()) or 1
			local mianshang
			if gw_Level >= 1 then
				mianshang = 1
			end
			if gw_Level >= 11 then
				mianshang = .9
			end
			if gw_Level >= 18 then
				mianshang = .85
			end
			amount = amount *mianshang
        end
		return old_DoDelta(self, amount, ...)
	end
end)

----等级攻击加成
AddComponentPostInit("combat", function(self)
    local old_GetAttacked = self.GetAttacked
    function self:GetAttacked(attacker, damage, weapon, stimuli, spdamage)
        local target = self.inst
		local owner = attacker

		if damage == nil then
            damage = 0
            -- print("byd别打你那个破蜈蚣了") ------（蜈蚣传入伤害有问题，传入到下方的damage变成了nil，所以判定一下当为nil时=0）（后续克雷修复了可以删）
        end

		if owner and owner.prefab == "gwen" 
		and owner.components.gwen_competence
		and owner:HasTag("player") and owner.components.health and not owner.components.health:IsDead() and not owner:HasTag("playerghost")
		then 
			local gw_Level = (owner.components.gwen_competence and owner.components.gwen_competence:Get_gwen_Level()) or 1
			if gw_Level >= 18 then
				damage = damage *(1+(gw_Level-18)*.01)
			end
		end

		if owner and owner:HasTag("gw_cs_1") then
            damage = damage * 1.1
        elseif owner and owner:HasTag("gw_cs_2") then
            damage = damage * 1.25
        end
		return old_GetAttacked(self, attacker, damage, weapon, stimuli, spdamage)
	end
end)



--死亡不掉落骨架
local ex_fns = require "prefabs/player_common_extensions"
local old_Ghost  = ex_fns.OnMakePlayerGhost

ex_fns.OnMakePlayerGhost = function(inst,data)
	if inst and inst.prefab == "gwen" then
		if data and data.skeleton then
			data.skeleton = nil
			--SpawnPrefab("gwen_wawa").Transform:SetPosition(inst.Transform:GetWorldPosition())
		end
		old_Ghost(inst,data)
		inst.Network:RemoveUserFlag(USERFLAGS.IS_GHOST)
		TheWorld:DoTaskInTime(0.2, function()
		TheWorld:PushEvent("ms_playercounts",
            {
                total = TheWorld.shard.components.shard_players:GetNumPlayers(),
                ghosts = TheWorld.shard.components.shard_players:GetNumGhosts(),
                alive = TheWorld.shard.components.shard_players:GetNumAlive(),
            })
		end)
	else
		old_Ghost(inst,data)
		TheWorld:DoTaskInTime(0.2, function()
		TheWorld:PushEvent("ms_playercounts",
            {
                total = TheWorld.shard.components.shard_players:GetNumPlayers(),
                ghosts = TheWorld.shard.components.shard_players:GetNumGhosts(),
                alive = TheWorld.shard.components.shard_players:GetNumAlive(),
            })
		end)
	end
end

----作祟失效
AddComponentPostInit("hauntable",function(self)
	local old_DoHaunt = self.DoHaunt
	function self:DoHaunt(doer,...)
		if doer and doer.prefab == "gwen" then
			return
		else
			old_DoHaunt(self,doer,...)
		end
	end
end)

----猴子诅咒免疫（抄自奇幻降临）
AddComponentPostInit("cursable", function(self)
	local oldIsCursable = self.IsCursable
	function self:IsCursable(item)
		if item and item.components.curseditem and item.components.curseditem.curse  == "MONKEY" and self.inst:HasTag("player") and self.inst.prefab == "gwen" then
			return false
		end
		return oldIsCursable(self,item)
	end
	local oldApplyCurse = self.ApplyCurse
	function self:ApplyCurse(item)
		if item and item.components.curseditem and item.components.curseditem.curse == "MONKEY" and self.inst:HasTag("player") and self.inst.prefab == "gwen" then
			item:RemoveTag("applied_curse")
        	item.components.curseditem.cursed_target = nil
			return
		end
		return oldApplyCurse(self,item)
	end
	local oldForceOntoOwner = self.ForceOntoOwner
	function self:ForceOntoOwner(item)
		if item and item.components.curseditem and item.components.curseditem.curse == "MONKEY" and self.inst:HasTag("player") and self.inst.prefab == "gwen" then
			return
		end
		return oldForceOntoOwner(self,item)
	end
end)

----移速
AddComponentPostInit("locomotor", function(Locomotor)
    local oldGetWalkSpeed = Locomotor.GetWalkSpeed
    function Locomotor:GetWalkSpeed()
        if self.inst.prefab == "gwen" and self.inst:HasTag("gwen_flying") then
            local mult = self:GetSpeedMultiplier() > 1 and self:GetSpeedMultiplier() or 1
            local ground_mult = self.groundspeedmultiplier > 1 and self.groundspeedmultiplier or 1
            return self.walkspeed * mult * ground_mult
        else
            return oldGetWalkSpeed(self)
        end
    end

    local oldGetRunSpeed = Locomotor.GetRunSpeed
    function Locomotor:GetRunSpeed()
        if self.inst.prefab == "gwen" and self.inst:HasTag("gwen_flying") then
            local mult = self:GetSpeedMultiplier() > 1 and self:GetSpeedMultiplier() or 1
            local ground_mult = self.groundspeedmultiplier > 1 and self.groundspeedmultiplier or 1
            return self.runspeed * mult * ground_mult
        else
            return oldGetRunSpeed(self)
        end
    end
end)

----不知道是啥
AddPrefabPostInitAny(function(inst)
    if not TheWorld.ismastersim then
        return inst
    end
    if not inst.components.lootdropper then
		inst:AddComponent("lootdropper")
	end
end)

AddComponentPostInit("lootdropper", function(self)
	local _oldDropLoot = self.DropLoot
	function self:DropLoot(...)
        if self.inst.e_NoLootdropper ~= nil then
            return
        else
			_oldDropLoot(self,...)
		end
	end
end)

----月台效果
AddPrefabPostInit("moonbase", function(inst)
	local OldGetDisplayName = inst.GetDisplayName
	inst.GetDisplayName = function(self, ...)
		local str = ""
		if inst.replica.gwen_moon then
			if inst.replica.gwen_moon:Getmoon_Level() == 2 and inst.replica.gwen_moon:Getmooning() == 0 then
				str = str.."\n(给予彩虹宝石激活仪式)"
			elseif inst.replica.gwen_moon:Getmoon_Level() == 2 and inst.replica.gwen_moon:Getmooning() == 1 then
				str = str.."\n(仪式进行中..)"
			else
				str = ""
			end
		end
		return OldGetDisplayName(self, ...)..str
	end

	inst:AddComponent("talker")
	inst.components.talker.fontsize = 28
	inst.components.talker.offset = Vector3(0, -324, 0)
	inst.components.talker.colour = Vector3(1, .7, .7, 1)

	if TheWorld.ismastersim then
		if not inst.components.gwen_moon then
			inst:AddComponent("gwen_moon")
		end

		local oldabletoaccepttest = inst.components.trader.abletoaccepttest
        inst.components.trader.abletoaccepttest =  function(inst, item)
			if item.prefab == "gw_refactor_0" then
				return true
			end
			return oldabletoaccepttest(inst, item)
		end

		local oldonaccept = inst.components.trader.onaccept
        inst.components.trader.onaccept =  function(inst, giver, item)
			oldonaccept(inst, giver, item)
			if item.prefab == "gw_refactor_0" then
				if inst.components.gwen_moon then
					inst.components.gwen_moon:Setmoon_Level(2)
					inst.components.gwen_moon:gw_refactor_0()
				end
			end
		end

		local oldonpickedfn = inst.components.pickable.onpickedfn
        inst.components.pickable.onpickedfn =  function(inst, picker, loot)
			oldonpickedfn(inst, picker, loot)
			if inst.components.gwen_moon then
				inst.components.gwen_moon:Restemoon_Level()
			end
		end
	end

	inst:ListenForEvent("ms_playerjoined",function()
		inst:DoTaskInTime(.33,function()
			if inst.components.gwen_moon then
				if inst.components.gwen_moon:Getmoon_Level() == 2 then
					inst.AnimState:OverrideSymbol("swap_staffs", "gw_refactor_0", "gw_refactor_0")
					inst.components.gwen_moon:Replace("gw_refactor_0")
				elseif inst.components.gwen_moon:Getmoon_Level() == 3 then
					inst.AnimState:OverrideSymbol("swap_staffs", "gw_refactor_3", "gw_refactor_3")
					inst.components.gwen_moon:Replace("gw_refactor_3")
				end
			end
		end)
	end, TheWorld)

end)


----棱彩重构文字描述
AddPrefabPostInitAny(function(inst)
	local OldGetDisplayName = inst.GetDisplayName
	inst.GetDisplayName = function(self, ...)
		local str = ""
		if inst.replica.gwen_refactor then
			if inst.replica.gwen_refactor:Getgw_Permanent() == 1 then
				str = str.."-棱彩级"
			else
				str = "\n(可棱彩重构)"
			end
		end
		return OldGetDisplayName(self, ...)..str
	end
end)

----添加棱彩重构
local function gwen_refactor(inst)
	if not TheWorld.ismastersim then
        return inst
    end
    if not inst.components.gwen_refactor then
		inst:AddComponent("gwen_refactor")
	end
end

GLOBAL.TUNING.GW_REFACTOR_ENABLE = true
GLOBAL.GW_REFACTOR = gwen_refactor

----棱彩重构白名单
local gwen_refactor_item = {
	"gw_tasui",							---踏碎
	"gw_muhun",							----牧魂

	"lol_wp_divine",					----神圣分离者
	"alchemy_chainsaw",					----炼金朋克链锯
	"gallop_blackcutter",				----黑切
	"lol_wp_s10_guinsoo",				----狂暴之刃
	"lol_wp_s13_infinity_edge",			----无尽战刃
	"lol_wp_s13_infinity_edge_amulet",	----无尽战刃
	"lol_wp_trinity",					----三相之力
	"riftmaker_weapon",					----峡谷制造者
	"riftmaker_amulet",					----峡谷制造者
	"roaminggun",						----华丽漫游
	"blacksword",						----黑剑●重塑
	"nashor_tooth",						----纳什之牙
	"lol_wp_overlordbloodarmor",		----霸王血铠
	"lol_wp_demonicembracehat",			----恶魔之拥
	"lol_wp_s10_guinsoo",				----鬼索的狂暴之刃
	"lol_wp_s13_statikk_shiv_charged",	----斯塔缇克电刀
	"lol_wp_s17_luden",					----卢登的回声

	"xingyan_sickle",					----星衍巨镰
	"xingyan_greatsword",				----星衍重剑
	"xingyan_bow",						----星衍弓箭
	"tailaren",							----泰拉刃
	"yongyeren",						----永夜刃
	"moguchangmao",						----蘑菇长矛
	"terrariazenith",					----天顶剑
	"linghuatianguang",					----灵晔天光

	"soul_harvester",					----狗头的权杖

}

for g, v in pairs(gwen_refactor_item) do
	AddPrefabPostInit(v, gwen_refactor)
end

----棱彩攻击加成
AddComponentPostInit("combat", function(self)
    local old_GetAttacked = self.GetAttacked
    function self:GetAttacked(attacker, damage, weapon, stimuli, spdamage)
        local target = self.inst
		local owner = attacker

		if damage == nil then
            damage = 0
            print("byd别打你那个破蜈蚣了") ------（蜈蚣传入伤害有问题，传入到下方的damage变成了nil，所以判定一下当为nil时=0）
        end

		if owner and owner:HasTag("player") and owner.components.health and not owner.components.health:IsDead() and not owner:HasTag("playerghost") then 
			local doer = owner and owner.components.inventory
			local weapon = doer and doer:GetEquippedItem(EQUIPSLOTS.HANDS)

			if weapon ~= nil and weapon.components.gwen_refactor and weapon.components.gwen_refactor:Getgw_Permanent() == 1 then
				damage = damage * TUNING.GW_LENGCAIJIACHENG
			end
		end
		return old_GetAttacked(self, attacker, damage, weapon, stimuli, spdamage)
	end
end)


----快速制作
local function gw_taozhuang_nvpu(self, action)
    if self and self.actionhandlers and self.actionhandlers[action] then
        local old = self.actionhandlers[action].deststate
        self.actionhandlers[action].deststate = function(inst, action, ...)
            if action and action.doer and action.doer.gw_taozhuang_nvpu ~= nil then
                if action.recipe and (action.recipe:find("myth_fly"))  then
                    if type(old) == "string" then
                        return old
                    end
                    return old(inst, action, ...)
                end
                return "doshortaction"
            end
            if type(old) == "string" then
                return old
            end
            return old(inst, action, ...)
        end
    end
end

----快速种植
local function gw_taozhuang_yuanding(self, action)
    if self and self.actionhandlers and self.actionhandlers[action] then
        local old = self.actionhandlers[action].deststate
        self.actionhandlers[action].deststate = function(inst, act, ...)
            if act and act.doer and act.doer.gw_taozhuang_yuanding ~= nil then
                return "doshortaction"
            end
            if type(old) == "string" then
                return old
            end
            return old(inst, act, ...)
        end
    end
end

----套装建造速度增加
AddStategraphPostInit("wilson", function(self)
    gw_taozhuang_nvpu(self,ACTIONS.BUILD)	----制作
	gw_taozhuang_yuanding(self,ACTIONS.PLANTSOIL)	----种植
end)

AddStategraphPostInit("wilson_client", function(self)
    gw_taozhuang_nvpu(self,ACTIONS.BUILD)	----制作
	gw_taozhuang_yuanding(self,ACTIONS.PLANTSOIL)	----种植
end)

AddPlayerPostInit(function(inst)
	inst:ListenForEvent("working", function(inst, data)
		if inst and inst.gw_taozhuang_nvpu ~= nil 
		and data.target and data.target:HasTag("MINE_workable")
		and math.random() < .1
		then
			local workable = data.target and data.target.components.workable
            workable.workleft = 0
        end
    end)
end)


-----------------------------------------------------------------------------
-- ----圣诞套装的礼物效果
-- ---给世界一个任务，每天早上给套装玩家发个礼物
-- AddPrefabPostInit("world", function(inst)
--     if not TheWorld.ismastersim then return end
    
--     inst:WatchWorldState("phase", function()
--         if TheWorld.state.phase == "day"     -----是黎明
--             and TheWorld.state.iswinter      -----是冬天
--         then

--             local weight_pool = {}
--             local level_items = {
--                 {weight = 50, items = {
--                     "charcoal",      -- 木炭
--                     "goldnugget",    -- 金块
--                     "cutstone",      -- 石砖
--                     "boards",        -- 木板
--                     "rope",          -- 绳子
--                     "marble",        -- 大理石
--                     "moonrocknugget" -- 月岩
--                 }},

--                 {weight = 35, items = {
--                     "gears",         -- 齿轮
--                     "purplegem",     -- 紫宝石
--                     "greengem",      -- 绿宝石
--                     "yellowgem",     -- 黄宝石
--                     "orangegem",     -- 橙宝石
--                     "bluegem",       -- 蓝宝石
--                     "redgem"         -- 红宝石
--                 }},

--                 {weight = 12, items = {
--                     "deerclops_eyeball", -- 巨鹿眼球
--                     "dragon_scales",     -- 龙鳞
--                     "minotaurhorn",      -- 犀牛角
--                     "shroom_skin",       -- 蘑菇皮
--                     "bearger_fur",       -- 熊皮
--                     "royal_jelly",       -- 蜂王浆
--                     "walrus_tusk"        -- 海象牙
--                 }},

--                 {weight = 3, items = {
--                     "krampus_sack"       -- 坎普斯背包
--                 }}
--             }
            
--             -- 构建一下权重
--             for _, level in ipairs(level_items) do
--                 for _, item in ipairs(level.items) do
--                     table.insert(weight_pool, {item = item, weight = level.weight})
--                 end
--             end
            
--             -- 冬季盛宴小零食（为什么没有4的水果蛋糕呢好难猜）
--             local winter_foods = {
--                 "winter_food1", "winter_food2", "winter_food3",
--                 "winter_food5", "winter_food6", "winter_food7", 
--                 "winter_food8", "winter_food9"
--             }
            
--             for _, player in ipairs(AllPlayers) do
--                 if player.gw_taozhuang_shengdan == true then
--                     local logs = {}
--                     local selected_prefabs = {}
                    
--                     -- 三个冬季盛宴食物
--                     for i = 1, 3 do
--                         table.insert(selected_prefabs, winter_foods[math.random(1, #winter_foods)])
--                     end
                    
--                     -- 第四个物品从权重中随机选择一个
--                     local total_weight = 0
--                     for _, data in ipairs(weight_pool) do
--                         total_weight = total_weight + data.weight
--                     end
                    
--                     local random_point = math.random(1, total_weight)
--                     local current_weight = 0
--                     local special_item = nil
                    
--                     for _, data in ipairs(weight_pool) do
--                         current_weight = current_weight + data.weight
--                         if random_point <= current_weight then
--                             special_item = data.item
--                             break
--                         end
--                     end
                    
--                     if special_item then
--                         table.insert(selected_prefabs, special_item)
--                     end

--                     for i = 1, 4 do
--                         local item_name = selected_prefabs[i]
--                         local item = SpawnPrefab(item_name)
--                         if item then
--                             table.insert(logs, item)
--                         end
--                     end

--                     local gift = SpawnPrefab("gift")
--                     if gift and gift.components.unwrappable then
--                         gift.components.unwrappable:WrapItems(logs)
--                         if player.components.inventory then
--                             player.components.inventory:GiveItem(gift)
--                         end
--                     end
--                 end
--             end
--         end
--     end)
-- end)


-----------------------------------------------------------------------------
---给世界加一个生物死亡掉魂的监听
AddPrefabPostInit("world", function(inst)
    if not TheWorld.ismastersim then return end

    local gw_soul_common = require("prefabs/gw_soul_common")
    
    local function IsValidVictim(victim, explosive)
        return gw_soul_common.HasSoul(victim) and (victim.components.health:IsDead() or explosive)
    end
    
    local function OnRestoreSoul(victim)
        victim.world_soul_generated = nil
    end
    
    local function OnEntityDropLootForWorld(victim, data)
        if not victim or victim.world_soul_generated or not victim:IsValid() then
            return
        end

        if IsValidVictim(victim, data.explosive) then
            victim.world_soul_generated = victim:DoTaskInTime(5, OnRestoreSoul)
            gw_soul_common.SpawnSoulsAt(victim, gw_soul_common.GetNumSouls(victim))
        end
    end
    
    local function OnEntityDeathForWorld(victim, data)
        if victim ~= nil then
            victim._soulsource = data.afflicter
            if (victim.components.lootdropper == nil or 
                victim.components.lootdropper.forcewortoxsouls or 
                data.explosive) then
                OnEntityDropLootForWorld(victim, data)
            end
        end
    end
    
    inst:ListenForEvent("entity_death", function(world, data)
        if data and data.inst then
            OnEntityDeathForWorld(data.inst, data)
        end
    end)
    
    inst:ListenForEvent("entity_droploot", function(world, data)
        if data and data.inst then
            OnEntityDropLootForWorld(data.inst, data)
        end
    end)
end)


-----------------------------------------------------------------------------
---克劳斯掉落号角
---遍历，确保唯一
-- local function IsHaoJiaoExists()
--     local entities = TheSim:FindEntities(0,0,0, 10000, {"gwen_haojiao"})
--     for _, ent in ipairs(entities) do
--         if ent.prefab == "gwen_haojiao" then
--             return true
--         end
--     end
--     return false
-- end

-- local function AddHaoJiaoLoot(inst)
--     if not TheWorld.ismastersim then
--         return inst
--     end
--     if inst and inst.components.lootdropper then
--         local old_GenerateLoot = inst.components.lootdropper.GenerateLoot
--         inst.components.lootdropper.GenerateLoot = function(self, ...)
--             local loot = old_GenerateLoot(self, ...)
--             if not IsHaoJiaoExists() then
--                 table.insert(loot, "gwen_haojiao")
--             end
--             return loot
--         end
--     end
-- end

-- AddPrefabPostInit("klaus", AddHaoJiaoLoot)


-----------------------------------------------------------------------------------------------
-----改变号角的施法动作
AddStategraphPostInit("wilson", function(sg)
    local old_CASTAOE = sg.actionhandlers[ACTIONS.CASTAOE].deststate
    sg.actionhandlers[ACTIONS.CASTAOE].deststate = function(inst, action, ...)
        if action.invobject ~= nil and action.invobject:HasTag("gwen_haojiao") then
            return "play_horn"
        end
        return old_CASTAOE(inst, action, ...)
    end
end)

AddStategraphPostInit("wilson_client", function(sg)
    local old_CASTAOE = sg.actionhandlers[ACTIONS.CASTAOE].deststate
    sg.actionhandlers[ACTIONS.CASTAOE].deststate = function(inst, action, ...)
        if action.invobject ~= nil and action.invobject:HasTag("gwen_haojiao") then
            return "play_horn"
        end
        return old_CASTAOE(inst, action, ...)
    end
end)


-----------------------------------------------------------------------------------------------
----给蘸豆头2的护目镜移除滤镜
AddClassPostConstruct(
    'widgets/gogglesover',
    function(widget)
        local oldToggleGoggles = widget.ToggleGoggles
        widget.ToggleGoggles = function(s, show, ...)
            local owner = s.owner
            local forceHide = false
            if owner and owner.replica and owner.replica.inventory then
                local headItem = owner.replica.inventory:GetEquippedItem(GLOBAL.EQUIPSLOTS.HEAD)
                if headItem and headItem:HasTag("gw_fuzhuang") and headItem:HasTag("goggles") then
                    forceHide = true
                end
            end

            if forceHide then
                oldToggleGoggles(s, false, ...)
            else
                oldToggleGoggles(s, show, ...)
            end
        end
    end
)

-----------------------------------------------------------------------------------------------
----生成坟墓
local function SpawnGraveAtPos(pos)
    local grave = SpawnPrefab("gw_grave")
    if grave ~= nil then
        grave.Transform:SetPosition(pos:Get())
        local fx = SpawnPrefab("maxwell_smoke")
        if fx ~= nil then
            fx.Transform:SetPosition(pos:Get())
        end
    end
end

-- 尝试在玩家周围生成坟墓
local function TrySpawnGraveAroundPlayer()
    local graves = TheSim:FindEntities(0, 0, 0, 10000, {"gw_grave"})
    if #graves >= 6 then
        return
    end

    local player = nil
    for i, v in ipairs(AllPlayers) do
        if v ~= nil and v.entity:IsVisible() and not v:HasTag("playerghost") and not v.components.health:IsDead() then
            player = v
            break
        end
    end
    if player == nil then
        return
    end

    local x, y, z = player.Transform:GetWorldPosition()
    local ground = TheWorld

    for attempt =  1, 12 do
        local distance = 30 + math.random() * 90
        local angle = math.random() * 2 * math.pi
        local offset_x = math.cos(angle) * distance
        local offset_z = math.sin(angle) * distance
        local pos = Vector3(x + offset_x, 0, z + offset_z)
        if ground.Map:IsAboveGroundAtPoint(pos:Get()) and
            ground.Pathfinder:IsClear(x, 0, z, pos.x, 0, pos.z, { ignorewalls = true }) and
            #TheSim:FindEntities(pos.x, pos.y, pos.z, 1) <= 0 and
            not ground.Map:IsPointNearHole(pos) then
            SpawnGraveAtPos(pos)
            return
        end
    end
end
local function SpawnGraveAroundPlayerEx(player, minDist, maxDist, maxAttempts)
    if not player then return false end
    local x, y, z = player.Transform:GetWorldPosition()
    for _ = 1, maxAttempts or 12 do
        local angle = math.random() * 2 * math.pi
        local dist = minDist + math.random() * (maxDist - minDist)
        local pos = Vector3(x + math.cos(angle) * dist, 0, z + math.sin(angle) * dist)
        if TheWorld.Map:IsAboveGroundAtPoint(pos:Get()) and
           TheWorld.Pathfinder:IsClear(x,0,z, pos.x,0,pos.z, {ignorewalls=true}) and
           #TheSim:FindEntities(pos.x,pos.y,pos.z, 1) == 0 and
           not TheWorld.Map:IsPointNearHole(pos) then
            SpawnGraveAtPos(pos)
            return true
        end
    end
    return false
end

---世界的生成任务
local function OnWorldCycleChanged()
    --- 别在洞穴和火山里生成了，我怕不知名bug
    if not (TheWorld.ismastersim and not TheWorld:HasOneOfTags({"cave","volcano"})) then
        return
    end
    local cycles = TheWorld.state.cycles

    if cycles < 3 and not TheWorld.gwen_initial_graves then
        local graves = TheSim:FindEntities(0,0,0, 10000, {"gw_grave"})
        local needed = math.max(0, 3 - #graves)
        if needed > 0 then
            for _, v in ipairs(AllPlayers) do
                if v and v.entity:IsVisible() and not v:HasTag("playerghost") and not v.components.health:IsDead() then
                    for _ = 1, needed do
                        SpawnGraveAroundPlayerEx(v, 50, 999, 20)
                    end
                    break
                end
            end
        end
        TheWorld.gwen_initial_graves = true
    end
    if cycles % 5 == 0 then
        TrySpawnGraveAroundPlayer()
    end
end

AddPrefabPostInit("world", function(inst)
    if TheWorld.ismastersim then
        inst:WatchWorldState("cycles", OnWorldCycleChanged)
    end
end)