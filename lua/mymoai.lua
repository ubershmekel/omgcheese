
function wait ( action )
    -- wait for animation to finish
    -- http://getmoai.com/wiki/index.php?title=Moai_SDK_Basics_Part_Two
    assert(action ~= nil)
    while action:isBusy() do coroutine:yield() end
end



function staticImage(fname, layer, minX, minY, maxX, maxY)
    local gfx = MOAIGfxQuad2D.new()
    gfx:setTexture(fname)
    gfx:setRect(minX, minY, maxX, maxY)
    --gfx:setUVRect ( 0, 0, 1, 1 )
    local prop = MOAIProp2D.new ()
    prop:setDeck(gfx)
    layer:insertProp (prop)
    --prop:setLoc(1, 1)
    return prop, gfx
end



local font = MOAIFont.new ()
font:load ( 'arialbd.ttf' )
--font:loadFromTTF ( "arialbd.ttf", "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789,.?!", 12, 163 )

function textBox(text, layer, minX, minY, maxX, maxY)
    local textbox = MOAITextBox.new ()
    textbox:setFont ( font )
    textbox:setTextSize ( 12 )
    textbox:setRect ( minX, minY, maxX, maxY )
    --textbox:setLoc(minX, minY)
    --textbox:setLoc ( maxX, maxY, 2)
    textbox:setAlignment ( MOAITextBox.CENTER_JUSTIFY )
    textbox:setYFlip ( true )
    textbox:setString ( text )
    layer:insertProp ( textbox )
    --textbox:spool ()
end


function resetControl()
    if MOAIInputMgr.device.touch ~= nil then
        MOAIInputMgr.device.touch:setCallback(nil)
    end
    if MOAIInputMgr.device.pointer ~= nil then
        MOAIInputMgr.device.mouseLeft:setCallback (nil)
        MOAIInputMgr.device.pointer:setCallback(nil)
    end
end

function setupControl(mouseOver, click)
    if MOAIInputMgr.device.touch ~= nil then
        print('Registering touch')
        MOAIInputMgr.device.touch:setCallback (
            function ( eventType, idx, sx, sy, tapCount )
                if eventType == MOAITouchSensor.TOUCH_UP then
                    --tilesLayer:removeProp(highlightProp)
                    click(sx, sy)
                end
                if eventType == MOAITouchSensor.TOUCH_DOWN or eventType == MOAITouchSensor.TOUCH_MOVE then
                    mouseOver(sx, sy)
                end
            end
        )
    end
    if MOAIInputMgr.device.pointer ~= nil then
        print('Registering pointer')
        MOAIInputMgr.device.mouseLeft:setCallback (
            function(isMouseDown)
                if(isMouseDown) then
                    -- mouseDown
                else
                    -- mouseUp
                    click(MOAIInputMgr.device.pointer:getLoc())
                end
            end
        )
        MOAIInputMgr.device.pointer:setCallback (
            function(sx, sy)
                mouseOver(MOAIInputMgr.device.pointer:getLoc())
            end
        )
    end
    
    if MOAIInputMgr.device.touch == nil and MOAIInputMgr.device.pointer == nil then
        print('!All input methods nil')
    end
end

function setupViewport(gridx, gridy, name)
    local screenWidth = MOAIEnvironment.horizontalResolution
    local screenHeight = MOAIEnvironment.verticalResolution
    if screenWidth == nil then screenWidth = 800 end
    if screenHeight == nil then screenHeight = 480 end

    MOAISim.openWindow (name, screenWidth, screenHeight)
    
    local viewport = MOAIViewport.new ()
    viewport:setSize ( screenWidth, screenHeight )
    viewport:setScale ( gridx, gridy )
    viewport:setOffset(-1, -1) -- origin at bottom left

    local layer = MOAILayer2D.new ()
    layer:setViewport ( viewport )
    MOAISim.pushRenderPass ( layer )

    return viewport, layer
end

--[[function mouseThread()
    local mainThread = MOAICoroutine.new ()
    mainThread:run (function ()

        local frames = 0
        while true do
            coroutine.yield ()
            frames = frames + 1
            if MOAIInputMgr.device.mouseLeft:down () then
                print ( MOAIInputMgr.device.pointer:getLoc () )
            end
        end
    end)
end]]
