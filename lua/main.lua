
require 'mymoai'
require 'level'
require 'selectlevel'
require 'StateMenu'
require 'state-manager'

function onBackButtonPressed ()
	print ( "onBackButtonPressed: " )

    if #states == 0 then
    	return false
    end
    
    local callback = table.remove(states, #states)
    callback()

	-- Return true if you want to override the back button press and prevent the system from handling it.
    return true
end

local function arcade()
    table.insert(states, mainMenu)
    resetControl()
    Level:init()
end

local function levels()
    table.insert(states, mainMenu)
    resetControl()
    SelectLevel:init()
end

local function title()
    table.insert(states, mainMenu)
end

local function init()
    if MOAIApp ~= nil then
        -- android
        MOAIApp.setListener ( MOAIApp.BACK_BUTTON_PRESSED, onBackButtonPressed )
    end
end

local screenWidth = MOAIEnvironment.horizontalResolution
local screenHeight = MOAIEnvironment.verticalResolution
if screenWidth == nil then screenWidth = 800 end
if screenHeight == nil then screenHeight = 480 end

MOAISim.openWindow ("test", screenWidth, screenHeight)
viewport = MOAIViewport.new ()

--viewport = setupViewport(COLS, ROWS, "test")

statemgr.push ( "StateMenu.lua" )	
statemgr.begin()

--init()

--StateMenu:init()
--arcade()
--levels()
