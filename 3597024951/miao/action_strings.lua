local G = GLOBAL
------------------
--部署动作加“铺设地毯”字符 
local old_deploy_strfn = G.ACTIONS.DEPLOY.strfn
G.ACTIONS.DEPLOY.strfn = function(act)
	return act.invobject and act.invobject:HasTag("jx_rug_item") and "JX_DEPLOY" or old_deploy_strfn(act)
end
-----------------------------------------------------------------------------------------------------------
--采集动作加“拿取”字符
local old_pick_strfn = G.ACTIONS.PICK.strfn
G.ACTIONS.PICK.strfn = function(act)
	return act.target and act.target:HasAnyTag("jx_oven", "jx_table_2", "jx_table_6", "jx_icemaker", "jx_vending_machine") and "TAKEITEM" or old_pick_strfn(act)
end
-----------------------------------------------------------------------------------------------------------
--交易动作加字符
local old_give_strfn = G.ACTIONS.GIVE.strfn
G.ACTIONS.GIVE.strfn = function(act)
	return act.target and act.target:HasTag("jx_washer") and "WASH" or
    act.target and act.target:HasTag("jx_sewingmachine") and "SEW" or
    old_give_strfn(act)
end