-----------------------------------
---------- Discord Reports --------
---           by Dead           ---
-----------------------------------

-- Config --
webhookURL = ''  -- <-- Set your actual Discord webhook URL here
displayIdentifiers = true

-- Helper functions --
function GetPlayers()
    local players = {}
    for _, i in ipairs(GetActivePlayers()) do
        if NetworkIsPlayerActive(i) then
            table.insert(players, i)
        end
    end
    return players
end

function stringsplit(inputstr, sep)
    if sep == nil then sep = "%s" end
    local t = {} ; local i = 1
    for str in string.gmatch(inputstr, "([^"..sep.."]+)") do
        t[i] = str
        i = i + 1
    end
    return t
end

function ExtractIdentifiers(src)
    local identifiers = { steam = "", ip = "", discord = "", license = "", xbl = "", live = "" }
    for i = 0, GetNumPlayerIdentifiers(src) - 1 do
        local id = GetPlayerIdentifier(src, i)
        if string.find(id, "steam") then identifiers.steam = id
        elseif string.find(id, "ip") then identifiers.ip = id
        elseif string.find(id, "discord") then identifiers.discord = id
        elseif string.find(id, "license") then identifiers.license = id
        elseif string.find(id, "xbl") then identifiers.xbl = id
        elseif string.find(id, "live") then identifiers.live = id
        end
    end
    return identifiers
end

function sendToDisc(title, message, footer)
    local embed = {{
        ["color"] = 16711680, -- RED
        ["title"] = "**".. title .."**",
        ["description"] = message,
        ["footer"] = { ["text"] = footer }
    }}
    PerformHttpRequest(webhookURL, function(err, text, headers) end, 'POST', json.encode({username = "Dead Reports", embeds = embed}), { ['Content-Type'] = 'application/json' })
end

-- Report Command --
RegisterCommand("report", function(source, args, rawCommand)
    local sm = stringsplit(rawCommand, " ")

    if #args < 2 then
        TriggerClientEvent('chatMessage', source, "^1ERROR: Invalid Usage. ^2Proper Usage: /report <id> <reason>")
        return
    end

    local id = tonumber(sm[2])
    if GetPlayerFromServerId(id) == nil then
        TriggerClientEvent('chatMessage', source, "^1ERROR: The specified ID is not online")
        return
    end

    local msg = ""
    local message = ""
    for i = 3, #sm do
        msg = msg .. sm[i] .. " "
        message = message .. sm[i] .. " "
    end

    TriggerClientEvent("Reports:CheckPermission:Client", -1, " ^9(^6" .. GetPlayerName(source) .. "^9) ^1[^3" .. id .. "^1] " .. msg, false)
    TriggerClientEvent('chatMessage', source, "^9[^1Dead-Reports^9] ^2Report has been submitted! Thank you!")

    if displayIdentifiers then
        local ids = ExtractIdentifiers(id)
        local steam = ids.steam:gsub("steam:", "")
        local steamDec = tostring(tonumber(steam,16))
        steam = "https://steamcommunity.com/profiles/" .. steamDec
        local gameLicense = ids.license
        local discord = ids.discord
        sendToDisc(
            "NEW REPORT: _[" .. id .. "] " .. GetPlayerName(id) .. "_",
            'Reason: **' .. message .. '**\n' ..
            'Steam: **' .. steam .. '**\n' ..
            'GameLicense: **' .. gameLicense .. '**\n' ..
            'Discord Tag: **<@' .. discord:gsub('discord:', '') .. '>**\n' ..
            'Discord UID: **' .. discord:gsub('discord:', '') .. '**',
            "Reported by: [" .. source .. "] " .. GetPlayerName(source)
        )
    else
        sendToDisc(
            "NEW REPORT: _[" .. id .. "] " .. GetPlayerName(id) .. "_",
            'Reason: **' .. message .. '**',
            "Reported by: [" .. source .. "] " .. GetPlayerName(source)
        )
    end
end)

-- Permission Check Event --
RegisterNetEvent("Reports:CheckPermission")
AddEventHandler("Reports:CheckPermission", function(msg)
    local src = source
    if IsPlayerAceAllowed(src, "DeadReports.See") then 
        TriggerClientEvent('chatMessage', src, "^9[^1Report^9] ^8" .. msg)
    end
end)
