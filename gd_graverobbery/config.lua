Config = {}

Config.Debug = true
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

Config.Graves = { -- add as many graves as you like 
    {coords = vector3(-1774.06, -237.26, 51.78), distance = 2.0, cooldown = 300, icon = "fas fa-skull", label = "Grave Site"},
}

Config.Loot = {
    {item = 'bread',      label = 'Bread',      chance = 30, min = 1, max = 3},
    {item = 'water',      label = 'Water',      chance = 30, min = 1, max = 2},
    {item = 'money',      label = 'Dirty Money',chance = 20, min = 50, max = 150},
    {item = 'gold_ring',  label = 'Gold Ring',  chance = 15, min = 1, max = 1},
    {item = 'diamond',    label = 'Diamond',    chance = 5,  min = 1, max = 1}
}
