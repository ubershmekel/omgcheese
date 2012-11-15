
require 'mymoai'
require 'level'
require 'selectlevel'

local partition = nil
local bgLayer = nil
local mainMenu = nil
states = {}

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

local buttons = {
    {'buttonArcade.png', arcade},
    {'buttonLevels.png', levels}
    }


local function mouseOver(sx, sy)
    --print('mouseOver')
end

local function click(sx, sy)
    print('click')
    local x, y = bgLayer:wndToWorld(sx, sy)
    local obj = partition:propForPoint(x, y)
    if obj == nil then
        return
    end
    
    if obj.action == nil then
        print('click', nil)
        return
    end
    
    print('click', obj.name)
    obj.action()
end

function mainMenu()
    local ROWS = 10
    local COLS = 14
    viewport, bgLayer = setupViewport(COLS, ROWS, "test")
    
    partition = MOAIPartition.new()
    bgLayer:setPartition(partition)
    
    local buttonWidth = 4
    local buttonHeight = 3
    staticImage('bg.jpg', bgLayer, 0, 0, COLS, ROWS)
    staticImage('title.png', bgLayer, 0, 0, COLS - buttonWidth, ROWS)

    for i, fname_action in ipairs(buttons) do
        local fname = fname_action[1]
        local action = fname_action[2]
        local prop, gfx = staticImage(fname, bgLayer, COLS - buttonWidth, ROWS - i * buttonHeight, COLS, ROWS - (i - 1) * buttonHeight)
        prop.name = fname
        prop.action = action
        partition:insertProp(prop)
    end

    textBox('whatever', bgLayer, 2, 2, 10, 10)

    setupControl(mouseOver, click)
    --mouseThread()
end

local function init()
    if MOAIApp ~= nil then
        -- android
        MOAIApp.setListener ( MOAIApp.BACK_BUTTON_PRESSED, onBackButtonPressed )
    end
end


init()
--mainMenu()
--arcade()
levels()
