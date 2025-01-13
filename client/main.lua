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

for k, v in pairs(Config.location) do
	if not Config.Target == 'qb-target' then
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
end

for k,v in pairs(Config.GangLocations) do
	if not Config.Target == 'qb-target' then
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
end


local function isGang(gang)
	local Player = Core.Functions.GetPlayerData()
	if Player.gang.name == gang then
		return true
	else
		return false
	end
end

local function OpenGangLocker(gang)
	if Config.inventory == 'qb' then
		TriggerServerEvent('SickLockers:OpenInvQB', string.upper(gang))
	elseif Config.inventory == 'ox' then
		TriggerServerEvent("SickEvidence:createGangLocker", string.upper(gang))
		Wait(1000)
	    ox_inventory:openInventory('Stash', string.upper(gang))
	end
end

local function OpenPersonalGangLocker()
	local Player = Core.Functions.GetPlayerData()
	local name = string.upper(Player.gang.name)..': '..Player.charinfo.firstname
	if Config.inventory == 'qb' then
		TriggerServerEvent('SickLockers:OpenInvQB', name)
	elseif Config.inventory == 'ox' then
		TriggerServerEvent("SickEvidence:createGangLocker", name)
		Wait(1000)
	    ox_inventory:openInventory('Stash', name)
	end
end

RegisterNetEvent('SickLockers:OpenGangLocker')
AddEventHandler('SickLockers:OpenGangLocker', function(k)
	local Player = Core.Functions.GetPlayerData()
	if Player.gang.name == k.gang then
		if Player.gang['grade'].level >= k.AllowedRank then
			lib.registerContext({
				id = 'GangInventory',
				title = 'Gang Lockers!',
				options = {
					{
						title = 'Open Gang Locker',
						description = 'Open Gang Locker',
						arrow = true,
						event = 'SickEvidence:OpenGangLocker',
						onSelect = function()
							OpenGangLocker(k.gang)
						end
					},
					{
						title = 'Open Personal Gang Locker',
						description = 'Open Personal Gang Locker',
						arrow = true,
						event = 'SickEvidence:OpenPersonalGangLocker',
						onSelect = function()
							OpenPersonalGangLocker()
						end
					}
				},
			})
			lib.showContext('GangInventory')
		elseif Config.PoliceJobs[Player.job.name] then
			lib.registerContext({
				id = 'PoliceRaidInventory',
				title = 'Gang Lockers!',
				options = {
					{
						title = 'Open Gang Locker',
						description = 'Open Gang Locker',
						arrow = true,
						event = 'SickEvidence:OpenGangLocker',
						onSelect = function()
							OpenGangLocker(k.gang)
						end
					}
				},
			})
			lib.showContext('PoliceRaidInventory')
		end
	end
end)


if Config.Framework == 'QBCore' then
	for k,v in pairs(Config.GangLocations) do
		if Config.Target == 'ox_target' then
			exports[Config.Target]:addBoxZone({
				coords = vector3(v.coords.x,v.coords.y,v.coords.z),
				size = v.size,
				rotation = v.rotation,
				debug = false,
				options = {
					{
						name = 'gang_locker',
						icon = 'fa-solid fa-cube',
						label = v.TargetLabel,
						canInteract = function(entity, distance, coords, name)
							--if isGang(v.gang) then
								return isGang(v.gang)
							--end
						end,
						onSelect = function()
							TriggerEvent('SickLockers:OpenGangLocker', v)
						end
					},
					--[[{
						name = 'evidence_heist',
						icon = 'fa-solid fa-cube',
						label = 'Hack Evidence',
						canInteract = function(entity, distance, coords, name)
							local isHeist = exports.SickLibs:IsInHeist()
							if isHeist and Config.SickDirtyCopsHeist and v.cop then
								return true
							end
						end,
						onSelect = function()
							TriggerEvent('SickLockers:OpenGangLocker', true)
						end
					}]]
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
                    	event = 'SickLockers:OpenGangLocker',
                    	icon = 'fas fa-door-open',
                    	label = v.TargetLabel,
                    },
                },
				job = {v.job},
                distance = 2.5
            })
		elseif Config.Target == 'qb-target' then
			break
		end
	end
end

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
				--[[{
					name = 'evidence_heist',
					icon = 'fa-solid fa-cube',
					label = 'Hack Evidence',
					canInteract = function(entity, distance, coords, name)
						local isHeist = exports.SickLibs:IsInHeist()
						if isHeist and Config.SickDirtyCopsHeist and v.cop then
							return true
						end
					end,
					onSelect = function()
						TriggerEvent('SickEvidence:openInventory', true)
					end
				}]]
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
		break
	end
end

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


--[[lib.registerContext({
	id = 'openHeistInv',
	title = 'Evidence Lockers!',
	options = {
		{
			title = 'Open Evidence',
			description = 'Open Evidence Locker',
			arrow = true,
			event = 'SickEvidence:OpenHeistMenu',
		}
	},
})]] -- COMING SOON

RegisterNetEvent('SickEvidence:openInventory')
AddEventHandler('SickEvidence:openInventory',function(isHeist)
	refreshjob()
	if Config.Framework == 'ESX' then
		for k,v in pairs(Config.location) do
			if v.cop == true and v.job == PlayerData.job.name and PlayerData.job.grade >= v.AllowedRank then
				lib.showContext('chiefmenu')
			elseif v.cop == true and v.job == PlayerData.job.name then
				lib.showContext('openInventory')
			elseif v.cop == false and v.job == PlayerData.job.name then
				lib.showContext('other_lockers')
			--[[elseif isHeist then
				lib.showContext('openHeistInv')]]
			end
		end
	elseif Config.Framework == 'QBCore' then
		for k,v in pairs(Config.location) do
			if v.cop == true and v.job == PlayerData.job.name and PlayerData.job.grade.level >= v.AllowedRank then
				lib.showContext('chiefmenu')
			elseif v.cop == true and v.job == PlayerData.job.name then
				lib.showContext('openInventory')
			elseif v.cop == false and v.job == PlayerData.job.name then
				lib.showContext('other_lockers')
			--[[elseif isHeist then
				lib.showContext('openHeistInv')]]
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
			--TriggerServerEvent('SickEvidence:loadStashes', evidenceID)
			Wait(1000)
			ox_inventory:openInventory('Stash', evidenceID)
		elseif Config.inventory == 'qb' then
			TriggerServerEvent('SickLockers:OpenInvQB', evidenceID)
		end
	end
end)

--[[RegisterNetEvent('SickEvidence:OpenHeistMenu')
AddEventHandler('SickEvidence:OpenHeistMenu', function()
	local input = lib.inputDialog('LSPD Evidence', {'Incident Number (#...)'})

	if not input then
		lib.hideContext(false)
		return
	end
	local evidenceID = ("Case: "..input[1]) --("Case :"..input[1]) -- if you have issues when updating.. changed format cause it just looks better
	print(evidenceID)
	local exists = lib.callback.await('SickEvidence:getInventory', 1000, evidenceID)
	print(exists)
	if not exists then
		exports.SickLibs:ClientNotify(3, "No Evidence with that Number! Try Again or get better info!")
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
			},
		})
		lib.showContext('evidenceOption')
	end
end)]] -- COMING SOON

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
		if Config.inventory == 'qb' or Config.inventory == 'qs' then
			TriggerServerEvent('SickLockers:OpenInvQB', evidenceID)
		elseif Config.inventory == 'ox' then
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
	end
end)

RegisterNetEvent('SickEvidence:evidenceOptions')
AddEventHandler('SickEvidence:evidenceOptions', function(args)
	if args.selection == "delete" then
		local evidenceID = args.inventory
		TriggerServerEvent("SickEvidence:deleteEvidence", evidenceID)
		Notify(1, "Lockers", "Deleted Evidence!")
		--exports.SickLibs:ClientNotify(1, "Lockers", "Deleted Evidence!")
	elseif args.selection == "open" then
		local evidenceID = args.inventory
		TriggerServerEvent('SickEvidence:loadStashes', evidenceID)
		Wait(1000)
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
	    ox_inventory:openInventory('Stash', lockerID)
	end
end)

local function lockerOption(lockerID)
	if Config.inventory == 'qb' then
		TriggerServerEvent('SickLockers:OpenInvQB', lockerID)
	elseif Config.inventory == 'ox' then
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
end

RegisterNetEvent('SickEvidence:lockerOptions')
AddEventHandler('SickEvidence:lockerOptions', function(args)
	if args.selection == "delete" then
		local lockerID = args.inventory
		TriggerServerEvent("SickEvidence:deleteLocker", lockerID)
		--exports.SickLibs:ClientNotify(1, "Lockers", "Deleted Locker!")
	elseif args.selection == "open" then
		local lockerID = args.inventory
		TriggerServerEvent('SickEvidence:loadStashes', lockerID)
		Wait(1000)
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
				if Config.inventory == 'qb' then
					TriggerServerEvent('SickLockers:OpenInvQB', lockerID)
				elseif Config.inventory == 'ox' then
					Core.Functions.TriggerCallback('SickEvidence:getLocker', function(locker)
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
				end
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
		if Config.inventory == 'qb' then
			TriggerServerEvent('SickLockers:OpenInvQB', lockerID)
		elseif Config.inventory == 'ox' then
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
		Core.TriggerServerCallback('SickEvidence:getLocker', function(exists)
			if exists then
				lockerOption(ID)
			else
				Notify(3, "Lockers", string.format('No Lockers with name: '..ID))
			end
		end, ID)
	elseif Config.Framework == 'QBCore' then
		Core.Functions.TriggerCallback('SickEvidence:getLocker', function(exists)
			if exists then
				lockerOption(ID)
			else
				Notify(3, "Lockers", string.format('No Lockers with name: '..ID))
			end
		end, ID)
	end
end)

RegisterNetEvent('SickEvidence:ChieflockerOptions')
AddEventHandler('SickEvidence:ChieflockerOptions', function(args)
	if args.selection == "delete" then
		local lockerID = args.inventory
		TriggerServerEvent("SickEvidence:deleteLocker", lockerID)
		exports.SickLibs:ClientNotify(1, "lockers", "Deleted Locker!")
	elseif args.selection == "open" then
		local lockerID = args.inventory
		TriggerServerEvent('SickEvidence:loadStashes', lockerID)
		Wait(1000)
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
		exports.SickLibs:ClientNotify(1, "Lockers", "Deleted Locker!")
	elseif args.selection == "open" then
		local OtherlockerID = args.inventory
		TriggerServerEvent('SickEvidence:loadStashes', OtherlockerID)
		Wait(1000)
	    ox_inventory:openInventory('Stash', OtherlockerID)
	end
end)

RegisterNetEvent('SickEvidence:OtherlockerCallbackEvent')
AddEventHandler('SickEvidence:OtherlockerCallbackEvent', function()
	if Config.Framework == 'ESX' then
		Core.TriggerServerCallback('SickEvidence:getPlayerName', function(data)
			if data then
				local OtherlockerID = (PlayerData.job.name.. ": " ..data.firstname.." "..data.lastname)
				Core.TriggerServerCallback('SickEvidence:getOtherInventories', function(Otherlocker)
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
				end, OtherlockerID)
			else
				Notify(3, "Lockers", "Info can\'t be found!")
			end
		end)
	elseif Config.Framework == 'QBCore' then
		Core.Functions.TriggerCallback('SickEvidence:getPlayerName', function(data)
			if data then
				local OtherlockerID = (PlayerData.job.name.. ": " ..data.firstname.." "..data.lastname)
				if Config.inventory == 'qb' then
					TriggerServerEvent('SickLockers:OpenInvQB', OtherlockerID)
				elseif Config.inventory == 'ox' then
					Core.Functions.TriggerCallback('SickEvidence:getOtherInventories', function(Otherlocker)
						print(Otherlocker)
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
										serverEvent = 'SickEvidence:deleteLocker',
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
					end, OtherlockerID)
				end
			else
				Notify(3, "Lockers", "Info can\'t be found!")
			end
		end)
	end
end)

RegisterNetEvent('SickEvidence:confirmorcancelOthers')
AddEventHandler('SickEvidence:confirmorcancelOthers', function(args)
	if args.selection == "confirm" then
		local OtherlockerID = args.inventory
		TriggerServerEvent("SickEvidence:createOtherLocker", OtherlockerID)
		TriggerServerEvent('SickEvidence:loadStashes', OtherlockerID)
		Wait(1000)
	    ox_inventory:openInventory('Stash', OtherlockerID)
	end
end)
