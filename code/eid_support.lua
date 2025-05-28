local mod = FlippedRunes

if EID then

    EID:addCard(mod.flippedHagalazID, "Fills all {{ColorGray}}pits{{CR}} in the room#{{ColorGray}}Pits{{CR}} stay filled even if the room is exited", "Hagalaz?", "en_us")
    EID:addCard(mod.flippedJeraID, "Rerolls {{Coin}}, {{Bomb}}, {{Key}}, and {{HalfHeart}}/{{Heart}} into other variants of their pickup type#{{Shop}} Works on pickups that are for sale", "Jera?", "en_us")
    EID:addCard(mod.flippedEhwazID, "{{DemonBeggar}} Teleports Isaac to the {{ColorGray}}Black Market{{CR}}#Spawns a {{Card1}} {{ColorGreen}}Fool Card{{CR}} inside the Black Market after teleporting", "Ehwaz?", "en_us")
    EID:addCard(mod.flippedDagazID, "\2 Adds a random {{ColorPurple}}curse{{CR}} to the current floor#\1 For the rest of the floor, enemies have a chance to be {{ColorError}}debuffed{{CR}} when a room is entered# The chance for a {{ColorError}}debuff{{CR}} increases with the number of active {{ColorPurple}}curses{{CR}}#{{Card35}} {{ColorTransform}}Dagaz{{CR}} grants an extra {{HalfSoulHeart}} per {{ColorPurple}}curse{{CR}} added by {{ColorTeal}}Dagaz?{{CR}}", "Dagaz?", "en_us")
    EID:addCard(mod.flippedAnsuzID, "{{CurseLostSmall}} Adds {{ColorPurple}}Curse of the Lost{{CR}} to the current floor#{{Card35}} A {{ColorTransform}}Dagaz{{CR}} rune will drop after the boss is killed if no hits were taken this floor#{{UltraSecretRoom}} If the floor's {{ColorPurple}}Curse of the Lost{{CR}} is removed in any way, the {{ColorRed}}Ultra Secret Room{{CR}} will be revealed AND {{Collectible580}} opened", "Ansuz?", "en_us")
    EID:addCard(mod.flippedPerthroID, "{{ColorLime}}Rerolls{{CR}} items in the room into items Isaac already owns# Avoids {{ColorLime}}rerolling{{CR}} into vanilla items that have no benefit when duplicated, including active items #{{Blank}} (except {{Collectible297}},{{Collectible515}},{{Collectible490}},{{Collectible628}})# If Isaac has no eligible items, {{ColorLime}}rerolls{{CR}} into a random item from the current room's pool", "Perthro?", "en_us")
    EID:addCard(mod.flippedBerkanoID, "\2 Removes up to 2 {{ColorSilver}}vanilla{{CR}} familiars#\1 Spawns an item from the current room's pool for each familiar removed", "Berkano?", "en_us")
    EID:addCard(mod.flippedAlgizID, "{{BrokenHeart}} +1 Broken Heart#{{Timer}} Wears off over 40 seconds:#\1 x2 Tears multiplier#\1 +10 Luck#Using {{ColorTeal}}Algiz?{{CR}} again while it's already active will reset the timer", "Algiz?", "en_us")
    EID:addCard(mod.flippedBlankID, "{{Rune}} Converts all {{ColorTransform}}rune{{CR}} pickups in the room into their {{ColorTeal}}flipped{{CR}} variants#{{Shop}} Works on {{ColorTransform}}runes{{CR}} that are for sale", "Blank Rune?", "en_us")
    EID:addCard(mod.flippedBlackID, "Creates a wide variety of pickups#!!! {{ColorYellow}}Highly volatile!#{{Collectible263}} Can't be mimicked by Clear Rune", "Black Rune?", "en_us")
    EID:addCard(mod.crackedFlippedBlackID, "Creates 1-3 {{Card}}, {{Pill}}, and {{Battery}}, 2-3 times#!!! {{ColorYellow}}Explodes after a short delay when dropped{{CR}}#{{Collectible263}} Can't be mimicked by Clear Rune", "Black Rune..?", "en_us")
    EID:addCard(mod.brokenFlippedBlackID, "Creates 1-2 {{Chest}}, {{BlackSack}}, and {{Heart}}, 2-3 times#!!! {{ColorYellow}}Explodes after a short delay when dropped{{CR}}#{{Collectible263}} Can't be mimicked by Clear Rune", "Black Rune...", "en_us")
    EID:addCard(mod.shiningFlippedBlackID, "!!! Likely to {{ColorGray}}explode{{CR}} and spawn bombs around Isaac, lighting enemies ablaze with a {{ColorError}}high damage burning debuff{{CR}}# Small chance to create 2-3 {{ColorYellow}}Trinkets{{CR}}, {{GoldenKey}}, {{GoldenBomb}}, and {{CoinHeart}} instead, without consuming the rune#!!! {{ColorYellow}}Explodes after a short delay when dropped{{CR}}#{{Collectible263}} Can't be mimicked by Clear Rune", "Black Rune!?", "en_us")
    
    local eidSprite = Sprite()
    eidSprite:Load("gfx/eid_icons.anm2", true)
    EID:addIcon("Card"..mod.flippedHagalazID, "flippedRune1", -1, 18, 23, 6, 7, eidSprite)
    EID:addIcon("Card"..mod.flippedJeraID, "flippedRune1", -1, 18, 23, 6, 7, eidSprite)
    EID:addIcon("Card"..mod.flippedEhwazID, "flippedRune1", -1, 18, 23, 6, 7, eidSprite)
    EID:addIcon("Card"..mod.flippedDagazID, "flippedRune1", -1, 18, 23, 6, 7, eidSprite)
    EID:addIcon("Card"..mod.flippedAnsuzID, "flippedRune2", -1, 18, 23, 6, 6, eidSprite)
    EID:addIcon("Card"..mod.flippedPerthroID, "flippedRune2", -1, 18, 23, 6, 6, eidSprite)
    EID:addIcon("Card"..mod.flippedBerkanoID, "flippedRune2", -1, 18, 23, 6, 6, eidSprite)
    EID:addIcon("Card"..mod.flippedAlgizID, "flippedRune2", -1, 18, 23, 6, 6, eidSprite)
    EID:addIcon("Card"..mod.flippedBlankID, "flippedRune2", -1, 18, 23, 6, 6, eidSprite)
    EID:addIcon("Card"..mod.flippedBlackID, "flippedRuneBlack", -1, 18, 23, 6, 7, eidSprite)
    EID:addIcon("Card"..mod.crackedFlippedBlackID, "crackedFlippedRuneBlack", -1, 18, 23, 6, 7, eidSprite)
    EID:addIcon("Card"..mod.brokenFlippedBlackID, "brokenFlippedRuneBlack", -1, 18, 23, 6, 7, eidSprite)
    EID:addIcon("Card"..mod.shiningFlippedBlackID, "shiningFlippedRuneBlack", -1, 18, 23, 6, 7, eidSprite)
    
    --Black candle cond
    local function BlackCandleModifierCondition(descObj)
        if descObj.ObjType == EntityType.ENTITY_PICKUP and descObj.ObjVariant == PickupVariant.PICKUP_COLLECTIBLE and descObj.ObjSubType == CollectibleType.COLLECTIBLE_BLACK_CANDLE then
            local numPlayers = Game():GetNumPlayers()
            for i = 0, numPlayers do
                local player = Isaac.GetPlayer(i)
                if player:GetCard(0) == mod.flippedAnsuzID or player:GetCard(1) == mod.flippedAnsuzID or player:GetCard(2) == mod.flippedAnsuzID then
                    return true
                end
            end
        end
        return false
    end

    --Black candle callb
    local function blackCandleModifierCallback(descObj)
        EID:appendToDescription(descObj, "#{{Card"..mod.flippedAnsuzID.."}} Allows {{ColorTeal}}Ansuz?{{CR}} to open a path to the {{UltraSecretRoom}} {{ColorRed}}Ultra Secret Room{{CR}} on use")
        return descObj
    end

    EID:addDescriptionModifier("BlackCandleAnsuz?", BlackCandleModifierCondition, blackCandleModifierCallback)

    --Ansuz? cond
    local function FlippedAnsuzModifierCondition(descObj)
        if descObj.ObjType == EntityType.ENTITY_PICKUP and descObj.ObjVariant == PickupVariant.PICKUP_TAROTCARD and descObj.ObjSubType == mod.flippedAnsuzID then
            local numPlayers = Game():GetNumPlayers()
            for i = 0, numPlayers do
                local player = Isaac.GetPlayer(i)
                if player:HasCollectible(CollectibleType.COLLECTIBLE_BLACK_CANDLE) then
                    return true
                end
            end
        end
    end

    --Ansuz? callb
    local function FlippedAnsuzModifierCallback(descObj)
        EID:appendToDescription(descObj, "#{{Collectible260}} Black Candle lets {{ColorTeal}}Ansuz?{{CR}} bypass all other conditions and open the {{UltraSecretRoom}} {{ColorRed}}Ultra Secret Room{{CR}} immediately")
        return descObj
    end
    
    EID:addDescriptionModifier("Ansuz?BlackCandle", FlippedAnsuzModifierCondition, FlippedAnsuzModifierCallback)
 
    --Dagaz cond
    local function DagazModifierCondition(descObj)
        if mod.DagazEidFlag == true then
            return true
        end
        if descObj.ObjType == EntityType.ENTITY_PICKUP and descObj.ObjVariant == PickupVariant.PICKUP_TAROTCARD and descObj.ObjSubType == Card.RUNE_DAGAZ then
            local numPlayers = Game():GetNumPlayers()
            for i = 0, numPlayers do
                local player = Isaac.GetPlayer(i)
                if player:GetCard(0) == mod.flippedDagazID or player:GetCard(1) == mod.flippedDagazID or player:GetCard(2) == mod.flippedDagazID then
                    return true
                end
            end
        end
        return false
    end

    --Dagaz callb
    local function DagazModifierCallback(descObj)
        EID:appendToDescription(descObj, "#{{Card"..mod.flippedDagazID.."}} Grants an extra {{HalfSoulHeart}} on use for every curse added by {{ColorTeal}}Dagaz?{{CR}}")
        return descObj
    end

    EID:addDescriptionModifier("DagazDagaz?", DagazModifierCondition, DagazModifierCallback)

    local ansuzDescChosen = false

    --Ansuz? cond
    local function FlippedAnsuzModifierCondition(descObj)
        if not ansuzDescChosen then
            if descObj.ObjType == EntityType.ENTITY_PICKUP and descObj.ObjVariant == PickupVariant.PICKUP_TAROTCARD and descObj.ObjSubType == mod.flippedAnsuzID then
                return true
            end
        end 
    end

    --Ansuz? callb
    local function FlippedAnsuzModifierCallback(descObj)
        if Game():IsGreedMode() then
            EID:addCard(mod.flippedAnsuzID, "#{{Shop}} In {{ColorYellow}}Greed Mode{{CR}}, spawns the {{Collectible76}} X-Ray Vision item", "Ansuz?", "en_us")
        else
            EID:addCard(mod.flippedAnsuzID, "{{CurseLostSmall}} Adds {{ColorPurple}}Curse of the Lost{{CR}} to the current floor#{{Card35}} A {{ColorTransform}}Dagaz{{CR}} rune will drop after the boss is killed if no hits were taken this floor#{{UltraSecretRoom}} If the floor's {{ColorPurple}}Curse of the Lost{{CR}} is removed in any way, the {{ColorRed}}Ultra Secret Room{{CR}} will be revealed AND {{Collectible580}} opened", "Ansuz?", "en_us")
        end
        ansuzDescChosen = true
        return descObj
    end

    EID:addDescriptionModifier("Ansuz?GreedMode", FlippedAnsuzModifierCondition, FlippedAnsuzModifierCallback)

    function ResetAnsuzChosen()
        ansuzDescChosen = false
    end

    mod:AddCallback(ModCallbacks.MC_POST_GAME_STARTED, ResetAnsuzChosen)
end