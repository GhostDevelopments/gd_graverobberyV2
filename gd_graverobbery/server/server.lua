local config = Config
local graveCooldowns <const> = {}

local function debugLog(...)
    if not config.Debug then return end
    lib.print.debug(...)
end

local function getGraveKey(index)
    return "grave_" .. index
end

lib.callback.register("grave_robbery:server:getCooldowns", function()
    return graveCooldowns
end)

local function applyAntiCheat(src)
    if not config.AntiCheat.Enabled then return true end

    debugLog(("Applying anti-cheat for player %d"):format(src))
    local player = exports.qbx_core:GetPlayer(src)
    if not player then return false end

    local id = player.PlayerData.license

    if not graveCooldowns[id] then
        graveCooldowns[id] = {
            lastDig = 0,
            digCount = 0,
            timeFrameStart = os.time()
        }
    end

    local playerData = graveCooldowns[id]
    local now = os.time()

    -- Reset time frame counter
    if now - playerData.timeFrameStart >= config.AntiCheat.TimeFrameSeconds then
        playerData.digCount = 0
        playerData.timeFrameStart = now
    end

    -- Check minimum time between digs
    local timeSinceLastDig = now - playerData.lastDig
    if timeSinceLastDig < config.AntiCheat.MinTimeBetweenDigs then
        debugLog(("Anti-cheat: Player %d digging too fast. Last dig: %ds ago"):format(src, timeSinceLastDig))
        TriggerClientEvent("ox_lib:notify", src, {
            title = "Grave Robbery",
            description = "You're digging too fast!",
            type = "error"
        })
        return false
    end

    -- Check max digs in time frame
    if playerData.digCount >= config.AntiCheat.MaxDigsInTimeFrame then
        debugLog(("Anti-cheat: Player %d exceeded max digs (%d/%d)"):format(src, playerData.digCount, config.AntiCheat.MaxDigsInTimeFrame))
        TriggerClientEvent("ox_lib:notify", src, {
            title = "Grave Robbery",
            description = "You're digging too much!",
            type = "error"
        })

        if WebhookConfig.AntiCheatWebhook and WebhookConfig.AntiCheatWebhook ~= "" then
            local playerName = player.PlayerData.charinfo.firstname .. " " .. player.PlayerData.charinfo.lastname
            local message = string.format("**Anti-Cheat Triggered**\nPlayer: %s (%s)\nReason: Too many digs in time frame", playerName, id)
            PerformHttpRequest(WebhookConfig.AntiCheatWebhook, function() end, "POST", json.encode({
                username = WebhookConfig.BotName,
                avatar_url = WebhookConfig.BotAvatar,
                content = message,
                color = WebhookConfig.Colors.kick
            }), { ["Content-Type"] = "application/json" })
        end

        DropPlayer(src, "Anti-cheat triggered: Grave robbery")
        return false
    end

    playerData.lastDig = now
    playerData.digCount = playerData.digCount + 1

    return true
end

local function getGraveCooldown(index)
    local key = getGraveKey(index)
    if not graveCooldowns[key] then return false end
    return os.time() < graveCooldowns[key]
end

local function setGraveCooldown(index)
    local key = getGraveKey(index)
    local cooldownTime = config.Graves[index].cooldown or 300
    graveCooldowns[key] = os.time() + cooldownTime
end

local function generateLoot()
    local items = {}

    local numItems = math.random(config.MinLootItems, config.MaxLootItems)
    debugLog(("Generating loot: rolling for %d items"):format(numItems))

    for _ = 1, numItems do
        local roll = math.random(1, 100)
        local totalChance = 0

        for _, lootItem in ipairs(config.Loot) do
            totalChance = totalChance + lootItem.chance
            if roll <= totalChance then
                local amount = math.random(lootItem.min, lootItem.max)
                debugLog(("Loot roll: %d (TotalChance: %d) - Found %dx %s"):format(roll, totalChance, amount, lootItem.item))

                if lootItem.item == "money" then
                    items["cash"] = (items["cash"] or 0) + amount
                else
                    items[lootItem.item] = (items[lootItem.item] or 0) + amount
                end
                break
            end
        end
    end

    return items
end

local function giveLoot(src, loot)
    local player = exports.qbx_core:GetPlayer(src)
    if not player then return end

    local playerName = player.PlayerData.charinfo.firstname .. " " .. player.PlayerData.charinfo.lastname
    local lootList = {}

    for item, amount in pairs(loot) do
        if item == "cash" then
            exports.qbx_core:AddMoney(src, "cash", amount, "grave_robbery")
            lootList[#lootList + 1] = string.format("$%d cash", amount)
        else
            exports.ox_inventory:AddItem(src, item, amount)
            local itemLabel = item
            for _, lootConfig in ipairs(config.Loot) do
                if lootConfig.item == item then
                    itemLabel = lootConfig.label
                    break
                end
            end
            lootList[#lootList + 1] = string.format("%dx %s", amount, itemLabel)
        end
    end

    if #lootList > 0 then
        local lootString = table.concat(lootList, ", ")
        lib.notify(src, {
            title = "Grave Robbery",
            description = "You found: " .. lootString,
            type = "success"
        })

        if WebhookConfig.LootWebhook and WebhookConfig.LootWebhook ~= "" then
            local id = player.PlayerData.license
            local message = string.format("**Grave Robbed**\nPlayer: %s (%s)\nLoot: %s", playerName, id, lootString)
            PerformHttpRequest(WebhookConfig.LootWebhook, function() end, "POST", json.encode({
                username = WebhookConfig.BotName,
                avatar_url = WebhookConfig.BotAvatar,
                content = message,
                color = WebhookConfig.Colors.loot
            }), { ["Content-Type"] = "application/json" })
        end
    else
        lib.notify(src, {
            title = "Grave Robbery",
            description = "You found nothing...",
            type = "inform"
        })
    end
end

RegisterNetEvent("grave_robbery:server:digGrave", function(graveIndex)
    local src = source
    debugLog(("Player %d attempting to dig grave %d"):format(src, graveIndex))

    local player = exports.qbx_core:GetPlayer(src)
    if not player then return end

    if not config.Graves[graveIndex] then return end

    if getGraveCooldown(graveIndex) then
        lib.notify(src, {
            title = "Grave Robbery",
            description = "This grave has already been robbed recently",
            type = "error"
        })
        return
    end

    if not applyAntiCheat(src) then return end

    local hasItem = exports.ox_inventory:GetItemCount(src, config.RequiredItem) > 0
    if not hasItem then
        lib.notify(src, {
            title = "Grave Robbery",
            description = "You need a shovel to dig",
            type = "error"
        })
        return
    end

    local loot = generateLoot()
    giveLoot(src, loot)
    setGraveCooldown(graveIndex)
end)

lib.addCommand("graverobbery", {
    help = "Reset grave robbery cooldowns (Police rank 2+)",
    params = {},
    restricted = "group.police"
}, function(src)
    local player = exports.qbx_core:GetPlayer(src)
    if not player then return end

    -- Grade is a number in Qbox
    if player.PlayerData.job.grade.level >= 2 then
        for k in pairs(graveCooldowns) do
            if type(k) == "string" and k:find("grave_") then
                graveCooldowns[k] = nil
            end
        end

        lib.notify(src, {
            title = "Grave Robbery",
            description = "All grave cooldowns have been reset",
            type = "success"
        })
    else
        lib.notify(src, {
            title = "Grave Robbery",
            description = "You need to be at least grade 2 (Police) to use this",
            type = "error"
        })
    end
end)

-- Admin Commands (ACE restricted: command.admin)

lib.addCommand("gr_inspect", {
    help = "Inspect active cooldowns and player anti-cheat data (Console output)",
    restricted = "command.admin"
}, function(src)
    local activeCooldowns = 0
    local now = os.time()

    print("^3--- Grave Robbery State ---^7")
    for k, v in pairs(graveCooldowns) do
        if type(k) == "string" and k:find("grave_") then
            if v > now then
                activeCooldowns = activeCooldowns + 1
                print(string.format("Grave: %s | Cooldown Remaining: %ds", k, v - now))
            end
        else
            -- Anti-cheat data (k is license)
            print(string.format("Player %s: Digs: %d | Timeframe: %ds ago", k, v.digCount, now - v.timeFrameStart))
        end
    end
    print(string.format("^3Total active grave cooldowns: %d^7", activeCooldowns))

    lib.notify(src, {
        title = "Admin: Inspect",
        description = "State printed to server console",
        type = "inform"
    })
end)

lib.addCommand("gr_reset", {
    help = "Reset all or specific grave cooldowns",
    params = {
        { name = "index", help = "Grave index or 'all'", type = "string", optional = true }
    },
    restricted = "command.admin"
}, function(src, args)
    local target = args.index
    if not target or target == "all" then
        for k in pairs(graveCooldowns) do
            if type(k) == "string" and k:find("grave_") then
                graveCooldowns[k] = nil
            end
        end
        lib.notify(src, { title = "Admin: Reset", description = "All grave cooldowns cleared", type = "success" })
    else
        local index = tonumber(target)
        if index and config.Graves[index] then
            local key = getGraveKey(index)
            graveCooldowns[key] = nil
            lib.notify(src, { title = "Admin: Reset", description = "Grave " .. index .. " reset", type = "success" })
        else
            lib.notify(src, { title = "Admin: Reset", description = "Invalid grave index", type = "error" })
        end
    end
end)

lib.addCommand("gr_force", {
    help = "Force a dig event for a player (ignores cooldown/items)",
    params = {
        { name = "target", help = "Player Server ID", type = "number" },
        { name = "index", help = "Grave index", type = "number" }
    },
    restricted = "command.admin"
}, function(src, args)
    local targetId = args.target
    local graveIndex = args.index

    if not exports.qbx_core:GetPlayer(targetId) then
        lib.notify(src, { title = "Admin: Force", description = "Invalid player ID", type = "error" })
        return
    end

    if not config.Graves[graveIndex] then
        lib.notify(src, { title = "Admin: Force", description = "Invalid grave index", type = "error" })
        return
    end

    local loot = generateLoot()
    giveLoot(targetId, loot)
    setGraveCooldown(graveIndex)

    lib.notify(src, {
        title = "Admin: Force",
        description = string.format("Forced dig at grave %d for player %d", graveIndex, targetId),
        type = "success"
    })
end)

lib.addCommand("gr_reward", {
    help = "Manually grant random grave loot to a player",
    params = {
        { name = "target", help = "Player Server ID", type = "number" }
    },
    restricted = "command.admin"
}, function(src, args)
    local targetId = args.target
    if not exports.qbx_core:GetPlayer(targetId) then
        lib.notify(src, { title = "Admin: Reward", description = "Invalid player ID", type = "error" })
        return
    end

    local loot = generateLoot()
    giveLoot(targetId, loot)

    lib.notify(src, {
        title = "Admin: Reward",
        description = "Granted random grave loot to player " .. targetId,
        type = "success"
    })
end)

lib.addCommand("grave_robbery_help", {
    help = "Show admin help for grave robbery",
    restricted = "command.admin"
}, function(src)
    local helpText = [[
        Grave Robbery Admin Commands:
        /gr_inspect - View cooldowns/AC data (Console)
        /gr_reset [index/all] - Clear cooldowns
        /gr_force [id] [grave] - Force dig event
        /gr_reward [id] - Give random loot
    ]]
    print(helpText)
    lib.notify(src, {
        title = "Admin Help",
        description = "Admin commands listed in console",
        type = "inform"
    })
end)
