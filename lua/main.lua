
require 'mymoai'
require 'level'

local partition = nil
local bgLayer = nil

local function mouseOver(sx, sy)
    --print('mouseOver')
end

local function click(sx, sy)
    local x, y = bgLayer:wndToWorld(sx, sy)
    local obj = partition:propForPoint(x, y)
    if obj == nil then
        return
    end
    
    if obj.name == nil then
        print('click', nil)
        return
    end
    
    print('click', obj.name)
    resetControl()
    Level:init()
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
    
    for i=0, 2 do
        local prop, gfx = staticImage('button.png', bgLayer, COLS - buttonWidth, i * buttonHeight, COLS, (i + 1) * buttonHeight)
        prop.name = "i" .. i
        partition:insertProp(prop)
    end
    --bgLayer:setPartition(partition)

    --textBox('whatever', bgLayer, 2, 2, 10, 10)

    setupControl(mouseOver, click)
end


init()
