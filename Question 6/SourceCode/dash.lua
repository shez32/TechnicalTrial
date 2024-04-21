-- Define the maximum number of tiles a creature can dash through
local dashTileLimit = 10

-- Define a table of unwanted tile states for dashing
local unwanted_tilestates = { 
	TILESTATE_PROTECTIONZONE, 	-- Areas where dashing is restricted
	TILESTATE_HOUSE,			-- Cannot dash inside houses 		
	TILESTATE_FLOORCHANGE, 		-- Cannot dash through floor transitions
	TILESTATE_TELEPORT, 		-- Cannot dash through teleport locations
	TILESTATE_BLOCKSOLID, 		-- Cannot dash through solid objects
	TILESTATE_BLOCKPATH 		-- Cannot dash through path-blocking objects
}

-- Handles casting the dash spell by a creature
function onCastSpell(creature, variant, isHotkey)
	-- Get the creature's nextTilerent position and direction
	local position = creature:getPosition()
	local direction = creature:getDirection()

	
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
		else
			-- Break the loop if encountering an invalid tile (e.g., out of bounds)
			break
		end
	end
	-- Return true to indicate successful dash execution (or early cancellation)
    return true
end