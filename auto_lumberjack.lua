------------------------------------------------------------------------------------
-- START OPTIONS for script that auto lumberjacks
-- by OMG Arturo
------------------------------------------------------------------------------------

-- Don't screw around with this.
local VERSION = "1.2"

-- Probably don't mess with this either
local ACTION_DELAY = 750

local TOOL_GRAPHIC_ID = 0x0F43

local LOG_GRAPHIC_ID = 0x1BDD

-- Only keep these leathers, rest gets dropped on groud
local KEEP_HUES = {
    --0x0000, -- Regular
    --0x0973, -- Dull Copper
    --0x0966, -- Shadow Iron
    --0x096D, -- Copper
    --0x0972, -- Bronze
    --0x08A5, -- Gold
    --0x0979, -- Agapite
    --0x089F, -- Verite
    0x08AB, -- Valorite
}

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


tool = GetTool(2)
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
    if Journal.Contains("There's not enough wood") or Journal.Contains("You can't use an axe on that") then
        Messages.Print("Done", Colors.Caution)
        break
    end
    Journal.Clear()

    tool = GetTool(2)
    if not tool then
        Messages.Print("Tool not found", Colors.Warning)
        break
    end

    Player.UseObject(tool.Serial)
    Target.WaitForTarget(3000)
    Target.Last()
end

for _, log in ipairs(Items.FindByFilter({ onground = false, graphics = LOG_GRAPHIC_ID})) do
    if log and log.Container == Player.Backpack.Serial and not tableContains(KEEP_HUES, log.Hue) then
        Player.PickUp(log.Serial, log.Amount)
        Player.DropOnGround()
        Pause(ACTION_DELAY)
    elseif log and log.Container == Player.Backpack.Serial then
        Player.UseObject(tool.Serial)
        Target.TargetSerial(log.Serial)
        Pause(ACTION_DELAY)
    end
end