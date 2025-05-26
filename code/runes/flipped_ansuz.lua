local mod = FlippedRunes
local FlippedAnsuz = {}

local flippedAnsuzSfx = Isaac.GetSoundIdByName("flippedAnsuz")

--Ansuz? globals
local g_active = false
local g_counter = 0
local g_duration = 30
local g_previousCurses = 0
local g_damageTakenThisFloor = false
local g_damageTakenThisFloor_GHG = false
local g_bossRoom
local g_bossRoomBackup
local g_inBossRoom = false
local g_inBossRoomDagazDrop = false
local g_dagazDropQueued = false

--Adds curse of the lost to the floor. If you manage to get rid of it, reveals and opens the usr
--beating the entire floor without any non-self damage will make the boss drop a Dagaz rune
--having black candle causes the rune to reveal and open the usr directly
---@param player EntityPlayer
function FlippedAnsuz:UseFlippedAnsuz(_, player, _)

    mod:PlayOverlay("flippedAnsuz.png", mod.OverlayColors, flippedAnsuzSfx)

    g_bossRoom = GetCorrectBossRoom()
    g_bossRoomBackup = g_bossRoom
    print(g_bossRoom)
    local level = Game():GetLevel()
    if player:HasCollectible(CollectibleType.COLLECTIBLE_BLACK_CANDLE) then
        Isaac.RunCallback("POST_REMOVE_CURSE_OF_LOST")
    else
        level:AddCurse(LevelCurse.CURSE_OF_THE_LOST, false)
        Game():ShakeScreen(7)
        g_active = true
    end
end

mod:AddCallback(ModCallbacks.MC_USE_CARD, FlippedAnsuz.UseFlippedAnsuz, mod.flippedAnsuzID)

--ANSUZ?: Finds and opens a path to the Usr from all valid rooms that are 2 away from it, reveals usr on map
function FlippedAnsuz:OpenPathToUsr()
    
    local sfx = SFXManager()
    sfx:Play(SoundEffect.SOUND_GOLDENKEY)

    local level = Game():GetLevel()

    local usrIndex = level:QueryRoomTypeIndex(RoomType.ROOM_ULTRASECRET, true, RNG(), true)

    if usrIndex and usrIndex ~= -1 then
        level:GetRoomByIdx(usrIndex).DisplayFlags = 100
    end

    local westWest = usrIndex-2
    local northNorth = usrIndex-26
    local eastEast = usrIndex+2
    local southSouth = usrIndex+26

    local northWest = usrIndex-14
    local northEast = usrIndex-12
    local southEast = usrIndex+14
    local southWest = usrIndex+12

    local usrRow
    local usrColumn
    
    usrColumn, usrRow = GetColumnAndRow(usrIndex)

    local cornerRoomLocations = {}

    if IsWithinBounds(usrRow, usrColumn-2) then
        table.insert(cornerRoomLocations, westWest)
    end
    if IsWithinBounds(usrRow-2, usrColumn) then
        table.insert(cornerRoomLocations, northNorth)
    end
    if IsWithinBounds(usrRow, usrColumn+2) then
        table.insert(cornerRoomLocations, eastEast)
    end
    if IsWithinBounds(usrRow+2, usrColumn) then
        table.insert(cornerRoomLocations, southSouth)
    end
    if IsWithinBounds(usrRow-1, usrColumn-1) then
        table.insert(cornerRoomLocations, northWest)
    end
    if IsWithinBounds(usrRow-1, usrColumn+1) then
        table.insert(cornerRoomLocations, northEast)
    end
    if IsWithinBounds(usrRow+1, usrColumn+1) then
        table.insert(cornerRoomLocations, southEast)
    end
    if IsWithinBounds(usrRow+1, usrColumn-1) then
        table.insert(cornerRoomLocations, southWest)
    end

    local safeGridIndices = {}

    for i = 1, #cornerRoomLocations do
        local roomDesc = level:GetRoomByIdx(cornerRoomLocations[i])
        if roomDesc.SafeGridIndex ~= -1 and roomDesc.Data ~= nil and roomDesc.Data.Shape ~= nil then
            safeGridIndices[roomDesc.SafeGridIndex] = roomDesc.Data.Shape
        end
    end

    local row
    local column
    local doorToOpen

    for safeGridIndex, roomShape in pairs(safeGridIndices) do

        column, row = GetColumnAndRow(safeGridIndex)

        if column == usrColumn and row < usrRow then
            if roomShape == RoomShape.ROOMSHAPE_LTL then
                doorToOpen = DoorSlot.DOWN1
            else
                doorToOpen = DoorSlot.DOWN0
            end
        elseif column > usrColumn and row == usrRow then 
            doorToOpen = DoorSlot.LEFT0
        elseif column == usrColumn and row > usrRow then 
            if roomShape == RoomShape.ROOMSHAPE_LTL then
                doorToOpen = DoorSlot.UP1
            else
                doorToOpen = DoorSlot.UP0
            end
        elseif column < usrColumn and row == usrRow then
            doorToOpen = DoorSlot.RIGHT0
        elseif column < usrColumn and row < usrRow then
            if roomShape == RoomShape.ROOMSHAPE_1x1 or roomShape == RoomShape.ROOMSHAPE_1x2 then
                doorToOpen = DoorSlot.DOWN0
            else
                doorToOpen = DoorSlot.DOWN1
            end
        elseif column < usrColumn and row > usrRow then
            if roomShape == RoomShape.ROOMSHAPE_1x1 or roomShape == RoomShape.ROOMSHAPE_1x2 then
                doorToOpen = DoorSlot.UP0
            else
                doorToOpen = DoorSlot.UP1
            end
        elseif column > usrColumn and row > usrRow then
            doorToOpen = DoorSlot.UP0
        elseif column > usrColumn and row < usrRow then
            if roomShape == RoomShape.ROOMSHAPE_1x1 or roomShape == RoomShape.ROOMSHAPE_2x1 then
                doorToOpen = DoorSlot.LEFT0
            else
                doorToOpen = DoorSlot.LEFT1
            end
        end
        level:MakeRedRoomDoor(safeGridIndex, doorToOpen)
    end
    level:UpdateVisibility()
end

mod:AddCallback("POST_REMOVE_CURSE_OF_LOST", FlippedAnsuz.OpenPathToUsr)

--ANSUZ?: returns the column and row of a safeGridIndex.
---@param safeGridIndex integer
function GetColumnAndRow(safeGridIndex)
    
    local column = safeGridIndex % 13
    local row = safeGridIndex // 13
    return column, row
end

--ANSUZ?: function to check if row and column are within bounds
function IsWithinBounds(row, col)
    return row >= 0 and row < 13 and col >= 0 and col < 13
end

--ANSUZ?: fires off the POST_REMOVE_CURSE_OF_LOST callback if the curse of the lost was recently removed
function FlippedAnsuz:FlippedAnsuzDetectCurseChange()
    
    if g_active then
        if g_counter == g_duration then
            local currentCurses = Game():GetLevel():GetCurses()
            if currentCurses & LevelCurse.CURSE_OF_THE_LOST == 0 and g_previousCurses & LevelCurse.CURSE_OF_THE_LOST ~= 0 then
                Isaac.RunCallback("POST_REMOVE_CURSE_OF_LOST")
            end
            g_previousCurses = currentCurses
            g_counter = 0
        end
        g_counter = g_counter + 1
    end
end

mod:AddCallback(ModCallbacks.MC_POST_UPDATE, FlippedAnsuz.FlippedAnsuzDetectCurseChange)

--ANSUZ?: Turn global to true when any damage is taken this floor
function FlippedAnsuz:DetectPlayerDamageTakenThisFloor(_, _, damageFlag)
    --if not self damage
    if damageFlag & DamageFlag.DAMAGE_NO_PENALTIES == 0 then
        g_damageTakenThisFloor = true
    end
end

mod:AddCallback(ModCallbacks.MC_ENTITY_TAKE_DMG, FlippedAnsuz.DetectPlayerDamageTakenThisFloor, EntityType.ENTITY_PLAYER)

--ANSUZ?: returns the SafeGridIndex of the 'true' boss room for the floor.
--For most floors this is simply the boss, for XL it is the second boss, and for the Void floor,
--it is Delirium's room. If theres more than 2 boss rooms but none are 2x2, it returns the SafeGridIndex
--of a random boss room.
function GetCorrectBossRoom()

    local level = Game():GetLevel()

    local bossRooms = {}

    local rooms = level:GetRooms()

    for i = 0, rooms.Size do
        local room = rooms:Get(i)
        if room ~= nil and room.Data.Type ~= nil and room.SafeGridIndex ~= -1 then
            if room.Data.Type == RoomType.ROOM_BOSS then
                print("Found boss room at " .. tostring(room.SafeGridIndex))
                table.insert(bossRooms, room.SafeGridIndex)
            end
        end
    end

    --if one boss room, return it
    if #bossRooms == 1 then
        return bossRooms[1]

    --if two, we are on XL floor, and have to find which is final
    elseif #bossRooms == 2 then

        --indices of possible nearby rooms
        local nearbyRoomIndices = {
            -1, -13, 1, 13
        }

        --var to store nearby rooms for both boss rooms
        local bossRoom1NearbyValidRooms = 0
        local bossRoom2NearbyValidRooms = 0
        
        --increment nearbyValidRooms for both
        for i = 1, #nearbyRoomIndices do
            local nearbyRoomDesc1 = level:GetRoomByIdx(bossRooms[1]+nearbyRoomIndices[i], 0)
            if nearbyRoomDesc1.Data ~= nil then
                bossRoom1NearbyValidRooms = bossRoom1NearbyValidRooms + 1
            end
            local nearbyRoomDesc2 = level:GetRoomByIdx(bossRooms[2]+nearbyRoomIndices[i], 0)
            if nearbyRoomDesc2.Data ~= nil then
                bossRoom2NearbyValidRooms = bossRoom2NearbyValidRooms + 1
            end
        end

        if bossRoom1NearbyValidRooms < bossRoom2NearbyValidRooms then
            return bossRooms[1]
        else
            return bossRooms[2]
        end

    --if > two, we are either on Void or some modded floor
    else
        --find deli room by all 8 door flags being true
        for i = 1, #bossRooms do
            local roomDesc = level:GetRoomByIdx(bossRooms[i], 0)
            if roomDesc.Data.Doors == 255 then
                return bossRooms[i]
            end
        end

        --if no deli room found, just return a random boss room
        return bossRooms[math.random(#bossRooms)]
    end
end

function FlippedAnsuz:FlippedAnsuzEnableDagazDrop()
    if Game():GetLevel():GetCurrentRoomDesc().SafeGridIndex == g_bossRoom then
        g_inBossRoom = true
        g_inBossRoomDagazDrop = true
    else
        g_inBossRoom = false
        g_inBossRoomDagazDrop = false
    end

    if g_dagazDropQueued then
        SpawnDagazCenterRoom(Game():GetRoom())
    end
end

mod:AddCallback(ModCallbacks.MC_POST_NEW_ROOM, FlippedAnsuz.FlippedAnsuzEnableDagazDrop)

function FlippedAnsuz:FlippedAnsuzDropDagaz()

    if g_inBossRoom then
        if Game():GetLevel():GetCurrentRoomDesc().Clear then
            if not g_damageTakenThisFloor then

                local room = Game():GetRoom()
                Game():Spawn(EntityType.ENTITY_EFFECT, EffectVariant.REVERSE_EXPLOSION, room:GetCenterPos(), Vector(0,0), nil, 0, mod:SafeRandom())
                FlippedRunes:DelayFunc(33, SpawnDagazCenterRoom, room)
            end

            g_inBossRoom = false
            g_bossRoom = nil
        end
    end
end

mod:AddCallback(ModCallbacks.MC_POST_UPDATE, FlippedAnsuz.FlippedAnsuzDropDagaz)

function SpawnDagazCenterRoom(room)
    if g_inBossRoomDagazDrop or g_dagazDropQueued then
        Game():Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_TAROTCARD, room:GetCenterPos(), Vector(0,0), nil, Card.RUNE_DAGAZ, mod:SafeRandom())
        g_dagazDropQueued = false
    else
        g_dagazDropQueued = true
    end
end

function FlippedAnsuz:OnRewind()
    g_bossRoom = g_bossRoomBackup
    g_damageTakenThisFloor = g_damageTakenThisFloor_GHG
end

mod:AddCallback(ModCallbacks.MC_PRE_USE_ITEM, FlippedAnsuz.OnRewind, CollectibleType.COLLECTIBLE_GLOWING_HOUR_GLASS)

function FlippedAnsuz:OnChangeRoom()
    g_damageTakenThisFloor_GHG = g_damageTakenThisFloor
end

mod:AddCallback(ModCallbacks.MC_POST_NEW_ROOM, FlippedAnsuz.OnChangeRoom)

function FlippedAnsuz:FlippedAnsuzResetGlobals(isContinued)
    isContinued = isContinued or false
    if isContinued == false then
        g_previousCurses = 0
        g_active = false
        g_damageTakenThisFloor = false
        g_inBossRoom = false
        g_bossRoom = nil
    end
end

mod:AddCallback(ModCallbacks.MC_POST_GAME_STARTED, FlippedAnsuz.FlippedAnsuzResetGlobals)
mod:AddCallback(ModCallbacks.MC_POST_NEW_LEVEL, FlippedAnsuz.FlippedAnsuzResetGlobals)