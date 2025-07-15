--[[
    UO Sagas

    OMG Arthur

    Moves all items from container1 to container2.
--]]

-- Adjust based on latency
PAUSE_DELAY_MS = 666

Messages.Print("Move all items by type to a new container.", 77)
Messages.Print("Select source container.", 66)
srcContainerSerial = Targeting.GetNewTarget()
Messages.Print("Pick a destination container.", 66)
destContainerSerial = Targeting.GetNewTarget()


items = Items.GetContainerItems(srcContainerSerial)
Messages.Print("Moving " .. #items .. " items from " .. sourceContainer.Name .. " to " .. destinationContainer.Name, 77)

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