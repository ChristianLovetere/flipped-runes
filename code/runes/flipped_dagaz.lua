local mod = FlippedRunes
local Runes = {}

FlippedDagazID = Isaac.GetCardIdByName("Dagaz?")

local flippedDagazSfx = Isaac.GetSoundIdByName("flippedDagaz")

--Dagaz? globals
local flippedDagazActive = nil
local flippedDagazPlayer = nil
local flippedDagazCurses = {
    LevelCurse.CURSE_OF_DARKNESS,
    LevelCurse.CURSE_OF_THE_LOST,
    LevelCurse.CURSE_OF_THE_UNKNOWN,
    LevelCurse.CURSE_OF_MAZE,
    LevelCurse.CURSE_OF_BLIND
}
local activeCurses
local floorStartCurses = 0

--adds a random curse and a chance to add status effects to enemies when walking into rooms 
--for the current floor. The chance for a status effect increases with amount of curses
function Runes:UseFlippedDagaz(_, player, _)
    
    local level = Game():GetLevel()
    local newCurse = GetRandomCurse()
    local allCursesPresent, _ = FlippedDagazCursesPresent()
    if allCursesPresent ~= true then
        level:AddCurse(newCurse, true)
        Game():ShakeScreen(10)
        flippedDagazActive = true
        flippedDagazPlayer = player
        _, activeCurses = FlippedDagazCursesPresent() 
    end
end

mod:AddCallback(ModCallbacks.MC_USE_CARD, Runes.UseFlippedDagaz, FlippedDagazID)

--DAGAZ?: get a random curse that isn't already in effect
function GetRandomCurse()

    local level = Game():GetLevel()
    local currentCurses = level:GetCurses()
    local newCurse

    local allCursesPresent, _ = FlippedDagazCursesPresent()

    repeat newCurse = flippedDagazCurses[math.random(#flippedDagazCurses)]
    until newCurse & currentCurses == 0 or allCursesPresent == true

    return newCurse
end

--DAGAZ?: returns true if all curses giveable by Dagaz? are already present, false otherwise, also returns number of Dagaz? curses found
function FlippedDagazCursesPresent()

    local activeCurses = Game():GetLevel():GetCurses()
    local numCurses = 0
    for _, mask in ipairs(flippedDagazCurses) do
        if (activeCurses & mask) ~= 0 then
            numCurses = numCurses + 1
        end
    end
    if numCurses == #flippedDagazCurses then
        return true, numCurses
    end
    return false, numCurses
end

--DAGAZ?: returns the number of curses that are currently active
function GetNumActiveCurses()
    local bitMasks = {
        1, 2, 4, 8, 16, 32, 64, 128
    }
    local activeCurses = Game():GetLevel():GetCurses()
    local numCurses = 0.0
    for _, mask in ipairs(bitMasks) do
        if (activeCurses & mask) ~= 0 then
            numCurses = numCurses + 1.0
        end
    end
    return numCurses
end

--DAGAZ?: finds enemies in the room and applies a random status to them
function Runes:FlippedDagazActiveOnNewRoom()
    if flippedDagazActive ~= true or flippedDagazPlayer == nil then
        return
    end

    for _, entity in ipairs(Isaac.GetRoomEntities()) do
        if entity and IsMonster(entity) then
            ApplyRandomStatusEffect(entity, flippedDagazPlayer)
        end
    end
end

mod:AddCallback(ModCallbacks.MC_POST_NEW_ROOM, Runes.FlippedDagazActiveOnNewRoom)

--DAGAZ?: disables the floor-wide effect after changing floor and gets new floorStartCurses
function Runes:FlippedDagazResetGlobals(isContinued)
    isContinued = isContinued or false
    if isContinued == false then
        floorStartCurses = GetNumActiveCurses()
        flippedDagazActive = false
        flippedDagazPlayer = nil
    end
end

mod:AddCallback(ModCallbacks.MC_POST_NEW_LEVEL, Runes.FlippedDagazResetGlobals)
mod:AddCallback(ModCallbacks.MC_POST_GAME_STARTED, Runes.FlippedDagazResetGlobals)

--DAGAZ?: apply a random status effect to the enemy. chance to fail decreases with number of active curses
function ApplyRandomStatusEffect(enemy, source)

    local statusEffects = {
        function(e, s) e:AddFreeze(EntityRef(s), 180) end,
        function(e, s) e:AddPoison(EntityRef(s), 180, Game():GetLevel():GetStage()*3.5) end,
        function(e, s) e:AddSlowing(EntityRef(s), 300, 0.5, Color(.5,.5,.5,1,0,0,0)) end,
        function(e, s) e:AddCharmed(EntityRef(s), 600) end,
        function(e, s) e:AddConfusion(EntityRef(s), 300, true) end,
        function(e, s) e:AddFear(EntityRef(s), 300) end,
        function(e, s) e:AddBurn(EntityRef(s), 120, Game():GetLevel():GetStage()*1.75) end,
        function(e, s) e:AddMidasFreeze(EntityRef(s), 300) end
    }
    local midasIndex = #statusEffects
    --select a random effect
    local effectChosen = math.random(#statusEffects)
    --60% chance to reroll effect if midas is chosen
    if effectChosen == midasIndex and math.random(100) < 60 then
        effectChosen = math.random(#statusEffects)
    end

    local randomEffect = statusEffects[effectChosen]
    
    local activeC = GetNumActiveCurses()
    if activeC == 0 then
        return
    end
    --apply the effect. chance of applying is 1/(#activeCurses + 1)
    if enemy and randomEffect and (math.random(100) > (1.0/(activeC + 1.0))*100.0) then
        randomEffect(enemy, source)
    end
end

--DAGAZ?: Normal Dagaz grants an extra half soul heart for each curse removed after 1
function Runes:GetSoulHeartsToAddOnUseDagaz(_, player, _)
    
    if flippedDagazActive ~= true then
        return
    end
    player:AddSoulHearts(activeCurses - floorStartCurses)

    flippedDagazActive = false
    activeCurses = 0
end

mod:AddCallback(ModCallbacks.MC_USE_CARD, Runes.GetSoulHeartsToAddOnUseDagaz, Card.RUNE_DAGAZ)