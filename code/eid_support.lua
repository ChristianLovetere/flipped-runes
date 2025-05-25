if EID then

    EID:addCard(FlippedHagalazID, "Fills all pits in the room#Pits stay filled even if the room is exited", "Hagalaz?", "en_us")
    EID:addCard(FlippedJeraID, "Rerolls {{Coin}}, {{Bomb}}, {{Key}}, and {{HalfHeart}}/{{Heart}} into other variants of their pickup type#{{Shop}} Works on pickups that are for sale", "Jera?", "en_us")
    EID:addCard(FlippedEhwazID, "{{DemonBeggar}} Teleports Isaac to the Black Market#Spawns a {{Card1}} Fool Card inside the Black Market after teleporting", "Ehwaz?", "en_us")
    EID:addCard(FlippedDagazID, "\2 Adds a random {{ColorPurple}}curse{{CR}} to the current floor#\1 For the rest of the floor, enemies have a chance to be debuffed when a room is entered# The chance for a debuff increases with the number of active curses#{{Card35}} Dagaz grants an extra {{HalfSoulHeart}} per curse added by this rune", "Dagaz?", "en_us")
    EID:addCard(FlippedAnsuzID, "{{CurseLostSmall}} Adds Curse of the Lost to the current floor#{{Card35}} A Dagaz rune will drop after the boss is killed if no damage was taken this floor#{{UltraSecretRoom}} If the floor's Curse of the Lost is removed in any way, the Ultra Secret Room will be revealed and a path to it will be opened", "Ansuz?", "en_us")
    EID:addCard(FlippedPerthroID, "Rerolls items in the room into items Isaac already owns# Avoids rerolling into vanilla items that have no benefit when duplicated, including active items #{{Blank}} (except {{Collectible297}},{{Collectible515}},{{Collectible490}},{{Collectible628}})# If Isaac has no eligible items, rerolls into a random item from the current room's pool", "Perthro?", "en_us")
    EID:addCard(FlippedBerkanoID, "\2 Removes up to 2 vanilla familiars#\1 Spawns an item from the current room's pool for each familiar removed", "Berkano?", "en_us")
    EID:addCard(FlippedAlgizID, "{{BrokenHeart}} +1 Broken Heart#{{Timer}} Wears off over 40 seconds:#\1 x2 Tears multiplier#\1 +10 Luck#Using Algiz? again while it's already active will reset the timer", "Algiz?", "en_us")
    EID:addCard(FlippedBlankID, "{{Rune}} Converts all rune pickups in the room into their flipped variants#{{Shop}} Works on runes that are for sale", "Blank Rune?", "en_us")
    EID:addCard(FlippedBlackID, "Creates a wide variety of pickups#!!! Highly volatile!#{{Collectible263}} Can't be mimicked by Clear Rune", "Black Rune?", "en_us")
    EID:addCard(CrackedFlippedBlackID, "Creates 1-3 {{Card}}, {{Pill}}, and {{Battery}}, 2-3 times#!!! Explodes after a short delay when dropped#{{Collectible263}} Can't be mimicked by Clear Rune", "Black Rune..?", "en_us")
    EID:addCard(BrokenFlippedBlackID, "Creates 1-2 {{Chest}}, {{BlackSack}}, and {{Heart}}, 2-3 times#!!! Explodes after a short delay when dropped#{{Collectible263}} Can't be mimicked by Clear Rune", "Black Rune...", "en_us")
    EID:addCard(ShiningFlippedBlackID, "!!! Likely to explode and spawn bombs around Isaac, lighting enemies ablaze with a high damage burning effect# Small chance to create 2-3 {{ColorYellow}}Trinkets{{CR}}, {{GoldenKey}}, {{GoldenBomb}}, and {{CoinHeart}} instead, without consuming the rune#!!! Explodes after a short delay when dropped#{{Collectible263}} Can't be mimicked by Clear Rune", "Black Rune!?", "en_us")
    
    local eidSprite = Sprite()
    eidSprite:Load("gfx/eid_icons.anm2", true)
    EID:addIcon("Card"..FlippedHagalazID, "flippedRune1", -1, 18, 23, 5, 7, eidSprite)
    EID:addIcon("Card"..FlippedJeraID, "flippedRune1", -1, 18, 23, 5, 7, eidSprite)
    EID:addIcon("Card"..FlippedEhwazID, "flippedRune1", -1, 18, 23, 5, 7, eidSprite)
    EID:addIcon("Card"..FlippedDagazID, "flippedRune1", -1, 18, 23, 5, 7, eidSprite)
    EID:addIcon("Card"..FlippedAnsuzID, "flippedRune2", -1, 18, 23, 5, 6, eidSprite)
    EID:addIcon("Card"..FlippedPerthroID, "flippedRune2", -1, 18, 23, 5, 6, eidSprite)
    EID:addIcon("Card"..FlippedBerkanoID, "flippedRune2", -1, 18, 23, 5, 6, eidSprite)
    EID:addIcon("Card"..FlippedAlgizID, "flippedRune2", -1, 18, 23, 5, 6, eidSprite)
    EID:addIcon("Card"..FlippedBlankID, "flippedRune2", -1, 18, 23, 5, 6, eidSprite)
    EID:addIcon("Card"..FlippedBlackID, "flippedRuneBlack", -1, 18, 23, 5, 7, eidSprite)
    EID:addIcon("Card"..CrackedFlippedBlackID, "crackedFlippedRuneBlack", -1, 18, 23, 5, 7, eidSprite)
    EID:addIcon("Card"..BrokenFlippedBlackID, "brokenFlippedRuneBlack", -1, 18, 23, 5, 7, eidSprite)
    EID:addIcon("Card"..ShiningFlippedBlackID, "shiningFlippedRuneBlack", -1, 18, 23, 5, 7, eidSprite)
    
    local function BlackCandleModifierCondition(descObj)
        if descObj.ObjType == EntityType.ENTITY_PICKUP and descObj.ObjVariant == PickupVariant.PICKUP_COLLECTIBLE and descObj.ObjSubType == CollectibleType.COLLECTIBLE_BLACK_CANDLE then
            local numPlayers = Game():GetNumPlayers()
            for i = 0, numPlayers do
                local player = Isaac.GetPlayer(i)
                if player:GetCard(0) == FlippedAnsuzID or player:GetCard(1) == FlippedAnsuzID or player:GetCard(2) == FlippedAnsuzID then
                    return true
                end
            end
        end
        return false
    end

    local function blackCandleModifierCallback(descObj)
        EID:appendToDescription(descObj, "#{{Card"..FlippedAnsuzID.."}} Allows Ansuz? to open a path to the {{UltraSecretRoom}} Ultra Secret Room on use")
        return descObj
    end

    EID:addDescriptionModifier("BlackCandleAnsuz?", BlackCandleModifierCondition, blackCandleModifierCallback)

    local function FlippedAnsuzModifierCondition(descObj)
        if descObj.ObjType == EntityType.ENTITY_PICKUP and descObj.ObjVariant == PickupVariant.PICKUP_TAROTCARD and descObj.ObjSubType == FlippedAnsuzID then
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