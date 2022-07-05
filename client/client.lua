if Config.EnableKillLogs then
    CreateThread(function()
        local DeathReason, Killer, DeathCauseHash, Weapon
        while true do
            Wait(250)
            if IsEntityDead(PlayerPedId()) then
                local PedKiller = GetPedSourceOfDeath(PlayerPedId())
                local killername = GetPlayerName(PedKiller)
                DeathCauseHash = GetPedCauseOfDeath(PlayerPedId())
                Weapon = ClientWeapons.WeaponNames[tostring(DeathCauseHash)]
                if IsEntityAPed(PedKiller) and IsPedAPlayer(PedKiller) then
                    Killer = NetworkGetPlayerIndexFromPed(PedKiller)
                elseif IsEntityAVehicle(PedKiller) and IsEntityAPed(GetPedInVehicleSeat(PedKiller, -1)) and IsPedAPlayer(GetPedInVehicleSeat(PedKiller, -1)) then
                    Killer = NetworkGetPlayerIndexFromPed(GetPedInVehicleSeat(PedKiller, -1))
                end
                if (Killer == PlayerId()) then
                    DeathReason = DeathReasons.Suicide
                elseif (Killer == nil) then
                    DeathReason = DeathReasons.Died
                else
                    if ClientFunc.IsMelee(DeathCauseHash) then
                        DeathReason = DeathReasons.Murdered
                    elseif ClientFunc.IsTorch(DeathCauseHash) then
                        DeathReason = DeathReasons.Torched
                    elseif ClientFunc.IsKnife(DeathCauseHash) then
                        DeathReason = DeathReasons.Knifed
                    elseif ClientFunc.IsPistol(DeathCauseHash) then
                        DeathReason = DeathReasons.Pistoled
                    elseif ClientFunc.IsSub(DeathCauseHash) then
                        DeathReason = DeathReasons.Riddled
                    elseif ClientFunc.IsRifle(DeathCauseHash) then
                        DeathReason = DeathReasons.Rifled
                    elseif ClientFunc.IsLight(DeathCauseHash) then
                        DeathReason = DeathReasons.MachineGunned
                    elseif ClientFunc.IsShotgun(DeathCauseHash) then
                        DeathReason = DeathReasons.Pulverized
                    elseif ClientFunc.IsSniper(DeathCauseHash) then
                        DeathReason = DeathReasons.Sniped
                    elseif ClientFunc.IsHeavy(DeathCauseHash) then
                        DeathReason = DeathReasons.Obliterated
                    elseif ClientFunc.IsMinigun(DeathCauseHash) then
                        DeathReason = DeathReasons.Shredded
                    elseif ClientFunc.IsBomb(DeathCauseHash) then
                        DeathReason = DeathReasons.Bombed
                    elseif ClientFunc.IsVeh(DeathCauseHash) then
                        DeathReason = DeathReasons.MowedOver
                    elseif ClientFunc.IsVK(DeathCauseHash) then
                        DeathReason = DeathReasons.Flattened
                    else
                        DeathReason = DeathReasons.Killed
                    end
                end
                local coords = json.encode(GetEntityCoords(PlayerPedId()))
                if DeathReason == DeathReasons.Suicide or DeathReason == DeathReasons.Died then
                    TriggerServerEvent("is-logger:server:LogWithPlayerInformation", "PlayerDied", GetPlayerName(PlayerId()) .. " " .. DeathReason .. " with " .. (Weapon or "") .. " at Coords: " .. coords, {
                        weapon = Weapon or "",
                        deathReason = DeathReason,
                        coords = coords,
                    }, "Admin")
                else
                    TriggerServerEvent("is-logger:server:LogWithPlayerInformation", "PlayerDied", GetPlayerName(Killer) .. " " .. DeathReason .. GetPlayerName(PlayerId()) .. " with " .. (Weapon or "") .. " at Coords: " .. coords, {
                        weapon = Weapon or "",
                        killerId = Killer,
                        killerName = GetPlayerName(Killer),
                        deathReason = DeathReason,
                        coords = coords,
                    }, "Admin")
                end
                Killer = nil
                DeathReason = nil
                DeathCauseHash = nil
                Weapon = nil
            end
            while IsEntityDead(PlayerPedId()) do
                Wait(1000)
            end
        end
    end)
end

if Config.EnableShootingLogs then
    CreateThread(function()
        local currWeapon = 0
        local fireWeapon = nil
        local timeout = 0
        local fireCount = 0
        while true do
            Wait(0)
            local playerped = GetPlayerPed(PlayerId())
            local coords = json.encode(GetEntityCoords(PlayerPedId()))
            if IsPedShooting(playerped) then
                fireWeapon = GetSelectedPedWeapon(playerped)
                fireCount = fireCount + 1
                timeout = 1000
            elseif not IsPedShooting(playerped) and fireCount ~= 0 and timeout ~= 0 then
                if timeout ~= 0 then
                    timeout = timeout - 1
                end
                if fireWeapon ~= GetSelectedPedWeapon(playerped) then
                    timeout = 0
                end
                if fireCount ~= 0 and timeout == 0 then
                    if not ClientWeapons.WeaponNames[tostring(fireWeapon)] then
                        TriggerServerEvent("is-logger:server:LogWithPlayerInformation", "PlayerShooting", GetPlayerName(PlayerId()) .. " fired Undefined at Coords: " .. coords, {
                            weapon = "Undefined",
                            coords = coords,
                        }, "Admin")
                        return
                    end

                    isLoggedWeapon = true
                    for k,v in pairs(ClientWeapons.NotLogged) do
                        if GetSelectedPedWeapon(playerped) == GetHashKey(v) then
                            isLoggedWeapon = false
                        end
                    end
                    if isLoggedWeapon then
                        local weaponName = ClientWeapons.WeaponNames[tostring(fireWeapon)]
                        TriggerServerEvent("is-logger:server:LogWithPlayerInformation", "PlayerShooting", GetPlayerName(PlayerId()) .. " fired a " .. weaponName .. " " .. fireCount .. " times` at Coords: " .. coords, {
                            weapon = weaponName,
                            fireCount = fireCount,
                            coords = coords,
                        }, "Admin")
                    end
                    fireCount = 0
                end
            end
        end
    end)
end
