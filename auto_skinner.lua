------------------------------------------------------------------------------------
-- START OPTIONS for script that auto mines
-- by OMG Arturo
------------------------------------------------------------------------------------

-- Open Corpses, Skin, Loot Rare Leather, Cut Once
-- UO Sagas
-- Improved Version: 2025-12-10
-- By Chaz II (updated from original by JaseOwns)
-- Slimmed down and made significantly worse by omg arturo

-- Don't screw aroudn with this.
local VERSION = "1.2"

local CORPSE_GRAPHIC = 0x2006
local SKINNING_KNIFE  = 0xFEA9
local SCISSOR_GRAPHIC = 0x0F9F
local ACTION_DELAY = 800


-- Only keep these leathers, rest gets dropped on groud
local KEEP_HUES = {
    --0x0000, -- Regular
    --0x0973, -- Dull Copper
    --0x0966, -- Shadow Iron
    --0x096D, -- Copper
    --0x0972, -- Bronze
    --0x08A5, -- Gold
    --0x0979, -- Agapite
    0x089F, -- Verite
    0x08AB, -- Valorite
}

------------------------------------------------------------------------------------
-- END OPTIONS
-- by OMG Arturo
------------------------------------------------------------------------------------


-- Define Color Scheme
local Colors = {
    Alert   = 33,       -- Red
    Warning = 48,       -- Orange
    Caution = 53,       -- Yellow
    Action  = 67,       -- Green
    Confirm = 73,       -- Light Green
    Info    = 84,       -- Light Blue
    Status  = 93        -- Blue
}

-- Print Initial Start-Up Greeting
Messages.Print("___________________________________", Colors.Info)
Messages.Print("Skinning System Online (v" .. VERSION .. ")", Colors.Info)
Messages.Print("Disable auto-open corpses w/ ALT + O", Colors.Info)
Messages.Print("__________________________________", Colors.Info)

---------------------------------------------------------
--  HELPERS
---------------------------------------------------------

-- Helepr
function tableContains(tbl, val)
    for _, value in ipairs(tbl) do
        if value == val then
            return true
        end
    end
    return false
end

function GetSkinningKnife()
    for i, item in ipairs(Items.FindByFilter({ graphics = {SKINNING_KNIFE} })) do
        if item.RootContainer == Player.Serial then
            return item
        end
    end
end

---------------------------------------------------------
--  CORPSE TRACKING (Only process once)
---------------------------------------------------------
local processedCorpses = {}

function HasProcessedCorpse(serial)
    return processedCorpses[serial] == true
end

function MarkCorpseProcessed(serial)
    processedCorpses[serial] = true
end

---------------------------------------------------------
--  MAIN LOOP
---------------------------------------------------------
local corpseFilter = {
    graphics = { CORPSE_GRAPHIC },
    onground = true,
    rangemin = 0,
    rangemax = 2,
}

while true do

    local scissors = Items.FindByType(SCISSOR_GRAPHIC)
    local skinningKnife = GetSkinningKnife()
    if skinningKnife == nil then
        Messages.Overhead("No skinningKnife!", 34, Player.Serial)
        Pause(3000)
    else
        local corpses = Items.FindByFilter(corpseFilter)
        for _, corpse in ipairs(corpses) do
            if not HasProcessedCorpse(corpse.Serial) then
                Messages.Overhead("Processing corpse: " .. (corpse.Name or "Unknown"), 69, Player.Serial)

                -- Skin the corpse
                Player.UseObject(skinningKnife.Serial)
                Target.WaitForTarget(1000, false)
                Target.TargetSerial(corpse.Serial)
                Pause(ACTION_DELAY)


                -- Open the corpse
                Player.UseObject(corpse.Serial)
                Pause(ACTION_DELAY)

                local hides = Items.FindByFilter({ graphics = { 0x1079 }, onground = false })
                for _, hide in ipairs(hides) do
                    if hide.RootContainer == Player.Serial and not tableContains(KEEP_HUES, hide.Hue) then
                        Player.PickUp(hide.Serial, hide.Amount)
                        --Player.DropInContainer(corpse.Serial)
                        Player.DropOnGround()
                        Pause(ACTION_DELAY)
                    elseif hide.RootContainer == Player.Serial and scissors ~= nil then
                        Player.UseObject(scissors.Serial)
                        Target.WaitForTarget(3000)
                        Target.TargetSerial(hide.Serial)
                        Pause(ACTION_DELAY)
                    end
                end

                -- Mark corpse processed so it never repeats
                MarkCorpseProcessed(corpse.Serial)
            end
        end
    end

    Pause(250)
end