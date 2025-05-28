local mod = FlippedRunes
local FlippedAnsuz = {}

local flippedAnsuzSfx = Isaac.GetSoundIdByName("flippedAnsuz")

--Ansuz? globals
local g_active = false
local g_checkCurseCounter = 0
local g_checkCurseDuration = 30
local g_previousCurses = 0
local g_damageTakenThisFloor = false
local g_damageTakenThisFloor_GHG = false
local g_bossRoom
local g_inBossRoom = false
local g_dagazSpawnAttempted = false
local g_dagazSpawnAttempted_GHG = false
local g_rewindingOutOfBossRoom = false
local g_dagazSpawnQueued = false
local g_doNotSpawn = false

local g_dagazSpawnEnabled = false
local g_dagazFrameCounter = 0
local g_dagazFrameDuration = 34

local g_justRewound = 0

local g_indicator
local g_indicatorPlayer
local g_indicatorMaxFrame = 0
local g_currentAnim
local g_currentAnim_GHG
local g_indicatorJustActivated = false

---@enum ansuzAnim
local ansuzAnim = {
    ACTIVE = 1,
    LOST = 2,
    SUCCESS = 3
}

--Adds curse of the lost to the floor. If you manage to get rid of it, reveals and opens the usr
--beating the entire floor without any non-self damage will make the boss drop a Dagaz rune
--having black candle causes the rune to reveal and open the usr directly
---@param player EntityPlayer
function FlippedAnsuz:UseFlippedAnsuz(_, player, _)

    mod:PlayOverlay("flippedAnsuz.png", mod.OverlayColors, flippedAnsuzSfx)

    g_bossRoom = GetCorrectBossRoom()
    FlippedAnsuz:BossRoomCheck()

    local level = Game():GetLevel()
    if player:HasCollectible(CollectibleType.COLLECTIBLE_BLACK_CANDLE) then
        Isaac.RunCallback("POST_REMOVE_CURSE_OF_LOST")
    else
        level:AddCurse(LevelCurse.CURSE_OF_THE_LOST, false)
        Game():ShakeScreen(7)
        g_active = true
    end

    --Anim stuff
    g_indicatorJustActivated = true
    g_indicatorPlayer = player
    g_indicator = Sprite()
    g_indicator:Load("gfx/flippedAnsuzIndicator.anm2", true)
    if not g_damageTakenThisFloor then
        g_indicator.PlaybackSpeed = 1.0
        g_indicator:Play("Active")
        g_currentAnim = ansuzAnim.ACTIVE
        g_indicatorMaxFrame = 11
    else
        g_indicator.PlaybackSpeed = 1.5
        g_indicator:Play("Lost")
        g_currentAnim = ansuzAnim.LOST
        SFXManager():Play(SoundEffect.SOUND_THUMBS_DOWN)
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
function FlippedAnsuz:DetectCurseChange()
    
    if g_active then
        if g_checkCurseCounter == g_checkCurseDuration then
            local currentCurses = Game():GetLevel():GetCurses()
            if currentCurses & LevelCurse.CURSE_OF_THE_LOST == 0 and g_previousCurses & LevelCurse.CURSE_OF_THE_LOST ~= 0 and g_justRewound ~= 2 then
                Isaac.RunCallback("POST_REMOVE_CURSE_OF_LOST")
            end
            g_previousCurses = currentCurses
            g_checkCurseCounter = 0
        end
        g_checkCurseCounter = g_checkCurseCounter + 1
    end
end

mod:AddCallback(ModCallbacks.MC_POST_UPDATE, FlippedAnsuz.DetectCurseChange)

--ANSUZ?: Turn global to true when any damage is taken this floor
function FlippedAnsuz:DetectPlayerDamageTakenThisFloor(_, _, damageFlag)
    --if not self damage
    if damageFlag & DamageFlag.DAMAGE_NO_PENALTIES == 0 then
        g_damageTakenThisFloor = true
        if g_indicator then
            g_indicator.PlaybackSpeed = 1.5
            g_indicator:Play("Lost", true)
            g_currentAnim = ansuzAnim.LOST
            SFXManager():Play(SoundEffect.SOUND_THUMBS_DOWN)
        end
        
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

function FlippedAnsuz:BossRoomCheck()
    if Game():GetLevel():GetCurrentRoomDesc().SafeGridIndex == g_bossRoom then
        g_inBossRoom = true
    else
        g_inBossRoom = false
    end
end

mod:AddCallback(ModCallbacks.MC_POST_NEW_ROOM, FlippedAnsuz.BossRoomCheck)

function FlippedAnsuz:DropDagaz()

    if g_inBossRoom then
        if Game():GetLevel():GetCurrentRoomDesc().Clear and not g_dagazSpawnAttempted and not g_damageTakenThisFloor then

            g_dagazSpawnEnabled = true
            g_dagazSpawnAttempted = true

            --Anim stuff
            if g_indicator then
                g_indicator:Reset()
                SFXManager():Play(SoundEffect.SOUND_THUMBSUP)
                Game():Spawn(EntityType.ENTITY_EFFECT, EffectVariant.BOMB_EXPLOSION, g_indicatorPlayer.Position + Vector(0, -45), Vector(0,0), nil, 0, mod:SafeRandom())
            end
        end
    end    
end

mod:AddCallback(ModCallbacks.MC_POST_UPDATE, FlippedAnsuz.DropDagaz)

function FlippedAnsuz:OnRewind()
    g_justRewound = 1
    g_damageTakenThisFloor = g_damageTakenThisFloor_GHG
    g_dagazSpawnAttempted = g_dagazSpawnAttempted_GHG

    g_currentAnim = g_currentAnim_GHG
    
    if g_currentAnim == ansuzAnim.ACTIVE then
        g_indicator:Play("Active", true)
    elseif g_currentAnim == ansuzAnim.LOST then
        g_indicator:Play("Lost", true)
    elseif g_indicatorJustActivated then
        g_indicator:Reset()
    end

    if g_inBossRoom then
        g_rewindingOutOfBossRoom = true
        g_inBossRoom = false
    else
        g_rewindingOutOfBossRoom = false
    end
    print(Game():GetLevel():GetLastRoomDesc().SafeGridIndex, g_bossRoom, tostring(g_dagazSpawnQueued))
    if Game():GetLevel():GetLastRoomDesc().SafeGridIndex == g_bossRoom and not g_dagazSpawnQueued then
        
        g_doNotSpawn = true
    end
end

mod:AddCallback(ModCallbacks.MC_PRE_USE_ITEM, FlippedAnsuz.OnRewind, CollectibleType.COLLECTIBLE_GLOWING_HOUR_GLASS)

function FlippedAnsuz:OnChangeRoom()
    g_damageTakenThisFloor_GHG = g_damageTakenThisFloor
    g_currentAnim_GHG = g_currentAnim

    if not g_rewindingOutOfBossRoom then
        g_dagazSpawnAttempted_GHG = g_dagazSpawnAttempted
    end

    --if we left before dagaz spawned
    if g_dagazFrameCounter > 0 and not g_inBossRoom and not g_rewindingOutOfBossRoom then
        g_dagazSpawnQueued = true
        g_dagazSpawnEnabled = false
        g_dagazFrameCounter = 0
    end

    --if we rewind before dagaz spawned
    if g_dagazFrameCounter > 0 and not g_inBossRoom and g_rewindingOutOfBossRoom then
        g_dagazSpawnEnabled = false
        g_dagazFrameCounter = 0
    end

    --if we go back into boss room after allowing a dagaz to queue
    if g_dagazSpawnQueued and g_inBossRoom then
        g_dagazSpawnEnabled = true
    end

    if g_justRewound ~= 2 then
        g_indicatorJustActivated = false
    end
    if g_justRewound == 2 then
        g_justRewound = 0
    end
    if g_justRewound  == 1 then
        g_justRewound = 2
    end
    
end

mod:AddCallback(ModCallbacks.MC_POST_NEW_ROOM, FlippedAnsuz.OnChangeRoom)

function FlippedAnsuz:SpawnDagazCenterRoom()
    if g_doNotSpawn then
        return
    end

    local room = Game():GetRoom()
    if g_dagazFrameCounter == 1 and g_dagazSpawnEnabled then
        Game():Spawn(EntityType.ENTITY_EFFECT, EffectVariant.REVERSE_EXPLOSION, room:GetCenterPos(), Vector(0,0), nil, 0, mod:SafeRandom())
    end
    
    if g_inBossRoom and g_dagazSpawnEnabled then
        
        if g_dagazFrameCounter == g_dagazFrameDuration then
            Game():Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_TAROTCARD, room:GetCenterPos(), Vector(0,0), nil, Card.RUNE_DAGAZ, mod:SafeRandom())
            g_dagazFrameCounter = 0
            g_dagazSpawnEnabled = false
            g_dagazSpawnQueued = false
            return
        end
        g_dagazFrameCounter = g_dagazFrameCounter + 1
    end
end

mod:AddCallback(ModCallbacks.MC_POST_UPDATE, FlippedAnsuz.SpawnDagazCenterRoom)

function FlippedAnsuz:ResetGlobals(isContinued)
    isContinued = isContinued or false
    if isContinued == false then

        g_previousCurses = 0
        g_active = false

        g_damageTakenThisFloor = false
        g_inBossRoom = false
        g_bossRoom = nil
        g_dagazSpawnAttempted = false
        g_rewindingOutOfBossRoom = false
        g_dagazSpawnQueued = false
        g_doNotSpawn = false
        g_dagazSpawnEnabled = false
        g_dagazFrameCounter = 0

        g_justRewound = 0

        g_indicator = nil
        g_indicatorPlayer = nil
        g_currentAnim = nil
    end
end

mod:AddCallback(ModCallbacks.MC_POST_GAME_STARTED, FlippedAnsuz.ResetGlobals)
mod:AddCallback(ModCallbacks.MC_POST_NEW_LEVEL, FlippedAnsuz.ResetGlobals)

function FlippedAnsuz:OnRender()

    if g_indicatorPlayer then
        
        if g_currentAnim == ansuzAnim.ACTIVE then
            if Isaac.GetFrameCount() % 4 == 0 then
            
                if g_indicator:GetFrame() == g_indicatorMaxFrame then
                    g_indicator:SetFrame(0)
                end
                g_indicator:Update()
            end
        elseif g_currentAnim == ansuzAnim.LOST then
            if Isaac.GetFrameCount() % 4 == 0 then
            
                g_indicator:Update()
            end
        elseif g_currentAnim == ansuzAnim.SUCCESS then
            if Isaac.GetFrameCount() % 4 == 0 then
            
                g_indicator:Update()
            end
        end
        local playerPos = Isaac.WorldToScreen(g_indicatorPlayer.Position)
        local abovePlayerHead = playerPos + Vector(0, -45)
        g_indicator:Render(abovePlayerHead)
        if g_indicator:IsFinished() then
            g_indicator = nil
            g_indicatorPlayer = nil
            g_currentAnim = 0
            g_indicatorMaxFrame = 0
        end
    end
end

mod:AddCallback(ModCallbacks.MC_POST_RENDER, FlippedAnsuz.OnRender)