--[[
    UO Sagas

    OMG Arthur

    Scavenger by omg arturo
    WIP
--]]

-- 



-- Adjust based on latency
PAUSE_DELAY_MS = 150
LOOT_ITEM_DELAY_MS = 250

-- Add graphics of items you want to scavenger in order of priority
ITEMS_TO_LOOT = {
   -- 0x2203, -- Skull
--    0x0EED, -- Gold
--    0x0F3F, -- arrow
--    0x1BFB, -- bolt
---    0x0E79, -- pouch
--    0x9FF9, -- Chest
--    0x0966, -- Chest
    0x9FF8, -- Chest
    0x0E3D, -- Big crate

}
checkPoison = os.clock() + 1
while not Player.IsDead do

	filter = {onground=true, corpse=false, rangemax=2, graphics=ITEMS_TO_LOOT}

	items = Items.FindByFilter(filter)
	for i, item in ipairs(items) do
        if item ~= nil then
            if item.Name ~= nil then
           	    Messages.Print(tostring(i) .. ' ' .. item.Name .. ' ' .. item.Serial)
            else
                Messages.Print(tostring(i) .. ' (unknown name) ' .. item.Serial)
            end
      		Player.PickUp(item.Serial)
            Pause(LOOT_ITEM_DELAY_MS)
    		Player.DropInBackpack()
    		Pause(LOOT_ITEM_DELAY_MS)
        end
    end

    Pause(PAUSE_DELAY_MS)

    

    Pause(PAUSE_DELAY_MS)    
end
-- mb - 0x00481E39
-- corpse 0x4720834F