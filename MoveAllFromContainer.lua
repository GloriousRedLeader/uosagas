Messages.Print("Move all items from source container to destination container.")

Messages.Print("Pick source container...")
sourceContainer = Items.FindBySerial(Targeting.GetNewTarget())

Messages.Print("Pick destination container...")
destinationContainer = Items.FindBySerial(Targeting.GetNewTarget())

Messages.Print("Moving all items from " .. tostring(sourceContainer.Name) .. " to " .. tostring(destinationContainer.Name))