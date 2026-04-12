------------------------------------------------------------------------------------
-- START OPTIONS for script that auto fishes
-- by OMG Arturo
------------------------------------------------------------------------------------

-- Don't screw around with this.
local VERSION = "1.0"

-- Probably don't mess with this either
local ACTION_DELAY = 750

-- Static tool graphic id
local TOOL_GRAPHIC_ID = 0x0DC0

-- Use /say when dropping or keeping a resource.
-- Otherwise it will print privately over your head.
local NOISY_MODE = false

-- Turn this on if you want to leave your char over night.
-- true = Keep fishing a node even it if is empty
-- false = script stops when no more fish
local KEEP_FISHING_AFTER_NODE_IS_EMPTY = true

-- Enable this to auto-drop all the junk in the list below
-- When this variable is false, no items are dropped.
local DROP_JUNK_ITEMS = true

-- Drop at player's feet any item in this list
local DROP_THESE_ITEMS = {
    0x170F, -- Shoes
    0x1711, -- Thigh Boots
    0x170D, -- Sandals
    0x170B, -- Boots
    0x0000, -- 00000000
    0x0000, -- 00000000
    0x0000, -- 00000000
    0x0000, -- 00000000
    0x0000, -- 00000000
    0x09CF, -- Fish
    0x09CC, -- Fish
    0x09CD, -- Fish
    0x0DD6, -- Prize Fish
    0x0DD6, -- Truly Rare Fish
    0x09CE, -- Fish
    0x0000, -- 00000000
    0x0000, -- 00000000
    0x0000, -- 00000000
    0x0000, -- 00000000
    0x0000, -- 00000000
    0x0000, -- 00000000
    0x0000, -- 00000000
    0x0000, -- 00000000
    0x0000, -- 00000000
    0x0000, -- 00000000
    0x0000, -- 00000000
    0x0000, -- 00000000
    0x0000, -- 00000000
    0x0000, -- 00000000
    0x0000, -- 00000000
    0x0000, -- 00000000
    0x0000, -- 00000000
    0x0000, -- 00000000
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
Messages.Print("Fishing System Online (v" .. VERSION .. ")", Colors.Info)
Messages.Print("Auto-fishes a single node until it's", Colors.Info)
Messages.Print("depleted. Check options in script.", Colors.Info)
Messages.Print("__________________________________", Colors.Info)

local checkFish = 0

-- Helepr
function tableContains(tbl, val)
    for _, value in ipairs(tbl) do
        if value == val then
            return true
        end
    end
    return false
end

function DropJunk()
    for index, junkGraphic in ipairs(DROP_THESE_ITEMS) do
        for _, junkItem in ipairs(Items.FindByFilter({ onground = false, graphics = junkGraphic})) do
            if junkItem and junkItem.Container == Player.Backpack.Serial then
                if NOISY_MODE then
                    Player.Say("- " .. junkItem.Name .. " -", Colors.Warning)
                else
                    Messages.OverheadMobile(Player.Serial, "- " .. junkItem.Name .. " -", Colors.Warning)
                end
                Player.PickUp(junkItem.Serial, junkItem.Amount)
                Player.DropOnGround()
                Pause(ACTION_DELAY)
            end
        end
    end
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

local checkFish = os.time() + 8

while true do
    Pause(ACTION_DELAY)
    if Journal.Contains("You can't fish") or Journal.Contains("Target cannot be seen") or (KEEP_FISHING_AFTER_NODE_IS_EMPTY == false and Journal.Contains("The fish don't seem to be biting")) or Journal.Contains("That is too far away") or Journal.Contains("You need to be closer to the water") then
        Messages.Print("Done", Colors.Caution)
        --Messages.OverheadMobile(Player.Serial, "Done", Colors.Caution)
        break
    end
    Journal.Clear()

    tool = GetTool(2)
    if not tool then
        Messages.Print("Tool not found", Colors.Warning)
        break
    end

    if os.time() > checkFish then
        Player.UseObject(tool.Serial)
        Target.WaitForTarget(3000)
        Target.Last()
        checkFish = os.time() + 8
    else
        DropJunk()
    end
end

DropJunk()