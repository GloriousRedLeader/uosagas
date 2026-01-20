------------------------------------------------------------------------------------
-- START OPTIONS for script that trains snooping on a targetting pack. Select a player
-- backpack through their paperdoll. Might work on a pack animal directly too.
-- not very sophisticated. 
-- by OMG Arturo
------------------------------------------------------------------------------------

-- Enable this if you want to remain hidden
local USE_HIDING = true

------------------------------------------------------------------------------------
-- END OPTIONS 
-- by OMG Arturo
------------------------------------------------------------------------------------

Messages.Print("Target a player backpack or pack animal")

local pack = Targeting.GetNewTarget()
while true do
    if USE_HIDING and not Player.IsHidden then
        Skills.Use("Hiding")
    else
        Player.UseObject(pack)
    end
    Pause(1000)
end