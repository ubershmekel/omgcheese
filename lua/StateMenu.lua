
local StateMenu = {}

local partition = nil
local bgLayer = nil

local function arcade()
    statemgr.push('StateLevel.lua')
end

local function levels()
    statemgr.push('StateSelectLevel.lua')
end

local buttons = {
    {'buttonArcade.png', arcade},
    {'buttonLevels.png', levels}
    }

local function mouseOver(sx, sy)
    --print('mouseOver')
end

local function click(sx, sy)
    --print('click', sx, sy)
    local x, y = bgLayer:wndToWorld(sx, sy)
    local obj = partition:propForPoint(x, y)
    if obj == nil then
    	print('click no obj')
        return
    end
    
    if obj.action == nil then
        print('click o', nil)
        return
    end
    
    print('click n', obj.name)
    obj.action()
end

StateMenu.onInput = function ( self )
	if inputmgr:up () then
		click ( inputmgr:getTouch ())		
	elseif inputmgr:down () then
		mouseOver( inputmgr:getTouch ())
	end
end

function StateMenu:onLoad()
    --local ROWS = 10
    --local COLS = 14

    --[[if self.viewport == nil then
	    self.viewport = MOAIViewport.new ()
    	self.viewport:setSize ( screenWidth, screenHeight )
        self.viewport:setScale ( COLS, ROWS )
        self.viewport:setOffset(-1, -1) -- origin at bottom left
    end]]

    bgLayer = newLayer(self)
    
    partition = MOAIPartition.new()
    bgLayer:setPartition(partition)
    
    local buttonWidth = Env.wx / 4
    local buttonHeight = Env.wy / 4
    staticImage('bg.jpg', bgLayer, 0, 0, Env.wx, Env.wy)
    staticImage('title.png', bgLayer, 0, 0, Env.wx - buttonWidth, Env.wy)

    for i, fname_action in ipairs(buttons) do
        local fname = fname_action[1]
        local action = fname_action[2]
        local prop, gfx = staticImage(fname, bgLayer, Env.wx - buttonWidth, Env.wy - i * buttonHeight, Env.wx, Env.wy - (i - 1) * buttonHeight)
        prop.name = fname
        prop.action = action
        partition:insertProp(prop)
    end

    --textBox('whatever', bgLayer, 2, 2, 10, 10)

    --setupControl(mouseOver, click)
    --mouseThread()
    --print(table.tostring(StateMenu))
end

return StateMenu
