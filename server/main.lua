local Core = nil

local ox_inventory = exports.ox_inventory

Discord_url = ""

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
      
      ox_inventory:RegisterStash(id, label, slots, maxWeight)
      sendCreateDiscord(source, name, "Created Evidence", evidenceID)
    elseif Config.Framework == 'QBCore' then
      local xPlayer = Core.Functions.GetPlayer(source)
      local name = xPlayer.PlayerData.charinfo.firstname..' '..xPlayer.PlayerData.charinfo.lastname
      local id = evidenceID
      local label = evidenceID  
      local slots = 25 
      local maxWeight = 5000 
      
      ox_inventory:RegisterStash(id, label, slots, maxWeight,nil)
      sendCreateDiscord(source, name, "Created Evidence", evidenceID)
    end
end)

lib.callback.register('SickEvidence:getInventory', function(source, evidenceID)
  print(evidenceID)
    local inv = exports.ox_inventory:GetInventory(evidenceID, false)
    print(inv)
    if inv then
      return true
    else
      return false
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
    sendDeleteDiscord(source, name, "Deleted Evidence",evidenceID)
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

lib.callback.register('SickEvidence:getOtherInventories', function(source, Otherlocker)
    local inv = exports.ox_inventory:GetInventory(Otherlocker, false)
    if inv then
      return true
    else
      return false
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
        
        ox_inventory:RegisterStash(id, label, slots, maxWeight,nil)
        local data = {
          Discord_url = Discord_url,
          title = 'Lockers',
          message = ('%s Created Job Locker %s'):format(Player.getName(), label)
        }
        exports.SickLibs:DiscordLog(data)
    elseif Config.Framework == 'QBCore' then
        local xPlayer = Core.Functions.GetPlayer(source)
        local name = xPlayer.PlayerData.charinfo.firstname..' '..xPlayer.PlayerData.charinfo.lastname
        local id = OtherlockerID  
        local label = OtherlockerID  
        local slots = 25 
        local maxWeight = 5000 
        
        ox_inventory:RegisterStash(id, label, slots, maxWeight,nil)
        local data = {
          Discord_url = Discord_url,
          title = 'Lockers',
          message = ('%s %s Created Job Locker %s'):format(Player.PlayerData.charinfo.firstname, Player.PlayerData.charinfo.lastname, label)
        }
        exports.SickLibs:DiscordLog(data)
    end
end)


lib.callback.register('SickEvidence:getLocker', function(source, lockerID)
  local inv = exports.ox_inventory:GetInventory(lockerID, false)
  if not inv then
    return true
  else
    return false
  end
end)

RegisterNetEvent('SickEvidence:deleteLocker')
AddEventHandler('SickEvidence:deleteLocker', function(lockerID)
      MySQL.update('DELETE FROM ox_inventory WHERE name = ?',
      {
        lockerID
      },function(result)
        if result then
          --Notify(1, src, "Warrant was deleted Successfully!")
        else
          --Notify(3, src, "Warrant wasn\'t Deleted please try again!")
        end
    end)
    if Config.Framework == 'ESX' then
      local Player = Core.GetPlayerFromId(source)
      local data = {
        Discord_url = Discord_url,
        title = 'Lockers',
        message = ('%s Deleted Locker %s'):format(Player.getName(), lockerID)
      }
      exports.SickLibs:DiscordLog(data)
    elseif Config.Framework == 'QBCore' then
      local Player = Core.Functions.GetPlayer(source)
      local data = {
        Discord_url = Discord_url,
        title = 'Lockers',
        message = ('%s %s Deleted Locker %s'):format(Player.PlayerData.charinfo.firstname, Player.PlayerData.charinfo.lastname, lockerID)
      }
      exports.SickLibs:DiscordLog(data)
    end
end)

sendDeleteDiscord = function(color, name, message, footer)
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

sendCreateDiscord = function(color, name, message, footer)
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

lib.callback.register('SickEvidence:getPlayerName', function(source)
    if Config.Framework == 'ESX' then
      local xPlayer = Core.GetPlayerFromId(source)
      MySQL.query('SELECT `firstname`,`lastname` FROM `users` WHERE `identifier` = @identifier',{
          ['@identifier'] = xPlayer.identifier}, 
        function(results)
          if results[1] then
            local data = {
              firstname = results[1].firstname,
              lastname  = results[1].lastname,
            }
            return data
          else
            return nil
          end
      end)
    elseif Config.Framework == 'QBCore' then
      local xPlayer = Core.Functions.GetPlayer(source)
      local data = {
        firstname = xPlayer.PlayerData.charinfo.firstname,
        lastname  = xPlayer.PlayerData.charinfo.lastname,
      }
      return data
    end
end)

AddEventHandler('txAdmin:events:scheduledRestart', function(eventData)
  if eventData.secondsRemaining == 60 then
      CreateThread(function()
          Wait(45000)
          ExecuteCommand('saveinv')
      end)
  end
end)

AddEventHandler('onResourceStop', function(resourceName)
  if (GetCurrentResourceName() == resourceName) then
      ExecuteCommand('saveinv')
  end
end)