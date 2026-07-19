local _version = "1.6.6"
local WindUI = loadstring(game:HttpGet("https://github.com/Footagesus/WindUI/releases/download/" .. _version .. "/main.lua"))() 
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local Camera = workspace.CurrentCamera
local LocalPlayer = Players.LocalPlayer

-- Функция уведомления при появлении GunDrop
task.spawn(function()
    local gunDetected = false
    while true do
        task.wait(0.1)
        local gunDrop = workspace:FindFirstChild("GunDrop", true)
        
        if gunDrop then
            if not gunDetected then
                WindUI:Notify({ Title = "Profix Hub", Content = "Оружие выпало! Его можно подобрать.", Duration = 5, Icon = "triangle-alert" })
                gunDetected = true
            end
        else
            gunDetected = false
        end
    end
end)

local ESP_Settings = { Sherif = false, Murderer = false, Innocent = false, Tracers = false, EmptyBox = false, Names = false, Studs = false, Highlight = false, GunESP = false }
local FarmSettings = { Enabled = false, Speed = 17 }
local PlayerSettings = { WalkSpeed = 16, JumpPower = 50 }
local PlayerCheats = { SpinSpeed = 10 }
local currentTween, AimButtonGui, KillButtonGui, GunButtonGui = nil, nil, nil, nil
local ESP_Objects = {}

-- Переменные для Player Cheats 
local noclipConnection, jumpConnection, spinLoop
local flyBv, flyBg, flyHeartbeat, flyRenderStepped
local tpwalking = false
local flySpeedMultiplier = 1

-- Переменные для Anti-Fling
local antiFlingConnections = {}
local AntiFlingEnabled = false

local function getActiveMap()
    local mapKeywords = {
        ["Bank"] = "Bank", ["Bio"] = "Biolaboratory", ["Factory"] = "Factory", ["Hospital"] = "Hospital",
        ["Hotel"] = "Hotel", ["House"] = "House", ["Mansion"] = "Mansion", ["Mil"] = "Military Base",
        ["Office"] = "Office", ["Police"] = "Police station", ["Research"] = "Research Center", ["Work"] = "Workplace"
    }
    for _, obj in pairs(workspace:GetChildren()) do
        for key, fullName in pairs(mapKeywords) do
            if string.find(obj.Name, key) then return obj, fullName end
        end
    end
    return nil, nil
end

local function applyPlayerSettings(character)
    local humanoid = character and character:FindFirstChild("Humanoid")
    if humanoid then humanoid.WalkSpeed = PlayerSettings.WalkSpeed; humanoid.JumpPower = PlayerSettings.JumpPower end
end

LocalPlayer.CharacterAdded:Connect(function(character) task.wait(0.5); applyPlayerSettings(character) end)

local function getPlayerRole(player)
    if not player.Character then return "Innocent" end
    if player.Character:FindFirstChild("Knife", true) or (player.Backpack and player.Backpack:FindFirstChild("Knife", true)) then return "Murderer"
    elseif player.Character:FindFirstChild("Gun", true) or (player.Backpack and player.Backpack:FindFirstChild("Gun", true)) then return "Sherif" end
    return "Innocent"
end

-- Функция получения списка игроков (Теперь глобальная для Teleport и Troll)
local function getPlayerNames()
    local list = {}
    for _, p in pairs(Players:GetPlayers()) do 
        if p ~= LocalPlayer then table.insert(list, p.Name) end 
    end
    return list
end

-- === Anti-Fling ===
local function setupCharacterCollision(character)
    local function disableCollide(part)
        if AntiFlingEnabled and part:IsA("BasePart") then part.CanCollide = false end
    end
    for _, part in ipairs(character:GetChildren()) do disableCollide(part) end
    local childAddedConn = character.ChildAdded:Connect(disableCollide)
    local steppedConn = RunService.Stepped:Connect(function()
        if AntiFlingEnabled and character:IsDescendantOf(workspace) then
            for _, part in ipairs(character:GetChildren()) do
                if part:IsA("BasePart") and part.CanCollide then part.CanCollide = false end
            end
        end
    end)
    character.Destroying:Connect(function() childAddedConn:Disconnect(); steppedConn:Disconnect() end)
end

local function trackPlayer(player)
    if player == LocalPlayer then return end
    local charAddedConn = player.CharacterAdded:Connect(setupCharacterCollision)
    if player.Character then setupCharacterCollision(player.Character) end
    antiFlingConnections[player] = charAddedConn
end

local function untrackPlayer(player)
    if antiFlingConnections[player] then antiFlingConnections[player]:Disconnect(); antiFlingConnections[player] = nil end
end

for _, player in ipairs(Players:GetPlayers()) do trackPlayer(player) end
Players.PlayerAdded:Connect(trackPlayer)
Players.PlayerRemoving:Connect(untrackPlayer)

WindUI:AddTheme({ Name = "SubRed", Text = Color3.fromHex("#FFFFFF"), Icon = Color3.fromHex("#ef4444") })

local Window = WindUI:CreateWindow({
    Background = "video:https://github.com/snegr8308-lab/Backgrounds-Themes/raw/main/red_bg.webm",
    BackgroundTransparency = 0.67, Title = "Profix Hub", Icon = "shield", Author = "by Enormus", Folder = "ProfixHub", Size = UDim2.fromOffset(580, 460), Transparent = true, Theme = "SubRed", User = { Enabled = true, Anonymous = false },
})

local HomeTab = Window:Tab({ Title = "Home", Icon = "house" })
local EcpTab = Window:Tab({ Title = "Ecp", Icon = "eye" })
local AutoFarmTab = Window:Tab({ Title = "AutoFarm", Icon = "zap" })
local PlayerTab = Window:Tab({ Title = "Player", Icon = "user" })
local SherifTab = Window:Tab({ Title = "Sherif", Icon = "crosshair" })
local MurderTab = Window:Tab({ Title = "Murderer", Icon = "skull" })
local TeleportTab = Window:Tab({ Title = "Teleport", Icon = "map-pin" })
local TrollTab = Window:Tab({ Title = "Troll", Icon = "swords" })

HomeTab:Paragraph({
    Title = "Hello, " .. LocalPlayer.DisplayName,
    Desc = "Executor: " .. (identifyexecutor and identifyexecutor() or "Unknown") .. "\nAccount Age: " .. LocalPlayer.AccountAge .. " days" .. "\nUserID: " .. LocalPlayer.UserId .. "\nStatus: " .. ((LocalPlayer.Name == "kedeo06" and "Creator") or (LocalPlayer.MembershipType == Enum.MembershipType.Premium and "Premium" or "Normal")),
    Image = "rbxthumb://type=AvatarHeadShot&id=" .. LocalPlayer.UserId .. "&w=420&h=420", ImageSize = 80
})

EcpTab:Toggle({ Title = "ESP Sherif", Callback = function(s) ESP_Settings.Sherif = s end })
EcpTab:Toggle({ Title = "ESP Murderer", Callback = function(s) ESP_Settings.Murderer = s end })
EcpTab:Toggle({ Title = "ESP Innocent", Callback = function(s) ESP_Settings.Innocent = s end })
EcpTab:Toggle({ Title = "ESP Dropped Gun", Callback = function(s) ESP_Settings.GunESP = s end })
EcpTab:Toggle({ Title = "Tracers", Callback = function(s) ESP_Settings.Tracers = s end })
EcpTab:Toggle({ Title = "Box", Callback = function(s) ESP_Settings.EmptyBox = s end })
EcpTab:Toggle({ Title = "Names", Callback = function(s) ESP_Settings.Names = s end })
EcpTab:Toggle({ Title = "Outlines", Callback = function(s) ESP_Settings.Highlight = s end })
AutoFarmTab:Slider({ Title = "Farm Speed", Value = { Min = 17, Max = 100, Default = 17 }, Callback = function(v) FarmSettings.Speed = v end })
AutoFarmTab:Toggle({
    Title = "Start Auto Farm", State = false,
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

PlayerTab:Slider({ Title = "WalkSpeed", Value = { Min = 16, Max = 100, Default = 16 }, Callback = function(v) PlayerSettings.WalkSpeed = v; applyPlayerSettings(LocalPlayer.Character) end })
PlayerTab:Slider({ Title = "JumpPower", Value = { Min = 50, Max = 200, Default = 50 }, Callback = function(v) PlayerSettings.JumpPower = v; applyPlayerSettings(LocalPlayer.Character) end })

PlayerTab:Toggle({ Title = "Anti-Fling", State = false, Callback = function(state) AntiFlingEnabled = state end })

PlayerTab:Toggle({ Title = "Noclip", State = false, Callback = function(state)
    if state then
        noclipConnection = RunService.Stepped:Connect(function()
            local char = LocalPlayer.Character
            if char then
                for _, part in pairs(char:GetDescendants()) do
                    if part:IsA("BasePart") and part.CanCollide then part.CanCollide = false end
                end
            end
        end)
    else
        if noclipConnection then noclipConnection:Disconnect() noclipConnection = nil end
    end
end})

PlayerTab:Toggle({ Title = "MultiJump", State = false, Callback = function(state)
    if state then
        jumpConnection = UserInputService.JumpRequest:Connect(function()
            local char = LocalPlayer.Character
            local hum = char and char:FindFirstChild("Humanoid")
            if hum then hum:ChangeState(Enum.HumanoidStateType.Jumping) end
        end)
    else
        if jumpConnection then jumpConnection:Disconnect() jumpConnection = nil end
    end
end})

PlayerTab:Toggle({ Title = "Fly", State = false, Callback = function(state)
    local char = LocalPlayer.Character
    local hum = char and char:FindFirstChildOfClass("Humanoid")
    local root = char and (char:FindFirstChild("UpperTorso") or char:FindFirstChild("Torso") or char:FindFirstChild("HumanoidRootPart"))
    
    if state then
        if not char or not hum or not root then return end
        local states = { Enum.HumanoidStateType.Climbing, Enum.HumanoidStateType.FallingDown, Enum.HumanoidStateType.Flying, Enum.HumanoidStateType.Freefall, Enum.HumanoidStateType.GettingUp, Enum.HumanoidStateType.Jumping, Enum.HumanoidStateType.Landed, Enum.HumanoidStateType.Physics, Enum.HumanoidStateType.PlatformStanding, Enum.HumanoidStateType.Ragdoll, Enum.HumanoidStateType.Running, Enum.HumanoidStateType.RunningNoPhysics, Enum.HumanoidStateType.Seated, Enum.HumanoidStateType.StrafingNoPhysics, Enum.HumanoidStateType.Swimming }
        for _, s in ipairs(states) do pcall(function() hum:SetStateEnabled(s, false) end) end
        pcall(function() hum:ChangeState(Enum.HumanoidStateType.Swimming) end)
        
        local animate = char:FindFirstChild("Animate")
        if animate then animate.Disabled = true end
        for _, v in pairs(hum:GetPlayingAnimationTracks()) do v:AdjustSpeed(0) end
        hum.PlatformStand = true
        
        flyBg = Instance.new("BodyGyro", root); flyBg.P = 9e4; flyBg.MaxTorque = Vector3.new(9e9, 9e9, 9e9); flyBg.CFrame = root.CFrame
        flyBv = Instance.new("BodyVelocity", root); flyBv.Velocity = Vector3.new(0, 0, 0); flyBv.MaxForce = Vector3.new(9e9, 9e9, 9e9)
        
        tpwalking = true
        flyHeartbeat = RunService.Heartbeat:Connect(function()
            if tpwalking and char and hum and hum.Parent then
                if hum.MoveDirection.Magnitude > 0 then char:TranslateBy(hum.MoveDirection * flySpeedMultiplier) end
                if UserInputService:IsKeyDown(Enum.KeyCode.Space) then char:TranslateBy(Vector3.new(0, 0.5 * flySpeedMultiplier, 0)) end
                if UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) or UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) then char:TranslateBy(Vector3.new(0, -0.5 * flySpeedMultiplier, 0)) end
            end
        end)
        flyRenderStepped = RunService.RenderStepped:Connect(function()
            if flyBg then flyBg.CFrame = Camera.CoordinateFrame end
        end)
    else
        tpwalking = false
        if flyHeartbeat then flyHeartbeat:Disconnect() flyHeartbeat = nil end
        if flyRenderStepped then flyRenderStepped:Disconnect() flyRenderStepped = nil end
        if flyBg then flyBg:Destroy() flyBg = nil end
        if flyBv then flyBv:Destroy() flyBv = nil end
        
        if hum then
            local states = { Enum.HumanoidStateType.Climbing, Enum.HumanoidStateType.FallingDown, Enum.HumanoidStateType.Flying, Enum.HumanoidStateType.Freefall, Enum.HumanoidStateType.GettingUp, Enum.HumanoidStateType.Jumping, Enum.HumanoidStateType.Landed, Enum.HumanoidStateType.Physics, Enum.HumanoidStateType.PlatformStanding, Enum.HumanoidStateType.Ragdoll, Enum.HumanoidStateType.Running, Enum.HumanoidStateType.RunningNoPhysics, Enum.HumanoidStateType.Seated, Enum.HumanoidStateType.StrafingNoPhysics, Enum.HumanoidStateType.Swimming }
            for _, s in ipairs(states) do pcall(function() hum:SetStateEnabled(s, true) end) end
            pcall(function() hum:ChangeState(Enum.HumanoidStateType.RunningNoPhysics) end)
            hum.PlatformStand = false
        end
        if char then
            local animate = char:FindFirstChild("Animate")
            if animate then animate.Disabled = false end
        end
    end
end})
PlayerTab:Slider({ Title = "Fly Speed", Value = { Min = 1, Max = 20, Default = 1 }, Callback = function(v) flySpeedMultiplier = v end})

PlayerTab:Toggle({ Title = "Spin", State = false, Callback = function(state)
    if state then
        spinLoop = RunService.RenderStepped:Connect(function()
            local char = LocalPlayer.Character
            local hrp = char and char:FindFirstChild("HumanoidRootPart")
            if hrp then hrp.CFrame = hrp.CFrame * CFrame.Angles(0, math.rad(PlayerCheats.SpinSpeed), 0) end
        end)
    else
        if spinLoop then spinLoop:Disconnect() spinLoop = nil end
    end
end})

PlayerTab:Slider({ Title = "Spin Speed", Value = { Min = 1, Max = 100, Default = 10 }, Callback = function(v) PlayerCheats.SpinSpeed = v end})

SherifTab:Button({
    Title = "Spawn wallbang murder button",
    Callback = function()
        if AimButtonGui then AimButtonGui:Destroy() AimButtonGui = nil
        else
            AimButtonGui = Instance.new("ScreenGui", game.CoreGui)
            local btn = Instance.new("ImageButton", AimButtonGui)
            btn.Size = UDim2.new(0, 100, 0, 100); btn.Position = UDim2.new(0.5, -120, 0.5, -50); btn.BackgroundColor3 = Color3.fromRGB(45, 45, 45); btn.AutoButtonColor = false; btn.Draggable = true
            Instance.new("UICorner", btn).CornerRadius = UDim.new(0.25, 0); Instance.new("UIStroke", btn).Thickness = 4
            local function cL(s, p) local l = Instance.new("Frame", btn) l.Size = s; l.Position = p; l.BackgroundColor3 = Color3.new(1,1,1); l.BorderSizePixel = 0 end
            cL(UDim2.new(0.06,0,0.35,0), UDim2.new(0.47,0,0.1,0)); cL(UDim2.new(0.06,0,0.35,0), UDim2.new(0.47,0,0.55,0)); cL(UDim2.new(0.35,0,0.06,0), UDim2.new(0.1,0,0.47,0)); cL(UDim2.new(0.35,0,0.06,0), UDim2.new(0.55,0,0.47,0))
            btn.MouseButton1Click:Connect(function()
                local LocalChar = LocalPlayer.Character
                local MyHRP = LocalChar and LocalChar:FindFirstChild("HumanoidRootPart")
                local Gun = LocalChar:FindFirstChild("Gun", true) or LocalPlayer.Backpack:FindFirstChild("Gun", true)
                if not MyHRP or not Gun then return end
                for _, player in pairs(Players:GetPlayers()) do
                    if player ~= LocalPlayer and getPlayerRole(player) == "Murderer" and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
                        local TargetHRP = player.Character.HumanoidRootPart
                        local savedCFrame = MyHRP.CFrame
                        MyHRP.CFrame = CFrame.lookAt(MyHRP.Position, Vector3.new(TargetHRP.Position.X, MyHRP.Position.Y, TargetHRP.Position.Z))
                        if Gun:FindFirstChild("Shoot") then Gun.Shoot:FireServer(TargetHRP.CFrame, MyHRP.CFrame) end
                        task.wait(0.05)
                        MyHRP.CFrame = savedCFrame
                        break
                    end
                end
            end)
        end
    end
})

SherifTab:Button({
    Title = "Spawn Auto-Grab Button",
    Callback = function()
        if GunButtonGui then GunButtonGui:Destroy() GunButtonGui = nil
        else
            GunButtonGui = Instance.new("ScreenGui", game.CoreGui)
            local btn = Instance.new("TextButton", GunButtonGui); btn.Size = UDim2.new(0, 150, 0, 50); btn.Position = UDim2.new(0.5, 0, 0.7, 0); btn.BackgroundColor3 = Color3.fromRGB(45, 45, 45); btn.Text = "Grab Gun"; btn.TextColor3 = Color3.new(1, 1, 1); btn.Draggable = true
            Instance.new("UICorner", btn)
            btn.MouseButton1Click:Connect(function()
                local char = LocalPlayer.Character
                local HRP = char and char:FindFirstChild("HumanoidRootPart")
                if not HRP then return end
                local gunDrop = workspace:FindFirstChild("GunDrop", true)
                if gunDrop and gunDrop:IsA("BasePart") then
                    local savedPosition = HRP.CFrame
                    HRP.CFrame = gunDrop.CFrame
                    task.wait(0.1)
                    if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then LocalPlayer.Character.HumanoidRootPart.CFrame = savedPosition end
                end
            end)
        end
    end
})

MurderTab:Button({
    Title = "Spawn kill all button",
    Callback = function()
        if KillButtonGui then KillButtonGui:Destroy() KillButtonGui = nil
        else
            KillButtonGui = Instance.new("ScreenGui", game.CoreGui)
            local btn = Instance.new("ImageButton", KillButtonGui)
            btn.Size = UDim2.new(0, 100, 0, 100); btn.Position = UDim2.new(0.5, 20, 0.5, -50); btn.BackgroundColor3 = Color3.fromRGB(45, 45, 45); btn.AutoButtonColor = false; btn.Draggable = true
            Instance.new("UICorner", btn).CornerRadius = UDim.new(0.25, 0); Instance.new("UIStroke", btn).Thickness = 4
            local icon = Instance.new("ImageLabel", btn); icon.Size = UDim2.new(0.6, 0, 0.6, 0); icon.Position = UDim2.new(0.2, 0, 0.2, 0); icon.BackgroundTransparency = 1; icon.Image = "rbxassetid://6034878345"; icon.ImageColor3 = Color3.fromRGB(255, 50, 50)
            btn.MouseButton1Click:Connect(function()
                local hasKnife = LocalPlayer.Character:FindFirstChild("Knife", true) or (LocalPlayer.Backpack and LocalPlayer.Backpack:FindFirstChild("Knife", true))
                if not hasKnife then return end
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

local selectedPlayer = nil
local playerDropdown = nil

TeleportTab:Button({ Title = "Refresh Player List", Callback = function() if playerDropdown then playerDropdown:Refresh(getPlayerNames()) end end })

playerDropdown = TeleportTab:Dropdown({ Title = "Select Player", List = getPlayerNames(), Callback = function(val) selectedPlayer = val end })

TeleportTab:Button({ Title = "TP to Selected Player", Callback = function()
    if selectedPlayer and Players:FindFirstChild(selectedPlayer) then
        local target = Players[selectedPlayer].Character
        if target and target:FindFirstChild("HumanoidRootPart") then LocalPlayer.Character.HumanoidRootPart.CFrame = target.HumanoidRootPart.CFrame end
    end
end})

TeleportTab:Button({ Title = "TP to Murderer", Callback = function()
    for _, p in pairs(Players:GetPlayers()) do
        if getPlayerRole(p) == "Murderer" and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then LocalPlayer.Character.HumanoidRootPart.CFrame = p.Character.HumanoidRootPart.CFrame; break end
    end
end})

TeleportTab:Button({ Title = "TP to Sherif", Callback = function()
    for _, p in pairs(Players:GetPlayers()) do
        if getPlayerRole(p) == "Sherif" and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then LocalPlayer.Character.HumanoidRootPart.CFrame = p.Character.HumanoidRootPart.CFrame; break end
    end
end})

TeleportTab:Button({ Title = "TP to Map", Callback = function()
    local map = getActiveMap()
    if map and map:FindFirstChild("Spawns") then
        local spawns = map.Spawns:GetChildren()
        if #spawns > 0 then LocalPlayer.Character.HumanoidRootPart.CFrame = spawns[1].CFrame + Vector3.new(0, 3, 0) end
    end
end})

TeleportTab:Button({ Title = "TP to Lobby", Callback = function()
    local lobby = workspace:FindFirstChild("RegularLobby")
    if lobby and lobby:FindFirstChild("HumanoidRootPart") then LocalPlayer.Character.HumanoidRootPart.CFrame = lobby.HumanoidRootPart.CFrame
    elseif lobby and lobby:FindFirstChildWhichIsA("BasePart") then LocalPlayer.Character.HumanoidRootPart.CFrame = lobby:FindFirstChildWhichIsA("BasePart").CFrame end
end})
-- === TROLL TAB LOGIC ===
local trollSelectedPlayer = nil
local trollPlayerDropdown = nil

local TargetFlingEnabled = false
local FlingAllEnabled = false
local FlingSherifEnabled = false
local FlingMurderEnabled = false

local function IsAnyFlingEnabled()
    return TargetFlingEnabled or FlingAllEnabled or FlingSherifEnabled or FlingMurderEnabled
end

getgenv().OldPos = nil
getgenv().FPDH = workspace.FallenPartsDestroyHeight

-- Оригинальная функция SkidFling, портированная под WindUI
local function SkidFling(TargetPlayer)
    local Character = LocalPlayer.Character
    local Humanoid = Character and Character:FindFirstChildOfClass("Humanoid")
    local RootPart = Humanoid and Humanoid.RootPart
    local TCharacter = TargetPlayer.Character
    if not TCharacter then return end
    
    local THumanoid, TRootPart, THead, Accessory, Handle
    if TCharacter:FindFirstChildOfClass("Humanoid") then THumanoid = TCharacter:FindFirstChildOfClass("Humanoid") end
    if THumanoid and THumanoid.RootPart then TRootPart = THumanoid.RootPart end
    if TCharacter:FindFirstChild("Head") then THead = TCharacter.Head end
    if TCharacter:FindFirstChildOfClass("Accessory") then Accessory = TCharacter:FindFirstChildOfClass("Accessory") end
    if Accessory and Accessory:FindFirstChild("Handle") then Handle = Accessory.Handle end
    
    if Character and Humanoid and RootPart then
        if RootPart.Velocity.Magnitude < 50 then getgenv().OldPos = RootPart.CFrame end
        if THumanoid and THumanoid.Sit then WindUI:Notify({ Title = "Error", Content = TargetPlayer.Name .. " is sitting", Duration = 2 }); return end
        
        if THead then workspace.CurrentCamera.CameraSubject = THead
        elseif Handle then workspace.CurrentCamera.CameraSubject = Handle
        elseif THumanoid and TRootPart then workspace.CurrentCamera.CameraSubject = THumanoid end
        if not TCharacter:FindFirstChildWhichIsA("BasePart") then return end
        
        local FPos = function(BasePart, Pos, Ang)
            RootPart.CFrame = CFrame.new(BasePart.Position) * Pos * Ang
            Character:SetPrimaryPartCFrame(CFrame.new(BasePart.Position) * Pos * Ang)
            RootPart.Velocity = Vector3.new(9e7, 9e7 * 10, 9e7)
            RootPart.RotVelocity = Vector3.new(9e8, 9e8, 9e8)
        end
        
        local SFBasePart = function(BasePart)
            local TimeToWait = 2
            local Time = tick()
            local Angle = 0
            repeat
                if RootPart and THumanoid then
                    if BasePart.Velocity.Magnitude < 50 then
                        Angle = Angle + 100
                        FPos(BasePart, CFrame.new(0, 1.5, 0) + THumanoid.MoveDirection * BasePart.Velocity.Magnitude / 1.25, CFrame.Angles(math.rad(Angle),0 ,0))
                        task.wait()
                        FPos(BasePart, CFrame.new(0, -1.5, 0) + THumanoid.MoveDirection * BasePart.Velocity.Magnitude / 1.25, CFrame.Angles(math.rad(Angle), 0, 0))
                        task.wait()
                        FPos(BasePart, CFrame.new(0, 1.5, 0) + THumanoid.MoveDirection * BasePart.Velocity.Magnitude / 1.25, CFrame.Angles(math.rad(Angle),0 ,0))
                        task.wait()
                        FPos(BasePart, CFrame.new(0, -1.5, 0) + THumanoid.MoveDirection * BasePart.Velocity.Magnitude / 1.25, CFrame.Angles(math.rad(Angle), 0, 0))
                        task.wait()
                        FPos(BasePart, CFrame.new(0, 1.5, 0) + THumanoid.MoveDirection, CFrame.Angles(math.rad(Angle),0 ,0))
                        task.wait()
                        FPos(BasePart, CFrame.new(0, -1.5, 0) + THumanoid.MoveDirection, CFrame.Angles(math.rad(Angle), 0, 0))
                        task.wait()
                    else
                        FPos(BasePart, CFrame.new(0, 1.5, THumanoid.WalkSpeed), CFrame.Angles(math.rad(90), 0, 0))
                        task.wait()
                        FPos(BasePart, CFrame.new(0, -1.5, -THumanoid.WalkSpeed), CFrame.Angles(0, 0, 0))
                        task.wait()
                        FPos(BasePart, CFrame.new(0, 1.5, THumanoid.WalkSpeed), CFrame.Angles(math.rad(90), 0, 0))
                        task.wait()
                        FPos(BasePart, CFrame.new(0, -1.5, 0), CFrame.Angles(math.rad(90), 0, 0))
                        task.wait()
                        FPos(BasePart, CFrame.new(0, -1.5, 0), CFrame.Angles(0, 0, 0))
                        task.wait()
                        FPos(BasePart, CFrame.new(0, -1.5, 0), CFrame.Angles(math.rad(90), 0, 0))
                        task.wait()
                        FPos(BasePart, CFrame.new(0, -1.5, 0), CFrame.Angles(0, 0, 0))
                        task.wait()
                    end
                end
            -- Если любой из переключателей Fling выключат, цикл прервется
            until Time + TimeToWait < tick() or not IsAnyFlingEnabled()
        end
        
        workspace.FallenPartsDestroyHeight = 0/0
        local BV = Instance.new("BodyVelocity")
        BV.Parent = RootPart
        BV.Velocity = Vector3.new(0, 0, 0)
        BV.MaxForce = Vector3.new(9e9, 9e9, 9e9)
        Humanoid:SetStateEnabled(Enum.HumanoidStateType.Seated, false)
        
        if TRootPart then SFBasePart(TRootPart)
        elseif THead then SFBasePart(THead)
        elseif Handle then SFBasePart(Handle)
        else WindUI:Notify({ Title = "Error", Content = TargetPlayer.Name .. " has no valid parts", Duration = 2 }); return end
        
        BV:Destroy()
        Humanoid:SetStateEnabled(Enum.HumanoidStateType.Seated, true)
        workspace.CurrentCamera.CameraSubject = Humanoid
        
        if getgenv().OldPos then
            repeat
                RootPart.CFrame = getgenv().OldPos * CFrame.new(0, .5, 0)
                Character:SetPrimaryPartCFrame(getgenv().OldPos * CFrame.new(0, .5, 0))
                Humanoid:ChangeState("GettingUp")
                for _, part in pairs(Character:GetChildren()) do
                    if part:IsA("BasePart") then part.Velocity, part.RotVelocity = Vector3.new(), Vector3.new() end
                end
                task.wait()
            until (RootPart.Position - getgenv().OldPos.p).Magnitude < 25
            workspace.FallenPartsDestroyHeight = getgenv().FPDH
        end
    else
        WindUI:Notify({ Title = "Error", Content = "Your character is not ready", Duration = 2 })
    end
end

TrollTab:Button({ Title = "Refresh Player List", Callback = function() if trollPlayerDropdown then trollPlayerDropdown:Refresh(getPlayerNames()) end end })

trollPlayerDropdown = TrollTab:Dropdown({ Title = "Select Target", List = getPlayerNames(), Callback = function(val) trollSelectedPlayer = val end })

TrollTab:Toggle({
    Title = "Target Fling (Skid)",
    State = false,
    Callback = function(state)
        TargetFlingEnabled = state
        if state then
            task.spawn(function()
                while TargetFlingEnabled do
                    if trollSelectedPlayer and Players:FindFirstChild(trollSelectedPlayer) then
                        local targetUser = Players[trollSelectedPlayer]
                        if targetUser.Character then
                            SkidFling(targetUser)
                        end
                    else
                        WindUI:Notify({ Title = "Error", Content = "Target not found or not selected!", Duration = 2 })
                        task.wait(2)
                    end
                    task.wait(0.5)
                end
            end)
        end
    end
})

TrollTab:Toggle({
    Title = "Fling All",
    State = false,
    Callback = function(state)
        FlingAllEnabled = state
        if state then
            task.spawn(function()
                while FlingAllEnabled do
                    for _, player in pairs(Players:GetPlayers()) do
                        if player ~= LocalPlayer and FlingAllEnabled then
                            if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
                                SkidFling(player)
                                task.wait(0.1)
                            end
                        end
                    end
                    task.wait(0.5)
                end
            end)
        end
    end
})

TrollTab:Toggle({
    Title = "Fling Sherif",
    State = false,
    Callback = function(state)
        FlingSherifEnabled = state
        if state then
            task.spawn(function()
                while FlingSherifEnabled do
                    for _, player in pairs(Players:GetPlayers()) do
                        if player ~= LocalPlayer and getPlayerRole(player) == "Sherif" and FlingSherifEnabled then
                            if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
                                SkidFling(player)
                                task.wait(0.1)
                            end
                        end
                    end
                    task.wait(0.5)
                end
            end)
        end
    end
})

TrollTab:Toggle({
    Title = "Fling Murderer",
    State = false,
    Callback = function(state)
        FlingMurderEnabled = state
        if state then
            task.spawn(function()
                while FlingMurderEnabled do
                    for _, player in pairs(Players:GetPlayers()) do
                        if player ~= LocalPlayer and getPlayerRole(player) == "Murderer" and FlingMurderEnabled then
                            if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
                                SkidFling(player)
                                task.wait(0.1)
                            end
                        end
                    end
                    task.wait(0.5)
                end
            end)
        end
    end
})

-- === ESP SYSTEM ===
RunService.RenderStepped:Connect(function()
    local gunDrop = workspace:FindFirstChild("GunDrop", true)
    if ESP_Settings.GunESP and gunDrop and gunDrop:IsA("BasePart") then
        local pos, onScreen = Camera:WorldToViewportPoint(gunDrop.Position)
        if not ESP_Objects["GunDrop"] then
            local label = Drawing.new("Text")
            label.Center = true; label.Outline = true; label.Size = 20; label.Color = Color3.fromRGB(255, 255, 0); label.Text = "Dropped Gun"
            ESP_Objects["GunDrop"] = label
        end
        ESP_Objects["GunDrop"].Visible = onScreen
        ESP_Objects["GunDrop"].Position = Vector2.new(pos.X, pos.Y)
    else
        if ESP_Objects["GunDrop"] then ESP_Objects["GunDrop"]:Remove(); ESP_Objects["GunDrop"] = nil end
    end

    for _, player in pairs(Players:GetPlayers()) do
        local char = player.Character
        if player == LocalPlayer or not char or not char:FindFirstChild("HumanoidRootPart") then
            if ESP_Objects[player] then
                for _, obj in pairs(ESP_Objects[player]) do 
                    if typeof(obj) == "Instance" then obj:Destroy() 
                    elseif typeof(obj) == "table" then for _, line in pairs(obj) do line:Remove() end
                    elseif obj.Remove then obj:Remove() end 
                end
                ESP_Objects[player] = nil
            end
            continue
        end

        local role = getPlayerRole(player)
        local isEnabled = (role == "Sherif" and ESP_Settings.Sherif) or (role == "Murderer" and ESP_Settings.Murderer) or (role == "Innocent" and ESP_Settings.Innocent)
        
        if isEnabled then
            if not ESP_Objects[player] then
                ESP_Objects[player] = { Box = Drawing.new("Square"), Tracer = Drawing.new("Line"), Name = Drawing.new("Text"), Highlight = Instance.new("Highlight"), Skeleton = {} }
                for i = 1, 15 do ESP_Objects[player].Skeleton[i] = Drawing.new("Line") end
                ESP_Objects[player].Box.Filled = false; ESP_Objects[player].Box.Thickness = 1.5; ESP_Objects[player].Highlight.Parent = char
            end

            local color = (role == "Murderer" and Color3.fromRGB(255, 0, 0)) or (role == "Sherif" and Color3.fromRGB(0, 120, 255)) or Color3.fromRGB(0, 255, 0)
            local hrp = char.HumanoidRootPart
            local pos, onScreen = Camera:WorldToViewportPoint(hrp.Position)
            local head = char:FindFirstChild("Head")
            
            local topPos = Camera:WorldToViewportPoint((head and head.Position or hrp.Position) + Vector3.new(0, 0.5, 0))
            local bottomPos = Camera:WorldToViewportPoint(hrp.Position - Vector3.new(0, 3, 0))
            local obj = ESP_Objects[player]
            
            obj.Highlight.Enabled = ESP_Settings.Highlight; obj.Highlight.FillColor = color; obj.Highlight.FillTransparency = 0.4
            
            local height = math.abs(topPos.Y - bottomPos.Y)
            obj.Box.Visible = ESP_Settings.EmptyBox and onScreen; obj.Box.Size = Vector2.new(height / 2, height); obj.Box.Position = Vector2.new(pos.X - obj.Box.Size.X / 2, pos.Y - height / 2); obj.Box.Color = color
            obj.Name.Visible = ESP_Settings.Names and onScreen; obj.Name.Text = player.Name; obj.Name.Position = Vector2.new(pos.X, topPos.Y - 25); obj.Name.Color = color
            obj.Tracer.Visible = ESP_Settings.Tracers and onScreen; obj.Tracer.From = Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y); obj.Tracer.To = Vector2.new(bottomPos.X, bottomPos.Y); obj.Tracer.Color = color

            local bones = { {"Head", "UpperTorso"}, {"UpperTorso", "LowerTorso"}, {"UpperTorso", "LeftUpperArm"}, {"LeftUpperArm", "LeftLowerArm"}, {"LeftLowerArm", "LeftHand"}, {"UpperTorso", "RightUpperArm"}, {"RightUpperArm", "RightLowerArm"}, {"RightLowerArm", "RightHand"}, {"LowerTorso", "LeftUpperLeg"}, {"LeftUpperLeg", "LeftLowerLeg"}, {"LeftLowerLeg", "LeftFoot"}, {"LowerTorso", "RightUpperLeg"}, {"RightUpperLeg", "RightLowerLeg"}, {"RightLowerLeg", "RightFoot"} }

            for i, bone in pairs(bones) do
                local part1 = char:FindFirstChild(bone[1], true)
                local part2 = char:FindFirstChild(bone[2], true)
                if part1 and part2 and ESP_Settings.Highlight then
                    local p1, s1 = Camera:WorldToViewportPoint(part1.Position)
                    local p2, s2 = Camera:WorldToViewportPoint(part2.Position)
                    if s1 and s2 then
                        obj.Skeleton[i].From = Vector2.new(p1.X, p1.Y); obj.Skeleton[i].To = Vector2.new(p2.X, p2.Y); obj.Skeleton[i].Color = color; obj.Skeleton[i].Visible = true
                    else obj.Skeleton[i].Visible = false end
                else obj.Skeleton[i].Visible = false end
            end
            
        elseif ESP_Objects[player] then
            for _, obj in pairs(ESP_Objects[player]) do 
                if typeof(obj) == "Instance" then obj:Destroy() 
                elseif typeof(obj) == "table" then for _, line in pairs(obj) do line:Remove() end
                elseif obj.Remove then obj:Remove() end 
            end
            ESP_Objects[player] = nil
        end
    end
end)
