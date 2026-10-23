-- UO SAGAS IN-GAME LUA ASSISTANT (NOT RAZOR ENHANCED)
-- Gold + cut leather dropper and consolidator
-- Original gold stacker by OMG Arturo; corrected version 1.4

local VERSION = "1.4"
local ACTION_DELAY = 600
local MAX_STACK = 20000
local GROUND_RANGE = 2
local MAX_CARRY_WEIGHT = 800
local WEIGHT_BUFFER = 10
local MAX_ACTIONS = 120

local LEATHER_GRAPHIC = 0x1081
local POSSIBLE_LEATHER_GRAPHIC = 0x096D -- also used as the Copper hue
local GOLD_GRAPHIC = 0x0EED

local Colors = { Alert=33, Warning=48, Caution=53, Action=67, Confirm=73, Info=84 }

local RESOURCES = {
    { name="Cut leather", graphic=LEATHER_GRAPHIC, grams=0.5,
    graphics={LEATHER_GRAPHIC, POSSIBLE_LEATHER_GRAPHIC} },
    { name="Gold", graphic=GOLD_GRAPHIC, grams=0.02,
    graphics={GOLD_GRAPHIC} }
}

local function Amount(item)
    return math.max(0, math.floor(item.Amount or 1))
end

local function Match(item, res)
    if not item or not item.Serial then return false end
    if item.Graphic == res.graphic then return true end
    if res.graphic ~= LEATHER_GRAPHIC then return false end
    if item.Graphic ~= POSSIBLE_LEATHER_GRAPHIC then return false end
    -- Only accept this alternate graphic when it is actually named leather.
    local name = string.lower(item.Name or "")
    return string.find(name, "leather", 1, true) ~= nil and not item.IsArmor
end

local function OwnedByMe(item)
    if not item then return false end
    if item.Container == Player.Backpack.Serial then return true end
    if item.RootContainer == Player.Serial then return true end
    if item.RootContainer == Player.Backpack.Serial then return true end
    return false
end

local function BackpackPiles(res)
    local list, seen = {}, {}
    local function Add(item)
        if Match(item, res) and OwnedByMe(item) and not seen[item.Serial] then
            seen[item.Serial] = true
            table.insert(list, item)
        end
    end
    local direct = Items.FindInContainer(Player.Backpack.Serial) or {}
    for _, item in ipairs(direct) do Add(item) end
    local all = Items.FindByFilter({graphics=res.graphics, onground=false}) or {}
    for _, item in ipairs(all) do Add(item) end
    return list
end

local function GroundPiles(res)
    local result = {}
    local all = Items.FindByFilter({graphics=res.graphics, onground=true,
    rangemin=0, rangemax=GROUND_RANGE}) or {}
    for _, item in ipairs(all) do
        if Match(item, res) and not item.IsLocked and Amount(item) > 0 then
            table.insert(result, item)
        end
    end
    return result
end

local function AtFeet(item)
    return item.X == Player.X and item.Y == Player.Y
end

local function WeightCeiling()
    return math.min(MAX_CARRY_WEIGHT, Player.MaxWeight or MAX_CARRY_WEIGHT)
end

local function FreeStones()
    if type(Player.Weight) ~= "number" then return 0 end
    return math.max(0, WeightCeiling() - Player.Weight - WEIGHT_BUFFER)
end

local function CanLiftGround(item, res)
    return Amount(item) * res.grams <= FreeStones()
end

local function Move(item, how, amount)
    amount = amount or Amount(item)
    if not item or amount < 1 then return false end
    if not Player.PickUp(item.Serial, amount) then
        Messages.Print("Cannot lift " .. (item.Name or "item"), Colors.Warning)
        return false
    end
    Pause(ACTION_DELAY)
    local ok = false
    if how == "backpack" then
        ok = Player.DropInBackpack()
    else
        ok = Player.DropOnGround()
    end
    Pause(ACTION_DELAY)
    if not ok then
        Messages.Print("Drop failed; trying ground recovery", Colors.Alert)
        Player.DropOnGround()
        Pause(ACTION_DELAY)
        return false
    end
    return true
end

-- Always drop backpack leather FIRST, even if existing ground gold is heavy.
local function EmptyBackpack(res)
    local first = BackpackPiles(res)
    Messages.Print(res.name .. ": " .. #first .. " backpack stack(s) found", Colors.Info)
    local priorSerial, priorAmount = nil, nil
    for i = 1, MAX_ACTIONS do
        local piles = BackpackPiles(res)
        if #piles == 0 then return true end
        local item = piles[1]
        local amount = Amount(item)
        if amount <= 0 then return false end
        if priorSerial == item.Serial and priorAmount == amount then
            Messages.Print(res.name .. ": backpack item did not move", Colors.Warning)
            return false
        end
        priorSerial, priorAmount = item.Serial, amount
        local take = math.min(amount, MAX_STACK)
        if not Move(item, "ground", take) then return false end
        Messages.Print("Dropped " .. take .. " " .. res.name, Colors.Confirm)
    end
    Messages.Print(res.name .. ": reached action limit", Colors.Warning)
    return false
end

local function DiagnoseLeather()
    if #BackpackPiles(RESOURCES[1]) > 0 then return end
    local items = Items.GetContainerItems(Player.Backpack.Serial) or {}
    for _, item in ipairs(items) do
        if string.find(string.lower(item.Name or ""), "leather", 1, true) then
            local details = string.format("0x%04X hue 0x%04X", item.Graphic or 0, item.Hue or 0)
            Messages.Print("Leather-looking item: " .. details, Colors.Info)
        end
    end
end

-- Ground-only movement: never put these piles in the backpack.
-- The game may automatically join stacks dropped on the same tile.
local function PutNearbyPilesAtFeet(res)
    local skipped = 0
    for _, item in ipairs(GroundPiles(res)) do
        if not AtFeet(item) then
            if CanLiftGround(item, res) then
                Move(item, "ground")
            else
                skipped = skipped + 1
            end
        end
    end
    if skipped > 0 then
        Messages.Print(res.name .. ": skipped " .. skipped .. " heavy ground pile(s)", Colors.Caution)
    end
end

local function TryDirectGroundMerge(res)
    local piles = GroundPiles(res)
    for i = 1, #piles do
        local a = piles[i]
        if AtFeet(a) and Amount(a) < MAX_STACK then
            for j = i + 1, #piles do
                local b = piles[j]
                if AtFeet(b) and a.Graphic == b.Graphic and a.Hue == b.Hue then
                    local smaller = a
                    if Amount(b) < Amount(a) then smaller = b end
                    if CanLiftGround(smaller, res) then
                        Move(smaller, "ground")
                    end
                    return
                end
            end
        end
    end
end

-- Fallback: merge matching piles in the backpack, using only a safe amount.
-- This can split a source pile to make a 20,000 stack; never load more than
-- the smaller of (actual MaxWeight, 800) minus the safety buffer.
local function FindSafeMerge(res, partialDone)
    local piles = GroundPiles(res)
    local limit = math.min(MAX_STACK, math.floor(FreeStones() / res.grams))
    local best, bestScore = nil, -1
    for i = 1, #piles do
        local a = piles[i]
        if AtFeet(a) then
            for j = 1, #piles do
                if i ~= j then
                    local b = piles[j]
                    if AtFeet(b) and a.Graphic == b.Graphic and a.Hue == b.Hue then
                        local take = math.min(Amount(b), MAX_STACK - Amount(a), limit - Amount(a))
                        local key = tostring(a.Graphic) .. ":" .. tostring(a.Hue or 0)
                        if take > 0 then
                            local partial = take < Amount(b)
                            if not partial or not partialDone[key] then
                                local score = Amount(a) + take
                                if not partial then score = score + 1000000 end
                                if score > bestScore then
                                    best = {first=a, second=b, take=take, total=Amount(a)+take, key=key, partial=partial}
                                    bestScore = score
                                end
                            end
                        end
                    end
                end
            end
        end
    end
    return best
end

local function MergeThroughBackpack(res)
    local partialDone = {}
    local cycles = 0
    while cycles < MAX_ACTIONS do
        local merge = FindSafeMerge(res, partialDone)
        if not merge then return end
        cycles = cycles + 1
        local a = merge.first
        local b = merge.second

        if not CanLiftGround(a, res) then return end
        if not Move(a, "backpack") then return end

        -- Re-check after the first move because Player.Weight may change.
        if merge.take * res.grams > FreeStones() then
            EmptyBackpack(res)
            return
        end
        if not Move(b, "backpack", merge.take) then
            EmptyBackpack(res)
            return
        end

        local bag = BackpackPiles(res)
        local merged, count = nil, 0
        for _, item in ipairs(bag) do
            if item.Graphic == a.Graphic and item.Hue == a.Hue then
                merged = item
                count = count + 1
            end
        end
        if count ~= 1 or not merged or Amount(merged) ~= merge.total then
            Messages.Print(res.name .. ": backpack did not merge; restoring", Colors.Warning)
            EmptyBackpack(res)
            return
        end
        if not Move(merged, "ground") then return end
        Messages.Print(res.name .. ": merged " .. merge.total .. " onto ground", Colors.Confirm)
        if merge.partial then partialDone[merge.key] = true end
    end
    Messages.Print(res.name .. ": merge action limit reached", Colors.Warning)
end

Messages.Print("Gold + Leather Stacker v" .. VERSION, Colors.Info)
Messages.Print("Weight ceiling: " .. tostring(WeightCeiling()) .. " stones", Colors.Info)

if not Player.Backpack or not Player.Backpack.Serial then
    Messages.Print("Cannot find backpack", Colors.Alert)
else
    -- Phase one deliberately finishes BOTH backpack drops before ground work.
    local canConsolidate = {}
    for _, res in ipairs(RESOURCES) do
        canConsolidate[res.graphic] = EmptyBackpack(res)
    end
    DiagnoseLeather()
    for _, res in ipairs(RESOURCES) do
        if canConsolidate[res.graphic] then
            PutNearbyPilesAtFeet(res)
            TryDirectGroundMerge(res)
            MergeThroughBackpack(res)
        else
            Messages.Print(res.name .. ": skipped ground merges after drop failure", Colors.Warning)
        end
    end
    Messages.Print("Done", Colors.Info)
end
