------------------------------------------------------------------------------------
-- START OPTIONS for 
-- For blacksmithy. Spams create last.
-- This one will also attempt to smelt things.
-- by OMG Arturo
------------------------------------------------------------------------------------

local CRAFTING_TOOL_GRAPHIC_ID = 0x13E3    -- Blacksmith

-- If this is set, it will look in your backpack for this item
-- and attempt to smelt it after every craft.
-- WARNING: If you have a bombass item that has the same GRAPHIC_ID
-- DON'T DO THIS. YOU WILL LOSE THAT FUCKER. 
local SMELT_GRAPHIC_ID = 0x1B73 

------------------------------------------------------------------------------------
-- END OPTIONS 
-- by OMG Arturo
------------------------------------------------------------------------------------
Messages.Overhead("SmithyMaster5000 for my good man Blood", 47, Player.Serial)

if not SMELT_GRAPHIC_ID then
    Messages.Overhead("Set SMELT_GRAPHIC_ID to auto-recycle an item!", 47, Player.Serial)
else
    Messages.Overhead("YOU WILL BE AUTO-RECYCLING AN ITEM!!!!!!", 37, Player.Serial)
end

local toolUsed = false  -- Track if tool and pestle has been used already

while true do
    -- Open Menu
    if not toolUsed then
        local tool = Items.FindByType(CRAFTING_TOOL_GRAPHIC_ID)
        if tool then
            Player.UseObject(tool.Serial)
            Pause(750)  -- Brief pause to ensure the tool is used
            toolUsed = true  -- Mark the tool as used
        else
            Messages.Print("Smith hamemr not found! Quitting.")
            break
        end
    end

    Journal.Clear()

    local itemToSmelt = Items.FindByType(SMELT_GRAPHIC_ID)
    if itemToSmelt then
        Messages.Print("Smelting some shit ")
        Gumps.PressButton(2653346093, 14)
        Targeting.WaitForTarget(1000)
        Targeting.Target(itemToSmelt.Serial)
    else
        -- Press the "Create Last" button to craft the item
        Gumps.PressButton(2653346093, 21)
    end
    Gumps.WaitForGump(2653346093, 1000)
    Pause(750)

    -- Scan the journal for "You have worn out your tool!"
    if Journal.Contains("You have worn out your tool!") then
        toolUsed = false
    end        
        -- Clear the journal to avoid repeatedly seeing the same message

    Pause(750)
end	