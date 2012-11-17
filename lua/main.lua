
require 'mymoai'
require 'statemgr'

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
viewport:setSize ( screenWidth, screenHeight )

--viewport:setScale ( 640, 480 )
--viewport = setupViewport(COLS, ROWS, "test")

statemgr.push ( "StateMenu.lua" )
--statemgr.push ( "statesimple.lua" )
statemgr.begin()

--init()

--StateMenu:init()
--arcade()
--levels()
