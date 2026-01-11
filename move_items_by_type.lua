

-- Adjust based on latency
PAUSE_DELAY_MS = 666

Messages.Print("Move all items by type to a new container.", 77)
Messages.Print("Select an item.", 66)
itemSerial = Targeting.GetNewTarget()
Messages.Print("Pick a destination container.", 66)
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