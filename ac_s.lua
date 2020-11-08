--Hiermit können Sie bestimmte THAC-Komponenten ein- und ausschalten. Hinweis: Sie können diese auch deaktivieren, während das Skript mithilfe von Ereignissen ausgeführt wird. Beispiele hierfür finden Sie weiter unten
Components = {
	Teleport = true,
	GodMode = true,
	Speedhack = true,
	WeaponBlacklist = true,
	CustomFlag = true,
	Explosions = true,
}

--[[
event beispiele:

thac:SetComponentStatus( component, state )
	aktiviert oder deaktiviert spezielle Komponenten
		komponenten:
			Teleport
			GodMode
			Speedhack
			WeaponBlacklist
			CustomFlag
			Explosions

thac:SetAllComponents( true oder false )
	aktiviert oder deaktiviert **alle** Komponenten


Beispiel Event:
	TriggerEvent("thac:SetComponentStatus", "Teleport", false)

Die Evente können nicht von einem Client ausgeführt werden!

]]


Users = {}
violations = {}


recentExplosions = {}



RegisterServerEvent("thac:timer")
AddEventHandler("thac:timer", function()
	if Users[source] then
		if (os.time() - Users[source]) < 15 and Components.Speedhack then -- Verhindert, dass der Spieler einen guten alten Speedhack für Cheat-Motoren ausführt hehe
			DropPlayer(source, "Speedhacking")
		else
			Users[source] = os.time()
		end
	else
		Users[source] = os.time()
	end
end)

AddEventHandler('playerDropped', function()
	if(Users[source])then
		Users[source] = nil
	end
end)

RegisterServerEvent("thac:kick")
AddEventHandler("thac:kick", function(reason)
	DropPlayer(source, reason)
end)

AddEventHandler("thac:SetComponentStatus", function(component, state)
	if type(component) == "string" and type(state) == "boolean" then
		Components[component] = state -- ändert die Komponente in den gewünschten Status
	end
end)

AddEventHandler("thac:ToggleComponent", function(component)
	if type(component) == "string" then
		Components[component] = not Components[component]
	end
end)

AddEventHandler("thac:SetAllComponents", function(state)
	if type(state) == "boolean" then
		for i,theComponent in pairs(Components) do
			Components[i] = state
		end
	end
end)

Citizen.CreateThread(function()
	while true do 
		Wait(2000)
		clientExplosionCount = {}
		for i, expl in ipairs(recentExplosions) do 
			if not clientExplosionCount[expl.sender] then clientExplosionCount[expl.sender] = 0 end
			clientExplosionCount[expl.sender] = clientExplosionCount[expl.sender]+1
			table.remove(recentExplosions,i)
		end 
		recentExplosions = {}
		for c, count in pairs(clientExplosionCount) do 
			if count > 20 then
				local license, steam = GetPlayerNeededIdentifiers(c)
				local name = GetPlayerName(c)

				local isKnown, isKnownCount, isKnownExtraText = WarnPlayer(name,"Explosion Spawning", true, c)

				SendWebhookMessage(webhook, "**Explosion Spawner!** \n```\nSpieler:"..name.."\n"..license.."\n"..steam.."\nGespawnt "..count.." Explosionen in <2s. \nthac Flags:"..isKnownCount..""..isKnownExtraText.." ```")
			end
		end
	end
end)

Citizen.CreateThread(function()

	function SendWebhookMessage(wh,message)
		webhook = GetConvar("ac_webhook", "none")
		if wh ~= "none" then
			PerformHttpRequest(wh, function(err, text, headers) end, 'POST', json.encode({content = message}), { ['Content-Type'] = 'application/json' })
		end
	end
	
	function WarnPlayer(playername, reason,banInstantly,pid)
		local isKnown = false
		local isKnownCount = 1
		local isKnownExtraText = ""
		for i,thePlayer in ipairs(violations) do
			if thePlayer.name == playername then
				isKnown = true
				if banInstantly then
					TriggerEvent("banCheater", pid or source,"Cheating")
					isKnownCount = violations[i].count
					table.remove(violations,i)
					isKnownExtraText = ", wurde direkt gebannt."
				else
					if violations[i].count == 1 then
						TriggerEvent("EasyAdmin:TakeScreenshot", source)
					end
					if violations[i].count == 3 then
						TriggerEvent("banCheater", pid or source,"Cheating")
						isKnownCount = violations[i].count
						table.remove(violations,i)
						isKnownExtraText = ", wurde gebannt."
					else
						violations[i].count = violations[i].count+1
						isKnownCount = violations[i].count
					end
				end
			end
		end

		if not isKnown then
			if banInstantly then
				TriggerEvent("banCheater", pid or source,"Cheating")
				isKnownExtraText = ", wurde direkt gebannt."
			else
				table.insert(violations, { name = playername, count = 1 })
			end
		end

		return isKnown, isKnownCount,isKnownExtraText
	end

	function GetPlayerNeededIdentifiers(player)
		local ids = GetPlayerIdentifiers(player)
		for i,theIdentifier in ipairs(ids) do
			if string.find(theIdentifier,"license:") or -1 > -1 then
				license = theIdentifier
			elseif string.find(theIdentifier,"steam:") or -1 > -1 then
				steam = theIdentifier
			end
		end
		if not steam then
			steam = "steam: missing"
		end
		return license, steam
	end

	RegisterServerEvent('thac:SpeedFlag')
	AddEventHandler('thac:SpeedFlag', function(rounds, roundm)
		if Components.Speedhack and not IsPlayerAceAllowed(source,"thac.bypass") then
			local license, steam = GetPlayerNeededIdentifiers(source)
			local name = GetPlayerName(source)

			local isKnown, isKnownCount, isKnownExtraText = WarnPlayer(name,"Speed Hacking")

			SendWebhookMessage(webhook, "**Speed Hacker!** \n```\nSpieler:"..name.."\n"..license.."\n"..steam.."\nWar unterwegs "..rounds.. " einheiten. Das sind "..roundm.." mehr als normal! \nthac Flags:"..isKnownCount..""..isKnownExtraText.." ```")
		end
	end)



	RegisterServerEvent('thac:NoclipFlag')
	AddEventHandler('thac:NoclipFlag', function(distance)
		if Components.Speedhack and not IsPlayerAceAllowed(source,"thac.bypass") then
			local license, steam = GetPlayerNeededIdentifiers(source)
			local name = GetPlayerName(source)

			local isKnown, isKnownCount, isKnownExtraText = WarnPlayer(name,"Noclip/Teleport Hacking")


			SendWebhookMessage(webhook,"**Noclip/Teleport!** \n```\nSpieler:"..name.."\n"..license.."\n"..steam.."\nGefangen mit "..distance.." Einheiten zwischen dem zuletzt überprüften Ort\nthac Flags:"..isKnownCount..""..isKnownExtraText.." ```")
		end
	end)

	
	
	RegisterServerEvent('thac:CustomFlag')
	AddEventHandler('thac:CustomFlag', function(reason,extrainfo)
		if Components.CustomFlag and not IsPlayerAceAllowed(source,"thac.bypass") then
			local license, steam = GetPlayerNeededIdentifiers(source)
			local name = GetPlayerName(source)
			if not extrainfo then extrainfo = "Keine Informationen angegeben!" end
			local isKnown, isKnownCount, isKnownExtraText = WarnPlayer(name,reason)


			SendWebhookMessage(webhook,"**"..reason.."** \n```\nSpieler:"..name.."\n"..license.."\n"..steam.."\n"..extrainfo.."\nthac Flags:"..isKnownCount..""..isKnownExtraText.." ```")
		end
	end)

	RegisterServerEvent('thac:HealthFlag')
	AddEventHandler('thac:HealthFlag', function(invincible,oldHealth, newHealth, curWait)
		if Components.GodMode and not IsPlayerAceAllowed(source,"thac.bypass") then
			local license, steam = GetPlayerNeededIdentifiers(source)
			local name = GetPlayerName(source)

			local isKnown, isKnownCount, isKnownExtraText = WarnPlayer(name,"Health Hacking")

			if invincible then
				SendWebhookMessage(webhook,"**Heil Hack!** \n```\nSpieler:"..name.."\n"..license.."\n"..steam.."\nRegenerierte "..newHealth-oldHealth.."hp ( erreicht "..newHealth.."hp ) in "..curWait.."millisekunden! ( PlayerPed ist unsichtbar )\nthac Flags:"..isKnownCount..""..isKnownExtraText.." ```")
			else
				SendWebhookMessage(webhook,"**Heil Hack!** \n```\nSpieler:"..name.."\n"..license.."\n"..steam.."\nRegenerierte "..newHealth-oldHealth.."hp ( erreicht "..newHealth.."hp ) in "..curWait.."millisekunden! ( Heilung wurde erzwungen )\nthac Flags:"..isKnownCount..""..isKnownExtraText.." ```")
			end
		end
	end)

	RegisterServerEvent('thac:JumpFlag')
	AddEventHandler('thac:JumpFlag', function(jumplength)
		if Components.SuperJump and not IsPlayerAceAllowed(source,"thac.bypass") then
			local license, steam = GetPlayerNeededIdentifiers(source)
			local name = GetPlayerName(source)

			local isKnown, isKnownCount, isKnownExtraText = WarnPlayer(name,"SuperJump Hacking")

			SendWebhookMessage(webhook,"**SuperSprung Hack!** \n```\nSpieler:"..name.."\n"..license.."\n"..steam.."\nSpringt "..jumplength.."millisekunden lang\nthac Flags:"..isKnownCount..""..isKnownExtraText.." ```")
		end
	end)

	RegisterServerEvent('thac:WeaponFlag')
	AddEventHandler('thac:WeaponFlag', function(weapon)
		if Components.WeaponBlacklist and not IsPlayerAceAllowed(source,"thac.bypass") then
			local license, steam = GetPlayerNeededIdentifiers(source)
			local name = GetPlayerName(source)

			local isKnown, isKnownCount, isKnownExtraText = WarnPlayer(name,"Inventory Cheating")

			SendWebhookMessage(webhook,"**Inventar Hack!** \n```\nSpieler:"..name.."\n"..license.."\n"..steam.."\nBekommt Waffe: "..weapon.."( Blacklisted )\nthac Flags:"..isKnownCount..""..isKnownExtraText.." ```")
			TriggerClientEvent("thac:RemoveInventoryWeapons", source) 
		end
	end)

	AddEventHandler('explosionEvent', function(sender, ev)
		if Components.Explosions and ev.damageScale ~= 0.0 and ev.ownerNetId == 0 then -- Stellt sicher, dass die Komponente aktiviert ist, der Schaden nicht 0 ist und der Eigentümer der Absender ist
			ev.time = os.time()
			table.insert(recentExplosions, {sender = sender, data=ev})
		end
	end)
end)

local verFile = LoadResourceFile(GetCurrentResourceName(), "version.json")
local curVersion = json.decode(verFile).version
Citizen.CreateThread( function()
	local updatePath = "/WeLoveJavaScript/TH-AC"
	local resourceName = "thac ("..GetCurrentResourceName()..")"
	PerformHttpRequest("https://raw.githubusercontent.com"..updatePath.."/master/version.json", function(err, response, headers)
		local data = json.decode(response)


		if curVersion ~= data.version and tonumber(curVersion) < tonumber(data.version) then
			print("\n--------------------------------------------------------------------------")
			print("\n"..resourceName.." ist outdated.\nAkuellste Version: "..data.version.."\nDeine Version: "..curVersion.."\nBitte update sie auf https://github.com"..updatePath.."")
			print("\nUpdate Changelog:\n"..data.changelog)
			print("\n--------------------------------------------------------------------------")
		elseif tonumber(curVersion) > tonumber(data.version) then
			print("Deine Version von "..resourceName.." scheint höher zu sein als die aktuelle Version.")
		else
			print(resourceName.." ist up to date!")
		end
	end, "GET", "", {version = 'this'})
end)
