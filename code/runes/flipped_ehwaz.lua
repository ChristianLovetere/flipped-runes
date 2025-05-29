local mod = FlippedRunes
local FlippedEhwaz = {}

local flippedEhwazSfx = Isaac.GetSoundIdByName("flippedEhwaz")

--Ehwaz? globals
local g_shouldSpawnReturnCard = nil

--teleports Isaac to the Black Market and spawns a 0 - The Fool card to let him teleport back out of it
function FlippedEhwaz:UseFlippedEhwaz()

    if REPENTOGON then
        ItemOverlay.Show(mod.flippedEhwazGbook)
        SFXManager():Play(flippedEhwazSfx)
    else
        mod:PlayOverlay("flippedEhwaz.png", mod.OverlayColors, flippedEhwazSfx)
    end
    

    local game = Game()
    local level = game:GetLevel()
    
    -- Get the Black Market's room index (if available)
    local blackMarketIndex = level:QueryRoomTypeIndex(RoomType.ROOM_BLACK_MARKET, false, RNG())
    
    if blackMarketIndex then
        game:StartRoomTransition(blackMarketIndex, Direction.NO_DIRECTION, RoomTransitionAnim.TELEPORT)
        g_shouldSpawnReturnCard = true
    end
end

mod:AddCallback(ModCallbacks.MC_USE_CARD, FlippedEhwaz.UseFlippedEhwaz, mod.flippedEhwazID)

--EHWAZ?: spawns a fool card in the black market so the player can get out
function FlippedEhwaz:OnEnterBlackMarket()
    if g_shouldSpawnReturnCard then
        g_shouldSpawnReturnCard = false

        local player = Isaac.GetPlayer(0)
        Game():Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_TAROTCARD, player.Position + Vector(0, 40), Vector(0,0), nil, Card.CARD_FOOL, mod:SafeRandom())
    end 
end

mod:AddCallback(ModCallbacks.MC_POST_NEW_ROOM, FlippedEhwaz.OnEnterBlackMarket)
