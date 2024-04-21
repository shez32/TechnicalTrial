-- Function to print names of small guilds
function printSmallGuildNames(memberCount)
	-- SQL query to select guilds with less than memberCount members
	local selectGuildQuery = "SELECT name FROM guilds WHERE max_members < %d;"
	
	-- Execute the query and store the result
	local resultId = db.storeQuery(string.format(selectGuildQuery, memberCount))
	
	-- If the query was successful (resultId is not false)
	if resultId ~= false then
	
		-- Loop over the result set
		repeat
			-- Get the name of the current guild
			local guildName = result.getString(resultId, "name")
			
			-- Print the guild name
			print(guildName)
			
		-- Continue until there are no more rows in the result set	
		until not result.next(resultId)
		
		-- Free the result set
		result.free(resultId)
		
	else
		-- If the query failed, print an error message
		print("Failed to find any guilds with less than " .. memberCount .. " members.")
	end
end

