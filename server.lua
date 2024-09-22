--MADE WITH LOVE FOR THE QBOX COMMUNITY

local launderingCooldowns = {}


local function sendWebhookNotification(characterName, cryptonetCount, moneyAmount)
    if Config.WebhookEnabled and Config.WebhookURL ~= '' then
        PerformHttpRequest(Config.WebhookURL, function(err, text, headers) end, 'POST', json.encode({
            content = "", 
            username = "Blanchiment d'argent",
            embeds = {{
                title = "Blanchiment d'argent",
                description = string.format("**%s** a blanchi **%d** cryptonet et a reçu **%d** en argent.", characterName, cryptonetCount, moneyAmount),
                color = 16711680 
            }}
        }), { ['Content-Type'] = 'application/json' })
    end
end


exports.qbx_core:CreateUseableItem('cryptonet', function(source, item)
    TriggerClientEvent('launder:exchange', source)
end)

-- Processus de blanchiment
RegisterNetEvent('launder:exchangeMoney')
AddEventHandler('launder:exchangeMoney', function()
    local src = source
    local xPlayer = exports.qbx_core:GetPlayer(src)

    local characterName = xPlayer.PlayerData.name or "Nom inconnu"

    
    if launderingCooldowns[src] and launderingCooldowns[src] > os.time() then
        local remainingTime = launderingCooldowns[src] - os.time()
        TriggerClientEvent('ox_lib:notify', src, {description = string.format("Vous pouvez blanchir à nouveau dans %d secondes.", remainingTime), type = 'error'})
        return
    end

    
    local cryptonetCount = exports.ox_inventory:Search(src, 'count', 'cryptonet')
    if cryptonetCount > 0 then
        local moneyAmount = math.floor(cryptonetCount * Config.ExchangeRate)

       
        local launderingTime = 10 
        if cryptonetCount > Config.ExtraTimeThreshold then
            launderingTime = launderingTime + Config.ExtraTime
        end

        
        TriggerClientEvent('launder:progress', src, launderingTime)

       
        Wait(launderingTime * 1000)

        
        exports.ox_inventory:RemoveItem(src, 'cryptonet', cryptonetCount)
        exports.ox_inventory:AddItem(src, 'money', moneyAmount)

       
        launderingCooldowns[src] = os.time() + Config.LaunderingTimeout

       
        sendWebhookNotification(characterName, cryptonetCount, moneyAmount)

        
        TriggerClientEvent('ox_lib:notify', src, {description = string.format("Vous avez blanchi %d cryptonet et reçu %d en argent.", cryptonetCount, moneyAmount), type = 'success'})
    else
        TriggerClientEvent('ox_lib:notify', src, {description = "Vous n'avez pas de cryptonet !", type = 'error'})
    end
end)


--MADE WITH LOVE FOR THE QBOX COMMUNITY