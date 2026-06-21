local left_x = -211
local midleft_x = -48
local midright_x = 38
local right_x = 165

local pos_y = 176

local ORDERS =
{
    {"E",           { -215 + 18   , 176 + 30 }},
	{"V",         { -90 + 18   , 176 + 30 }},
	{"I",         { 38 + 18   , 176 + 30 }},
	{"L",         { 165 + 18   , 176 + 30 }},

}

--------------------------------------------------------------------------------------------------

local function BuildSkillsData(SkillTreeFns)
    local skills = 
    {	 
		mevileyes_hope = {
            title = "Light of Hope",
            desc = "Nearby allies recover a small amount of sanity.",
            icon = "wilson_torch_brightness_1",
            pos = {left_x + 15 , pos_y -10 },
            group = "E",
            tags = {"Hope"},
			root = true,
            onactivate = function(inst, fromload)
				inst:AddComponent("sanityaura")
				inst.components.sanityaura.aura = TUNING.SANITYAURA_TINY
			end,
			ondeactivate = function(inst, fromload)
				inst:RemoveComponent("sanityaura")
            end			
        },
		mevileyes_introvert = {
            title = "introvert+",
            desc = "More sanity regen 50% when alone.",
            icon = "willow_berniehealth_2",
			pos = {left_x + 35 + 35 -15, pos_y -10},
            group = "E",			
			tags = {"introvert"},
			root = true,
			onactivate = function(inst, fromload)
                inst.introvert = 1.5
            end,
			ondeactivate = function(inst, fromload)
				inst.introvert = nil			
            end,      
        },		
--------------------------------------------------------------		
		mevileyes_friend_lock = {
			desc = "Learn 2 skills to unlock.",
            pos = {left_x +15 , pos_y -15 - 34},
            group = "E",
            tags = {"evileyes_item","lock"},
			root = true,
            lock_open = function(prefabname, activatedskills, readonly)
                return SkillTreeFns.CountSkills(prefabname, activatedskills) >= 2
            end,
            connects = {                
				"mevileyes_friend",
            }			
        },

		mevileyes_friend = {
            title = "Energy",
            desc = "1 nearby player don't drain your sanity.",
            icon = "winona_battery_efficiency_1",
            pos = {left_x +15, pos_y -10 - 34 -34},            
            group = "E",
            tags = {"evileyes_friend"},			
			onactivate = function(inst, fromload)
                inst.friendcount = 1	
            end,
			ondeactivate = function(inst, fromload)
				inst.friendcount = nil			
            end,
			connects = {                
				"mevileyes_friend2",
            }
        },
		
		mevileyes_friend2 = {
            title = "Energy+",
            desc = "2 nearby player don't drain your sanity.",
            icon = "winona_battery_efficiency_2",
            pos = {left_x +15, pos_y -10 - 34 -34 -34},            
            group = "E",
            tags = {"evileyes_friend"},
			onactivate = function(inst, fromload)
                inst.friendcount = 2	
            end,
			ondeactivate = function(inst, fromload)
				inst.friendcount = 1			
            end,
			connects = {                
				"mevileyes_friend3",
            }
        },
		
		mevileyes_friend3 = {
            title = "Energy++",
            desc = "3 nearby player don't drain your sanity.",
            icon = "winona_battery_efficiency_3",
            pos = {left_x +15, pos_y -10 - 34 -34 -34 -34},            
            group = "E",
            tags = {"evileyes_friend"},
			onactivate = function(inst, fromload)
                inst.friendcount = 3
            end,
			ondeactivate = function(inst, fromload)
				inst.friendcount = 2			
            end
        },

		mevileyes_mind_lock = {
			desc = "Learn 4 skills to unlock.",
            pos = {left_x + 35 + 35-15, pos_y -15 - 34},
            group = "E",
            tags = {"evileyes_shadow","lock"},
			root = true,
            lock_open = function(prefabname, activatedskills, readonly)
                return SkillTreeFns.CountSkills(prefabname, activatedskills) >= 4
            end,
            connects = {
                "mevileyes_mind"--"mevileyes_sailor","mevileyes_planardefense",			
            }
        },
		
		--mevileyes_sailor = {
        --    title = "Expert Sailor",
        --    desc = "More quickly do various boat-related actions.",
        --    icon = "wolfgang_planardamage_5",
        --    pos = {left_x + 35 + 35-15, pos_y -10 - 34 -34},            
        --    group = "V",
		--	tags = {"sailor"},
		--	onactivate = function(inst, fromload)                
		--		inst:AddComponent("expertsailor")
        --    end,
		--	ondeactivate = function(inst, fromload)
		--		inst:RemoveComponent("expertsailor")			
        --    end,			
        --},	
		--		
		--mevileyes_planardefense = {
        --    title = "Shadow Cloak",
        --    desc = "+5 Planar Defense.",
        --    icon = "wathgrithr_combat_defense",
        --    pos = {left_x + 35 + 35-15, pos_y -10 - 34  -34 -34},            
        --    group = "E",
        --    tags = {"evileyes_hand"},
		--	onactivate = function(inst, fromload)                
		--		if inst.components.planardefense ~= nil then
		--			inst.components.planardefense:AddBonus(inst, TUNING.SKILLS.WATHGRITHR.BONUS_PLANAR_DEF, "mevileyes_combat_defense")
		--		end
        --    end,
		--	ondeactivate = function(inst, fromload)
		--		if inst.components.planardefense ~= nil then
		--			inst.components.planardefense:RemoveBonus(inst, "mevileyes_combat_defense")
		--		end		
        --    end,
        --},
		
		mevileyes_mind = {
            title = "The Shadow Within",
            desc = "Resist Shadow Creatures Damage & +5 Planar Defense.",
            icon = "wx78_allegiance_shadow",
            --icon = "woodie_curse_weremeter_3",
            --icon = "wolfgang_allegiance_shadow_1",
			--pos = {left_x + 35 + 35-15, pos_y -10 - 34  -34 -34 -34},
			pos = {left_x + 35 + 35-15, pos_y -10 - 34 -34},
            group = "E",
            tags = {"mind",},
			
            onactivate = function(inst, fromload)
               local damagetyperesist = inst.components.damagetyperesist
                if damagetyperesist then
                    damagetyperesist:AddResist("shadow_aligned", inst, TUNING.SKILLS.WILSON_ALLEGIANCE_SHADOW_RESIST, "evileyes_shadow_resis")
                end
				
				if inst.components.planardefense ~= nil then
					inst.components.planardefense:AddBonus(inst, TUNING.SKILLS.WATHGRITHR.BONUS_PLANAR_DEF, "mevileyes_mind")
				end
            end,
			ondeactivate = function(inst, fromload)
				local damagetyperesist = inst.components.damagetyperesist
                if damagetyperesist then
                    damagetyperesist:RemoveResist("shadow_aligned", inst, "evileyes_shadow_resis")
                end
				
				if inst.components.planardefense ~= nil then
					inst.components.planardefense:RemoveBonus(inst, "mevileyes_mind")
				end		
            end,         
        },
				
	
---------------------------------------------------------------------------------------------				
		mevileyes_samuraixxx = {
            title = "Samurai helmet",
            desc = "Learn to craft Samurai helmet.",
            icon = "wathgrithr_arsenal_helmet_1",
            --icon = "wolfgang_allegiance_shadow_1",
			pos = {midleft_x-38 +18, pos_y },            
            group = "V",
            tags = {"samuraihelmet",},
			root = true,			
        },
		
		mevileyes_samurai_lock = {
			desc = "Unlock Samurai helmet+",
            pos = {midleft_x-38 -12, pos_y -10 -14 },
            group = "v",
            tags = {"lock"},
			root = true,
            lock_open = function(prefabname, activatedskills, readonly)
                return SkillTreeFns.CountTags(prefabname, "samuraihelmet", activatedskills) > 0 
            end,          
        },
		
		mevileyes_samuraix = {
            title = "Samurai helmet+",
            desc = "Samurai helmet more regen.",
            icon = "wathgrithr_arsenal_helmet_2",            
			pos = {midleft_x-38+18, pos_y -10 - 34 },
            group = "V",
            tags = {"samuraihelmet"},
			locks = {"mevileyes_samurai_lock"},
			connects = {
                "mevileyes_samuraixx",				
            }
        },
		
		mevileyes_samuraixx = {
            title = "Samurai helmet++",
            desc = "Samurai helmet less drain sanity.",
            icon = "wathgrithr_arsenal_helmet_4",
            pos = {midleft_x-38+18, pos_y -10 - 34 -34},            
            group = "V",
            tags = {"samuraihelmet"},				
        },
		
		 -- Medic
		mevileyes_medic = {
            title = "Calm Mind",
            desc = "Use healing items faster and with a 50% bonus to their effects.",
            icon = "wurt_amphibian_healing_2",            
			pos = {midleft_x+38 -18, pos_y },
            group = "V",
            tags = {"scouthealer"},			
			root = true,
			onactivate = function(inst, fromload)
                inst:AddTag("fasthealer")		
                if inst.components.efficientuser == nil then
                    inst:AddComponent("efficientuser")
                end		
                inst.components.efficientuser:AddMultiplier(ACTIONS.HEAL, TUNING.SKILLS.WALTER.HEALERS_EFFECTIVENESS_MODIFIER, "evileyes_camp_firstaid")
            end,		
            ondeactivate = function(inst, fromload)
                inst:RemoveTag("fasthealer")		
                if inst.components.efficientuser ~= nil then
                    inst.components.efficientuser:RemoveMultiplier(ACTIONS.HEAL, "evileyes_camp_firstaid")
                end
            end
			
        },
		
        mevileyes_shadow_armor = {
            title = "Inner Shadow+",
            desc = "Inner equipment +5 Planar Defense & more movement speed 5%.",
            --icon = "wx78_allegiance_shadow",
            icon = "woodie_curse_weremeter_3",
            pos = {midleft_x+38-18, pos_y -10 - 34},           
            group = "V",
            tags = {"bushi"},
            root = true,
            --connects = {                
            --    "mevileyes_katana_mobility",                
            --},
        },
        mevileyes_katana_mobility = {
            title = "Samurai Step",
            desc = "Netra's weapon more movement speed 10%.",
            icon = "wilson_alchemy_1",
            pos = {midleft_x+38-18,pos_y -10 - 34 -34},
            group = "V",
            tags = {"bushi"},
			root = true,
        },
				
		mevileyes_minion_speed = {
            title = "Minion Speed+",
            desc = "Shadow minion gain movement speed 25%.",
            icon = "wolfgang_speed",
            pos = {midleft_x, pos_y -20 - 34 -34 -34},          
            group = "shadowminion",
            tags = {"minion_speed"},			
			root = true,
        },
				
		mevileyes_minion_armor = {
            title = "Minion Armor",
            desc = "Shadow minion gain damage reduction 25%.",
            icon = "wolfgang_allegiance_shadow_2",
            pos = {midleft_x - 35, pos_y -20 - 34 -34 -34},             
            group = "shadowminion",
            tags = {"minion_armor"},
			root = true,
			onactivate = function(inst, fromload)					
				inst.myshadowdef = .25
			end,
			ondeactivate = function(inst, fromload)
				inst.myshadowdef = nil
            end     
        },
		
		mevileyes_minion_armor_lock = {
			desc = "Unlock Minion Armor+",
            pos = {midleft_x - 35, pos_y -20 - 34 -34 -34 -34},
            group = "I",
            tags = {"lock"},
			root = true,
            lock_open = function(prefabname, activatedskills, readonly)
                return SkillTreeFns.CountTags(prefabname, "minion_armor", activatedskills) > 0 
            end,          
        },
		
		mevileyes_minion_attacker = {
            title = "Minion Duelist",
            desc = "Shadow Duelist deal more damage 15%.",
            icon = "willow_berniesanity_1",
            pos = {midleft_x + 35, pos_y -20 - 34 -34 -34},            
            group = "shadowminion",
            tags = {"minion_attack"},
			root = true,
			onactivate = function(inst, fromload)					
				inst.myshadowattack = 1.15
			end,
			ondeactivate = function(inst, fromload)
				inst.myshadowattack = nil
            end,
        },
		
		mevileyes_minion_attacker_lock = {
			desc = "Unlock Minion Duelist+",
            pos = {midleft_x + 35, pos_y -20 - 34 -34 -34 -34},
            group = "I",
            tags = {"lock"},
			root = true,
            lock_open = function(prefabname, activatedskills, readonly)
                return SkillTreeFns.CountTags(prefabname, "minion_attack", activatedskills) > 0 
            end,		
        },        
		------------------------------------------------------------------------------

		mevileyes_scales_lock = {
			desc = "Learn 5 skills to unlock.",
            pos = {midright_x + 40, pos_y -10 - 34 - 34},
            group = "I",
            tags = {"lock"},
			root = true,
            lock_open = function(prefabname, activatedskills, readonly)
                return SkillTreeFns.CountSkills(prefabname, activatedskills) >= 6
            end,
            connects = {
                "mevileyes_itemregen","mevileyes_6sense","mevileyes_litlecrow"--,"mevileyes_darkmagic"            			
            }
        },
		
		--mevileyes_darkmagic = {
        --    title = "Dark Magic",
        --    desc = "Can repair shadow weapon while insane.",
        --    icon = "wortox_favor_shadow",
		--	pos = {midright_x + 40, pos_y -10 - 34},                      
        --    group = "I",
        --    tags = {"evileyes_shadow"},				
        --},

		mevileyes_itemregen = {
            title = "Netra Weapon+",
            desc = "Netra's weapon more repair.",
            icon = "walter_ammo_utility",
			pos = {midright_x + 5, pos_y -10 - 34 - 34},
            group = "I",
            tags = {"evileyes_item"},			
        },
		
        mevileyes_6sense = {
            title = "Sixth Sense",
            desc = "Can dodge Charlie's hit 1 time & +5 Planar Defense.",
            icon = "winona_charlie_2",
            --icon = "woodie_curse_master",
			pos = {midright_x + 75, pos_y -10 - 34 - 34},
            group = "I",			
			tags = {"noqueen"},			
			onactivate = function(inst, fromload)
                inst.components.grue:SetResistance(1)
				if inst.components.planardefense ~= nil then
					inst.components.planardefense:AddBonus(inst, TUNING.SKILLS.WATHGRITHR.BONUS_PLANAR_DEF, "mevileyes_6sense")
				end
				
            end,
			ondeactivate = function(inst, fromload)
				inst.components.grue:SetResistance(nil)
				if inst.components.planardefense ~= nil then
					inst.components.planardefense:RemoveBonus(inst, "mevileyes_6sense")
				end
				
							
            end,      
        },
		
		mevileyes_litlecrow = {
            title = "Lightningpiercer",
            desc = "Learn to craft the legendary sword Kogarasumaru.",
            icon = "wortox_scales",
            pos = {midright_x + 40, pos_y -10 - 34 -34 - 34},
            group = "I",
            tags = {"kogarasumaru",},
            
        },
		
		--mevileyes_eater = {
        --    title = "Value of Sustenance",
        --    desc = "Monster Tartare & Monster Lasagna are not affect Health & Sanity",
        --    icon = "wortox_scales",
        --    pos = {midright_x + 40, pos_y -10 - 34 -34 - 34},
        --    group = "I",
        --    tags = {"chefmaster",},
        --    onactivate = function(inst, fromload)					
		--		inst.components.foodaffinity:AddPrefabAffinity("monstertartare", 1.33) 
		--		inst.components.foodaffinity:AddPrefabAffinity("monsterlasagna", 1.33) 
		--	end,
		--	ondeactivate = function(inst, fromload)
		--		inst.components.foodaffinity:RemovePrefabAffinity("monstertartare") 
		--		inst.components.foodaffinity:RemovePrefabAffinity("monsterlasagna") 
        --    end,       
        --},
		
		--allegiance-----------------------------------------------------------------------------------
		mevileyes_allegiance_lock_1 = {
			desc = "Learn 8 skills to unlock.",
            pos = {right_x + 15, pos_y  },
            group = "L",
            tags = {"allegiance","lock"},
			root = true,
            lock_open = function(prefabname, activatedskills, readonly)
                return SkillTreeFns.CountSkills(prefabname, activatedskills) >= 8
            end,
            connects = {
                "mevileyes_allegiance_lock_2",				
            }
        },
		mevileyes_allegiance_lock_2 = {
			desc = STRINGS.SKILLTREE.ALLEGIANCE_LOCK_2_DESC,            
            pos = {right_x + 45, pos_y   },
            group = "L",
            tags = {"allegiance","lock"},
			--root = true,			
            lock_open = function(prefabname, activatedskills, readonly) 
                if readonly then
                    return "question"
                end

                return TheGenericKV:GetKV("fuelweaver_killed") == "1"
            end,
            connects = {
                "mevileyes_allegiance_shadow"
            }
        },
				
		mevileyes_crazy = {
            title = "Minion Master",
            desc = "Shadow Duelist can attack shadow creature when insane.",
            icon = "willow_bernieai",
            pos = {right_x + 30, pos_y - 34},            
            group = "L",
            tags = {"allegiance"},
			locks = {"mevileyes_allegiance_lock_1","mevileyes_allegiance_lock_2"},
        },
		
		mevileyes_minion_armor2 = {
            title = "Minion Armor+",
            desc = "Shadow minion gain damage reduction 50%.",
            icon = "willow_allegiance_shadow_bernie",
            pos = {right_x +30, pos_y - 34 -34},            
            group = "shadowminion",
            tags = {"allegiance"},
			locks = {"mevileyes_allegiance_lock_1","mevileyes_allegiance_lock_2","mevileyes_minion_armor_lock"},
			onactivate = function(inst, fromload)					
				inst.myshadowdef = .5
			end,
			ondeactivate = function(inst, fromload)
				inst.myshadowdef = .25
            end,       
        },
		
		mevileyes_minion_attacker2 = {
            title = "Minion Duelist+",
            desc = "Shadow Duelist deal more damage 25%.",
            icon = "willow_berniesanity_2",
            pos = {right_x +30, pos_y - 34 -34 -34},            
            group = "shadowminion",
            tags = {"allegiance"},
			locks = {"mevileyes_allegiance_lock_1","mevileyes_allegiance_lock_2","mevileyes_minion_attacker_lock"},
			onactivate = function(inst, fromload)
				inst.myshadowattack = 1.25
			end,
			ondeactivate = function(inst, fromload)
				inst.myshadowattack = 1.15
            end,       
        },

		mevileyes_allegiance_shadow = {	--allegiance skill 2 Shadow
            title = "Izanami's Grace",
            desc = "Resist shadows and strike harder against the lunar forces, Shadow Reaper can aoe attack to target for 12 second after used Warp Skill, While insane every hit repair shadow weapon", -- Shadow Item not drain sanity & 
            icon = "wilson_favor_shadow",
            pos = {right_x + 30, pos_y  - 34 -34 -34 -34},
            group = "L",
            tags = {"shadow_favor","allegiance","shadow"},
			locks = {"mevileyes_allegiance_lock_1","mevileyes_allegiance_lock_2"},
            onactivate = function(inst, fromload)
                inst:AddTag("player_shadow_aligned")
                local damagetyperesist = inst.components.damagetyperesist
                if damagetyperesist then
                    damagetyperesist:AddResist("shadow_aligned", inst, TUNING.SKILLS.WILSON_ALLEGIANCE_SHADOW_RESIST, "evileyes_allegiance_shadow")
                end
                local damagetypebonus = inst.components.damagetypebonus
                if damagetypebonus then
                    damagetypebonus:AddBonus("lunar_aligned", inst, TUNING.SKILLS.WILSON_ALLEGIANCE_VS_LUNAR_BONUS, "evileyes_allegiance_shadow")
					damagetypebonus:AddBonus("shadow_aligned", inst, TUNING.SKILLS.WILSON_ALLEGIANCE_VS_SHADOW_BONUS, "evileyes_allegiance_lunar")
                end
				--inst.shadowitemresist = true
            end,
            ondeactivate = function(inst, fromload)
                inst:RemoveTag("player_shadow_aligned")
                local damagetyperesist = inst.components.damagetyperesist
                if damagetyperesist then
                    damagetyperesist:RemoveResist("shadow_aligned", inst, "evileyes_allegiance_shadow")
                end
                local damagetypebonus = inst.components.damagetypebonus
                if damagetypebonus then
                    damagetypebonus:RemoveBonus("lunar_aligned", inst, "evileyes_allegiance_shadow")
                    damagetypebonus:RemoveBonus("shadow_aligned", inst, "evileyes_allegiance_lunar")
                end
				--inst.shadowitemresist = nil
            end,
        }
		
    }

    return {
        SKILLS = skills,
        ORDERS = ORDERS,
    }
end

--------------------------------------------------------------------------------------------------

return BuildSkillsData