------------------------------------------------------------------------------------
-- START OPTIONS for script that trains snooping on a targetting pack. Select a player
-- backpack through their paperdoll. Might work on a pack animal directly too.
-- not very sophisticated. 
-- by OMG Arturo
------------------------------------------------------------------------------------

-- n/a

------------------------------------------------------------------------------------
-- END OPTIONS 
-- by OMG Arturo
------------------------------------------------------------------------------------

Messages.Print("Target a player backpack or pack animal")

local pack = Targeting.GetNewTarget()
while true do
    Player.UseObject(pack)
    Pause(1000)
end