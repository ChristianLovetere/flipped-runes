local mod = FlippedRunes
local FlippedBerkano = {}

local flippedBerkanoSfx = Isaac.GetSoundIdByName("flippedBerkano")

--deletes up to 2 vanilla familiars and turns them into items from the current room's pool
function FlippedBerkano:UseFlippedBerkano(_, player, _)

    if REPENTOGON then
        ItemOverlay.Show(mod.flippedBerkanoGbook)
        SFXManager():Play(flippedBerkanoSfx)
    else
        mod:PlayOverlay("flippedBerkano.png", mod.OverlayColors, flippedBerkanoSfx)
    end

    --find familiars to remove
    local entities = Isaac.GetRoomEntities()
    local eligibleFamiliarCollectibles = {}
    local familiarPositions = {}

    for _, entity in ipairs(entities) do
        local familiar = entity:ToFamiliar()
        if familiar then
            
            local collectibleID = GetCollectibleFromFamiliar(familiar)
            if collectibleID ~= nil then
                table.insert(familiarPositions, familiar.Position)
                table.insert(eligibleFamiliarCollectibles, collectibleID)
            end
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
        Game():Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_COLLECTIBLE, familiarPositions[i], Vector(0,0), nil, collectibleID, mod:SafeRandom())
        Game():Spawn(EntityType.ENTITY_EFFECT, EffectVariant.POOF04, familiarPositions[i], Vector(0,0), nil, 0, mod:SafeRandom())
    end
    
end

mod:AddCallback(ModCallbacks.MC_USE_CARD, FlippedBerkano.UseFlippedBerkano, mod.flippedBerkanoID)

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
    return familiarToCollectible[familiarVar]
end