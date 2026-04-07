------------------------------------------------------------------------------------
-- START OPTIONS for script that auto mines
-- by OMG Arturo
------------------------------------------------------------------------------------

-- Don't screw around with this.
local VERSION = "1.6"

-- Probably don't mess with this either
local ACTION_DELAY = 750

-- Static tool graphic id
local TOOL_GRAPHIC_ID = 0x0E86

-- TODO: THIS IS NOT IMPLEMENTED YET, DOES NOTHING.
-- Enable to auto smelt ore when near a forge
local SMELT_ORE = false

-- TODO: THIS IS NOT IMPLEMENTED YET, DOES NOTHING.
-- Needed for smelting
local SMITHY_TOOL_GRAPHIC_ID = 0x13E3

-- Only keep these ores, rest gets dropped on groud
local KEEP_HUES = {
    --0x0000, -- Regular Iron
    --0x0973, -- Dull Copper
    --0x0966, -- Shadow Iron
    --0x096D, -- Copper
    --0x0972, -- Bronze
    --0x08A5, -- Gold
    --0x0979, -- Agapite
    --0x089F, -- Verite
    0x08AB, -- Valorite
}

local ORE_GRAPHICS = { 0x19B9, 0x19B8, 0x19BA, 0x19B7 }

-- Use /say when dropping or keeping a resource.
-- Otherwise it will print privately over your head.
local NOISY_MODE = true

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
Messages.Print("Automines a single node until it's", Colors.Info)
Messages.Print("depleted. Check options in script.", Colors.Info)
Messages.Print("__________________________________", Colors.Info)

-- Helepr
function tableContains(tbl, val)
    for _, value in ipairs(tbl) do
        if value == val then
            return true
        end
    end
    return false
end

-- Finds tool needed to gather resources
function GetTool(layer)
    local tool = Items.FindByLayer(layer)
    if tool == nil or tool.Graphic ~= TOOL_GRAPHIC_ID then
        Player.ClearHands("both")
        Pause(ACTION_DELAY)
        Messages.Print("No tool in hand", Colors.Warning)
        tool = Items.FindByType(TOOL_GRAPHIC_ID)
        if tool == nil then
            Messages.Print("No tool found in backpacking, halting", Colors.Alert)
            return
        end
        Messages.Print("Equipping tool", Colors.Action)
        Player.Equip(tool.Serial)
        Pause(ACTION_DELAY)
    end
    return tool
end

tool = GetTool(1)
if not tool then
    Messages.Print("Tool not found", Colors.Warning)
    return
end

Journal.Clear()
Player.UseObject(tool.Serial)
Messages.Print("Select a node", Colors.Confirm)
Target.WaitForTarget(3000)

while Target.IsTargeting() do
    Pause(250)
end

while true do
    Pause(ACTION_DELAY)
    if Journal.Contains("There is no metal here to mine") or Journal.Contains("Target cannot be seen") or Journal.Contains("You can't mine") or Journal.Contains("That is too far away") then
        Messages.Print("Done", Colors.Caution)
        break
    end
    Journal.Clear()

    --local smithyTool = Items.FindByType(SMITHY_TOOL_GRAPHIC_ID)
    --if SMELT_ORE and smithyTool ~= nil then
    --    Player.UseObject(smithyTool.Serial)
    --end
    tool = GetTool(1)
    if not tool then
        Messages.Print("Tool not found", Colors.Warning)
        break
    end

    Player.UseObject(tool.Serial)
    Target.WaitForTarget(3000)
    Target.Last()
end

for index, oreGraphic in ipairs(ORE_GRAPHICS) do
    for _, ore in ipairs(Items.FindByFilter({ onground = false, graphics = oreGraphic})) do
        if ore and ore.Container == Player.Backpack.Serial and not tableContains(KEEP_HUES, ore.Hue) then
            if NOISY_MODE then
                Player.Say("- " .. ore.Name .. " -", Colors.Warning)
            else
                Messages.OverheadMobile(Player.Serial, "- " .. ore.Name .. " -", Colors.Warning)
            end
            Player.PickUp(ore.Serial, ore.Amount)
            Player.DropOnGround()
            Pause(ACTION_DELAY)
        end
    end
end