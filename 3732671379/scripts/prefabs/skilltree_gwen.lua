local CERE_X = -190
local CERE_Y =  210

local ORDERS =
{
    {"cut_shadow",  { CERE_X , CERE_Y }}, 
    {"cut_radiance",  { -CERE_X , CERE_Y }}, 
    {"dash_shadow",  { -130 ,120}},
    {"dash_radiance",  { 130 ,120}},
    {"gwen_wawa",  { 0 ,85}},
    {"shengai_shadow",  { CERE_X , 120 }},
    {"shengai_radiance",  { -CERE_X , 120 }},
    {"fly_shadow",  { -150 , 30}},
    {"fly_radiance",  { 150 , 30}},
    {"feizhen_shadow",  { -90 , 30}},
    {"feizhen_radiance",  { 90 , 30}},
    {"gwen_shadow_end",  { -90 , 240}},
    {"gwen_radiance_end",  { 90 , 240}},
    {"gwen_xiubu",  { 0 , 185}},
}

local L = {
    PANELS = {
        CUT_SHADOW =   "灵魂收割",
        CUT_RADIANCE = "神圣洗礼",
        DASH_SHADOW =  "灵魂冲击",
        DASH_RADIANCE ="正义冲拳",
        GWEN_WAWA    = "灵罗娃娃",
        SHENGAI_SHADOW = "魂锁典狱",
        SHENGAI_RADIANCE = "神圣庇护",
        FLY_SHADOW = "游荡暗影",
        FLY_RADIANCE = "光明之旅",
        FEIZHEN_SHADOW = "飞针（暗影）",
        FEIZHEN_RADIANCE = "飞针（哨兵）",
        GWEN_SHADOW_END  = "黑雾之女",
        GWEN_RADIANCE_END = "光明哨兵",
        GWEN_XIUBU = "心灵手巧",
    },
}

STRINGS.SKILLTREE.PANELS = L.PANELS

local function BuildSkillsData(SkillTreeFns)
    local skills = {


        -----------------------------------------------------------------------------------------------------
        ---最终阵营选择
        
        gwen_end_shadow_lock_1 = {
            desc = '需要学习最少5个本阵营技能且未选择哨兵阵营',
            pos = {-60, 210},
            group = 'gwen_shadow_end',
            tags = {'gwen_shadow',"gwen_shadow_end", 'lock'},
            root = true,
            lock_open = function(prefabname, activatedskills, readonly)
                return not SkillTreeFns.HasTag(prefabname, "gwen_radiance_end", activatedskills) and SkillTreeFns.CountTags(prefabname, 'gwen_shadow', activatedskills) >= 5
            end,
        },

        gwen_end_shadow = {
            title = "黑雾之女",
            desc = "加入黑雾阵营,获得1.2总攻击倍率，同时对月亮阵营增伤",
            icon = "wendy_gravestone_1",
            pos = {-90, 210},
            group = "gwen_shadow_end",
            tags = {"gwen_shadow_end"},
            locks = {"gwen_end_shadow_lock_1"},
            onactivate = function(inst) 
                inst.components.combat.externaldamagemultipliers:SetModifier(inst, 1.2, "briar_blood_state")
                local damagetypebonus = inst.components.damagetypebonus
                 if damagetypebonus then
                    damagetypebonus:AddBonus("lunar_aligned", inst, 1.20, "gwen_end_shadow1")
                end
            end,
            ondeactivate = function(inst)
                inst.components.combat.externaldamagemultipliers:RemoveModifier(inst, "gwen_end_shadow")
                local damagetypebonus = inst.components.damagetypebonus
                if damagetypebonus then
                    damagetypebonus:RemoveBonus("lunar_aligned", inst, "gwen_end_shadow1")
                end
            end,
        },

        gwen_end_radiance_lock_1 = {
            desc = '需要学习最少5个本阵营技能且未选择黑雾阵营',
            pos = {60, 210},
            group = 'gwen_radiance_end',
            tags = {'gwen_radiance',"gwen_radiance_end", 'lock'},
            root = true,
            lock_open = function(prefabname, activatedskills, readonly)
                return not SkillTreeFns.HasTag(prefabname, "gwen_shadow_end", activatedskills) and SkillTreeFns.CountTags(prefabname, 'gwen_radiance', activatedskills) >= 5
            end,
        },

        gwen_end_radiance = {
            title = "光明哨兵",
            desc = "加入哨兵阵营，获得20%总免伤，同时对暗影阵营获得伤害减免",
            icon = "wendy_gravestone_1",
            pos = {90, 210},
            group = "gwen_radiance_end",
            tags = {"gwen_radiance_end"},
            locks = {"gwen_end_radiance_lock_1"},
            onactivate = function(inst) 
                if inst.components.damagetyperesist ~= nil then
                    inst.components.damagetyperesist:AddResist("shadow_aligned", inst, 0.75, "gwen_end_radiance_resist")
                end
                inst.components.health:SetAbsorptionAmount(0.2)
            end,
            ondeactivate = function(inst)
                if inst.components.damagetyperesist ~= nil then
                    inst.components.damagetyperesist:RemoveResist("shadow_aligned", inst, "gwen_end_radiance_resist")
                end
                inst.components.health:SetAbsorptionAmount(0)
            end,
        },

        -----------------------------------------------------------------------------------------------------
        ---q剪刀阵营强化
        gwen_cut_shadow_lock_1 = {
            desc = '你只能选择一种对快刀乱剪的阵营强化',
           pos = {CERE_X, CERE_Y - 58},
            group = 'cut_shadow',
            tags = {'cut_shadow', 'lock'},
            root = true,
            lock_open = function(prefabname, activatedskills, readonly)
                return not SkillTreeFns.HasTag(prefabname, "cut_radiance", activatedskills)
            end,
        },

        gwen_cut_shadow_1 = {
            title = "剪影",
            desc = "你的影子将代替你完成对敌人的剪断",
            icon = "wendy_gravestone_1",
            pos = {CERE_X, CERE_Y - 25},
            group = "cut_shadow",
            tags = {'gwen_shadow',"cut_shadow"},
            connects = {"gwen_cut_shadow_2"},
            locks = {"gwen_cut_shadow_lock_1"},
        },

        gwen_cut_shadow_2 = {
            title = "投影仪",
            desc = "现在你的影子会出现在指针目标地点",
            icon = "wendy_gravestone_1",
            pos = {-160, CERE_Y - 60},
            group = "cut_shadow",
            tags = {'gwen_shadow',"cut_shadow"},
        },


        gwen_cut_radiance_lock_1 = {
            desc = '你只能选择一种对快刀乱剪的阵营强化',
           pos = {-CERE_X, CERE_Y - 58},
            group = 'cut_radiance',
            tags = {'cut_radiance', 'lock'},
            root = true,
            lock_open = function(prefabname, activatedskills, readonly)
                return not SkillTreeFns.HasTag(prefabname, "cut_shadow", activatedskills)
            end,
        },

        gwen_cut_radiance_1 = {
            title = "神圣",
            desc = "快刀乱剪范围增加",
            icon = "wendy_gravestone_1",
            pos = {-CERE_X, CERE_Y - 25},
            group = "cut_radiance",
            tags = {'gwen_radiance',"cut_radiance"},
            connects = {"gwen_cut_radiance_2"},
            locks = {"gwen_cut_radiance_lock_1"},
        },


        gwen_cut_radiance_2 = {
            title = "净化",
            desc = "快刀乱剪伤害增加，并且有概率剪下来生物的掉落物",
            icon = "wendy_gravestone_1",
            pos = {160, CERE_Y - 60},
            group = "cut_radiance",
            tags = {'gwen_radiance',"cut_radiance"},
        },


        --------------------------------------------------------------------------------------------------------------
        ---冲刺E的阵营强化
        gwen_dash_shadow_lock_1 = {
            desc = '你只能选择一种对冲刺的阵营强化',
           pos = {-130, CERE_Y - 155},
            group = 'dash_shadow',
            tags = {'dash_shadow', 'lock'},
            root = true,
            lock_open = function(prefabname, activatedskills, readonly)
                return not SkillTreeFns.HasTag(prefabname, "dash_radiance", activatedskills)
            end,
        },

        gwen_dash_shadow_1 = {
            title = "暗影冲击",
            desc = "冲刺时会产生一个向同样方向冲刺的幽魂，恐惧命中的生物",
            icon = "wendy_gravestone_1",
            pos = {-130, CERE_Y - 120},
            group = "dash_shadow",
            tags = {'gwen_shadow',"dash_shadow"},
            connects = {"gwen_dash_shadow_2"},
            locks = {"gwen_dash_shadow_lock_1"},
        },

        gwen_dash_shadow_2 = {
            title = "幽暗途径",
            desc = "你自身的冲刺距离增加，且生成的幽魂将会快速折返",
            icon = "wendy_gravestone_1",
            pos = {-100, CERE_Y - 155},
            group = "dash_shadow",
            tags = {'gwen_shadow',"dash_shadow"},
        },


        gwen_dash_radiance_lock_1 = {
            desc = '你只能选择一种对冲刺的阵营强化',
            pos = {130, CERE_Y - 155},
            group = 'dash_radiance',
            tags = {'dash_radiance', 'lock'},
            root = true,
            lock_open = function(prefabname, activatedskills, readonly)
                return not SkillTreeFns.HasTag(prefabname, "dash_shadow", activatedskills)
            end,
        },


        gwen_dash_radiance_1 = {
            title = "娃娃冲击",
            desc = "你的冲刺将会替换为一次强大的冲撞，撞击大物体时会受到反作用力",
            icon = "wendy_gravestone_1",
            pos = {130, CERE_Y - 120},
            group = "dash_radiance",
            tags = {'gwen_radiance',"dash_radiance"},
            connects = {"gwen_dash_radiance_2"},
            locks = {"gwen_dash_radiance_lock_1"},
        },

        gwen_dash_radiance_2 = {
            title = "缓冲",
            desc = "减少撞击后受到的反作用力",
            icon = "wendy_gravestone_1",
            pos = {100, CERE_Y - 155},
            group = "dash_radiance",
            tags = {'gwen_radiance',"dash_radiance"},
        },


        -------------------------------------------------------------------------------------------------------------
        ---中下娃娃相关
        gwen_wawa_1 = {
            title = "吉祥物",
            desc = "格温娃娃将会为其他玩家释放战斗激励",
            icon = "wendy_gravestone_1",
            pos = {0, 60},
            group = "gwen_wawa",
            tags = {"gwen_wawa"},
            root = true,
            connects = {"gwen_wawa_shadow","gwen_wawa_radiance"},
        },

        gwen_wawa_lock = {
            desc = '你只能选择一种对娃娃的阵营强化',
            pos = {0, 20},
            group = 'gwen_wawa',
            tags = {'gwen_wawa', 'lock'},
            root = true,
            lock_open = function(prefabname, activatedskills, readonly)
                if readonly then
                    return "question"
                end
                return SkillTreeFns.HasTag(prefabname, "gwen_wawa", activatedskills) and not (SkillTreeFns.HasTag(prefabname, "gwen_wawa_radiance", activatedskills) or
                          SkillTreeFns.HasTag(prefabname, "gwen_wawa_shadow", activatedskills))
            end,
        },

        gwen_wawa_shadow = {
            title = "黑雾遗物",
            desc = "战斗激励额外提供20%伤害倍率",
            icon = "wendy_gravestone_1",
            pos = {-35, 20},
            group = "gwen_wawa",
            tags = {'gwen_shadow',"gwen_wawa_shadow"},
            locks = {"gwen_wawa_lock"},
        },

        gwen_wawa_radiance = {
            title = "神圣玩偶",
            desc = "战斗激励额外提供20%减伤效果",
            icon = "wendy_gravestone_1",
            pos = {35, 20},
            group = "gwen_wawa",
            tags = {'gwen_radiance',"gwen_wawa_radiance"},
            locks = {"gwen_wawa_lock"},
        },


        --------------------------------------------------------------------------------------------------------------
        ---圣爱w的阵营强化
        gwen_shengai_shadow_lock_1 = {
            desc = '你只能选择一种对圣蔼的阵营强化',
           pos = {CERE_X, CERE_Y - 155},
            group = 'shengai_shadow',
            tags = {'shengai_shadow', 'lock'},
            root = true,
            lock_open = function(prefabname, activatedskills, readonly)
                return not SkillTreeFns.HasTag(prefabname, "shengai_radiance", activatedskills)
            end,
        },

        gwen_shengai_shadow_1 = {
            title = "魂锁典狱",
            desc = "圣蔼被替换为一个升起的灵魂牢笼,牢笼会持续伤害其中的敌人并治疗格温",
            icon = "wendy_gravestone_1",
            pos = {CERE_X, CERE_Y - 120},
            group = "shengai_shadow",
            tags = {'gwen_shadow',"shengai_shadow"},
            connects = {"gwen_shengai_shadow_2"},
            locks = {"gwen_shengai_shadow_lock_1"},
        },

        gwen_shengai_shadow_2 = {
            title = "灵魂汲取",
            desc = "牢笼升起和造成持续伤害时都有概率剥离生物的灵魂",
            icon = "wendy_gravestone_1",
            pos = {CERE_X, CERE_Y - 190},
            group = "shengai_shadow",
            tags = {'gwen_shadow',"shengai_shadow"},
        },

        gwen_shengai_radiance_lock_1 = {
            desc = '你只能选择一种对圣蔼的阵营强化',
            pos = {-CERE_X, CERE_Y - 155},
            group = 'shengai_radiance',
            tags = {'shengai_radiance', 'lock'},
            root = true,
            lock_open = function(prefabname, activatedskills, readonly)
                return not SkillTreeFns.HasTag(prefabname, "shengai_shadow", activatedskills)
            end,
        },


        gwen_shengai_radiance_1 = {
            title = "环绕轨道",
            desc = "你的圣蔼将会跟随你一起移动",
            icon = "wendy_gravestone_1",
            pos = {-CERE_X, CERE_Y - 120},
            group = "shengai_radiance",
            tags = {'gwen_radiance',"shengai_radiance"},
            connects = {"gwen_shengai_radiance_2"},
            locks = {"gwen_shengai_radiance_lock_1"},
        },

        gwen_shengai_radiance_2 = {
            title = "圣蔼庇护",
            desc = "在圣蔼存在时，你获得额外减伤",
            icon = "wendy_gravestone_1",
            pos = {-CERE_X, CERE_Y - 190},
            group = "shengai_radiance",
            tags = {'gwen_radiance',"shengai_radiance"},
        },

        --------------------------------------------------------------------------------------------------------------
        ---飞行的阵营强化
        
        -- gwen_fly_shadow_lock_1 = {
        --     desc = '你只能选择一种对飞行的阵营强化',
        --     pos = {-120, 0},
        --     group = 'fly_shadow',
        --     tags = {'fly_shadow', 'lock'},
        --     root = true,
        --     lock_open = function(prefabname, activatedskills, readonly)
        --         return not SkillTreeFns.HasTag(prefabname, "fly_radiance", activatedskills)
        --     end,
        -- },

        gwen_fly_shadow_1 = {
            title = "游魂",
            desc = "你在飞行过程中将会被暗影遮盖从而不会被生物仇恨",
            icon = "wendy_gravestone_1",
            pos = {-150, 0},
            group = "fly_shadow",
            tags = {'gwen_shadow',"fly_shadow"},
            root = true,
            -- locks = {"gwen_fly_shadow_lock_1"},
        },

        -- gwen_fly_radiance_lock_1 = {
        --     desc = '你只能选择一种对飞行的阵营强化',
        --     pos = {120, 0},
        --     group = 'fly_radiance',
        --     tags = {'fly_radiance', 'lock'},
        --     root = true,
        --     lock_open = function(prefabname, activatedskills, readonly)
        --         return not SkillTreeFns.HasTag(prefabname, "fly_shadow", activatedskills)
        --     end,
        -- },

        gwen_fly_radiance_1 = {
            title = "旅行",
            desc = "飞行过程中不再持续消耗圣蔼",
            icon = "wendy_gravestone_1",
            pos = {150, 0},
            group = "fly_radiance",
            tags = {'gwen_radiance',"fly_radiance"},
            root = true,
            -- locks = {"gwen_fly_radiance_lock_1"},
        },


        --------------------------------------------------------------------------------------------------------------
        ---飞针的阵营强化
        
        gwen_feizhen_shadow_1 = {
            title = "敬请期待",
            desc = "敬请期待",
            icon = "wendy_gravestone_1",
            pos = {-90, 0},
            group = "feizhen_shadow",
            tags = {'gwen_shadow',"feizhen_shadow"},
            root = true,
        },

         gwen_feizhenradiance_1 = {
            title = "敬请期待",
            desc = "敬请期待",
            icon = "wendy_gravestone_1",
            pos = {90, 0},
            group = "feizhen_radiance",
            tags = {'gwen_radiance',"feizhen_radiance"},
            root = true,
        },


        -----------------------------------------------------------------------------------------------------
        ---缝补相关
        gwen_xiubu_1 = {
            title = "心灵手巧Ⅰ",
            desc = "背包修复的效率提升且消耗更少的圣蔼",
            icon = "wendy_gravestone_1",
            pos = {-45, 160},
            group = "gwen_xiubu",
            tags = {'gwen_xiubu'},
            connects = {"gwen_xiubu_2"},
            root = true,
        },

        gwen_xiubu_2 = {
            title = "心灵手巧Ⅱ",
            desc = "主动使用背包修复时会缓慢恢复自身血量",
            icon = "wendy_gravestone_1",
            pos = {0, 160},
            group = "gwen_xiubu",
            tags = {'gwen_xiubu'},
            connects = {"gwen_xiubu_3"},
        },

        gwen_xiubu_3 = {
            title = "心灵手巧Ⅲ",
            desc = "背包现在会自动缓慢修复其中物品",
            icon = "wendy_gravestone_1",
            pos = {45, 160},
            group = "gwen_xiubu",
            tags = {'gwen_xiubu'},
        },
    }
    
    return {
        SKILLS = skills,
        ORDERS = ORDERS,
    }
end

return BuildSkillsData