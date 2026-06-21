
--English
require("speech/english/sdf_skilltree_strings")


local ORDERS =
{
    {"skull",           { -214+18   , 176 + 30 }},
    {"undeath",         { -62       , 176 + 30 }},
    {"backbone",        { 66+18     , 176 + 30 }},
    {"allegiance_sdf",  { 204       , 176 + 30 }},
}

--------------------------------------------------------------------------------------------------

local function BuildSkillsData(SkillTreeFns)
    local skills = 
    {

--Backbone
--Daring Dash
        sdf_backbone_lock_1 = {
	    desc = SKILLTREE.SDF.SDF_BACKBONE_LOCK_1_DESC,
            pos = {177,136}, --136
            group = "backbone",
            tags = {"backbone","lock"},
            root = true,
            lock_open = function(prefabname, activatedskills, readonly) 
                if readonly then
                    return "question"
                end

                return TheGenericKV:GetKV("sdf_warg_killed") == "1"
                --return true
            end,
            connects = {
                "sdf_backbone_1",
            },
        },

        sdf_backbone_1 = {
            title = SKILLTREE.SDF.SDF_BACKBONE_1_TITLE,
            desc = SKILLTREE.SDF.SDF_BACKBONE_1_DESC,
            icon = "wathgrithr_arsenal_shield_1",
            pos = {177,184},
            group = "backbone",
            tags = {"backbone"},
	    locks = {"sdf_backbone_lock_1"},
            onactivate = function(inst, fromload)
		--inst:AddTag("sdf_daring_dash")
	    end,
            connects = {
                "sdf_backbone_2",
                "sdf_backbone_3",
            },
        },


        sdf_backbone_2 = {
            title = SKILLTREE.SDF.SDF_BACKBONE_2_TITLE,
            desc = SKILLTREE.SDF.SDF_BACKBONE_2_DESC,
            icon = "wathgrithr_arsenal_shield_3",
            pos = {215,126},
            group = "backbone",
            tags = {"backbone"},
            onactivate = function(inst, fromload)
		--inst:AddTag("sdf_steadfast")
	    end,        
        },

        sdf_backbone_3 = {
            title = SKILLTREE.SDF.SDF_BACKBONE_3_TITLE,
            desc = SKILLTREE.SDF.SDF_BACKBONE_3_DESC,
            icon = "wathgrithr_arsenal_shield_2",
            pos = {139,126},
            group = "backbone",
            tags = {"backbone"},
            onactivate = function(inst, fromload)
		--inst:AddTag("sdf_vigor")
	    end,
        },


--Valor
        sdf_backbone_lock_2 = {
	    desc = SKILLTREE.SDF.SDF_BACKBONE_LOCK_2_DESC,
            pos = {215,88}, --88
            group = "backbone",
            tags = {"backbone","lock"},
            root = true,
            lock_open = function(prefabname, activatedskills, readonly) 
                if readonly then
                    return "question"
                end

                return TheGenericKV:GetKV("sdf_super_armour_collected") == "1"
                --return true
            end,
            connects = {
                "sdf_backbone_4",
            },
        },

        sdf_backbone_lock_3 = {
	    desc = SKILLTREE.SDF.SDF_BACKBONE_LOCK_3_DESC,
            pos = {139,88}, --88
            group = "backbone",
            tags = {"backbone","lock"},
            root = true,
            lock_open = function(prefabname, activatedskills, readonly) 
                if readonly then
                    return "question"
                end

                return TheGenericKV:GetKV("sdf_all_chalices_collected") == "1"
                --return true
            end,
            connects = {
                "sdf_backbone_4",
            },
        },

        sdf_backbone_4 = {
            title = SKILLTREE.SDF.SDF_BACKBONE_4_TITLE,
            desc = SKILLTREE.SDF.SDF_BACKBONE_4_DESC,
            icon = "wolfgang_autogym",
            pos = {177,88},
            group = "backbone",
            tags = {"backbone"},
	    locks = {"sdf_backbone_lock_2", "sdf_backbone_lock_3"},
            onactivate = function(inst, fromload)
		--inst:AddTag("sdf_valor")
	    end,          
        },


--Energy Bones
        sdf_backbone_lock_4 = {
	    desc = SKILLTREE.SDF.SDF_BACKBONE_LOCK_4_DESC,
            pos = {177,52}, --62
            group = "backbone",
            tags = {"backbone","lock"},
            root = true,
            lock_open = function(prefabname, activatedskills, readonly) 
                if readonly then
                    return "question"
                end

                return TheGenericKV:GetKV("sdf_bearger_killed") == "1"
                --return true
            end,
            connects = {
                "sdf_backbone_5",
            },
        },

        sdf_backbone_5 = {
            title = SKILLTREE.SDF.SDF_BACKBONE_5_TITLE,
            desc = SKILLTREE.SDF.SDF_BACKBONE_5_DESC,
            icon = "woodie_curse_moose_2",
            pos = {177,12},
            group = "backbone",
            tags = {"backbone"},
	    locks = {"sdf_backbone_lock_4"},
            onactivate = function(inst, fromload)
		--inst:AddTag("sdf_energy_bones")
		--Add planar defense
		if inst.components.planardefense ~= nil then
		    inst.components.planardefense:AddBonus(inst, TUNING.SDF_SKILLSET_BACKBONE_ENERGY_BONES_BONUS_PLANAR_DEF, "sdf_skilltree_energy_bones")
		end
	    end,
            ondeactivate = function(inst, fromload)
		--Remove planar defense
		if inst.components.planardefense ~= nil then
		    inst.components.planardefense:RemoveBonus(inst, "sdf_skilltree_energy_bones")
		end
            end,
        },

--Undeath
--Embalming
        sdf_undeath_1 = {
            title = SKILLTREE.SDF.SDF_UNDEATH_1_TITLE,
            desc = SKILLTREE.SDF.SDF_UNDEATH_1_DESC,
            icon = "wilson_alchemy_iky_1",
            pos = {36,126}, --130
            group = "undeath",
            tags = {"undeath"},
            onactivate = function(inst, fromload)
		--inst:AddTag("sdf_embalming_1")
	    end,
            root = true,
            connects = {
                "sdf_undeath_2",
            },
        },

        sdf_undeath_2 = {
            title = SKILLTREE.SDF.SDF_UNDEATH_2_TITLE,
            desc = SKILLTREE.SDF.SDF_UNDEATH_2_DESC,
            icon = "wilson_alchemy_iky_2",
            pos = {36,88},
            group = "undeath",
            tags = {"undeath"},
            onactivate = function(inst, fromload) 
		--inst:AddTag("sdf_embalming_2")
	    end,
            connects = {
                "sdf_undeath_3",
            },
        },

        sdf_undeath_3 = {
            title = SKILLTREE.SDF.SDF_UNDEATH_3_TITLE,
            desc = SKILLTREE.SDF.SDF_UNDEATH_3_DESC,
            icon = "wilson_alchemy_iky_3",
            pos = {36,50},
            group = "undeath",
            tags = {"undeath"},
            onactivate = function(inst, fromload) 
		--inst:AddTag("sdf_embalming_3")
	    end,
        },

--Culling
        sdf_undeath_4 = {
            title = SKILLTREE.SDF.SDF_UNDEATH_4_TITLE,
            desc = SKILLTREE.SDF.SDF_UNDEATH_4_DESC,
            icon = "wortox_thief_4",
            pos = {-3,126}, --130
            group = "undeath",
            tags = {"undeath"},
            onactivate = function(inst, fromload)
		--inst:AddTag("sdf_culling")
            end,        
            root = true,
        },

--Rites
        sdf_undeath_5 = {
            title = SKILLTREE.SDF.SDF_UNDEATH_5_TITLE,
            desc = SKILLTREE.SDF.SDF_UNDEATH_5_DESC,
            icon = "wormwood_blooming_speed1",
            pos = {-42,126},
            group = "undeath",
            tags = {"undeath"},
            onactivate = function(inst, fromload)
		--inst:AddTag("sdf_rites_1")
	    end,       
            root = true,
            connects = {
                "sdf_undeath_6",
            },
        },

        sdf_undeath_6 = {
            title = SKILLTREE.SDF.SDF_UNDEATH_6_TITLE,
            desc = SKILLTREE.SDF.SDF_UNDEATH_6_DESC,
            icon = "wormwood_blooming_speed2",
            pos = {-42,88},
            group = "undeath",
            tags = {"undeath"},
            onactivate = function(inst, fromload) 
		--inst:AddTag("sdf_rites_2")
	    end,
            connects = {
                "sdf_undeath_7",
            },
        },

        sdf_undeath_7 = {
            title = SKILLTREE.SDF.SDF_UNDEATH_7_TITLE,
            desc = SKILLTREE.SDF.SDF_UNDEATH_7_DESC,
            icon = "wormwood_blooming_speed3",
            pos = {-42,50},
            group = "undeath",
            tags = {"undeath"},
            onactivate = function(inst, fromload) 
		--inst:AddTag("sdf_rites_3")
	    end,
        },

--Professors Lab
        sdf_undeath_lock_1 = {
	    desc = SKILLTREE.SDF.SDF_UNDEATH_LOCK_1_DESC,
            pos = {-3,88},
            group = "undeath",
            tags = {"undeath","lock"},
            root = true,
            lock_open = function(prefabname, activatedskills, readonly)
                --return SkillTreeFns.CountSkills(prefabname, activatedskills) >= 8
		return false
		--return true
            end,
            connects = {
                "sdf_undeath_8",
            },
        },

        sdf_undeath_8 = {
            title = SKILLTREE.SDF.SDF_UNDEATH_8_TITLE,
            desc = SKILLTREE.SDF.SDF_UNDEATH_8_DESC,
            icon = "wilson_alchemy_1",
            pos = {-3,50}, --54
            group = "undeath",
            tags = {"undeath"},
	    locks = {"sdf_undeath_lock_1"},
            onactivate = function(inst, fromload)
		--inst:AddTag("sdf_professors_lab")
	    end,        
        },

--Freakshow
        sdf_undeath_lock_2 = {
	    desc = SKILLTREE.SDF.SDF_UNDEATH_LOCK_2_DESC,
            pos = {71,168}, --173
            group = "undeath",
            tags = {"undeath","lock"},
            root = true,
            lock_open = function(prefabname, activatedskills, readonly) 
                if readonly then
                    return "question"
                end

                return TheGenericKV:GetKV("sdf_twinofterror1_killed") == "1" and TheGenericKV:GetKV("sdf_twinofterror2_killed") == "1" and
			TheGenericKV:GetKV("sdf_mutateddeerclops_killed") == "1" and TheGenericKV:GetKV("sdf_mutatedwarg_killed") == "1" and
			TheGenericKV:GetKV("sdf_mutatedbearger_killed") == "1"
                --return true
            end,
            connects = {
                "sdf_undeath_9",
            },
        },

        sdf_undeath_9 = {
            title = SKILLTREE.SDF.SDF_UNDEATH_9_TITLE,
            desc = SKILLTREE.SDF.SDF_UNDEATH_9_DESC,
            icon = "wendy_makegravemounds",
            pos = {95,213},
            group = "undeath",
            tags = {"undeath"},
	    locks = {"sdf_undeath_lock_2"},
            onactivate = function(inst, fromload)
		--inst:AddTag("sdf_freakshow")
		inst:AddTag("sdf_wodens_brand_builder")
	    end,
            ondeactivate = function(inst, fromload)
		inst:RemoveTag("sdf_wodens_brand_builder")
            end,
        },

--Honor of Gallowmere
        sdf_undeath_lock_3 = {
	    desc = SKILLTREE.SDF.SDF_UNDEATH_LOCK_3_DESC,
            pos = {-77,168}, --173
            group = "undeath",
            tags = {"undeath","lock"},
            root = true,
            lock_open = function(prefabname, activatedskills, readonly) 
                if readonly then
                    return "question"
                end

                return TheGenericKV:GetKV("sdf_fates_arrow_survived") == "1"
                --return true
            end,
            connects = {
                "sdf_undeath_10",
            },
        },

        sdf_undeath_10 = {
            title = SKILLTREE.SDF.SDF_UNDEATH_10_TITLE,
            desc = SKILLTREE.SDF.SDF_UNDEATH_10_DESC,
            icon = "wendy_gravestone_1",
            pos = {-101,213}, --101
            group = "undeath",
            tags = {"undeath"},
	    locks = {"sdf_undeath_lock_3"},
            onactivate = function(inst, fromload)
		--inst:AddTag("sdf_honorofgallowmere")
		local helmItem = inst.components.inventory:GetEquippedItem(EQUIPSLOTS.HEAD)
		if helmItem then
		    if helmItem.prefab == "sdf_helmet" then
			helmItem.components.equippable.onequipfn(helmItem, inst)
		    end
		end
	    end,
            ondeactivate = function(inst, fromload)
		local helmItem = inst.components.inventory:GetEquippedItem(EQUIPSLOTS.HEAD)
		if helmItem then
		    if helmItem.prefab == "sdf_helmet" then
			helmItem.components.equippable.onunequipfn(helmItem, inst)
		    end
		end
            end,
        },

--Time Dilation Runesmith
        sdf_undeath_lock_4 = {
	    desc = SKILLTREE.SDF.SDF_UNDEATH_LOCK_4_DESC,
            pos = {36,168},
            group = "undeath",
            tags = {"undeath","lock"},
            root = true,
            lock_open = function(prefabname, activatedskills, readonly) 
                if readonly then
                    return "question"
                end

                return TheGenericKV:GetKV("sdf_cave_chalices_collected") == "1"
                --return true
            end,
            connects = {
                "sdf_undeath_11",
            },
        },
        sdf_undeath_lock_5 = {
	    desc = SKILLTREE.SDF.SDF_UNDEATH_LOCK_5_DESC,
            pos = {-42,168},
            group = "undeath",
            tags = {"undeath","lock"},
            root = true,
            lock_open = function(prefabname, activatedskills, readonly) 
                if readonly then
                    return "question"
                end

                return TheGenericKV:GetKV("sdf_overworld_chalices_collected") == "1"
                --return true
            end,
            connects = {
                "sdf_undeath_11",
            },
        },
        sdf_undeath_11 = {
            title = SKILLTREE.SDF.SDF_UNDEATH_11_TITLE,
            desc = SKILLTREE.SDF.SDF_UNDEATH_11_DESC,
            icon = "woodie_curse_weremeter_3",
            pos = {-3,168},
            group = "undeath",
            tags = {"undeath"},
	    locks = {"sdf_undeath_lock_4","sdf_undeath_lock_5"},
            onactivate = function(inst, fromload)
		--inst:AddTag("sdf_time_dilation_runesmith")
		inst:AddTag("sdf_time_rune_builder")
	    end,
            ondeactivate = function(inst, fromload)
		inst:RemoveTag("sdf_time_rune_builder")
            end,
        },

--Skull
--Eye of Amon Ra
        sdf_skull_lock_1 = {
	    desc = SKILLTREE.SDF.SDF_SKULL_LOCK_1_DESC,
            pos = {-180,136}, --136
            group = "skull",
            tags = {"skull","lock"},
            root = true,
            lock_open = function(prefabname, activatedskills, readonly) 
                if readonly then
                    return "question"
                end

                return TheGenericKV:GetKV("sdf_eyeofterror_killed") == "1"
                --return true
            end,
            connects = {
                "sdf_skull_1",
            },
        },

        sdf_skull_1 = {
            title = SKILLTREE.SDF.SDF_SKULL_1_TITLE,
            desc = SKILLTREE.SDF.SDF_SKULL_1_DESC,
            icon = "wolfgang_allegiance_lunar_2",
            pos = {-180,184},
            group = "skull",
            tags = {"skull"},
	    locks = {"sdf_skull_lock_1"},
            onactivate = function(inst, fromload)
		--inst:AddTag("sdf_eye_of_amon_ra")
		inst:SkilltreeEyeOfAmonRaUpdateFn()
	    end,
            ondeactivate = function(inst, fromload)
		--inst:RemoveTag("sdf_eye_of_amon_ra")
		inst:SkilltreeEyeOfAmonRaUpdateFn()
            end,
            connects = {
                "sdf_skull_2",
                "sdf_skull_3",
            },
        },

        sdf_skull_2 = {
            title = SKILLTREE.SDF.SDF_SKULL_2_TITLE,
            desc = SKILLTREE.SDF.SDF_SKULL_2_DESC,
            icon = "wolfgang_allegiance_lunar_1",
            pos = {-142,126},
            group = "skull",
            tags = {"skull"},
            onactivate = function(inst, fromload)
		--inst:AddTag("sdf_focus")
	    end,        
        },

        sdf_skull_3 = {
            title = SKILLTREE.SDF.SDF_SKULL_3_TITLE,
            desc = SKILLTREE.SDF.SDF_SKULL_3_DESC,
            icon = "wolfgang_allegiance_lunar_3",
            pos = {-218,126},
            group = "skull",
            tags = {"skull"},
            onactivate = function(inst, fromload)
		--inst:AddTag("sdf_perception")
	    end,         
        },

--Insight
        sdf_skull_lock_2 = {
	    desc = SKILLTREE.SDF.SDF_SKULL_LOCK_2_DESC,
            pos = {-142,88}, --62
            group = "skull",
            tags = {"skull","lock"},
            root = true,
            lock_open = function(prefabname, activatedskills, readonly) 
                if readonly then
                    return "question"
                end

                return TheGenericKV:GetKV("sdf_book_of_gallowmere_riddles_completed") == "1"
                --return true
            end,
            connects = {
                "sdf_skull_4",
            },
        },

        sdf_skull_lock_3 = {
	    desc = SKILLTREE.SDF.SDF_SKULL_LOCK_3_DESC,
            pos = {-218,88}, --62
            group = "skull",
            tags = {"skull","lock"},
            root = true,
            lock_open = function(prefabname, activatedskills, readonly) 
                if readonly then
                    return "question"
                end

                return TheGenericKV:GetKV("sdf_book_of_gallowmere_restored") == "1"
                --return true
            end,
            connects = {
                "sdf_skull_4",
            },
        },

        sdf_skull_4 = {
            title = SKILLTREE.SDF.SDF_SKULL_4_TITLE,
            desc = SKILLTREE.SDF.SDF_SKULL_4_DESC,
            icon = "wathgrithr_songs_revivewarrior",
            pos = {-180,88},
            group = "skull",
            tags = {"skull"},
	    locks = {"sdf_skull_lock_2", "sdf_skull_lock_3"},
            onactivate = function(inst, fromload)
		--inst:AddTag("sdf_insight")
		inst:AddTag("sdf_book_of_gallowmere_builder")

		--learn recipe
		inst.components.builder:UnlockRecipe("sdf_book_of_gallowmere")
		inst:PushEvent("learnrecipe", { teacher = inst, recipe = GetValidRecipe("sdf_book_of_gallowmere") })
	    end,
            ondeactivate = function(inst, fromload)
		local book_of_gallowmere_Enabled = inst.components.sdf_jack_of_the_green_riddle_quest:CheckBookOfGallowmere()
		if book_of_gallowmere_Enabled == false then
		    inst:RemoveTag("sdf_book_of_gallowmere_builder")
		end
            end,
        },

--Morten the Earthworm
        sdf_skull_lock_4 = {
	    desc = SKILLTREE.SDF.SDF_SKULL_LOCK_4_DESC,
            pos = {-180,52}, --62
            group = "skull",
            tags = {"skull","lock"},
            root = true,
            lock_open = function(prefabname, activatedskills, readonly) 
                if readonly then
                    return "question"
                end

                return TheGenericKV:GetKV("sdf_deerclops_killed") == "1"
                --return true
            end,
            connects = {
                "sdf_skull_5",
            },
        },

        sdf_skull_5 = {
            title = SKILLTREE.SDF.SDF_SKULL_5_TITLE,
            desc = SKILLTREE.SDF.SDF_SKULL_5_DESC,
            icon = "woodie_human_lucy_3",
            pos = {-180,12},
            group = "skull",
            tags = {"skull"},
	    locks = {"sdf_skull_lock_4"},
            onactivate = function(inst, fromload)
		--inst:AddTag("sdf_morten")
		local hand = inst.components.inventory:GetEquippedItem(EQUIPSLOTS.HANDS)
		if hand then
		    if hand.components.oceanfishingrod and hand.components.container then
			--create new Morten
			inst:MakeMortenFn()
		    end
		end
	    end,
            ondeactivate = function(inst, fromload)
		--Remove any old mortens
		for follower,_ in pairs(inst.components.leader.followers) do
		    if follower.prefab == "sdf_morten" then
			follower:Remove()
		    end
		end
            end,
        },


--Allegiance Tree
        sdf_allegiance_lock_1 = {
	    desc = SKILLTREE.SDF.SDF_ALLEGIANCE_LOCK_1_DESC,
            pos = {-3,12}, --12
            group = "allegiance_sdf",
            tags = {"allegiance","lock"},
            root = true,
            lock_open = function(prefabname, activatedskills, readonly)
                return SkillTreeFns.CountSkills(prefabname, activatedskills) >= 12
            end,
            connects = {
                "sdf_allegiance_shadow",
            },
        },

        sdf_allegiance_lock_2 = {
            desc = SKILLTREE.SDF.SDF_ALLEGIANCE_LOCK_2_DESC,
            pos = {36,12}, --30
            group = "allegiance_sdf",
            tags = {"allegiance","lock"},
            root = true,
            lock_open = function(prefabname, activatedskills, readonly) 
                if readonly then
                    return "question"
                end

                return TheGenericKV:GetKV("fuelweaver_killed") == "1"
            end,
            connects = {
                "sdf_allegiance_shadow",
            },
        },

        sdf_allegiance_lock_4 = {
            desc = SKILLTREE.SDF.SDF_ALLEGIANCE_LOCK_4_DESC,
            pos = {71,12},
            group = "allegiance_sdf",
            tags = {"allegiance","lock"},
            root = true,
            lock_open = function(prefabname, activatedskills, readonly)
                if SkillTreeFns.CountTags(prefabname, "lunar_favor", activatedskills) == 0 then
                    return true
                end
    
                return nil -- Important to return nil and not false.
            end,
            connects = {
                "sdf_allegiance_shadow",
            },
        },    

        sdf_allegiance_shadow = {
            title = SKILLTREE.SDF.SDF_ALLEGIANCE_SHADOW_TITLE,
            desc = SKILLTREE.SDF.SDF_ALLEGIANCE_SHADOW_DESC,
            icon = "wilson_favor_shadow",
            pos = {114,12},
            group = "allegiance_sdf",
            tags = {"allegiance","shadow","shadow_favor"},
            locks = {"sdf_allegiance_lock_1", "sdf_allegiance_lock_2", "sdf_allegiance_lock_4"},
            onactivate = function(inst, fromload)
		--inst:AddTag("sdf_guts")
            end,
        },  

        sdf_allegiance_lock_3 = {
            desc = SKILLTREE.SDF.SDF_ALLEGIANCE_LOCK_3_DESC,
            pos = {-42,12}, -- -36
            group = "allegiance_sdf",
            tags = {"allegiance","lock"},
            root = true,
            lock_open = function(prefabname, activatedskills, readonly) 
                if readonly then
                    return "question"
                end

                return TheGenericKV:GetKV("celestialchampion_killed") == "1"
            end,
            connects = {
                "sdf_allegiance_lunar",
            },
        },

        sdf_allegiance_lock_5 = {
            desc = SKILLTREE.SDF.SDF_ALLEGIANCE_LOCK_5_DESC,
            pos = {-77,12},
            group = "allegiance_sdf",
            tags = {"allegiance","lock"},
            root = true,
            lock_open = function(prefabname, activatedskills, readonly)
                if SkillTreeFns.CountTags(prefabname, "shadow_favor", activatedskills) == 0 then
                    return true
                end
    
                return nil -- Important to return nil and not false.
            end,
            connects = {
                "sdf_allegiance_lunar",
            },
        },

        sdf_allegiance_lunar = {
            title = SKILLTREE.SDF.SDF_ALLEGIANCE_LUNAR_TITLE,
            desc = SKILLTREE.SDF.SDF_ALLEGIANCE_LUNAR_DESC,
            icon = "wolfgang_allegiance_shadow_1",
            pos = {-120,12},
            group = "allegiance_sdf",
            tags = {"allegiance","lunar","lunar_favor"},
            locks = {"sdf_allegiance_lock_1", "sdf_allegiance_lock_3","sdf_allegiance_lock_5"},
            onactivate = function(inst, fromload)
		--inst:AddTag("sdf_nerve")
		inst.components.sanity.night_drain_mult = (TUNING.SDF_SANITY_NIGHT_DRAIN_MULT * TUNING.SDF_SKILLSET_ALLEGIANCE_NERVE)
		inst.components.sanity.neg_aura_mult = (TUNING.SDF_SANITY_NEG_AURA_MULT * TUNING.SDF_SKILLSET_ALLEGIANCE_NERVE)
            end,
            ondeactivate = function(inst, fromload)
		inst.components.sanity.night_drain_mult = TUNING.SDF_SANITY_NIGHT_DRAIN_MULT
		inst.components.sanity.neg_aura_mult = TUNING.SDF_SANITY_NEG_AURA_MULT
            end,
        },
    }

    return {
        SKILLS = skills,
        ORDERS = ORDERS,
    }
end

--------------------------------------------------------------------------------------------------

return BuildSkillsData