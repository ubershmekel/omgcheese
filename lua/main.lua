
require 'mymoai'
require 'level'

local partition = nil
local bgLayer = nil

local function arcade()
    resetControl()
    Level:init()
end

local function levels()
    --print('levels')
end

local buttons = {
    {'buttonArcade.png', arcade},
    {'buttonLevels.png', levels}
    }


local function mouseOver(sx, sy)
    --print('mouseOver')
end

local function click(sx, sy)
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

local function init()
    local screenWidth = MOAIEnvironment.horizontalResolution
    local screenHeight = MOAIEnvironment.verticalResolution
    if screenWidth == nil then screenWidth = 800 end
    if screenHeight == nil then screenHeight = 480 end

    local ROWS = 10
    local COLS = 14

    MOAISim.openWindow ("test", screenWidth, screenHeight)

    local viewport = MOAIViewport.new ()
    viewport:setSize ( screenWidth, screenHeight )
    viewport:setScale ( COLS, ROWS )
    viewport:setOffset(-1, -1) -- origin at bottom left

    bgLayer = MOAILayer2D.new ()
    bgLayer:setViewport ( viewport )
    MOAISim.pushRenderPass ( bgLayer )
    
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
    --bgLayer:setPartition(partition)

    --textBox('whatever', bgLayer, 2, 2, 10, 10)

    setupControl(mouseOver, click)
end


init()
