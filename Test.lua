local RUNEBOOK_SERIAL = 0x45A036A4
local recall = Items.FindByType(0x1F4C)
if recall ~= nil then
    Messages.Print("Found recall " .. recall.Name)
    Player.PickUp(recall.Serial, recall.Amount)
    Player.DropInContainer(RUNEBOOK_SERIAL)
else
    Messages.Print("No recalls found")
end