-- 临时调试脚本：检查CHARACTER_ABILITIES是否被正确加载
return function()
    if not GLOBAL.NPC_TUNING then
        print('[DEBUG] ERROR: NPC_TUNING 未被加载！')
        return
    end
    print('[DEBUG] NPC_TUNING 已加载')
    if not GLOBAL.NPC_TUNING.CHARACTER_ABILITIES then
        print('[DEBUG] ERROR: CHARACTER_ABILITIES 不存在！')
        return
    end
    print('[DEBUG] CHARACTER_ABILITIES 已加载')
    if GLOBAL.NPC_TUNING.CHARACTER_ABILITIES.winona then
        print(string.format('[DEBUG] winona有%d个能力', #GLOBAL.NPC_TUNING.CHARACTER_ABILITIES.winona))
    else
        print('[DEBUG] ERROR: winona条目不存在！')
    end
    if GLOBAL.NPC_TUNING.CHARACTER_ABILITIES.wathgrithr then
        print(string.format('[DEBUG] wathgrithr有%d个能力', #GLOBAL.NPC_TUNING.CHARACTER_ABILITIES.wathgrithr))
    else
        print('[DEBUG] ERROR: wathgrithr条目不存在！')
    end
end
