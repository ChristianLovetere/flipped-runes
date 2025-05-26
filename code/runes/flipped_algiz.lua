local mod = FlippedRunes
local FlippedAlgiz = {}

local flippedAlgizSfx = Isaac.GetSoundIdByName("flippedAlgiz")

--Algiz? globals
local g_tearsMult = 1.0
local g_luckToAdd = 0.0
local g_startTearsMult = 1.0
local g_startLuckToAdd = 0.0
local g_player
local g_count = nil
local g_duration = nil
local g_count_GHG = nil

--adds one broken heart and grants x2 tears and +10 luck that fades away over 40 seconds
---@param player EntityPlayer
function FlippedAlgiz:UseFlippedAlgiz(_, player, _)

    mod:PlayOverlay("flippedAlgiz.png", mod.OverlayColors, flippedAlgizSfx)

    player:AddBrokenHearts(1)
    g_player = player
    g_count = 0
    g_duration = 1200.0
    
    g_startTearsMult = 2.0
    g_startLuckToAdd = 10.0
    g_tearsMult = g_startTearsMult
    g_luckToAdd = g_startLuckToAdd
end

mod:AddCallback(ModCallbacks.MC_USE_CARD, FlippedAlgiz.UseFlippedAlgiz, mod.flippedAlgizID)

--ALGIZ?: adds tears specified to the player specified
---@param player EntityPlayer
function FlippedAlgiz:AddTears(player, _)
    
    if player.MaxFireDelay == -1 then
        return
    end
    local onscreenTears = 30 / (player.MaxFireDelay + 1) --conversion from MaxFireDelay to tears stat
    local newOnscreenTears = onscreenTears*g_tearsMult
    if newOnscreenTears == 0 then
        return
    end
    local newFireDelay = 30 / newOnscreenTears - 1 --conversion from tears stat to MaxFireDelay
    player.MaxFireDelay = newFireDelay
end

mod:AddCallback(ModCallbacks.MC_EVALUATE_CACHE, FlippedAlgiz.AddTears, CacheFlag.CACHE_FIREDELAY)

--ALGIZ?: adds luck specified to the player specified
---@param player EntityPlayer
function FlippedAlgiz:AddLuck(player, _)

    player.Luck = player.Luck + g_luckToAdd
end

mod:AddCallback(ModCallbacks.MC_EVALUATE_CACHE, FlippedAlgiz.AddLuck, CacheFlag.CACHE_LUCK)

function FlippedAlgiz:TurnOffFlippedAlgizOnNewRun(isContinued)
    if isContinued == false then
        g_count = g_duration
        g_tearsMult = 1.0
        g_luckToAdd = 0.0

        local numPlayers = Game():GetNumPlayers()

        for i = 0, numPlayers - 1 do
            local player = Isaac.GetPlayer(i)
            player:AddCacheFlags(CacheFlag.CACHE_ALL)
            player:EvaluateItems()
        end
    end
end

mod:AddCallback(ModCallbacks.MC_POST_GAME_STARTED, FlippedAlgiz.TurnOffFlippedAlgizOnNewRun)

function FlippedAlgiz:FlippedAlgizOnUpdate()

    --if anything is nil we can't proceed
    if g_count == nil or g_duration == nil or g_player == nil then
        return
    end

    --if count passes duration, we are done
    if g_count > g_duration then
        g_count = nil
        g_duration = nil
        g_player = nil
        return
    end

    --only decrement once every second
    if g_count % 30 == 0 then
        FlippedAlgizAbility(g_player, g_count, g_duration)  
    end
    g_count = g_count + 1
end

mod:AddCallback(ModCallbacks.MC_POST_UPDATE, FlippedAlgiz.FlippedAlgizOnUpdate)

function FlippedAlgizAbility(player, count, duration)
    
    if duration == 0 or g_startTearsMult*duration == 0 then
        return
    end
    g_tearsMult = g_startTearsMult * (1 - count/(g_startTearsMult*duration))
    g_luckToAdd = g_startLuckToAdd * (1 - count/duration)


    player:AddCacheFlags(CacheFlag.CACHE_FIREDELAY)
    player:AddCacheFlags(CacheFlag.CACHE_LUCK)

    player:EvaluateItems()
end

function FlippedAlgiz:OnChangeRoom()
    g_count_GHG = g_count
end

mod:AddCallback(ModCallbacks.MC_POST_NEW_ROOM, FlippedAlgiz.OnChangeRoom)

function FlippedAlgiz:OnRewind()
    if g_count_GHG ~= nil then
        local restoredCount = (g_count_GHG // 30) * 30
        g_count = restoredCount
    end
end

mod:AddCallback(ModCallbacks.MC_PRE_USE_ITEM, FlippedAlgiz.OnRewind, CollectibleType.COLLECTIBLE_GLOWING_HOUR_GLASS)