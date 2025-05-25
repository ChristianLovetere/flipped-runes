local mod = FlippedRunes
local Overlay = {}

local overlay = Sprite()
local currentFrame = -1
local colorTable = {}

mod.OverlayColors = {
    mod.RuneColor,
    mod.RuneColor,
    mod.RuneColor,
    mod.RuneColor
}

---@param sprite string name of file including file extension, must be in gfx/ui/giantbook/
---@param colors table a table containing the colors to apply to the background[1], dustPoof1[2], dustPoof2[3], and swirlyDustPoof[4]
---@param sound SoundEffect the sound to play alongside the overlay
function mod:PlayOverlay(sprite, colors, sound)

    table.insert(colorTable, Color(1,1,1))
    for i = 1, #colors do
        table.insert(colorTable, colors[i])
    end

    overlay:Load("gfx/ui/giantbook/giantbook.anm2", true)
    overlay:ReplaceSpritesheet(0, "gfx/ui/giantbook/" .. sprite)
    overlay:LoadGraphics()
    overlay:Play("Appear")
    SFXManager():Play(sound)
    currentFrame = 0
end

function Overlay:RenderOverlay()
    if currentFrame > 33 then
        currentFrame = -1
    end

    if currentFrame > -1 then
        if Isaac.GetFrameCount() % 2 == 0 then
            overlay:Update()
            currentFrame = currentFrame + 1
        end

        local screenCenterX, screenCenterY = Overlay:GetScreenSize()
        local screenCenter = Vector(screenCenterX/2,screenCenterY/2)
        for i = 5, 1, -1 do
            overlay.Color = colorTable[i]
            overlay:RenderLayer(i-1, screenCenter)
        end
    end
end

mod:AddCallback(ModCallbacks.MC_POST_RENDER, Overlay.RenderOverlay)

function Overlay:GetScreenSize()
    local game = Game()
    local room = game:GetRoom()
    local pos = Isaac.WorldToScreen(Vector(0,0)) - room:GetRenderScrollOffset() - game.ScreenShakeOffset
    
    local rx = pos.X + 60 * 26 / 40
    local ry = pos.Y + 140 * (26 / 40)
    
    return rx*2 + 13*26, ry*2 + 7*26
end