-- Open Corpses, Skin, Loot Rare Leather, Cut Once
-- UO Sagas
-- Improved Version: 2025-12-10
-- By Chaz II (updated from original by JaseOwns)
-- Slimmed down and made significantly worse by omg arturo

Messages.Overhead("Skinning System Online", 69, Player.Serial)
Messages.Overhead("Disable auto-open corpses w/ ALT + O", 69, Player.Serial)

---------------------------------------------------------
--  CONFIG
---------------------------------------------------------

local CORPSE_GRAPHIC = 0x2006
local SKINNING_KNIFE  = 0xFEA9
local ACTION_DELAY_MS = 800

---------------------------------------------------------
--  HELPERS
---------------------------------------------------------

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
                Pause(ACTION_DELAY_MS)


                -- Open the corpse
                Player.UseObject(corpse.Serial)
                Pause(ACTION_DELAY_MS)

                local hides = Items.FindByFilter({ graphics = { 0x1079 } })
                for _, hide in ipairs(hides) do
                    if hide.RootContainer == Player.Serial then
                        Player.PickUp(hide.Serial, hide.Amount)
                        Player.DropInContainer(corpse.Serial)
                        Pause(ACTION_DELAY_MS)
                    end
                end

                -- Mark corpse processed so it never repeats
                MarkCorpseProcessed(corpse.Serial)
            end
        end
    end

    Pause(250)
end