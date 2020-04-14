ESX 			    			= nil
local callActive = false
local haveTarget = false
local isCall = false
local work = {}
local target = {}

Citizen.CreateThread(function()
	while ESX == nil do
		TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)
		Citizen.Wait(0)
	end
end)

Citizen.CreateThread(function()
    while true do
        Citizen.Wait(1)
        -- if IsControlJustPressed(1, 56) then
        --     local plyPos = GetEntityCoords(GetPlayerPed(-1), true)
        --     TriggerServerEvent("call:makeCall", "uber", {x=plyPos.x,y=plyPos.y,z=plyPos.z})
        -- end

        -- Press E key to get the call
        if IsControlJustPressed(1, 38) and callActive then
			if isCall == false then
				TriggerServerEvent("call:getCall", work)
				SendNotification("~b~Vous avez pris l'appel !")
				target.blip = AddBlipForCoord(target.pos.x, target.pos.y, target.pos.z)
				SetBlipRoute(target.blip, true)
				haveTarget = true
				isCall = true
				callActive = false
			else
				SendNotification("~r~Vous avez déjà un appel en cours !")
			end
        -- Press Y key to decline the call
        elseif IsControlJustPressed(1, 246) and callActive then
            SendNotification("~r~Vous avez refusé l'appel.")
            callActive = false
        end
        if haveTarget then
            DrawMarker(1, target.pos.x, target.pos.y, target.pos.z-1, 0, 0, 0, 0, 0, 0, 2.001, 2.0001, 0.5001, 255, 255, 255, 200, 0, 0, 0, 0)
            local playerPos = GetEntityCoords(GetPlayerPed(-1), true)
            if Vdist(target.pos.x, target.pos.y, target.pos.z, playerPos.x, playerPos.y, playerPos.z) < 2.0 then
                RemoveBlip(target.blip)
                haveTarget = false
				isCall = false
            end
        end
    end
end)

RegisterNetEvent("call:cancelCall")
AddEventHandler("call:cancelCall", function()
	if haveTarget then
		RemoveBlip(target.blip)
        haveTarget = false
		isCall = false
	else
		TriggerEvent("itinerance:notif", "~r~Vous n'avez aucun appel en cours !")
	end
end)

RegisterNetEvent("call:callIncoming")
AddEventHandler("call:callIncoming", function(job, pos, msg)
    callActive = true
    work = job
    target.pos = pos
	
	--print(json.encode(target.pos))
	coords = GetEntityCoords(GetPlayerPed(-1))
	dist = CalculateTravelDistanceBetweenPoints(coords.x,coords.y,coords.z,target.pos.x,target.pos.y,target.pos.z)
	streetname = GetStreetNameFromHashKey(GetStreetNameAtCoord(target.pos.x,target.pos.y,target.pos.z)) .. " ("..math.ceil(dist).."m)"
	
	if work == "police" then
	ESX.ShowAdvancedNotification('Centrale', '~b~Appel d\'urgence LSPD', '~b~Localisation: ~s~'.. streetname.. '\n~b~Raison:~s~ '.. msg..'', "CHAR_CALL911", 1)
	    SendNotification("Accepter: ~g~E~s~ ou ~r~Y~s~")
	    PlaySoundFrontend(-1, "Start_Squelch", "CB_RADIO_SFX", 0)
	elseif work == "sheriff" then
	ESX.ShowAdvancedNotification('Centrale', '~b~Appel d\'urgence BCSO', '~b~Localisation: ~s~'.. streetname.. '\n~b~Raison:~s~ '.. msg..'', "CHAR_MANUEL", 1)
	    SendNotification("Accepter: ~g~E~s~ ou ~r~Y~s~")
	    PlaySoundFrontend(-1, "Start_Squelch", "CB_RADIO_SFX", 0)
	elseif work == "mecano" then
		ESX.ShowAdvancedNotification('Centrale', '~b~Appel Central', '~b~Localisation: ~s~'.. streetname.. '\n~b~Raison:~s~ '.. msg..'', "CHAR_CARSITE3", 1)
		SendNotification("Accepter: ~g~E~s~ ou ~r~Y~s~")
	elseif work == "taxi" then
		ESX.ShowAdvancedNotification('Centrale', '~y~Appel Central D&C', '~y~Localisation: ~s~'.. streetname.. '\n~y~Raison:~s~ '.. msg..'', "CHAR_TAXI", 1)
		SendNotification("Accepter: ~g~E~s~ ou ~r~Y~s~")
	elseif work == "ambulance" then
		ESX.ShowAdvancedNotification('Centrale', '~r~Appel d\'urgence LSDH', '~r~Localisation: ~s~'.. streetname.. '\n~r~Raison:~s~ '.. msg..'', "CHAR_CALL911", 1)
		SendNotification("Accepter: ~g~E~s~ ou ~r~Y~s~")
		PlaySoundFrontend(-1, "Start_Squelch", "CB_RADIO_SFX", 0)
	elseif work == "fib" then
		ESX.ShowAdvancedNotification('Centrale', '~b~Appel d\'urgence: 913', '~b~Localisation: ~s~'.. streetname.. '\n~b~Raison:~s~ '.. msg..'', "CHAR_CALL911", 1)
		SendNotification("Accepter: ~g~E~s~ ou ~r~Y~s")
		PlaySoundFrontend(-1, "Start_Squelch", "CB_RADIO_SFX", 0)
	elseif work == "pilot" then
		SendNotification("~r~APPEL EN COURS:~w~ " ..tostring(msg))
	elseif work == "brinks" then
		ESX.ShowAdvancedNotification('Brinks', '~b~Appel Convoi', '~g~Localisation: ~s~'.. streetname.. '\n~g~Raison:~s~ '.. msg..'', "CHAR_CALL911", 1)
		SendNotification("Accepter: ~g~E~s~ ou ~r~Y~s")
	elseif work == "journaliste" then
		ESX.ShowAdvancedNotification('Weazel News', '~b~Information', '~b~Localisation: ~s~'.. streetname.. '\n~b~Raison:~s~ '.. msg..'', "CHAR_LIFEINVADER", 1)
		SendNotification("Accepter: ~g~E~s~ ou ~r~Y~s")
	end
	
end)

RegisterNetEvent("call:taken")
AddEventHandler("call:taken", function(a)
	callActive = false
    SendNotification("~b~L'appel a été pris par "..a)
end)

-- If player disconnect, remove him from the inService server table
AddEventHandler('playerDropped', function()
	TriggerServerEvent("player:serviceOff", nil)
end)

function SendNotification(message)
    SetNotificationTextEntry('STRING')
    AddTextComponentString(message)
    DrawNotification(false, false)
end

