local mod = FlippedRunes
local Runes = {}

FlippedBlankID = Isaac.GetCardIdByName("Blank Rune?")

local flippedBlackSfx = Isaac.GetSoundIdByName("flippedBlack")

--turns all runes on the ground in the room into flipped variant
function Runes:UseFlippedBlank()
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

mod:AddCallback(ModCallbacks.MC_USE_CARD, Runes.UseFlippedBlank, FlippedBlankID)

--BLANK RUNE?: return flipped rune id based on the id of the normal rune
function GetFlippedIdFromNormal(subType)

    local subTypeToFlippedRuneIdMap = {
        [Card.RUNE_HAGALAZ] = FlippedHagalazID,
        [Card.RUNE_JERA] = FlippedJeraID,
        [Card.RUNE_EHWAZ] = FlippedEhwazID,
        [Card.RUNE_DAGAZ] = FlippedDagazID,
        [Card.RUNE_ANSUZ] = FlippedAnsuzID,
        [Card.RUNE_PERTHRO] = FlippedPerthroID,
        [Card.RUNE_BERKANO] = FlippedBerkanoID,
        [Card.RUNE_ALGIZ] = FlippedAlgizID,
        [Card.RUNE_BLANK] = FlippedBlankID,
        [Card.RUNE_BLACK] = FlippedBlackID
    }
    return subTypeToFlippedRuneIdMap[subType]
end