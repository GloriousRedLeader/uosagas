------------------------------------------------------------------------------------
-- AUTO FISHER + ARCHER (UO Sagas in-game Lua assistant, not Razor)
-- by OMG Arturo; self-target fishing, archer defense and steak stacking
------------------------------------------------------------------------------------

local VERSION = "1.9.1"
local ACTION_DELAY = 750
local TOOL_GRAPHIC_ID = 0x0DC0 -- Fishing pole
local NOISY_MODE = false
-- True: advance the boat to a new node when the current one is depleted.
-- False: stop on a depleted node (the original stop/continue option).
local KEEP_FISHING_AFTER_NODE_IS_EMPTY = true
local BOAT_FORWARD_STEPS = 5
local BOAT_STEP_DELAY_MS = 750
-- If a forward move hits an obstacle, strafe five one-tile steps to the left,
-- probe forward, then try five right steps and another forward probe if needed.
local BOAT_OBSTACLE_SIDE_STEPS = 5
-- If BOTH side detours fail, reverse five tiles and try the side detours again.
local BOAT_OBSTACLE_BACK_STEPS = 5
-- Give the boat time to report a move that didn't show up immediately.
local BOAT_MOVE_CONFIRM_SECONDS = 3
local BOAT_UNKNOWN_RETRY_SECONDS = 3
local BOAT_MAX_UNCONFIRMED_COMMANDS = 3
-- Never wait forever for manual X/Y movement when the boat gets stuck.
-- Retry navigation automatically, then resume fishing if it is still blocked.
local BOAT_STUCK_AUTO_RETRY_SECONDS = 12
local BOAT_MAX_STUCK_AUTO_RETRIES = 2
local BOAT_ABORT_COOLDOWN_SECONDS = 30
-- Retry temporary fishing/equipment/focus failures rather than stopping.
local FISHING_RETRY_SECONDS = 4
local POST_COMBAT_RECOVERY_SECONDS = 2
local FISHING_CAST_INTERVAL_SECONDS = 8
local DROP_JUNK_ITEMS = true

-- Any listed fish is KEPT (not carved and not dropped).
-- Leave this empty to keep no fish. Entries can be graphic IDs or name fragments.
-- Shared graphics (e.g. 0x0DD6 for several magic fish) can be filtered by name.
local KEEP_FISH = {
    -- 0x0DD6,          -- Keep ALL magic/special fish with this graphic.
    -- "truly rare fish", -- Keep fish whose name contains this phrase.
}

-- Only the four ordinary fish graphics are cut with a knife.
local ORDINARY_FISH_GRAPHICS = {0x09CC, 0x09CD, 0x09CE, 0x09CF}
local RAW_FISH_STEAK_GRAPHIC = 0x097A

-- Hold about 20 raw fish steaks before consolidating at your feet.
-- Before leaving a depleted node, flush even smaller stacks.
local STEAK_BUFFER_AMOUNT = 20
local STEAK_GROUND_RANGE = 2
local STEAK_MAX_CARRY_WEIGHT = 800
-- Classic UO raw fish steaks weigh roughly 0.1 stone EACH in a stack.
-- Use the item's displayed total weight if available; otherwise this estimate.
local STEAK_WEIGHT_PER_PIECE = 0.1
-- Additional spare stones; guarantees estimates do not approach 800 exactly.
local STEAK_PICKUP_SAFETY = 5
-- A refused ground pickup is not retried on every pass.
local STEAK_FAILED_PICKUP_RETRY = 15

-- Try a dagger first, then a cleaver, then a Sagas skinning knife.
local FISH_KNIFE_GRAPHICS = {0x0F52, 0x0EC2, 0xFEA9}

-- Corpse skinning after combat. Uses a Sagas skinning knife in inventory.
local AUTO_SKIN_CORPSES = true
local SKINNING_KNIFE_GRAPHIC = 0xFEA9
local CORPSE_SKIN_RANGE = 2
local SKIN_RETRY_SECONDS = 5
-- Same body IDs already skipped by the archer/skinner script (human corpses).
local SKIP_HUMAN_CORPSES = true

-- Cut skinned hides (0x1079) into leather (0x1081) with scissors.
-- Only these CUT LEATHER hues are retained; all other hues go on the ground.
-- You may add more hues to this list later, if desired.
local HIDE_GRAPHIC = 0x1079
local CUT_LEATHER_GRAPHIC = 0x1081
local SCISSORS_GRAPHIC = 0x0F9F
local KEEP_LEATHER_HUES = {
    0x089F, -- Verite
    0x08AB  -- Valorite
}
local HIDE_ACTION_RETRY_SECONDS = 5

-- Smart stacking for KEPT cut leather (Verite and Valorite only).
-- Combine existing backpack stacks first; then lift matching ground piles.
-- For temporary leather pickups, use the 800-stone drag threshold,
-- NOT Player.MaxWeight (which may show 390). A pickup must stay STRICTLY
-- below 800 stones; the server still has the final say on whether it works.
-- Never move Verite/Valorite back onto the ground merely for stacking.
local LEATHER_GROUND_RANGE = 2
local LEATHER_MAX_CARRY_WEIGHT = 800
local LEATHER_WEIGHT_PER_PIECE = 0.5
local LEATHER_FAILED_PICKUP_RETRY_SECONDS = 15
local LEATHER_FAILED_MERGE_RETRY_SECONDS = 30

-- Creature defense: check 5 tiles around the player BEFORE every fishing cast.
local AUTO_ATTACK = true
local ATTACK_RANGE = 5
local ATTACK_RETRY_SECONDS = 3
-- Gray and Criminal are gray targets; Enemy and Murderer cover hostile/red mobs.
local ATTACK_NOTORIETIES = {"Gray", "Criminal", "Enemy", "Murderer"}
-- Avoid attacking human-bodied mobiles (including most players).
-- The assistant cannot reliably identify all player-controlled pets or players.
local SKIP_HUMAN_MOBILES = true
local SKIP_RENAMABLE_PETS = true

-- Preferred bow graphics, in order. 0x13B2 is the standard bow.
-- Remove any types you do not want the script to equip.
local BOW_GRAPHICS = {
    0x13B2, -- Bow
    0x13B1, -- Bow (alternate art)
    0x26C2, -- Composite bow
    0x2D1F, -- Magical shortbow
    0x2D1E, -- Elven composite longbow
    0x27A5  -- Yumi
}

local DROP_THESE_ITEMS = {
    0x170F, -- Shoes
    0x1711, -- Thigh Boots
    0x170D, -- Sandals
    0x170B, -- Boots
    0x0000, -- Unused
    0x0000, -- Unused
    0x0000, -- Unused
    0x0000, -- Unused
    0x0000, -- Unused
    0x09CF, -- Fish
    0x09CC, -- Fish
    0x09CD, -- Fish
    0x0DD6, -- Prize / truly rare fish
    0x0DD6, -- Duplicate retained from original list
    0x09CE, -- Fish (carved instead of dropped whole)
    0x097A, -- Raw fish steaks (created by carving)
    0x0000, -- Unused
    0x0000, -- Unused
    0x0000, -- Unused
    0x0000, -- Unused
    0x0000, -- Unused
    0x0000, -- Unused
    0x0000, -- Unused
    0x0000, -- Unused
    0x0000, -- Unused
    0x0000, -- Unused
    0x0000, -- Unused
    0x0000, -- Unused
    0x0000, -- Unused
    0x0000, -- Unused
    0x0000, -- Unused
    0x0000, -- Unused
    0x0000, -- Unused
    0x0000, -- Unused
    0x0000, -- Unused
    0x0000, -- Unused
    0x0000  -- Unused
}

------------------------------------------------------------------------------------
-- END OPTIONS
------------------------------------------------------------------------------------

local Colors = {
    Alert   = 33,
    Warning = 48,
    Caution = 53,
    Action  = 67,
    Confirm = 73,
    Info    = 84,
    Status  = 93
}

local junkGraphics = {}
for _, graphic in ipairs(DROP_THESE_ITEMS) do
    if graphic ~= 0 then junkGraphics[graphic] = true end
end

local ordinaryFishGraphics = {}
for _, graphic in ipairs(ORDINARY_FISH_GRAPHICS) do
    ordinaryFishGraphics[graphic] = true
end

local function IsKeptFish(item)
    if not item then return false end
    for _, choice in ipairs(KEEP_FISH) do
        if type(choice) == "number" and item.Graphic == choice then return true end
        if type(choice) == "string" and item.Name then
            if string.find(string.lower(item.Name), string.lower(choice), 1, true) then return true end
        end
    end
    return false
end

local function IsBowGraphic(graphic)
    for _, candidate in ipairs(BOW_GRAPHICS) do
        if graphic == candidate then return true end
    end
    return false
end

local function FindEquippedBow()
    local left = Items.FindByLayer(2)
    if left and IsBowGraphic(left.Graphic) then return left end
    local right = Items.FindByLayer(1)
    if right and IsBowGraphic(right.Graphic) then return right end
    return nil
end

local function FindOwnedItem(graphic)
    local matches = Items.FindByFilter({graphics = {graphic}, onground = false}) or {}
    for _, item in ipairs(matches) do
        if item.RootContainer == Player.Serial then return item end
    end
    return nil
end

local function FindOwnedBow()
    for _, graphic in ipairs(BOW_GRAPHICS) do
        local bow = FindOwnedItem(graphic)
        if bow then return bow end
    end
    return nil
end

local function FindOwnedFishKnife()
    for _, graphic in ipairs(FISH_KNIFE_GRAPHICS) do
        local knife = FindOwnedItem(graphic)
        if knife then return knife end
    end
    return nil
end

-- Returns true only when a bow is equipped or an equip request succeeded.
local function EnsureBow()
    if FindEquippedBow() then return true end
    local bow = FindOwnedBow()
    if not bow then return false end
    Player.ClearHands("both")
    Pause(ACTION_DELAY)
    local equipped = Player.Equip(bow.Serial)
    Pause(ACTION_DELAY)
    return equipped == true or FindEquippedBow() ~= nil
end

-- A successful Player.Equip request does not guarantee that the server has
-- updated the equipment layer yet. Do not try fishing with an unverified pole.
local function EquippedFishingPole()
    local left = Items.FindByLayer(2)
    if left and left.Graphic == TOOL_GRAPHIC_ID then return left end
    local right = Items.FindByLayer(1)
    if right and right.Graphic == TOOL_GRAPHIC_ID then return right end
    return nil
end

local function EnsureFishingPole()
    local equipped = EquippedFishingPole()
    if equipped then return equipped end

    local pole = FindOwnedItem(TOOL_GRAPHIC_ID)
    if not pole then return nil end

    Player.ClearHands("both")
    Pause(ACTION_DELAY)
    Player.Equip(pole.Serial)
    Pause(ACTION_DELAY)

    -- Wait briefly for the game to acknowledge the bow -> pole switch.
    for attempt = 1, 5 do
        equipped = EquippedFishingPole()
        if equipped then return equipped end
        Pause(250)
    end
    return nil -- Retry later instead of casting while still holding a bow.
end

-- Support both current Sagas Targeting.* and older Target.* assistants.
local function FishingTargetAPI()
    if Targeting and Targeting.WaitForTarget then return Targeting end
    if Target and Target.WaitForTarget then return Target end
    return nil
end

local function CastFishingPoleOnSelf(pole)
    local api = FishingTargetAPI()
    if not api then return false end
    -- Do not initiate a fishing cast unless the pole is physically equipped.
    local equipped = EquippedFishingPole()
    if not equipped or equipped.Serial ~= pole.Serial then return false end
    if not Player.UseObject(equipped.Serial) then return false end
    if not api.WaitForTarget(3000) then return false end

    if api.Self then return api.Self() end
    if api.TargetSelf then return api.TargetSelf() end
    if api.TargetSerial then return api.TargetSerial(Player.Serial) end
    if api.Target then return api.Target(Player.Serial) end
    return false
end

-- Prioritize the closest eligible creature. Human-bodied mobiles and
-- renameable pets are excluded by default to reduce accidental attacks.
local function FindNearbyHostile()
    if not AUTO_ATTACK then return nil end

    local mobiles = Mobiles.FindByFilter({rangemax = ATTACK_RANGE, dead = false, notorieties = ATTACK_NOTORIETIES}) or {}
    local closest = nil
    for _, mobile in ipairs(mobiles) do
        if mobile.Serial and mobile.Serial ~= Player.Serial
        and not mobile.IsDead
        and not mobile.IsDestroyed
        and mobile.Distance and mobile.Distance <= ATTACK_RANGE
        and (mobile.Hits == nil or mobile.Hits > 0)
        and (not SKIP_HUMAN_MOBILES or mobile.IsHuman ~= true)
        and (not SKIP_RENAMABLE_PETS or mobile.IsRenamable ~= true) then
        if not closest or mobile.Distance < closest.Distance then
            closest = mobile
        end
    end
end
return closest
end

-- ============================================================================
-- CORPSE SKINNING: ONE CORPSE AT A TIME, ONLY WHEN NO HOSTILES ARE PRESENT
-- ============================================================================
local skinnedCorpseSerials = {}
local nextSkinAttemptBySerial = {}

local function TrySkinNearbyCorpse()
    if not AUTO_SKIN_CORPSES then return false end
    local knife = FindOwnedItem(SKINNING_KNIFE_GRAPHIC)
    if not knife then return false end
    -- Do not create heavy hides that we cannot cut later.
    if not FindOwnedItem(SCISSORS_GRAPHIC) then return false end

    local api = FishingTargetAPI()
    if not api or not api.WaitForTarget or not api.TargetSerial then return false end
    if api.IsTargeting and api.IsTargeting() then return false end

    -- The corpse filter finds all recognized corpse graphics, without a list.
    local corpses = Items.FindByFilter({corpse = true, onground = true, rangemax = CORPSE_SKIN_RANGE}) or {}
    table.sort(corpses, function(a, b)
        return (a.Distance or 99) < (b.Distance or 99)
    end)

    local now = os.time()
    for _, corpse in ipairs(corpses) do
        if corpse.Serial and (corpse.Distance == nil or corpse.Distance <= CORPSE_SKIN_RANGE)
        and not skinnedCorpseSerials[corpse.Serial] then
        if SKIP_HUMAN_CORPSES and (corpse.Amount == 400 or corpse.Amount == 401) then
            skinnedCorpseSerials[corpse.Serial] = true
        elseif now >= (nextSkinAttemptBySerial[corpse.Serial] or 0) then
            -- Don't clear the journal: navigation needs to see tiller messages.
            if Player.UseObject(knife.Serial) then
                if api.WaitForTarget(1500) and api.TargetSerial(corpse.Serial) then
                    -- One attempt per corpse, even if that monster has no hides.
                    skinnedCorpseSerials[corpse.Serial] = true
                    Messages.Print('Skinning corpse ' .. tostring(corpse.Serial), Colors.Action)
                    Pause(ACTION_DELAY)
                    return true
                end
            end
            nextSkinAttemptBySerial[corpse.Serial] = now + SKIN_RETRY_SECONDS
            return false
        end
    end
end
return false
end

-- ============================================================================
-- HIDES / CUT LEATHER: USE SCISSORS; KEEP ONLY VERITE AND VALORITE
-- Process at most ONE stack per idle pass to avoid fighting the targeting cursor
-- used by fishing, skinning, or carving fish. Combat remains highest priority.
-- ============================================================================
local hideActionRetryBySerial = {}
local lastScissorsWarningAt = 0

local function KeepLeatherHue(hue)
    for _, wanted in ipairs(KEEP_LEATHER_HUES) do
        if hue == wanted then return true end
    end
    return false
end

local function BackpackItemsOfType(graphic)
    if not Player.Backpack or not Player.Backpack.Serial then return {} end
    return Items.FindInContainer(Player.Backpack.Serial, graphic) or {}
end

local function DropOneUnwantedCutLeather()
    -- Do not discard Val/Verite, whether originally cut or freshly skinned.
    for _, snapshot in ipairs(BackpackItemsOfType(CUT_LEATHER_GRAPHIC)) do
        if snapshot.Serial and not KeepLeatherHue(snapshot.Hue) then
            local now = os.time()
            if now >= (hideActionRetryBySerial[snapshot.Serial] or 0) then
                local leather = Items.FindBySerial(snapshot.Serial)
                if leather and leather.Container == Player.Backpack.Serial
                and leather.Graphic == CUT_LEATHER_GRAPHIC and not KeepLeatherHue(leather.Hue) then
                local amount = leather.Amount or 1
                if Player.PickUp(leather.Serial, amount) then
                    Pause(ACTION_DELAY)
                    if Player.DropOnGround() then
                        Pause(ACTION_DELAY)
                        Messages.Print('Discarded ' .. tostring(amount) .. ' cut leather (hue ' .. string.format('0x%04X', leather.Hue or 0) .. ')', Colors.Warning)
                        return true
                    end
                    -- If the drop was refused, return the held stack safely.
                    Player.DropInBackpack()
                end
            end
            hideActionRetryBySerial[snapshot.Serial] = now + HIDE_ACTION_RETRY_SECONDS
        end
    end
end
return false
end

local function CutOneStackOfHides()
    local hides = BackpackItemsOfType(HIDE_GRAPHIC)
    if #hides == 0 then return false end
    local scissors = FindOwnedItem(SCISSORS_GRAPHIC)
    if not scissors then
        if os.time() >= lastScissorsWarningAt then
            Messages.Print('Hides in backpack: scissors (0x0F9F) required to cut them', Colors.Warning)
            lastScissorsWarningAt = os.time() + 15
        end
        return false -- Never drop uncut Verite or Valorite by accident.
    end

    local api = FishingTargetAPI()
    if not api or not api.WaitForTarget or not api.TargetSerial then return false end
    if api.IsTargeting and api.IsTargeting() then return false end

    for _, snapshot in ipairs(hides) do
        if snapshot.Serial and os.time() >= (hideActionRetryBySerial[snapshot.Serial] or 0) then
            local hide = Items.FindBySerial(snapshot.Serial)
            if hide and hide.Graphic == HIDE_GRAPHIC and hide.Container == Player.Backpack.Serial then
                local now = os.time()
                hideActionRetryBySerial[hide.Serial] = now + HIDE_ACTION_RETRY_SECONDS
                if Player.UseObject(scissors.Serial) and api.WaitForTarget(3000) then
                    if api.TargetSerial(hide.Serial) then
                        Pause(ACTION_DELAY)
                        Messages.Print('Cutting ' .. (hide.Name or 'hides'), Colors.Action)
                        return true
                    end
                end
                return false
            end
        end
    end
    return false
end

-- ============================================================================
-- SMART STACKING OF KEPT CUT LEATHER (LEAVE VAL/VERITE IN THE BACKPACK)
-- Uses only matching 0x1081 graphics AND exact same hue. Ground piles are
-- touched only when there is already a matching stack in the main backpack.
-- One item movement per idle loop keeps combat, targeting and boat navigation
-- responsive, and avoids cycling leather ground -> backpack -> ground.
-- ============================================================================
local failedLeatherGroundUntil = {}
local failedLeatherMergeUntil = {}
local leatherPredictedCarry = 0
local leatherPredictedCarryExpires = 0

local function GetKeptLeatherGroups()
    local groups = {}
    for _, item in ipairs(BackpackItemsOfType(CUT_LEATHER_GRAPHIC)) do
        if item.Serial and KeepLeatherHue(item.Hue) then
            local hue = item.Hue
            if not groups[hue] then
                groups[hue] = {hue = hue, count = 0, stacks = {}}
            end
            groups[hue].count = groups[hue].count + (item.Amount or 1)
            table.insert(groups[hue].stacks, item)
        end
    end
    return groups
end

local function LeatherSafeCarryLimit()
    -- Player.MaxWeight is the normal encumbrance threshold, not the requested
    -- 800-stone temporary pickup threshold. A 390-stone character may still
    -- attempt to lift a suitable stack when its projected weight stays <800.
    return LEATHER_MAX_CARRY_WEIGHT
end

local function EstimatedLeatherPileWeight(item)
    -- Sagas cut leather weighs 0.5 stone per piece. Do not round up: for
    -- example 799 + 0.5 remains strictly below 800, so that pickup is valid.
    local estimated = (item.Amount or 1) * LEATHER_WEIGHT_PER_PIECE
    if type(item.Properties) == 'string' then
        local textWeight = string.match(item.Properties, '[Ww]eight:%s*(%d+%.?%d*)%s*[Ss]tone')
        if textWeight then
            estimated = math.max(estimated, tonumber(textWeight) or 0)
        end
    end
    return estimated
end

local function PredictedLeatherWeight()
    if type(Player.Weight) ~= 'number' then return nil end
    if os.time() > leatherPredictedCarryExpires then
        leatherPredictedCarry = 0
    end
    return math.max(Player.Weight, leatherPredictedCarry)
end

local function MergeOneBackpackLeatherStack()
    local now = os.time()
    local groups = GetKeptLeatherGroups()
    for _, hue in ipairs(KEEP_LEATHER_HUES) do
        local group = groups[hue]
        if group and #group.stacks > 1 and now >= (failedLeatherMergeUntil[hue] or 0) then
            -- Prefer lifting the smaller of two already-carried piles.
            table.sort(group.stacks, function(a, b)
                return (a.Amount or 1) < (b.Amount or 1)
            end)
            local source = group.stacks[1]
            if not Player.PickUp(source.Serial, source.Amount or 1) then
                failedLeatherMergeUntil[hue] = now + LEATHER_FAILED_MERGE_RETRY_SECONDS
                return true
            end
            Pause(ACTION_DELAY)
            local placed = Player.DropInBackpack()
            Pause(ACTION_DELAY)
            if not placed then
                Player.DropInBackpack() -- Avoid leaving the lifted leather on cursor.
                failedLeatherMergeUntil[hue] = now + LEATHER_FAILED_MERGE_RETRY_SECONDS
                return true
            end
            local updated = GetKeptLeatherGroups()[hue]
            if not updated or updated.count ~= group.count or #updated.stacks >= #group.stacks then
                -- Sagas may refuse to merge, e.g. because of a stack-size limit.
                -- Do not repeatedly pick up the same pile when no merge occurs.
                failedLeatherMergeUntil[hue] = now + LEATHER_FAILED_MERGE_RETRY_SECONDS
            else
                failedLeatherMergeUntil[hue] = nil
                Messages.Print('Combined backpack cut leather (hue ' .. string.format('0x%04X', hue) .. ')', Colors.Confirm)
            end
            return true
        end
    end
    return false
end

local function CollectOneMatchingGroundLeatherStack()
    local limit = LeatherSafeCarryLimit()
    local carried = PredictedLeatherWeight()
    if not carried or carried >= limit then return false end
    if not Player.Backpack or not Player.Backpack.Serial then return false end

    local groups = GetKeptLeatherGroups()
    local nearby = Items.FindByFilter({graphics = {CUT_LEATHER_GRAPHIC}, onground = true, rangemax = LEATHER_GROUND_RANGE}) or {}
    if #nearby == 0 then return false end

    -- Prefer big piles when safe, but consider smaller piles when a big one
    -- would put the character at or above 800 stones.
    table.sort(nearby, function(a, b)
        return (a.Amount or 1) > (b.Amount or 1)
    end)

    local now = os.time()
    for _, hue in ipairs(KEEP_LEATHER_HUES) do
        local bag = groups[hue]
        local options = {}

        for _, snapshot in ipairs(nearby) do
            if snapshot.Serial and snapshot.Hue == hue
            and now >= (failedLeatherGroundUntil[snapshot.Serial] or 0) then
            local ground = Items.FindBySerial(snapshot.Serial)
            if ground and ground.Graphic == CUT_LEATHER_GRAPHIC
            and ground.Hue == hue
            and (ground.OnGround == true or ground.Container == 0)
            and (ground.Distance == nil or ground.Distance <= LEATHER_GROUND_RANGE) then
            local extraWeight = EstimatedLeatherPileWeight(ground)
            -- Strictly UNDER 800, not under Player.MaxWeight.
            if carried + extraWeight < limit then
                table.insert(options, {item = ground, weight = extraWeight})
            end
        end
    end
end

local selected = nil
if bag and bag.count > 0 then
    -- A matching backpack pile is already available to combine with.
    -- Don't require exactly one backpack pile: two are also valid.
    selected = options[1]
else
    -- If backpack has no leather of this hue, only lift a ground pile
    -- when a SECOND matching pile ALSO fits. This avoids picking up
    -- unrelated lone ground piles merely to put them in our bag.
    for i = 1, #options do
        for j = i + 1, #options do
            if carried + options[i].weight + options[j].weight < limit then
                selected = options[i]
                break
            end
        end
        if selected then break end
    end
end

if selected then
    local ground = selected.item
    local amount = ground.Amount or 1
    local beforeCount = bag and bag.count or 0
    local predictedAfter = carried + selected.weight

    if not Player.PickUp(ground.Serial, amount) then
        failedLeatherGroundUntil[ground.Serial] = now + LEATHER_FAILED_PICKUP_RETRY_SECONDS
        Messages.Print('Ground leather pickup refused; retrying later', Colors.Warning)
        return true
    end
    Pause(ACTION_DELAY)
    local placed = Player.DropInBackpack()
    Pause(ACTION_DELAY)

    -- Check actual backpack quantities. A successful drop request
    -- does NOT prove the server has finished processing it.
    local updated = GetKeptLeatherGroups()[hue]
    local newCount = updated and updated.count or 0
    for verify = 1, 4 do
        if newCount >= beforeCount + amount then break end
        Pause(200)
        updated = GetKeptLeatherGroups()[hue]
        newCount = updated and updated.count or 0
    end
    if newCount < beforeCount + amount then
        -- A submitted drop can still be refused by the server. If the
        -- leather remains held, retry into our backpack one more time.
        -- NEVER dump valuable Verite/Valorite leather on the ground.
        Player.DropInBackpack()
        Pause(ACTION_DELAY)
        updated = GetKeptLeatherGroups()[hue]
        newCount = updated and updated.count or 0
    end

    if newCount >= beforeCount + amount then
        leatherPredictedCarry = predictedAfter
        leatherPredictedCarryExpires = os.time() + 8
        failedLeatherGroundUntil[ground.Serial] = nil
        Messages.Print('Leather +' .. tostring(amount) .. ' (hue ' .. string.format('0x%04X', hue) .. ') to backpack; estimated ' .. tostring(predictedAfter) .. '/800 stones', Colors.Confirm)
    else
        failedLeatherGroundUntil[ground.Serial] = now + LEATHER_FAILED_PICKUP_RETRY_SECONDS
        Messages.Print('Leather transfer not confirmed; will retry later (no ground drop)', Colors.Warning)
    end
    return true
end
end
return false
end

local function ProcessLeatherInventory()
    -- Unwanted cut leather is discarded first to release backpack weight.
    -- Uncut hides of ALL hues are then cut; only wanted hues survive cleanup.
    if DropOneUnwantedCutLeather() then return true end
    if CutOneStackOfHides() then return true end
    if MergeOneBackpackLeatherStack() then return true end
    if CollectOneMatchingGroundLeatherStack() then return true end
    return false
end

-- Carve one unprotected ordinary fish per idle pass. If there is no knife
-- or the target fails, do NOT drop the uncarved fish: retry next pass.
local nextKnifeWarningAt = 0
local function CarveOneOrdinaryFish()
    if not Player.Backpack or not Player.Backpack.Serial then return false end
    local contents = Items.FindInContainer(Player.Backpack.Serial) or {}
    local fish = nil
    for _, item in ipairs(contents) do
        if ordinaryFishGraphics[item.Graphic] and not IsKeptFish(item) then
            fish = item
            break
        end
    end
    if not fish then return false end

    local knife = FindOwnedFishKnife()
    if not knife then
        if os.time() >= nextKnifeWarningAt then
            Messages.Print("Ordinary fish in backpack, but no knife found; keeping uncut fish", Colors.Warning)
            nextKnifeWarningAt = os.time() + 15
        end
        return false
    end

    local api = FishingTargetAPI()
    if not api or not api.TargetSerial then return false end
    if not Player.UseObject(knife.Serial) then return false end
    if not api.WaitForTarget(3000) then return false end
    if not api.TargetSerial(fish.Serial) then return false end
    Pause(ACTION_DELAY)
    return true
end

-- Other junk goes on the ground. Raw fish steaks are managed separately
-- in ConsolidateFishSteaks(), so they are NOT dropped one at a time.
-- Fish in KEEP_FISH are protected. Never drop uncarved ordinary fish.
local function DropJunk()
    if not DROP_JUNK_ITEMS or not Player.Backpack then return end
    local contents = Items.FindInContainer(Player.Backpack.Serial) or {}
    for _, item in ipairs(contents) do
        if junkGraphics[item.Graphic] and item.Serial then
            if item.Graphic ~= RAW_FISH_STEAK_GRAPHIC and not ordinaryFishGraphics[item.Graphic] and not IsKeptFish(item) then
                if NOISY_MODE then
                    Player.Say("- " .. (item.Name or "junk") .. " -", Colors.Warning)
                else
                    Messages.OverheadMobile(Player.Serial, "- " .. (item.Name or "junk") .. " -", Colors.Warning)
                end
                if Player.PickUp(item.Serial, item.Amount or 1) then
                    Pause(ACTION_DELAY)
                    if not Player.DropOnGround() then Player.DropInBackpack() end
                    Pause(ACTION_DELAY)
                end
            end
        end
    end
end

-- ============================================================================
-- RAW FISH STEAKS: SAVE A 20-PIECE BUFFER; COMBINE ON THE BACKPACK; DROP ONCE
-- ============================================================================

local failedSteakPickupUntil = {}

local function GetBagSteakGroups()
    local groups = {}
    if not Player.Backpack or not Player.Backpack.Serial then return groups end

    local contents = Items.FindInContainer(Player.Backpack.Serial, RAW_FISH_STEAK_GRAPHIC) or {}
    for _, item in ipairs(contents) do
        if item.Serial and not IsKeptFish(item) then
            local hue = item.Hue or 0
            if not groups[hue] then groups[hue] = {hue = hue, count = 0, stacks = {}} end
            local group = groups[hue]
            group.count = group.count + (item.Amount or 1)
            table.insert(group.stacks, item)
        end
    end
    return groups
end

local function CountBagSteaksByHue(hue)
    local group = GetBagSteakGroups()[hue]
    return group and group.count or 0
end

local function GetSafeCarryLimit()
    local limit = STEAK_MAX_CARRY_WEIGHT
    if Player.MaxWeight and Player.MaxWeight < limit then limit = Player.MaxWeight end
    return limit - STEAK_PICKUP_SAFETY
end

-- Read an item's total displayed Weight, when present. The official item API
-- doesn't supply a weight field, so the per-piece estimate is the fallback.
local function EstimatedGroundStackWeight(item)
    if item.Properties then
        local number = string.match(item.Properties, '[Ww]eight:%s*(%d+%.?%d*)%s*[Ss]tone')
        if number and tonumber(number) then return tonumber(number) end
    end
    return math.max(1, math.ceil((item.Amount or 1) * STEAK_WEIGHT_PER_PIECE))
end

local function GetNearbyGroundSteaks(hue)
    local result = {}
    local items = Items.FindByFilter({graphics = {RAW_FISH_STEAK_GRAPHIC}, onground = true, rangemax = STEAK_GROUND_RANGE}) or {}
    for _, item in ipairs(items) do
        if item.Serial and (item.Hue or 0) == hue and (item.Amount or 0) > 0 then
            table.insert(result, item)
        end
    end
    -- Largest eligible pile first = fewer lifts and fewer ground piles.
    table.sort(result, function(a, b)
        if a.Amount == b.Amount then return (a.Distance or 0) < (b.Distance or 0) end
        return a.Amount > b.Amount
    end)
    return result
end

-- If the game didn't auto-join stacks when they entered the backpack,
-- try one whole-stack lift and backpack drop. Stop on no progress.
local function MergeBackpackSteakStacks(hue)
    for attempt = 1, 8 do
        local group = GetBagSteakGroups()[hue]
        if not group or #group.stacks <= 1 then return true end
        local countBefore = #group.stacks
        table.sort(group.stacks, function(a, b) return (a.Amount or 1) < (b.Amount or 1) end)
            local source = group.stacks[1]
            if not Player.PickUp(source.Serial, source.Amount or 1) then return false end
            Pause(ACTION_DELAY)
            local submitted = Player.DropInBackpack()
            Pause(ACTION_DELAY)
            if not submitted then
                Player.DropInBackpack()
                Pause(ACTION_DELAY)
                return false
            end
            local updated = GetBagSteakGroups()[hue]
            if not updated or #updated.stacks >= countBefore then return false end
        end
        local final = GetBagSteakGroups()[hue]
        return not final or #final.stacks <= 1
    end

    -- Drop each final backpack stack once. When the client successfully merged
    -- in the backpack, this is exactly ONE stack and ONE ground drop.
    local function DropBackpackSteaks(hue)
        if not MergeBackpackSteakStacks(hue) then
            Messages.Print('Fish steaks did not merge in backpack; dropping available stacks', Colors.Warning)
        end
        local group = GetBagSteakGroups()[hue]
        if not group then return end
        for _, snapshot in ipairs(group.stacks) do
            local current = Items.FindBySerial(snapshot.Serial)
            if current and current.Container == Player.Backpack.Serial and current.Graphic == RAW_FISH_STEAK_GRAPHIC then
                if (current.Hue or 0) == hue and not IsKeptFish(current) then
                    if Player.PickUp(current.Serial, current.Amount or 1) then
                        Pause(ACTION_DELAY)
                        if Player.DropOnGround() then
                            Pause(ACTION_DELAY)
                        else
                            Player.DropInBackpack()
                            Pause(ACTION_DELAY)
                            return
                        end
                    end
                end
            end
        end
    end

    -- Called after carving, before leaving a depleted node, and on exit.
    -- force=true flushes a remaining buffer even below 20 steaks.
    local function ConsolidateFishSteaks(force)
        if not DROP_JUNK_ITEMS or not Player.Backpack then return end

        local groups = GetBagSteakGroups()
        for hue, group in pairs(groups) do
            local almostFull = Player.Weight and (Player.Weight >= GetSafeCarryLimit() - 2)
            if force or group.count >= STEAK_BUFFER_AMOUNT or almostFull then
                local piles = GetNearbyGroundSteaks(hue)
                local estimatedCarry = Player.Weight
                for _, snapshot in ipairs(piles) do
                    local now = os.time()
                    if (failedSteakPickupUntil[snapshot.Serial] or 0) <= now then
                        -- Re-fetch to avoid acting on a ground pile that just moved.
                        local ground = Items.FindBySerial(snapshot.Serial)
                        if ground and ground.OnGround and ground.Graphic == RAW_FISH_STEAK_GRAPHIC then
                            if (ground.Hue or 0) == hue and Player.Weight and Player.MaxWeight then
                                estimatedCarry = math.max(estimatedCarry or 0, Player.Weight)
                                local extraWeight = EstimatedGroundStackWeight(ground)
                                if estimatedCarry + extraWeight < GetSafeCarryLimit() then
                                    local before = GetBagSteakGroups()[hue]
                                    local beforeCount = before and before.count or 0
                                    local beforeStacks = before and #before.stacks or 0
                                    if Player.PickUp(ground.Serial, ground.Amount or 1) then
                                        Pause(ACTION_DELAY)
                                        local submitted = Player.DropInBackpack()
                                        Pause(ACTION_DELAY)
                                        local after = GetBagSteakGroups()[hue]
                                        local afterCount = after and after.count or 0
                                        if submitted and afterCount >= beforeCount + (ground.Amount or 1) then
                                            -- Account for client weight-reporting lag on later pickups.
                                            estimatedCarry = estimatedCarry + extraWeight
                                            if after and #after.stacks > beforeStacks then
                                                -- Join failure: don't pull even more piles this pass.
                                                break
                                            end
                                        else
                                            -- If a drop was refused and still held, release it.
                                            Player.DropOnGround()
                                            Pause(ACTION_DELAY)
                                            failedSteakPickupUntil[ground.Serial] = now + STEAK_FAILED_PICKUP_RETRY
                                            Messages.Print('Ground fish-steak transfer not confirmed', Colors.Warning)
                                            break
                                        end
                                    else
                                        failedSteakPickupUntil[ground.Serial] = now + STEAK_FAILED_PICKUP_RETRY
                                    end
                                end
                                -- Skip overweight piles entirely; never lift a partial stack.
                            end
                        end
                    end
                end
                -- First batch: drop 20 at feet. Later batches: pull a safe nearby
                -- pile into backpack, combine, and drop the larger pile only once.
                DropBackpackSteaks(hue)
            end
        end
    end

    -- Never terminate due to a generic journal error. Some messages such as
    -- "That is too far away" can come from ground-steak pickups, not fishing.
    -- Treat these as transient only when we actually submitted a fishing cast.
    local function FishingRetryReason()
        if Journal.Contains("Your game window does not have focus") then
            return "game window not focused"
        end
        if Journal.Contains("The fishing pole must be equipped") then
            return "fishing pole not ready"
        end
        if Journal.Contains("You must wait to perform another action") then
            return "action cooldown"
        end
        if Journal.Contains("Target cannot be seen") then
            return "target not visible"
        end
        if Journal.Contains("That is too far away") then
            return "target too far away"
        end
        if Journal.Contains("You need to be closer to the water") then
            return "water out of range"
        end
        if Journal.Contains("There is nothing you can harvest nearby") then
            return "no fishable water within 2 tiles"
        end
        if Journal.Contains("You can't fish") then
            return "unable to fish now"
        end
        return nil
    end

    Messages.Print("___________________________________", Colors.Info)
    Messages.Print("Fishing + Archer Online (v" .. VERSION .. ")", Colors.Info)
    Messages.Print("Self-target fishing; defending within 5 tiles", Colors.Info)
    Messages.Print("Node depleted = 5 x forward one (750ms)", Colors.Info)
    Messages.Print("Obstacle: left/right; then back 5 + left/right", Colors.Info)
    Messages.Print("Boat watchdog: auto-retry stuck moves; resume fishing", Colors.Info)
    Messages.Print("Skinning: corpses within 2 tiles (skin knife required)", Colors.Info)
    Messages.Print("Leather: scissors cut hides; keep Verite and Valorite only", Colors.Info)
    Messages.Print("Smart leather stacking: < 800 stones (ignores normal MaxWeight)", Colors.Info)
    Messages.Print("Raw fish steaks: 20-piece buffer, safe ground merges", Colors.Info)
    Messages.Print("___________________________________", Colors.Info)

    local nextFishingAt = 0
    local lastEnemySerial = nil
    local nextAttackAt = 0
    local lastWarningAt = 0
    local lastFishingWarningAt = 0
    local wasFighting = false
    local boatStepsRemaining = 0
    local boatMode = "forward"
    local boatSideStepsRemaining = 0
    local boatBackStepsRemaining = 0
    local boatPending = nil
    local boatRetryAt = 0
    local boatUnconfirmedAttempts = 0
    local boatStuckX = nil
    local boatStuckY = nil
    local boatStuckRetryAt = 0
    local boatAutomaticRecoveryAttempts = 0
    local nextBoatNavigationAllowedAt = 0
    local nextBoatAckMessageAt = 0
    local awaitingFishingOutcome = false

    local function FishingWarning(message)
        local now = os.time()
        if now >= lastFishingWarningAt then
            Messages.Print(message, Colors.Warning)
            lastFishingWarningAt = now + 10
        end
    end

    -- Check the tiller response to a particular move, not old journal lines.
    local function BoatStoppedMessage()
        return Journal.Contains("we've stopped") or Journal.Contains("we have stopped")
    end

    -- Some boat moves receive a tiller acknowledgement without an immediate
    -- Player.X/Y refresh. An acknowledgement is weaker than a coordinate update:
    -- ONLY accept it after the blocked-message timeout and if no stop was reported.
    local function BoatAcknowledgedMessage()
        return Journal.Contains("aye aye") or Journal.Contains("are aye")
    end

    local function BoatPositionChanged(x, y)
        return Player.X ~= nil and Player.Y ~= nil and x ~= nil and y ~= nil
        and (Player.X ~= x or Player.Y ~= y)
    end

    local function FinishForwardBoatStep()
        boatStepsRemaining = boatStepsRemaining - 1
        boatAutomaticRecoveryAttempts = 0
        boatMode = "forward"
        boatSideStepsRemaining = 0
        boatBackStepsRemaining = 0
        if boatStepsRemaining <= 0 then
            boatStepsRemaining = 0
            nextFishingAt = os.time() + POST_COMBAT_RECOVERY_SECONDS
            Messages.Print("Boat advanced; resuming fishing", Colors.Confirm)
        end
    end

    -- Unlike the older "stuck" mode, this automatically retries after a pause.
    -- After a bounded number of recoveries it returns to fishing rather than
    -- spinning forever at the 100ms loop while waiting for a manual step.
    local function EnterBoatStuck(message)
        boatMode = "stuck"
        boatStuckX = Player.X
        boatStuckY = Player.Y
        boatPending = nil
        boatStuckRetryAt = os.time() + BOAT_STUCK_AUTO_RETRY_SECONDS
        Messages.Print(message .. "; automatic retry scheduled", Colors.Warning)
    end

    -- A blockage is only recognized if the tiller reports a stop and X/Y
    -- is unchanged since that particular command. Navigation is bounded:
    -- left 5 -> forward -> right 5 -> forward -> back 5 -> left/right probes.
    local function HandleBoatResult(phase, result)
        if result == "failed" then
            boatUnconfirmedAttempts = boatUnconfirmedAttempts + 1
            if boatUnconfirmedAttempts >= BOAT_MAX_UNCONFIRMED_COMMANDS then
                EnterBoatStuck("Boat speech failed repeatedly")
            else
                boatRetryAt = os.time() + BOAT_UNKNOWN_RETRY_SECONDS
                FishingWarning("Boat speech command failed; will retry")
            end
            return
        end
        boatUnconfirmedAttempts = 0
        if phase == "forward" then
            if result == "blocked" then
                boatMode = "left"
                boatSideStepsRemaining = BOAT_OBSTACLE_SIDE_STEPS
                Messages.Print("Boat blocked: trying left " .. tostring(BOAT_OBSTACLE_SIDE_STEPS), Colors.Warning)
            else
                FinishForwardBoatStep()
            end
        elseif phase == "left" or phase == "right" or phase == "back_left" or phase == "back_right" then
            -- As in v1.5, count each sideways attempt, even if it was blocked.
            -- The next forward probe determines whether the detour worked.
            boatSideStepsRemaining = boatSideStepsRemaining - 1
            if boatSideStepsRemaining <= 0 then
                if phase == "left" then
                    boatMode = "probe_left"
                elseif phase == "right" then
                    boatMode = "probe_right"
                elseif phase == "back_left" then
                    boatMode = "probe_back_left"
                else
                    boatMode = "probe_back_right"
                end
                Messages.Print("Side maneuver complete; trying forward", Colors.Info)
            end
        elseif phase == "probe_left" then
            if result == "blocked" then
                boatMode = "right"
                boatSideStepsRemaining = BOAT_OBSTACLE_SIDE_STEPS
                Messages.Print("Still blocked: trying right " .. tostring(BOAT_OBSTACLE_SIDE_STEPS), Colors.Warning)
            else
                FinishForwardBoatStep()
            end
        elseif phase == "probe_right" then
            if result == "blocked" then
                -- Both original lateral paths failed. Back up to get around
                -- the obstacle, then try a second, bounded left/right detour.
                boatMode = "back"
                boatBackStepsRemaining = BOAT_OBSTACLE_BACK_STEPS
                Messages.Print("Both detours blocked: backing up " .. tostring(BOAT_OBSTACLE_BACK_STEPS), Colors.Warning)
            else
                FinishForwardBoatStep()
            end
        elseif phase == "back" then
            if result == "blocked" then
                -- Do not spam the tiller indefinitely against a rear obstacle.
                EnterBoatStuck("Cannot back up past obstacle")
            else
                boatBackStepsRemaining = boatBackStepsRemaining - 1
                if boatBackStepsRemaining <= 0 then
                    boatMode = "back_left"
                    boatSideStepsRemaining = BOAT_OBSTACLE_SIDE_STEPS
                    Messages.Print("Backed up; trying left " .. tostring(BOAT_OBSTACLE_SIDE_STEPS), Colors.Info)
                end
            end
        elseif phase == "probe_back_left" then
            if result == "blocked" then
                boatMode = "back_right"
                boatSideStepsRemaining = BOAT_OBSTACLE_SIDE_STEPS
                Messages.Print("Still blocked after retreat: trying right", Colors.Warning)
            else
                FinishForwardBoatStep()
            end
        elseif phase == "probe_back_right" then
            if result == "blocked" then
                EnterBoatStuck("No route after backing and side detours")
            else
                FinishForwardBoatStep()
            end
        end
    end

    -- One boat command only. Capture X/Y BEFORE each move; clear old messages;
    -- give the server 750ms (and a short latency allowance) to respond.
    local function TryBoatCommand(command)
        local startX = Player.X
        local startY = Player.Y
        Journal.Clear()
        if not Player.Say(command) then return "failed", startX, startY end
        Pause(BOAT_STEP_DELAY_MS)
        if BoatPositionChanged(startX, startY) then return "moved", startX, startY end
        if BoatStoppedMessage() then return "blocked", startX, startY end
        Pause(300)
        if BoatPositionChanged(startX, startY) then return "moved", startX, startY end
        if BoatStoppedMessage() then return "blocked", startX, startY end
        return "pending", startX, startY
    end

    local function RunBoatNavigation()
        if boatMode == "stuck" then
            if BoatPositionChanged(boatStuckX, boatStuckY) then
                boatMode = "forward"
                boatUnconfirmedAttempts = 0
                boatBackStepsRemaining = 0
                boatSideStepsRemaining = 0
                boatAutomaticRecoveryAttempts = 0
                boatRetryAt = 0
                Messages.Print("Position changed; retrying remaining boat steps", Colors.Info)
            elseif os.time() >= boatStuckRetryAt then
                if boatAutomaticRecoveryAttempts >= BOAT_MAX_STUCK_AUTO_RETRIES then
                    -- No manual input required: release the fishing loop. If the
                    -- spot is still depleted, navigation can retry after cooldown.
                    boatStepsRemaining = 0
                    boatMode = "forward"
                    boatPending = nil
                    boatAutomaticRecoveryAttempts = 0
                    nextBoatNavigationAllowedAt = os.time() + BOAT_ABORT_COOLDOWN_SECONDS
                    nextFishingAt = os.time() + FISHING_RETRY_SECONDS
                    Messages.Print("Boat still unresponsive; resuming fishing and cooling down boat commands", Colors.Warning)
                else
                    boatAutomaticRecoveryAttempts = boatAutomaticRecoveryAttempts + 1
                    boatMode = "forward"
                    boatUnconfirmedAttempts = 0
                    boatBackStepsRemaining = 0
                    boatSideStepsRemaining = 0
                    boatRetryAt = 0
                    Messages.Print("Automatic boat recovery attempt " .. tostring(boatAutomaticRecoveryAttempts), Colors.Info)
                end
            end
            return
        end

        -- Honor delayed boat responses. Prefer a server stop to an acknowledgement.
        -- Acknowledgement-only success is the fallback if the client isn't updating
        -- Player.X/Y while the boat moves (the symptom seen in v1.7/v1.8).
        if boatPending then
            if BoatPositionChanged(boatPending.x, boatPending.y) then
                local phase = boatPending.phase
                boatPending = nil
                HandleBoatResult(phase, "moved")
            elseif BoatStoppedMessage() then
                local phase = boatPending.phase
                boatPending = nil
                HandleBoatResult(phase, "blocked")
            elseif os.time() >= boatPending.expiry then
                local phase = boatPending.phase
                boatPending = nil
                if BoatAcknowledgedMessage() then
                    if os.time() >= nextBoatAckMessageAt then
                        Messages.Print("Tiller acknowledged boat command; X/Y update delayed", Colors.Info)
                        nextBoatAckMessageAt = os.time() + 30
                    end
                    HandleBoatResult(phase, "acknowledged")
                else
                    boatUnconfirmedAttempts = boatUnconfirmedAttempts + 1
                    if boatUnconfirmedAttempts >= BOAT_MAX_UNCONFIRMED_COMMANDS then
                        EnterBoatStuck("Boat move not confirmed by tiller or X/Y")
                    else
                        boatRetryAt = os.time() + BOAT_UNKNOWN_RETRY_SECONDS
                        FishingWarning("Boat move not confirmed; retrying")
                    end
                end
            end
            return
        end

        if os.time() < boatRetryAt then return end

        local phase = boatMode
        local command = "forward one"
        if phase == "left" or phase == "back_left" then command = "left one" end
        if phase == "right" or phase == "back_right" then command = "right one" end
        if phase == "back" then command = "back one" end

        local result, startX, startY = TryBoatCommand(command)
        if result == "pending" then
            boatPending = {phase = phase, x = startX, y = startY, expiry = os.time() + BOAT_MOVE_CONFIRM_SECONDS}
        else
            HandleBoatResult(phase, result)
        end
    end

    Journal.Clear()

    while not Player.IsDead do
        if boatStepsRemaining > 0 then
            Pause(100)
        else
            Pause(ACTION_DELAY)
        end

        -- Combat always takes priority, even while moving the boat.
        local enemy = FindNearbyHostile()
        if enemy then
            if not wasFighting then
                -- Discard any in-flight fishing cursor when a monster appears.
                local api = FishingTargetAPI()
                if api and api.IsTargeting and api.CancelTarget then
                    if api.IsTargeting() then api.CancelTarget() end
                end
                awaitingFishingOutcome = false
            end
            wasFighting = true
            if EnsureBow() then
                local now = os.time()
                if enemy.Serial ~= lastEnemySerial or now >= nextAttackAt then
                    if Player.Attack(enemy.Serial) then
                        Messages.Print("Attacking " .. (enemy.Name or "creature"), Colors.Action)
                    end
                    lastEnemySerial = enemy.Serial
                    nextAttackAt = now + ATTACK_RETRY_SECONDS
                end
            elseif os.time() >= lastWarningAt + 10 then
                Messages.Print("Hostile nearby, but no bow found in inventory", Colors.Warning)
                lastWarningAt = os.time()
            end
        else
            if wasFighting then
                wasFighting = false
                lastEnemySerial = nil
                nextAttackAt = 0
                awaitingFishingOutcome = false
                -- Re-equip the fishing pole and allow the combat action to settle.
                -- If this fails, the normal idle loop keeps trying rather than exits.
                if EnsureFishingPole() then
                    Messages.Print("Combat over; fishing pole re-equipped", Colors.Confirm)
                else
                    FishingWarning("Combat over; waiting to equip fishing pole")
                end
                nextFishingAt = os.time() + POST_COMBAT_RECOVERY_SECONDS
            end

            -- Navigation must run before leather processing. The old ordering
            -- could starve a pending boat move if item processing kept succeeding.
            -- Combat always remains the highest priority.
            local processedLeather = false
            local skinnedCorpse = false
            if boatStepsRemaining <= 0 then
                processedLeather = ProcessLeatherInventory()
                if not processedLeather then skinnedCorpse = TrySkinNearbyCorpse() end
            end

            if boatStepsRemaining > 0 then
                RunBoatNavigation()
            elseif processedLeather or skinnedCorpse then
                -- Let the scissors/skinning action settle before fishing again.
                nextFishingAt = math.max(nextFishingAt, os.time() + 2)
            elseif Journal.Contains("The fish don't seem to be biting") then
                -- Process catches at this location before the boat leaves.
                CarveOneOrdinaryFish()
                ConsolidateFishSteaks(true)
                DropJunk()
                Journal.Clear() -- Consume this depletion event exactly once.
                awaitingFishingOutcome = false
                if KEEP_FISHING_AFTER_NODE_IS_EMPTY then
                    if os.time() < nextBoatNavigationAllowedAt then
                        nextFishingAt = nextBoatNavigationAllowedAt
                        Messages.Print("Boat recovery cooling down; fishing retry scheduled", Colors.Warning)
                    else
                        boatStepsRemaining = BOAT_FORWARD_STEPS
                        boatMode = "forward"
                        boatSideStepsRemaining = 0
                        boatBackStepsRemaining = 0
                        boatPending = nil
                        boatRetryAt = 0
                        boatUnconfirmedAttempts = 0
                        boatAutomaticRecoveryAttempts = 0
                        Messages.Print("Fishing node depleted; advancing " .. tostring(BOAT_FORWARD_STEPS) .. " tiles", Colors.Info)
                    end
                else
                    Messages.Print("Fishing node depleted; stopping", Colors.Caution)
                    break
                end
            else
                -- A failure after a cast is temporary. Never treat random pickup
                -- errors as a reason to terminate fishing permanently.
                local retryReason = nil
                if awaitingFishingOutcome then
                    retryReason = FishingRetryReason()
                end
                if retryReason then
                    awaitingFishingOutcome = false
                    Journal.Clear()
                    nextFishingAt = os.time() + FISHING_RETRY_SECONDS
                    FishingWarning("Fishing retry: " .. retryReason)
                end

                -- Continue fish carving and safe steak stacking between casts.
                CarveOneOrdinaryFish()
                ConsolidateFishSteaks(false)
                DropJunk()

                if os.time() >= nextFishingAt then
                    local pole = EnsureFishingPole()
                    if not pole then
                        awaitingFishingOutcome = false
                        FishingWarning("Fishing pole not equipped; retrying")
                        nextFishingAt = os.time() + FISHING_RETRY_SECONDS
                    else
                        Journal.Clear()
                        local cast = CastFishingPoleOnSelf(pole)
                        awaitingFishingOutcome = cast == true
                        if cast then
                            nextFishingAt = os.time() + FISHING_CAST_INTERVAL_SECONDS
                        else
                            FishingWarning("Self-target fishing failed; retrying")
                            nextFishingAt = os.time() + FISHING_RETRY_SECONDS
                        end
                    end
                end
            end
        end
    end

    -- Cleanup if the script ends (death or depleted-node stop).
    if not Player.IsDead then
        ProcessLeatherInventory()
        CarveOneOrdinaryFish()
        ConsolidateFishSteaks(true)
        DropJunk()
    end
    Messages.Print("Done.", Colors.Info)
