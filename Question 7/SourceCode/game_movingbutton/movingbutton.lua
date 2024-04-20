-- Declare local variables to store the button movement event and the game window instance
local actionButtonMoveEvent = nil
local gameWindowInstance = nil

-- Declare the main module for the moving button game
MovingButtonModule = {}

-- Declare a local variable for the button movement increment
-- This value controls the speed of the button movement event
local buttonMoveIncrement = 1

-- Declare a local variable for the cycleEvent delay
-- This value controls tick rate of the button movement event
local deltaTick = 10

-- Initialize the UI Menu when the player logs in
function init()
  connect(g_game, { onLogin = MovingButtonModule.initializeGame,
  onGameEnd = MovingButtonModule.terminateGame })
end

-- Clean up UI when player logs out
function terminate()
  disconnect(g_game, { onLogin = MovingButtonModule.initializeGame,
                  onGameEnd = MovingButtonModule.terminateGame })
  removeEvent(actionButtonMoveEvent)
  MovingButtonModule.terminateGame()
  actionButtonMoveEvent = nil
end

-- Create the game window and start the button movement tick event
function MovingButtonModule.initializeGame()
  gameWindowInstance = g_ui.displayUI('movingbutton.otui')
  actionButton = gameWindowInstance:getChildById('actionButton')
  MovingButtonModule.startButtonMovement(true)
end

-- Destroy the game window and stop the button movement event
function MovingButtonModule.terminateGame()
  gameWindowInstance:destroy()
  MovingButtonModule.startButtonMovement(false)
end

-- Move the button to the left within boundaries of the Main Window
function MovingButtonModule.moveActionButton()
  -- If the button will not cross the boundary extents of the UI Menu, then it will move to the left
  if actionButton:getMarginRight() + actionButton:getWidth()* 1.75 < gameWindowInstance:getWidth()  then
    actionButton:setMarginRight(actionButton:getMarginRight() + buttonMoveIncrement)
  -- if the button exceeds the boundary extents of the UI Menu, then reset it back to a random position at the extreme right
  else
	 -- Reset the button if it goes out of bounds
    MovingButtonModule.resetGame()
  end
end

-- Reset the x position of the button to the corner and also set a random y position 
function MovingButtonModule.resetGame()
  actionButton:setMarginRight(0)
  actionButton:setMarginTop(math.random(0,gameWindowInstance:getHeight()-actionButton:getHeight()*3))
end

-- Clear previous event (if any) before creating a new one
function MovingButtonModule.ClearTick()
	if actionButtonMoveEvent ~= nil then
		removeEvent(actionButtonMoveEvent)
		actionButtonMoveEvent = nil
	end
	-- Reset the button position before starting the loop
	MovingButtonModule.resetGame()
end

-- This function turns on or off (based on bool input value) the cycleEvent that calls the moveGameButton() function
function MovingButtonModule.startButtonMovement(bool)
  -- Interrupts current event (if exists)
  MovingButtonModule.ClearTick()
  
  if bool then
	-- Create a new loop for moving the button
    actionButtonMoveEvent = cycleEvent(MovingButtonModule.moveActionButton, deltaTick) 
  end
end