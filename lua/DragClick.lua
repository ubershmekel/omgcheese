require 'stats'
require 'mymoai'
require 'CycleBuffer'

DragClick = {}


DragClick.mt = { __index = DragClick }
function DragClick:new(drag, click)
    assert(click ~= nil)
    assert(drag ~= nil)
    local object = {
        click = click,
        drag = drag
        }
    setmetatable(object, DragClick.mt)
    return object

end

local decay = 0.9
local minV = 0.5
function DragClick:swipeDecay()
    while true do
        --print('swipeDecay')
        if self.lastTouch ~= nil then
            return
        end

        local vx = self.vx * decay
        local vy = self.vy * decay
        --print('vx,vy',vx,vy)
        if math.abs(vx) + math.abs(vy) < minV then
            self.vx = 0
            self.vy = 0
            return
        end
        
        self.drag(vx, vy)
        self.vx, self.vy = vx, vy
        coroutine:yield()
    end
end

function DragClick:down(wix, wiy)
    --local firstTouch
    local distance
    if self.lastTouch == nil then
        --firstTouch
        self.historyDX = CycleBuffer:new(10)
        self.historyDY = CycleBuffer:new(10)
        distance = 0
    else
        local dx = wix - self.lastTouch.x
        local dy = -(wiy - self.lastTouch.y) -- reverse y, go figure
        self.historyDX:add(dx)
        self.historyDY:add(dy)
        --print('dx,dy', dx,dy)
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
    if lastTouch == nil then
        return
    elseif lastTouch.distance > Env.Screen.width / 15.0 then
        --end of swipe, animate swipe decay

        self.vx = stats.mean(self.historyDX)
        self.vy = stats.mean(self.historyDY)
	    swipingThread = MOAICoroutine.new ()
	    swipingThread:run ( self.swipeDecay, self )
        return
    end
    print('click')
    self.click(wix, wiy)
end


function DragClick:click(wix, wiy)
end
function DragClick:drag(dix, diy)
end

