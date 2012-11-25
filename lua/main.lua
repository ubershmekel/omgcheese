
require 'mymoai'
require 'statemgr'
require 'inputmgr'
require 'Board'
require 'particle'
require 'Levels'
require 'savefiles'

function onBackButtonPressed ()
	print ( "onBackButtonPressed: " )

    if statemgr.stackSize() == 1 then
    	return false
    end
    
    statemgr.pop()

	-- Return true if you want to override the back button press and prevent the system from handling it.
    return true
end


screenWidth = MOAIEnvironment.horizontalResolution
screenHeight = MOAIEnvironment.verticalResolution
if screenWidth == nil then screenWidth = 800 end
if screenHeight == nil then screenHeight = 480 end

Env = {}
Env.wx = 800
Env.wy = 480
Env.Screen = {}
Env.Screen.width = screenWidth
Env.Screen.height = screenHeight
Env.scale = Env.Screen.height / Env.wy
Env.saveFile = savefiles.get ( "gameSave" )

MOAISim.openWindow ("test", screenWidth, screenHeight)
MOAIGfxDevice.setClearColor(0.1, 0.4, 0.9, 1)

viewport = MOAIViewport.new ()
viewport:setSize ( screenWidth, screenHeight )

viewport:setScale ( Env.wx, Env.wy )
viewport:setOffset(-1, -1) -- origin at bottom left

DEVICE = true

Env.progress = function(map, setValue)
    assert(map ~= nil)
    assert(map.name ~= nil)
    assert(map.group ~= nil)

    local saveFile = Env.saveFile
    if saveFile.data.progress == nil then
        saveFile.data.progress = {}
    end
    if saveFile.data.progress[map.group] == nil then
        saveFile.data.progress[map.group] = {}
    end

    if setValue == nil then
        if saveFile.data.progress[map.group][map.name] == nil then
            return 1
        else
            return saveFile.data.progress[map.group][map.name]
        end
    else
        saveFile.data.progress[map.group][map.name] = setValue
        saveFile:saveGame()
    end
end


if MOAIApp ~= nil then
    -- android
    MOAIApp.setListener ( MOAIApp.BACK_BUTTON_PRESSED, onBackButtonPressed )
end


statemgr.push ( "StateMenu.lua" )
--statemgr.push ( "StateLevel.lua" )
--statemgr.push ( "StateSelectLevel.lua" )
statemgr.begin()


