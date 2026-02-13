local run = function(func)
	func()
end

local cloneref = cloneref or function(obj)
	return obj
end

local unpack = table.unpack or unpack
local playersService = cloneref(game:GetService('Players'))
local inputService = cloneref(game:GetService('UserInputService'))

local gameCamera = workspace.CurrentCamera
local lplr = playersService.LocalPlayer
local vape = shared.vape

local function getFishFolder()
	local gameFolder = workspace:FindFirstChild('Game')
	local fishFolder = gameFolder and gameFolder:FindFirstChild('Fish')
	return fishFolder and fishFolder:FindFirstChild('client') or nil
end

local function getToolEvent()
	local debris = workspace:FindFirstChild('debris')
	if debris then
		local playerHolder = debris:FindFirstChild(lplr.Name)
		local playerTool = playerHolder and playerHolder:FindFirstChild('Tool')
		local playerEvent = playerTool and playerTool:FindFirstChild('Event')
		if playerEvent and playerEvent:IsA('RemoteEvent') then
			return playerEvent
		end

		for _, holder in debris:GetChildren() do
			local tool = holder:FindFirstChild('Tool')
			local remote = tool and tool:FindFirstChild('Event')
			if remote and remote:IsA('RemoteEvent') then
				return remote
			end
		end
	end

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
end

local function getClosestFish(maxFov)
	local fishFolder = getFishFolder()
	if not fishFolder then
		return nil
	end

	local mousePosition = inputService:GetMouseLocation()
	local closestRoot
	local closestDistance = maxFov > 0 and maxFov or math.huge

	for _, fish in fishFolder:GetChildren() do
		local root = fish:FindFirstChild('RootPart')
		if root and root:IsA('BasePart') then
			local screen, visible = gameCamera:WorldToViewportPoint(root.Position)
			if visible then
				local distance = (Vector2.new(screen.X, screen.Y) - mousePosition).Magnitude
				if distance < closestDistance then
					closestDistance = distance
					closestRoot = root
				end
			end
		end
	end

	return closestRoot
end

run(function()
	local FishSilentAim
	local FOV
	local hooked = false
	local oldNamecall

	FishSilentAim = vape.Categories.Blatant:CreateModule({
		Name = 'FishSilentAim',
		Function = function(callback)
			if not callback then
				return
			end

			if hooked then
				return
			end

			if not hookmetamethod or not getnamecallmethod or not newcclosure then
				vape:CreateNotification(
					'FishSilentAim',
					'Exploit tidak support hookmetamethod/getnamecallmethod.',
					10,
					'alert'
				)
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
				local args = {...}

				if FishSilentAim.Enabled and method == 'FireServer' and args[1] == 'use' then
					local event = getToolEvent()
					if event and self == event then
						local fishRoot = getClosestFish(FOV.Value)
						if fishRoot then
							local cameraPosition = gameCamera.CFrame.Position
							local delta = fishRoot.Position - cameraPosition
							if delta.Magnitude > 0 then
								args[2] = fishRoot.Position
								args[3] = delta.Unit
								return oldNamecall(self, unpack(args))
							end
						end
					end
				end

				return oldNamecall(self, ...)
			end))
		end,
		Tooltip = 'Silent aim ke ikan terdekat di workspace.Game.Fish.client'
	})

	FOV = FishSilentAim:CreateSlider({
		Name = 'FOV',
		Min = 25,
		Max = 1000,
		Default = 300
	})
end)
