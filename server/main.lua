local Core = nil

local ox_inventory = exports.ox_inventory

Discord_url = "" -- set webhook url here!

local function sendDeleteDiscord(color, name, message, footer)
  local embed = {
        {
            ["color"] = 3085967,
            ["title"] = "**".. name .."**",
            ["description"] = message,
            ["footer"] = {
                ["text"] = footer,
            },
            ["author"] = {
              ["name"] = 'Made by | SickJuggalo666',
              ['icon_url'] = 'https://i.imgur.com/arJnggZ.png'
            }
        }
    }

  PerformHttpRequest(Discord_url, function(err, text, headers) end, 'POST', json.encode({username = name, embeds = embed}), { ['Content-Type'] = 'application/json' })
end

local function sendCreateDiscord(color, name, message, footer)
  local embed = {
        {
            ["color"] = 3085967,
            ["title"] = "**".. name .."**",
            ["description"] = message,
            ["footer"] = {
                ["text"] = footer,
            },
            ["author"] = {
              ["name"] = 'Made by | SickJuggalo666',
              ['icon_url'] = 'https://i.imgur.com/arJnggZ.png'
            }
        }
    }

  PerformHttpRequest(Discord_url, function(err, text, headers) end, 'POST', json.encode({username = name, embeds = embed}), { ['Content-Type'] = 'application/json' })
end

if Config.Framework == 'ESX' then
  Core = exports['es_extended']:getSharedObject()
elseif Config.Framework == 'QBCore' then
  Core = exports['qb-core']:GetCoreObject()
end

RegisterNetEvent('SickEvidence:createInventory')
AddEventHandler('SickEvidence:createInventory', function(evidenceID)
    if Config.Framework == 'ESX' then
      local xPlayer = Core.GetPlayerFromId(source)
      local name = xPlayer.getName()
      local id = evidenceID
      local label = evidenceID
      local slots = 25
      local maxWeight = 5000

      ox_inventory:RegisterStash(id, label, slots, maxWeight, nil, false, nil)
      sendCreateDiscord(source, name, "Created Evidence", evidenceID)
    elseif Config.Framework == 'QBCore' then
      local xPlayer = Core.Functions.GetPlayer(source)
      local name = xPlayer.PlayerData.charinfo.firstname..' '..xPlayer.PlayerData.charinfo.lastname
      local id = evidenceID
      local label = evidenceID
      local slots = 25
      local maxWeight = 5000

      ox_inventory:RegisterStash(id, label, slots, maxWeight, nil, false, nil)
      sendCreateDiscord(source, name, "Created Evidence", evidenceID)
    end
end)

RegisterNetEvent('SickEvidence:deleteEvidence')
AddEventHandler('SickEvidence:deleteEvidence', function(evidenceID)
    MySQL.update('DELETE FROM ox_inventory WHERE name = ?',
      {
        evidenceID
      },function(result)
        if result then
          --Notify(1, src, "Warrant was deleted Successfully!")
        else
          --Notify(3, src, "Warrant wasn\'t Deleted please try again!")
        end
    end)
    sendDeleteDiscord(source, 'name', "Deleted Evidence",evidenceID)
end)

RegisterNetEvent('SickEvidence:createLocker')
AddEventHandler('SickEvidence:createLocker', function(lockerID)
    if Config.Framework == 'ESX' then
        local xPlayer = Core.GetPlayerFromId(source)
        local name = xPlayer.getName()
        local id = lockerID
        local label = lockerID
        local slots = 25
        local maxWeight = 5000

        ox_inventory:RegisterStash(id, label, slots, maxWeight,nil)
        sendCreateDiscord(source, name, "Created Locker",label)
    elseif Config.Framework == 'QBCore' then
        local xPlayer = Core.Functions.GetPlayer(source)
        local name = xPlayer.PlayerData.charinfo.firstname..' '..xPlayer.PlayerData.charinfo.lastname
        local id = lockerID
        local label = lockerID
        local slots = 25
        local maxWeight = 5000

        ox_inventory:RegisterStash(id, label, slots, maxWeight,nil)
        sendCreateDiscord(source, name, "Created Locker",label)
    end
end)

RegisterNetEvent('SickEvidence:createOtherLocker')
AddEventHandler('SickEvidence:createOtherLocker', function(OtherlockerID)
    if Config.Framework == 'ESX' then
        local xPlayer = Core.GetPlayerFromId(source)
        local name = xPlayer.getName()
        local id = OtherlockerID
        local label = OtherlockerID
        local slots = 25
        local maxWeight = 5000

        ox_inventory:RegisterStash(id, label, slots, maxWeight, nil, false, nil)
        local message = ('%s Created Job Locker %s'):format(xPlayer.getName(), label)
        sendCreateDiscord(source, name, message, label)
    elseif Config.Framework == 'QBCore' then
        local xPlayer = Core.Functions.GetPlayer(source)
        local name = xPlayer.PlayerData.charinfo.firstname..' '..xPlayer.PlayerData.charinfo.lastname
        local id = OtherlockerID
        local label = OtherlockerID
        local slots = 25
        local maxWeight = 5000

        ox_inventory:RegisterStash(id, label, slots, maxWeight, nil, false, nil)
        local message = ('%s %s Created Job Locker %s'):format(xPlayer.PlayerData.charinfo.firstname, xPlayer.PlayerData.charinfo.lastname, label)
        sendCreateDiscord(source, name, message, label)
    end
end)

RegisterNetEvent('SickEvidence:createGangLocker')
AddEventHandler('SickEvidence:createGangLocker', function(GanglockerID)
    if Config.Framework == 'ESX' then
      local xPlayer = Core.GetPlayerFromId(source)
      local name = xPlayer.getName()
      local id = GanglockerID
      local label = GanglockerID
      local slots = 25
      local maxWeight = 5000

      ox_inventory:RegisterStash(id, label, slots, maxWeight, nil, false, nil)
      local message = ('%s Created Job Locker %s'):format(xPlayer.getName(), label)
      sendCreateDiscord(source, name, message, label)
    elseif Config.Framework == 'QBCore' then
        local xPlayer = Core.Functions.GetPlayer(source)
        local name = xPlayer.PlayerData.charinfo.firstname..' '..xPlayer.PlayerData.charinfo.lastname
        local id = GanglockerID
        local label = GanglockerID
        local slots = 25
        local maxWeight = 5000

        ox_inventory:RegisterStash(id, label, slots, maxWeight, nil, false, nil)
        local message = ('%s %s Created Job Locker %s'):format(xPlayer.PlayerData.charinfo.firstname, xPlayer.PlayerData.charinfo.lastname, label)
        sendCreateDiscord(source, name, message, label)
    end
end)

RegisterNetEvent('SickEvidence:deleteLocker')
AddEventHandler('SickEvidence:deleteLocker', function(lockerID)
    local src = source
    MySQL.query('DELETE FROM ox_inventory WHERE name = ?',
      {
        lockerID.inventory
      },function(result)
        if result then
          print('true')
          --Notify(1, src, "Locker was deleted Successfully!")
        else
          print('false')
          --Notify(3, src, "Locker wasn\'t Deleted please try again!")
        end
    end)
end)

if Config.Framework == 'ESX' then
    Core.RegisterServerCallback('SickEvidence:getPlayerName', function(src, cb)
      local xPlayer = Core.GetPlayerFromId(src)
      MySQL.query('SELECT `firstname`,`lastname` FROM `users` WHERE `identifier` = @identifier',{
          ['@identifier'] = xPlayer.identifier},
        function(results)
          if results[1] then
              local data = {
                firstname = results[1].firstname,
                lastname  = results[1].lastname,
              }
              cb(data)
          end
      end)

    end)
    Core.RegisterServerCallback('SickEvidence:getLocker', function(src, cb, lockerID)
        local inv = exports.ox_inventory:GetInventory(lockerID, false)
        if inv then
          cb(true)
        else
          cb(false)
        end
    end)
    Core.RegisterServerCallback('SickEvidence:getOtherInventories', function(src, cb, Otherlocker)
        local inv = exports.ox_inventory:GetInventory(Otherlocker, false)
        if inv then
          return true
        else
          return false
        end
    end)
    Core.RegisterServerCallback('SickEvidence:getInventory', function(source, cb, evidenceID)
        local inv = exports.ox_inventory:GetInventory(evidenceID, false)
        if inv then
          cb(true)
        else
          cb(false)
        end
    end)
elseif Config.Framework == 'QBCore' then
    Core.Functions.CreateCallback('SickEvidence:getPlayerName',function(source, cb)
        local xPlayer = Core.Functions.GetPlayer(source)
        local data = {
          job = xPlayer.PlayerData.job.label,
          firstname = xPlayer.PlayerData.charinfo.firstname,
          lastname  = xPlayer.PlayerData.charinfo.lastname,
        }
        cb(data)
    end)
    Core.Functions.CreateCallback('SickEvidence:getLocker',function(source,cb, lockerID)
        local inv = exports.ox_inventory:GetInventory(lockerID, false)
        if not inv then
          cb(true)
        else
          cb(false)
        end
    end)
    Core.Functions.CreateCallback('SickEvidence:getOtherInventories',function(source,cb, Otherlocker)
        local inv = exports.ox_inventory:GetInventory(Otherlocker, false)
        if inv then
          cb(true)
        else
          cb(false)
        end
    end)
    Core.Functions.CreateCallback('SickEvidence:getInventory', function(source, cb, evidenceID)
        local inv = exports.ox_inventory:GetInventory(evidenceID, false)
        if inv then
          cb(true)
        else
          cb(false)
        end
    end)
end

RegisterNetEvent('SickEvidence:loadStashes', function(id)
    MySQL.query('SELECT * FROM `ox_inventory` WHERE name =?', {id}, function(result)
        if result then
          ox_inventory:RegisterStash(id, id, 50, 100000)
        end
    end)
end)