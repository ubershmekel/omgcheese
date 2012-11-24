
function wait ( action )
    -- wait for animation to finish
    -- http://getmoai.com/wiki/index.php?title=Moai_SDK_Basics_Part_Two
    assert(action ~= nil)
    while action:isBusy() do coroutine:yield() end
end

R = {}

R.fontCache = {}

local cache = {}
function getQuad(fname, minX, minY, maxX, maxY)
    local cacheName = fname .. "=" .. table.concat({minX, minY, maxX, maxY}, ",")
    print(cacheName)
    local gfx = cache[cacheName]
    if gfx == nil then
        gfx = MOAIGfxQuad2D.new()
        gfx:setTexture(fname)
        gfx:setUVRect ( 0, 1, 1, 0 )
        gfx:setRect(minX, minY, maxX, maxY)
        cache[cacheName] = gfx
    end
    return gfx
end

function staticImage(fname, layer, minX, minY, maxX, maxY)
    local gfx = getQuad(fname, minX, minY, maxX, maxY)
    local prop = MOAIProp2D.new ()
    prop:setDeck(gfx)
    layer:insertProp (prop)
    --prop:setLoc(1, 1)
    return prop, gfx
end



local defaultFont = MOAIFont.new ()
defaultFont:load ( 'arialbd.ttf' )
--font:loadFromTTF ( "arialbd.ttf", "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789,.?!", 12, 163 )

function textBox(text, layer, minX, minY, maxX, maxY)
    local textbox = MOAITextBox.new ()
    textbox:setFont ( defaultFont )
    textbox:setTextSize ( 12 )
    textbox:setRect ( minX, minY, maxX, maxY )
    --textbox:setLoc(minX, minY)
    --textbox:setLoc ( maxX, maxY, 2)
    textbox:setAlignment ( MOAITextBox.CENTER_JUSTIFY )
    textbox:setYFlip ( true )
    textbox:setString ( text )
    layer:insertProp ( textbox )
    --textbox:spool ()
    return textbox
end

function R.getFont(fontName)
    if fontName == nil then
        return defaultFont
    elseif self.fontCache[fontName] == nil then
        local newFont = MOAIFont.new()
        newFont:load(fontName)
        self.fontCache[fontName] = newFont
    end
    return self.fontCache[fontName]
end

function R:label(data)
    --e.g. R:label({width=10, height=10, font='arialbd.ttf', fontSize=10, layer=layer})
    --MOAIDebugLines.setStyle ( MOAIDebugLines.TEXT_BOX, 1, 1, 1, 1, 1 )
    local lbl = MOAITextBox.new()
    lbl:setRect( -data.width * Env.scale / 2, -data.height * Env.scale / 2,
                  data.width * Env.scale / 2, data.height * Env.scale / 2 )
    lbl:setScl( 1 / Env.scale )
    lbl:setFont( R.getFont( data.font ) )
    lbl:setYFlip ( true )
    lbl:setString ( data.text )
    lbl:setTextSize( data.fontSize * Env.scale )
    data.layer:insertProp ( lbl )
    return lbl
end

DragClick = {}
function DragClick:down(wix, wiy)
    --local firstTouch
    local distance
    if self.lastTouch == nil then
        --firstTouch = {x = wix, y = wiy}
        distance = 0
    else
        local dx = wix - self.lastTouch.x
        local dy = -(wiy - self.lastTouch.y) -- reverse y, go figure
        distance = self.lastTouch.distance + math.abs(dx) + math.abs(dy)
        --firstTouch = self.lastTouch.firstTouch
        self.drag(dx, dy)
        --print(dx,dy)
    end
    self.lastTouch = {x = wix, y = wiy, distance=distance}
end
function DragClick:up(wix, wiy)
    local lastTouch = self.lastTouch
    self.lastTouch = nil
    if lastTouch.distance > Env.Screen.width / 15.0 then
        return
    end
    print('click')
    self.click(wix, wiy)
end
function DragClick:click(wix, wiy)
end
function DragClick:drag(dix, diy)
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

local windowSetup = false
function setupViewport(gridx, gridy, name)
    local screenWidth = MOAIEnvironment.horizontalResolution
    local screenHeight = MOAIEnvironment.verticalResolution
    if screenWidth == nil then screenWidth = 800 end
    if screenHeight == nil then screenHeight = 480 end

    if not windowSetup then
        MOAISim.openWindow (name, screenWidth, screenHeight)
        windowSetup = true
        viewport = MOAIViewport.new ()
        viewport:setSize ( screenWidth, screenHeight )
    end
    
    viewport:setScale ( gridx, gridy )
    viewport:setOffset(-1, -1) -- origin at bottom left

    return viewport
end

function newLayer(state)
    assert(viewport ~= nil)
    assert(state ~= nil)
    local layer = MOAILayer2D.new ()
    layer:setViewport ( viewport )
    --MOAISim.pushRenderPass ( layer )
    
    -- The state-manager has a set of layers for whichever place
    -- this state is on the stack. E.g. if a popup is in the foreground
    -- then state.layerTable[2] can have an additional greying-out layer.
    if state.layerTable == nil then
        state.layerTable = {{}}
    end
    table.insert(state.layerTable[1], layer)

    return layer
end

function clearLayers()
	MOAIRenderMgr.clearRenderStack ()
	MOAISim.forceGarbageCollection ()
	
    for i, layer in ipairs(layers) do
        layer:clear()
    end
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
