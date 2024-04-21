-- Define the maximum number of tiles a creature can dash through
local dashTileLimit = 10

-- Name of the creature type used for the temporary clone effect
local summonName = "Wolf" -- Or any desired creature type (currently using wolf)

-- Define a table of unwanted tile states for dashing
local unwanted_tilestates = { 
	TILESTATE_PROTECTIONZONE, 	-- Areas where dashing is restricted
	TILESTATE_HOUSE,			-- Cannot dash inside houses 		
	TILESTATE_FLOORCHANGE, 		-- Cannot dash through floor transitions
	TILESTATE_TELEPORT, 		-- Cannot dash through teleport locations
	TILESTATE_BLOCKSOLID, 		-- Cannot dash through solid objects
	TILESTATE_BLOCKPATH 		-- Cannot dash through path-blocking objects
}

-- Function to calculate the new position for the clone based on player direction
local function calculatePosition(playerDirection, playerPos)
	-- if Player is facing North, get the position behind the player
    if playerDirection == 0 then
         return Position(playerPos.x, playerPos.y + 1, playerPos.z)
		 
	-- if Player is facing West, get the position behind the player
    elseif playerDirection == 1 then
         return Position(playerPos.x - 1, playerPos.y, playerPos.z)
	
	-- if Player is facing South, get the position behind the player
    elseif playerDirection == 2 then
         return Position(playerPos.x, playerPos.y - 1, playerPos.z)

	-- if Player is facing East, get the position behind the player
    elseif playerDirection == 3 then
         return Position(playerPos.x + 1, playerPos.y, playerPos.z)
    end
end

-- Function to schedule the removal of a creature after a delay
function delayedRemove(creatureID)
	doRemoveCreature(creatureID)
end

-- Function to create a temporary clone and handle its removal
function onCastClone(creature, var)
	
	-- Get the player's position and direction
    local creaturePosition = creature:getPosition()
	local creatureDirection = creature:getDirection()
	
    -- Create a temporary clone creature of the same type   
	local summon = Game.createMonster(summonName, creaturePosition, false, false, CONST_ME_NONE)
    
	-- Set the clone's master to the player    
	summon:setMaster(creature)
	
	-- Copy the player's outfit to the clone
	local outfit = summon:getOutfit()
	local playerOutfit = creature:getOutfit()
	outfit.lookType = playerOutfit.lookType
	outfit.lookHead = playerOutfit.lookHead
	outfit.lookBody = playerOutfit.lookBody
	outfit.lookLegs = playerOutfit.lookLegs
	outfit.lookFeet = playerOutfit.lookFeet
	summon:setOutfit(outfit)
     
	-- Calculate a slightly offset position behind the player based on direction
	local offsetPos = calculatePosition(creatureDirection, creaturePosition)

	-- Teleport the clone to the offset position and set its direction to the direction the player is facing
	summon:teleportTo(offsetPos, true)
	summon:setDirection(creatureDirection)

	-- Schedule the removal of the clone creature after a 0.4 second delay
	addEvent(doRemoveCreature, 400, summon:getId())
end


-- Handles casting the dash spell by a creature
function onCastSpell(creature, variant, isHotkey)
	-- Get the player's position and direction
	local position = creature:getPosition()
	local direction = creature:getDirection()

	-- Get the tile object at the next position
	local nextTile = position
	local tile = Tile(nextTile)

	-- Loop through each potential dash tile
	for i = 1, dashTileLimit do
		-- Calculate the next tile position based on direction and increment
		nextTile  = {
			x = position.x + (direction == 1 and i or direction == 3 and -i or 0), 
			y = position.y + (direction == 0 and -i or direction == 2 and i or 0), 
			z = position.z
		}
		
		-- Get the tile object at the next position
		tile = Tile(nextTile)
		
		-- Check for unwanted tile states that would block dashing
		for _, tilestate in pairs(unwanted_tilestates) do
			if tile:hasFlag(tilestate) then
				creature:sendCancelMessage("You can't dash any further.")
				return false	-- Cancel the dash if encountering unwanted state
			end
		end
		
		-- If the tile is valid (not nil)
		if tile ~= nil then
			-- Teleport the creature to the next tile
			creature:teleportTo(nextTile, true)
			
			-- Trigger a ground shaker visual effect on the destination tile
			creature:getPosition():sendMagicEffect(CONST_ME_GROUNDSHAKER)
			onCastClone(creature, variant)
		else
			-- Break the loop if encountering an invalid tile (e.g., out of bounds)
			break
		end
	end
	-- Return true to indicate successful dash execution (or early cancellation)
    return true
end