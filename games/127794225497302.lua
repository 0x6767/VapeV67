local run = function(func)
	func()
end
local cloneref = cloneref or function(obj)
	return obj
end

local playersService = cloneref(game:GetService('Players'))
local replicatedStorage = cloneref(game:GetService('ReplicatedStorage'))
local runService = cloneref(game:GetService('RunService'))
local inputService = cloneref(game:GetService('UserInputService'))
local tweenService = cloneref(game:GetService('TweenService'))
local httpService = cloneref(game:GetService('HttpService'))
local textChatService = cloneref(game:GetService('TextChatService'))
local collectionService = cloneref(game:GetService('CollectionService'))
local contextActionService = cloneref(game:GetService('ContextActionService'))
local guiService = cloneref(game:GetService('GuiService'))
local coreGui = cloneref(game:GetService('CoreGui'))
local starterGui = cloneref(game:GetService('StarterGui'))

local isnetworkowner = identifyexecutor and table.find({'AWP', 'Nihon'}, ({identifyexecutor()})[1]) and isnetworkowner or function()
	return true
end
local gameCamera = workspace.CurrentCamera
local lplr = playersService.LocalPlayer
local moduleCategories = {'Combat', 'Blatant', 'Render', 'Utility', 'World', 'Minigames'}

local vape = shared.vape
local lucide = vape.Libraries.lucide

local removeModules = {}
for moduleName, module in vape.Modules do
	for _, category in next, moduleCategories do
		if module.Category == category then
			table.insert(removeModules, moduleName)
		end
	end
end
for _, moduleName in next, removeModules do
	vape:Remove(moduleName)
end

local farm = vape:CreateCategory({
	Name = 'Farm',
	Icon = lucide and lucide:GetAssetId('fishing-hook', 'fish') or ''
})


run(function()
	local Catch
	local Range
	local fish

	local function getFish()
		local target = nil
		local character = lplr.Character
		if not character or not character.HumanoidRootPart then
			return nil
		end

		local suc, fishes = pcall(function()
			return workspace.Game.Fish.client:GetChildren()
		end)
		if not suc then
			return nil
		end

		for _, fishObj in next, fishes do
			if fishObj.RootPart then
				local magnitude = (fishObj.RootPart.Position - character.HumanoidRootPart.Position).Magnitude
				if magnitude < Range.Value then
					target = fishObj
				end
			end
		end
		return target
	end
	
	Catch = farm:CreateModule({
		Name = 'Auto Catch',
		Function = function(callback)
			if callback then
				repeat
					fish = getFish()
					if fish then
						replicatedStorage.common.packages.Knit.Services.HarpoonService.RF.StartCatching:InvokeServer(
							fish.Name
						)
					end
					task.wait()
				until not Catch.Enabled
			end
		end
	})

	Range = Catch:CreateSlider({
		Name = 'Range',
		Min = 0,
		Max = 30,
		Default = 20,
		Suffix = 'm'
	})
end)

run(function()
	local Minigame
	local Gradient
	local Size

	Minigame = farm:CreateModule({
		Name = 'Auto Minigame',
		Function = function(callback)
			if callback then
				repeat
					local catchui
					local suc = pcall(function()
						catchui = lplr.PlayerGui.Main.CatchingBar.Frame.Bar.Catch
					end)
					if suc and catchui and catchui.Parent then
						catchui.Green.Size = UDim2.new(0, 0, Size.Value, 0)
						if Gradient.Enabled then
							catchui.Gradient.BackgroundColor3 = Color3.fromRGB(136, 194, 89)
						end
					end
					task.wait()
				until not Minigame.Enabled
			end
		end,
		Tooltip = 'take a guess'
	})
	Gradient = Minigame:CreateToggle({
		Name = 'Gradient',
		Tooltip = 'make your bar turn green'
	})
	Size = Minigame:CreateSlider({
		Name = 'Size',
		Min = 0,
		Max = 1,
		Default = 1,
		Suffix = ''
	})
end)
