--MADE WITH LOVE FOR THE QBOX COMMUNITY



local launderingBlip = nil
local isLaundering = false
local ped = nil


local function spawnLaunderingPed()
    RequestModel(Config.PedModel)
    while not HasModelLoaded(Config.PedModel) do
        Wait(1)
    end

    ped = CreatePed(4, Config.PedModel, Config.LaunderingLocation.x, Config.LaunderingLocation.y, Config.LaunderingLocation.z - 1.0, Config.PedHeading, false, true)
    SetEntityInvincible(ped, true)
    SetBlockingOfNonTemporaryEvents(ped, true)
    TaskStartScenarioInPlace(ped, 'WORLD_HUMAN_AA_SMOKE', 0, true)
end


local function setupOxTarget()
    exports.ox_target:addLocalEntity(ped, {
        {
            name = 'launder_money',
            label = 'Blanchir du Cryptonet',
            icon = 'fas fa-dollar-sign',
            onSelect = function()
                TriggerEvent('launder:exchange')
            end,
            canInteract = function(entity, distance, data)
                return not isLaundering and distance < 2.5
            end
        }
    })
end


CreateThread(function()
    spawnLaunderingPed()
    setupOxTarget()
end)

RegisterNetEvent('launder:exchange')
AddEventHandler('launder:exchange', function()
    if isLaundering then
        exports.ox_lib:notify({description = "Vous êtes déjà en train de blanchir !", type = 'error'})
        return
    end

    
    if Config.EnableTimeRestriction then
        local currentHour = GetClockHours()
        if currentHour < Config.LaunderingStartTime or currentHour >= Config.LaunderingEndTime then
            exports.ox_lib:notify({description = "Le blanchiment est disponible uniquement entre " .. Config.LaunderingStartTime .. "h et " .. Config.LaunderingEndTime .. "h.", type = 'error'})
            return
        end
    end

    
    TriggerServerEvent('launder:exchangeMoney')
end)


RegisterNetEvent('launder:progress')
AddEventHandler('launder:progress', function(time)
    isLaundering = true
    exports.ox_lib:progressBar({
        duration = time * 1000,
        label = "Blanchiment en cours...",
        useWhileDead = false,
        canCancel = false,
        disable = { car = true }
    }, function(cancel)

        if cancel then
            exports.ox_lib:notify({description = "Blanchiment annulé.", type = 'error'})
        else
            exports.ox_lib:notify({description = "Blanchiment terminé !", type = 'success'})
        end

        isLaundering = false
    end)
end)


--MADE WITH LOVE FOR THE QBOX COMMUNITY