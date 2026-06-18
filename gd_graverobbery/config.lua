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
    [1] = {coords = vector3(100.0, 200.0, 30.0), distance = 2.0, cooldown = 300, icon = 'fas fa-skull', label = 'Old Grave'},
    [2] = {coords = vector3(110.0, 210.0, 30.0), distance = 2.0, cooldown = 300, icon = 'fas fa-skull', label = 'Forgotten Grave'},
    [3] = {coords = vector3(120.0, 220.0, 30.0), distance = 2.0, cooldown = 300, icon = 'fas fa-skull', label = 'Abandoned Grave'},
}

Config.Loot = {
    {item = 'bread',      label = 'Bread',      chance = 30, min = 1, max = 3},
    {item = 'water',      label = 'Water',      chance = 30, min = 1, max = 2},
    {item = 'money',      label = 'Dirty Money',chance = 20, min = 50, max = 150},
    {item = 'gold_ring',  label = 'Gold Ring',  chance = 15, min = 1, max = 1},
    {item = 'diamond',    label = 'Diamond',    chance = 5,  min = 1, max = 1}
}