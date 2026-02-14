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

local mouseDown = false
local function pressMouse()
	if mouseDown then
		return
	end
	if not mouse1press then
		return
	end
	pcall(function()
		mouse1press()
		mouseDown = true
	end)
end
local function releaseMouse()
	if not mouseDown then
		return
	end
	if not mouse1release then
		return
	end
	pcall(function()
		mouse1release()
		mouseDown = false
	end)
end

local function getCharacterRoot()
	local character = lplr.Character
	return character and character:FindFirstChild('HumanoidRootPart') or nil
end

local function getFishFolder()
	local gameFolder = workspace:FindFirstChild('Game')
	local fish = gameFolder and gameFolder:FindFirstChild('Fish')
	return fish and fish:FindFirstChild('client') or nil
end

local function getClosestFish(maxRange)
	local fishFolder = getFishFolder()
	local root = getCharacterRoot()
	if not fishFolder or not root then
		return nil
	end

	local target
	local distance = maxRange
	for _, fish in fishFolder:GetChildren() do
		local fishRoot = fish:FindFirstChild('RootPart')
		if fishRoot then
			local fishDistance = (fishRoot.Position - root.Position).Magnitude
			if fishDistance <= distance then
				target = fish
				distance = fishDistance
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
	local Catch
	local Range

	Catch = vape.Categories.Combat:CreateModule({
		Name = 'Auto Catch',
		Function = function(callback)
			if not callback then
				return
			end

			local remote = getStartCatchingRemote()
			if not remote then
				vape:CreateNotification(
					'Auto Catch',
					'StartCatching remote not found.',
					7,
					'alert'
				)
				task.defer(function()
					if Catch.Enabled then
						Catch:Toggle()
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
			until not Catch.Enabled
		end,
		Tooltip = 'Automatically catches nearby fish.'
	})

	Range = Catch:CreateSlider({
		Name = 'Range',
		Min = 1,
		Max = 30,
		Default = 20,
		Suffix = 'm'
	})
end)

run(function()
	local Minigame
	local Gradient
	local Legit

	Minigame = vape.Categories.Combat:CreateModule({
		Name = 'Auto Minigame',
		Function = function(callback)
			if not callback then
				releaseMouse()
				return
			end

			repeat
				local catchUI = getCatchUI()
				if catchUI then
					local green = catchUI:FindFirstChild('Green')
					local marker = catchUI:FindFirstChild('Marker')
					local fish = marker and marker:FindFirstChild('Fish')
					local gradient = catchUI:FindFirstChild('Gradient')

					if green and fish then
						if not Legit.Enabled then
							green.Size = UDim2.fromScale(1, 1)
							if Gradient.Enabled and gradient and gradient:IsA('GuiObject') then
								gradient.BackgroundColor3 = Color3.fromRGB(136, 194, 89)
							end
						end

						local greenCenter = green.AbsolutePosition + (green.AbsoluteSize / 2)
						local fishCenter = fish.AbsolutePosition + (fish.AbsoluteSize / 2)
						if (greenCenter - fishCenter).Magnitude > 3 then
							pressMouse()
						else
							releaseMouse()
						end
					else
						releaseMouse()
					end
				else
					releaseMouse()
				end
				task.wait()
			until not Minigame.Enabled

			releaseMouse()
		end,
		Tooltip = 'Automatically solves the fishing minigame.'
	})

	Gradient = Minigame:CreateToggle({
		Name = 'Gradient'
	})
	Legit = Minigame:CreateToggle({
		Name = 'Legit'
	})
end)
