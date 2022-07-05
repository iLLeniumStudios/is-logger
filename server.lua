local waitingForIP = false
local ipAddress = nil
local host = nil

local function GetServerIPAddress()
    waitingForIP = true
    ipAddress = nil
    PerformHttpRequest("https://ipinfo.io/ip", function(err, response, headers)
        if response[1] == "{" then
            ipAddress = json.decode(response).ip
        else
            ipAddress = response
        end
        waitingForIP = false
    end)
    while waitingForIP do
        Wait(100)
    end
    return ipAddress
end

local function EnsureHost()
    if not host then
        if Logger.ServerName and Logger.ServerName ~= "" then
            host = Logger.ServerName
        else
            host = GetServerIPAddress() .. ":" .. tostring(Logger.ServerPort)
        end
    end
end

local function HandleGrayLog(message, attributes, permission, headers)
    local payload = {
        short_message = message,
        host = host
    }

    permission = permission or Logger.StreamFilterValue

    if Logger.EnableStreamFilter then
        payload["_" .. Logger.StreamFilterKey] = permission
    end

    if attributes then
        for k, v in pairs(attributes) do
            payload["_" .. k] = v
        end
    end

    if Logger.Debug then
        print("[DEBUG] " .. json.encode(payload))
    end
    PerformHttpRequest(Logger.Endpoint, nil, "POST", json.encode(payload), headers)
end

function LogRaw(message, attributes, permission)
    EnsureHost()
    local headers = {}
    headers["Content-Type"] = "application/json"

    if Logger.Target == "GrayLog" then
        HandleGrayLog(message, attributes, permission, headers)
    else
        print("[ERROR] Invalid Target: " .. Logger.Target)
    end
end
