local Core = nil
local ox_inventory = exports.ox_inventory
local pedspawned = false
local PlayerData = {}
local evidenceNpc = nil


if Config.Framework == 'ESX' then
	Core = exports['es_extended']:getSharedObject()
elseif Config.Framework == 'QBCore' then
	Core = exports['qb-core']:GetCoreObject()
end

if Config.Framework == 'ESX' then
	RegisterNetEvent('esx:playerLoaded')
	AddEventHandler('esx:playerLoaded', function(xPlayer)
		PlayerData = xPlayer
	end)

	RegisterNetEvent('esx:setJob')
	AddEventHandler('esx:setJob', function(job)
		PlayerData.job = job
	end)
elseif Config.Framework == 'QBCore' then
	RegisterNetEvent('QBCore:Client:OnPlayerLoaded', function()
		PlayerData = Core.Functions.GetPlayerData()
	end)

	RegisterNetEvent('QBCore:Client:OnJobUpdate',function(JobInfo)
		PlayerData.job = JobInfo
	end)
end

local function Notify(type,title, message)
    if title == nil then title = "Lockers" end
    if Config.NotificationType.Client == 'libs' then
            if type == 1 then
                lib.notify({
                    title = title,
                    description = message,
                    type = 'success'
                })
            elseif type == 2 then
                lib.notify({
                    title = title,
                    description = message,
                    type = 'inform'
                })
            elseif type == 3 then
                lib.notify({
                    title = title,
                    description = message,
                    type = 'error'
                })
            end
    elseif Config.NotificationType.Client == 'custom' then

    end
end


local function refreshjob()
	if Config.Framework == 'ESX' then
		PlayerData = Core.GetPlayerData()
	elseif Config.Framework == 'QBCore' then
    	PlayerData = Core.Functions.GetPlayerData()
	end
end

Citizen.CreateThread(function()
	for k, v in pairs(Config.location) do
		if v.UsePed == true then
			local hash = GetHashKey(v.ped)
			if not HasModelLoaded(hash) then
				RequestModel(hash)
				Wait(10)
			end
			while not HasModelLoaded(hash) do
				Wait(10)
			end

			pedspawned = true
			evidenceNpc = CreatePed(5, hash, v.coords, v.h, false, false)
			SetBlockingOfNonTemporaryEvents(evidenceNpc, true)
			SetPedDiesWhenInjured(evidenceNpc, false)
			SetPedCanPlayAmbientAnims(evidenceNpc, true)
			SetPedCanRagdollFromPlayerImpact(evidenceNpc, false)
			SetPedCanBeTargetted(evidenceNpc, false)
			SetEntityInvincible(evidenceNpc, true)
			FreezeEntityPosition(evidenceNpc, true)
		end
	end
end)

Citizen.CreateThread(function()
	for k,v in pairs(Config.location) do
		if Config.Target == 'ox_target' then
			exports[Config.Target]:addBoxZone({
				coords = vector3(v.coords.x,v.coords.y,v.coords.z+1.5),
				size = v.size,
				rotation = v.rotation,
				debug = false,
				options = {
					{
						name = 'evidence_Lockers',
						icon = 'fa-solid fa-cube',
						groups = v.job,
						label = v.TargetLabel,
						canInteract = function(entity, distance, coords, name)
							return true
						end,
						onSelect = function()
							TriggerEvent('SickEvidence:openInventory', false)
						end
					},
				}
			})
		elseif Config.Target == 'qtarget' then
			exports[Config.Target]:AddBoxZone('evidence_Lockers', vector3(v.coords.x,v.coords.y,v.coords.z), 3, 2, {
                name='evidence_Lockers',
                heading = v.h,
                debugPoly=false,
				minZ = 1.58,
				maxZ = 4.56
            }, {
                options = {
                    {
                    event = 'SickEvidence:openInventory',
                    icon = 'fas fa-door-open',
                    label = v.TargetLabel,
                    },
                },
				job = {v.job},
                distance = 2.5
            })
		elseif Config.Target == 'qb-target' then
			exports[Config.Target]:AddBoxZone("evidence_Lockers", vector3(v.coords.x,v.coords.y,v.coords.z), 3, 2, {
                name = 'evidence_Lockers',
                heading = v.h,
                debugPoly = false,
				minZ = 1.58,
				maxZ = 4.56
			}, {
				options = {
					{
						type = "client",
						event = 'SickEvidence:openInventory',
						icon = 'fas fa-door-open',
						label = v.TargetLabel,
						job = v.job,
					},
				},
				distance = 2.5
			})

		end
	end
end)


lib.registerContext({
	id = 'chiefmenu',
	title = 'Big Chief Shit!',
	options = {
		{
			title = 'Chief Options',
			description = 'Chief Options',
			arrow = true,
			event = 'SickEvidence:ChiefMenu',
		},
		{
			title = 'Open Locker Room',
			description = 'Open Locker Room',
			arrow = true,
			event = 'SickEvidence:lockerCallbackEvent',
		},
		{
			title = 'Open Evidence',
			description = 'Open Evidence Locker',
			arrow = true,
			event = 'SickEvidence:triggerEvidenceMenu',
		}
	},
})

lib.registerContext({
	id = 'openInventory',
	title = 'Evidence Lockers!',
	options = {
		{
			title = 'Open Locker Room',
			description = 'Open Locker Room',
			arrow = true,
			event = 'SickEvidence:lockerCallbackEvent',
		},
		{
			title = 'Open Evidence',
			description = 'Open Evidence Locker',
			arrow = true,
			event = 'SickEvidence:triggerEvidenceMenu',
		}
	},
})

RegisterNetEvent('SickEvidence:openInventory')
AddEventHandler('SickEvidence:openInventory',function(isHeist)
	refreshjob()
	if Config.Framework == 'ESX' then
		for k,v in pairs(Config.location) do
			for c,d in pairs(v.job) do
				if v.cop == true and d == PlayerData.job.name and PlayerData.job.grade >= c then
					lib.showContext('chiefmenu')
				elseif v.cop == true and d == PlayerData.job.name then
					lib.showContext('openInventory')
				elseif v.cop == false and d == PlayerData.job.name then
					lib.showContext('other_lockers')
				elseif isHeist then
					lib.showContext('openHeistInv')
				end
			end
		end
	elseif Config.Framework == 'QBCore' then
		for k,v in pairs(Config.location) do
			for c,d in pairs(v.job) do
				if v.cop == true and d == PlayerData.job.name and PlayerData.job.grade.level >= v.AllowedRank then
					lib.showContext('chiefmenu')
				elseif v.cop == true and d == PlayerData.job.name then
					lib.showContext('openInventory')
				elseif v.cop == false and d == PlayerData.job.name then
					lib.showContext('other_lockers')
				elseif isHeist then
					lib.showContext('openHeistInv')
				end
			end
		end
	end
end)

--- EVIDENCE LOCKERS ---

RegisterNetEvent('SickEvidence:confirmorcancel')
AddEventHandler('SickEvidence:confirmorcancel',function(args)
	if args.selection == "confirm" then
		local evidenceID = args.inventory
		if Config.inventory == 'ox' then
			TriggerServerEvent("SickEvidence:createInventory", evidenceID)
			Wait(1000)
			TriggerServerEvent('ox:loadStashes')
			ox_inventory:openInventory('Stash', evidenceID)
		elseif Config.inventory == 'qb' then
			local evidenceLocker = {}
			evidenceLocker.label = evidenceID
			evidenceLocker.items = evidenceID.inventory or {}
			evidenceLocker.slots = 50
			TriggerServerEvent("inventory:server:OpenInventory", "pdevidence", evidenceLocker.label, evidenceLocker)
		end
	end
end)


RegisterNetEvent('SickEvidence:triggerEvidenceMenu')
AddEventHandler('SickEvidence:triggerEvidenceMenu', function()
	local input = lib.inputDialog('LSPD Evidence', {'Incident Number (#...)'})

	if not input then
		lib.hideContext(false)
		return
	end
	local evidenceID = ("Case: "..input[1]) --("Case :"..input[1]) -- if you have issues when updating.. changed format cause it just looks better
	if Config.Framework == 'ESX' then
		Core.TriggerServerCallback('SickEvidence:getInventory', function(exists)
			if not exists then
				lib.registerContext({
					id = 'confirmCreate',
					title = 'Confirm or Cancel',
					options = {
						{
							title = 'Create New Evidence Inventory?',
							description = 'Evidence Inventory System'
						},
						{
							title = 'Confirm Creation?',
							description = 'Create an Evidence Storage?',
							arrow = true,
							event = 'SickEvidence:confirmorcancel',
							args = {
								selection = 'confirm',
								inventory = evidenceID
							}
						},
						{
							title = 'Cancel Creation?',
							description = 'Cancel The Creation of this Evidence Storage?',
							arrow = true,
							event = 'SickEvidence:confirmorcancel',
							args = {
								selection = 'cancel'
							}
						}
					},
				})
		
				lib.showContext('confirmCreate')
			else
				lib.registerContext({
					id = 'evidenceOption',
					title = 'Evidence Options',
					options = {
						{
							title = 'Evidence Delete/Open'
						},
						{
							title = 'Open Evidence?',
							description = 'Open Evidence Storage?',
							arrow = true,
							event = 'SickEvidence:evidenceOptions',
							args = {
								selection = "open",
								inventory = evidenceID
							}
						},
						{
							title = 'Delete Inventory?',
							description = 'Delete this Evidence Storage?',
							arrow = true,
							event = 'SickEvidence:evidenceOptions',
							args = {
								selection = "delete",
								inventory = evidenceID
							}
						}
					},
				})
				lib.showContext('evidenceOption')
			end
		end,evidenceID)
	elseif Config.Framework == 'QBCore' then
		Core.Functions.TriggerCallback('SickEvidence:getInventory', function(exists)
			if not exists then
				lib.registerContext({
					id = 'confirmCreate',
					title = 'Confirm or Cancel',
					options = {
						{
							title = 'Create New Evidence Inventory?',
							description = 'Evidence Inventory System'
						},
						{
							title = 'Confirm Creation?',
							description = 'Create an Evidence Storage?',
							arrow = true,
							event = 'SickEvidence:confirmorcancel',
							args = {
								selection = 'confirm',
								inventory = evidenceID
							}
						},
						{
							title = 'Cancel Creation?',
							description = 'Cancel The Creation of this Evidence Storage?',
							arrow = true,
							event = 'SickEvidence:confirmorcancel',
							args = {
								selection = 'cancel'
							}
						}
					},
				})
		
				lib.showContext('confirmCreate')
			else
				lib.registerContext({
					id = 'evidenceOption',
					title = 'Evidence Options',
					options = {
						{
							title = 'Evidence Delete/Open'
						},
						{
							title = 'Open Evidence?',
							description = 'Open Evidence Storage?',
							arrow = true,
							event = 'SickEvidence:evidenceOptions',
							args = {
								selection = "open",
								inventory = evidenceID
							}
						},
						{
							title = 'Delete Inventory?',
							description = 'Delete this Evidence Storage?',
							arrow = true,
							event = 'SickEvidence:evidenceOptions',
							args = {
								selection = "delete",
								inventory = evidenceID
							}
						}
					},
				})
				lib.showContext('evidenceOption')
			end
		end, evidenceID)
	end
end)

RegisterNetEvent('SickEvidence:evidenceOptions')
AddEventHandler('SickEvidence:evidenceOptions', function(args)
	if args.selection == "delete" then
		local evidenceID = args.inventory
		TriggerServerEvent("SickEvidence:deleteEvidence", evidenceID)
		exports.SickLibs:ClientNotify(1, "Lockers", "Deleted Evidence!")
	elseif args.selection == "open" then
		local evidenceID = args.inventory
		Wait(1000)
		TriggerServerEvent('ox:loadStashes')
	    ox_inventory:openInventory('Stash', evidenceID)
	end
end)

--- PERSONAL LOCKERS ---

RegisterNetEvent('SickEvidence:confirmLocker')
AddEventHandler('SickEvidence:confirmLocker', function(args)
	if args.selection == "confirm" then
		local lockerID = args.inventory
		TriggerServerEvent("SickEvidence:createLocker", lockerID)
		Wait(1000)
		TriggerServerEvent('ox:loadStashes')
	    ox_inventory:openInventory('Stash', lockerID)
	end
end)

local function lockerOption(lockerID)
	lib.registerContext({
		id = 'lockerOption',
		title = 'Confirm or Cancel',
		options = {
			{
				title = 'Locker Options',
				description = 'Locker Delete/Open'
			},
			{
				title = 'Open Locker?',
				description = 'Open a Personal Locker?',
				arrow = true,
				event = 'SickEvidence:lockerOptions',
				args = {
					selection = 'open',
					inventory = lockerID
				},
				metadata = {
					{label = lockerID}
				}
			},
			{
				title = 'Delete Locker?',
				description = 'Delete Your Personal Locker?',
				arrow = true,
				event = 'SickEvidence:confirmorcancel',
				args = {
					selection = "delete",
					inventory = lockerID
				}
			}
		},
	})

	lib.showContext('lockerOption')
end

RegisterNetEvent('SickEvidence:lockerOptions')
AddEventHandler('SickEvidence:lockerOptions', function(args)
	if args.selection == "delete" then
		local lockerID = args.inventory
		TriggerServerEvent("SickEvidence:deleteLocker", lockerID)
		exports.SickLibs:ClientNotify(1, "Lockers", "Deleted Locker!")
	elseif args.selection == "open" then
		local lockerID = args.inventory
		TriggerServerEvent('ox:loadStashes')
	    ox_inventory:openInventory('Stash', lockerID)
	end
end)

RegisterNetEvent('SickEvidence:lockerCallbackEvent')
AddEventHandler('SickEvidence:lockerCallbackEvent', function()
	if Config.Framework == 'ESX' then
		Core.TriggerServerCallback('SickEvidence:getPlayerName', function(data)
			if data then
				local lockerID = ("LEO: "..data.firstname.." "..data.lastname)
				Core.TriggerServerCallback('SickEvidence:getLocker', function(locker)
					if locker then
						lib.registerContext({
							id = 'lockerCreate',
							title = 'Confirm or Cancel',
							menu = 'openInventory',
							options = {
								{
									title = 'Create New Locker?',
									description = 'Locker Inventory System'
								},
								{
									title = 'Confirm Creation?',
									description = 'Create a Personal Locker?',
									arrow = true,
									event = 'SickEvidence:confirmLocker',
									args = {selection = 'confirm', inventory = lockerID}
								},
								{
									title = 'Cancel Creation?',
									description = 'Cancel The Creation of this Personal Locker?',
									arrow = true,
									event = 'SickEvidence:confirmLocker',
									args = {selection = 'cancel'}
								}
							},
						})

						lib.showContext('lockerCreate')
					else
						lib.registerContext({
							id = 'lockerOption',
							title = 'Confirm or Cancel',
							options = {
								{
									title = 'Locker Options',
									description = 'Locker Delete/Open'
								},
								{
									title = 'Open Locker?',
									description = 'Open a Personal Locker?',
									arrow = true,
									event = 'SickEvidence:lockerOptions',
									args = {
										selection = 'open',
										inventory = lockerID
									},
									metadata = {
										{label = lockerID}
									}
								},
								{
									title = 'Delete Locker?',
									description = 'Delete Your Personal Locker?',
									arrow = true,
									event = 'SickEvidence:confirmorcancel',
									args = {
										selection = "delete",
										inventory = lockerID
									}
								}
							},
						})

						lib.showContext('lockerOption')
					end
				end, lockerID)
			else
				Notify(3, "Lockers", "Info can\'t be found!")
			end

		end)
	elseif Config.Framework == 'QBCore' then
		Core.Functions.TriggerCallback('SickEvidence:getPlayerName', function(data)
			if data then
				local lockerID = ("LEO: "..data.firstname.." "..data.lastname)
				Core.Functions.TriggerCallback('SickEvidence:getPlayerName', function(locker)
					if locker then
						lib.registerContext({
							id = 'lockerCreate',
							title = 'Confirm or Cancel',
							menu = 'openInventory',
							options = {
								{
									title = 'Create New Locker?',
									description = 'Locker Inventory System'
								},
								{
									title = 'Confirm Creation?',
									description = 'Create a Personal Locker?',
									arrow = true,
									event = 'SickEvidence:confirmLocker',
									args = {selection = 'confirm', inventory = lockerID}
								},
								{
									title = 'Cancel Creation?',
									description = 'Cancel The Creation of this Personal Locker?',
									arrow = true,
									event = 'SickEvidence:confirmLocker',
									args = {selection = 'cancel'}
								}
							},
						})
		
						lib.showContext('lockerCreate')
					else
						lib.registerContext({
							id = 'lockerOption',
							title = 'Confirm or Cancel',
							options = {
								{
									title = 'Locker Options',
									description = 'Locker Delete/Open'
								},
								{
									title = 'Open Locker?',
									description = 'Open a Personal Locker?',
									arrow = true,
									event = 'SickEvidence:lockerOptions',
									args = {
										selection = 'open',
										inventory = lockerID
									},
									metadata = {
										{label = lockerID}
									}
								},
								{
									title = 'Delete Locker?',
									description = 'Delete Your Personal Locker?',
									arrow = true,
									event = 'SickEvidence:confirmorcancel',
									args = {
										selection = "delete",
										inventory = lockerID
									}
								}
							},
						})
		
						lib.showContext('lockerOption')
					end
				end, lockerID)
			else
				Notify(3, "Lockers", "Info can\'t be found!")
			end
		end)
	end
end)


--- CHIEF SHIT ---
RegisterNetEvent('SickEvidence:ChiefMenu')
AddEventHandler('SickEvidence:ChiefMenu', function()
	lib.showContext('chooseOption')
end)

lib.registerContext({
	id = 'chooseOption',
	title = 'Options...',
	options = {
		{
			title = 'Choose Option',
			description = 'Pick an Option below for Locker/Evidence Opening!'
		},
		{
			title = 'Open Locker?',
			description = 'Open a Personal Locker?',
			arrow = true,
			event = 'SickEvidence:ChiefLookup',
		},
		{
			title = 'Open Case?',
			description = 'Open an Evidence Storage?',
			arrow = true,
			event = 'SickEvidence:ChiefCaseMenu',
		}
	},
})

local function ChooseOption()
	lib.showContext('chooseOption')
end

RegisterNetEvent('SickEvidence:ChiefLookup')
AddEventHandler('SickEvidence:ChiefLookup', function()
	local input = lib.inputDialog('Police locker', {'First Name', 'Last Name'})

	if not input then
		lib.hideContext(false)
		return
	end
	local lockerID = ("LEO: "..input[1].. " "..input[2])
	if Config.Framework == 'ESX' then
		Core.TriggerServerCallback('SickEvidence:getInventory', function(exists)
			if exists then
				lib.registerContext({
					id = 'lockerOption',
					title = 'Confirm or Cancel',
					options = {
						{
							title = 'Locker Options',
							description = 'Locker Delete/Open'
						},
						{
							title = 'Open Locker?',
							description = 'Open a Personal Locker?',
							arrow = true,
							event = 'SickEvidence:lockerOptions',
							args = {
								selection = 'open',
								inventory = lockerID
							},
							metadata = {
								{label = lockerID}
							}
						},
						{
							title = 'Delete Locker?',
							description = 'Delete Your Personal Locker?',
							arrow = true,
							event = 'SickEvidence:confirmorcancel',
							args = {
								selection = "delete",
								inventory = lockerID
							}
						}
					},
				})
		
				lib.showContext('lockerOption')
			else
				Notify(3, "Lockers", string.format('No Lockers with name: '..lockerID))
			end
		end, lockerID)
	elseif Config.Framework == 'QBCore' then
		Core.Functions.TriggerCallback('SickEvidence:getInventory', function(exists)
			if exists then
				lib.registerContext({
					id = 'lockerOption',
					title = 'Confirm or Cancel',
					options = {
						{
							title = 'Locker Options',
							description = 'Locker Delete/Open'
						},
						{
							title = 'Open Locker?',
							description = 'Open a Personal Locker?',
							arrow = true,
							event = 'SickEvidence:lockerOptions',
							args = {
								selection = 'open',
								inventory = lockerID
							},
							metadata = {
								{label = lockerID}
							}
						},
						{
							title = 'Delete Locker?',
							description = 'Delete Your Personal Locker?',
							arrow = true,
							event = 'SickEvidence:confirmorcancel',
							args = {
								selection = "delete",
								inventory = lockerID
							}
						}
					},
				})
		
				lib.showContext('lockerOption')
			else
				Notify(3, "Lockers", string.format('No Lockers with name: '..lockerID))
			end
		end, lockerID)
	end
end)

RegisterNetEvent('SickEvidence:ChiefCaseMenu')
AddEventHandler('SickEvidence:ChiefCaseMenu', function()
	local input = lib.inputDialog('LSPD Cases', {'Enter Case#'})

	if not input then
		lib.hideContext(false)
		return
	end
	local evidenceID = ("Case: "..input[1])
	if Config.Framework == 'ESX' then
		Core.TriggerServerCallback('SickEvidence:getInventory', function(exists)
			if exists then
				lib.registerContext({
					id = 'evidenceOption',
					title = 'Evidence Options',
					options = {
						{
							title = 'Evidence Delete/Open'
						},
						{
							title = 'Open Evidence?',
							description = 'Open Evidence Storage?',
							arrow = true,
							event = 'SickEvidence:evidenceOptions',
							args = {
								selection = "open",
								inventory = evidenceID
							}
						},
						{
							title = 'Delete Inventory?',
							description = 'Delete this Evidence Storage?',
							arrow = true,
							event = 'SickEvidence:evidenceOptions',
							args = {
								selection = "delete",
								inventory = evidenceID
							}
						}
					},
				})
				lib.showContext('evidenceOption')
			else
				Notify(3, "Lockers", string.format('No Evidence Storages with name: '..evidenceID))
			end
		end, evidenceID)
	elseif Config.Framework == 'QBCore' then
		Core.Functions.TriggerCallback('SickEvidence:getInventory', function(exists)
			if exists then
				lib.registerContext({
					id = 'evidenceOption',
					title = 'Evidence Options',
					options = {
						{
							title = 'Evidence Delete/Open'
						},
						{
							title = 'Open Evidence?',
							description = 'Open Evidence Storage?',
							arrow = true,
							event = 'SickEvidence:evidenceOptions',
							args = {
								selection = "open",
								inventory = evidenceID
							}
						},
						{
							title = 'Delete Inventory?',
							description = 'Delete this Evidence Storage?',
							arrow = true,
							event = 'SickEvidence:evidenceOptions',
							args = {
								selection = "delete",
								inventory = evidenceID
							}
						}
					},
				})
				lib.showContext('evidenceOption')
			else
				Notify(3, "Lockers", string.format('No Evidence Storages with name: '..evidenceID))
			end
		end, evidenceID)
	end
end)

RegisterNetEvent('SickEvidence:ChiefLockerCheck')
AddEventHandler('SickEvidence:ChiefLockerCheck', function(ID)
	if Config.Framework == 'ESX' then
		Core.TriggerServerCallback('SickEvidence:getLocker',function(exists)
			if exists then
				lockerOption(ID)
			else
				Notify(3, "Lockers", string.format('No Lockers with name: '..ID))
			end
		end,ID)
	elseif Config.Framework == 'QBCore' then
		Core.Functions.TriggerCallback('SickEvidence:getLocker',function(exists)
			if exists then
				lockerOption(ID)
			else
				Notify(3, "Lockers", string.format('No Lockers with name: '..ID))
			end
		end,ID)
	end
end)

RegisterNetEvent('SickEvidence:ChieflockerOptions')
AddEventHandler('SickEvidence:ChieflockerOptions', function(args)
	if args.selection == "delete" then
		local lockerID = args.inventory
		TriggerServerEvent("SickEvidence:deleteLocker", lockerID)
		Notify(1, "Lockers", "Deleted Locker!")
	elseif args.selection == "open" then
		local lockerID = args.inventory
		TriggerServerEvent('ox:loadStashes')
	    ox_inventory:openInventory('Stash', lockerID)
	end
end)

----NEW JOBS---

lib.registerContext({
	id = 'other_lockers',
	title = 'Personal Lockers!',
	options = {
		{
			title = 'Open Locker Room',
			description = 'Open Locker Room',
			arrow = true,
			event = 'SickEvidence:OtherlockerCallbackEvent',
		}
	},
})

RegisterNetEvent('SickEvidence:OtherlockerOptions')
AddEventHandler('SickEvidence:OtherlockerOptions', function(args)
	if args.selection == "delete" then
		local OtherlockerID = args.inventory
		TriggerServerEvent("SickEvidence:deleteLocker", OtherlockerID)
		Notify(1, "Lockers", "Deleted Locker!")
	elseif args.selection == "open" then
		local OtherlockerID = args.inventory
		TriggerServerEvent('ox:loadStashes')
	    ox_inventory:openInventory('Stash', OtherlockerID)
	end
end)

RegisterNetEvent('SickEvidence:OtherlockerCallbackEvent')
AddEventHandler('SickEvidence:OtherlockerCallbackEvent', function()
	if Config.Framework == 'ESX' then
		Core.TriggerServerCallback('SickEvidence:getPlayerName',function(data)
			--if data then
				
				local OtherlockerID = (PlayerData.job.name.. ": " ..data.firstname.." "..data.lastname)
				Core.TriggerServerCallback('SickEvidence:getOtherInventories',function(Otherlocker)
					if Otherlocker then
						lib.registerContext({
							id = 'Other_lockerOption',
							title = 'Confirm or Cancel',
							options = {
								{
									title = 'Locker Options',
									description = 'Locker Delete/Open'
								},
								{
									title = 'Open Locker?',
									description = 'Open a Personal Locker?',
									arrow = true,
									event = 'SickEvidence:OtherlockerOptions',
									args = {
										selection = 'open',
										inventory = OtherlockerID
									}
								},
								{
									title = 'Delete Locker?',
									description = 'Delete Your Personal Locker?',
									arrow = true,
									event = 'SickEvidence:confirmorcancel',
									args = {
										selection = "delete",
										inventory = OtherlockerID
									}
								}
							},
						})

						lib.showContext('Other_lockerOption')
					else
						lib.registerContext({
							id = 'Other_lockerCreate',
							title = 'Confirm or Cancel',
							options = {
								{
									title = 'Create New Locker?',
									description = 'Locker Inventory System'
								},
								{
									title = 'Confirm Creation?',
									description = 'Create a Personal Locker?',
									arrow = true,
									event = 'SickEvidence:confirmorcancelOthers',
									args = {selection = 'confirm', inventory = OtherlockerID}
								},
								{
									title = 'Cancel Creation?',
									description = 'Cancel The Creation of this Personal Locker?',
									arrow = true,
									event = 'SickEvidence:confirmorcancelOthers',
									args = {selection = 'cancel'}
								}
							},
						})

						lib.showContext('Other_lockerCreate')
					end
				end,OtherlockerID)
			--else
				--Notify(3, "Lockers", "Info can\'t be found!")
			--end
		end)
	elseif Config.Framework == 'QBCore' then
		Core.TriggerServerCallback('SickEvidence:getPlayerName',function(data)
			local OtherlockerID = (PlayerData.job.name.. ": " ..data.firstname.." "..data.lastname)
			Core.TriggerServerCallback('SickEvidence:getOtherInventories',function(Otherlocker)
				if Otherlocker then
					lib.registerContext({
						id = 'Other_lockerOption',
						title = 'Confirm or Cancel',
						options = {
							{
								title = 'Locker Options',
								description = 'Locker Delete/Open'
							},
							{
								title = 'Open Locker?',
								description = 'Open a Personal Locker?',
								arrow = true,
								event = 'SickEvidence:OtherlockerOptions',
								args = {
									selection = 'open',
									inventory = OtherlockerID
								}
							},
							{
								title = 'Delete Locker?',
								description = 'Delete Your Personal Locker?',
								arrow = true,
								event = 'SickEvidence:confirmorcancel',
								args = {
									selection = "delete",
									inventory = OtherlockerID
								}
							}
						},
					})

					lib.showContext('Other_lockerOption')
				else
					lib.registerContext({
						id = 'Other_lockerCreate',
						title = 'Confirm or Cancel',
						options = {
							{
								title = 'Create New Locker?',
								description = 'Locker Inventory System'
							},
							{
								title = 'Confirm Creation?',
								description = 'Create a Personal Locker?',
								arrow = true,
								event = 'SickEvidence:confirmorcancelOthers',
								args = {selection = 'confirm', inventory = OtherlockerID}
							},
							{
								title = 'Cancel Creation?',
								description = 'Cancel The Creation of this Personal Locker?',
								arrow = true,
								event = 'SickEvidence:confirmorcancelOthers',
								args = {selection = 'cancel'}
							}
						},
					})

					lib.showContext('Other_lockerCreate')
				end
			end,OtherlockerID)
		end)
	end
end)

RegisterNetEvent('SickEvidence:confirmorcancelOthers')
AddEventHandler('SickEvidence:confirmorcancelOthers', function(args)
	if args.selection == "confirm" then
		local OtherlockerID = args.inventory
		TriggerServerEvent("SickEvidence:createOtherLocker", OtherlockerID)
		Wait(1000)
		TriggerServerEvent('ox:loadStashes')
	    ox_inventory:openInventory('Stash', OtherlockerID)
	end
end)
