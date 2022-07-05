function GetPlayerIdentifiersStripped(src, permission)
    local identifiers = {}

    for i = 0, GetNumPlayerIdentifiers(src) - 1 do
        local id = GetPlayerIdentifier(src, i)

        if string.find(id, "steam:") then
            identifiers["steam"] = id:gsub("steam:", "")
        elseif string.find(id, "ip:") and permission == "Admin" then
            identifiers["ip"] = id:gsub("ip:", "")
        elseif string.find(id, "discord:") then
            identifiers["discord"] = id:gsub("discord:", "")
        elseif string.find(id, "license:") then
            identifiers["license"] = id:gsub("license:", "")
        elseif string.find(id, "license2:") then
            identifiers["license2"] = id:gsub("license2:", "")
        elseif string.find(id, "xbl:") then
            identifiers["xbl"] = id:gsub("xbl:", "")
        elseif string.find(id, "live:") then
            identifiers["live"] = id:gsub("live:", "")
        elseif string.find(id, "fivem:") then
            identifiers["fivem"] = id:gsub("fivem:", "")
        end
    end

    return identifiers
end
