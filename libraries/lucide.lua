local lucide = {
	BaseUrl = 'https://raw.githubusercontent.com/lucide-icons/lucide/main/icons/',
	AssetRoot = 'vape67/assets/lucide/',
	Icons = {
		activity = 'activity',
		alert = 'alert-triangle',
		arrow_right = 'arrow-right',
		backpack = 'backpack',
		bug = 'bug',
		check = 'check',
		circle = 'circle',
		crosshair = 'crosshair',
		eye = 'eye',
		flame = 'flame',
		gamepad = 'gamepad-2',
		globe = 'globe',
		info = 'info',
		layout = 'layout-grid',
		radar = 'radar',
		search = 'search',
		settings = 'settings',
		shield = 'shield',
		swords = 'swords',
		target = 'target',
		text = 'text-cursor',
		user = 'user-round',
		users = 'users-round',
		wrench = 'wrench'
	},
	Aliases = {
		combat = 'swords',
		blatant = 'flame',
		render = 'eye',
		utility = 'wrench',
		world = 'globe',
		inventory = 'backpack',
		minigames = 'gamepad',
		profiles = 'user',
		friends = 'users',
		targets = 'crosshair',
		textgui = 'text',
		radar = 'radar',
		notifications = 'alert',
		gui = 'layout'
	}
}

local function normalize(name)
	return tostring(name or ''):lower():gsub('%s+', '_'):gsub('-', '_')
end

function lucide:Get(name, fallback)
	local key = normalize(name)
	local icon = self.Icons[key]
	if icon then
		return icon
	end

	local alias = self.Aliases[key]
	if alias then
		return self.Icons[alias] or alias
	end

	local fallbackKey = normalize(fallback or 'circle')
	return self.Icons[fallbackKey] or fallbackKey:gsub('_', '-')
end

function lucide:GetUrl(name, fallback)
	local icon = self:Get(name, fallback)
	return self.BaseUrl..icon..'.svg'
end

function lucide:GetAssetPath(name, fallback)
	local icon = self:Get(name, fallback)
	return self.AssetRoot..icon..'.svg'
end

function lucide:Has(name)
	local key = normalize(name)
	return self.Icons[key] ~= nil or self.Aliases[key] ~= nil
end

return lucide
