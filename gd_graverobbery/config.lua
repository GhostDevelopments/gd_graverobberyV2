Config = {}

Config.Debug = false
Config.RequiredItem = 'shovel'
Config.DiggingTime = 8000
Config.MinLootItems = 1
Config.MaxLootItems = 3

-- Show blips on map for graves
Config.UseTargetBlips = false

Config.AntiCheat = {
    Enabled = true,
    MinTimeBetweenDigs = 5,
    MaxDigsInTimeFrame = 3,
    TimeFrameSeconds = 30
}

Config.Graves = {
    -- Hill Valley Cemetery (Pacific Bluffs)
    {coords = vector3(-1743.15, -594.12, 35.5), distance = 2.0, cooldown = 300, icon = "fas fa-skull", label = "Grave Site"},
    {coords = vector3(-1745.89, -597.22, 35.5), distance = 2.0, cooldown = 300, icon = "fas fa-skull", label = "Grave Site"},
    {coords = vector3(-1749.12, -600.41, 35.5), distance = 2.0, cooldown = 300, icon = "fas fa-skull", label = "Grave Site"},
    {coords = vector3(-1752.1, -603.54, 35.5),  distance = 2.0, cooldown = 300, icon = "fas fa-skull", label = "Grave Site"},
    
    -- Vinewood Cemetery (Alta)
    {coords = vector3(-302.24, -709.68, 34.5),  distance = 2.0, cooldown = 300, icon = "fas fa-skull", label = "Grave Site"},
    {coords = vector3(-306.84, -712.42, 34.5),  distance = 2.0, cooldown = 300, icon = "fas fa-skull", label = "Grave Site"},
    {coords = vector3(-312.15, -714.92, 34.5),  distance = 2.0, cooldown = 300, icon = "fas fa-skull", label = "Grave Site"},
    {coords = vector3(-317.51, -717.38, 34.5),  distance = 2.0, cooldown = 300, icon = "fas fa-skull", label = "Grave Site"},
    
    -- Paleto Bay Cemetery
    {coords = vector3(-450.15, 6331.02, 13.9),  distance = 2.0, cooldown = 300, icon = "fas fa-skull", label = "Grave Site"},
    {coords = vector3(-453.84, 6334.25, 13.9),  distance = 2.0, cooldown = 300, icon = "fas fa-skull", label = "Grave Site"},
    {coords = vector3(-457.12, 6337.84, 13.9),  distance = 2.0, cooldown = 300, icon = "fas fa-skull", label = "Grave Site"},
}

Config.Loot = {
    {item = 'bread',      label = 'Bread',      chance = 30, min = 1, max = 3},
    {item = 'water',      label = 'Water',      chance = 30, min = 1, max = 2},
    {item = 'money',      label = 'Dirty Money',chance = 20, min = 50, max = 150},
    {item = 'gold_ring',  label = 'Gold Ring',  chance = 15, min = 1, max = 1},
    {item = 'diamond',    label = 'Diamond',    chance = 5,  min = 1, max = 1}
}
