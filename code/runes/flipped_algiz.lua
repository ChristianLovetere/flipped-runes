local mod = FlippedRunes
local Runes = {}

FlippedAlgizID = Isaac.GetCardIdByName("Algiz?")

local flippedAlgizSfx = Isaac.GetSoundIdByName("flippedAlgiz")

--Algiz? globals
local tearsMult = 1.0
local luckToAdd = 0.0
local startTearsMult = 1.0
local startLuckToAdd = 0.0
local flippedAlgizPlayer
local flippedAlgizCount = nil
local flippedAlgizDuration = nil
local flippedAlgizCountBackup = nil

--adds one broken heart and grants x2 tears and +10 luck that fades away over 40 seconds
---@param player EntityPlayer
function Runes:UseFlippedAlgiz(_, player, _)

    player:AddBrokenHearts(1)
    flippedAlgizPlayer = player
    flippedAlgizCount = 0
    flippedAlgizDuration = 1200.0
    
    startTearsMult = 2.0
    startLuckToAdd = 10.0
    tearsMult = startTearsMult
    luckToAdd = startLuckToAdd
end

mod:AddCallback(ModCallbacks.MC_USE_CARD, Runes.UseFlippedAlgiz, FlippedAlgizID)

--ALGIZ?: adds tears specified to the player specified
---@param player EntityPlayer
function Runes:AddTears(player, _)
    
    if player.MaxFireDelay == -1 then
        return
    end
    local onscreenTears = 30 / (player.MaxFireDelay + 1) --conversion from MaxFireDelay to tears stat
    local newOnscreenTears = onscreenTears*tearsMult
    if newOnscreenTears == 0 then
        return
    end
    local newFireDelay = 30 / newOnscreenTears - 1 --conversion from tears stat to MaxFireDelay
    player.MaxFireDelay = newFireDelay
end

mod:AddCallback(ModCallbacks.MC_EVALUATE_CACHE, Runes.AddTears, CacheFlag.CACHE_FIREDELAY)

--ALGIZ?: adds luck specified to the player specified
---@param player EntityPlayer
function Runes:AddLuck(player, _)

    player.Luck = player.Luck + luckToAdd
end

mod:AddCallback(ModCallbacks.MC_EVALUATE_CACHE, Runes.AddLuck, CacheFlag.CACHE_LUCK)

function Runes:TurnOffFlippedAlgizOnNewRun(isContinued)
    if isContinued == false then
        flippedAlgizCount = flippedAlgizDuration
        tearsMult = 1.0
        luckToAdd = 0.0

        local numPlayers = Game():GetNumPlayers()

        for i = 0, numPlayers - 1 do
            local player = Isaac.GetPlayer(i)
            player:AddCacheFlags(CacheFlag.CACHE_ALL)
            player:EvaluateItems()
        end
    end
end

mod:AddCallback(ModCallbacks.MC_POST_GAME_STARTED, Runes.TurnOffFlippedAlgizOnNewRun)

function Runes:FlippedAlgizOnUpdate()

    --if anything is nil we can't proceed
    if flippedAlgizCount == nil or flippedAlgizDuration == nil or flippedAlgizPlayer == nil then
        return
    end

    --if count passes duration, we are done
    if flippedAlgizCount > flippedAlgizDuration then
        flippedAlgizCount = nil
        flippedAlgizDuration = nil
        flippedAlgizPlayer = nil
        return
    end

    --only decrement once every second
    if flippedAlgizCount % 30 == 0 then
        FlippedAlgizAbility(flippedAlgizPlayer, flippedAlgizCount, flippedAlgizDuration)  
    end
    flippedAlgizCount = flippedAlgizCount + 1
end

mod:AddCallback(ModCallbacks.MC_POST_UPDATE, Runes.FlippedAlgizOnUpdate)

function FlippedAlgizAbility(player, count, duration)
    
    if duration == 0 or startTearsMult*duration == 0 then
        return
    end
    tearsMult = startTearsMult * (1 - count/(startTearsMult*duration))
    luckToAdd = startLuckToAdd * (1 - count/duration)


    player:AddCacheFlags(CacheFlag.CACHE_FIREDELAY)
    player:AddCacheFlags(CacheFlag.CACHE_LUCK)

    player:EvaluateItems()
end

function Runes:OnChangeRoom()
    flippedAlgizCountBackup = flippedAlgizCount
end

mod:AddCallback(ModCallbacks.MC_POST_NEW_ROOM, Runes.OnChangeRoom)

function Runes:OnRewind()
    if flippedAlgizCountBackup ~= nil then
        local restoredCount = (flippedAlgizCountBackup // 30) * 30
        flippedAlgizCount = restoredCount
    end
end

mod:AddCallback(ModCallbacks.MC_PRE_USE_ITEM, Runes.OnRewind, CollectibleType.COLLECTIBLE_GLOWING_HOUR_GLASS)