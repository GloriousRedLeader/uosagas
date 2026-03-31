------------------------------------------------------------------------------------
-- START OPTIONS for script that auto lumberjacks
-- by OMG Arturo
------------------------------------------------------------------------------------

-- Don't screw around with this.
local VERSION = "1.0"

-- Probably don't mess with this either
local ACTION_DELAY = 750

local AXE_GRAPHIC_ID = 0x0F43

local LOG_GRAPHIC_ID = 0x1BDD

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
Messages.Print("Lumberjacking System Online (v" .. VERSION .. ")", Colors.Info)
Messages.Print("Equips axe and double clicks it", Colors.Info)
Messages.Print("__________________________________", Colors.Info)

while true do

    local tool = Items.FindByLayer(2)

    if tool == nil then
        Messages.Print("No tool in hand", Colors.Warning)
        tool = Items.FindByType(AXE_GRAPHIC_ID)
        if tool == nil then
            Messages.Print("No tool found in backpacking, halting", Colors.Alert)
            return
        end

        Messages.Print("Equipping axe", Colors.Action)
        Player.Equip(tool.Serial)
        Pause(ACTION_DELAY)
    end

    Player.UseObject(tool.Serial)
    logs = Items.FindByType(LOG_GRAPHIC_ID)
    if logs ~= nil then
        Messages.Print(logs.Name)
        Target.WaitForTarget(750)
        Target.TargetSerial(logs.Serial)
    end
    Pause(ACTION_DELAY)
end