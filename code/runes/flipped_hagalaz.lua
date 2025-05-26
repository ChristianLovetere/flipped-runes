local mod = FlippedRunes
local FlippedHagalaz = {}

local flippedHagalazSfx = Isaac.GetSoundIdByName("flippedHagalaz")

--Hagalaz? globals
local g_floorColorPulseCounter = nil
local g_floorColorPulseDuration = nil
local g_floorColorPulseRo, g_floorColorPulseGo, g_floorColorPulseBo

local g_roomIndicesWithPitsRemoved = {}
local g_hagalazUsedThisFloor = false
local g_hagalazUsedThisRoom = false

function FlippedHagalaz:UseFlippedHagalaz()
    
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

    g_hagalazUsedThisRoom = true
    g_hagalazUsedThisFloor = true
    g_roomIndicesWithPitsRemoved[level:GetCurrentRoomDesc().GridIndex] = pitLocations
    InitFloorColorPulse(0.355/2,.601/2,.554/2, 60.0)
end

mod:AddCallback(ModCallbacks.MC_USE_CARD, FlippedHagalaz.UseFlippedHagalaz, mod.flippedHagalazID)

function InitFloorColorPulse(ro, go, bo, duration)
    
    g_floorColorPulseCounter = 0.0
    g_floorColorPulseDuration = duration
    g_floorColorPulseRo = ro
    g_floorColorPulseGo = go
    g_floorColorPulseBo = bo
end

--HAGALAZ?: sets the floor color and then gradually reduces it back to normal
function FloorColorPulse()
    
    if g_floorColorPulseCounter == 0.0 then
        Game():GetRoom():SetFloorColor(Color(1, 1, 1, 1, g_floorColorPulseRo, g_floorColorPulseGo, g_floorColorPulseBo))
    elseif g_floorColorPulseDuration == 0 then
        g_floorColorPulseCounter = g_floorColorPulseCounter + 1.0
        return
    else
        local progress = g_floorColorPulseCounter / g_floorColorPulseDuration
        local partialRo = g_floorColorPulseRo * (1 - progress)
        local partialGo = g_floorColorPulseGo * (1 - progress)
        local partialBo = g_floorColorPulseBo * (1 - progress)

        Game():GetRoom():SetFloorColor(Color(1,1,1,1,partialRo,partialGo,partialBo))
    end   
    g_floorColorPulseCounter = g_floorColorPulseCounter + 1.0
end

function ColorPulseOnUpdate()
    
    if g_floorColorPulseCounter == nil or g_floorColorPulseDuration == nil then
        return
    end
    --reset back to nil when done
    if g_floorColorPulseCounter > g_floorColorPulseDuration then
        g_floorColorPulseCounter = nil
        g_floorColorPulseDuration = nil
        g_floorColorPulseRo = nil
        g_floorColorPulseGo = nil
        g_floorColorPulseBo = nil
    else
        FloorColorPulse()
    end
end

mod:AddCallback(ModCallbacks.MC_POST_UPDATE, ColorPulseOnUpdate)

function FlippedHagalaz:ColorPulseCancelOnChangeRoom()
    if g_floorColorPulseCounter == nil or g_floorColorPulseDuration == nil then
        return
    end
    g_floorColorPulseCounter = nil
    g_floorColorPulseDuration = nil
    g_floorColorPulseRo = nil
    g_floorColorPulseGo = nil
    g_floorColorPulseBo = nil
end

mod:AddCallback(ModCallbacks.MC_POST_NEW_ROOM, FlippedHagalaz.ColorPulseCancelOnChangeRoom)

--HAGALAZ?: discretely removes pits after walking into a room where Hagalaz? was used previously
function FlippedHagalaz:DiscretelyRemovePits()

    if g_hagalazUsedThisFloor ~= true then
        return
    end

    local pitLocations = g_roomIndicesWithPitsRemoved[Game():GetLevel():GetCurrentRoomDesc().GridIndex]

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

mod:AddCallback(ModCallbacks.MC_POST_NEW_ROOM, FlippedHagalaz.DiscretelyRemovePits)

function FlippedHagalaz:ResetUsedThisRoom()
    g_hagalazUsedThisRoom = false
end

mod:AddCallback(ModCallbacks.MC_POST_NEW_ROOM, FlippedHagalaz.ResetUsedThisRoom)

function FlippedHagalaz:OnRewind()
    if g_hagalazUsedThisRoom then
        local roomIndex = Game():GetLevel():GetCurrentRoomDesc().GridIndex
        if g_roomIndicesWithPitsRemoved[roomIndex] ~= nil then
            g_roomIndicesWithPitsRemoved[roomIndex] = nil
        end
        g_hagalazUsedThisRoom = false
    end
end

mod:AddCallback(ModCallbacks.MC_PRE_USE_ITEM, FlippedHagalaz.OnRewind, CollectibleType.COLLECTIBLE_GLOWING_HOUR_GLASS)

--HAGALAZ?: Reset vars related to Hagalaz? ability
function FlippedHagalaz:ResetHagalaz(isContinued)
    isContinued = isContinued or false
    if isContinued == false then
        g_hagalazUsedThisFloor = false
    g_roomIndicesWithPitsRemoved = {}
    
    g_floorColorPulseRo = nil
    g_floorColorPulseGo = nil
    g_floorColorPulseBo = nil
    g_floorColorPulseCounter = nil
    g_floorColorPulseDuration = nil
    end
end

mod:AddCallback(ModCallbacks.MC_POST_NEW_LEVEL, FlippedHagalaz.ResetHagalaz)
mod:AddCallback(ModCallbacks.MC_POST_GAME_STARTED, FlippedHagalaz.ResetHagalaz)