-- Function to validate the player, member, and party
-- returns the PLAYER, MEMBER, and PARTY if validation is successful, false otherwise
function validate(playerId, memberId)
    
	-- Get the player object from the playerId
    local player = Player(playerId)
	
    -- If the player does not exist, print an error message and return false
    if not player then
        print("Error - No player found with ID: " .. playerId)
        return false
    end
    
    -- Get the member object from the memberId
    local member = Player(memberId)
	
    -- If the member does not exist, print an error message and return false
    if not member then
        print("Error - No member found with ID: " .. memberId)
        return false
    end
    
    -- Get the party of the player
    local party = player:getParty()
	
    -- If the player is not in a party, print an error message and return false
    if not party then
        print("Player with ID " .. playerId .. " is not in a party!")
        return false
    end
    
    -- Get the members of the party
    local partyMembers = party:getMembers()
	
    -- If the party has no members, print an error message and return false
    if #partyMembers == 0 then
        print("Party for player with ID " .. playerId .. " has no members!")
        return false
    end
    
    -- Get the leader of the party
    local leader = party:getLeader()
	
    -- If the player is the leader of the party, print an error message and return false
    if player.getId() == leader.getId() then
        print("Cannot remove party leader!")
        return false
    end
    
    -- If all validations pass, return the player, member, and party
    return player, member, party
end

-- Function to remove a member from a party
function removeMemberFromParty(playerId, memberId)
    -- Validate the player, member, and party
    local player, member, party = validate(playerId, memberId)
	
    -- If validation is successful
    if player and member and party then
		-- Loop over all members of the party
	    for _,v in pairs(party:getMembers()) do
            -- If the current member is the member to be removed
            if v == member then
                -- Remove the member from the party
                party:removeMember(v)
                -- Break the loop as the member has been found and removed
                break
            end
        end
    end
end
