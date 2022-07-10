local QBCore = exports['qb-core']:GetCoreObject()

CreateThread(function()
    if Config.UseTarget then
        CreateThread(function()

            for k, _ in pairs(Config.Stashes) do
                exports['qb-target']:AddBoxZone(Config.Stashes[k].stashName, vector3(Config.Stashes[k].coords.x, Config.Stashes[k].coords.y, Config.Stashes[k].coords.z), 1, 1, {
                    name = Config.Stashes[k].stashName,
                    heading = 0,
                    debugPoly = false,
                    minZ = Config.Stashes[k].coords.z - 1,
                    maxZ = Config.Stashes[k].coords.z + 1,
                }, {
                    options = {
                        {
                            type = "client",
                            icon = "fas fa-box",
                            label = "Open Stash",
                            action = function(entity)
                                if IsPedAPlayer(entity) then return false end
                                TriggerEvent('qb-business:client:openStash', k, Config.Stashes[k].stashName)
                            end,
                        },
                    },
                    distance = 2.0
                })
            end

        end)
    else
        local alreadyEnteredZone = false
        local text = '<b>[E] Open Stash</b>'
        while true do
        wait = 5
        local ped = PlayerPedId()
        local inZone = false

        for k in pairs(Config.Stashes) do

            local dist = #(GetEntityCoords(ped)-vector3(Config.Stashes[k].coords.x, Config.Stashes[k].coords.y, Config.Stashes[k].coords.z))
            if dist <= 2.0 then
            wait = 5
            inZone  = true

            if IsControlJustReleased(0, 38) then
                TriggerEvent('qb-business:client:openStash', k, Config.Stashes[k].stashName)
            end
            break
            else
            wait = 2000
            end
        end

        if inZone and not alreadyEnteredZone then
            alreadyEnteredZone = true
            exports['qb-core']:DrawText(text ,'left')
        end

        if not inZone and alreadyEnteredZone then
            alreadyEnteredZone = false
            exports['qb-core']:HideText()
        end
        Citizen.Wait(wait)
        end
    end
end)

RegisterNetEvent('qb-business:client:openStash', function(currentstash, _)

    local PlayerData = QBCore.Functions.GetPlayerData()
    local PlayerJob = PlayerData.job.name
    local PlayerGang = PlayerData.gang.name
    local canOpen = false

    if Config.PoliceOpen then
        if PlayerJob == "police" then
            canOpen = true
        end
    end

    if Config.Stashes[currentstash].jobrequired then 
        if PlayerJob == Config.Stashes[currentstash].job then
            canOpen = true
        end
    end

    if Config.Stashes[currentstash].requirecid then
        for _, v in pairs (Config.Stashes[currentstash].cid) do
            if QBCore.Functions.GetPlayerData().citizenid == v then
                canOpen = true
            end
        end
    end

    if Config.Stashes[currentstash].gangrequired then
        if PlayerGang == Config.Stashes[currentstash].gang then
            canOpen = true
        end
    end

    if Config.Stashes[currentstash].canAnyoneOpen then
        TriggerServerEvent("inventory:server:OpenInventory", "stash", Config.Stashes[currentstash].stashName, {maxweight = Config.Stashes[currentstash].stashSize, slots = Config.Stashes[currentstash].stashSlots})
        TriggerEvent("inventory:client:SetCurrentStash", Config.Stashes[currentstash].stashName)
        TriggerServerEvent("InteractSound_SV:PlayOnSource", "StashOpen", 0.5)
    elseif canOpen then
        TriggerServerEvent("inventory:server:OpenInventory", "stash", Config.Stashes[currentstash].stashName, {maxweight = Config.Stashes[currentstash].stashSize, slots = Config.Stashes[currentstash].stashSlots})
        TriggerEvent("inventory:client:SetCurrentStash", Config.Stashes[currentstash].stashName)
        TriggerServerEvent("InteractSound_SV:PlayOnSource", "StashOpen", 0.5)
    else
        QBCore.Functions.Notify('You cannot open this', 'error')
    end

end)
