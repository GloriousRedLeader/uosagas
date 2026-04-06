------------------------------------------------------------------------------------
-- START OPTIONS for
-- script that basically presses the craft last button.
-- Profession depends on CRAFTING_TOOL_GRAPHIC_ID below.
-- by OMG Arturo
------------------------------------------------------------------------------------

-- Don't screw aroudn with this.
local VERSION = "1.1"

-- Pick the right one. Will search bags for a tool and use it.
local CRAFTING_TOOL_GRAPHIC_ID = 0x0E9B    -- Alchemy
--local CRAFTING_TOOL_GRAPHIC_ID = 0x0FBF    -- Scribe

local ACTION_DELAY = 750

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
Messages.Print("Crafting System Online (v" .. VERSION .. ")", Colors.Info)
Messages.Print("Set the tool graphic id in script", Colors.Info)
Messages.Print("__________________________________", Colors.Info)

while true do
    -- Open Menu
    local tool = Items.FindByType(CRAFTING_TOOL_GRAPHIC_ID)
    if tool then
        Player.UseObject(tool.Serial)
        Pause(ACTION_DELAY)
    else
        Messages.Print("Tool not found, quitting", Colors.Alert)
        return
    end

    -- Press the "Create Last" button to craft the item
    Gumps.PressButton(2653346093, 21)

    -- Wait for the gump
    Gumps.WaitForGump(2653346093, 1000)

    Pause(ACTION_DELAY)
end