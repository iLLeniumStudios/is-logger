local QBCore = exports["qb-core"]:GetCoreObject()

local function LogWithPlayerInformation(event, message, attributes, permission)
    local src = source
    if not attributes then
        attributes = {}
    end

    if (src == nil or src == "") and (attributes["playerID"] and attributes["playerID"] ~= "") then
        src = attributes["playerID"]
    else
        attributes["playerID"] = src
    end

    if src then

        local player = QBCore.Functions.GetPlayer(src)
        local identifiers = GetPlayerIdentifiersStripped(src, permission)
        local playerName = GetPlayerName(src)

        attributes["playerName"] = playerName
        if player then
            attributes["citizenID"] = player.PlayerData.citizenid
        end

        for k, v in pairs(identifiers) do
            attributes[k] = v
        end
    end

    attributes["event"] = event

    LogRaw(message, attributes, permission)
end

local function OnPlayerConnecting(name, setKickReason, deferrals)
    local src = source
    local playerName = GetPlayerName(src)

    LogWithPlayerInformation("PlayerConnecting", "Player '" .. playerName .. "' is joining the server")
end

local function OnPlayerDropped(reason)
    local src = source
    local playerName = GetPlayerName(src)

    LogWithPlayerInformation("PlayerDropped", "Player '" .. playerName .. "' dropped. Reason: " .. reason)
end

local function LogResourceStartedEvent(resourceName)
    if GetCurrentResourceName() == resourceName then
        LogRaw("Logger is Online", {
            event = "LoggingStarted"
        })
    end
    local attributes = {
        event = "ResourceStarted",
        resourceName = resourceName
    }
    LogRaw("Resource '" .. resourceName .. "' started", attributes)
end

local function LogResourceStoppedEvent(resourceName)
    if GetCurrentResourceName() == resourceName then
        LogRaw("Logger is Offline", {
            event = "LoggingStopped"
        })
    end
    local attributes = {
        event = "ResourceStopped",
        resourceName = resourceName
    }
    LogRaw("Resource '" .. resourceName .. "' stopped", attributes)
end

local function LogChatMessageEvent(message)
    local src = source
    local playerName = GetPlayerName(src)
    local attributes = {
        event = "ChatMessage",
    }
    LogWithPlayerInformation("ChatMessage", playerName .. ": " .. message, attributes)
end

AddEventHandler("onResourceStart", LogResourceStartedEvent)
AddEventHandler("onResourceStop", LogResourceStoppedEvent)

AddEventHandler("playerConnecting", OnPlayerConnecting)
AddEventHandler("playerDropped", OnPlayerDropped)

RegisterNetEvent("is-logger:server:LogWithPlayerInformation", LogWithPlayerInformation)
RegisterNetEvent("is-logger:server:LogChatMessageEvent", LogChatMessageEvent)


RegisterNetEvent('qb-log:server:CreateLog', function(name, title, color, message, tagEveryone)
    LogWithPlayerInformation(name, message, {
        title = title,
    })
end)
