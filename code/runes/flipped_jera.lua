local mod = FlippedRunes
local FlippedJera = {}

local flippedJeraSfx = Isaac.GetSoundIdByName("flippedJera")

--rerolls basic pickups into more advanced forms (less chance for coins)
function FlippedJera:UseFlippedJera()

    mod:PlayOverlay("flippedJera.png", mod.OverlayColors, flippedJeraSfx)

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

mod:AddCallback(ModCallbacks.MC_USE_CARD, FlippedJera.UseFlippedJera, mod.flippedJeraID)

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