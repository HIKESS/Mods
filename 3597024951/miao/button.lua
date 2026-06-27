local G = GLOBAL
---------------------
--按钮(偷懒)
local old_incinerate_fn = G.ACTIONS.INCINERATE.fn
G.ACTIONS.INCINERATE.fn = function(act)
  if act.target and act.target:HasTag("jx_button_container") then
    if act.target.StartWork then
      if act.target.components.container then
        act.target.components.container:Close()
      end
      act.target:StartWork()
      return true
    else
      return false
    end
    
  elseif act.target and act.target:HasTag("jx_disassembler") then
    for k, v in pairs(act.target.components.container.slots) do
      if v ~= nil then
        return act.target:OnGetItem(v, act.doer)
      end
    end
    return false
    
  else
    return old_incinerate_fn(act)
  end
end