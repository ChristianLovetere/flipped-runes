local mod = FlippedRunes
local FlippedDagaz = {}

local flippedDagazSfx = Isaac.GetSoundIdByName("flippedDagaz")

--Dagaz? globals
local g_active = nil
local g_player = nil
local g_curses = {
    LevelCurse.CURSE_OF_DARKNESS,
    LevelCurse.CURSE_OF_THE_LOST,
    LevelCurse.CURSE_OF_THE_UNKNOWN,
    LevelCurse.CURSE_OF_MAZE,
    LevelCurse.CURSE_OF_BLIND
}
local g_activeCurses
local g_floorStartCurses = 0

--flag for an EID callback
if EID then
    mod.DagazEidFlag = false
end

--adds a random curse and a chance to add status effects to enemies when walking into rooms 
--for the current floor. The chance for a status effect increases with amount of curses
function FlippedDagaz:UseFlippedDagaz(_, player, _)

    if REPENTOGON then
        ItemOverlay.Show(mod.flippedDagazGbook)
        SFXManager():Play(flippedDagazSfx)
    else
        mod:PlayOverlay("flippedDagaz.png", mod.OverlayColors, flippedDagazSfx)
    end
    
    
    local level = Game():GetLevel()
    local newCurse = GetRandomCurse()
    local allCursesPresent, _ = CursesPresent()
    if allCursesPresent ~= true then
        if REPENTOGON then
            level:AddCurse(newCurse, false)
        else
            level:AddCurse(newCurse, true)
        end
        Game():ShakeScreen(10)
        g_active = true

        if EID then
            mod.DagazEidFlag = true
        end

        g_player = player
        _, g_activeCurses = CursesPresent() 
    end
end

mod:AddCallback(ModCallbacks.MC_USE_CARD, FlippedDagaz.UseFlippedDagaz, mod.flippedDagazID)

--DAGAZ?: get a random curse that isn't already in effect
function GetRandomCurse()

    local level = Game():GetLevel()
    local currentCurses = level:GetCurses()
    local newCurse

    local allCursesPresent, _ = CursesPresent()

    repeat newCurse = g_curses[math.random(#g_curses)]
    until newCurse & currentCurses == 0 or allCursesPresent == true

    return newCurse
end

--DAGAZ?: returns true if all curses giveable by Dagaz? are already present, false otherwise, also returns number of Dagaz? curses found
function CursesPresent()

    local g_activeCurses = Game():GetLevel():GetCurses()
    local numCurses = 0
    for _, mask in ipairs(g_curses) do
        if (g_activeCurses & mask) ~= 0 then
            numCurses = numCurses + 1
        end
    end
    if numCurses == #g_curses then
        return true, numCurses
    end
    return false, numCurses
end

--DAGAZ?: returns the number of curses that are currently active
function GetNumActiveCurses()
    local bitMasks = {
        1, 2, 4, 8, 16, 32, 64, 128
    }
    local g_activeCurses = Game():GetLevel():GetCurses()
    local numCurses = 0.0
    for _, mask in ipairs(bitMasks) do
        if (g_activeCurses & mask) ~= 0 then
            numCurses = numCurses + 1.0
        end
    end
    return numCurses
end

--DAGAZ?: finds enemies in the room and applies a random status to them
function FlippedDagaz:ActiveOnNewRoom()
    if g_active ~= true or g_player == nil then
        return
    end

    for _, entity in ipairs(Isaac.GetRoomEntities()) do
        if entity and FlippedRunes:IsMonster(entity) then
            ApplyRandomStatusEffect(entity, g_player)
        end
    end
end

mod:AddCallback(ModCallbacks.MC_POST_NEW_ROOM, FlippedDagaz.ActiveOnNewRoom)

function FlippedDagaz:ActiveOnNewEnemyGreedMode(npc)

    local roomType = Game():GetLevel():GetCurrentRoomDesc().Data.Type
    if Game():IsGreedMode() and g_active and roomType == 1 then
        if npc and mod:IsMonster(npc) then
            ApplyRandomStatusEffect(npc, g_player)
        end
    end
    
end

mod:AddCallback(ModCallbacks.MC_POST_NPC_INIT, FlippedDagaz.ActiveOnNewEnemyGreedMode)

--DAGAZ?: disables the floor-wide effect after changing floor and gets new g_floorStartCurses
function FlippedDagaz:ResetGlobals(isContinued)
    isContinued = isContinued or false
    if isContinued == false then
        g_floorStartCurses = GetNumActiveCurses()
        g_active = false
        if EID then
            mod.DagazEidFlag = false
        end
        g_player = nil
    end
end

mod:AddCallback(ModCallbacks.MC_POST_NEW_LEVEL, FlippedDagaz.ResetGlobals)
mod:AddCallback(ModCallbacks.MC_POST_GAME_STARTED, FlippedDagaz.ResetGlobals)

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
    local effectChosen
    --select a random effect
    if Game():IsGreedMode() then
        --never pick midas in greed mode
        effectChosen = math.random(#statusEffects - 1)
    else
        effectChosen = math.random(#statusEffects)

        --60% chance to reroll effect if midas is chosen
        if effectChosen == midasIndex and math.random(100) < 60 then
            effectChosen = math.random(#statusEffects)
        end
    end
    
    local randomEffect = statusEffects[effectChosen]
    
    local activeC = GetNumActiveCurses()
    if activeC == 0 or activeC == -1 then
        return
    end
    --apply the effect. chance of applying is 1/(#g_activeCurses + 1)
    if enemy and randomEffect and (math.random(100) > (1.0/(activeC + 1.0))*100.0) then
        randomEffect(enemy, source)
    end
end

--DAGAZ?: Normal Dagaz grants an extra half soul heart for each curse removed after 1
function FlippedDagaz:GetSoulHeartsToAddOnUseDagaz(_, player, _)
    
    if g_active ~= true then
        return
    end
    player:AddSoulHearts(g_activeCurses - g_floorStartCurses)

    g_active = false
    if EID then
        mod.DagazEidFlag = false
    end
    g_activeCurses = 0
end

mod:AddCallback(ModCallbacks.MC_USE_CARD, FlippedDagaz.GetSoulHeartsToAddOnUseDagaz, Card.RUNE_DAGAZ)