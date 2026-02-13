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
local assetfunction = getcustomasset

local vape = shared.vape
local entitylib = vape.Libraries.entity
local targetinfo = vape.Libraries.targetinfo

local function getFish(Range)
    local Target = nil
	
    for i, v in next, workspace.Game.Fish.client:GetChildren() do
        if not v.dead.Enabled then
            local Magnitude = (v.RootPart.Position - lplr.Character.HumanoidRootPart.Position).Magnitude
            if Range < Magnitude then
                Target = v
            end
        end
    end
	return Target
end

run(function ()
    local Catch
    local Range
    local fish
	
	Catch = vape.Categories.Combat:CreateModule({
		Name = 'Auto Catch',
		Function = function(callback)
			if callback then
				repeat
					fish = getFish(Range)
					if fish then
						replicatedStorage.common.packages.Knit.Services.HarpoonService.RF.StartCatching:InvokeServer(fish.Name)
					end
				until not Catch.Enabled
			end
		end
	})

	Range = Catch:CreateSlider({
		Name = '',
		Min = 0,
		Max = 30,
		Default = 20,
		Suffix = 'm'
	})
end)

run(function ()
    local Minigame
	local Color
	local catchui = lplr.PlayerGui.Main.CatchingBar.Frame.Bar.Catch

	Minigame = vape.Categories.Combat:CreateModule({
		Name = 'Auto Minigame',
		Function = function(callback)
			if callback then
				repeat
					if catchui.Parent then
						catchui.Green.Position = UDim2.new(0, catchui.Marker.Fish.Position.X.Scale, 0, catchui.Marker.Fish.Position.Y.Scale)
					end
				until not Minigame.Enabled
			end
		end
	})
end)