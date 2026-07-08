local _version = "1.6.6"
local WindUI = loadstring(game:HttpGet("https://github.com/Footagesus/WindUI/releases/download/" .. _version .. "/main.lua"))() 
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local Camera = workspace.CurrentCamera
local LocalPlayer = Players.LocalPlayer

local ESP_Settings = {
    Sherif = false, 
    Murderer = false, 
    Innocent = false,
    Tracers = false, 
    EmptyBox = false, 
    Names = false, 
    Studs = false, 
    Highlight = false
}

local function getPlayerRole(player)
    if not player.Character then return "Innocent" end
    if player.Character:FindFirstChild("Knife", true) or (player.Backpack and player.Backpack:FindFirstChild("Knife", true)) then
        return "Murderer"
    elseif player.Character:FindFirstChild("Gun", true) or (player.Backpack and player.Backpack:FindFirstChild("Gun", true)) then
        return "Sherif"
    end
    return "Innocent"
end

WindUI:AddTheme({ 
    Name = "SubRed", 
    Text = Color3.fromHex("#FFFFFF"), 
    Icon = Color3.fromHex("#ef4444") 
})

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
    User = { 
        Enabled = true, 
        Anonymous = false,
    },
})

local MainSection = Window:Section({ Title = "Main", Icon = "home", Opened = true })
local EcpTab = MainSection:Tab({ Title = "Ecp" })
local AutoFarmTab = MainSection:Tab({ Title = "AutoFarm" })

EcpTab:Toggle({ Title = "ESP Sherif", Callback = function(s) ESP_Settings.Sherif = s end })
EcpTab:Toggle({ Title = "ESP Murderer", Callback = function(s) ESP_Settings.Murderer = s end })
EcpTab:Toggle({ Title = "ESP Innocent", Callback = function(s) ESP_Settings.Innocent = s end })
EcpTab:Toggle({ Title = "Tracers", Callback = function(s) ESP_Settings.Tracers = s end })
EcpTab:Toggle({ Title = "Box", Callback = function(s) ESP_Settings.EmptyBox = s end })
EcpTab:Toggle({ Title = "Names", Callback = function(s) ESP_Settings.Names = s end })
EcpTab:Toggle({ Title = "Studs", Callback = function(s) ESP_Settings.Studs = s end })
EcpTab:Toggle({ Title = "Highlights", Callback = function(s) ESP_Settings.Highlight = s end })

local ESP_Objects = {}

RunService.RenderStepped:Connect(function()
    for _, player in pairs(Players:GetPlayers()) do
        if player == LocalPlayer or not player.Character or not player.Character:FindFirstChild("HumanoidRootPart") then
            if ESP_Objects[player] then
                for _, obj in pairs(ESP_Objects[player]) do 
                    if typeof(obj) == "Instance" then obj:Destroy() else obj:Remove() end 
                end
                ESP_Objects[player] = nil
            end
            continue
        end

        local role = getPlayerRole(player)
        local isEnabled = (role == "Sherif" and ESP_Settings.Sherif) or (role == "Murderer" and ESP_Settings.Murderer) or (role == "Innocent" and ESP_Settings.Innocent)

        if isEnabled then
            if not ESP_Objects[player] then
                ESP_Objects[player] = { 
                    Box = Drawing.new("Square"), 
                    Tracer = Drawing.new("Line"), 
                    Name = Drawing.new("Text"),
                    Highlight = Instance.new("Highlight")
                }
                ESP_Objects[player].Box.Filled = false
                ESP_Objects[player].Box.Thickness = 1.5
                ESP_Objects[player].Name.Size = 18
                ESP_Objects[player].Name.Center = true
                ESP_Objects[player].Highlight.Parent = player.Character
            end

            local color = (role == "Murderer" and Color3.fromRGB(255, 0, 0)) or (role == "Sherif" and Color3.fromRGB(0, 120, 255)) or Color3.fromRGB(0, 255, 0)
            local hrp = player.Character.HumanoidRootPart
            local pos, onScreen = Camera:WorldToViewportPoint(hrp.Position)
            local dist = (Camera.CFrame.Position - hrp.Position).Magnitude
            local size = 1000 / pos.Z
            local obj = ESP_Objects[player]

            obj.Highlight.Enabled = ESP_Settings.Highlight
            obj.Highlight.FillColor = color
            obj.Highlight.OutlineColor = color

            obj.Box.Visible = ESP_Settings.EmptyBox and onScreen
            obj.Box.Color = color
            obj.Box.Size = Vector2.new(size * 1.5, size * 2)
            obj.Box.Position = Vector2.new(pos.X - obj.Box.Size.X / 2, pos.Y - obj.Box.Size.Y / 2)
            
            obj.Tracer.Visible = ESP_Settings.Tracers and onScreen
            obj.Tracer.Color = color
            obj.Tracer.From = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y)
            obj.Tracer.To = Vector2.new(pos.X, pos.Y)
            
            obj.Name.Visible = (ESP_Settings.Names or ESP_Settings.Studs) and onScreen
            obj.Name.Color = color
            obj.Name.Text = (ESP_Settings.Names and player.Name or "") .. (ESP_Settings.Studs and (" [" .. math.floor(dist) .. "]") or "")
            obj.Name.Position = Vector2.new(pos.X, pos.Y - size)
            
        elseif ESP_Objects[player] then
            for _, o in pairs(ESP_Objects[player]) do 
                if typeof(o) == "Instance" then o:Destroy() else o:Remove() end 
            end
            ESP_Objects[player] = nil
        end
    end
end)

local FarmEnabled = false
AutoFarmTab:Toggle({
    Title = "start auto farm",
    State = false,
    Callback = function(state)
        FarmEnabled = state
        
        
        if not FarmEnabled then
            local char = LocalPlayer.Character
            if char and char:FindFirstChild("Humanoid") then
                char.Humanoid.Health = 0
            end
            return
        end

        
        if FarmEnabled then
            task.spawn(function()
                while FarmEnabled do
                    local character = LocalPlayer.Character
                    local RootPart = character and character:FindFirstChild("HumanoidRootPart")
                    
                    if RootPart then
                        
                        local murderer = nil
                        for _, p in pairs(Players:GetPlayers()) do
                            if getPlayerRole(p) == "Murderer" and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
                                murderer = p.Character.HumanoidRootPart
                                break
                            end
                        end

                        if murderer then
                            local distToMurderer = (RootPart.Position - murderer.Position).Magnitude
                            if distToMurderer > 1000 then
                                task.wait(1)
                                continue 
                            end
                        end

                        local closestCoin, shortestDistance = nil, math.huge
                        for _, obj in pairs(workspace:GetDescendants()) do
                            if obj.Name == "Coin_Server" and obj:IsA("BasePart") and obj:FindFirstChild("TouchInterest") then
                                local dist = (RootPart.Position - obj.Position).Magnitude
                                if dist < shortestDistance then
                                    shortestDistance, closestCoin = dist, obj
                                end
                            end
                        end
                        
                        if closestCoin then
                            local tween = TweenService:Create(RootPart, TweenInfo.new(shortestDistance / 17, Enum.EasingStyle.Linear), {CFrame = closestCoin.CFrame})
                            tween:Play()
                            
                            while closestCoin and closestCoin:FindFirstChild("TouchInterest") and FarmEnabled do
                                task.wait(0.1)
                            end
                            task.wait(0.1)
                        else
                            task.wait(0.1)
                        end
                    end
                    task.wait(0.1)
                end
            end)
        end
    end
})
