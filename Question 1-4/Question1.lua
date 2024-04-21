-- Define the delay before releasing storage on logout
local releaseDelay = 1000

local function releaseStorage(playerID)
	--create Player object from the playerID
	--It will either create a valid Player object or it will return "nil"
	local player = Player(playerID)
	--If the player object exists (i.e the playerID was valid)
	if player then 
		--Player Object exists, therefore we can safely execute the following  code:
		player:setStorageValue(1000, -1)
	else
		-- Player object is nil, handle potential error 
		print("Failed to release storage for player:", playerId)
	end
end

function onLogout(player)
	if player:getStorageValue(1000) == 1 then
		--Pass the playerID instead of the player Object
		--passing the player object would prove problematic as there is a chance that it could be deleted causing a server crash when running the code
		addEvent(releaseStorage, releaseDelay, player.getId())
	end
return true
end