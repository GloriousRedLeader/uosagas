------------------------------------------------------------------------------------
-- START OPTIONS for AUTO DEXER / ARCHER / HEALER / AUTOLOOTER / POUCHPOPPER / POISON
-- by OMG Arturo
------------------------------------------------------------------------------------

-- Don't screw aroudn with this.
local VERSION = "1.4"

-- Milliseconds of delay between actions
local ACTION_DELAY = 750

-- Use /say when dropping or keeping a resource.
-- Otherwise it will print privately over your head.
local NOISY_MODE = true

-- Auto-pickup mushrooms when you are out of combat (no current enemy selected)
-- You also need to be above 80 health, not poisoned, etc. This is true for a lot of
-- these non-essential functions so heals and such can be prioritized.
local PICKUP_MUSHROOMS = false

-- Will auto attack monsters so you dont have to. Warning: Will
-- attack grays and reds  if you configure it!
local AUTO_ATTACK = true

-- Tiles to look for bad guys
local ATTACK_RANGE = 5

-- When AUTO_ATTACK = true, this will attack red players and MOBS!
local AUTO_ATTACK_REDS = true

-- When AUTO_ATTACK = true and your alchemy skill is >= 100, will auto
-- throw explode pots at targets every 5 seconds.
--local EXPLODE_POTS = true

-- IF this is true and you have over 90 alchemy, will throw pots
local USE_INFLAMMABLE_POTS = false

-- When AUTO_ATTACK = true, this will NOT attack demons because mages.
local SKIP_DEMONS = true

-- Auto apply poison to blade to WEAPON_GRAPHIC.
local USE_POISONS = false

-- Only apply poison to your weapon if you have a current target and
-- the current target does not have poison on it already. This option conserves poisons.
local SMART_POISONING = false

-- Required when POISONS = true. Only poison THIS weapon graphic because
-- poisoners dont always want to poison EVERY weapon. For example switch
-- to a war fork on mobs that are immune.
--local WEAPON_GRAPHIC = 0x1405 -- Fork
--local WEAPON_GRAPHIC = 0x1401 -- Kryss
--local WEAPON_GRAPHIC = 0x0F52 -- dagger
local WEAPON_GRAPHIC = 0 -- ANY weapon

-- Auto bandage yourself or allies
-- Cooldown 10 seconds
local USE_BANDAGES = false

-- Will use bandages on friends defined in FRIEND_SERIALS below
local BANDAGES_ON_FRIENDS = false

-- A decimal representing percentage of a friend's health bar. Bandage healing will
-- only kick in if they are below this threshold, e.g. 0.9  (less than 90%)
local BANDAGE_FRIENDS_MIN_THRESHOLD_HP = 0.9

-- Heal damaged friend by their serial if they are close.
-- Only applicable when BANDAGES = true
local FRIEND_SERIALS = {
    0x006C6854, -- omg artie
    0x0046C66E, -- mr slave
    0x0012705D, -- omg arthur
    0x003A3990, -- omg arturo
    0x0012DDAB,  -- mr karl
    0x0013C547, -- Blood Draw
    0x00110988, -- fastball
    0x001DB49D, -- bash
    0x003EC94F, -- Bruenor te dwarf
    0x003B4020, -- jingle jangle
    0x0069B641, -- dead on arrival
    0x006AE324, -- puk ice
    0x0040CC3E, -- lady lumps
    0x00466D56, -- pink floyd
    0x003D131B, -- xufu
    0x00391EC1, -- chaz
    0x00358EEE, -- brian damage
    0x0044459B, -- Thuutumi
    0x003306A5, -- Dardes Jum Zir
}

-- Auto pop pouches
local USE_POUCHES = false

-- Primitive auto looter. Does not scavenge.
local AUTOLOOT = true

-- IF this is true and you ahve more than 20 peacemaking
local USE_PEACE = false

-- IF this is true and you have more than 20 discordance
local USE_DISCORD = false

-- If music is > 80, will cast this every X seconds
local USE_SONG_OF_HEALING = false

-- Recast song of healing every X ms
local SONG_OF_HEALING_RECAST = 188 * 1000

-- If music is > 80, will attempt to cast song of fortune
local USE_SONG_OF_FORTUNE = false

-- Number of ms to recast song of fortune. I think it's OK
-- to cast it often. Even if the buff lasts for 12 minutes, it is
-- OK to recast every minute just in case the cast fails you don't want to miss out
local SONG_OF_FORTUNE_RECAST = 725 * 1000

-- If music > 80, will attempt to cast song of light
local USE_SONG_OF_LIGHT = false

-- Number of ms to recast song of light.
local SONG_OF_LIGHT_RECAST = 725 * 1000

-- When script starts it finds your currently equipped weapon.
-- It will then check every few seconds to re-equip it if its not
-- currently equipped.
local REEQUIP_WEAPON = true

-- Use orange potion when poisoned. Drinking logic:
-- 1. If 80 alchemy, just drinks
-- 2. Else it unequips left hand (then re-equips)
local USE_CURE_POTS = false

-- Auto looter, add graphic ids here. Only applies when AUTOLOOT = true
local graphicIdLootableItemPriorityList =
{
    -- (highest priority)
    0xFDAD,  -- Eren Coin
    0x0F91,  -- Fragment
    0x2BF7,  -- Mystic Crafting Material
    0x41E7,  -- Weapon Rack
    0x41E6,  -- Weapon Rack
    0x9EE7,  -- Hanging Plate Chest
    0x9EE8,  -- Hanging Plate Chest
    0x241E,  -- Blue Urn
    0x21FC,  -- Pile Of Skulls
    0x20D9,  -- Gargoyle Statuette
    0x5726,  -- Fey Wings
    0x2109,  -- Ghoul Statuette
    0x20D3,  -- Daemon Statuette
    0x20F4,  -- Gazer Statuette
    0x212F,  -- Giant Toad Statuette
    0x212C,  -- Duskfen Matriarch Statuette
    0x20ED,  -- Air Elemental Statuette
    0x20F3,  -- Fire Elemental Statuette
    0x2D8A,  -- Changeling Statuette
    0xFD8C,  -- Soul
    0xFD8F,  -- Mastery Gem
    0x0E73,  -- Skill Cap Ball
    0xFF3A,  -- Skill Scroll
    --0x9FF8,  -- Paragon Chest
    --0x9FF9,  -- Paragon Chest
    --0x2D9D,  -- Grimoire
    --0x0EED,  -- Gold
    --0x14EC,  -- Treasure Map
    0x14F0,  -- Halloween ticket
    0x573B,  -- Pigments
    0x099F,  -- Message in a Bottle
    --0x0EB2,  -- Lap Harp
    --0x0EB1,  -- Standing Harp
    --0x0EB3,  -- Lute
    --0x0E9D,  -- Tambourine
    --0x0E9E,  -- Tambourine
    --0x0E9C,  -- Drum
    0x0F26,  -- Diamond
    0x0F10,  -- Emerald
    --0x0F16,  -- Amethyst
    --0x0F10,  -- Emerald
    --0x0F19,  -- Saphire
    --0x0F25,  -- Amber
    --0x0F13,  -- Ruby
    --0x0000,  -- Daemon Scales
    --0x26B4,  -- Daemon Scales
    --0x0F7E,  -- Bones
    --0xFCA9,  -- Hardened Resin
    --0x318B,  -- Enchanted Bark
    --0x0E21,  -- Clean Bandage
    --0x0F8D,  -- Spider Silk
    --0x0F86,  -- Mandrake Root
    --0x0F8C,  -- Ash
    --0x0F7B,  -- Blood Moss
    --0x0F88,  -- Night Shade
    --0x0F84,   -- Garlic
    --0x0F7A,   -- Black Pearl
    --0x0F85,   -- Ginseng
    0x0F3F,   -- Arrows
    --0x1BFB,   -- Bolts
    -- 0x09F1,  -- Raw Ribs
    -- (lowest priority)
}

-- Enable to automatically skin corpses. Needs a skinning knife.
local AUTO_SKIN_CORPSES = true

-- Used for skinning corpses
local CORPSE_GRAPHIC = 0x2006
-- Unwanted uncut hides: put them in a nearby corpse first, then on the ground.
-- Use the corpse property, not a hand-maintained list of corpse graphics.
local HIDE_DISPOSAL_RANGE = 2

-- Used for skinning corpses
local SKINNING_KNIFE = 0xFEA9

-- Used for skinning corpses (cuts leather you want to keep)
local SCISSOR_GRAPHIC = 0x0F9F

-- Store cut leather matching KEEP_HUES in a nearby pack horse.
-- Finds it by body graphic, not name or a hardcoded serial.
local AUTO_STORE_LEATHER = true
local PACK_HORSE_GRAPHIC = 0x0123
local PACK_HORSE_RANGE = 2
local CUT_LEATHER_GRAPHIC = 0x1081
-- If a horse cannot accept the leather, keep it until this weight.
-- Below 390 stones = keep. At 390+ = drop only enough cut leather to
-- get safely below 390. The server's cut-leather weight is 0.5 stone each.
local MAX_LEATHER_CARRY_WEIGHT = 390
local CUT_LEATHER_WEIGHT = 0.5
-- Do not skin unless at least this much carrying capacity is available.
-- This is based on the weight AFTER cutting, not the heavier uncut hides.
-- With 0.5 stone per leather, 50 stones covers about 100 cut pieces.
-- Actual hide yield is unknown until after skinning.
local MIN_FREE_WEIGHT_TO_SKIN = 50
-- A rejected pack horse is skipped for 15 seconds, PER HORSE.
-- Other nearby horses are tried immediately without waiting.
local HORSE_FAILURE_RETRY_MS = 15000
-- A renameable pet is normally one you control; this avoids random nearby horses.
-- If your own pack horse is not marked renameable, change to false.
local REQUIRE_RENAMABLE_HORSE = true

-- Only keep these leathers, rest gets dropped on groud
local KEEP_HUES = {
    -- 0x0000, -- Regular
    --0x0973, -- Dull Copper
    --0x0966, -- Shadow Iron
    --0x096D, -- Copper
    --0x0972, -- Bronze
    --0x08A5, -- Gold
    0x0979, -- Agapite
    0x089F, -- Verite
    0x08AB -- Valorite
}

-- This is actually encoded in the Item.Amount field...
local SKIP_CORPSES = {
    400, -- Human
    401, -- Female
}

-- Auto attack won't target these
local MOBS_TO_IGNORE = {
    --    "a giant toad",
    --    "a rat"
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

local MUSHROOM_GRAPHIC_ID = 0xFEBF

local POISON_IMMUNE_MOBS = {
    "a wanderer of the void",
    "a crystal elemental",
    "a dread spider",
    "a lost soul",
    "a gate keeper",
    "a plague beast",
}

local INSTRUMENTS = {
    0x0E9C, -- DRUM
    0x0E9D, -- TAMBOURINE
    0x0E9E, -- TAMBOURINE
    0x0EB2, -- HARP
    0x0EB3, -- LUTE
}

local peaceReadyMs = (os.time() * 1000) + 1000
local discordReadyMs = (os.time() * 1000) + 1000
local reEquipShieldReadyMs = (os.time() * 1000) + 1000
local reEquipWeaponReadyMs = (os.time() * 1000) + 1000
local songOfHealingReadyMs = (os.time() * 1000) + 1000
local songOfLightReadyMs = (os.time() * 1000) + 1000
local songOfFortuneReadyMs = (os.time() * 1000) + 1000
local inflammableReadyMs = (os.time() * 1000) + 1000
local checkPoison = os.time() + 1
local useBandageReadyMs = (os.time() + 1) * 1000
local fatAlertReadyMs = (os.time() * 1000) + 1000

-- Helepr
function tableContains(tbl, val)
    for _, value in ipairs(tbl) do
        if value == val then
            return true
        end
    end
    return false
end

---------------------------------------------------------
--  CORPSE TRACKING (Only process once) for skinning
---------------------------------------------------------
local processedCorpses = {}

function HasProcessedCorpse(serial)
    return processedCorpses[serial] == true
end

function MarkCorpseProcessed(serial)
    processedCorpses[serial] = true
end

function GetSkinningKnife()
    for i, item in ipairs(Items.FindByFilter({
        graphics = {SKINNING_KNIFE}
    })) do
    if item.RootContainer == Player.Serial then
        return item
    end
end
end

Cooldown = {}; do
local data = {}
setmetatable(Cooldown, {
    __call = function(t, k, v)
        if not v then
            return t[k]
        end
        t[k] = v
    end,
    __index = function(_, k)
        local cd = data[k]
        if not cd then
            return
        end

        local v = cd.delay - (os.time() - cd.clock) * 1000
        if v < 0 then
            data[k] = nil
            v = nil
        end
        return v
    end,
    __newindex = function(_, k, v)
        if not v then
            data[k] = nil
            return
        end

        local cd = data[k] or { clock = os.time() }
        cd.delay = type(v) == "number" and v > 0 and v or 0 or 0
        data[k] = cd
    end
})
end

local function containsString(haystack, needle)
    for i = 1, #haystack do
        if haystack[i] == needle then
            return true
        end
    end
    return false
end

local function compareByDistance(a, b)
    -- This function must return true if 'a' should precede 'b'
    -- (i.e., if 'a's distance is less than 'b's distance for ascending order)
    return a.Distance < b.Distance
end

local graphicIdLootableSet = {}
local graphicIdToPriority = {}
for i, graphic in ipairs(graphicIdLootableItemPriorityList) do
    graphicIdLootableSet[graphic] = true
    graphicIdToPriority[graphic] = i
end

function WordCheckMultiple(str1, keywordString)
    local lowerStr = string.lower(str1)
    for word in string.gmatch(keywordString, "%S+") do
        local lowerWord = string.lower(word)
        if not string.find(lowerStr, lowerWord, 1, true) then
            return false
        end
    end
    return true
end

function extract_weight(item)
    -- Pattern explanation:
    -- .*- matches any character (including newlines due to how Lua handles this in patterns) zero or more times, as few as possible.
    -- (?:...) - this is a general regex concept, but not directly supported in standard Lua patterns.
    -- The approach below uses Lua's native patterns and capture groups.

    -- Attempt to match "Weight: " followed by 1-3 digits.
    -- 'Weight:%s*(%d%d?%d?)'
    -- %s* matches zero or more whitespace characters.
    -- (%d%d?%d?) captures 1, 2, or 3 digits.
    local weight_str = string.match(item.Properties, "Weight:%s*(%d%d?%d?) Stone")

    if weight_str then
        return tonumber(weight_str) -- Convert the captured string to a number
    else
        -- If the "Weight: " pattern isn't found, you might want to return nil or a default value
        -- depending on your specific needs when it's missing entirely.
        -- In this case, it returns nil, so you can handle it.
        return nil
    end
end


local serialIdCorpseIgnoreList = {}
function IgnoreCorpse(serialIdCorpse)
    if #serialIdCorpseIgnoreList >= 50 then
        table.remove(serialIdCorpseIgnoreList, 1)
    end
    table.insert(serialIdCorpseIgnoreList, serialIdCorpse)
end

function IsCorpseIgnored(serialIdCorpse)
    for _, id in ipairs(serialIdCorpseIgnoreList) do
        if id == serialIdCorpse then
            return true
        end
    end
    return false
end

function FindCorpse()
    local itemCorpse = nil
    local itemList = Items.FindByFilter({})
    for index, item in ipairs(itemList) do
        if item.IsCorpse == false then
            goto continue
        end
        if item.Distance == nil or item.Distance > 2 then
            goto continue
        end
        if IsCorpseIgnored(item.Serial) == true then
            goto continue
        end
        if Journal.Contains("Looting this monster corpse will be a criminal act!") == true then
            Journal.Clear()
            goto continue
        end
        itemCorpse = item
        break
        ::continue::
    end
    return itemCorpse
end

function GetSortedItemList()
    local seriableIdLootPriorityList = {}
    local itemList = Items.FindByFilter({onground=false})
    for index, item in ipairs(itemList) do
        if item.RootContainer == Player.Serial then
            goto continue
        end

        if item.RootContainer == Player.Backpack.Serial then
            goto continue
        end

        --        if item.RootContainer == lootbag.Serial then
        --            goto continue
        --        end

        local container = Items.FindBySerial(item.Container)

        if container == nil or container.Name == nil or string.find(container.Name:lower(), "corpse") == nil or container.Distance > 2 then
            goto continue
        end

        if item.Distance == nil or (item.Distance > 2 and item.Distance < 16) then
            goto continue
        end

        if not graphicIdLootableSet[item.Graphic] then
            goto continue
        end

        if item.IsLootable == false then
            goto continue
        end

        if item.Name == nil then
            goto continue
        end

        if item.Properties == nil then
            goto continue
        end

        local isLockedDown = WordCheckMultiple(item.Properties, "Locked Down")
        if isLockedDown == true then
            goto continue
        end

        local weight = extract_weight(item)
        if weight ~= nil and weight + Player.Weight > Player.MaxWeight then
            --if not Cooldown("FatAlert") then
            if os.time() * 1000 > fatAlertReadyMs then
                --Messages.Overhead("too fat, big heavy .. no pick up " .. item.Name .. " (" .. tostring(weight) .. " stones)", 47, Player.Serial)
                Messages.OverheadMobile(Player.Serial, "too fat, big heavy .. no pick up " .. item.Name .. " (" .. tostring(weight) .. " stones)", 47)
                --Cooldown("FatAlert", 5000)
                fatAlertReadyMs = (os.time() * 1000) + 5000
            end
            goto continue
        end

        --Messages.Print("Found item " .. item.Name .. " in root container " .. item.RootContainer)

        table.insert(seriableIdLootPriorityList, item)
        ::continue::
    end

    table.sort(seriableIdLootPriorityList, function(a, b)
        local priorityA = graphicIdToPriority[a.Graphic] or math.huge
        local priorityB = graphicIdToPriority[b.Graphic] or math.huge
        if priorityA == priorityB then
            return (a.Name or "") < (b.Name or "")
        end
        return priorityA < priorityB
    end)

    return seriableIdLootPriorityList
end

local mobileTargetLast = nil
local mobileTargetHitpoints = math.huge
local checkRetarget = os.time() + 1
function AutoAttack()
    mobileTarget = nil
    if not AUTO_ATTACK then return end
    local mobileList = Mobiles.FindByFilter({ rangemax=ATTACK_RANGE, dead = false, notorieties = { 0, 3, 4, 5, 6} })
    table.sort(mobileList, compareByDistance)
    for index, mobile in ipairs(mobileList) do
        local mobile = mobileList[index]
        if mobile == nil then
            goto continue
        end

        if mobile.Distance == nil then
            goto continue
        else
            if mobile.Distance > ATTACK_RANGE then
                goto continue
            end
        end

        if mobile.IsDead then
            Messages.Print("Mobile is dead!!!!")
            goto continue
        end

        if AUTO_ATTACK_REDS == false then
            if mobile.NotorietyFlag == "Murderer" then
                goto continue
            end
        end

        if mobile.NotorietyFlag == "Innocent" or mobile.NotorietyFlag == "Ally" or mobile.NotorietyFlag == "Invulnerable" then
            goto continue
        end

        if mobile.Hits <= 0 then
            goto continue
        end

        if mobile.Hits > mobileTargetHitpoints then
            goto continue
        end

        if SKIP_DEMONS and mobile.Graphic == 0x0009 and mobile.Hue == 0x0000 then
            goto continue
        end

        if containsString(MOBS_TO_IGNORE, mobile.Name)
        then
        goto continue
    end

    if containsString(FRIEND_SERIALS, mobile.Serial)
    then
    goto continue
end

mobileTargetHitpoints = mobile.Hits
mobileTarget = mobile
break

::continue::
end

mobileTargetHitpoints = math.huge
if mobileTarget ~= nil then
    if mobileTargetLast == nil or mobileTarget.Serial ~= mobileTargetLast.Serial or os.time() > checkRetarget then
        mobileTargetLast = mobileTarget
        Messages.Print("Attacking... " .. mobileTarget.Name, 69, Player.Serial)
        Player.Attack(mobileTarget.Serial)
        checkRetarget = os.time() + 3
        --return mobileTarget
    end
end
return mobileTarget

--    if mobileTarget ~= nil and Skills.GetValue("Alchemy") >= 100 and EXPLODE_POTS and os.time() > checkExplodePot then
--        pots = Items.FindByID(0x0F0D, Player.Backpack.Serial)
--        pots = Items.FindByType(0x0F0D)

--        if pots ~= nil then
--            Messages.Print(pots.Serial)
--            Items.UseItem(pots.Serial)
--            Player.UseObjectByType(0x0E21)
--           Target.WaitForTarget(1000)
--            Target.TargetSerial(mobileTarget.Serial)
--            Messages.Print("Throwing Pot")
--       else
--            Messages.Print("You have no pots")
--        end
--
--        checkExplodePot = os.time() + 5
--    end
end


function ApplyPoison(mobileTarget)
    if not USE_POISONS then return end
    if not mobileTarget then return end
    if containsString(POISON_IMMUNE_MOBS, mobileTarget.Name) then return end
    if mobileTarget.IsPoisoned and SMART_POISONING then return end

    if os.time() > checkPoison then
        wep = Items.FindByLayer(1)
        if wep ~= nil and wep.Properties ~= nil then
            if WEAPON_GRAPHIC ~= 0 and wep.Graphic ~= WEAPON_GRAPHIC then return end

            if string.find(wep.Properties, 'Poison') == nil then
                --Messages.Overhead("You dont have poison", 44, Player.Serial)
                --Messages.OverheadMobile(Player.Serial, 'You dont have poison', 44)

                local poison = Items.FindByType(0x0F0A)
                if poison ~= nil then
                    local weapon = Items.FindByLayer(1)
                    if weapon ~= nil then
                        --Messages.Overhead("Using Poison", 44, Player.Serial)
                        Messages.OverheadMobile(Player.Serial, '+ Applying Poison +', 44)
                        Skills.Use("Poisoning")
                        Target.WaitForTarget(1000)
                        Target.TargetSerial(poison.Serial)
                        --Target.TargetSerial(poison.Serial)
                        Target.WaitForTarget(1000)
                        --                        Target.TargetSerial(weapon.Serial)
                        Target.TargetSerial(weapon.Serial)
                    end
                end
            end
        end
        checkPoison = os.time() + 3
    end
end

function AutoLoot()
    if AUTOLOOT then
        local sortedItemList = GetSortedItemList()
        if #sortedItemList > 0 then
            --Messages.Print("> " .. sortedItemList[1].Name, 69, Player.Serial)
            Player.PickUp(sortedItemList[1].Serial, sortedItemList[1].Amount)
            Player.DropInBackpack()
            Pause(ACTION_DELAY)
        end
    end
end

function PopPouch()
    if USE_POUCHES and Player.IsParalyzed then
        local items = Items.FindByFilter({
            graphics = {0x0E79},
            hues = {0x0025}
        })
        for i, item in ipairs(items) do
            if item.RootContainer == Player.Serial then
                Player.UseObject(item.Serial)
                break
            end
        end
    end
end


function UseDiscord(mobileTarget)
    if not USE_DISCORD then return end
    --if Cooldown("Discord") then return end
    if os.time() * 1000 < discordReadyMs then return end
    if Player.Hits < 40 then return end
    if Player.IsPoisoned then return end
    if not mobileTarget then return end
    if Skills.GetValue("Discordance") < 20 then return end
    --if USE_SONG_OF_HEALING and not Cooldown("SongOfHealing") then return end
    if USE_SONG_OF_HEALING and (os.time() * 1000) > songOfHealingReadyMs then return end

    local instrument
    for i, graphicId in ipairs(INSTRUMENTS) do
        instrument = Items.FindByType(graphicId)
        if instrument ~= nil then break end
    end

    if not instrument then return end

    Journal.Clear()
    Spells.Cast('SongOfDiscordance')
    Target.WaitForTarget(1000)
    if Journal.Contains("What instrument shall you play?") then
        Target.TargetSerial(instrument.Serial)
        Target.WaitForTarget(1000)
    end
    Target.TargetSerial(mobileTarget.Serial)
    discordReadyMs = (os.time() * 1000) + 7000
    Pause(ACTION_DELAY)
end


function UsePeace(mobileTarget)
    if not USE_PEACE then return end
    if os.time() * 1000 < peaceReadyMs then return end
    if Player.Hits < 40 then return end
    if Player.IsPoisoned then return end
    if not mobileTarget then return end
    if Skills.GetValue("Peacemaking") < 20 then return end
    if USE_SONG_OF_HEALING and (os.time() * 1000) > songOfHealingReadyMs then return end

    local instrument
    for i, graphicId in ipairs(INSTRUMENTS) do
        instrument = Items.FindByType(graphicId)
        if instrument ~= nil then break end
    end

    if not instrument then return end

    Journal.Clear()
    Spells.Cast('SongOfPeacemaking')
    Target.WaitForTarget(1000)
    if Journal.Contains("What instrument shall you play?") then
        Target.TargetSerial(instrument.Serial)
        Target.WaitForTarget(1000)
    end
    Target.TargetSerial(mobileTarget.Serial)
    peaceReadyMs = (os.time() * 1000) + 7000
    Pause(ACTION_DELAY)
end


function UseInflammablePots(targetMobile)
    if not USE_INFLAMMABLE_POTS then return end
    if Skills.GetValue("Alchemy") < 90 then return end
    --if Cooldown("UseInflammablePot") then return end
    if (os.time() * 1000) < inflammableReadyMs then return end
    if not targetMobile then return end

    local pot = Items.FindByType(0xFDB3)
    if not pot then return end -- No cure pots, no healing
    if pot.Container ~= Player.Backpack.Serial then return end -- sometimes pots may be on ground and far away

    Player.UseObject(pot.Serial)
    Target.WaitForTarget(1000)
    Target.TargetSerial(targetMobile.Serial)
    --Cooldown("UseInflammablePot", 10000)
    inflammableReadyMs = (os.time() * 1000) + 10000
    Pause(ACTION_DELAY)
end


function UseSongOfHealing()
    if not USE_SONG_OF_HEALING then return end
    if Skills.GetValue("Musicianship") < 50 then return end
    --if Cooldown("SongOfHealing") then return end
    if (os.time() * 1000) < songOfHealingReadyMs then return end
    if Player.Hits < 50 then return end

    local instrument
    for i, graphicId in ipairs(INSTRUMENTS) do
        instrument = Items.FindByType(graphicId)
        if instrument ~= nil then break end
    end

    if not instrument then return end

    Journal.Clear()
    Spells.Cast('SongOfHealing')
    Target.WaitForTarget(1000)
    if Journal.Contains("What instrument shall you play?") then
        Target.TargetSerial(instrument.Serial)
        Target.WaitForTarget(1000)
    end

    Pause(ACTION_DELAY)

    if Journal.Contains("Your song creates a healing aura around you") then
        --Cooldown("SongOfHealing", SONG_OF_HEALING_RECAST)
        songOfHealingReadyMs = (os.time() * 1000) + SONG_OF_HEALING_RECAST
        -- 3:07
        Player.Say("+ Song of Healing +", 67)
    elseif Journal.Contains("You are already under the effects of this song") then
        --Cooldown("SongOfHealing", 20 * 1000)
        songOfHealingReadyMs = (os.time() * 1000) + 20000
    end
end

function UseSongOfFortune(mobileTarget)
    if not USE_SONG_OF_FORTUNE then return end
    if mobileTarget then return end
    if Skills.GetValue("Musicianship") < 50 then return end
    --if Cooldown("SongOfFortune") then return end
    if (os.time() * 1000) < songOfFortuneReadyMs then return end
    if Player.Hits < 50 then return end
    --if USE_SONG_OF_HEALING and not Cooldown("SongOfHealing") then return end
    if USE_SONG_OF_HEALING and (os.time() * 1000) > songOfHealingReadyMs then return end

    local instrument
    for i, graphicId in ipairs(INSTRUMENTS) do
        instrument = Items.FindByType(graphicId)
        if instrument ~= nil then break end
    end

    if not instrument then return end

    Journal.Clear()
    Spells.Cast('SongOfFortune')
    Target.WaitForTarget(1000)
    if Journal.Contains("What instrument shall you play?") then
        Target.TargetSerial(instrument.Serial)
        Target.WaitForTarget(1000)
    end

    Pause(ACTION_DELAY)

    if Journal.Contains("You play the song of fortune") then
        --Cooldown("SongOfFortune", SONG_OF_FORTUNE_RECAST)
        songOfFortuneReadyMs = (os.time() * 1000) + SONG_OF_FORTUNE_RECAST
        -- 3:07
        Player.Say("+ Song of Fortune +", 67)
    elseif Journal.Contains("You already have a luck bonus") then
        --Cooldown("SongOfFortune", 30 * 1000)
        songOfFortuneReadyMs = (os.time() * 1000) + 30000
    else
        --Cooldown("SongOfFortune", 5 * 1000)
        songOfFortuneReadyMs = (os.time() * 1000) + 5000
    end
end

function UseSongOfLight(mobileTarget)
    if not USE_SONG_OF_LIGHT then return end
    if mobileTarget then return end
    if Skills.GetValue("Musicianship") < 50 then return end
    --if Cooldown("SongOfLight") then return end
    if (os.time() * 1000) < songOfLightReadyMs then return end
    if Player.Hits < 50 then return end
    --if USE_SONG_OF_HEALING and not Cooldown("SongOfHealing") then return end
    if USE_SONG_OF_HEALING and (os.time() * 1000) > songOfHealingReadyMs then return end

    local instrument
    for i, graphicId in ipairs(INSTRUMENTS) do
        instrument = Items.FindByType(graphicId)
        if instrument ~= nil then break end
    end

    if not instrument then return end

    Journal.Clear()
    Spells.Cast('SongOfLight')
    Target.WaitForTarget(1000)
    if Journal.Contains("What instrument shall you play?") then
        Target.TargetSerial(instrument.Serial)
        Target.WaitForTarget(1000)
    end

    Pause(ACTION_DELAY)

    if Journal.Contains("You fail to play the song of light") then
        --Cooldown("SongOfLight", 30 * 1000)
        songOfLightReadyMs = (os.time() * 1000) + 30000
        --if Journal.Contains("You already have night sight") then
        --Cooldown("SongOfLight", 10 * 1000)
    elseif Journal.Contains("You successfully play the song of light") then
        --Cooldown("SongOfLight", SONG_OF_LIGHT_RECAST)
        songOfLightReadyMs = (os.time() * 1000) + SONG_OF_LIGHT_RECAST
        Player.Say("+ Song of Light +", 67)
    else
        --Cooldown("SongOfLight", 5 * 1000)
        songOfLightReadyMs = (os.time() * 1000) + 5000
    end
end

function PickupMushrooms(mobileTarget)
    if not PICKUP_MUSHROOMS then return end
    if mobileTarget ~= nil then return end
    local shrooms = Items.FindByFilter({ graphics = MUSHROOM_GRAPHIC_ID, rangemax = 2, onground = true  })
    if #shrooms > 0 then
        Player.UseObject(shrooms[1].Serial)
        --Messages.Overhead("OMG ", 37, shrooms[1].Serial)
        --Messages.OverheadMobile(shrooms[1].Serial, 'OMG', 37)
        Pause(ACTION_DELAY)
    end
end

function UseCurePot()
    if not USE_CURE_POTS then
        return
    end

    if not Player.IsPoisoned then
        return
    end

    local pot = Items.FindByType(0x0F07)
    if not pot then return end -- No cure pots, no healing
    if pot.Container ~= Player.Backpack.Serial then return end -- sometimes pots may be on ground and far away

    if Skills.GetValue("Alchemy") >= 80 then
        Player.UseObject(pot.Serial)
        --Messages.Overhead("Drinking Cure", 1128, Player.Serial)
        Messages.OverheadMobile(Player.Serial, 'Drinking Cure', 1128)
        Pause(ACTION_DELAY)
    else
        local twoHanded = Items.FindByLayer(2)
        if twoHanded then
            -- Just unequip shield. We'll drink the cure pot
            -- next tick. Gets re-equipped by the ReequipShield()
            -- function (if player is not poisoned)
            --Messages.Overhead("- Shield -", 37, Player.Serial)
            Messages.OverheadMobile(Player.Serial, '- Shield -', 57)
            Player.PickUp(twoHanded.Serial, twoHanded.Amount)
            Player.DropInBackpack()
            Pause(ACTION_DELAY)
        else
            Player.UseObject(pot.Serial)
            --Messages.Overhead("Drinking Cure", 1128, Player.Serial)
            Messages.OverheadMobile(Player.Serial, '+ Drinking Cure +', 1128)
            Pause(ACTION_DELAY)
        end
    end
    return
end

local WEAPON_TO_EQUIP = 0x13B2

function ReequipWeapon()
    if not REEQUIP_WEAPON then return end
    if not WEAPON_TO_EQUIP then return end
    if (os.time() * 1000) < reEquipWeaponReadyMs then return end

    local weapon = Items.FindByLayer(2)
    if not weapon or weapon.Graphic ~= WEAPON_TO_EQUIP then
        Player.ClearHands("both")
        Pause(ACTION_DELAY)
        weapon = Items.FindByType(WEAPON_TO_EQUIP)
        if weapon then
            Messages.Print("Auto equipping weapon", Colors.Info)
            Player.Equip(weapon.Serial)
            Pause(ACTION_DELAY)
        end
    end

    reEquipWeaponReadyMs = (os.time() * 1000) + 1000
end

function UseBandage()
    if not USE_BANDAGES then return end

    -- Check global bandage timer
    if (os.time() * 1000) < useBandageReadyMs then return end
    if Skills.GetValue("Healing") < 40 then return end

    local bandage = Items.FindByType(0x0E21)
    if not bandage then return end

    -- 1. Check Self First
    if Player.Hits < Player.HitsMax or Player.IsPoisoned then
        if Player.UseObject(bandage.Serial) then
            if Target.WaitForTarget(500) then
                Target.Self()

                -- Calculate delay based on Dex
                local selfDelay = ((8.0 + 0.85 * ((130 - Player.Dex) / 20)) * 1100)

                Messages.OverheadMobile(Player.Serial, "+ Healing Self +", 67)
                useBandageReadyMs = (os.time() * 1000) + selfDelay

                Pause(ACTION_DELAY)
                return -- Exit function after starting heal
            end
        else
            Pause(ACTION_DELAY)
            Messages.OverheadMobile(Player.Serial, "I no use bandage", 82)
        end
        return
    end

    -- 2. Check Allies if Self is Healthy
    if BANDAGES_ON_FRIENDS then
        for _, serial in ipairs(FRIEND_SERIALS) do
            if serial == Player.Serial then
                goto continue
            end

            local ally = Mobiles.FindBySerial(serial)

            -- Check if ally exists, is alive, in range (1 tile), and needs help
            if ally and ally.Hits > 0 and ally.Distance <= 1 then
                local hpPercent = (ally.Hits / ally.HitsMax)

                if hpPercent <= BANDAGE_FRIENDS_MIN_THRESHOLD_HP or ally.IsPoisoned then
                    -- UPDATED: Use your new variable here instead of Cooldown()
                    if (os.time() * 1000) >= useBandageReadyMs then
                        if Player.UseObject(bandage.Serial) then
                            if Target.WaitForTarget(500) then
                                Target.TargetSerial(ally.Serial)
                                Player.Say("+ Healing " .. ally.Name .. " +", 67)

                                -- Set 5-second delay for healing others
                                useBandageReadyMs = (os.time() * 1000) + 5000
                                Pause(ACTION_DELAY)
                                return -- Heal one person at a time
                            end
                        end
                    end
                end
            end
            ::continue::
        end
    end
end -- This closes the function correctly

---------------------------------------------------------
-- CUT LEATHER: NEARBY PACK HORSE, THEN 390-STONE FALLBACK
-- Only leather graphic 0x1081 in KEEP_HUES is ever moved here.
---------------------------------------------------------
local nextLeatherStoreCheckMs = 0
-- Each horse has its own failure timeout. One full horse never blocks another.
local failedHorseRetryBySerial = {}

-- Direct children of the main backpack only; no nested bags or hides.
function GetKeptCutLeatherInBackpack()
    if not Player.Backpack or not Player.Backpack.Serial then return {} end

    local contents = Items.FindInContainer(Player.Backpack.Serial, CUT_LEATHER_GRAPHIC) or {}
    local result = {}
    for _, item in ipairs(contents) do
        if tableContains(KEEP_HUES, item.Hue) then
            table.insert(result, item)
        end
    end
    return result
end

function CountBackpackCutLeatherHue(hue)
    if not Player.Backpack or not Player.Backpack.Serial then return 0 end

    local total = 0
    local contents = Items.FindInContainer(Player.Backpack.Serial, CUT_LEATHER_GRAPHIC, hue) or {}
    for _, item in ipairs(contents) do
        total = total + (item.Amount or 1)
    end
    return total
end

-- Get a current copy of a stack, because a rejected drop may return the
-- leather with a different serial (or merge it with another backpack stack).
function RefreshKeptCutLeather(serial, hue)
    local sameHue = nil
    for _, item in ipairs(GetKeptCutLeatherInBackpack()) do
        if item.Serial == serial then return item end
        if item.Hue == hue and sameHue == nil then sameHue = item end
    end
    return sameHue
end

-- No special names and no hardcoded pet serials. Sort closest first.
function FindNearbyPackHorses()
    local horses = Mobiles.FindByFilter({
        bodies = {PACK_HORSE_GRAPHIC},
        dead = false,
        rangemax = PACK_HORSE_RANGE
    }) or {}

    local eligible = {}
    for _, horse in ipairs(horses) do
        if horse.Serial ~= nil
        and (not REQUIRE_RENAMABLE_HORSE or horse.IsRenamable == true)
        and not horse.IsDead
        and horse.Distance ~= nil
        and horse.Distance <= PACK_HORSE_RANGE then
        table.insert(eligible, horse)
    end
end
table.sort(eligible, function(a, b)
    if a.Distance == b.Distance then return a.Serial < b.Serial end
    return a.Distance < b.Distance
end)
return eligible
end

-- The client's successful drop return does not prove the server accepted
-- it. Confirm that the stack really left our backpack after the action.
-- Returns (true) on confirmed transfer, or (false, reason) otherwise.
function TryStoreCutLeatherOnHorse(horse, leather)
    local nearby = Mobiles.FindBySerial(horse.Serial)
    if not nearby or nearby.IsDead or nearby.Distance == nil
    or nearby.Distance > PACK_HORSE_RANGE
    or (REQUIRE_RENAMABLE_HORSE and nearby.IsRenamable ~= true) then
    return false, 'horse'
end

local before = CountBackpackCutLeatherHue(leather.Hue)
local amount = leather.Amount or 1
if before <= 0 or amount <= 0 then return false, 'item' end

if not Player.PickUp(leather.Serial, amount) then
    -- Failed pickup isn't evidence that the HORSE is full.
    return false, 'pickup'
end
Pause(ACTION_DELAY)

local submitted = Player.DropInContainer(horse.Serial)
Pause(ACTION_DELAY)

-- If rejected and still held, put it back. If accepted, there is
-- nothing on the cursor and this returns false without moving items.
local returnedToBag = Player.DropInBackpack()
if returnedToBag then Pause(ACTION_DELAY) end

local after = CountBackpackCutLeatherHue(leather.Hue)
if submitted and not returnedToBag and after < before then
    Messages.Print('Stored ' .. tostring(before - after) ..
    ' cut leather in pack horse ' .. tostring(horse.Serial), Colors.Confirm)
    return true
end

return false, 'horse'
end

-- When every horse fails (or none is nearby), retain kept cut leather if
-- Weight < 390. Otherwise drop ONLY the excess cut leather in KEEP_HUES.
function DropExcessKeptCutLeather()
    if Player.Weight == nil then return end

    local limit = MAX_LEATHER_CARRY_WEIGHT
    if Player.MaxWeight and Player.MaxWeight < limit then
        limit = Player.MaxWeight
    end
    if Player.Weight < limit then return end

    -- Aim one stone below the limit to allow for client rounding.
    local targetWeight = limit - 1
    local leatherStacks = GetKeptCutLeatherInBackpack()

    -- Prefer dropping earlier hues in the user's KEEP_HUES list first.
    table.sort(leatherStacks, function(a, b)
        local rankA = #KEEP_HUES + 1
        local rankB = #KEEP_HUES + 1
        for i, hue in ipairs(KEEP_HUES) do
            if hue == a.Hue then rankA = i end
            if hue == b.Hue then rankB = i end
        end
        return rankA < rankB
    end)

    for _, leather in ipairs(leatherStacks) do
        if Player.Weight < limit then break end

        local pieces = math.ceil((Player.Weight - targetWeight) / CUT_LEATHER_WEIGHT)
        pieces = math.max(1, math.min(leather.Amount or 1, pieces))
        local before = CountBackpackCutLeatherHue(leather.Hue)

        if Player.PickUp(leather.Serial, pieces) then
            Pause(ACTION_DELAY)
            local submitted = Player.DropOnGround()
            Pause(ACTION_DELAY)
            -- As above, a refused drop can leave an item on the cursor.
            local returnedToBag = Player.DropInBackpack()
            if returnedToBag then Pause(ACTION_DELAY) end
            local after = CountBackpackCutLeatherHue(leather.Hue)

            if submitted and not returnedToBag and after < before then
                Messages.Print('Weight ' .. tostring(Player.Weight) ..
                ': dropped ' .. tostring(before - after) ..
                ' kept cut leather (hue ' .. string.format('0x%04X', leather.Hue) ..
                ')', Colors.Warning)
            else
                Messages.Print('Could not drop excess cut leather', Colors.Warning)
                break
            end
        else
            Messages.Print('Could not pick up excess cut leather to drop', Colors.Warning)
            break
        end
    end
end

function StoreKeptLeatherOnPackHorse()
    if not Player.Backpack or not Player.Backpack.Serial then return end

    local nowMs = os.time() * 1000
    if nowMs < nextLeatherStoreCheckMs then return end
    nextLeatherStoreCheckMs = nowMs + 2000

    local leatherStacks = GetKeptCutLeatherInBackpack()
    if #leatherStacks == 0 then return end

    local horses = {}
    if AUTO_STORE_LEATHER then
        horses = FindNearbyPackHorses()
    end

    -- Try EVERY eligible nearby horse, closest first, for each stack.
    -- A full / unreachable horse is cooled down independently. When one
    -- rejects the leather, try the next horse immediately on this pass.
    for _, originalLeather in ipairs(leatherStacks) do
        for _, horse in ipairs(horses) do
            if (failedHorseRetryBySerial[horse.Serial] or 0) <= nowMs then
                local leather = RefreshKeptCutLeather(originalLeather.Serial, originalLeather.Hue)
                if not leather then break end

                local stored, reason = TryStoreCutLeatherOnHorse(horse, leather)
                if stored then
                    -- One success means this stack is handled. The next stack
                    -- starts again at the nearest non-failed horse.
                    failedHorseRetryBySerial[horse.Serial] = nil
                    break
                elseif reason == 'horse' then
                    failedHorseRetryBySerial[horse.Serial] = nowMs + HORSE_FAILURE_RETRY_MS
                    Messages.Print('Pack horse ' .. tostring(horse.Serial) ..
                    ' full/unavailable; trying another', Colors.Warning)
                else
                    -- A missing item or failed pickup will not improve by
                    -- trying a different horse; avoid useless extra actions.
                    break
                end
            end
        end
    end

    -- Always protect weight after all eligible horses have been tried.
    -- Never drop kept cut leather while safely below the carry limit.
    DropExcessKeptCutLeather()
end

---------------------------------------------------------
-- SKINNING CAPACITY: don't trigger automatic hide pickup
-- unless there is room for an expected 50-stone cut yield.
-- We cannot know the exact number of hides before skinning.
---------------------------------------------------------
local nextSkinningWarningMs = 0

function SkinningCapacityLimit()
    local limit = MAX_LEATHER_CARRY_WEIGHT
    if Player.MaxWeight and Player.MaxWeight < limit then
        limit = Player.MaxWeight
    end
    return limit
end

function SkinningWarning(message)
    local nowMs = os.time() * 1000
    if nowMs >= nextSkinningWarningMs then
        Messages.Print(message, Colors.Warning)
        nextSkinningWarningMs = nowMs + 10000
    end
end

function HaveKeptUncutHides()
    -- Only check our own inventory. Don't touch hides inside corpses.
    local hides = Items.FindByFilter({ graphics = {0x1079}, onground = false }) or {}
    for _, hide in ipairs(hides) do
        if hide.RootContainer == Player.Serial and tableContains(KEEP_HUES, hide.Hue) then
            return true
        end
    end
    return false
end

---------------------------------------------------------
-- UNWANTED HIDES: CORPSE FIRST, GROUND IF REJECTED
-- Uses Items.FindByFilter(corpse=true) rather than a graphic list.
-- Only uncut 0x1079 hides outside KEEP_HUES go through here.
---------------------------------------------------------
function FindNearbyHideDisposalCorpses(preferredCorpseSerial)
    local corpses = Items.FindByFilter({corpse = true, onground = true, rangemax = HIDE_DISPOSAL_RANGE}) or {}
    table.sort(corpses, function(a, b)
        if a.Serial == preferredCorpseSerial then return true end
        if b.Serial == preferredCorpseSerial then return false end
        if (a.Distance or 999) ~= (b.Distance or 999) then return (a.Distance or 999) < (b.Distance or 999) end
        return (a.Serial or 0) < (b.Serial or 0)
    end)
    return corpses
end

function PutUnwantedHidesInCorpseOrGround(hide, preferredCorpseSerial)
    -- The script only handles unwanted UNCUT hides in our own inventory.
    if not hide or hide.Graphic ~= 0x1079 then return false end
    if hide.RootContainer ~= Player.Serial then return false end
    if tableContains(KEEP_HUES, hide.Hue) then return false end

    local serial = hide.Serial
    local amount = hide.Amount or 1
    local hue = hide.Hue
    local corpses = FindNearbyHideDisposalCorpses(preferredCorpseSerial)

    -- Lift once; don't drop on the ground and then pick it up again.
    if not Player.PickUp(serial, amount) then return false end
    Pause(ACTION_DELAY)

    for _, corpse in ipairs(corpses) do
        local currentCorpse = Items.FindBySerial(corpse.Serial)
        if currentCorpse and currentCorpse.IsCorpse and currentCorpse.OnGround
        and currentCorpse.Distance and currentCorpse.Distance <= HIDE_DISPOSAL_RANGE then
        local before = Items.CountTypeInContainer(corpse.Serial, 0x1079, hue)
        local submitted = Player.DropInContainer(corpse.Serial)
        Pause(ACTION_DELAY)

        -- A client-side true means the drop was sent, not necessarily accepted.
        -- Confirm by the item's destination or a rise in the corpse's count.
        local fresh = Items.FindBySerial(serial)
        local after = Items.CountTypeInContainer(corpse.Serial, 0x1079, hue)
        if submitted and ((fresh and fresh.Container == corpse.Serial) or after > before) then
            Messages.Print('Unwanted hides -> corpse ' .. tostring(corpse.Serial), Colors.Status)
            return true
        end

        -- If the server bounced the hides into the backpack, lift again
        -- for the next corpse. If they're still held, PickUp just returns
        -- false and the next drop can proceed without lifting again.
        if fresh and fresh.RootContainer == Player.Serial and not fresh.OnGround then
            if Player.PickUp(fresh.Serial, fresh.Amount or amount) then Pause(ACTION_DELAY) end
        elseif fresh and fresh.OnGround then
            -- The server placed them on the ground; don't retrieve them.
            return true
        end
    end
end

-- No corpse, all rejected, or not confirmed: drop once at our feet.
if Player.DropOnGround() then
    Pause(ACTION_DELAY)
    Messages.Print('Unwanted hides -> ground', Colors.Status)
    return true
end

-- Some server rejections return the hides directly to the backpack.
-- Re-lift ONLY if the original stack is visibly still ours.
local fresh = Items.FindBySerial(serial)
if fresh and fresh.RootContainer == Player.Serial and not fresh.OnGround then
    if Player.PickUp(fresh.Serial, fresh.Amount or amount) then
        Pause(ACTION_DELAY)
        if Player.DropOnGround() then
            Pause(ACTION_DELAY)
            Messages.Print('Unwanted hides -> ground', Colors.Status)
            return true
        end
    end
end

-- Last resort: avoid leaving something on the cursor if a drop failed.
Player.DropInBackpack()
Pause(ACTION_DELAY)
return false
end

function CutOrDropInventoryHides(scissors, preferredCorpseSerial)
    -- A Sagas server change sends skinned hides directly into the backpack.
    -- Cut KEEP_HUES; try to put all unwanted uncut hides in a nearby corpse.
    local hides = Items.FindByFilter({ graphics = {0x1079}, onground = false }) or {}
    for _, hide in ipairs(hides) do
        if hide.RootContainer == Player.Serial then
            if not tableContains(KEEP_HUES, hide.Hue) then
                if NOISY_MODE then
                    Player.Say('- ' .. (hide.Name or 'hides') .. ' -', Colors.Warning)
                else
                    Messages.OverheadMobile(Player.Serial, '- ' .. (hide.Name or 'hides') .. ' -', Colors.Warning)
                end
                PutUnwantedHidesInCorpseOrGround(hide, preferredCorpseSerial)
            elseif scissors then
                if NOISY_MODE then
                    Player.Say('+ ' .. (hide.Name or 'hides') .. ' +', Colors.Confirm)
                else
                    Messages.OverheadMobile(Player.Serial, '+ ' .. (hide.Name or 'hides') .. ' +', Colors.Confirm)
                end
                Player.UseObject(scissors.Serial)
                Target.WaitForTarget(3000)
                Target.TargetSerial(hide.Serial)
                Pause(ACTION_DELAY)
            end
        end
    end
end

function AutoSkin()
    if not AUTO_SKIN_CORPSES then return end
    if Skills.GetValue('Skinning') < 1 then return end

    local scissors = Items.FindByType(SCISSOR_GRAPHIC)
    -- Prevent new heavy hides if we cannot actually cut them afterward.
    if scissors and scissors.RootContainer ~= Player.Serial then
        scissors = nil
    end

    -- Process any existing backpack hides BEFORE the weight check.
    -- Otherwise old, heavy hides could leave us permanently blocked.
    CutOrDropInventoryHides(scissors)

    local skinningKnife = GetSkinningKnife()
    if not skinningKnife then return end

    local corpses = Items.FindByFilter({
        graphics = {CORPSE_GRAPHIC},
        onground = true,
        rangemin = 0,
        rangemax = 2
    }) or {}

    for _, corpse in ipairs(corpses) do
        if not HasProcessedCorpse(corpse.Serial) then
            if tableContains(SKIP_CORPSES, corpse.Amount) then
                Messages.Print('Skipping corpse: ' .. (corpse.Name or 'Unknown'), Colors.Warning)
                if AUTOLOOT then
                    Player.UseObject(corpse.Serial)
                    Pause(ACTION_DELAY)
                end
                MarkCorpseProcessed(corpse.Serial)
            elseif not scissors then
                SkinningWarning('Not skinning: scissors are not in your inventory')
                -- Don't mark this corpse; retry when scissors are available.
            elseif HaveKeptUncutHides() then
                SkinningWarning('Not skinning: uncut KEEP_HUES hides still in backpack')
                -- Cut old hides successfully before taking on more.
            else
                local limit = SkinningCapacityLimit()
                local freeWeight = Player.Weight and (limit - Player.Weight) or -1
                if freeWeight < MIN_FREE_WEIGHT_TO_SKIN then
                    SkinningWarning('Not skinning: ' .. tostring(freeWeight) ..
                    ' free stones (need ' .. tostring(MIN_FREE_WEIGHT_TO_SKIN) ..
                    ', limit ' .. tostring(limit) .. ')')
                    -- IMPORTANT: Don't mark corpse processed when skipping for weight.
                    -- It remains eligible if you later unload leather.
                else
                    Messages.Print('Processing corpse: ' .. (corpse.Name or 'Unknown'), Colors.Info)
                    Player.UseObject(skinningKnife.Serial)
                    Target.WaitForTarget(1000, false)
                    Target.TargetSerial(corpse.Serial)
                    Pause(ACTION_DELAY)

                    -- Open for the existing autolooter; hides are handled in inventory.
                    Player.UseObject(corpse.Serial)
                    Pause(ACTION_DELAY)

                    CutOrDropInventoryHides(scissors, corpse.Serial)
                    MarkCorpseProcessed(corpse.Serial)
                end
            end
        end
    end
end

Journal.Clear()

-- Print Initial Start-Up Greeting
Messages.Print("___________________________________", Colors.Info)
Messages.Print("Gatherer Archer Bot Online (v" .. VERSION .. ")", Colors.Info)
Messages.Print("Be sure to configure options in script", Colors.Info)
Messages.Print("__________________________________", Colors.Info)


while not Player.IsDead and not Player.IsHidden do
    Pause(1)
    mobileTarget = AutoAttack()
    UseBandage()
    PopPouch()
    UseCurePot()
    ApplyPoison(mobileTarget)
    UseInflammablePots(mobileTarget)
    UseDiscord(mobileTarget)
    UsePeace(mobileTarget)
    UseSongOfHealing()
    UseSongOfFortune(mobileTarget)
    UseSongOfLight(mobileTarget)
    ReequipWeapon()
    PickupMushrooms(mobileTarget)
    AutoSkin()
    StoreKeptLeatherOnPackHorse()
    AutoLoot()
end
