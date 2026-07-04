local _version = "1.6.6"
local WindUI = loadstring(game:HttpGet("https://github.com/Footagesus/WindUI/releases/download/" .. _version .. "/main.lua"))() 

WindUI:AddTheme({
    Name = "SubAmber",
    Text = Color3.fromHex("#FFFFFF"),
    Icon = Color3.fromHex("#f59e0b"),
})

local Window = WindUI:CreateWindow({
    Background = "video:https://raw.githubusercontent.com/snegr8308-lab/Backgrounds-Themes/main/Orange_video_bg.webm",
    BackgroundTransparency = 0.67,
    Title = "Profix Hub",
    Icon = "shield",
    Author = "by enormus",
    Folder = "ProfixHub",
    Size = UDim2.fromOffset(580, 460),
    Transparent = true,
    Theme = "SubAmber",
    User = {
        Enabled = true,
        Anonymous = false,
    },
})

local MainSection = Window:Section({ 
    Title = "Main", 
    Icon = "home", 
    Opened = true 
})
local PlayerTab = MainSection:Tab({ 
    Title = "Player" 
})
local SherifTab = MainSection:Tab({ 
    Title = "Sherif" 
})
local MurderTab = MainSection:Tab({ 
    Title = "Murder" 
})
local EcpTab = MainSection:Tab({ 
    Title = "Ecp" 
})

local MiscSection = Window:Section({ 
    Title = "Misc", 
    Icon = "settings", 
    Opened = false 
})
local TrollTab = MiscSection:Tab({ 
    Title = "Troll" 
})
