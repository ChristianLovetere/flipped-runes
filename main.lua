FlippedRunes = RegisterMod("Flipped Runes", 1)
local mod = FlippedRunes
local Runes = {}

--Helpers
include("code.unstackable_vanilla_items")

--Rune Logic
include("code.runes.flipped_hagalaz")
include("code.runes.flipped_jera")
include("code.runes.flipped_ehwaz")
include("code.runes.flipped_dagaz")
include("code.runes.flipped_ansuz")
include("code.runes.flipped_perthro")
include("code.runes.flipped_berkano")
include("code.runes.flipped_algiz")
include("code.runes.flipped_blank")
include("code.runes.flipped_black")

--Mod Compat
include("code.eid_support")

RuneColor = Color(0.355/2,.601/2,.554/2)

--misc globals
local activeCoroutines = {}
local forceProceedCoroutines = false
local coroutineNumber = 1

--GENERIC: given a function and number of frames, call the function after that many frames pass
function DelayFunc(frames, func, ...)
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
function ProcessCoroutines()
    for i = #activeCoroutines, 1, -1 do
        local status = coroutine.status(activeCoroutines[i])

        if status == "dead" then
            table.remove(activeCoroutines, i) --remove finished coroutine
        else
            coroutine.resume(activeCoroutines[i]) --resume and process coroutine
        end
    end
end

mod:AddCallback(ModCallbacks.MC_POST_UPDATE, ProcessCoroutines)

function EnableCoroutinesToWaitOnUpdate()
    forceProceedCoroutines = false
end

mod:AddCallback(ModCallbacks.MC_POST_UPDATE, EnableCoroutinesToWaitOnUpdate)

--GENERIC: Attempts to filter out all non-monsters
function IsMonster(entity)
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