local waitingForIP = false
local ipAddress = nil
local host = nil
local payloads = {}
local headers = {}

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

local function HandleGrayLog(message, attributes, permission)
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

local function HandleLokiLog(attributes)
    local message = {}
    if attributes then
        for k, v in pairs(attributes) do
            if k ~= 'event' then
                message[k] = v
            end
        end
    end

    local timestamp = tostring(os.time(os.date("*t")) ) .. "000000000"

    local payload = {
        stream = {
            server = "fivem",
            host = host,
            type = attributes['event']
        },
        values = {
            {
                timestamp,
                json.encode(message)
            }
        }
    }

    if Logger.Debug then
        print("[DEBUG] " .. json.encode(payload))
    end

    if not payloads[attributes['event']] then
        payloads[attributes['event']] = payload
    else
        local lastIndex = #payloads[attributes['event']].values

        payloads[attributes['event']].values[lastIndex+1] = {
            timestamp,
            json.encode(message)
        }
    end
end

function LogRaw(message, attributes, permission)
    EnsureHost()
    if Logger.Target == "GrayLog" then
        headers["Content-Type"] = "application/json"
        HandleGrayLog(message, attributes, permission)
    elseif Logger.Target == "Loki" then
        headers["Content-Type"] = "application/json"
        HandleLokiLog(attributes)
    else
        headers = {}
        print("[ERROR] Invalid Target: " .. Logger.Target)
    end
end

if Logger.Target == 'Loki' then
    local function SendData()
        local payload = {}
        if Logger.Target == "Loki" then
            for k,v in pairs(payloads) do
                payload[#payload+1] = v
            end

            payload = { streams = payload }
        end
        if next(payloads) then
            PerformHttpRequest(Logger.Endpoint, function (errorCode, resultData, resultHeaders)
                if errorCode  and errorCode ~= "204" and errorCode ~= "200" then
                    print('[DEBUG]', errorCode, " There was an issue posting." )
                else
                    print('SENT LOKI DATA')
                end
                payloads = {}
            end, "POST", json.encode(payload), headers)
        end
        DataTimer()
    end

    function DataTimer ()
        CreateThread(function()
            Wait(Logger.BulkTimer * 1000)
            SendData()
        end)
    end

    DataTimer()
end