-- ============================================================================
-- START OPTIONS for
-- Auto Gold Consolidator (UO Sagas)
-- Drops backpack gold and nearby ground gold (within 2 tiles) at your feet,
-- combining them into a single pile up to a maximum of 60,000 gold.
-- by OMG Arturo
-- ============================================================================

-- Don't screw aroudn with this.
local VERSION = "1.1"

local ACTION_DELAY = 500

local GOLD_GRAPHIC = 0x0EED

local MAX_STACK = 25000

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

function ProcessGold()
    -- 1. Find gold currently in the backpack
    local bagGold = Items.FindByFilter({ graphics = {GOLD_GRAPHIC}, onground = false })
    local mainBagGold = nil
    local bagAmount = 0

    if bagGold then
        for _, item in ipairs(bagGold) do
            if item.RootContainer == Player.Serial then
                mainBagGold = item
                bagAmount = item.Amount or 1
                break -- We only want to operate on one bag pile at a time
            end
        end
    end

    -- 2. If the bag has a completed 25k stack, drop it on the ground immediately
    if bagAmount >= MAX_STACK then
        Player.PickUp(mainBagGold.Serial, MAX_STACK)
        Pause(ACTION_DELAY)
        Player.DropOnGround()
        Pause(ACTION_DELAY)
        return true -- State changed, run loop again
    end

    -- 3. Find all gold on the ground within 2 tiles
    local groundGold = Items.FindByFilter({ graphics = {GOLD_GRAPHIC}, onground = true, rangemin = 0, rangemax = 2 })
    local partialGroundPiles = {}

    if groundGold then
        for _, item in ipairs(groundGold) do
            if (item.Amount or 1) < MAX_STACK then
                table.insert(partialGroundPiles, item)
            end
        end
    end

    -- 4. Exit Condition: Bag is empty and there is 1 (or 0) partial piles on the ground
    if bagAmount == 0 and #partialGroundPiles <= 1 then
        return false -- We are fully consolidated
    end

    -- 5. If we have room in the bag, pull exactly what we need from a partial ground pile
    if #partialGroundPiles > 0 then
        local targetGroundPile = partialGroundPiles[1]
        local spaceNeeded = MAX_STACK - bagAmount
        local amountToTake = math.min(targetGroundPile.Amount or 1, spaceNeeded)

        Player.PickUp(targetGroundPile.Serial, amountToTake)
        Pause(ACTION_DELAY)
        Player.DropInBackpack()
        Pause(ACTION_DELAY)
        return true -- State changed, run loop again
    end

    -- 6. Cleanup: Bag has leftover gold (< 25k) but no more ground piles exist to combine with.
    -- Drop this final remainder on the ground so your inventory is clean.
    if bagAmount > 0 then
        Player.PickUp(mainBagGold.Serial, bagAmount)
        Pause(ACTION_DELAY)
        Messages.Print("Dropping " .. tostring(mainBagGold.Amount) .. " gold", Colors.Confirm)
        Player.DropOnGround()
        Pause(ACTION_DELAY)
        return true -- State changed, run loop again
    end

    return false
end

-- Run the logic continuously until ProcessGold() returns false (meaning no more moves are needed)
local isRunning = true
while isRunning do
    isRunning = ProcessGold()
    Pause(150) -- Small buffer between loop cycles to prevent client freezing
end

Messages.Print("Done.", Colors.Info)