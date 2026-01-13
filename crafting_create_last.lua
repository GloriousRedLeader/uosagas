------------------------------------------------------------------------------------
-- START OPTIONS for 
-- script that basically presses the craft last button.
-- Profession depends on CRAFTING_TOOL_GRAPHIC_ID below.
-- by OMG Arturo
------------------------------------------------------------------------------------

local toolUsed = false  -- Track if tool and pestle has been used already

-- Pick the right one. Will search bags for a tool and use it.
local CRAFTING_TOOL_GRAPHIC_ID = 0x0E9B    -- Alchemy

------------------------------------------------------------------------------------
-- END OPTIONS 
-- by OMG Arturo
------------------------------------------------------------------------------------

while true do
    -- Open Menu
    if not toolUsed then
        local tool = Items.FindByType(CRAFTING_TOOL_GRAPHIC_ID)
        if tool then
            Player.UseObject(tool.Serial)
            Messages.Print("Using mortar and pestle to open the gump...")
            Pause(500)  -- Brief pause to ensure the mortar and pestle is used
            toolUsed = true  -- Mark the mortar as used
        else
            Messages.Print("Mortar and pestle not found!")
        end
    end
    
    -- Press the "Create Last" button to craft the item
    Gumps.PressButton(2653346093, 21)
    
    -- Wait for the gump
    Gumps.WaitForGump(2653346093, 1000)
    
    -- Brief pause to ensure proper timing before proceeding
    Pause(500)

    -- Scan the journal for "You have worn out your tool!"
    if Journal.Contains("You have worn out your tool!") then
        local tool = Items.FindByType(CRAFTING_TOOL_GRAPHIC_ID)
        if tool then
            Player.UseObject(tool.Serial)
            Messages.Print("Using a new mortar and pestle...")
            Pause(500)  -- Brief pause to ensure it is used
            toolUsed = false  -- Reset the mortar usage flag
        else
            Messages.Print("Mortar and pestle not found!")
        end
        
        -- Clear the journal to avoid repeatedly seeing the same message
        Journal.Clear()
        
        -- Restart the loop after handling the worn-out tool
        Messages.Print("Restarting the script...")
        Pause(1000) 
    end

    Pause(500)

end	