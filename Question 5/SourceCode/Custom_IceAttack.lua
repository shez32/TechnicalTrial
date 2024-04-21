-- Define a combat object
local combat = Combat()

-- Set the combat area as a circle with a 5x5 radius (see SPELLS.LUA for definition)
-- This defines the area of effect for the spell's area combat attacks.
combat:setArea(createCombatArea(AREA_CIRCLE5X5))

-- Function triggered by the onTargetTile callback (assuming Creature(cid) validation)
-- This function is triggered by the game engine when a player casts a spell and the spell hits a valid tile.
function spellCallback(cid, position)
	-- If the creature with the provided ID exists
    if Creature(cid) then
		-- Define a table of functions for different attack patterns 
		-- This table defines various ways the spell can unleash its area attacks with different timing patterns.
		local case = {
			[1] = function() 
				-- Schedule two area combat attacks with a 1 second delay between them
				addEvent(FNDoAreaCombat, 1000, cid, position)
				addEvent(FNDoAreaCombat, 2000, cid, position)
			end,
				
			[2] = function() 
				-- Schedule two area combat attacks with a different delay pattern
				addEvent(FNDoAreaCombat, 1300, cid, position)
				addEvent(FNDoAreaCombat, 2300, cid, position)
			end,
			
			--... Add more attack patterns if needed
				
			[3] = function() 
				addEvent(FNDoAreaCombat, 1600, cid, position)
				addEvent(FNDoAreaCombat, 2600, cid, position)
			end,
				
			[4] = function() 
				addEvent(FNDoAreaCombat, 1900, cid, position)
				addEvent(FNDoAreaCombat, 2900, cid, position)
			end,
			
			-- Single area combat attack			
			[5] = function() 
				addEvent(FNDoAreaCombat, 2200, cid, position)
			end,
				
			[6] = function() 
				addEvent(FNDoAreaCombat, 2500, cid, position)
			end
		}
		
		-- Generate a random number between 1 and 6		
		local value = math.random(1,6)
		
		-- If a valid attack pattern exists for the random value
		if case[value] then
			-- Execute the chosen attack pattern function
			case[value]()
		end
    end
end

-- Function to perform an area combat attack
function FNDoAreaCombat(cid, position)
	-- Trigger a visual effect (ice tornado in this case) at the position
	position:sendMagicEffect(CONST_ME_ICETORNADO)
	
	-- Perform area combat damage
	doAreaCombat(cid, COMBAT_ICEDAMAGE, position, 0, -100, -100, CONST_NONE)
end

-- Function to handle callback when a the spell lands on a tile
function onTargetTile(creature, position)
	-- Trigger the spell callback function with the player's ID and position
    spellCallback(creature:getId(), position)
end

-- Set the combat object's callback for targeted tiles
combat:setCallback(CALLBACK_PARAM_TARGETTILE, "onTargetTile")

-- Function to handle spell casting with random delayed area attacks
function onCastSpell(creature, variant, isHotkey)
    return combat:execute(creature, variant)
end