-- ============================================================================
-- START OPTIONS for
-- Auto Gold Consolidator (UO Sagas)
-- Drops backpack gold and nearby ground gold (within 2 tiles) at your feet,
-- combining them into a single pile up to a maximum of 60,000 gold.
-- by OMG Arturo
-- ============================================================================

-- Don't screw aroudn with this.
local VERSION = "1.1"

local ACTION_DELAY = 750

local GOLD_GRAPHIC = 0x0EED

local MAX_STACK = 60000

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
Messages.Print("Gold Stacker (v" .. VERSION .. ")", Colors.Info)
Messages.Print("Yarrrr", Colors.Info)
Messages.Print("__________________________________", Colors.Info)

local currentFeetAmount = 0
local itemsToProcess = {}

-- 1. Gather all gold on the ground within 2 tiles
local groundGold = Items.FindByFilter({
    graphics = {GOLD_GRAPHIC},
    onground = true,
    rangemin = 0,
    rangemax = 2
})

if groundGold then
    for _, item in ipairs(groundGold) do
        -- If distance is 0, it's already at our feet, so we count it as our base pile
        if item.Distance == 0 then
            currentFeetAmount = currentFeetAmount + (item.Amount or 1)
        else
            table.insert(itemsToProcess, item)
        end
    end
end

-- 2. Gather all gold currently in inventory
local invGold = Items.FindByFilter({
    graphics = {GOLD_GRAPHIC},
    onground = false
})

if invGold then
    for _, item in ipairs(invGold) do
        -- Ensure it's inside the player's root container (backpack/equipped)
        if item.RootContainer == Player.Serial then
            table.insert(itemsToProcess, item)
        end
    end
end

-- 3. Process the queued gold
if currentFeetAmount >= MAX_STACK then
    Messages.Print("You already have 60,000 or more gold at your feet!", Colors.Alert)
else
    local movedAny = false

    for _, item in ipairs(itemsToProcess) do
        if currentFeetAmount >= MAX_STACK then
            Messages.Print("Reached the 60,000 gold limit at your feet.", Colors.Confirm)
            break
        end

        local availableSpace = MAX_STACK - currentFeetAmount
        local amountToMove = item.Amount or 1

        -- Only move what we need to reach the maximum 60,000 cap
        if amountToMove > availableSpace then
            amountToMove = availableSpace
        end

        -- Pick up from source
        Player.PickUp(item.Serial, amountToMove)
        Pause(ACTION_DELAY)

        -- Drop exactly at player coordinates
        Player.DropOnGround()
        Pause(ACTION_DELAY)

        currentFeetAmount = currentFeetAmount + amountToMove
        movedAny = true
    end

    if movedAny then
        Messages.Print("Finished! Total gold at feet: " .. tostring(currentFeetAmount), Colors.Info)
    else
        Messages.Print("No additional nearby gold to consolidate.", Colors.Caution)
    end
end