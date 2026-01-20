------------------------------------------------------------------------------------
-- START OPTIONS for script that is very basic scavenger
-- by OMG Arturo
------------------------------------------------------------------------------------

local THINGS_TO_SCAVENGE = {
    0x0EED -- gold
}

------------------------------------------------------------------------------------
-- END OPTIONS 
-- by OMG Arturo
------------------------------------------------------------------------------------

while true do
    local filter = { onground=true, rangemax=1, graphics=THINGS_TO_SCAVENGE } -- Arrows and bolts
    local items = Items.FindByFilter(filter)
    if items then
        for _, item in ipairs(items) do
            if item.Distance <= 1 then
                Player.PickUp(item.Serial, item.Amount)
                Pause(200)
                Player.DropInBackpack()
                Pause(500)
            end
        end
    end
    Pause(100)
end