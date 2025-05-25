local mod = FlippedRunes
local Runes = {}

FlippedAnsuzID = Isaac.GetCardIdByName("Ansuz?")

local flippedAnsuzSfx = Isaac.GetSoundIdByName("flippedAnsuz")

--Ansuz? globals
local flippedAnsuzActive = false
local flippedAnsuzCounter = 0
local flippedAnsuzDuration = 30
local previousCurses = 0
local damageTakenThisFloor = false
local damageTakenThisFloorBackup = false
local ansuzBossRoom
local ansuzBossRoomBackup
local ansuzInBossRoom = false

--Adds curse of the lost to the floor. If you manage to get rid of it, reveals and opens the usr
--beating the entire floor without any non-self damage will make the boss drop a Dagaz rune
--having black candle causes the rune to reveal and open the usr directly
---@param player EntityPlayer
function Runes:UseFlippedAnsuz(_, player, _)

    ansuzBossRoom = GetCorrectBossRoom()
    ansuzBossRoomBackup = ansuzBossRoom
    print(ansuzBossRoom)
    local level = Game():GetLevel()
    if player:HasCollectible(CollectibleType.COLLECTIBLE_BLACK_CANDLE) then
        Isaac.RunCallback("POST_REMOVE_CURSE_OF_LOST")
    else
        level:AddCurse(LevelCurse.CURSE_OF_THE_LOST, false)
        Game():ShakeScreen(7)
        flippedAnsuzActive = true
    end
end

mod:AddCallback(ModCallbacks.MC_USE_CARD, Runes.UseFlippedAnsuz, FlippedAnsuzID)

--ANSUZ?: Finds and opens a path to the Usr from all valid rooms that are 2 away from it, reveals usr on map
function Runes:OpenPathToUsr()
    
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

mod:AddCallback("POST_REMOVE_CURSE_OF_LOST", Runes.OpenPathToUsr)

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
function Runes:FlippedAnsuzDetectCurseChange()
    
    if flippedAnsuzActive then
        if flippedAnsuzCounter == flippedAnsuzDuration then
            local currentCurses = Game():GetLevel():GetCurses()
            if currentCurses & LevelCurse.CURSE_OF_THE_LOST == 0 and previousCurses & LevelCurse.CURSE_OF_THE_LOST ~= 0 then
                Isaac.RunCallback("POST_REMOVE_CURSE_OF_LOST")
            end
            previousCurses = currentCurses
            flippedAnsuzCounter = 0
        end
        flippedAnsuzCounter = flippedAnsuzCounter + 1
    end
end

mod:AddCallback(ModCallbacks.MC_POST_UPDATE, Runes.FlippedAnsuzDetectCurseChange)

--ANSUZ?: Turn global to true when any damage is taken this floor
function Runes:DetectPlayerDamageTakenThisFloor(_, _, damageFlag)
    --if not self damage
    if damageFlag & DamageFlag.DAMAGE_NO_PENALTIES == 0 then
        damageTakenThisFloor = true
    end
end

mod:AddCallback(ModCallbacks.MC_ENTITY_TAKE_DMG, Runes.DetectPlayerDamageTakenThisFloor, EntityType.ENTITY_PLAYER)

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

function Runes:FlippedAnsuzEnableDagazDrop()
    if Game():GetLevel():GetCurrentRoomDesc().SafeGridIndex == ansuzBossRoom then
        ansuzInBossRoom = true
    end
end

mod:AddCallback(ModCallbacks.MC_POST_NEW_ROOM, Runes.FlippedAnsuzEnableDagazDrop)

function Runes:FlippedAnsuzDropDagaz()

    if ansuzInBossRoom then
        if Game():GetLevel():GetCurrentRoomDesc().Clear then
            if not damageTakenThisFloor then

                local room = Game():GetRoom()
                Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.REVERSE_EXPLOSION, 0, room:GetCenterPos(), Vector(0,0), nil)
                FlippedRunes:DelayFunc(33, SpawnDagazCenterRoom, room)
            end

            ansuzInBossRoom = false
            ansuzBossRoom = nil
        end
    end
end

mod:AddCallback(ModCallbacks.MC_POST_UPDATE, Runes.FlippedAnsuzDropDagaz)

function SpawnDagazCenterRoom(room)
    Isaac.Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_TAROTCARD, Card.RUNE_DAGAZ, room:GetCenterPos(), Vector(0,0), nil)
end

function Runes:OnRewind()
    ansuzBossRoom = ansuzBossRoomBackup
    damageTakenThisFloor = damageTakenThisFloorBackup
end

mod:AddCallback(ModCallbacks.MC_PRE_USE_ITEM, Runes.OnRewind, CollectibleType.COLLECTIBLE_GLOWING_HOUR_GLASS)

function Runes:OnChangeRoom()
    damageTakenThisFloorBackup = damageTakenThisFloor
    print(damageTakenThisFloor)
end

mod:AddCallback(ModCallbacks.MC_POST_NEW_ROOM, Runes.OnChangeRoom)

function Runes:FlippedAnsuzResetGlobals(isContinued)
    isContinued = isContinued or false
    if isContinued == false then
        previousCurses = 0
        flippedAnsuzActive = false
        damageTakenThisFloor = false
        ansuzInBossRoom = false
        ansuzBossRoom = nil
    end
end

mod:AddCallback(ModCallbacks.MC_POST_GAME_STARTED, Runes.FlippedAnsuzResetGlobals)
mod:AddCallback(ModCallbacks.MC_POST_NEW_LEVEL, Runes.FlippedAnsuzResetGlobals)