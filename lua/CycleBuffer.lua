CycleBuffer = {}

CycleBuffer.mt = { __index = CycleBuffer }
function CycleBuffer:new(maxSize)
    assert(maxSize > 0)
    local object = {
        _data = {
            maxSize = maxSize,
            pointer = 1
            }
        }
    setmetatable(object, CycleBuffer.mt)
    return object
end

function CycleBuffer:add(item)
    if self._data.pointer > self._data.maxSize then
        self._data.pointer = 1
    end
    self[self._data.pointer] = item
    self._data.pointer = self._data.pointer + 1
end
