Messages.Print("Select source container.", 66)
srcContainerSerial = Targeting.GetNewTarget()

Player.UseObject(srcContainerSerial)
Pause(750)
--Items.UseItem(0x4A296764)
scrolls = Items.FindInContainer(srcContainerSerial, 0xFF3A)

for index, item in ipairs(scrolls) do
-- Convert the name to lowercase once, then check for matches
-- Simple check

    
    if string.find(item.Name, "Poison") or string.find(item.Name, "Alchemy") then
        Messages.Print("This item is good!")

         Player.PickUp(item.Serial, item.Amount)

         Player.DropInBackpack()
         Pause(750)
        
    end

 

end

