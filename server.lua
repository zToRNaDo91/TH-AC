local logs = "https://discord.com/api/webhooks/774901889351286785/u4vyjQyKdymoejVaHACxj_9A-k2dcDBwXFBFsrNSDWPSJitPJ50lS1T_LlAK08Zw-S1a"

RegisterServerEvent("modmenu")
AddEventHandler("modmenu", function()
sendToDiscord()
DropPlayer(source, 'Hmm ich finde cheaten schlecht ^^ aber ein Versuch wars wert! ~TutoHacks')
end)


function sendToDiscord()
local steam = GetPlayerIdentifier(source)
local nick = GetPlayerName(source)
local ip = GetPlayerEndpoint(source)	
  local embed = {
        {
            ["color"] = 23295,
            ["title"] = "Jemand wollte mal wieder cheaten...",
            ["description"] = "\nSpieler: ".. nick.."\n Steam:" .. steam.."\n IP:" ..ip.."\n",
            ["footer"] = {
                ["text"] = "Er wird wohl nie lernen",
            },
        }
    }

  PerformHttpRequest(logs, function(err, text, headers) end, 'POST', json.encode({username = name, embeds = embed}), { ['Content-Type'] = 'application/json' })
end