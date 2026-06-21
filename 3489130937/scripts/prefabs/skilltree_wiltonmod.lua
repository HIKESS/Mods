local ORDERS =
{    
	{"wiltonmod_skill1",         { -214+15       , 176 + 30 }},
	{"wiltonmod_skill2",         { -62       , 176 + 30 }},
	{"wiltonmod_skill3",         { 66+18     , 176 + 30 }},

	{"allegiance",      { 204       , 176 + 30 }},      
}

--------------------------------------------------------------------------------------------------

local wilton_skill_str = STRINGS.SKILLTREE and STRINGS.SKILLTREE.WILTON or {}

STRINGS.SKILLTREE.PANELS.WILTONMOD_SKILL1 = wilton_skill_str.PANEL_SKILL1_TITLE or "骨头特性"
STRINGS.SKILLTREE.PANELS.WILTONMOD_SKILL2 = wilton_skill_str.PANEL_SKILL2_TITLE or "不死族工艺"
STRINGS.SKILLTREE.PANELS.WILTONMOD_SKILL3 = wilton_skill_str.PANEL_SKILL3_TITLE or "死灵巫术"

--------------------------------------------------------------------------------------------------

local function BuildSkillsData(SkillTreeFns) 
    local skills = 
    {
 
        wiltonmod_skill1_1 = {
            title = wilton_skill_str.SKILL1_1_TITLE or "空心骨1级",
            desc = wilton_skill_str.SKILL1_1_DESC or "威尔顿只剩一副骸骨，跑的比一般角色快一点，移动速度1.1。",
            icon = "wilson_alchemy_1",
            pos = {-214, 176},
            group = "wiltonmod_skill1",
            tags = {"wiltonmod_skill1", "wiltonmod_skill1_1"},
            onactivate = function(inst)
              inst.components.locomotor:SetExternalSpeedMultiplier(inst, "wiltonmod_skilltree", 1.1)
            end,
            root = true,
            connects = {
                "wiltonmod_skill1_2",
            },
        },       

        wiltonmod_skill1_2 = {
            title = wilton_skill_str.SKILL1_2_TITLE or "空心骨2级",
            desc = wilton_skill_str.SKILL1_2_DESC or "威尔顿跑的更快，移动速度1.25。",
            icon = "wilson_alchemy_1",
            pos = {-214, 176-40},        
            group = "kui_l_skill1",
            tags = {"wiltonmod_skill1", "wiltonmod_skill1_1"},
            onactivate = function(inst)
              inst.components.locomotor:SetExternalSpeedMultiplier(inst, "wiltonmod_skilltree", 1.25) 
            end, 
            --root = true,                  
            connects = {
                "wiltonmod_skill1_3",
            },
        },

        wiltonmod_skill1_3 = {
            title = wilton_skill_str.SKILL1_3_TITLE or "空心骨3级",
            desc = wilton_skill_str.SKILL1_3_DESC or "威尔顿身体很轻，可以在水面上奔跑，但潮湿度会不断上涨，在潮湿度达到峰值时会落水。",
            icon = "wilson_alchemy_1",
            pos = {-214, 176-40-40},        
            --pos = {0,-1},
            group = "wiltonmod_skill1",
            tags = {"wiltonmod_skill1", "wiltonmod_skill1_1"},
            onactivate = function(inst, fromload)

            end, 
        },

        wiltonmod_skill1_4 = {
            title = wilton_skill_str.SKILL1_4_TITLE or "骨质强化1级",
            desc = wilton_skill_str.SKILL1_4_DESC or "骨头不会导电，威尔顿获得100%防雷能力。",
            icon = "wilson_alchemy_1",
            pos = {-214+38, 176},
            group = "wiltonmod_skill1",
            tags = {"wiltonmod_skill1", "wiltonmod_skill1_1"},
            onactivate = function(inst)
 
            end,
            root = true,
            connects = {
                "wiltonmod_skill1_5",
            },
        },       

        wiltonmod_skill1_5 = {
            title = wilton_skill_str.SKILL1_5_TITLE or "骨质强化2级",
            desc = wilton_skill_str.SKILL1_5_DESC or "威尔顿免疫潮湿掉理智影响，武器不会脱手。",
            icon = "wilson_alchemy_1",
            pos = {-214+38, 176-40},        
            group = "kui_l_skill1",
            tags = {"wiltonmod_skill1", "wiltonmod_skill1_1"},
            onactivate = function(inst)
                inst:AddTag("stronggrip")
                inst.components.sanity.no_moisture_penalty = true
            end, 
            --root = true,                  
            connects = {
                "wiltonmod_skill1_6",
            },
        },

        wiltonmod_skill1_6 = {
            title = wilton_skill_str.SKILL1_6_TITLE or "骨质强化3级",
            desc = wilton_skill_str.SKILL1_6_DESC or "温度对骨头的影响微乎其微，威尔顿免疫过冷过热，体温恒定30度。",
            icon = "wilson_alchemy_1",
            pos = {-214+38, 176-40-40},        
            --pos = {0,-2},
            group = "wiltonmod_skill1",
            tags = {"wiltonmod_skill1", "wiltonmod_skill1_1"},
            onactivate = function(inst, fromload)

            end, 
        },

        wiltonmod_skill1_lock_1 = {
            desc = wilton_skill_str.SKILL1_LOCK1_DESC or "（学习3项骨头特性技能后解锁）",
            pos = {-214+18,58},
            --pos = {2,0},
            group = "wiltonmod_skill1",
            tags = {"wiltonmod_skill1","lock"},
            root = true,
            lock_open = function(prefabname, activatedskills, readonly)
                return SkillTreeFns.CountTags(prefabname, "wiltonmod_skill1", activatedskills) > 2
            end,
            connects = {
                "wiltonmod_skill1_7",
            },
        },

        wiltonmod_skill1_7 = {
            title = wilton_skill_str.SKILL1_7_TITLE or "钢筋铁骨",
            desc = wilton_skill_str.SKILL1_7_DESC or "威尔顿的骨质更加坚硬，获得40%减伤，背重物不再掉血。",
            icon = "wilson_torch_throw",
            pos = {-214+18,58-38},        
            --pos = {2,-1},
            group = "wiltonmod_skill1",
            tags = {"wiltonmod_skill1"},
        },

        --=============================2.不死族工艺
        wiltonmod_skill2_1 = {
            title = wilton_skill_str.SKILL2_1_TITLE or "掘墓者",
            desc = wilton_skill_str.SKILL2_1_DESC or "可以徒手挖坟，挖坟不会损失理智。",
            icon = "wilson_alchemy_1",
            pos = {-62,176},
            --pos = {1,0},
            group = "wiltonmod_skill2",
            tags = {"wiltonmod_skill2", "wiltonmod_skill2_1"},
            root = true,
            connects = {
                "wiltonmod_skill2_2",
                "wiltonmod_skill2_3",
                "wiltonmod_skill2_4",
            },
        },
        wiltonmod_skill2_2 = {
            title = wilton_skill_str.SKILL2_2_TITLE or "亡灵指挥家1级",
            desc = wilton_skill_str.SKILL2_2_DESC or "学会制作【骨杖】，移速+20%，可以消耗理智一键复活大范围的骷髅。",
            icon = "wilson_alchemy_gem_1",
            pos = {-62-38,176-54},        
            group = "wiltonmod_skill2",
            tags = {"wiltonmod_skill2", "wiltonmod_skill2_1"},
            connects = {
                "wiltonmod_skill2_5",
            },
        },
        wiltonmod_skill2_5 = {
            title = wilton_skill_str.SKILL2_5_TITLE or "亡灵指挥家2级",
            desc = wilton_skill_str.SKILL2_5_DESC or "骨杖的【死者苏生】技能可以为范围内的骷髅兵回满生命值。",
            icon = "wilson_alchemy_gem_2",
            pos = {-62-38,176-54-38},        
            --pos = {0,-2},
            group = "wiltonmod_skill2",
            tags = {"wiltonmod_skill2", "wiltonmod_skill2_1"},
            connects = {
                "wiltonmod_skill2_6",
            },
        },
        wiltonmod_skill2_6 = {
            title = wilton_skill_str.SKILL2_6_TITLE or "亡灵指挥家3级",
            desc = wilton_skill_str.SKILL2_6_DESC or "骨杖可以打开技能轮盘，更精细的控制骷髅行为，拥有待机，跟随，战斗，工作等指令。",
            icon = "wilson_alchemy_gem_3",
            pos = {-62-38,176-54-38-38},        
            group = "wiltonmod_skill2",
            tags = {"wiltonmod_skill2", "wiltonmod_skill2_1"},
        },

        wiltonmod_skill2_3 = {
            title = wilton_skill_str.SKILL2_3_TITLE or "乱葬岗1级",
            desc = wilton_skill_str.SKILL2_3_DESC or "学会制作【复生墓碑】可以制造等同于墓碑的复制品，每个墓碑都会附带一个坟墓，可以用铲子移动墓碑位置，坟墓也会跟着一起移动，但移动后会变为挖开状态。",
            icon = "wilson_alchemy_ore_1",
            pos = {-62,176-54},
            group = "wiltonmod_skill2",
            tags = {"wiltonmod_skill2", "wiltonmod_skill2_1"},
            connects = {
                "wiltonmod_skill2_7",
            },
        },
        wiltonmod_skill2_7 = {
            title = wilton_skill_str.SKILL2_7_TITLE or "乱葬岗2级",
            desc = wilton_skill_str.SKILL2_7_DESC or "当世界中有学会此技能的威尔顿时，每逢满月会将世界上所有已挖开的坟墓重置为未挖状态，并重新刷新陪葬品。",
            icon = "wilson_alchemy_ore_2",
            pos = {-62,176-54-38},
            --pos = {1,-2},
            group = "wiltonmod_skill2",
            tags = {"wiltonmod_skill2", "wiltonmod_skill2_1"},
            connects = {
                "wiltonmod_skill2_8",
            },
        },
        wiltonmod_skill2_8 = {
            title = wilton_skill_str.SKILL2_8_TITLE or "乱葬岗3级",
            desc = wilton_skill_str.SKILL2_8_DESC or "当世界中有学会此技能的威尔顿时，其他玩家的幽灵可以作祟未挖开的坟墓在原地复活，玩家可以作祟坟墓复活，恢复一半三维，但坟墓会变为挖开状态，不会掉落陪葬品。",
            icon = "wilson_alchemy_ore_3",
            pos = {-62,176-54-38-38},
            --pos = {1,-3},
            group = "wiltonmod_skill2",
            tags = {"wiltonmod_skill2", "wiltonmod_skill2_1"},
        },

        wiltonmod_skill2_4 = {
            title = wilton_skill_str.SKILL2_4_TITLE or "骷髅军团1级",
            desc = wilton_skill_str.SKILL2_4_DESC or "学会制作【亡灵军械库】可以消耗木头和燧石自动为骷髅提供临时的长矛，木甲和橄榄球头盔。",
            icon = "wilson_alchemy_iky_1",
            pos = {-62+38,176-54},
            --pos = {2,-1},
            group = "wiltonmod_skill2",
            tags = {"wiltonmod_skill2", "wiltonmod_skill2_1"},
            connects = {
                "wiltonmod_skill2_9",
            },
        },
        wiltonmod_skill2_9 = {
            title = wilton_skill_str.SKILL2_9_TITLE or "骷髅军团2级",
            desc = wilton_skill_str.SKILL2_9_DESC or "亡灵军械库可以放入噩梦燃料，可以消耗6个噩梦燃料制作暗夜甲和高礼帽。",
            icon = "wilson_alchemy_iky_2",
            pos = {-62+38,176-54-38},
            --pos = {2,-2},
            group = "wiltonmod_skill2",
            tags = {"wiltonmod_skill2", "wiltonmod_skill2_1"},
            connects = {
                "wiltonmod_skill2_10",
            },
        },
        wiltonmod_skill2_10 = {
            title = wilton_skill_str.SKILL2_10_TITLE or "骷髅军团3级",
            desc = wilton_skill_str.SKILL2_10_DESC or "亡灵军械库可以消耗4个噩梦燃料制作暗夜剑。",
            icon = "wilson_alchemy_iky_3",
            pos = {-62+38,176-54-38-38},
            group = "wiltonmod_skill2",
            tags = {"wiltonmod_skill2", "wiltonmod_skill2_1"},
        },

        --================ 骷髅巫术 & 亡灵巫术（参考 Wilson 胡子树布局，仅做图标与描述展示）
        wiltonmod_skill2_12 = {
            title = wilton_skill_str.SKILL2_12_TITLE or "骷髅巫术1级",
            desc = wilton_skill_str.SKILL2_12_DESC or "学会制作【无名王冠】拥有骨头头盔的所有功能，可以自由开关骨头头盔功能，90%防御，可以使用噩梦燃料修复。",
            icon = "wilson_beard_insulation_1",
            -- 对应 Wilson 胡子树左列第一格
            pos = {66,176},
            --pos = {0,0},
            group = "wiltonmod_skill3",
            tags = {"wiltonmod_skill3", "wiltonmod_skill3_1"},
            root = true,
            connects = {
                "wiltonmod_skill2_13",
            },
        },

        wiltonmod_skill2_13 = {
            title = wilton_skill_str.SKILL2_13_TITLE or "骷髅巫术2级",
            desc = wilton_skill_str.SKILL2_13_DESC or "无名王冠增加能力，穿戴时会使所有骷髅兵不会消耗装备耐久。",
            icon = "wilson_beard_insulation_2",
            -- 对应 Wilson 胡子树左列第二格
            pos = {66,176-38},
            --pos = {0,-1},
            group = "wiltonmod_skill3",
            tags = {"wiltonmod_skill3", "wiltonmod_skill3_1"},
            connects = {
                "wiltonmod_skill2_14",
            },
        },

        wiltonmod_skill2_14 = {
            title = wilton_skill_str.SKILL2_14_TITLE or "骷髅巫术3级",
            desc = wilton_skill_str.SKILL2_14_DESC or "无名王冠增加能力，穿戴时会使所有骷髅兵拥有限伤的能力，骷髅兵单次受伤不会超过10点。",
            icon = "wilson_beard_insulation_3",
            -- 对应 Wilson 胡子树左列第三格
            pos = {66,176-38-38},
            --pos = {0,-2},
            group = "wiltonmod_skill3",
            tags = {"wiltonmod_skill3", "wiltonmod_skill3_1"},
            connects = {
                "wiltonmod_skill3_lock_1",
            },
        },

        wiltonmod_skill2_15 = {
            title = wilton_skill_str.SKILL2_15_TITLE or "亡灵巫术1级",
            desc = wilton_skill_str.SKILL2_15_DESC or "学会制作【灵魂帷幕】拥有骨头盔甲的所有功能，40位面防御，可以使用噩梦燃料修复。",
            icon = "wilson_beard_speed_1",
            -- 对应 Wilson 胡子树右列第一格
            pos = {66+38,176},
            --pos = {1,0},
            group = "wiltonmod_skill3",
            tags = {"wiltonmod_skill3", "wiltonmod_skill3_1"},
            root = true,
            connects = {
                "wiltonmod_skill2_16",
            },
        },

        wiltonmod_skill2_16 = {
            title = wilton_skill_str.SKILL2_16_TITLE or "亡灵巫术2级",
            desc = wilton_skill_str.SKILL2_16_DESC or "灵魂帷幕增加能力，穿戴时会使所有骷髅兵获得每10秒一次的骨甲护盾。",
            icon = "wilson_beard_speed_2",
            -- 对应 Wilson 胡子树右列第二格
            pos = {66+38,176-38},
            --pos = {1,-1},
            group = "wiltonmod_skill3",
            tags = {"wiltonmod_skill3", "wiltonmod_skill3_1"},
            connects = {
                "wiltonmod_skill2_17",
            },
        },

        wiltonmod_skill2_17 = {
            title = wilton_skill_str.SKILL2_17_TITLE or "亡灵巫术3级",
            desc = wilton_skill_str.SKILL2_17_DESC or "灵魂帷幕增加能力，穿戴时会周期性为所有骷髅兵回复生命，每5秒回复5生命值。",
            icon = "wilson_beard_speed_3",
            -- 对应 Wilson 胡子树右列第三格
            pos = {66+38,176-38-38},
            --pos = {1,-2},
            group = "wiltonmod_skill3",
            tags = {"wiltonmod_skill3", "wiltonmod_skill3_1"},
            connects = {
                "wiltonmod_skill3_lock_1",
            },
        },

        -- 技能锁节点：当学习任意 12 项技能后，开启“灵魂出窍”
        wiltonmod_skill3_lock_1 = {
            desc = wilton_skill_str.SKILL3_LOCK1_DESC or "（学习12项技能解锁）",
            pos = {66+18,58},
            --pos = {2,0},
            group = "wiltonmod_skill3",
            tags = {"wiltonmod_skill3","lock"},
            root = true,
            lock_open = function(prefabname, activatedskills, readonly)
                -- 当角色已学习的任意技能数量达到 12 个时，开启灵魂出窍锁节点
                return SkillTreeFns.CountSkills(prefabname, activatedskills) >= 12
            end,
            connects = {
                "wiltonmod_skill2_18",
            },
        },

        -- 两条巫术分支的汇合终点，仅做技能图标展示，实际解锁逻辑由技能树系统统一处理
        wiltonmod_skill2_18 = {
            title = wilton_skill_str.SKILL2_18_TITLE or "灵魂出窍",
            desc = wilton_skill_str.SKILL2_18_DESC or "让你的灵魂获得自由，右键自身可以灵魂出窍，在原地留下一副不会被摧毁的骷髅，可以像幽灵一样自由移动，作祟物体，再次右键自身可以返回骨架中。灵魂状态下被给予告密的心，作祟复活道具不会产生任何效果。",
            icon = "wilson_beard_inventory",
            -- 对应 Wilson 胡子树底部汇合点
            pos = {66+18,58-38},
            --pos = {2,-1},
            group = "wiltonmod_skill3",
            -- 不计入巫术基础技能数量统计
            tags = {"wiltonmod_skill3"},
            -- 需要先通过巫术锁节点，才能点出“灵魂出窍”
            locks = {"wiltonmod_skill3_lock_1"},
        },

        -- 效忠技能锁节点（参考 Wilson 原始技能树，保持 UI 结构一致）
        wiltonmod_allegiance_lock_1 = {
            desc = STRINGS.SKILLTREE.WILSON.WILSON_ALLEGIANCE_LOCK_1_DESC,
            pos = {204+2,176},
            --pos = {0.5,0},
            group = "allegiance",
            tags = {"allegiance","lock"},
            root = true,
            lock_open = function(prefabname, activatedskills, readonly)
                return SkillTreeFns.CountSkills(prefabname, activatedskills) >= 12
            end,
            connects = {
                "wiltonmod_allegiance_shadow",
            },
        },

        wiltonmod_allegiance_lock_2 = {
            desc = STRINGS.SKILLTREE.ALLEGIANCE_LOCK_2_DESC,
            pos = {204-22+2,176-50+2},  
            --pos = {0,-1},
            group = "allegiance",
            tags = {"allegiance","lock"},
            root = true,
            lock_open = function(prefabname, activatedskills, readonly) 
                if readonly then
                    return "question"
                end

                return TheGenericKV:GetKV("fuelweaver_killed") == "1"
            end,
            connects = {
                "wiltonmod_allegiance_shadow",
            },
        },

        wiltonmod_allegiance_lock_4 = {
            desc = STRINGS.SKILLTREE.ALLEGIANCE_LOCK_4_DESC,
            pos = {204-22+2,176-100+8},  
            --pos = {0,-1},
            group = "allegiance",
            tags = {"allegiance","lock"},
            root = true,
            lock_open = function(prefabname, activatedskills, readonly)
                if SkillTreeFns.CountTags(prefabname, "lunar_favor", activatedskills) == 0 then
                    return true
                end
    
                return nil -- Important to return nil and not false.
            end,
            connects = {
                "wiltonmod_allegiance_shadow",
            },
        },    

        wiltonmod_allegiance_shadow = {
            title = STRINGS.SKILLTREE.WILSON.WILSON_ALLEGIANCE_SHADOW_TITLE,
            desc = STRINGS.SKILLTREE.WILTON.WILTON_ALLEGIANCE_SHADOW_DESC,
            icon = "wilson_favor_shadow",
            pos = {204-22+2 ,176-110-38+10},  --  -22
            --pos = {0,-2},
            group = "allegiance",
            tags = {"allegiance","shadow","shadow_favor"},
            locks = {"wiltonmod_allegiance_lock_1", "wiltonmod_allegiance_lock_2", "wiltonmod_allegiance_lock_4"},
            onactivate = function(inst, fromload)
                inst:AddTag("player_shadow_aligned")
                inst:AddTag("wiltonmod_shadow_aligned")
                local damagetyperesist = inst.components.damagetyperesist
                if damagetyperesist then
                    damagetyperesist:AddResist("shadow_aligned", inst, TUNING.SKILLS.WILSON_ALLEGIANCE_SHADOW_RESIST, "wiltonmod_allegiance_shadow")
                end
                local damagetypebonus = inst.components.damagetypebonus
                if damagetypebonus then
                    damagetypebonus:AddBonus("lunar_aligned", inst, TUNING.SKILLS.WILSON_ALLEGIANCE_VS_LUNAR_BONUS, "wiltonmod_allegiance_shadow")
                end
            end,
            ondeactivate = function(inst, fromload)
                inst:RemoveTag("player_shadow_aligned")
                inst:RemoveTag("wiltonmod_shadow_aligned")
                local damagetyperesist = inst.components.damagetyperesist
                if damagetyperesist then
                    damagetyperesist:RemoveResist("shadow_aligned", inst, "wilson_allegiance_shadow")
                end
                local damagetypebonus = inst.components.damagetypebonus
                if damagetypebonus then
                    damagetypebonus:RemoveBonus("lunar_aligned", inst, "wilson_allegiance_shadow")
                end
            end,
        },  

        wiltonmod_allegiance_lock_3 = {
            desc = STRINGS.SKILLTREE.ALLEGIANCE_LOCK_3_DESC,
            pos = {204+22+2,176-50+2},
            --pos = {0,-1},
            group = "allegiance",
            tags = {"allegiance","lock"},
            root = true,
            lock_open = function(prefabname, activatedskills, readonly) 
                if readonly then
                    return "question"
                end

                return TheGenericKV:GetKV("celestialchampion_killed") == "1"
            end,
            connects = {
                "wiltonmod_allegiance_lunar",
            },
        },

        wiltonmod_allegiance_lock_5 = {
            desc = STRINGS.SKILLTREE.ALLEGIANCE_LOCK_5_DESC,
            pos = {204+22+2,176-100+8},  
            --pos = {0,-1},
            group = "allegiance",
            tags = {"allegiance","lock"},
            root = true,
            lock_open = function(prefabname, activatedskills, readonly)
                if SkillTreeFns.CountTags(prefabname, "shadow_favor", activatedskills) == 0 then
                    return true
                end
    
                return nil -- Important to return nil and not false.
            end,
            connects = {
                "wiltonmod_allegiance_lunar",
            },
        },

        wiltonmod_allegiance_lunar = {
            title = STRINGS.SKILLTREE.WILSON.WILSON_ALLEGIANCE_LUNAR_TITLE,
            desc = STRINGS.SKILLTREE.WILTON.WILTON_ALLEGIANCE_LUNAR_DESC,
            icon = "wilson_favor_lunar",
            pos = {204+22+2 ,176-110-38+10},
            --pos = {0,-2},
            group = "allegiance",
            tags = {"allegiance","lunar","lunar_favor"},
            locks = {"wiltonmod_allegiance_lock_1", "wiltonmod_allegiance_lock_3","wiltonmod_allegiance_lock_5"},
            onactivate = function(inst, fromload)
                inst:AddTag("player_lunar_aligned")
                inst:AddTag("wiltonmod_lunar_aligned")
                local damagetyperesist = inst.components.damagetyperesist
                if damagetyperesist then
                    damagetyperesist:AddResist("lunar_aligned", inst, TUNING.SKILLS.WILSON_ALLEGIANCE_LUNAR_RESIST, "wiltonmod_allegiance_lunar")
                end
                local damagetypebonus = inst.components.damagetypebonus
                if damagetypebonus then
                    damagetypebonus:AddBonus("shadow_aligned", inst, TUNING.SKILLS.WILSON_ALLEGIANCE_VS_SHADOW_BONUS, "wiltonmod_allegiance_lunar")
                end
            end,
            ondeactivate = function(inst, fromload)
                inst:RemoveTag("player_lunar_aligned")
                inst:RemoveTag("wiltonmod_lunar_aligned")
                local damagetyperesist = inst.components.damagetyperesist
                if damagetyperesist then
                    damagetyperesist:RemoveResist("lunar_aligned", inst, "wilson_allegiance_lunar")
                end
                local damagetypebonus = inst.components.damagetypebonus
                if damagetypebonus then
                    damagetypebonus:RemoveBonus("shadow_aligned", inst, "wilson_allegiance_lunar")
                end
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