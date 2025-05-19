FlippedRunes = RegisterMod("Flipped Runes", 1)
local mod = FlippedRunes
local Runes = {}

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

--rerolls basic pickups into more advanced forms (less chance for coins)
function Runes:UseFlippedJera()
    local game = Game()
    local room = game:GetRoom()
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
                pickup:Morph(EntityType.ENTITY_PICKUP, refinedPickupVariant, refinedPickup)
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
        --level:ChangeRoom(blackMarketIndex)
        game:StartRoomTransition(blackMarketIndex, Direction.NO_DIRECTION, RoomTransitionAnim.TELEPORT)
        Runes.shouldSpawnReturnCard = true
    else
        print("No Black Market exists on this floor!")
    end
end

mod:AddCallback(ModCallbacks.MC_USE_CARD, Runes.UseFlippedEhwaz, flippedEhwazID)

--EHWAZ?: spawns a fool card in the black market so the player can get out
function Runes:OnEnterBlackMarket()
    if Runes.shouldSpawnReturnCard then
        Runes.shouldSpawnReturnCard = false

        local player = Isaac.GetPlayer(0)
        Isaac.Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_TAROTCARD, Card.CARD_FOOL, player.Position + Vector(0, 40), Vector(0,0), nil)
    end 
end

mod:AddCallback(ModCallbacks.MC_POST_NEW_ROOM, Runes.OnEnterBlackMarket)

--adds a random curse to the current floor
function Runes:UseFlippedDagaz(card, player, flags)
    local level = Game():GetLevel()
    local newCurse = GetRandomCurse()
    level:AddCurse(newCurse, false)
    Runes.isFlippedDagazActive = true
    Runes.Player = player
end

mod:AddCallback(ModCallbacks.MC_USE_CARD, Runes.UseFlippedDagaz, flippedDagazID)

function Runes:OnNewRoomFlippedDagazActive()
    if Runes.isFlippedDagazActive ~= true or Runes.Player == nil then
        return
    end

    for _, entity in ipairs(Isaac.GetRoomEntities()) do
        if entity and entity.IsActiveEnemy and entity.IsVulnerableEnemy and entity.Type >= EntityType.ENTITY_GAPER and entity.Type <= EntityType.ENTITY_BEAST then
            ApplyRandomStatusEffect(entity, Runes.Player)
        end
    end
end

mod:AddCallback(ModCallbacks.MC_POST_NEW_ROOM, Runes.OnNewRoomFlippedDagazActive)

function Runes:DisableFlippedDagaz()
    Runes.isFlippedDagazActive = false
    print("isFlippedDagazActive: " .. tostring(Runes.isFlippedDagazActive))
end

mod:AddCallback(ModCallbacks.MC_POST_NEW_LEVEL, Runes.DisableFlippedDagaz)

--redesign
function Runes:UseFlippedAnsuz()

    Runes.toggleSpecialRedRoomSearch = true
    local level = Game():GetLevel()
    --find usr
    local ultraSecretIndex = level:QueryRoomTypeIndex(RoomType.ROOM_ULTRASECRET, true, RNG(), true)

    --if usr exists, reveal it on map
    if ultraSecretIndex and ultraSecretIndex ~= -1 then
        level:GetRoomByIdx(ultraSecretIndex).DisplayFlags = 100
    end
    
    level:ApplyBlueMapEffect()
    level:UpdateVisibility()      
end

mod:AddCallback(ModCallbacks.MC_USE_CARD, Runes.UseFlippedAnsuz, flippedAnsuzID)

--add poof fx
--change max loops
--add eid support
function Runes:UseFlippedPerthro()
    --print("Using Flipped Perthro!")
    local game = Game()
    local room = game:GetRoom()
    local entities = Isaac.GetRoomEntities()

    for _, entity in ipairs(entities) do
        if entity:ToPickup() and entity:ToPickup().Variant == PickupVariant.PICKUP_COLLECTIBLE then
            --print("found pedestal item")
            local itemConfig = Isaac.GetItemConfig() --establish config
            local itemQuality
            local pedestalItem = entity:ToPickup() --obj for the pedestal
            if pedestalItem and pedestalItem.SubType then
            local item = itemConfig:GetCollectible(pedestalItem.SubType) --obj for specific item on the pedestal
            if item then
                itemQuality = item.Quality --quality of the item
                --print("Item quality: " .. tostring(itemQuality))
            else
                --print("Error: Could not retrieve item data for ID " .. tostring(pedestalItem.SubType))
            end
        else
            --print("Error: pedestalItem or its SubType is nil.")
        end
            local itemPoolObj = Game():GetItemPool() --get item pool obj
            local roomType = room:GetType() --get room type
            local rng = RNG() --init rng
            rng:SetSeed(Game():GetSeeds():GetStartSeed(), 1) --set rng seed
            local roomPool = itemPoolObj:GetPoolForRoom(roomType, rng:Next()) --get pool based on room
            if roomPool == -1 then
                roomPool = 0
            end

            local newItem = GetItemOfQualityFromPool(itemQuality, roomPool)
            if pedestalItem and newItem then
                --print("new item id: " .. tostring(newItem))
                pedestalItem:Morph(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_COLLECTIBLE, newItem)
            else
                --print("Error: Cannot morph, pedestalItem or newItem is nil.")
            end
        end
    end
end

mod:AddCallback(ModCallbacks.MC_USE_CARD, Runes.UseFlippedPerthro, flippedPerthroID)

--add visual effect to killed familiars
--add eid
--deletes up to 2 vanilla familiars and turns them into items from the current room's pool
function Runes:UseFlippedBerkano(card, player, flags)
    --print("using berkano?")
    --find familiars to remove
    local entities = Isaac.GetRoomEntities()
    local eligibleFamiliarCollectibles = {}
    local familiarPositions = {}
    for _, entity in ipairs(entities) do
        local familiar = entity:ToFamiliar()
        if familiar then
            --print("found a familiar")
            
            local collectibleID = GetCollectibleFromFamiliar(familiar)
            if collectibleID ~= nil then
                --print("familiar is eligible for removal")
                table.insert(familiarPositions, familiar.Position)
                table.insert(eligibleFamiliarCollectibles, collectibleID)
            end
            --print("familiar wasn't eligible for removal")
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
    end
    
end

mod:AddCallback(ModCallbacks.MC_USE_CARD, Runes.UseFlippedBerkano, flippedBerkanoID)


--turns all runes on the ground in the room into flipped variant
function Runes:UseFlippedBlank()
    print("using flipped blank")
    local entities = Isaac.GetRoomEntities()
    for _, entity in ipairs(entities) do
        if entity:ToPickup() and entity:ToPickup().Variant == PickupVariant.PICKUP_TAROTCARD then
            print("found a card pickup")
            local pickup = entity:ToPickup()
            if pickup and (pickup.SubType >= Card.RUNE_HAGALAZ and pickup.SubType <= Card.RUNE_BLACK) then
                print("found a vanilla rune")
                pickup:Morph(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_TAROTCARD, GetFlippedIdFromNormal(pickup.SubType))
                print("changed rune to flipped version")
            end
        end
    end
end

mod:AddCallback(ModCallbacks.MC_USE_CARD, Runes.UseFlippedBlank, flippedBlankID)

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
            --print("returning coin subtype: " .. tostring(coinData[2]))
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

--DAGAZ?: get a random curse that isn't already in effect
function GetRandomCurse()
    local curses = {
        LevelCurse.CURSE_OF_DARKNESS,
        LevelCurse.CURSE_OF_THE_LOST,
        LevelCurse.CURSE_OF_THE_UNKNOWN,
        LevelCurse.CURSE_OF_MAZE,
        LevelCurse.CURSE_OF_BLIND
    }

    local level = Game():GetLevel()
    local currentCurses = level:GetCurses()
    local newCurse

    repeat newCurse = curses[math.random(#curses)]
    until newCurse & currentCurses == 0 or currentCurses == 109

    return newCurse
end

--DAGAZ?: returns the number of curses that are currently active.
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
    

    --apply the effect 
    if enemy and randomEffect and (math.random(100) > (1.0/(GetNumActiveCurses() + 1.0))*100.0) then
        randomEffect(enemy, source)
    end
end

--PERTHRO?: attempts to find an item with same quality from the current room's pool
function GetItemOfQualityFromPool(quality, pool)
    --print("selected pool type: " .. tostring(pool))
    local rng = RNG()
    rng:SetSeed(Game():GetSeeds():GetStartSeed(), 1)
    local itemPoolObj = Game():GetItemPool()
    local item
    local count = 0
    while count < 200 do
        item = itemPoolObj:GetCollectible(pool, false, rng:Next()) --pull item from pool
        --print("pulled item id: " .. tostring(item))
        if item == nil then
            --print("could not get collectible from pool")
            return nil
        end
        local itemConfig = Isaac.GetItemConfig() --make configobj
        local itemData = itemConfig:GetCollectible(item) --get data of the item
        if itemData == nil then
            --print("could not get collectible " .. tostring(item))
            return nil
        end
        local itemQuality = itemData.Quality --get quality of the item
        if itemQuality == quality then --found an item of same quality
            itemPoolObj:RemoveCollectible(item) --remove it from pool
            return item
        end
        count = count + 1
    end
    itemPoolObj:RemoveCollectible(item)
    return item
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
    print("passing in " .. familiarVar)
    return familiarToCollectible[familiarVar]
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