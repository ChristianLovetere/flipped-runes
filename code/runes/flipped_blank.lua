local mod = FlippedRunes
local FlippedBlank = {}

--turns all runes on the ground in the room into flipped variant
function FlippedBlank:UseFlippedBlank()
    local entities = Isaac.GetRoomEntities()
    for _, entity in ipairs(entities) do
        if entity:ToPickup() and entity:ToPickup().Variant == PickupVariant.PICKUP_TAROTCARD then
            local pickup = entity:ToPickup()
            if pickup and (pickup.SubType >= Card.RUNE_HAGALAZ and pickup.SubType <= Card.RUNE_BLACK) then
                pickup:Morph(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_TAROTCARD, GetFlippedIdFromNormal(pickup.SubType), true)
                Game():Spawn(EntityType.ENTITY_EFFECT, EffectVariant.POOF01, pickup.Position, Vector(0,0), nil, 0, mod:SafeRandom())
            end
        end
    end
end

mod:AddCallback(ModCallbacks.MC_USE_CARD, FlippedBlank.UseFlippedBlank, mod.flippedBlankID)

--BLANK RUNE?: return flipped rune id based on the id of the normal rune
function GetFlippedIdFromNormal(subType)

    local subTypeToFlippedRuneIdMap = {
        [Card.RUNE_HAGALAZ] = mod.flippedHagalazID,
        [Card.RUNE_JERA] = mod.flippedJeraID,
        [Card.RUNE_EHWAZ] = mod.flippedEhwazID,
        [Card.RUNE_DAGAZ] = mod.flippedDagazID,
        [Card.RUNE_ANSUZ] = mod.flippedAnsuzID,
        [Card.RUNE_PERTHRO] = mod.flippedPerthroID,
        [Card.RUNE_BERKANO] = mod.flippedBerkanoID,
        [Card.RUNE_ALGIZ] = mod.flippedAlgizID,
        [Card.RUNE_BLANK] = mod.flippedBlankID,
        [Card.RUNE_BLACK] = mod.flippedBlackID
    }
    return subTypeToFlippedRuneIdMap[subType]
end