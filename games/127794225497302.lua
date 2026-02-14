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
local lucide = vape.Libraries.lucide

local hmm = {}
for k, v in vape.Modules do
	for _, categories in next, {'Combat', 'Blatant', 'Render', 'Utility', 'World', 'Minigames'} do
		if v.Category == categories then
			table.insert(hmm, k)
		end
	end
end
for _, china in next, hmm do
	vape:Remove(china)
end

local farm = vape:CreateCategory({
	Name = 'Farm',
	Icon = lucide:get('fishing-hook')
})

run(function ()
    local Catch
    local Range
    local fish

	local function getFish()
		local Target = nil
		
		for i, v in next, workspace.Game.Fish.client:GetChildren() do
			local Magnitude = (v.RootPart.Position - lplr.Character.HumanoidRootPart.Position).Magnitude
			if Magnitude < Range.Value then
				Target = v
			end
		end
		return Target
	end
	
	Catch = farm:CreateModule({
		Name = 'Auto Catch',
		Function = function(callback)
			if callback then
				repeat
					fish = getFish(Range)
                    if fish then
                        replicatedStorage.common.packages.Knit.Services.HarpoonService.RF.StartCatching:InvokeServer(
                        fish.Name)
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

run(function ()
    local Minigame
    local Color
	local Size
	local catchui = lplr.PlayerGui.Main.CatchingBar.Frame.Bar.Catch

	Minigame = farm:CreateModule({
		Name = 'Auto Minigame',
		Function = function(callback)
			if callback then
				repeat
                    if catchui.Parent then
						catchui.Green.Size = UDim2.new(0, 0, Size, 0)
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
		Default = 10,
		Suffix = ''
	})
end)