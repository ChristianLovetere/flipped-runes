local mod = FlippedRunes
local FlippedBlack = {}

local flippedBlackSfx = Isaac.GetSoundIdByName("flippedBlack")

local sfx = SFXManager()

--Black Rune? globals
local g_numRecycles = -1

function FlippedBlack:UseFlippedBlack(_, player, _)

    local spawnablePickups = {
        {PickupVariant.PICKUP_COIN, 0},
        {PickupVariant.PICKUP_BOMB, BombSubType.BOMB_NORMAL},
        {PickupVariant.PICKUP_GRAB_BAG, SackSubType.SACK_NORMAL},
        {PickupVariant.PICKUP_KEY, 0}
    }
    
    SpawnPickups(player.Position, math.random(2,3), 2, spawnablePickups)
    DegradeFlippedBlackRune(player, mod.flippedBlackID, mod.crackedFlippedBlackID)
end

mod:AddCallback(ModCallbacks.MC_USE_CARD, FlippedBlack.UseFlippedBlack, mod.flippedBlackID)

function FlippedBlack:UseCrackedFlippedBlack(_, player, _)

    local spawnablePickups = {
        {PickupVariant.PICKUP_TAROTCARD, 0},
        {PickupVariant.PICKUP_PILL, 0},
        {PickupVariant.PICKUP_LIL_BATTERY, 0}
    }
    
    SpawnPickups(player.Position, math.random(1,3), 3, spawnablePickups)
    DegradeFlippedBlackRune(player, mod.crackedFlippedBlackID, mod.brokenFlippedBlackID)
end

mod:AddCallback(ModCallbacks.MC_USE_CARD, FlippedBlack.UseCrackedFlippedBlack, mod.crackedFlippedBlackID)

function FlippedBlack:UseBrokenFlippedBlack(_, player, _)

    local spawnablePickups = {
        {PickupVariant.PICKUP_HEART, 0},
        {PickupVariant.PICKUP_GRAB_BAG, SackSubType.SACK_BLACK},
        {PickupVariant.PICKUP_CHEST, 0}
    }

    SpawnPickups(player.Position, math.random(1,2), 3, spawnablePickups)
    DegradeFlippedBlackRune(player, mod.brokenFlippedBlackID, mod.shiningFlippedBlackID)
end

mod:AddCallback(ModCallbacks.MC_USE_CARD, FlippedBlack.UseBrokenFlippedBlack, mod.brokenFlippedBlackID)

function FlippedBlack:UseShiningFlippedBlack(_, player, _)

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

        player:AddCard(mod.shiningFlippedBlackID)
        SpawnRockBreakEffect(player.Position, 6, 1)
        sfx:Play(SoundEffect.SOUND_ROCK_CRUMBLE)
        SpawnGlowEffect(player.Position)
        Game():ShakeScreen(7)
    else

        mod:DelayFunc(60, FlippedBlack.PlayVoiceover)

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

        sfx:Play(SoundEffect.SOUND_EXPLOSION_STRONG, 2)
        sfx:Play(SoundEffect.SOUND_PORTAL_OPEN, 2)        
    end
end

mod:AddCallback(ModCallbacks.MC_USE_CARD, FlippedBlack.UseShiningFlippedBlack, mod.shiningFlippedBlackID)

--Black RUNE?: Delayable func for playing voiceover
function FlippedBlack:PlayVoiceover()
    SFXManager():Play(flippedBlackSfx, 2)
end

--BLACK RUNE?: generic function for first 3 black rune variants
function DegradeFlippedBlackRune(player, currentRuneID, nextRuneID)

    if g_numRecycles == -1 then
        g_numRecycles = math.random(2)
    end
    if g_numRecycles > 0 then
        player:AddCard(currentRuneID)
        g_numRecycles = g_numRecycles - 1
    else
        player:AddCard(nextRuneID)
        g_numRecycles = -1
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
        Game():Spawn(EntityType.ENTITY_BOMB, bombVariant, bombPos, bombVelocity, player, 0, mod:SafeRandom())
    end
end

--BLACK RUNE?: prevent cracked, broken, and shining Black Rune?s from spawning naturally
function FlippedBlack:DeleteCrackedBlackRunes()
    for _, entity in ipairs(Isaac.GetRoomEntities()) do
        if entity:ToPickup() and entity:ToPickup().Variant == PickupVariant.PICKUP_TAROTCARD then
            local pickup = entity:ToPickup()
            if pickup and (pickup.SubType == mod.crackedFlippedBlackID or pickup.SubType == mod.brokenFlippedBlackID or pickup.SubType == mod.shiningFlippedBlackID) then
                pickup:Remove()
                Game():Spawn(EntityType.ENTITY_EFFECT, EffectVariant.BOMB_CRATER, pickup.Position, Vector(0,0), nil, 0, mod:SafeRandom())
            end
        end
    end
end

mod:AddCallback(ModCallbacks.MC_POST_NEW_ROOM, FlippedBlack.DeleteCrackedBlackRunes)

--BLACK RUNE?: when one of the unstable black runes spawn, reroll them into another flipped rune
function FlippedBlack:RerollCrackedBlackRunes(_, card, _, _)
    if card == mod.crackedFlippedBlackID or card == mod.brokenFlippedBlackID or card == mod.shiningFlippedBlackID then
        return GetRandomFlippedRune()
    end
end

mod:AddCallback(ModCallbacks.MC_GET_CARD, FlippedBlack.RerollCrackedBlackRunes)

--BLACK RUNE?: calls SelfDestructCrackedBlackRunes with a delay so the rune appears to explode when it hits the ground
function FlippedBlack:DelaySelfDestructCrackedBlackRunes(pickup)
    FlippedRunes:DelayFunc(25, SelfDestructCrackedBlackRunes, pickup)
end

mod:AddCallback(ModCallbacks.MC_POST_PICKUP_INIT, FlippedBlack.DelaySelfDestructCrackedBlackRunes)

--BLACK RUNE?: explodes and destroys cracked, broken, and shining Black Rune?s on being dropped on the ground
function SelfDestructCrackedBlackRunes(pickup)
    if pickup and pickup.Variant == PickupVariant.PICKUP_TAROTCARD and (pickup.SubType == mod.crackedFlippedBlackID or pickup.SubType == mod.brokenFlippedBlackID or pickup.SubType == mod.shiningFlippedBlackID) then
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
        local spawned = Game():Spawn(EntityType.ENTITY_PICKUP, pickupVariant, position, velocity, nil, subType, mod:SafeRandom())
        table.insert(pickupsSpawned, spawned)
    end
    return pickupsSpawned
end

--BLACK RUNE?: causes [numrocks] particles to appear at the player's feet and move outward at [intensity] speed
function SpawnRockBreakEffect(position, numRocks, intensity)
    for i = 1, numRocks do -- Spawn multiple rock fragments
        local velocity = Vector(math.random(-10*intensity, 10*intensity), math.random(-10*intensity, 10*intensity)) --randomized debris movement
        Game():Spawn(EntityType.ENTITY_EFFECT, EffectVariant.ROCK_PARTICLE, position, velocity, nil, 0, mod:SafeRandom())
    end
end

--BLACK RUNE?: causes a short red poof at position
function SpawnRedPoofEffect(position)
    Game():Spawn(EntityType.ENTITY_EFFECT, EffectVariant.POOF02, position, Vector(0,0), nil, 0, mod:SafeRandom())
end

--BLACK RUNE?: causes a short white glow at position
function SpawnGlowEffect(position)
    Game():Spawn(EntityType.ENTITY_EFFECT, EffectVariant.GROUND_GLOW, position, Vector(0,0), nil, 0, mod:SafeRandom())
end

--BLACK RUNE?: Prevent black runes from being mimicked by Clear Rune
---@param player EntityPlayer
function FlippedBlack:DontMimic(_, _, player)

    if player:GetCard(0) == mod.flippedBlackID or player:GetCard(0) == mod.crackedFlippedBlackID or
    player:GetCard(0) == mod.brokenFlippedBlackID or player:GetCard(0) == mod.shiningFlippedBlackID then
        sfx:Play(SoundEffect.SOUND_THUMBS_DOWN)
        return true
    end
end

mod:AddCallback(ModCallbacks.MC_PRE_USE_ITEM, FlippedBlack.DontMimic, CollectibleType.COLLECTIBLE_CLEAR_RUNE)

--BLACK RUNE?: resets globals
function FlippedBlack:FlippedBlackResetGlobals(isContinued)
    isContinued = isContinued or false
    if isContinued == false then
        g_numRecycles = -1
    end
end

mod:AddCallback(ModCallbacks.MC_POST_GAME_STARTED, FlippedBlack.FlippedBlackResetGlobals)

--BlACK RUNE?: returns a random flipped rune
function GetRandomFlippedRune()
    local flippedRunes = {
        mod.flippedHagalazID,
        mod.flippedJeraID,
        mod.flippedEhwazID,
        mod.flippedDagazID,
        mod.flippedAnsuzID,
        mod.flippedPerthroID,
        mod.flippedBerkanoID,
        mod.flippedAlgizID,
        mod.flippedBlankID,
        mod.flippedBlackID,
    }
    return flippedRunes[math.random(10)]
end