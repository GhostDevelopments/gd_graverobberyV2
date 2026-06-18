local config = Config
local isDigging = false
local shovelProp <const> = `prop_tool_shovel`

local function debugLog(...)
    if not config.Debug then return end
    lib.print.debug(...)
end

---@param ped number
---@param animDict string
---@param animName string
---@param blendIn number
---@param blendOut number
---@param duration number
---@param flag number
local function playAnim(ped, animDict, animName, blendIn, blendOut, duration, flag)
    lib.requestAnimDict(animDict)
    TaskPlayAnim(ped, animDict, animName, blendIn, blendOut, duration, flag, 0, false, false, false)
end

---@param model number
---@return number prop
local function createProp(model)
    lib.requestModel(model)
    local ped = cache.ped
    local prop = CreateObject(model, 0, 0, 0, true, true, false)
    local boneIndex = GetPedBoneIndex(ped, 28422) -- Right Hand
    -- Offsets for prop_tool_shovel to sit correctly in hand during random@burial
    AttachEntityToEntity(prop, ped, boneIndex, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, true, true, false, true, 1, true)
    return prop
end

---@param prop number
local function removeProp(prop)
    if DoesEntityExist(prop) then
        DeleteEntity(prop)
    end
end

local function startDigging(graveIndex)
    local grave = config.Graves[graveIndex]
    debugLog(("Starting dig at grave %d (%s)"):format(graveIndex, grave.label or "Unnamed"))
    
    local hasItem = exports.ox_inventory:Search("count", config.RequiredItem) > 0

    if not hasItem then
        lib.notify({
            title = "Grave Robbery",
            description = "You need a shovel to dig",
            type = "error"
        })
        return
    end

    isDigging = true
    local ped = cache.ped
    
    -- Face the grave
    local coords = grave.coords
    TaskTurnPedToFaceCoord(ped, coords.x, coords.y, coords.z, 1000)
    Wait(1000)

    -- Create shovel prop
    local shovel = createProp(shovelProp)
    
    local success = lib.progressBar({
        duration = config.DiggingTime,
        label = "Digging grave...",
        useWhileDead = false,
        canCancel = true,
        disable = {
            car = true,
            move = true,
            combat = true,
            mouse = false
        },
        anim = {
            dict = "random@burial",
            clip = "a_burial",
            flag = 1
        }
    })

    removeProp(shovel)
    isDigging = false
    StopAnimTask(ped, "random@burial", "a_burial", 1.0)

    if not success then
        debugLog("Digging cancelled")
        return
    end

    debugLog("Digging complete, triggering server event")
    TriggerServerEvent("grave_robbery:server:digGrave", graveIndex)
end

local function setupTargets()
    for i, grave in ipairs(config.Graves) do
        local options = {
            {
                name = "grave_" .. i,
                icon = grave.icon or "fas fa-skull",
                label = grave.label or "Grave",
                distance = grave.distance or 2.0,
                onSelect = function()
                    startDigging(i)
                end,
                canInteract = function()
                    return not isDigging and not cache.vehicle
                end
            }
        }

        local coords = grave.coords
        exports.ox_target:addBoxZone({
            name = "grave_zone_" .. i,
            coords = vec3(coords.x, coords.y, coords.z + 1.0),
            size = vec3(2.0, 2.0, 2.0),
            rotation = 0,
            debug = false,
            options = options
        })

        if config.UseTargetBlips then
            local blip = AddBlipForCoord(coords.x, coords.y, coords.z)
            SetBlipSprite(blip, 498)
            SetBlipDisplay(blip, 4)
            SetBlipScale(blip, 0.7)
            SetBlipAsShortRange(blip, true)
            BeginTextCommandSetBlipName("STRING")
            AddTextComponentString(grave.label or "Grave")
            EndTextCommandSetBlipName(blip)
        end
    end
end

RegisterNetEvent("grave_robbery:client:syncCooldowns", function(cooldowns)
    for i, cooldown in pairs(cooldowns) do
        if config.Graves[i] then
            config.Graves[i].onCooldown = cooldown
        end
    end
end)

CreateThread(function()
    setupTargets()
end)

AddEventHandler("onResourceStop", function(resourceName)
    if GetCurrentResourceName() ~= resourceName then return end
    if isDigging then
        ClearPedTasks(cache.ped)
    end
end)
