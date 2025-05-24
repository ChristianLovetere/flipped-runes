FlippedRunes = RegisterMod("Flipped Runes", 1)
local mod = FlippedRunes
local Runes = {}

include("unstackableVanillaItems")


local flippedHagalazID = Isaac.GetCardIdByName("Hagalaz?")
local flippedJeraID = Isaac.GetCardIdByName("Jera?")
local flippedEhwazID = Isaac.GetCardIdByName("Ehwaz?")
local flippedDagazID = Isaac.GetCardIdByName("Dagaz?")
local flippedAnsuzID = Isaac.GetCardIdByName("Ansuz?")
local flippedPerthroID = Isaac.GetCardIdByName("Perthro?")
local flippedBerkanoID = Isaac.GetCardIdByName("Berkano?")
local flippedAlgizID = Isaac.GetCardIdByName("Algiz?")
local flippedBlankID = Isaac.GetCardIdByName("Blank Rune?")
local flippedBlackID = Isaac.GetCardIdByName("Black Rune?")
local crackedFlippedBlackID = Isaac.GetCardIdByName("Black Rune..?")
local brokenFlippedBlackID = Isaac.GetCardIdByName("Black Rune...")
local shiningFlippedBlackID = Isaac.GetCardIdByName("Black Rune!?")

local flippedHagalazSfx = Isaac.GetSoundIdByName("flippedHagalaz")
local flippedJeraSfx = Isaac.GetSoundIdByName("flippedJera")
local flippedEhwazSfx = Isaac.GetSoundIdByName("flippedEhwaz")
local flippedDagazSfx = Isaac.GetSoundIdByName("flippedDagaz")
local flippedAnsuzSfx = Isaac.GetSoundIdByName("flippedAnsuz")
local flippedPerthroSfx = Isaac.GetSoundIdByName("flippedPerthro")
local flippedBerkanoSfx = Isaac.GetSoundIdByName("flippedBerkano")
local flippedAlgizSfx = Isaac.GetSoundIdByName("flippedAlgiz")
local flippedBlackSfx = Isaac.GetSoundIdByName("flippedBlack")

local runeColor = Color(0.355/2,.601/2,.554/2)

--misc globals
local activeCoroutines = {}
local sfx = SFXManager()
local forceProceedCoroutines = false
local coroutineNumber = 1

local numModdedCollectibles

for id = CollectibleType.NUM_COLLECTIBLES + 1, 10000000 do
    if not Isaac.GetItemConfig():GetCollectible(id) then
        numModdedCollectibles = id - CollectibleType.NUM_COLLECTIBLES - 1
        break
    end
end

local numTotalCollectibles = numModdedCollectibles + CollectibleType.NUM_COLLECTIBLES

--Hagalaz? globals
local floorColorPulseCounter = nil
local floorColorPulseDuration = nil
local floorColorPulseRo, floorColorPulseGo, floorColorPulseBo

local roomIndicesWithPitsRemoved = {}
local hagalazUsedThisFloor = false

--Ehwaz? globals
local shouldSpawnReturnCard = nil

--Dagaz? globals
local flippedDagazActive = nil
local flippedDagazPlayer = nil
local flippedDagazCurses = {
    LevelCurse.CURSE_OF_DARKNESS,
    LevelCurse.CURSE_OF_THE_LOST,
    LevelCurse.CURSE_OF_THE_UNKNOWN,
    LevelCurse.CURSE_OF_MAZE,
    LevelCurse.CURSE_OF_BLIND
}
local activeCurses
local floorStartCurses = 0

--Ansuz? globals
local flippedAnsuzActive = false
local flippedAnsuzCounter = 0
local flippedAnsuzDuration = 30
local previousCurses = 0
local damageTakenThisFloor = false
local ansuzBossRoom
local ansuzInBossRoom = false

--Algiz? globals
local tearsMult = 1.0
local luckToAdd = 0.0
local startTearsMult = 1.0
local startLuckToAdd = 0.0
local flippedAlgizPlayer
local flippedAlgizCount = nil
local flippedAlgizDuration = nil

--Black Rune? globals
local numRecycles = -1

if EID then

    EID:addCard(flippedHagalazID, "Fills all pits in the room#Pits stay filled even if the room is exited", "Hagalaz?", "en_us")
    EID:addCard(flippedJeraID, "Rerolls {{Coin}}, {{Bomb}}, {{Key}}, and {{HalfHeart}}/{{Heart}} into other variants of their pickup type#{{Shop}} Works on pickups that are for sale", "Jera?", "en_us")
    EID:addCard(flippedEhwazID, "{{DemonBeggar}} Teleports Isaac to the Black Market#Spawns a {{Card1}} Fool Card inside the Black Market after teleporting", "Ehwaz?", "en_us")
    EID:addCard(flippedDagazID, "\2 Adds a random {{ColorPurple}}curse{{CR}} to the current floor#\1 For the rest of the floor, enemies have a chance to be debuffed when a room is entered# The chance for a debuff increases with the number of active curses#{{Card35}} Dagaz grants an extra {{HalfSoulHeart}} per curse added by this rune", "Dagaz?", "en_us")
    EID:addCard(flippedAnsuzID, "{{CurseLostSmall}} Adds Curse of the Lost to the current floor#{{Card35}} A Dagaz rune will drop after the boss is killed if no damage was taken this floor#{{UltraSecretRoom}} If the floor's Curse of the Lost is removed in any way, the Ultra Secret Room will be revealed and a path to it will be opened", "Ansuz?", "en_us")
    EID:addCard(flippedPerthroID, "Rerolls items in the room into items Isaac already owns# Avoids rerolling into vanilla items that have no benefit when duplicated, including active items #{{Blank}} (except {{Collectible297}},{{Collectible515}},{{Collectible490}},{{Collectible628}})# If Isaac has no eligible items, rerolls into a random item from the current room's pool", "Perthro?", "en_us")
    EID:addCard(flippedBerkanoID, "\2 Removes up to 2 vanilla familiars#\1 Spawns an item from the current room's pool for each familiar removed", "Berkano?", "en_us")
    EID:addCard(flippedAlgizID, "{{BrokenHeart}} +1 Broken Heart#{{Timer}} Wears off over 40 seconds:#\1 x2 Tears multiplier#\1 +10 Luck#Using Algiz? again while it's already active will reset the timer", "Algiz?", "en_us")
    EID:addCard(flippedBlankID, "{{Rune}} Converts all rune pickups in the room into their flipped variants#{{Shop}} Works on runes that are for sale", "Blank Rune?", "en_us")
    EID:addCard(flippedBlackID, "Creates a wide variety of pickups#!!! Highly volatile!#{{Collectible263}} Can't be mimicked by Clear Rune", "Black Rune?", "en_us")
    EID:addCard(crackedFlippedBlackID, "Creates 1-3 {{Card}}, {{Pill}}, and {{Battery}}, 2-3 times#!!! Explodes after a short delay when dropped#{{Collectible263}} Can't be mimicked by Clear Rune", "Black Rune..?", "en_us")
    EID:addCard(brokenFlippedBlackID, "Creates 1-2 {{Chest}}, {{BlackSack}}, and {{Heart}}, 2-3 times#!!! Explodes after a short delay when dropped#{{Collectible263}} Can't be mimicked by Clear Rune", "Black Rune...", "en_us")
    EID:addCard(shiningFlippedBlackID, "!!! Likely to explode and spawn bombs around Isaac, lighting enemies ablaze with a high damage burning effect# Small chance to create 2-3 {{ColorYellow}}Trinkets{{CR}}, {{GoldenKey}}, {{GoldenBomb}}, and {{CoinHeart}} instead, without consuming the rune#!!! Explodes after a short delay when dropped#{{Collectible263}} Can't be mimicked by Clear Rune", "Black Rune!?", "en_us")
    
    local eidSprite = Sprite()
    eidSprite:Load("gfx/eid_icons.anm2", true)
    EID:addIcon("Card"..flippedHagalazID, "flippedRune1", -1, 18, 23, 5, 7, eidSprite)
    EID:addIcon("Card"..flippedJeraID, "flippedRune1", -1, 18, 23, 5, 7, eidSprite)
    EID:addIcon("Card"..flippedEhwazID, "flippedRune1", -1, 18, 23, 5, 7, eidSprite)
    EID:addIcon("Card"..flippedDagazID, "flippedRune1", -1, 18, 23, 5, 7, eidSprite)
    EID:addIcon("Card"..flippedAnsuzID, "flippedRune2", -1, 18, 23, 5, 6, eidSprite)
    EID:addIcon("Card"..flippedPerthroID, "flippedRune2", -1, 18, 23, 5, 6, eidSprite)
    EID:addIcon("Card"..flippedBerkanoID, "flippedRune2", -1, 18, 23, 5, 6, eidSprite)
    EID:addIcon("Card"..flippedAlgizID, "flippedRune2", -1, 18, 23, 5, 6, eidSprite)
    EID:addIcon("Card"..flippedBlankID, "flippedRune2", -1, 18, 23, 5, 6, eidSprite)
    EID:addIcon("Card"..flippedBlackID, "flippedRuneBlack", -1, 18, 23, 5, 7, eidSprite)
    EID:addIcon("Card"..crackedFlippedBlackID, "crackedFlippedRuneBlack", -1, 18, 23, 5, 7, eidSprite)
    EID:addIcon("Card"..brokenFlippedBlackID, "brokenFlippedRuneBlack", -1, 18, 23, 5, 7, eidSprite)
    EID:addIcon("Card"..shiningFlippedBlackID, "shiningFlippedRuneBlack", -1, 18, 23, 5, 7, eidSprite)
    
    local function BlackCandleModifierCondition(descObj)
        if descObj.ObjType == EntityType.ENTITY_PICKUP and descObj.ObjVariant == PickupVariant.PICKUP_COLLECTIBLE and descObj.ObjSubType == CollectibleType.COLLECTIBLE_BLACK_CANDLE then
            local numPlayers = Game():GetNumPlayers()
            for i = 0, numPlayers do
                local player = Isaac.GetPlayer(i)
                if player:GetCard(0) == flippedAnsuzID or player:GetCard(1) == flippedAnsuzID or player:GetCard(2) == flippedAnsuzID then
                    return true
                end
            end
        end
        return false
    end

    local function blackCandleModifierCallback(descObj)
        EID:appendToDescription(descObj, "#{{Card"..flippedAnsuzID.."}} Allows Ansuz? to open a path to the {{UltraSecretRoom}} Ultra Secret Room on use")
        return descObj
    end

    EID:addDescriptionModifier("BlackCandleAnsuz?", BlackCandleModifierCondition, blackCandleModifierCallback)

    local function FlippedAnsuzModifierCondition(descObj)
        if descObj.ObjType == EntityType.ENTITY_PICKUP and descObj.ObjVariant == PickupVariant.PICKUP_TAROTCARD and descObj.ObjSubType == flippedAnsuzID then
            local numPlayers = Game():GetNumPlayers()
            for i = 0, numPlayers do
                local player = Isaac.GetPlayer(i)
                if player:HasCollectible(CollectibleType.COLLECTIBLE_BLACK_CANDLE) then
                    return true
                end
            end
        end
    end

    local function FlippedAnsuzModifierCallback(descObj)
        EID:appendToDescription(descObj, "#{{Collectible260}} Black Candle lets Ansuz? bypass all other conditions and open the {{UltraSecretRoom}} Ultra Secret Room immediately")
        return descObj
    end
    
    EID:addDescriptionModifier("Ansuz?BlackCandle", FlippedAnsuzModifierCondition, FlippedAnsuzModifierCallback)
end


function Runes:UseFlippedHagalaz()
    
    if GiantBookAPI then
        if REPENTANCE_PLUS then
            GiantBookAPI.playGiantBook("Appear", "flippedHagalaz.png", runeColor, runeColor, runeColor, flippedHagalazSfx, false)
        elseif REPENTANCE then
            GiantBookAPI.playGiantBook("Appear", "flippedHagalaz.png", runeColor, runeColor, runeColor, flippedHagalazSfx, false)
        end
    end
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

    hagalazUsedThisFloor = true
    roomIndicesWithPitsRemoved[level:GetCurrentRoomDesc().GridIndex] = pitLocations
    InitFloorColorPulse(0.355/2,.601/2,.554/2, 30.0)
end

mod:AddCallback(ModCallbacks.MC_USE_CARD, Runes.UseFlippedHagalaz, flippedHagalazID)

--rerolls basic pickups into more advanced forms (less chance for coins)
function Runes:UseFlippedJera()
    local game = Game()
    local entities = Isaac.GetRoomEntities()

    for _, entity in ipairs(entities) do
        local refinedPickup, refinedPickupVariant
        local pickup = entity:ToPickup()
        if entity:ToPickup() then
            if pickup and pickup.Variant == PickupVariant.PICKUP_COIN and pickup.SubType == CoinSubType.COIN_PENNY then
                refinedPickup, refinedPickupVariant = GetRefinedCoin()
            elseif pickup and pickup.Variant == PickupVariant.PICKUP_BOMB and pickup.SubType == BombSubType.BOMB_NORMAL then
                refinedPickup, refinedPickupVariant = GetRefinedBomb()
            elseif pickup and pickup.Variant == PickupVariant.PICKUP_HEART and (pickup.SubType == HeartSubType.HEART_FULL or pickup.SubType == HeartSubType.HEART_HALF) then
                refinedPickup, refinedPickupVariant = GetRefinedHeart()
            elseif pickup and pickup.Variant == PickupVariant.PICKUP_KEY and pickup.SubType == KeySubType.KEY_NORMAL then
                refinedPickup, refinedPickupVariant = GetRefinedKey()
            end
            if pickup and refinedPickup and refinedPickupVariant then
                pickup:Morph(EntityType.ENTITY_PICKUP, refinedPickupVariant, refinedPickup, true)
            end
        end
    end
end

mod:AddCallback(ModCallbacks.MC_USE_CARD, Runes.UseFlippedJera, flippedJeraID)

--teleports Isaac to the Black Market and spawns a 0 - The Fool card to let him teleport back out of it
function Runes:UseFlippedEhwaz()
    local game = Game()
    local level = game:GetLevel()
    
    -- Get the Black Market's room index (if available)
    local blackMarketIndex = level:QueryRoomTypeIndex(RoomType.ROOM_BLACK_MARKET, false, RNG())
    
    if blackMarketIndex then
        game:StartRoomTransition(blackMarketIndex, Direction.NO_DIRECTION, RoomTransitionAnim.TELEPORT)
        shouldSpawnReturnCard = true
    end
end

mod:AddCallback(ModCallbacks.MC_USE_CARD, Runes.UseFlippedEhwaz, flippedEhwazID)

--adds a random curse and a chance to add status effects to enemies when walking into rooms 
--for the current floor. The chance for a status effect increases with amount of curses
function Runes:UseFlippedDagaz(_, player, _)
    
    local level = Game():GetLevel()
    local newCurse = GetRandomCurse()
    local allCursesPresent, _ = FlippedDagazCursesPresent()
    if allCursesPresent ~= true then
        level:AddCurse(newCurse, true)
        Game():ShakeScreen(10)
        flippedDagazActive = true
        flippedDagazPlayer = player
        _, activeCurses = FlippedDagazCursesPresent() 
    end
end

mod:AddCallback(ModCallbacks.MC_USE_CARD, Runes.UseFlippedDagaz, flippedDagazID)

--Adds curse of the lost to the floor. If you manage to get rid of it, reveals and opens the usr
--beating the entire floor without any non-self damage will make the boss drop a Dagaz rune
--having black candle causes the rune to reveal and open the usr directly
---@param player EntityPlayer
function Runes:UseFlippedAnsuz(_, player, _)

    ansuzBossRoom = GetCorrectBossRoom()
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

mod:AddCallback(ModCallbacks.MC_USE_CARD, Runes.UseFlippedAnsuz, flippedAnsuzID)

--Rerolls items in the room into items the player already owns
--will generally avoid items that have no benefit when duplicated
---@param player EntityPlayer
function Runes:UseFlippedPerthro(_, player, _)

    local playerCollectiblesOwned = GetPlayerCollectibles(player)    

    local game = Game()
    local entities = Isaac.GetRoomEntities()
    local itemConfig = Isaac.GetItemConfig()
    local rng = RNG()
    rng:SetSeed(Game():GetSeeds():GetStartSeed(), 1)

    for _, entity in ipairs(entities) do
        if entity:ToPickup() and entity:ToPickup().Variant == PickupVariant.PICKUP_COLLECTIBLE then
            local collectible = entity:ToPickup()
            if collectible and collectible.SubType ~= CollectibleType.COLLECTIBLE_NULL then

                local eligiblePlayerCollectiblesOwned = {}

                for k, v in pairs(playerCollectiblesOwned) do
                    eligiblePlayerCollectiblesOwned[k] = v
                end

                local newItem

                repeat
                    if #eligiblePlayerCollectiblesOwned == 0 then
                        local itemPoolObj = Game():GetItemPool()
                        local roomType = Game():GetRoom():GetType()
                        local roomPool = itemPoolObj:GetPoolForRoom(roomType, rng:Next())
                        if roomPool == -1 then
                            roomPool = 0
                        end

                        newItem = itemPoolObj:GetCollectible(roomPool, true, rng:Next())
                        break
                    end

                    local randomIndex = math.random(1, #eligiblePlayerCollectiblesOwned)

                    newItem = eligiblePlayerCollectiblesOwned[randomIndex]
                    table.remove(eligiblePlayerCollectiblesOwned, randomIndex)

                until newItem and (not itemConfig:GetCollectible(newItem):HasTags(ItemConfig.TAG_QUEST)) and CollectibleIsStackable(newItem)

                collectible:Morph(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_COLLECTIBLE, newItem, true)
                Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.POOF01, 0, collectible.Position, Vector(0,0), nil)               
            end
        end
    end
end

mod:AddCallback(ModCallbacks.MC_USE_CARD, Runes.UseFlippedPerthro, flippedPerthroID)

--deletes up to 2 vanilla familiars and turns them into items from the current room's pool
function Runes:UseFlippedBerkano(_, player, _)

    --find familiars to remove
    local entities = Isaac.GetRoomEntities()
    local eligibleFamiliarCollectibles = {}
    local familiarPositions = {}

    for _, entity in ipairs(entities) do
        local familiar = entity:ToFamiliar()
        if familiar then
            
            local collectibleID = GetCollectibleFromFamiliar(familiar)
            if collectibleID ~= nil then
                table.insert(familiarPositions, familiar.Position)
                table.insert(eligibleFamiliarCollectibles, collectibleID)
            end
        end
    end

    --remove the familiars' respective collectibles from the player who used the rune
    local familiarsKilled = 0
    if #eligibleFamiliarCollectibles > 0 then
        local collectiblesToRemove = math.min(#eligibleFamiliarCollectibles, 2)
        for i = 1, collectiblesToRemove do
            local index = math.random(#eligibleFamiliarCollectibles)
            player:RemoveCollectible(eligibleFamiliarCollectibles[index])
            table.remove(eligibleFamiliarCollectibles, index)
            familiarsKilled = familiarsKilled + 1
        end
    end

    --spawn a new item from current room's pool for each familiar removed
    local rng = RNG()
    rng:SetSeed(Game():GetSeeds():GetStartSeed(), 1)
    local itemPoolObj = Game():GetItemPool()
    local roomType = Game():GetRoom():GetType()
    local roomPool = itemPoolObj:GetPoolForRoom(roomType, rng:Next())
    if roomPool == -1 then
        roomPool = 0
    end
    for i = 1, familiarsKilled do
        local collectibleID = itemPoolObj:GetCollectible(roomPool, true, rng:Next())
        Isaac.Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_COLLECTIBLE, collectibleID, familiarPositions[i], Vector(0,0), nil)
        Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.POOF04, 0, familiarPositions[i], Vector(0,0), nil)
    end
    
end

mod:AddCallback(ModCallbacks.MC_USE_CARD, Runes.UseFlippedBerkano, flippedBerkanoID)

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

mod:AddCallback(ModCallbacks.MC_USE_CARD, Runes.UseFlippedAlgiz, flippedAlgizID)

--turns all runes on the ground in the room into flipped variant
function Runes:UseFlippedBlank()
    local entities = Isaac.GetRoomEntities()
    for _, entity in ipairs(entities) do
        if entity:ToPickup() and entity:ToPickup().Variant == PickupVariant.PICKUP_TAROTCARD then
            local pickup = entity:ToPickup()
            if pickup and (pickup.SubType >= Card.RUNE_HAGALAZ and pickup.SubType <= Card.RUNE_BLACK) then
                pickup:Morph(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_TAROTCARD, GetFlippedIdFromNormal(pickup.SubType), true)
                Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.POOF01, 0, pickup.Position, Vector(0,0), nil)
            end
        end
    end
end

mod:AddCallback(ModCallbacks.MC_USE_CARD, Runes.UseFlippedBlank, flippedBlankID)

function Runes:UseFlippedBlack(_, player, _)

    local spawnablePickups = {
        {PickupVariant.PICKUP_COIN, 0},
        {PickupVariant.PICKUP_BOMB, BombSubType.BOMB_NORMAL},
        {PickupVariant.PICKUP_GRAB_BAG, SackSubType.SACK_NORMAL},
        {PickupVariant.PICKUP_KEY, 0}
    }
    
    SpawnPickups(player.Position, math.random(2,3), 2, spawnablePickups)

    
    DegradeFlippedBlackRune(player, flippedBlackID, crackedFlippedBlackID)
end

mod:AddCallback(ModCallbacks.MC_USE_CARD, Runes.UseFlippedBlack, flippedBlackID)

function Runes:UseCrackedFlippedBlack(_, player, _)

    local spawnablePickups = {
        {PickupVariant.PICKUP_TAROTCARD, 0},
        {PickupVariant.PICKUP_PILL, 0},
        {PickupVariant.PICKUP_LIL_BATTERY, 0}
    }
    
    SpawnPickups(player.Position, math.random(1,3), 3, spawnablePickups)
    DegradeFlippedBlackRune(player, crackedFlippedBlackID, brokenFlippedBlackID)
end

mod:AddCallback(ModCallbacks.MC_USE_CARD, Runes.UseCrackedFlippedBlack, crackedFlippedBlackID)

function Runes:UseBrokenFlippedBlack(_, player, _)

    local spawnablePickups = {
        {PickupVariant.PICKUP_HEART, 0},
        {PickupVariant.PICKUP_GRAB_BAG, SackSubType.SACK_BLACK},
        {PickupVariant.PICKUP_CHEST, 0}
    }

    SpawnPickups(player.Position, math.random(1,2), 3, spawnablePickups)
    DegradeFlippedBlackRune(player, brokenFlippedBlackID, shiningFlippedBlackID)
end

mod:AddCallback(ModCallbacks.MC_USE_CARD, Runes.UseBrokenFlippedBlack, brokenFlippedBlackID)

function Runes:UseShiningFlippedBlack(_, player, _)

    local spawnablePickups = {
        {PickupVariant.PICKUP_TRINKET, 0},
        {PickupVariant.PICKUP_KEY, KeySubType.KEY_GOLDEN},
        {PickupVariant.PICKUP_BOMB, BombSubType.BOMB_GOLDEN},
        {PickupVariant.PICKUP_COIN, CoinSubType.COIN_GOLDEN}
    }

    if math.random(100) < 15 then
        local pickupsSpawned = SpawnPickups(player.Position, math.random(2,3), 5, spawnablePickups)
        for i = 1, #pickupsSpawned do
            if pickupsSpawned[i]:ToPickup() then
                local pickup = pickupsSpawned[i]:ToPickup()
                if pickup.Variant == PickupVariant.PICKUP_TRINKET then
                    pickup:Morph(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_TRINKET, pickup.SubType + 0x8000)
                end
            end
        end

        player:AddCard(shiningFlippedBlackID)
        SpawnRockBreakEffect(player.Position, 6, 1)
        sfx:Play(SoundEffect.SOUND_ROCK_CRUMBLE)
        SpawnGlowEffect(player.Position)
        Game():ShakeScreen(7)
    else

        for _, entity in ipairs(Isaac.GetRoomEntities()) do
            if entity and IsMonster(entity) then
                entity:AddBurn(EntityRef(player), 130, Game():GetLevel():GetStage()*8)
            end
        end

        Isaac.Explode(player.Position, player, 100)
        SpawnRockBreakEffect(player.Position, 10, 2)
        DoBombRing(player, BombVariant.BOMB_MR_MEGA, 5, 5, 70)
        DelayFunc(5, SpawnRockBreakEffect, player.Position, 10, 1.5)
        DelayFunc(5, DoBombRing, player, BombVariant.BOMB_NORMAL, 5, 6, 60, 24)
        DelayFunc(10, SpawnRockBreakEffect, player.Position, 10, 1)
        DelayFunc(10, DoBombRing, player, BombVariant.BOMB_SMALL, 5, 7, 45, 48)

        Game():ShakeScreen(20)
        SpawnRedPoofEffect(player.Position)

        sfx:Play(SoundEffect.SOUND_EXPLOSION_STRONG, 2)
        sfx:Play(SoundEffect.SOUND_PORTAL_OPEN, 2)        
    end
end

mod:AddCallback(ModCallbacks.MC_USE_CARD, Runes.UseShiningFlippedBlack, shiningFlippedBlackID)

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

--JERA?: get a weighted random improved coin type
function GetRefinedCoin()
    local coinWeights = {
        {50, CoinSubType.COIN_PENNY},           --50%
        {70, CoinSubType.COIN_DOUBLEPACK},      --20%
        {80, CoinSubType.COIN_NICKEL},          --10%
        {87, CoinSubType.COIN_DIME},            --7%
        {92, CoinSubType.COIN_STICKYNICKEL},    --5%
        {97, CoinSubType.COIN_LUCKYPENNY},      --5%
        {100, CoinSubType.COIN_GOLDEN}          --3%
    }

    local replacementCoin = math.random(100)
    
    for _, coinData in ipairs(coinWeights) do
        if replacementCoin <= coinData[1] then
            return coinData[2], PickupVariant.PICKUP_COIN
        end
    end
    return CoinSubType.COIN_PENNY, PickupVariant.PICKUP_COIN
end

--JERA?: get a weighted random improved bomb type
function GetRefinedBomb()

    local bombWeights = {
        {42, BombSubType.BOMB_NORMAL},      --42%
        {84, BombSubType.BOMB_DOUBLEPACK},  --42%
        {89, BombSubType.BOMB_TROLL},       --5%
        {94, BombSubType.BOMB_SUPERTROLL},  --5%
        {97, BombSubType.BOMB_GOLDEN},      --3%
        {100, BombSubType.BOMB_GIGA}        --3%
    }

    local replacementBomb = math.random(100)

    for _, bombData in ipairs(bombWeights) do
        if replacementBomb <= bombData[1] then
            return bombData[2], PickupVariant.PICKUP_BOMB
        end
    end

    return BombSubType.BOMB_NORMAL, PickupVariant.PICKUP_BOMB
end

--JERA?: get a weighted random improved heart type
function GetRefinedHeart()

    local heartWeights = {
        {14, HeartSubType.HEART_HALF},          --14%
        {28, HeartSubType.HEART_FULL},          --14%
        {42, HeartSubType.HEART_DOUBLEPACK},    --14%
        {56, HeartSubType.HEART_SCARED},        --14%
        {63, HeartSubType.HEART_HALF_SOUL},     --7%
        {70, HeartSubType.HEART_SOUL},          --7%
        {77, HeartSubType.HEART_BLACK},         --7%
        {84, HeartSubType.HEART_BLENDED},       --7%
        {88, HeartSubType.HEART_GOLDEN},        --4%
        {92, HeartSubType.HEART_BONE},          --4%
        {96, HeartSubType.HEART_ETERNAL},       --4%
        {100, HeartSubType.HEART_ROTTEN}        --4%
    }

    local replacementHeart = math.random(100)
    
    for _, heartData in ipairs(heartWeights) do
        if replacementHeart <= heartData[1] then
            return heartData[2], PickupVariant.PICKUP_HEART
        end
    end

    return HeartSubType.HEART_FULL, PickupVariant.PICKUP_HEART
end

--JERA?: get a weighted random improved key type
function GetRefinedKey()

    local keyWeights = {
        {40, KeySubType.KEY_NORMAL},        --40%
        {85, KeySubType.KEY_DOUBLEPACK},    --45%
        {95, KeySubType.KEY_CHARGED},       --10%
        {100, KeySubType.KEY_GOLDEN},       --5%
    }

    local replacementKey = math.random(100)

    for _, keyData in ipairs(keyWeights) do
        if replacementKey <= keyData[1] then
            return keyData[2], PickupVariant.PICKUP_KEY
        end
    end

    return KeySubType.KEY_NORMAL, PickupVariant.PICKUP_KEY
end

--EHWAZ?: spawns a fool card in the black market so the player can get out
function Runes:OnEnterBlackMarket()
    if shouldSpawnReturnCard then
        shouldSpawnReturnCard = false

        local player = Isaac.GetPlayer(0)
        Isaac.Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_TAROTCARD, Card.CARD_FOOL, player.Position + Vector(0, 40), Vector(0,0), nil)
    end 
end

mod:AddCallback(ModCallbacks.MC_POST_NEW_ROOM, Runes.OnEnterBlackMarket)

--DAGAZ?: get a random curse that isn't already in effect
function GetRandomCurse()

    local level = Game():GetLevel()
    local currentCurses = level:GetCurses()
    local newCurse

    local allCursesPresent, _ = FlippedDagazCursesPresent()

    repeat newCurse = flippedDagazCurses[math.random(#flippedDagazCurses)]
    until newCurse & currentCurses == 0 or allCursesPresent == true

    return newCurse
end

--DAGAZ?: returns true if all curses giveable by Dagaz? are already present, false otherwise, also returns number of Dagaz? curses found
function FlippedDagazCursesPresent()

    local activeCurses = Game():GetLevel():GetCurses()
    local numCurses = 0
    for _, mask in ipairs(flippedDagazCurses) do
        if (activeCurses & mask) ~= 0 then
            numCurses = numCurses + 1
        end
    end
    if numCurses == #flippedDagazCurses then
        return true, numCurses
    end
    return false, numCurses
end

--DAGAZ?: returns the number of curses that are currently active
function GetNumActiveCurses()
    local bitMasks = {
        1, 2, 4, 8, 16, 32, 64, 128
    }
    local activeCurses = Game():GetLevel():GetCurses()
    local numCurses = 0.0
    for _, mask in ipairs(bitMasks) do
        if (activeCurses & mask) ~= 0 then
            numCurses = numCurses + 1.0
        end
    end
    return numCurses
end

--DAGAZ?: finds enemies in the room and applies a random status to them
function Runes:FlippedDagazActiveOnNewRoom()
    if flippedDagazActive ~= true or flippedDagazPlayer == nil then
        return
    end

    for _, entity in ipairs(Isaac.GetRoomEntities()) do
        if entity and IsMonster(entity) then
            ApplyRandomStatusEffect(entity, flippedDagazPlayer)
        end
    end
end

mod:AddCallback(ModCallbacks.MC_POST_NEW_ROOM, Runes.FlippedDagazActiveOnNewRoom)

--DAGAZ?: disables the floor-wide effect after changing floor and gets new floorStartCurses
function Runes:FlippedDagazResetGlobals(isContinued)
    isContinued = isContinued or false
    if isContinued == false then
        floorStartCurses = GetNumActiveCurses()
        flippedDagazActive = false
        flippedDagazPlayer = nil
    end
end

mod:AddCallback(ModCallbacks.MC_POST_NEW_LEVEL, Runes.FlippedDagazResetGlobals)
mod:AddCallback(ModCallbacks.MC_POST_GAME_STARTED, Runes.FlippedDagazResetGlobals)

--DAGAZ?: apply a random status effect to the enemy. chance to fail decreases with number of active curses
function ApplyRandomStatusEffect(enemy, source)

    local statusEffects = {
        function(e, s) e:AddFreeze(EntityRef(s), 180) end,
        function(e, s) e:AddPoison(EntityRef(s), 180, Game():GetLevel():GetStage()*3.5) end,
        function(e, s) e:AddSlowing(EntityRef(s), 300, 0.5, Color(.5,.5,.5,1,0,0,0)) end,
        function(e, s) e:AddCharmed(EntityRef(s), 600) end,
        function(e, s) e:AddConfusion(EntityRef(s), 300, true) end,
        function(e, s) e:AddFear(EntityRef(s), 300) end,
        function(e, s) e:AddBurn(EntityRef(s), 120, Game():GetLevel():GetStage()*1.75) end,
        function(e, s) e:AddMidasFreeze(EntityRef(s), 300) end
    }
    local midasIndex = #statusEffects
    --select a random effect
    local effectChosen = math.random(#statusEffects)
    --60% chance to reroll effect if midas is chosen
    if effectChosen == midasIndex and math.random(100) < 60 then
        effectChosen = math.random(#statusEffects)
    end

    local randomEffect = statusEffects[effectChosen]
    
    local activeC = GetNumActiveCurses()
    if activeC == 0 then
        return
    end
    --apply the effect. chance of applying is 1/(#activeCurses + 1)
    if enemy and randomEffect and (math.random(100) > (1.0/(activeC + 1.0))*100.0) then
        randomEffect(enemy, source)
    end
end

--DAGAZ?: Normal Dagaz grants an extra half soul heart for each curse removed after 1
function Runes:GetSoulHeartsToAddOnUseDagaz(_, player, _)
    
    if flippedDagazActive ~= true then
        return
    end
    player:AddSoulHearts(activeCurses - floorStartCurses)

    flippedDagazActive = false
    activeCurses = 0
end

mod:AddCallback(ModCallbacks.MC_USE_CARD, Runes.GetSoulHeartsToAddOnUseDagaz, Card.RUNE_DAGAZ)

--ANSUZ?: Finds and opens a path to the Usr from all valid rooms that are 2 away from it, reveals usr on map
function Runes:OpenPathToUsr()
    
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
                DelayFunc(33, SpawnDagazCenterRoom, room)
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

--PERTHRO?: returns a list of all the collectibles the player has
---@param player EntityPlayer
function GetPlayerCollectibles(player)

    local ownedCollectibles = {}

    for id = 1, numTotalCollectibles do
        if player:HasCollectible(id, true) then
            local amount = player:GetCollectibleNum(id, true)
            for i = 1, amount do
                table.insert(ownedCollectibles, id)
            end
        end
    end

    return ownedCollectibles
end

--BERKANO?: returns false if trinket, quest, or otherwise ineligible familiars are detected
function IsEligibleFamiliar(familiar)
    local familiarVar = familiar.Variant
    if familiarVar == FamiliarVariant.KEY_FULL or
    familiarVar == FamiliarVariant.KEY_PIECE_1 or
    familiarVar == FamiliarVariant.KEY_PIECE_2 or
    familiarVar == FamiliarVariant.KNIFE_FULL or
    familiarVar == FamiliarVariant.KNIFE_PIECE_1 or
    familiarVar == FamiliarVariant.KNIFE_PIECE_2 or
    familiarVar == FamiliarVariant.ISAACS_HEAD or
    familiarVar == FamiliarVariant.BLUE_BABY_SOUL or
    familiarVar == FamiliarVariant.EVES_BIRD_FOOT or
    familiarVar == FamiliarVariant.BLUE_FLY or
    familiarVar == FamiliarVariant.BLUE_SPIDER or
    familiarVar == FamiliarVariant.DIP or
    familiarVar == FamiliarVariant.MINISAAC or
    familiarVar == FamiliarVariant.WISP or
    familiarVar == FamiliarVariant.ITEM_WISP or
    familiarVar == FamiliarVariant.BONE_SPUR or
    familiarVar == FamiliarVariant.STAR_OF_BETHLEHEM or
    familiarVar == FamiliarVariant.VANISHING_TWIN or
    familiarVar == FamiliarVariant.FORGOTTEN_BODY or
    familiarVar == FamiliarVariant.DECAP_ATTACK or
    familiarVar == FamiliarVariant.PEEPER_2 or
    familiarVar == FamiliarVariant.TINYTOMA_2 or
    familiarVar == FamiliarVariant.SIREN_MINION or
    familiarVar == FamiliarVariant.BABY_PLUM or
    familiarVar == FamiliarVariant.SPIN_TO_WIN or
    familiarVar == FamiliarVariant.GUILLOTINE or
    familiarVar == FamiliarVariant.CUBE_OF_MEAT_2 or
    familiarVar == FamiliarVariant.CUBE_OF_MEAT_3 or
    familiarVar == FamiliarVariant.CUBE_OF_MEAT_4 or
    familiarVar == FamiliarVariant.BALL_OF_BANDAGES_2 or
    familiarVar == FamiliarVariant.BALL_OF_BANDAGES_3 or
    familiarVar == FamiliarVariant.BALL_OF_BANDAGES_4 or
    familiarVar == FamiliarVariant.SCISSORS or
    familiarVar == FamiliarVariant.FLY_ORBITAL or
    familiarVar == FamiliarVariant.SWARM_FLY_ORBITAL or
    familiarVar == FamiliarVariant.ABYSS_LOCUST or
    familiarVar == FamiliarVariant.SUPER_BUM or
    familiarVar == FamiliarVariant.TONSIL or
    familiarVar == FamiliarVariant.SPIDER_BABY or
    familiarVar == FamiliarVariant.BROWN_NUGGET_POOTER or
    familiarVar == FamiliarVariant.BONE_ORBITAL or
    familiarVar == FamiliarVariant.LEPROSY or
    familiarVar == FamiliarVariant.DEAD_CAT or
    familiarVar == FamiliarVariant.DAMOCLES or
    familiarVar == FamiliarVariant.ONE_UP then
        return false
    end
    return true
end

--BERKANO?: returns a collectibleID given the familiar that it spawns
function GetCollectibleFromFamiliar(familiar)
    local familiarVar = familiar.Variant
    local familiarToCollectible = {
    [FamiliarVariant.BROTHER_BOBBY] = CollectibleType.COLLECTIBLE_BROTHER_BOBBY,
    [FamiliarVariant.DEMON_BABY] = CollectibleType.COLLECTIBLE_DEMON_BABY,
    [FamiliarVariant.LITTLE_CHUBBY] = CollectibleType.COLLECTIBLE_LITTLE_CHUBBY,
    [FamiliarVariant.LITTLE_GISH] = CollectibleType.COLLECTIBLE_LITTLE_GISH,
    [FamiliarVariant.LITTLE_STEVEN] = CollectibleType.COLLECTIBLE_STEVEN,
    [FamiliarVariant.ROBO_BABY] = CollectibleType.COLLECTIBLE_ROBO_BABY,
    [FamiliarVariant.SISTER_MAGGY] = CollectibleType.COLLECTIBLE_SISTER_MAGGY,
    [FamiliarVariant.ABEL] = CollectibleType.COLLECTIBLE_ABEL,
    [FamiliarVariant.GHOST_BABY] = CollectibleType.COLLECTIBLE_GHOST_BABY,
    [FamiliarVariant.HARLEQUIN_BABY] = CollectibleType.COLLECTIBLE_HARLEQUIN_BABY,
    [FamiliarVariant.RAINBOW_BABY] = CollectibleType.COLLECTIBLE_RAINBOW_BABY,
    [FamiliarVariant.DEAD_BIRD] = CollectibleType.COLLECTIBLE_DEAD_BIRD,
    [FamiliarVariant.DADDY_LONGLEGS] = CollectibleType.COLLECTIBLE_DADDY_LONGLEGS,
    [FamiliarVariant.PEEPER] = CollectibleType.COLLECTIBLE_PEEPER,
    [FamiliarVariant.BOMB_BAG] = CollectibleType.COLLECTIBLE_BOMB_BAG,
    [FamiliarVariant.SACK_OF_PENNIES] = CollectibleType.COLLECTIBLE_SACK_OF_PENNIES,
    [FamiliarVariant.LITTLE_CHAD] = CollectibleType.COLLECTIBLE_LITTLE_CHAD,
    [FamiliarVariant.RELIC] = CollectibleType.COLLECTIBLE_RELIC,
    [FamiliarVariant.BUM_FRIEND] = CollectibleType.COLLECTIBLE_BUM_FRIEND,
    [FamiliarVariant.HOLY_WATER] = CollectibleType.COLLECTIBLE_HOLY_WATER,
    [FamiliarVariant.FOREVER_ALONE] = CollectibleType.COLLECTIBLE_FOREVER_ALONE,
    [FamiliarVariant.DISTANT_ADMIRATION] = CollectibleType.COLLECTIBLE_DISTANT_ADMIRATION,
    [FamiliarVariant.GUARDIAN_ANGEL] = CollectibleType.COLLECTIBLE_GUARDIAN_ANGEL,
    [FamiliarVariant.SACRIFICIAL_DAGGER] = CollectibleType.COLLECTIBLE_SACRIFICIAL_DAGGER,
    [FamiliarVariant.GUPPYS_HAIRBALL] = CollectibleType.COLLECTIBLE_GUPPYS_HAIRBALL,
    [FamiliarVariant.CUBE_OF_MEAT_1] = CollectibleType.COLLECTIBLE_CUBE_OF_MEAT,
    [FamiliarVariant.SMART_FLY] = CollectibleType.COLLECTIBLE_SMART_FLY,
    [FamiliarVariant.DRY_BABY] = CollectibleType.COLLECTIBLE_DRY_BABY,
    [FamiliarVariant.JUICY_SACK] = CollectibleType.COLLECTIBLE_JUICY_SACK,
    [FamiliarVariant.ROBO_BABY_2] = CollectibleType.COLLECTIBLE_ROBO_BABY_2,
    [FamiliarVariant.ROTTEN_BABY] = CollectibleType.COLLECTIBLE_ROTTEN_BABY,
    [FamiliarVariant.HEADLESS_BABY] = CollectibleType.COLLECTIBLE_HEADLESS_BABY,
    [FamiliarVariant.LEECH] = CollectibleType.COLLECTIBLE_LEECH,
    [FamiliarVariant.MYSTERY_SACK] = CollectibleType.COLLECTIBLE_MYSTERY_SACK,
    [FamiliarVariant.BBF] = CollectibleType.COLLECTIBLE_BBF,
    [FamiliarVariant.BOBS_BRAIN] = CollectibleType.COLLECTIBLE_BOBS_BRAIN,
    [FamiliarVariant.BEST_BUD] = CollectibleType.COLLECTIBLE_BEST_BUD,
    [FamiliarVariant.LIL_BRIMSTONE] = CollectibleType.COLLECTIBLE_LIL_BRIMSTONE,
    [FamiliarVariant.ISAACS_HEART] = CollectibleType.COLLECTIBLE_ISAACS_HEART,
    [FamiliarVariant.LIL_HAUNT] = CollectibleType.COLLECTIBLE_LIL_HAUNT,
    [FamiliarVariant.DARK_BUM] = CollectibleType.COLLECTIBLE_DARK_BUM,
    [FamiliarVariant.BIG_FAN] = CollectibleType.COLLECTIBLE_BIG_FAN,
    [FamiliarVariant.SISSY_LONGLEGS] = CollectibleType.COLLECTIBLE_SISSY_LONGLEGS,
    [FamiliarVariant.PUNCHING_BAG] = CollectibleType.COLLECTIBLE_PUNCHING_BAG,
    [FamiliarVariant.BALL_OF_BANDAGES_1] = CollectibleType.COLLECTIBLE_BALL_OF_BANDAGES,
    [FamiliarVariant.MONGO_BABY] = CollectibleType.COLLECTIBLE_MONGO_BABY,
    [FamiliarVariant.SAMSONS_CHAINS] = CollectibleType.COLLECTIBLE_SAMSONS_CHAINS,
    [FamiliarVariant.CAINS_OTHER_EYE] = CollectibleType.COLLECTIBLE_CAINS_OTHER_EYE,
    [FamiliarVariant.BLUEBABYS_ONLY_FRIEND] = CollectibleType.COLLECTIBLE_BLUE_BABYS_ONLY_FRIEND,
    [FamiliarVariant.GEMINI] = CollectibleType.COLLECTIBLE_GEMINI,
    [FamiliarVariant.INCUBUS] = CollectibleType.COLLECTIBLE_INCUBUS,
    [FamiliarVariant.FATES_REWARD] = CollectibleType.COLLECTIBLE_FATES_REWARD,
    [FamiliarVariant.LIL_CHEST] = CollectibleType.COLLECTIBLE_LIL_CHEST,
    [FamiliarVariant.SWORN_PROTECTOR] = CollectibleType.COLLECTIBLE_SWORN_PROTECTOR,
    [FamiliarVariant.FRIEND_ZONE] = CollectibleType.COLLECTIBLE_FRIEND_ZONE,
    [FamiliarVariant.LOST_FLY] = CollectibleType.COLLECTIBLE_LOST_FLY,
    [FamiliarVariant.CHARGED_BABY] = CollectibleType.COLLECTIBLE_CHARGED_BABY,
    [FamiliarVariant.LIL_GURDY] = CollectibleType.COLLECTIBLE_LIL_GURDY,
    [FamiliarVariant.BUMBO] = CollectibleType.COLLECTIBLE_BUMBO,
    [FamiliarVariant.CENSER] = CollectibleType.COLLECTIBLE_CENSER,
    [FamiliarVariant.KEY_BUM] = CollectibleType.COLLECTIBLE_KEY_BUM,
    [FamiliarVariant.RUNE_BAG] = CollectibleType.COLLECTIBLE_RUNE_BAG,
    [FamiliarVariant.SERAPHIM] = CollectibleType.COLLECTIBLE_SERAPHIM,
    [FamiliarVariant.GB_BUG] = CollectibleType.COLLECTIBLE_GB_BUG,
    [FamiliarVariant.SPIDER_MOD] = CollectibleType.COLLECTIBLE_SPIDER_MOD,
    [FamiliarVariant.FARTING_BABY] = CollectibleType.COLLECTIBLE_FARTING_BABY,
    [FamiliarVariant.SUCCUBUS] = CollectibleType.COLLECTIBLE_SUCCUBUS,
    [FamiliarVariant.LIL_LOKI] = CollectibleType.COLLECTIBLE_LIL_LOKI,
    [FamiliarVariant.OBSESSED_FAN] = CollectibleType.COLLECTIBLE_OBSESSED_FAN,
    [FamiliarVariant.PAPA_FLY] = CollectibleType.COLLECTIBLE_PAPA_FLY,
    [FamiliarVariant.MILK] = CollectibleType.COLLECTIBLE_MILK,
    [FamiliarVariant.MULTIDIMENSIONAL_BABY] = CollectibleType.COLLECTIBLE_MULTIDIMENSIONAL_BABY,
    [FamiliarVariant.BIG_CHUBBY] = CollectibleType.COLLECTIBLE_BIG_CHUBBY,
    [FamiliarVariant.DEPRESSION] = CollectibleType.COLLECTIBLE_DEPRESSION,
    [FamiliarVariant.SHADE] = CollectibleType.COLLECTIBLE_SHADE,
    [FamiliarVariant.HUSHY] = CollectibleType.COLLECTIBLE_HUSHY,
    [FamiliarVariant.LIL_MONSTRO] = CollectibleType.COLLECTIBLE_LIL_MONSTRO,
    [FamiliarVariant.KING_BABY] = CollectibleType.COLLECTIBLE_KING_BABY,
    [FamiliarVariant.FINGER] = CollectibleType.COLLECTIBLE_FINGER,
    [FamiliarVariant.YO_LISTEN] = CollectibleType.COLLECTIBLE_YO_LISTEN,
    [FamiliarVariant.ACID_BABY] = CollectibleType.COLLECTIBLE_ACID_BABY,
    [FamiliarVariant.SACK_OF_SACKS] = CollectibleType.COLLECTIBLE_SACK_OF_SACKS,
    [FamiliarVariant.BLOODSHOT_EYE] = CollectibleType.COLLECTIBLE_BLOODSHOT_EYE,
    [FamiliarVariant.MOMS_RAZOR] = CollectibleType.COLLECTIBLE_MOMS_RAZOR,
    [FamiliarVariant.ANGRY_FLY] = CollectibleType.COLLECTIBLE_ANGRY_FLY,
    [FamiliarVariant.BUDDY_IN_A_BOX] = CollectibleType.COLLECTIBLE_BUDDY_IN_A_BOX,
    [FamiliarVariant.LIL_HARBINGERS] = CollectibleType.COLLECTIBLE_7_SEALS,
    [FamiliarVariant.ANGELIC_PRISM] = CollectibleType.COLLECTIBLE_ANGELIC_PRISM,
    [FamiliarVariant.MYSTERY_EGG] = CollectibleType.COLLECTIBLE_MYSTERY_EGG,
    [FamiliarVariant.LIL_SPEWER] = CollectibleType.COLLECTIBLE_LIL_SPEWER,
    [FamiliarVariant.SLIPPED_RIB] = CollectibleType.COLLECTIBLE_SLIPPED_RIB,
    [FamiliarVariant.POINTY_RIB] = CollectibleType.COLLECTIBLE_POINTY_RIB,
    [FamiliarVariant.HALLOWED_GROUND] = CollectibleType.COLLECTIBLE_HALLOWED_GROUND,
    [FamiliarVariant.JAW_BONE] = CollectibleType.COLLECTIBLE_JAW_BONE,
    [FamiliarVariant.INTRUDER] = CollectibleType.COLLECTIBLE_INTRUDER,
    [FamiliarVariant.BLOOD_OATH] = CollectibleType.COLLECTIBLE_BLOOD_OATH,
    [FamiliarVariant.PSY_FLY] = CollectibleType.COLLECTIBLE_PSY_FLY,
    [FamiliarVariant.BOILED_BABY] = CollectibleType.COLLECTIBLE_BOILED_BABY,
    [FamiliarVariant.FREEZER_BABY] = CollectibleType.COLLECTIBLE_FREEZER_BABY,
    [FamiliarVariant.BIRD_CAGE] = CollectibleType.COLLECTIBLE_BIRD_CAGE,
    [FamiliarVariant.LOST_SOUL] = CollectibleType.COLLECTIBLE_LOST_SOUL,
    [FamiliarVariant.LIL_DUMPY] = CollectibleType.COLLECTIBLE_LIL_DUMPY,
    [FamiliarVariant.TINYTOMA] = CollectibleType.COLLECTIBLE_TINYTOMA,
    [FamiliarVariant.BOT_FLY] = CollectibleType.COLLECTIBLE_BOT_FLY,
    [FamiliarVariant.PASCHAL_CANDLE] = CollectibleType.COLLECTIBLE_PASCHAL_CANDLE,
    [FamiliarVariant.BLOOD_PUPPY] = CollectibleType.COLLECTIBLE_BLOOD_PUPPY,
    [FamiliarVariant.FRUITY_PLUM] = CollectibleType.COLLECTIBLE_FRUITY_PLUM,
    [FamiliarVariant.LIL_ABADDON] = CollectibleType.COLLECTIBLE_LIL_ABADDON,
    [FamiliarVariant.LIL_PORTAL] = CollectibleType.COLLECTIBLE_LIL_PORTAL,
    [FamiliarVariant.TWISTED_BABY] = CollectibleType.COLLECTIBLE_TWISTED_PAIR,
    [FamiliarVariant.WORM_FRIEND] = CollectibleType.COLLECTIBLE_WORM_FRIEND,
    }
    return familiarToCollectible[familiarVar]
end

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

--BLANK RUNE?: return flipped rune id based on the id of the normal rune
function GetFlippedIdFromNormal(subType)

    local subTypeToFlippedRuneIdMap = {
        [Card.RUNE_HAGALAZ] = flippedHagalazID,
        [Card.RUNE_JERA] = flippedJeraID,
        [Card.RUNE_EHWAZ] = flippedEhwazID,
        [Card.RUNE_DAGAZ] = flippedDagazID,
        [Card.RUNE_ANSUZ] = flippedAnsuzID,
        [Card.RUNE_PERTHRO] = flippedPerthroID,
        [Card.RUNE_BERKANO] = flippedBerkanoID,
        [Card.RUNE_ALGIZ] = flippedAlgizID,
        [Card.RUNE_BLANK] = flippedBlankID,
        [Card.RUNE_BLACK] = flippedBlackID
    }
    return subTypeToFlippedRuneIdMap[subType]
end

--BLACK RUNE?: generic function for first 3 black rune variants
function DegradeFlippedBlackRune(player, currentRuneID, nextRuneID)

    if numRecycles == -1 then
        numRecycles = math.random(2)
    end
    if numRecycles > 0 then
        player:AddCard(currentRuneID)
        numRecycles = numRecycles - 1
    else
        player:AddCard(nextRuneID)
        numRecycles = -1
    end
    Game():ShakeScreen(7)
    sfx:Play(SoundEffect.SOUND_ROCK_CRUMBLE)
    SpawnRockBreakEffect(player.Position, 6, 1)
    SpawnGlowEffect(player.Position)
end

--BLACK RUNE?: big ring of explosions
function DoBombRing(player, bombVariant, numBombs, speed, spawnRadius, angleOffset)
    angleOffset = angleOffset or 0

    if numBombs == 0 then
        return
    end

    for i = 1, numBombs do
        local angle = math.rad((i - 1) * (360/numBombs) + angleOffset)
        local bombPos = player.Position + Vector(math.cos(angle), math.sin(angle)) * spawnRadius
        local bombVelocity = Vector(math.cos(angle), math.sin(angle)) * speed
        Isaac.Spawn(EntityType.ENTITY_BOMB, bombVariant, 0, bombPos, bombVelocity, player)
    end
end

--BLACK RUNE?: prevent cracked, broken, and shining Black Rune?s from spawning naturally
function Runes:DeleteCrackedBlackRunes()
    for _, entity in ipairs(Isaac.GetRoomEntities()) do
        if entity:ToPickup() and entity:ToPickup().Variant == PickupVariant.PICKUP_TAROTCARD then
            local pickup = entity:ToPickup()
            if pickup and (pickup.SubType == crackedFlippedBlackID or pickup.SubType == brokenFlippedBlackID or pickup.SubType == shiningFlippedBlackID) then
                pickup:Remove()
                Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.BOMB_CRATER, 0, pickup.Position, Vector(0,0), nil)
            end
        end
    end
end

mod:AddCallback(ModCallbacks.MC_POST_NEW_ROOM, Runes.DeleteCrackedBlackRunes)

function Runes:RerollCrackedBlackRunes(_, card, _, _)
    if card == crackedFlippedBlackID or card == brokenFlippedBlackID or card == shiningFlippedBlackID then
        return GetRandomFlippedRune()
    end
end

mod:AddCallback(ModCallbacks.MC_GET_CARD, Runes.RerollCrackedBlackRunes)

--BLACK RUNE?: calls SelfDestructCrackedBlackRunes with a delay so the rune appears to explode when it hits the ground
function Runes:DelaySelfDestructCrackedBlackRunes(pickup)
    DelayFunc(25, SelfDestructCrackedBlackRunes, pickup)
end

mod:AddCallback(ModCallbacks.MC_POST_PICKUP_INIT, Runes.DelaySelfDestructCrackedBlackRunes)

--BLACK RUNE?: explodes and destroys cracked, broken, and shining Black Rune?s on being dropped on the ground
function SelfDestructCrackedBlackRunes(pickup)
    if pickup and (pickup.SubType == crackedFlippedBlackID or pickup.SubType == brokenFlippedBlackID or pickup.SubType == shiningFlippedBlackID) then
        Isaac.Explode(pickup.Position, pickup, 0)
        pickup:Remove()
        SpawnRockBreakEffect(pickup.Position, 30, 2)
    end
end

--BLACK RUNE?: causes [numPickups] to appear at [position] and move outward at [intensity] speed
function SpawnPickups(position, numPickups, intensity, pickupsList)

    local pickupsSpawned = {}

    for i = 1, numPickups do
        local randomIndex = math.random(#pickupsList)
        local selectedPickup = pickupsList[randomIndex]

        local pickupVariant = selectedPickup[1]
        local subType = selectedPickup[2]
        local velocity = Vector(math.random(-3*intensity, 3*intensity), math.random(-3*intensity, 3*intensity))
        local spawned = Isaac.Spawn(EntityType.ENTITY_PICKUP, pickupVariant, subType, position, velocity, nil)
        table.insert(pickupsSpawned, spawned)
    end
    return pickupsSpawned
end

--BLACK RUNE?: causes [numrocks] particles to appear at the player's feet and move outward at [intensity] speed
function SpawnRockBreakEffect(position, numRocks, intensity)
    for i = 1, numRocks do -- Spawn multiple rock fragments
        local velocity = Vector(math.random(-10*intensity, 10*intensity), math.random(-10*intensity, 10*intensity)) --randomized debris movement
        Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.ROCK_PARTICLE, 0, position, velocity, nil)
    end
end

--BLACK RUNE?: causes a short red poof at position
function SpawnRedPoofEffect(position)
    Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.POOF02, 0, position, Vector(0,0), nil)
end

--BLACK RUNE?: causes a short white glow at position
function SpawnGlowEffect(position)
    Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.GROUND_GLOW, 0, position, Vector(0,0), nil)
end

--BLACK RUNE?: Prevent black runes from being mimicked by Clear Rune
---@param player EntityPlayer
function Runes:DontMimic(_, _, player)
    sfx = SFXManager()
    if player:GetCard(0) == flippedBlackID or player:GetCard(0) == crackedFlippedBlackID or
    player:GetCard(0) == brokenFlippedBlackID or player:GetCard(0) == shiningFlippedBlackID then
        sfx:Play(SoundEffect.SOUND_THUMBS_DOWN)
        return true
    end
end

mod:AddCallback(ModCallbacks.MC_PRE_USE_ITEM, Runes.DontMimic, CollectibleType.COLLECTIBLE_CLEAR_RUNE)

--BLACK RUNE?: resets globals
function Runes:FlippedBlackResetGlobals(isContinued)
    isContinued = isContinued or false
    if isContinued == false then
        numRecycles = -1
    end
end

mod:AddCallback(ModCallbacks.MC_POST_GAME_STARTED, Runes.FlippedBlackResetGlobals)

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

--GENERIC: returns a random flipped rune
function GetRandomFlippedRune()
    local flippedRunes = {
        flippedHagalazID,
        flippedJeraID,
        flippedEhwazID,
        flippedDagazID,
        flippedAnsuzID,
        flippedPerthroID,
        flippedBerkanoID,
        flippedAlgizID,
        flippedBlankID,
        flippedBlackID,
    }
    return flippedRunes[math.random(10)]
end