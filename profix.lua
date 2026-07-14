local _version = "1.6.6"
local WindUI = loadstring(game:HttpGet("https://github.com/Footagesus/WindUI/releases/download/" .. _version .. "/main.lua"))() 
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local Camera = workspace.CurrentCamera
local LocalPlayer = Players.LocalPlayer

-- Настройки и переменные
local ESP_Settings = {
    Sherif = false, Murderer = false, Innocent = false,
    Tracers = false, EmptyBox = false, Names = false, 
    Studs = false, Highlight = false
}
local FarmSettings = { Enabled = false, Speed = 17 }
local PlayerSettings = { WalkSpeed = 16, JumpPower = 50 }
local currentTween = nil 
local AimButtonGui = nil 
local KillButtonGui = nil
local ESP_Objects = {}

local function applyPlayerSettings(character)
    local humanoid = character and character:FindFirstChild("Humanoid")
    if humanoid then
        humanoid.WalkSpeed = PlayerSettings.WalkSpeed
        humanoid.JumpPower = PlayerSettings.JumpPower
    end
end

LocalPlayer.CharacterAdded:Connect(function(character)
    task.wait(0.5) 
    applyPlayerSettings(character)
end)

local function getPlayerRole(player)
    if not player.Character then return "Innocent" end
    if player.Character:FindFirstChild("Knife", true) or (player.Backpack and player.Backpack:FindFirstChild("Knife", true)) then
        return "Murderer"
    elseif player.Character:FindFirstChild("Gun", true) or (player.Backpack and player.Backpack:FindFirstChild("Gun", true)) then
        return "Sherif"
    end
    return "Innocent"
end

WindUI:AddTheme({ Name = "SubRed", Text = Color3.fromHex("#FFFFFF"), Icon = Color3.fromHex("#ef4444") })

local Window = WindUI:CreateWindow({
    Background = "video:https://github.com/snegr8308-lab/Backgrounds-Themes/raw/main/red_bg.webm",
    BackgroundTransparency = 0.67, 
    Title = "Profix Hub", 
    Icon = "shield",
    Author = "by enormus", 
    Folder = "ProfixHub", 
    Size = UDim2.fromOffset(580, 460),
    Transparent = true, 
    Theme = "SubRed", 
    User = { Enabled = true, Anonymous = false },
})

local MainSection = Window:Section({ Title = "Main", Icon = "home", Opened = true })
local EcpTab = MainSection:Tab({ Title = "Ecp" })
local AutoFarmTab = MainSection:Tab({ 
    Title = "AutoFarm",
    Locked = true,
    })
local PlayerTab = MainSection:Tab({ Title = "Player" })
local RolesSection = Window:Section({ Title = "Roles", Icon = "user", Opened = false })
local SherifTab = RolesSection:Tab({ Title = "Sherif" })
local MurderTab = RolesSection:Tab({ Title = "Murderer" })

-- ESP Toggles
EcpTab:Toggle({ Title = "ESP Sherif", Callback = function(s) ESP_Settings.Sherif = s end })
EcpTab:Toggle({ Title = "ESP Murderer", Callback = function(s) ESP_Settings.Murderer = s end })
EcpTab:Toggle({ Title = "ESP Innocent", Callback = function(s) ESP_Settings.Innocent = s end })
EcpTab:Toggle({ Title = "Tracers", Callback = function(s) ESP_Settings.Tracers = s end })
EcpTab:Toggle({ Title = "Box", Callback = function(s) ESP_Settings.EmptyBox = s end })
EcpTab:Toggle({ Title = "Names", Callback = function(s) ESP_Settings.Names = s end })
EcpTab:Toggle({ Title = "Studs", Callback = function(s) ESP_Settings.Studs = s end })
EcpTab:Toggle({ Title = "Highlights", Callback = function(s) ESP_Settings.Highlight = s end })

-- AutoFarm
AutoFarmTab:Slider({ Title = "Farm Speed",
    Locked = false,
    Value = { Min = 17, Max = 100, Default = 17 }, Callback = function(v) FarmSettings.Speed = v end })
AutoFarmTab:Toggle({
    Title = "Start Auto Farm", 
    State = false,
    Callback = function(state)
        FarmSettings.Enabled = state
        if not FarmSettings.Enabled then if currentTween then currentTween:Cancel() currentTween = nil end return end
        task.spawn(function()
            while FarmSettings.Enabled do
                local character = LocalPlayer.Character
                local RootPart = character and character:FindFirstChild("HumanoidRootPart")
                if RootPart then
                    local closestCoin, shortestDistance = nil, math.huge
                    for _, obj in pairs(workspace:GetDescendants()) do
                        if obj.Name == "Coin_Server" and obj:IsA("BasePart") then
                            local dist = (RootPart.Position - obj.Position).Magnitude
                            if dist < shortestDistance then shortestDistance, closestCoin = dist, obj end
                        end
                    end
                    if closestCoin then
                        currentTween = TweenService:Create(RootPart, TweenInfo.new(shortestDistance / FarmSettings.Speed, Enum.EasingStyle.Linear), {CFrame = closestCoin.CFrame})
                        currentTween:Play()
                        currentTween.Completed:Wait()
                    end
                end
                task.wait(0.1)
            end
        end)
    end
})

-- Player
PlayerTab:Slider({ Title = "WalkSpeed", Value = { Min = 16, Max = 100, Default = 16 }, Callback = function(v) PlayerSettings.WalkSpeed = v; applyPlayerSettings(LocalPlayer.Character) end })
PlayerTab:Slider({ Title = "JumpPower", Value = { Min = 50, Max = 200, Default = 50 }, Callback = function(v) PlayerSettings.JumpPower = v; applyPlayerSettings(LocalPlayer.Character) end })

-- Sherif Buttons
SherifTab:Button({
    Title = "Toggle Crosshair Button",
    Callback = function()
        if AimButtonGui then
            AimButtonGui:Destroy()
            AimButtonGui = nil
        else
            AimButtonGui = Instance.new("ScreenGui", game.CoreGui)
            local btn = Instance.new("ImageButton", AimButtonGui)
            btn.Size = UDim2.new(0, 100, 0, 100)
            btn.Position = UDim2.new(0.5, -120, 0.5, -50)
            btn.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
            btn.AutoButtonColor = false
            btn.Draggable = true
            Instance.new("UICorner", btn).CornerRadius = UDim.new(0.25, 0)
            Instance.new("UIStroke", btn).Color = Color3.new(0, 0, 0)
            Instance.new("UIStroke", btn).Thickness = 4
            
            local function cL(s, p) local l = Instance.new("Frame", btn) l.Size = s; l.Position = p; l.BackgroundColor3 = Color3.new(1,1,1); l.BorderSizePixel = 0 end
            cL(UDim2.new(0.06,0,0.35,0), UDim2.new(0.47,0,0.1,0))
            cL(UDim2.new(0.06,0,0.35,0), UDim2.new(0.47,0,0.55,0))
            cL(UDim2.new(0.35,0,0.06,0), UDim2.new(0.1,0,0.47,0))
            cL(UDim2.new(0.35,0,0.06,0), UDim2.new(0.55,0,0.47,0))
            
            btn.MouseButton1Click:Connect(function()
                for _, player in pairs(Players:GetPlayers()) do
                    if player ~= LocalPlayer and getPlayerRole(player) == "Murderer" and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
                        local Gun = LocalPlayer.Character:FindFirstChild("Gun", true) or LocalPlayer.Backpack:FindFirstChild("Gun", true)
                        if Gun and Gun:FindFirstChild("Shoot") then
                            Gun.Shoot:FireServer(player.Character.HumanoidRootPart.CFrame, LocalPlayer.Character.HumanoidRootPart.CFrame)
                        end
                        break
                    end
                end
            end)
        end
    end
})

-- Murderer Buttons
MurderTab:Button({
    Title = "Toggle KillAll Button",
    Callback = function()
        if KillButtonGui then
            KillButtonGui:Destroy()
            KillButtonGui = nil
        else
            KillButtonGui = Instance.new("ScreenGui", game.CoreGui)
            local btn = Instance.new("ImageButton", KillButtonGui)
            btn.Size = UDim2.new(0, 100, 0, 100)
            btn.Position = UDim2.new(0.5, 20, 0.5, -50)
            btn.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
            btn.AutoButtonColor = false
            btn.Draggable = true
            Instance.new("UICorner", btn).CornerRadius = UDim.new(0.25, 0)
            Instance.new("UIStroke", btn).Color = Color3.new(0, 0, 0)
            Instance.new("UIStroke", btn).Thickness = 4
            
            local icon = Instance.new("ImageLabel", btn)
            icon.Size = UDim2.new(0.6, 0, 0.6, 0)
            icon.Position = UDim2.new(0.2, 0, 0.2, 0)
            icon.BackgroundTransparency = 1
            icon.Image = "rbxassetid://6034878345"
            icon.ImageColor3 = Color3.fromRGB(255, 50, 50)
            
            btn.MouseButton1Click:Connect(function()
                local Remote = game:GetService("ReplicatedStorage"):WaitForChild("Remotes"):WaitForChild("Gameplay"):WaitForChild("KillEvent")
                local MyHRP = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
                if not MyHRP then return end
                local savedCFrame = MyHRP.CFrame
                for _, player in pairs(Players:GetPlayers()) do
                    if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
                        local targetHRP = player.Character.HumanoidRootPart
                        MyHRP.CFrame = targetHRP.CFrame * CFrame.new(0, 0, 1.5)
                        Remote:FireServer(player.Name, Color3.new(0.098, 0.882, 0.098), "Melee Kill!", targetHRP.CFrame)
                        task.wait(0.1)
                    end
                end
                MyHRP.CFrame = savedCFrame
            end)
        end
    end
})

-- ESP Loop
RunService.RenderStepped:Connect(function()
    for _, player in pairs(Players:GetPlayers()) do
        if player == LocalPlayer or not player.Character or not player.Character:FindFirstChild("HumanoidRootPart") then
            if ESP_Objects[player] then
                for _, obj in pairs(ESP_Objects[player]) do if typeof(obj) == "Instance" then obj:Destroy() else obj:Remove() end end
                ESP_Objects[player] = nil
            end
            continue
        end
        local role = getPlayerRole(player)
        local isEnabled = (role == "Sherif" and ESP_Settings.Sherif) or (role == "Murderer" and ESP_Settings.Murderer) or (role == "Innocent" and ESP_Settings.Innocent)
        if isEnabled then
            if not ESP_Objects[player] then
                ESP_Objects[player] = { Box = Drawing.new("Square"), Tracer = Drawing.new("Line"), Name = Drawing.new("Text"), Highlight = Instance.new("Highlight") }
                ESP_Objects[player].Box.Filled = false
                ESP_Objects[player].Highlight.Parent = player.Character
            end
            local color = (role == "Murderer" and Color3.fromRGB(255, 0, 0)) or (role == "Sherif" and Color3.fromRGB(0, 120, 255)) or Color3.fromRGB(0, 255, 0)
            local hrp = player.Character.HumanoidRootPart
            local pos, onScreen = Camera:WorldToViewportPoint(hrp.Position)
            local obj = ESP_Objects[player]
            obj.Highlight.Enabled = ESP_Settings.Highlight
            obj.Highlight.FillColor = color
            obj.Box.Visible = ESP_Settings.EmptyBox and onScreen
            obj.Box.Color = color
            obj.Box.Size = Vector2.new(1000/pos.Z * 1.5, 1000/pos.Z * 2)
            obj.Box.Position = Vector2.new(pos.X - obj.Box.Size.X/2, pos.Y - obj.Box.Size.Y/2)
            obj.Tracer.Visible = ESP_Settings.Tracers and onScreen
            obj.Tracer.Color = color
            obj.Tracer.From = Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y)
            obj.Tracer.To = Vector2.new(pos.X, pos.Y)
            obj.Name.Visible = (ESP_Settings.Names) and onScreen
            obj.Name.Color = color
            obj.Name.Text = player.Name
            obj.Name.Position = Vector2.new(pos.X, pos.Y - 50)
        elseif ESP_Objects[player] then
            for _, o in pairs(ESP_Objects[player]) do if typeof(o) == "Instance" then o:Destroy() else o:Remove() end end
            ESP_Objects[player] = nil
        end
    end
end)
