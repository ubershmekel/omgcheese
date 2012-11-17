
require 'mymoai'
require 'statemgr'

function onBackButtonPressed ()
	print ( "onBackButtonPressed: " )

    if statemgr.stackSize() == 1 then
    	return false
    end
    
    --local callback = table.remove(states, #states)
    --callback()
    statemgr.pop()

	-- Return true if you want to override the back button press and prevent the system from handling it.
    return true
end


screenWidth = MOAIEnvironment.horizontalResolution
screenHeight = MOAIEnvironment.verticalResolution
if screenWidth == nil then screenWidth = 800 end
if screenHeight == nil then screenHeight = 480 end

MOAISim.openWindow ("test", screenWidth, screenHeight)
viewport = MOAIViewport.new ()
viewport:setSize ( screenWidth, screenHeight )

--viewport:setScale ( 640, 480 )
--viewport = setupViewport(COLS, ROWS, "test")

if MOAIApp ~= nil then
    -- android
    MOAIApp.setListener ( MOAIApp.BACK_BUTTON_PRESSED, onBackButtonPressed )
end


--statemgr.push ( "StateMenu.lua" )
statemgr.push ( "StateLevel.lua" )
--statemgr.push ( "StateSelectLevel.lua" )
statemgr.begin()

--StateMenu:init()
--arcade()
--levels()
