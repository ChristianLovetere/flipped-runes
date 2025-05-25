local mod = FlippedRunes
local Runes = {}

--misc globals
local activeCoroutines = {}
local forceProceedCoroutines = false
local coroutineNumber = 1

--GENERIC: given a function and number of frames, call the function after that many frames pass
function mod:DelayFunc(frames, func, ...)
    local args = {...}

    local co = coroutine.create(function()
        local startFrame = Game():GetFrameCount()
        while Game():GetFrameCount() < startFrame + frames and forceProceedCoroutines == false do
            coroutine.yield() --pause until enough frames pass
        end
        coroutineNumber = coroutineNumber + 1
        func(table.unpack(args)) --execute function after delay
    end)
    
    table.insert(activeCoroutines, co)
end

--GENERIC: processes coroutines
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

function mod:EnableCoroutinesToWaitOnUpdate()
    forceProceedCoroutines = false
end

mod:AddCallback(ModCallbacks.MC_POST_UPDATE, mod.EnableCoroutinesToWaitOnUpdate)

--GENERIC: Attempts to filter out all non-monsters
function mod:IsMonster(entity)
    if entity.IsActiveEnemy and 
    entity.IsVulnerableEnemy and 
    entity.Type ~= EntityType.ENTITY_PICKUP and 
    entity.Type ~= EntityType.ENTITY_SLOT and 
    entity.Type ~= EntityType.ENTITY_FAMILIAR and 
    entity.Type ~= EntityType.ENTITY_PLAYER and 
    entity.Type ~= EntityType.ENTITY_ENVIRONMENT and 
    entity.Type ~= EntityType.ENTITY_BOMB and
    entity.Type ~= EntityType.ENTITY_EFFECT and 
    entity.Type ~= EntityType.ENTITY_TEXT then
        return true
    end
    return false
end