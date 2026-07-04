local _version = "1.6.6"
local WindUI = loadstring(game:HttpGet("https://github.com/Footagesus/WindUI/releases/download/" .. _version .. "/main.lua"))() 

local Window = WindUI:CreateWindow({
    Background = "https://raw.githubusercontent.com/snegr8308-lab/Backgrounds-Themes/main/Orange_video_bg.webm",
    Title = "Profix Hub",
    Icon = "shield",
    Author = "by enormus",
    Folder = "ProfixHub",
    Size = UDim2.fromOffset(580, 464),
    Transparent = true,
    Theme = "Amber",
})

local MainSection = Window:Section({
    Title = "Main",
    Icon = "home",
    Opened = true,
})

-- Добавляем табы внутрь секции
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
    Opened = true,
})

local TrollTab = MiscSection:Tab({ 
    Title = "Troll",
})
