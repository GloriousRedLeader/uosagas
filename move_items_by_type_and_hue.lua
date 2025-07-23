--[[
    UO Sagas

    OMG Arthur

    Moves all items by type and color from one container to another. This uses graphic id 
    and and also hue. 

    Example: You have 5 trapped pouches (red) and 5 regular pouches (brown). Target a 
    trapped pouch and it will only move the red ones.
--]]

-- Adjust based on latency
PAUSE_DELAY_MS = 666

Messages.Print("Move all items by type and color to a new container.", 77)
Messages.Print("Select an item.", 66)
itemSerial = Targeting.GetNewTarget()
Messages.Print("Pick a destination container.", 66)
destContainerSerial = Targeting.GetNewTarget()

item = Items.FindBySerial(itemSerial)
items = Items.FindInContainer(item.Container, item.Graphic, item.Hue)

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