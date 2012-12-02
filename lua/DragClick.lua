
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
    if lastTouch == nil or lastTouch.distance > Env.Screen.width / 15.0 then
        return
    end
    print('click')
    self.click(wix, wiy)
end
function DragClick:click(wix, wiy)
end
function DragClick:drag(dix, diy)
end

