------------------------------------------------------------------------------------
-- START OPTIONS for script that auto mines
-- by OMG Arturo
------------------------------------------------------------------------------------

-- Don't screw around with this.
local VERSION = "1.0"

-- Probably don't mess with this either
local ACTION_DELAY = 750

local PICKAXE_GRAPHIC_ID = 0x0E86

-- Enable to auto smelt ore when near a forge
local SMELT_ORE = false

local SMITHY_TOOL_GRAPHIC_ID = 0x13E3

local ORES = { 6585, 6584, 6586, 6585 }

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
Messages.Print("Mining System Online (v" .. VERSION .. ")", Colors.Info)
Messages.Print("Equips pickaxe and double clicks it", Colors.Info)
Messages.Print("__________________________________", Colors.Info)

while true do

    local tool = Items.FindByLayer(1)
    if tool == nil then
        Messages.Print("No tool in hand", Colors.Warning)
        tool = Items.FindByType(PICKAXE_GRAPHIC_ID)
        if tool == nil then
            Messages.Print("No tool found in backpacking, halting", Colors.Alert)
            return
        end

        Messages.Print("Equipping tool", Colors.Action)
        Player.Equip(tool.Serial)
        Pause(ACTION_DELAY)
    end



    local smithyTool = Items.FindByType(SMITHY_TOOL_GRAPHIC_ID)
    if SMELT_ORE and smithyTool ~= nil then
        Player.UseObject(smithyTool.Serial)
    end

    Journal.Clear()
    Player.UseObject(tool.Serial)





    while Target.IsTargeting() do
        Pause(250)
    end

    Pause(ACTION_DELAY)
    if Journal.Contains("There is no metal here to mine") then
        Messages.OverheadMobile(Player.Serial, "- no more ore -", Colors.Caution)
    end
    Journal.Clear()
    --    if Journal.Contains("There's not enough wood") then
    --        Messages.OverheadMobile(Player.Serial, "- no more wood -", Colors.Caution)
    --    end
end