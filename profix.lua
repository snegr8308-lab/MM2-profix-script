local _version = "1.6.6"
local WindUI = loadstring(game:HttpGet("https://github.com/Footagesus/WindUI/releases/download/" .. _version .. "/main.lua"))() 
local Window = WindUI:CreateWindow({
    Title = "Profix",
    Icon = "Star",
    Size = UDim2.fromOffset(500, 400), NewElements = true,
    Theme = "Red",
    
})

local Tab = Window:Tab({Title = "Test", Icon = "settings", ShowTabTitle = true})
local Section = Tab:Section({Title = "Dropdown Test", Box = true, BoxBorder = true, Opened = true})

local MyDropdown = Section:Dropdown({
    Title = "options",
    Values = {"1", "2", "3"},
    Locked = true,
    LockedTitle = "Locked",
    Callback = function(v)
        print("Choosen:", v)
    end
})
