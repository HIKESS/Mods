---创建技能树
local skilltree_defs = require("prefabs/skilltree_defs")
local BuildSkillsData = require("prefabs/skilltree_gwen")

if BuildSkillsData then
    local data = BuildSkillsData(skilltree_defs.FN)
    if data then
        skilltree_defs.CreateSkillTreeFor("gwen", data.SKILLS)
        skilltree_defs.SKILLTREE_ORDERS["gwen"] = data.ORDERS
    end
end

local OldGetSkilltreeBG = GLOBAL.GetSkilltreeBG
GLOBAL.GetSkilltreeBG = function(imagename,...)
    if imagename == "gwen_background.tex" then
        return "images/gwen_background.xml"  
    else
        return OldGetSkilltreeBG(imagename, ...)
    end
end