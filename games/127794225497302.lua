local run = function(func)
	func()
end
local cloneref = cloneref or function(obj)
	return obj
end

local unpack = table.unpack or unpack
local playersService = cloneref(game:GetService('Players'))
local inputService = cloneref(game:GetService('UserInputService'))

local gameCamera = workspace.CurrentCamera or workspace:FindFirstChildWhichIsA('Camera')
local lplr = playersService.LocalPlayer
local vape = shared.vape

local function notif(...)
	return vape:CreateNotification(...)
end

local function getFishFolder()
	local gameFolder = workspace:FindFirstChild('Game')
	if not gameFolder then return end
	local fishFolder = gameFolder:FindFirstChild('Fish')
	return fishFolder and fishFolder:FindFirstChild('client') or nil
end

local function getToolEvent()
	local character = lplr.Character
	if character then
		for _, tool in character:GetChildren() do
			if tool:IsA('Tool') then
				local remote = tool:FindFirstChild('Event')
				if remote and remote:IsA('RemoteEvent') then
					return remote
				end
			end
		end
	end

	local backpack = lplr:FindFirstChildOfClass('Backpack')
	if backpack then
		for _, tool in backpack:GetChildren() do
			if tool:IsA('Tool') then
				local remote = tool:FindFirstChild('Event')
				if remote and remote:IsA('RemoteEvent') then
					return remote
				end
			end
		end
	end

	local debris = workspace:FindFirstChild('debris')
	if not debris then return end
	for _, holder in debris:GetChildren() do
		local tool = holder:FindFirstChild('Tool')
		local remote = tool and tool:FindFirstChild('Event')
		if remote and remote:IsA('RemoteEvent') then
			return remote
		end
	end
end

local function getClosestFish(maxFov)
	local fishFolder = getFishFolder()
	if not fishFolder then return end

	local mousePosition = inputService:GetMouseLocation()
	local fishRoot
	local fishDistance = maxFov > 0 and maxFov or math.huge

	for _, fish in fishFolder:GetChildren() do
		local root = fish:FindFirstChild('RootPart')
		if root and root:IsA('BasePart') then
			local screenPosition, onScreen = gameCamera:WorldToViewportPoint(root.Position)
			if onScreen then
				local checkDistance = (Vector2.new(screenPosition.X, screenPosition.Y) - mousePosition).Magnitude
				if checkDistance < fishDistance then
					fishDistance = checkDistance
					fishRoot = root
				end
			end
		end
	end

	return fishRoot
end

run(function()
	local FishSilentAim
	local FOV
	local hooked = false
	local oldNamecall

	FishSilentAim = vape.Categories.Blatant:CreateModule({
		Name = 'FishSilentAim',
		Function = function(callback)
			if not callback then return end
			if hooked then return end

			if not hookmetamethod or not getnamecallmethod or not newcclosure then
				notif('FishSilentAim', 'Executor is missing hookmetamethod support.', 10, 'alert')
				task.defer(function()
					if FishSilentAim.Enabled then
						FishSilentAim:Toggle()
					end
				end)
				return
			end

			hooked = true
			oldNamecall = hookmetamethod(game, '__namecall', newcclosure(function(self, ...)
				local method = getnamecallmethod()
				if FishSilentAim.Enabled and method == 'FireServer' then
					local args = {...}
					if args[1] == 'use' then
						local event = getToolEvent()
						if event and self == event then
							local fish = getClosestFish(FOV.Value)
							if fish then
								local cameraPosition = gameCamera.CFrame.Position
								local direction = fish.Position - cameraPosition
								if direction.Magnitude > 0 then
									args[2] = fish.Position
									args[3] = direction.Unit
									return oldNamecall(self, unpack(args))
								end
							end
						end
					end
				end
				return oldNamecall(self, ...)
			end))
		end,
		Tooltip = 'Silently aims your use remote to the closest fish.'
	})

	FOV = FishSilentAim:CreateSlider({
		Name = 'FOV',
		Min = 25,
		Max = 1000,
		Default = 300
	})
end)
