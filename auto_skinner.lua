------------------------------------------------------------------------------------
-- START OPTIONS for script that auto mines
-- by OMG Arturo
------------------------------------------------------------------------------------
-- Open Corpses, Skin, Loot Rare Leather, Cut Once
-- UO Sagas
-- Improved Version: 2025-12-10
-- By Chaz II (updated from original by JaseOwns)
-- Slimmed down and made significantly worse by omg arturo
-- Don't screw aroudn with this.
local VERSION = "1.8"

local CORPSE_GRAPHIC = 0x2006
local SKINNING_KNIFE = 0xFEA9
local SCISSOR_GRAPHIC = 0x0F9F
local ACTION_DELAY = 800

-- Use /say when dropping or keeping a resource.
-- Otherwise it will print privately over your head.
local NOISY_MODE = true

-- Only keep these leathers, rest gets dropped on groud
local KEEP_HUES = { -- 0x0000, -- Regular
0x0973, -- Dull Copper
-- 0x0966, -- Shadow Iron
-- 0x096D, -- Copper
-- 0x0972, -- Bronze
-- 0x08A5, -- Gold
-- 0x0979, -- Agapite
0x089F, -- Verite
0x08AB -- Valorite
}

-- Primitive auto looter. Does not scavenge.
local AUTOLOOT = true

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
    0x9FF8,  -- Paragon Chest
    0x9FF9,  -- Paragon Chest
    --0x2D9D,  -- Grimoire
    --0x0EED,  -- Gold
    --0x14EC,  -- Treasure Map
    0x573B,  -- Pigments
    --0x0EB2,  -- Lap Harp
    --0x0EB1,  -- Standing Harp
    --0x0EB3,  -- Lute
    --0x0E9D,  -- Tambourine
    --0x0E9E,  -- Tambourine
    --0x0E9C,  -- Drum
    --0x0F26,  -- Diamond
    --0x0F10,  -- Emerald
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
    --0x0F3F,   -- Arrows
    --0x1BFB,   -- Bolts
    --0x09F1,  -- Raw Ribs
    0x0E86,  -- Pickaxe
    -- (lowest priority)
}

-- This is actually encoded in the Item.Amount field...
local SKIP_CORPSES = {
    400, -- Human
    401, -- Female
}

------------------------------------------------------------------------------------
-- END OPTIONS
-- by OMG Arturo
------------------------------------------------------------------------------------

-- Define Color Scheme
local Colors = {
    Alert = 33, -- Red
    Warning = 48, -- Orange
    Caution = 53, -- Yellow
    Action = 67, -- Green
    Confirm = 73, -- Light Green
    Info = 84, -- Light Blue
    Status = 93 -- Blue
}

-- Print Initial Start-Up Greeting
Messages.Print("___________________________________", Colors.Info)
Messages.Print("Skinning System Online (v" .. VERSION .. ")", Colors.Info)
Messages.Print("Disable auto-open corpses w/ ALT + O", Colors.Info)
Messages.Print("__________________________________", Colors.Info)

---------------------------------------------------------
--  HELPERS
---------------------------------------------------------

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

function tableContains(tbl, val)
    for _, value in ipairs(tbl) do
        if value == val then
            return true
        end
    end
    return false
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

function AutoLoot()
    if AUTOLOOT then
        local sortedItemList = GetSortedItemList()
        if #sortedItemList > 0 then
            for _, item in ipairs(sortedItemList) do
                Player.PickUp(sortedItemList[1].Serial, sortedItemList[1].Amount)
                Player.DropInBackpack()
                Pause(ACTION_DELAY)
            end
        end
    end
end


---------------------------------------------------------
--  CORPSE TRACKING (Only process once)
---------------------------------------------------------
local processedCorpses = {}

function HasProcessedCorpse(serial)
    return processedCorpses[serial] == true
end

function MarkCorpseProcessed(serial)
    processedCorpses[serial] = true
end



---------------------------------------------------------
--  MAIN LOOP
---------------------------------------------------------
local corpseFilter = {
    graphics = {CORPSE_GRAPHIC},
    onground = true,
    rangemin = 0,
    rangemax = 2
}

while true do

    local scissors = Items.FindByType(SCISSOR_GRAPHIC)
    local skinningKnife = GetSkinningKnife()
    if skinningKnife == nil then
        Messages.Overhead("No skinningKnife!", 34, Player.Serial)
        Pause(3000)
    else
        local corpses = Items.FindByFilter(corpseFilter)
        for _, corpse in ipairs(corpses) do
            if not HasProcessedCorpse(corpse.Serial) then
                if tableContains(SKIP_CORPSES, corpse.Amount) then
                    Messages.Print("Skipping corpse: " .. (corpse.Name or "Unknown"), Colors.Warning)
                    if AUTOLOOT then
                        Player.UseObject(corpse.Serial)
                        Pause(ACTION_DELAY)
                    end
                else
                    Messages.Print("Processing corpse: " .. (corpse.Name or "Unknown"), Colors.Info)

                    -- Skin the corpse
                    Player.UseObject(skinningKnife.Serial)
                    Target.WaitForTarget(1000, false)
                    Target.TargetSerial(corpse.Serial)
                    Pause(ACTION_DELAY)

                    -- Open the corpse
                    Player.UseObject(corpse.Serial)
                    Pause(ACTION_DELAY)

                    local hides = Items.FindByFilter({
                        graphics = {0x1079},
                        onground = false
                    })
                    for _, hide in ipairs(hides) do
                        if hide.RootContainer == Player.Serial and not tableContains(KEEP_HUES, hide.Hue) then
                            if NOISY_MODE then
                                Player.Say("- " .. hide.Name .. " -", Colors.Warning)
                            else
                                Messages.OverheadMobile(Player.Serial, "- " .. hide.Name .. " -", Colors.Warning)
                            end
                            Player.PickUp(hide.Serial, hide.Amount)
                            Player.DropOnGround()
                            Pause(ACTION_DELAY)
                        elseif hide.RootContainer == Player.Serial and scissors ~= nil then
                            if NOISY_MODE then
                                Player.Say("+ " .. hide.Name .. " +", Colors.Confirm)
                            else
                                Messages.OverheadMobile(Player.Serial, "+ " .. hide.Name .. " +", Colors.Confirm)
                            end
                            Player.UseObject(scissors.Serial)
                            Target.WaitForTarget(3000)
                            Target.TargetSerial(hide.Serial)
                            Pause(ACTION_DELAY)
                        end
                    end

                end

                -- Auto Loot
                AutoLoot()

                -- Mark corpse processed so it never repeats
                MarkCorpseProcessed(corpse.Serial)
            end
        end
    end

    Pause(250)
end
