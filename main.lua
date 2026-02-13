repeat task.wait() until game:IsLoaded()
if shared.vape then shared.vape:Uninject() end

-- why do exploits fail to implement anything correctly? Is it really that hard?
if identifyexecutor then
	if table.find({'Argon', 'Wave'}, ({identifyexecutor()})[1]) then
		getgenv().setthreadidentity = nil
	end
end

local vape
local loadstring = function(...)
	local res, err = loadstring(...)
	if err and vape then
		vape:CreateNotification('Vape', 'Failed to load : '..err, 30, 'alert')
	end
	return res
end
local queue_on_teleport = queue_on_teleport or function() end
local isfile = isfile or function(file)
	local suc, res = pcall(function()
		return readfile(file)
	end)
	return suc and res ~= nil and res ~= ''
end
local cloneref = cloneref or function(obj)
	return obj
end
local playersService = cloneref(game:GetService('Players'))

local function downloadFile(path, func)
	if not isfile(path) then
		local suc, res = pcall(function()
			return game:HttpGet('https://raw.githubusercontent.com/0x6767/VapeV67/'..readfile('vape67/profiles/commit.txt')..'/'..select(1, path:gsub('vape67/', '')), true)
		end)
		if not suc or res == '404: Not Found' then
			error(res)
		end
		if path:find('.lua') then
			res = '--This watermark is used to delete the file if its cached, remove it to make the file persist after vape updates.\n'..res
		end
		writefile(path, res)
	end
	return (func or readfile)(path)
end

local function finishLoading()
	vape.Init = nil
	vape:Load()
	task.spawn(function()
		repeat
			vape:Save()
			task.wait(10)
		until not vape.Loaded
	end)

	local teleportedServers
	vape:Clean(playersService.LocalPlayer.OnTeleport:Connect(function()
		if (not teleportedServers) and (not shared.VapeIndependent) then
			teleportedServers = true
			local teleportScript = [[
				shared.vapereload = true
				if shared.VapeDeveloper then
					loadstring(readfile('vape67/loader.lua'), 'loader')()
				else
					loadstring(game:HttpGet('https://raw.githubusercontent.com/0x6767/VapeV67/'..readfile('vape67/profiles/commit.txt')..'/loader.lua', true), 'loader')()
				end
			]]
			if shared.VapeDeveloper then
				teleportScript = 'shared.VapeDeveloper = true\n'..teleportScript
			end
			if shared.VapeCustomProfile then
				teleportScript = 'shared.VapeCustomProfile = "'..shared.VapeCustomProfile..'"\n'..teleportScript
			end
			vape:Save()
			queue_on_teleport(teleportScript)
		end
	end))

	if not shared.vapereload then
		if not vape.Categories then return end
		if vape.Categories.Main.Options['GUI bind indicator'].Enabled then
			vape:CreateNotification('Finished Loading', vape.VapeButton and 'Press the button in the top right to open GUI' or 'Press '..table.concat(vape.Keybind, ' + '):upper()..' to open GUI', 5)
		end
	end
end

if not isfile('vape67/profiles/gui.txt') then
	writefile('vape67/profiles/gui.txt', 'new')
end
local gui = readfile('vape67/profiles/gui.txt')

if not isfolder('vape67/assets/'..gui) then
	makefolder('vape67/assets/'..gui)
end
vape = loadstring(downloadFile('vape67/guis/'..gui..'.lua'), 'gui')()
shared.vape = vape

if not shared.VapeIndependent then
	loadstring(
		downloadFile('vape67/games/universal.lua'),
		'universal'
	)()

	local placeId = tostring(game.PlaceId)
	local cachedPlaceScriptPath = 'vape67/games/'..placeId..'.lua'
	local localPlaceScriptPath = 'games/'..placeId..'.lua'
	local placeScriptPath = cachedPlaceScriptPath
	if shared.VapeDeveloper and isfile(localPlaceScriptPath) then
		placeScriptPath = localPlaceScriptPath
	end

	if isfile(placeScriptPath) then
		loadstring(
			readfile(placeScriptPath),
			placeId
		)(...)
	else
		if not shared.VapeDeveloper then
			local suc, res = pcall(function()
				return game:HttpGet(
					'https://raw.githubusercontent.com/0x6767/VapeV67/'..readfile('vape67/profiles/commit.txt')..'/games/'..placeId..'.lua',
					true
				)
			end)
			if suc and res ~= '404: Not Found' then
				loadstring(
					downloadFile(cachedPlaceScriptPath),
					placeId
				)(...)
			end
		end
	end
	finishLoading()
else
	vape.Init = finishLoading
	return vape
end
