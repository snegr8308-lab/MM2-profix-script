local _version = "1.6.6"
local WindUI = loadstring(game:HttpGet("https://github.com/Footagesus/WindUI/releases/download/" .. _version .. "/main.lua"))() 
local Window = WindUI:CreateWindow({
    Title = "Przykład",
    Icon = "star",
    Size = UDim2.fromOffset(500, 400), NewElements = true,
    Theme = "Amber",
    
    Accent = Color3.fromHex("#b45309"),
    Background = Color3.fromHex("#3f210d"),
    Outline = Color3.fromHex("#fcd34d"),
    Text = Color3.fromHex("#fff7ed"),
    Placeholder = Color3.fromHex("#fbbf24"),
    Button = Color3.fromHex("#f59e0b"),
    Icon = Color3.fromHex("#f59e0b"),
    Slider = Color3.fromHex("#d97706"),
    Color = Color3.fromHex("#fbbf24"),
    Toggle = Color3.fromHex("d97706"),
})

local Tab = Window:Tab({Title = "Test", Icon = "settings", ShowTabTitle = true})
local Section = Tab:Section({Title = "Dropdown Test", Box = true, BoxBorder = true, Opened = true})

local MyDropdown = Section:Dropdown({
    Title = "Wybierz opcję",
    Values = {"Opcja 1", "Opcja 2", "Opcja 3"},
    Locked = true,
    LockedTitle = "Zablokowane",
    Callback = function(v)
        print("Wybrano:", v)
    end
})
