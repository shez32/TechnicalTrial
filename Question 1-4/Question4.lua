void Game::addItemToPlayer(const std::string& recipient, uint16_t itemId)
{
	// Try to get the player by name
	Player* player = g_game.getPlayerByName(recipient);
	
	// Keep track of whether we created a new player
	bool createdNewPlayer = false; 
	
	// If the player doesn't exist, create a new one and attempt to load data
	if (!player) {
		player = new Player(nullptr);	// Create a new player
		createdNewPlayer = true;		// Set the flag to indicate we created a new player
		
		// Try to load player data; if it fails, delete the player to avoid memory leak
		if (!IOLoginData::loadPlayerByName(player, recipient)) {
			delete player;  			// Proper cleanup in case of failure
			return;						// Exit if player loading fails
		}
	}

	// Create the item to add to the player's inbox
	Item* item = Item::CreateItem(itemId);
	
	 // If item creation fails, clean up newly created player, if any
	if (!item) {
		if (createdNewPlayer) {
            delete player;  			// Cleanup if the item creation failed and we created a new player
        }
		
		return;							// Exit if item creation fails
	}

	// Add the item to the player's inbox
	g_game.internalAddItem(player->getInbox(), item, INDEX_WHEREEVER, FLAG_NOLIMIT);

	// If the player is offline, save their data
	if (player->isOffline()) {
		IOLoginData::savePlayer(player);
		
		// If we created a new player, clean up after saving
		if (createdNewPlayer) {
            delete player;  			// Avoid memory leak
        }
    }   
	else if (createdNewPlayer) {
        delete player;  				// If we created a new player but they're online, clean up after adding the item
    }
}