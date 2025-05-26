local mod = FlippedRunes

--couroutine globals
local activeCoroutines = {}
local coroutineNumber = 1

--COROUTUNES: given a function and number of frames, call the function after that many frames pass
function mod:DelayFunc(frames, func, ...)
    local args = {...}

    local co = coroutine.create(function()
        local startFrame = Game():GetFrameCount()
        while Game():GetFrameCount() < startFrame + frames do
            coroutine.yield() --pause until enough frames pass
        end
        coroutineNumber = coroutineNumber + 1
        func(table.unpack(args)) --execute function after delay
    end)
    
    table.insert(activeCoroutines, co)
end

--COROUTINES: processes coroutines
function mod:ProcessCoroutines()
    for i = #activeCoroutines, 1, -1 do
        local status = coroutine.status(activeCoroutines[i])

        if status == "dead" then
            table.remove(activeCoroutines, i) --remove finished coroutine
        else
            coroutine.resume(activeCoroutines[i]) --resume and process coroutine
        end
    end
end

mod:AddCallback(ModCallbacks.MC_POST_UPDATE, mod.ProcessCoroutines)