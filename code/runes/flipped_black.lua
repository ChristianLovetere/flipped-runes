local mod = FlippedRunes
local Runes = {}

FlippedBlackID = Isaac.GetCardIdByName("Black Rune?")
CrackedFlippedBlackID = Isaac.GetCardIdByName("Black Rune..?")
BrokenFlippedBlackID = Isaac.GetCardIdByName("Black Rune...")
ShiningFlippedBlackID = Isaac.GetCardIdByName("Black Rune!?")

--Black Rune? globals
local numRecycles = -1

function Runes:UseFlippedBlack(_, player, _)

    local spawnablePickups = {
        {PickupVariant.PICKUP_COIN, 0},
        {PickupVariant.PICKUP_BOMB, BombSubType.BOMB_NORMAL},
        {PickupVariant.PICKUP_GRAB_BAG, SackSubType.SACK_NORMAL},
        {PickupVariant.PICKUP_KEY, 0}
    }
    
    SpawnPickups(player.Position, math.random(2,3), 2, spawnablePickups)
    DegradeFlippedBlackRune(player, FlippedBlackID, CrackedFlippedBlackID)
end

mod:AddCallback(ModCallbacks.MC_USE_CARD, Runes.UseFlippedBlack, FlippedBlackID)

function Runes:UseCrackedFlippedBlack(_, player, _)

    local spawnablePickups = {
        {PickupVariant.PICKUP_TAROTCARD, 0},
        {PickupVariant.PICKUP_PILL, 0},
        {PickupVariant.PICKUP_LIL_BATTERY, 0}
    }
    
    SpawnPickups(player.Position, math.random(1,3), 3, spawnablePickups)
    DegradeFlippedBlackRune(player, CrackedFlippedBlackID, BrokenFlippedBlackID)
end

mod:AddCallback(ModCallbacks.MC_USE_CARD, Runes.UseCrackedFlippedBlack, CrackedFlippedBlackID)

function Runes:UseBrokenFlippedBlack(_, player, _)

    local spawnablePickups = {
        {PickupVariant.PICKUP_HEART, 0},
        {PickupVariant.PICKUP_GRAB_BAG, SackSubType.SACK_BLACK},
        {PickupVariant.PICKUP_CHEST, 0}
    }

    SpawnPickups(player.Position, math.random(1,2), 3, spawnablePickups)
    DegradeFlippedBlackRune(player, BrokenFlippedBlackID, ShiningFlippedBlackID)
end

mod:AddCallback(ModCallbacks.MC_USE_CARD, Runes.UseBrokenFlippedBlack, BrokenFlippedBlackID)

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

        local sfx = SFXManager()

        player:AddCard(ShiningFlippedBlackID)
        SpawnRockBreakEffect(player.Position, 6, 1)
        sfx:Play(SoundEffect.SOUND_ROCK_CRUMBLE)
        SpawnGlowEffect(player.Position)
        Game():ShakeScreen(7)
    else

        for _, entity in ipairs(Isaac.GetRoomEntities()) do
            if entity and FlippedRunes:IsMonster(entity) then
                entity:AddBurn(EntityRef(player), 130, Game():GetLevel():GetStage()*8)
            end
        end

        Isaac.Explode(player.Position, player, 100)
        SpawnRockBreakEffect(player.Position, 10, 2)
        DoBombRing(player, BombVariant.BOMB_MR_MEGA, 5, 5, 70)
        FlippedRunes:DelayFunc(5, SpawnRockBreakEffect, player.Position, 10, 1.5)
        FlippedRunes:DelayFunc(5, DoBombRing, player, BombVariant.BOMB_NORMAL, 5, 6, 60, 24)
        FlippedRunes:DelayFunc(10, SpawnRockBreakEffect, player.Position, 10, 1)
        FlippedRunes:DelayFunc(10, DoBombRing, player, BombVariant.BOMB_SMALL, 5, 7, 45, 48)

        Game():ShakeScreen(20)
        SpawnRedPoofEffect(player.Position)

        local sfx = SFXManager()
        sfx:Play(SoundEffect.SOUND_EXPLOSION_STRONG, 2)
        sfx:Play(SoundEffect.SOUND_PORTAL_OPEN, 2)        
    end
end

mod:AddCallback(ModCallbacks.MC_USE_CARD, Runes.UseShiningFlippedBlack, ShiningFlippedBlackID)

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

    local sfx = SFXManager()

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
            if pickup and (pickup.SubType == CrackedFlippedBlackID or pickup.SubType == BrokenFlippedBlackID or pickup.SubType == ShiningFlippedBlackID) then
                pickup:Remove()
                Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.BOMB_CRATER, 0, pickup.Position, Vector(0,0), nil)
            end
        end
    end
end

mod:AddCallback(ModCallbacks.MC_POST_NEW_ROOM, Runes.DeleteCrackedBlackRunes)

--BLACK RUNE?: when one of the unstable black runes spawn, reroll them into another flipped rune
function Runes:RerollCrackedBlackRunes(_, card, _, _)
    if card == CrackedFlippedBlackID or card == BrokenFlippedBlackID or card == ShiningFlippedBlackID then
        return GetRandomFlippedRune()
    end
end

mod:AddCallback(ModCallbacks.MC_GET_CARD, Runes.RerollCrackedBlackRunes)

--BLACK RUNE?: calls SelfDestructCrackedBlackRunes with a delay so the rune appears to explode when it hits the ground
function Runes:DelaySelfDestructCrackedBlackRunes(pickup)
    FlippedRunes:DelayFunc(25, SelfDestructCrackedBlackRunes, pickup)
end

mod:AddCallback(ModCallbacks.MC_POST_PICKUP_INIT, Runes.DelaySelfDestructCrackedBlackRunes)

--BLACK RUNE?: explodes and destroys cracked, broken, and shining Black Rune?s on being dropped on the ground
function SelfDestructCrackedBlackRunes(pickup)
    if pickup and (pickup.SubType == CrackedFlippedBlackID or pickup.SubType == BrokenFlippedBlackID or pickup.SubType == ShiningFlippedBlackID) then
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

    local sfx = SFXManager()
    if player:GetCard(0) == FlippedBlackID or player:GetCard(0) == CrackedFlippedBlackID or
    player:GetCard(0) == BrokenFlippedBlackID or player:GetCard(0) == ShiningFlippedBlackID then
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

--BlACK RUNE?: returns a random flipped rune
function GetRandomFlippedRune()
    local flippedRunes = {
        FlippedHagalazID,
        FlippedJeraID,
        FlippedEhwazID,
        FlippedDagazID,
        FlippedAnsuzID,
        FlippedPerthroID,
        FlippedBerkanoID,
        FlippedAlgizID,
        FlippedBlankID,
        FlippedBlackID,
    }
    return flippedRunes[math.random(10)]
end