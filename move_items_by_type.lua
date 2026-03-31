------------------------------------------------------------------------------------
-- START OPTIONS for
--    Moves all items by type from container1 to container2.
-- by OMG Arturo
------------------------------------------------------------------------------------

-- Don't screw aroudn with this.
local VERSION = "1.0"

-- Adjust based on latency
PAUSE_DELAY_MS = 666

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
Messages.Print("Move Items By Type (v" .. VERSION .. ")", Colors.Info)
Messages.Print("From one container to another", Colors.Info)
Messages.Print("__________________________________", Colors.Info)

Messages.Print("Select an item.", Colors.Confirm)
itemSerial = Targeting.GetNewTarget()
Messages.Print("Pick a destination container.", Colors.Confirm)
destContainerSerial = Targeting.GetNewTarget()

item = Items.FindBySerial(itemSerial)
items = Items.FindInContainer(item.Container, item.Graphic)

Messages.Print("Moving " .. #items .. " items", 77)

for i, item in ipairs(items) do
    Player.PickUp(item.Serial, item.Amount)
    if destContainerSerial == Player.Backpack.Serial then
        Player.DropInBackpack()
    else
        Player.DropInContainer(destContainerSerial)
    end
    Pause(PAUSE_DELAY_MS)
end

Messages.Print("All done.", 77)