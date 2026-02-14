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
	end)
	mouseDown = true
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
	end)
	mouseDown = false
end

run(function()
	local Catch
	local Range

	local function getFish()
		local target = nil
		local character = lplr.Character
		local root = character and character.HumanoidRootPart
		if not root then
			return nil
		end

		local suc, fishes = pcall(function()
			return workspace.Game.Fish.client:GetChildren()
		end)
		if not suc then
			return nil
		end

		for _, fish in next, fishes do
			local fishRoot = fish.RootPart
			if fishRoot then
				local mag = (fishRoot.Position - root.Position).Magnitude
				if mag < Range.Value then
					target = fish
				end
			end
		end
		return target
	end

	Catch = vape.Categories.Combat:CreateModule({
		Name = 'Auto Catch',
		Function = function(callback)
			if not callback then
				return
			end

			local remote
			local suc = pcall(function()
				remote = replicatedStorage.common.packages.Knit.Services.HarpoonService.RF.StartCatching
			end)
			if not suc or not remote then
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
				local fish = getFish()
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
				local catchui
				local suc = pcall(function()
					catchui = lplr.PlayerGui.Main.CatchingBar.Frame.Bar.Catch
				end)

				if suc and catchui and catchui.Parent then
					local green = catchui.Green
					local fish = catchui.Marker.Fish
					if green and fish then
						if not Legit.Enabled then
							green.Size = UDim2.new(1, 0, 1, 0)
							if Gradient.Enabled and catchui.Gradient then
								catchui.Gradient.BackgroundColor3 = Color3.fromRGB(136, 194, 89)
							end
						end

						local greenp = green.AbsolutePosition + green.AbsoluteSize / 2
						local fishp = fish.AbsolutePosition + fish.AbsoluteSize / 2
						if (greenp - fishp).Magnitude > 3 then
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
