--- 海伊角色中文字符串兼容补丁。
-- 使用场景：
-- * 部分翻译或语言模组会整体覆盖 STRINGS 表，从而清空或替换其他角色模组的自定义字符串。
-- * 本文件在 Wilton 模组中通过 modimport 加载，用于在中文模式下重新写入海伊角色的关键中文字符串。
-- 实现方式：
-- * 通过一个局部函数集中设置海伊相关的中文字符串。
-- * 使用 AddSimPostInit 在世界加载完成后再次执行，尽量保证在翻译模组之后生效。

---
-- @desc 为海伊角色写入/覆盖关键中文字符串。
local function ApplyHaiyiChineseStrings()
	-- 皮肤描述：海伊默认皮肤
	STRINGS.SKIN_DESCRIPTIONS = STRINGS.SKIN_DESCRIPTIONS or {}
	STRINGS.SKIN_DESCRIPTIONS.haiyi_none = "海伊的默认外观。"

	-- 角色名言：海伊
	STRINGS.CHARACTER_QUOTES = STRINGS.CHARACTER_QUOTES or {}
	STRINGS.CHARACTER_QUOTES.haiyi = "\"活泼可爱，偶尔带点恶作剧的幽默感\""

	if TheNet ~= nil then
		print("[WILTON][HAIYI_COMPAT] Applied Haiyi Chinese strings, language=", tostring(TheNet:GetLanguageCode()))
	else
		print("[WILTON][HAIYI_COMPAT] Applied Haiyi Chinese strings.")
	end
end

-- 优先在世界加载完成后再执行一次补丁，避免被其他语言/翻译模组覆盖。
if AddSimPostInit ~= nil then
	AddSimPostInit(function()
		ApplyHaiyiChineseStrings()
	end)
else
	-- 兜底：如果运行环境不存在 AddSimPostInit，则立刻应用一次兼容补丁。
	ApplyHaiyiChineseStrings()
end
