local QBCore = exports['qb-core']:GetCoreObject()
Citizen.CreateThread(function()

    Wait(1000)
    TriggerServerEvent("lpsystem:FetchFeedbackTable", GetSourceId())
end)


function GetSourceId() 
    local playersource = GetPlayerServerId(PlayerId())
    return playersource
end

local oneSync = false
local FeedbackTable = {}
local canFeedback = true
local timeLeft = Config.FeedbackCooldown


RegisterCommand(Config.FeedbackClientCommand, function(source, args, rawCommand)
	if canFeedback then
		FeedbackMenu(false)
	else
		--antispam notifikasi
	end
end, false)


RegisterNetEvent('lpsystem:elpe')
AddEventHandler('lpsystem:elpe', function(source, args, rawCommand)
	FeedbackMenu(true)
end)


function FeedbackMenu(showAdminMenu)
	SetNuiFocus(true, true)
	if showAdminMenu then
		SendNUIMessage({
			action = "updateFeedback",
			FeedbackTable = FeedbackTable
		})
		SendNUIMessage({
			action = "OpenAdminFeedback",
		})
	else
		SendNUIMessage({
			action = "ClientFeedback",
		})
	end
end


RegisterNetEvent('lpsystem:NewFeedback')
AddEventHandler('lpsystem:NewFeedback', function(newFeedback)
		FeedbackTable[#FeedbackTable+1] = newFeedback

		SendNUIMessage({
			action = "updateFeedback",
			FeedbackTable = FeedbackTable
		})
end)

RegisterNetEvent('lpsystem:FetchFeedbackTable')
AddEventHandler('lpsystem:FetchFeedbackTable', function(feedback, oneS)
	FeedbackTable = feedback
	oneSync = oneS
end)

RegisterNetEvent('lpsystem:FeedbackConclude')
AddEventHandler('lpsystem:FeedbackConclude', function(feedbackID, info)
	local feedbackid = FeedbackTable[feedbackID]
	feedbackid.concluded = info

	SendNUIMessage({
		action = "updateFeedback",
		FeedbackTable = FeedbackTable
	})
end)


RegisterNUICallback("action", function(data)
	if data.action ~= "concludeFeedback" then
		SetNuiFocus(false, false)
	end

	if data.action == "newFeedback" then
		QBCore.Functions.Notify('Report poslat adminima!', 'success')
		
		local feedbackInfo = {subject = data.subject, information = data.information, category = data.category}
		TriggerServerEvent("lpsystem:NewFeedback", feedbackInfo)

		local time = Config.FeedbackCooldown * 60
		local pastTime = 0
		canFeedback = false

		while (time > pastTime) do
			Citizen.Wait(1000)
			pastTime = pastTime + 1
			timeLeft = time - pastTime
		end
		canFeedback = true
	elseif data.action == "assistFeedback" then
		if FeedbackTable[data.feedbackid] then
			if oneSync then
				TriggerServerEvent("lpsystem:AssistFeedback", data.feedbackid, true)
			else
				local playerFeedbackID = FeedbackTable[data.feedbackid].playerid
				local playerID = GetPlayerFromServerId(playerFeedbackID)
				local playerOnline = NetworkIsPlayerActive(playerID)
				if playerOnline then
					SetEntityCoords(PlayerPedId(), GetEntityCoords(GetPlayerPed(GetPlayerFromServerId(playerFeedbackID))))
					TriggerServerEvent("lpsystem:AssistFeedback", data.feedbackid, true)
				else
					-- Player sedang tidak ada di server
				end
			end
		end
	elseif data.action == "concludeFeedback" then
		local feedbackID = data.feedbackid
		local canConclude = data.canConclude
		local feedbackInfo = FeedbackTable[feedbackID]
		if feedbackInfo then
			if feedbackInfo.concluded ~= true or canConclude then
				TriggerServerEvent("lpsystem:FeedbackConclude", feedbackID, canConclude)
			end
		end
	end
end)