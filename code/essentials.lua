local mod = FlippedRunes

mod.flippedHagalazID = Isaac.GetCardIdByName("Hagalaz?")
mod.flippedJeraID = Isaac.GetCardIdByName("Jera?")
mod.flippedEhwazID = Isaac.GetCardIdByName("Ehwaz?")
mod.flippedDagazID = Isaac.GetCardIdByName("Dagaz?")
mod.flippedAnsuzID = Isaac.GetCardIdByName("Ansuz?")
mod.flippedPerthroID = Isaac.GetCardIdByName("Perthro?")
mod.flippedBerkanoID = Isaac.GetCardIdByName("Berkano?")
mod.flippedAlgizID = Isaac.GetCardIdByName("Algiz?")
mod.flippedBlankID = Isaac.GetCardIdByName("Blank Rune?")
mod.flippedBlackID = Isaac.GetCardIdByName("Black Rune?")
mod.crackedFlippedBlackID = Isaac.GetCardIdByName("Black Rune..?")
mod.brokenFlippedBlackID = Isaac.GetCardIdByName("Black Rune...")
mod.shiningFlippedBlackID = Isaac.GetCardIdByName("Black Rune!?")

function mod:SafeRandom()
    local rand
    repeat rand = Random()
    until rand ~= 0
    return rand
end

--GENERIC: Attempts to filter out all non-monsters
function mod:IsMonster(entity)
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