local mod = FlippedRunes
local Runes = {}

FlippedPerthroID = Isaac.GetCardIdByName("Perthro?")

local flippedPerthroSfx = Isaac.GetSoundIdByName("flippedPerthro")

--Perthro? globals
local numModdedCollectibles

for id = CollectibleType.NUM_COLLECTIBLES + 1, 10000000 do
    if not Isaac.GetItemConfig():GetCollectible(id) then
        numModdedCollectibles = id - CollectibleType.NUM_COLLECTIBLES - 1
        break
    end
end

local numTotalCollectibles = numModdedCollectibles + CollectibleType.NUM_COLLECTIBLES

--Rerolls items in the room into items the player already owns
--will generally avoid items that have no benefit when duplicated
---@param player EntityPlayer
function Runes:UseFlippedPerthro(_, player, _)

    local playerCollectiblesOwned = GetPlayerCollectibles(player)    

    local game = Game()
    local entities = Isaac.GetRoomEntities()
    local itemConfig = Isaac.GetItemConfig()
    local rng = RNG()
    rng:SetSeed(Game():GetSeeds():GetStartSeed(), 1)

    for _, entity in ipairs(entities) do
        if entity:ToPickup() and entity:ToPickup().Variant == PickupVariant.PICKUP_COLLECTIBLE then
            local collectible = entity:ToPickup()
            if collectible and collectible.SubType ~= CollectibleType.COLLECTIBLE_NULL then

                local eligiblePlayerCollectiblesOwned = {}

                for k, v in pairs(playerCollectiblesOwned) do
                    eligiblePlayerCollectiblesOwned[k] = v
                end

                local newItem

                repeat
                    if #eligiblePlayerCollectiblesOwned == 0 then
                        local itemPoolObj = Game():GetItemPool()
                        local roomType = Game():GetRoom():GetType()
                        local roomPool = itemPoolObj:GetPoolForRoom(roomType, rng:Next())
                        if roomPool == -1 then
                            roomPool = 0
                        end

                        newItem = itemPoolObj:GetCollectible(roomPool, true, rng:Next())
                        break
                    end

                    local randomIndex = math.random(1, #eligiblePlayerCollectiblesOwned)

                    newItem = eligiblePlayerCollectiblesOwned[randomIndex]
                    table.remove(eligiblePlayerCollectiblesOwned, randomIndex)

                until newItem and (not itemConfig:GetCollectible(newItem):HasTags(ItemConfig.TAG_QUEST)) and CollectibleIsStackable(newItem)

                collectible:Morph(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_COLLECTIBLE, newItem, true)
                Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.POOF01, 0, collectible.Position, Vector(0,0), nil)               
            end
        end
    end
end

mod:AddCallback(ModCallbacks.MC_USE_CARD, Runes.UseFlippedPerthro, FlippedPerthroID)

--PERTHRO?: returns a list of all the collectibles the player has
---@param player EntityPlayer
function GetPlayerCollectibles(player)

    local ownedCollectibles = {}

    for id = 1, numTotalCollectibles do
        if player:HasCollectible(id, true) then
            local amount = player:GetCollectibleNum(id, true)
            for i = 1, amount do
                table.insert(ownedCollectibles, id)
            end
        end
    end

    return ownedCollectibles
end