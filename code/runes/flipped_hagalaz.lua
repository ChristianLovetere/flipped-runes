local mod = FlippedRunes
local Runes = {}

FlippedHagalazID = Isaac.GetCardIdByName("Hagalaz?")

local flippedHagalazSfx = Isaac.GetSoundIdByName("flippedHagalaz")

--Hagalaz? globals
local floorColorPulseCounter = nil
local floorColorPulseDuration = nil
local floorColorPulseRo, floorColorPulseGo, floorColorPulseBo

local roomIndicesWithPitsRemoved = {}
local hagalazUsedThisFloor = false
local hagalazUsedThisRoom = false

function Runes:UseFlippedHagalaz()
    
    mod:PlayOverlay("flippedHagalaz.png", mod.OverlayColors, flippedHagalazSfx)
    local pitLocations = {}
    local level = Game():GetLevel()
    local room = Game():GetRoom()

    for i = 0, room:GetGridSize() - 1 do
        local gridEntity = room:GetGridEntity(i)
        if gridEntity and gridEntity:GetType() == GridEntityType.GRID_PIT then
            room:RemoveGridEntity(i, 0, true)
            Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.POOF01, 0, room:GetGridPosition(i), Vector(0,0), nil)
            table.insert(pitLocations, i)
        end
    end

    if #pitLocations == 0 then
        return
    end

    hagalazUsedThisRoom = true
    hagalazUsedThisFloor = true
    roomIndicesWithPitsRemoved[level:GetCurrentRoomDesc().GridIndex] = pitLocations
    InitFloorColorPulse(0.355/2,.601/2,.554/2, 60.0)
end

mod:AddCallback(ModCallbacks.MC_USE_CARD, Runes.UseFlippedHagalaz, FlippedHagalazID)

function InitFloorColorPulse(ro, go, bo, duration)
    
    floorColorPulseCounter = 0.0
    floorColorPulseDuration = duration
    floorColorPulseRo = ro
    floorColorPulseGo = go
    floorColorPulseBo = bo
end

--HAGALAZ?: sets the floor color and then gradually reduces it back to normal
function FloorColorPulse()
    
    if floorColorPulseCounter == 0.0 then
        Game():GetRoom():SetFloorColor(Color(1, 1, 1, 1, floorColorPulseRo, floorColorPulseGo, floorColorPulseBo))
    elseif floorColorPulseDuration == 0 then
        floorColorPulseCounter = floorColorPulseCounter + 1.0
        return
    else
        local progress = floorColorPulseCounter / floorColorPulseDuration
        local partialRo = floorColorPulseRo * (1 - progress)
        local partialGo = floorColorPulseGo * (1 - progress)
        local partialBo = floorColorPulseBo * (1 - progress)

        Game():GetRoom():SetFloorColor(Color(1,1,1,1,partialRo,partialGo,partialBo))
    end   
    floorColorPulseCounter = floorColorPulseCounter + 1.0
end

function ColorPulseOnUpdate()
    
    if floorColorPulseCounter == nil or floorColorPulseDuration == nil then
        return
    end
    --reset back to nil when done
    if floorColorPulseCounter > floorColorPulseDuration then
        floorColorPulseCounter = nil
        floorColorPulseDuration = nil
        floorColorPulseRo = nil
        floorColorPulseGo = nil
        floorColorPulseBo = nil
    else
        FloorColorPulse()
    end
end

mod:AddCallback(ModCallbacks.MC_POST_UPDATE, ColorPulseOnUpdate)

function Runes:ColorPulseCancelOnChangeRoom()
    if floorColorPulseCounter == nil or floorColorPulseDuration == nil then
        return
    end
    floorColorPulseCounter = nil
    floorColorPulseDuration = nil
    floorColorPulseRo = nil
    floorColorPulseGo = nil
    floorColorPulseBo = nil
end

mod:AddCallback(ModCallbacks.MC_POST_NEW_ROOM, Runes.ColorPulseCancelOnChangeRoom)

--HAGALAZ?: discretely removes pits after walking into a room where Hagalaz? was used previously
function Runes:DiscretelyRemovePits()

    if hagalazUsedThisFloor ~= true then
        return
    end

    local pitLocations = roomIndicesWithPitsRemoved[Game():GetLevel():GetCurrentRoomDesc().GridIndex]

    if pitLocations ~= nil then
        local room = Game():GetRoom()

        for i = 1, #pitLocations do
            local gridEntity = room:GetGridEntity(pitLocations[i])
            if gridEntity and gridEntity:GetType() == GridEntityType.GRID_PIT then
                room:RemoveGridEntity(pitLocations[i], 0, true)
            end
        end
    end
end

mod:AddCallback(ModCallbacks.MC_POST_NEW_ROOM, Runes.DiscretelyRemovePits)

function Runes:ResetUsedThisRoom()
    hagalazUsedThisRoom = false
end

mod:AddCallback(ModCallbacks.MC_POST_NEW_ROOM, Runes.ResetUsedThisRoom)

function Runes:OnRewind()
    if hagalazUsedThisRoom then
        local roomIndex = Game():GetLevel():GetCurrentRoomDesc().GridIndex
        if roomIndicesWithPitsRemoved[roomIndex] ~= nil then
            roomIndicesWithPitsRemoved[roomIndex] = nil
        end
        hagalazUsedThisRoom = false
    end
end

mod:AddCallback(ModCallbacks.MC_PRE_USE_ITEM, Runes.OnRewind, CollectibleType.COLLECTIBLE_GLOWING_HOUR_GLASS)

--HAGALAZ?: Reset vars related to Hagalaz? ability
function Runes:ResetHagalaz(isContinued)
    isContinued = isContinued or false
    if isContinued == false then
        hagalazUsedThisFloor = false
    roomIndicesWithPitsRemoved = {}
    
    floorColorPulseRo = nil
    floorColorPulseGo = nil
    floorColorPulseBo = nil
    floorColorPulseCounter = nil
    floorColorPulseDuration = nil
    end
end

mod:AddCallback(ModCallbacks.MC_POST_NEW_LEVEL, Runes.ResetHagalaz)
mod:AddCallback(ModCallbacks.MC_POST_GAME_STARTED, Runes.ResetHagalaz)