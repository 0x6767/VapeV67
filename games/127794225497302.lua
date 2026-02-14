--!no-universal
local run = function(func)
	func()
end
local cloneref = cloneref or function(obj)
	return obj
end

local playersService = cloneref(game:GetService('Players'))
local replicatedStorage = cloneref(game:GetService('ReplicatedStorage'))

local lplr = playersService.LocalPlayer
local vape = shared.vape

local function getCharacter()
	return lplr.Character
end

local function getFishFolder()
	local gameFolder = workspace:FindFirstChild('Game')
	local fishFolder = gameFolder and gameFolder:FindFirstChild('Fish')
	return fishFolder and fishFolder:FindFirstChild('client') or nil
end

local function getClosestFish(maxRange)
	local character = getCharacter()
	local root = character and character:FindFirstChild('HumanoidRootPart')
	local fishFolder = getFishFolder()
	if not root or not fishFolder then return end

	local target
	local bestDistance = maxRange
	for _, fish in fishFolder:GetChildren() do
		local fishRoot = fish:FindFirstChild('RootPart')
		if fishRoot then
			local distance = (fishRoot.Position - root.Position).Magnitude
			if distance <= bestDistance then
				bestDistance = distance
				target = fish
			end
		end
	end
	return target
end

local function getStartCatchingRemote()
	local common = replicatedStorage:FindFirstChild('common')
	local packages = common and common:FindFirstChild('packages')
	local knit = packages and packages:FindFirstChild('Knit')
	local services = knit and knit:FindFirstChild('Services')
	local harpoon = services and services:FindFirstChild('HarpoonService')
	local rf = harpoon and harpoon:FindFirstChild('RF')
	return rf and rf:FindFirstChild('StartCatching') or nil
end

local function getCatchUI()
	local playerGui = lplr:FindFirstChild('PlayerGui')
	local main = playerGui and playerGui:FindFirstChild('Main')
	local catchingBar = main and main:FindFirstChild('CatchingBar')
	local frame = catchingBar and catchingBar:FindFirstChild('Frame')
	local bar = frame and frame:FindFirstChild('Bar')
	return bar and bar:FindFirstChild('Catch') or nil
end

run(function()
	local AutoCatch
	local Range

	AutoCatch = vape.Categories.Combat:CreateModule({
		Name = 'Auto Catch',
		Function = function(callback)
			if not callback then return end

			local remote = getStartCatchingRemote()
			if not remote then
				vape:CreateNotification('Auto Catch', 'StartCatching remote not found.', 7, 'alert')
				task.defer(function()
					if AutoCatch.Enabled then
						AutoCatch:Toggle()
					end
				end)
				return
			end

			repeat
				local fish = getClosestFish(Range.Value)
				if fish then
					remote:InvokeServer(fish.Name)
				end
				task.wait(0.05)
			until not AutoCatch.Enabled
		end,
		Tooltip = 'Automatically catches nearby fish.'
	})

	Range = AutoCatch:CreateSlider({
		Name = 'Range',
		Min = 1,
		Max = 30,
		Default = 20,
		Suffix = 'm'
	})
end)

run(function()
	local AutoMinigame
	local Gradient

	AutoMinigame = vape.Categories.Combat:CreateModule({
		Name = 'Auto Minigame',
		Function = function(callback)
			if not callback then return end

			repeat
				local catchUI = getCatchUI()
				if catchUI then
					local green = catchUI:FindFirstChild('Green')
					local gradient = catchUI:FindFirstChild('Gradient')
					if green then
						green.Size = UDim2.fromScale(1, 1)
					end
					if Gradient.Enabled and gradient and gradient:IsA('GuiObject') then
						gradient.BackgroundColor3 = Color3.fromRGB(136, 194, 89)
					end
				end
				task.wait()
			until not AutoMinigame.Enabled
		end,
		Tooltip = 'Automatically solves the catch minigame.'
	})

	Gradient = AutoMinigame:CreateToggle({
		Name = 'Gradient'
	})
end)
