------------------------------------------------------------------------------------
-- START OPTIONS for script that applies poison to blade
-- by OMG Arturo
------------------------------------------------------------------------------------

-- Don't screw around with this.
local VERSION = "1.0"

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
Messages.Print("Poison Application System Online (v" .. VERSION .. ")", Colors.Info)
Messages.Print("Applies poison to currently equipped weapon", Colors.Info)
Messages.Print("__________________________________", Colors.Info)

local poison = Items.FindByType(0x0F0A)
if poison ~= nil then
    local weapon = Items.FindByLayer(1)
    if weapon ~= nil then
        Skills.Use("Poisoning")
        Target.WaitForTarget(1000)
        Target.TargetSerial(poison.Serial)
        Target.WaitForTarget(1000)
        Target.TargetSerial(weapon.Serial)
    end
end
