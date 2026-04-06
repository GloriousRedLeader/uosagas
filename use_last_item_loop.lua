------------------------------------------------------------------------------------
-- START OPTIONS for a script that prompts use to select an item, e.g. a keg.
-- it will then loop forever and click on that item every 1 second.
-- by OMG Arturo
------------------------------------------------------------------------------------

-- Don't screw around with this.
local VERSION = "1.3"

-- Probably don't mess with this either
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
Messages.Print("Double-clicker Online (v" .. VERSION .. ")", Colors.Info)
Messages.Print("D-Clicks an object many times", Colors.Info)
Messages.Print("__________________________________", Colors.Info)

Messages.Print("Select an object", Colors.Confirm)

obj = Targeting.GetNewTarget()
while true do
    Player.UseObject(obj)
    Pause(ACTION_DELAY)
end