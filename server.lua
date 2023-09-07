local oneSync = false

Citizen.CreateThread(function()
	if GetConvar("onesync") ~= 'off' then
		oneSync = true
	end
end)

local FeedbackTable = {}

RegisterNetEvent("lpsystem:NewFeedback")
AddEventHandler("lpsystem:NewFeedback", function(data)
	local newFeedback = {
		feedbackid = #FeedbackTable+1,
		playerid = source,
		subject = data.subject,
		information = data.information,
		category = data.category,
		concluded = false,
	}

	FeedbackTable[#FeedbackTable+1] = newFeedback

	TriggerClientEvent("lpsystem:NewFeedback", -1, newFeedback)
end)

RegisterNetEvent("lpsystem:FetchFeedbackTable")
AddEventHandler("lpsystem:FetchFeedbackTable", function()
		TriggerClientEvent("lpsystem:FetchFeedbackTable", source, FeedbackTable, staff, oneSync)
end)

RegisterNetEvent("lpsystem:AssistFeedback")
AddEventHandler("lpsystem:AssistFeedback", function(feedbackId, canAssist)
		if canAssist then
			local id = FeedbackTable[feedbackId].playerid
			if GetPlayerPing(id) > 0 then
				local ped = GetPlayerPed(id)
				local pedSource = GetPlayerPed(source)
				local playerCoords = GetEntityCoords(ped)
				local assistFeedback = {
					feedbackid = feedbackId,
				}

				SetEntityCoords(pedSource, playerCoords.x, playerCoords.y, playerCoords.z)
			else	
				QBCore.Functions.Notify(id, "Player tidak ada di server", 'error')
			end
			if not FeedbackTable[feedbackId].concluded then
				FeedbackTable[feedbackId].concluded = "assisting"
			end
			TriggerClientEvent("lpsystem:FeedbackConclude", -1, feedbackId, FeedbackTable[feedbackId].concluded)
		end
end)


RegisterNetEvent("lpsystem:FeedbackConclude")
AddEventHandler("lpsystem:FeedbackConclude", function(feedbackId, canConclude)
		local feedback = FeedbackTable[feedbackId]
		local concludeFeedback = {
			feedbackid = feedbackId,
		}

		if feedback then
			if feedback.concluded ~= true or canConclude then
				if canConclude then
					if FeedbackTable[feedbackId].concluded == true then
						FeedbackTable[feedbackId].concluded = false
					else
						FeedbackTable[feedbackId].concluded = true
					end
				else
					FeedbackTable[feedbackId].concluded = true
				end
				TriggerClientEvent("lpsystem:FeedbackConclude", -1, feedbackId, FeedbackTable[feedbackId].concluded)
			end
		end
end)