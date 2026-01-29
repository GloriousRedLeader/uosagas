------------------------------------------------------------------------------------
-- START OPTIONS for AUTO DEXER / ARCHER / HEALER / AUTOLOOTER / POUCHPOPPER / POISON
-- by OMG Arturo
------------------------------------------------------------------------------------

-- Milliseconds of delay between actions
local ACTION_DELAY = 550

-- Auto-pickup mushrooms when you are out of combat (no current enemy selected)
-- You also need to be above 80 health, not poisoned, etc. This is true for a lot of
-- these non-essential functions so heals and such can be prioritized.
local PICKUP_MUSHROOMS = true

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
local USE_POISONS = true

-- Only apply poison to your weapon if you have a current target and
-- the current target does not have poison on it already. This option conserves poisons.
local SMART_POISONING = true

-- Required when POISONS = true. Only poison THIS weapon graphic because 
-- poisoners dont always want to poison EVERY weapon. For example switch 
-- to a war fork on mobs that are immune.
--local WEAPON_GRAPHIC = 0x1405 -- Fork
--local WEAPON_GRAPHIC = 0x1401 -- Kryss
--local WEAPON_GRAPHIC = 0x0F52 -- dagger
local WEAPON_GRAPHIC = 0 -- ANY weapon

-- Auto bandage yourself or allies
-- Cooldown 10 seconds
local USE_BANDAGES = true

-- Will use bandages on friends defined in FRIEND_SERIALS below
local BANDAGES_ON_FRIENDS = true

-- A decimal representing percentage of a friend's health bar. Bandage healing will
-- only kick in if they are below this threshold, e.g. 0.9  (less than 90%)
local BANDAGE_FRIENDS_MIN_THRESHOLD_HP = 0.9

-- Heal damaged friend by their serial if they are close.
-- Only applicable when BANDAGES = true
local FRIEND_SERIALS = { 
    0x0046C66E, -- omg artie
    0x0012705D, -- omg arthur
    0x003A3990, -- omg arturo
    0x0012DDAB,  -- mr karl
    0x0013C547, -- Blood Draw
    0x00110988, -- fastball
    0x001DB49D, -- bash
    0x003EC94F, -- Bruenor te dwarf
    0x003B4020, -- jingle jangle
    0x0069B641, -- dead on arrival
    0x0040CC3E, -- lady lumps
    0x00466D56, -- pink floyd
    0x003D131B, -- xufu
}

-- Auto pop pouches
local USE_POUCHES = true

-- Primitive auto looter. Does not scavenge.
local AUTOLOOT = true

-- IF this is true and you have more than 20 discordance
local USE_DISCORD = true

-- If music is > 80, will cast this every X seconds
local USE_SONG_OF_HEALING = true

-- Recast song of healing every X ms
local SONG_OF_HEALING_RECAST = 188 * 1000

-- If music is > 80, will attempt to cast song of fortune
local USE_SONG_OF_FORTUNE = false

-- Number of ms to recast song of fortune. I think it's OK
-- to cast it often. Even if the buff lasts for 12 minutes, it is
-- OK to recast every minute just in case the cast fails you don't want to miss out
local SONG_OF_FORTUNE_RECAST = 120000

-- When script starts it finds your currently equipped weapon.
-- It will then check every few seconds to re-equip it if its not 
-- currently equipped.
local REEQUIP_WEAPON = true

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
    0x0EED,  -- Gold
    0x14EC,  -- Treasure Map
    0x573B,  -- Pigments
    --0x0EB2,  -- Lap Harp
    --0x0EB1,  -- Standing Harp
    --0x0EB3,  -- Lute
    --0x0E9D,  -- Tambourine
    --0x0E9E,  -- Tambourine
    --0x0E9C,  -- Drum
    0x0F26,  -- Diamond
    0x0F10,  -- Emerald
    0x0F16,  -- Amethyst
    0x0F10,  -- Emerald
    0x0F19,  -- Saphire
    0x0F25,  -- Amber
    0x0F13,  -- Ruby
    0x0000,  -- Daemon Scales
    --0x26B4,  -- Daemon Scales
    --0x0F7E,  -- Bones
    --0xFCA9,  -- Hardened Resin
    --0x318B,  -- Enchanted Bark
    0x0E21,  -- Clean Bandage
    0x0F8D,  -- Spider Silk
    0x0F86,  -- Mandrake Root
    0x0F8C,  -- Ash
    0x0F7B,  -- Blood Moss
    0x0F88,  -- Night Shade
    0x0F84,   -- Garlic
    0x0F7A,   -- Black Pearl
    0x0F85,   -- Ginseng
    0x0F3F,   -- Arrows
    0x1BFB,   -- Bolts
    -- (lowest priority)
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
}

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

            local v = cd.delay - (os.clock() - cd.clock) * 1000
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

            local cd = data[k] or { clock = os.clock() }
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
            if not Cooldown("FatAlert") then
                Messages.Overhead("too fat, big heavy .. no pick up " .. item.Name .. " (" .. tostring(weight) .. " stones)", 47, Player.Serial)
                Cooldown("FatAlert", 5000)
            end
            goto continue
        end

        Messages.Print("Found item " .. item.Name .. " in root container " .. item.RootContainer)

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

function UseBandage()
    if not USE_BANDAGES then return end
    if Cooldown("BandageSelf") then return end
    if Skills.GetValue("Healing") < 40 then return end

    local bandage = Items.FindByType(0x0E21)
    if not bandage then return end -- No bandages, no healing

    -- 1. Check Self First
    if Player.Hits < Player.HitsMax or Player.IsPoisoned then
            if Player.UseObject(bandage.Serial) then
                if Targeting.WaitForTarget(500) then
                    Targeting.TargetSelf()
                    -- Standard self-heal formula based on Dex
                    local selfDelay = (8.0 + 0.85 * ((130 - Player.Dex) / 20)) * 1100
                    Messages.Print("Healing self")
                    Cooldown("BandageSelf", selfDelay)
                    Pause(ACTION_DELAY)
                    return 
                end
            end
        return -- Prioritize self; exit if self-healing is needed/active
    end

    -- 2. Check Allies if Self is Healthy
    if BANDAGES_ON_FRIENDS then
        for _, serial in ipairs(FRIEND_SERIALS) do
            if serial == Player.Serial then
                goto continue
            end

            -- Find the mobile object for this serial
            local ally = Mobiles.FindBySerial(serial)
        
            -- Check if ally exists, is alive, in range (2 tiles), and missing > 10% HP
            if ally and ally.Hits > 0 and ally.Distance <= 1 then
                local hpPercent = (ally.Hits / ally.HitsMax)
            
                if hpPercent <= BANDAGE_FRIENDS_MIN_THRESHOLD_HP or ally.IsPoisoned then
                    if not Cooldown("BandageSelf") then -- Shares global bandage cooldown
                        if Player.UseObject(bandage.Serial) then
                            if Targeting.WaitForTarget(500) then
                                Targeting.Target(ally.Serial)
                                Player.Say("+ Healing " .. ally.Name .. " +", 67)
                                Cooldown("BandageSelf", 5000)
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
    return false
end

local mobileTarget = nil
local mobileTargetLast = nil
local mobileTargetHitpoints = math.huge
local checkRetarget = os.clock() + 1
--checkExplodePot = os.clock() + 1
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

        if autoAttackRed == false then
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

        if containsString(MOBS_TO_IGNORE, mobile.Name) then
            goto continue
        end

        if containsString(FRIEND_SERIALS, mobile.Serial) then
            goto continue
        end

        mobileTargetHitpoints = mobile.Hits
        mobileTarget = mobile
        --Messages.Print("Breaking")
        break

        ::continue::
        --Messages.Print("Continuing")
    end
    
    mobileTargetHitpoints = math.huge
    if mobileTarget ~= nil then
        if mobileTargetLast == nil or mobileTarget.Serial ~= mobileTargetLast.Serial or os.clock() > checkRetarget then
            mobileTargetLast = mobileTarget
            Messages.Print("Attacking... " .. mobileTarget.Name, 69, Player.Serial)
            Player.Attack(mobileTarget.Serial)
            checkRetarget = os.clock() + 3
            return mobileTarget
        end
    end

--    if mobileTarget ~= nil and Skills.GetValue("Alchemy") >= 100 and EXPLODE_POTS and os.clock() > checkExplodePot then
--        pots = Items.FindByID(0x0F0D, Player.Backpack.Serial)
--        pots = Items.FindByType(0x0F0D)

--        if pots ~= nil then
--            Messages.Print(pots.Serial)
--            Items.UseItem(pots.Serial)
--            Player.UseObjectByType(0x0E21)
--           Targeting.WaitForTarget(1000)
--            Targeting.Target(mobileTarget.Serial)
--            Messages.Print("Throwing Pot")
--       else
--            Messages.Print("You have no pots")
--        end
--
--        checkExplodePot = os.clock() + 5
--    end
end

checkPoison = os.clock() + 1
function ApplyPoison(mobileTarget)
    if not USE_POISONS then return end
    if not mobileTarget then return end
    if containsString(POISON_IMMUNE_MOBS, mobileTarget.Name) then return end
    if mobileTarget.IsPoisoned and SMART_POISONING then return end

    if os.clock() > checkPoison then
		wep = Items.FindByLayer(1)
		if wep ~= nil and wep.Properties ~= nil then
            if WEAPON_GRAPHIC ~= 0 and wep.Graphic ~= WEAPON_GRAPHIC then return end

			if string.find(wep.Properties, 'Poison') == nil then
				Messages.Overhead("You dont have poison", 44, Player.Serial)
				
				local poison = Items.FindByType(0x0F0A)
				if poison ~= nil then
					local weapon = Items.FindByLayer(1)
					if weapon ~= nil then
						Messages.Overhead("Using Poison", 44, Player.Serial)
						Skills.Use("Poisoning")
						Targeting.WaitForTarget(1000)
						Targeting.Target(poison.Serial)
						Targeting.WaitForTarget(1000)
						Targeting.Target(weapon.Serial)
					end
				end
            end
		else
			Messages.Overhead('Not applying poison', 34, Player.Serial)
		end    
		checkPoison = os.clock() + 3
	end
end

function AutoLoot()
    if AUTOLOOT then 
        local sortedItemList = GetSortedItemList()
        if #sortedItemList > 0 then
            Messages.Print("> " .. sortedItemList[1].Name, 69, Player.Serial)
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
    if Cooldown("Discord") then return end
    if Player.Hits < 40 then return end
    if Player.IsPoisoned then return end
    if not mobileTarget then return end
    if Skills.GetValue("Discordance") < 20 then return end
    if USE_SONG_OF_HEALING and not Cooldown("SongOfHealing") then return end

    local instrument 
    for i, graphicId in ipairs(INSTRUMENTS) do
        instrument = Items.FindByType(graphicId)
        if instrument ~= nil then break end
    end

    if not instrument then return end

    Journal.Clear()
    Spells.Cast('SongOfDiscordance')
    Targeting.WaitForTarget(1000)
    if Journal.Contains("What instrument shall you play?") then
        Targeting.Target(instrument.Serial)
        Targeting.WaitForTarget(1000)
    end
    Targeting.Target(mobileTarget.Serial)

    Cooldown("Discord", 7000)
    Pause(ACTION_DELAY)
end

function UseInflammablePots(targetMobile)
    if not USE_INFLAMMABLE_POTS then return end 
    if Skills.GetValue("Alchemy") < 90 then return end
    if Cooldown("UseInflammablePot") then return end
    if not targetMobile then return end

    local pot = Items.FindByType(0xFDB3)
    if not pot then return end -- No cure pots, no healing
    if pot.Container ~= Player.Backpack.Serial then return end -- sometimes pots may be on ground and far away

    Player.UseObject(pot.Serial)
    Targeting.WaitForTarget(1000)
    Targeting.Target(targetMobile.Serial)
    Cooldown("UseInflammablePot", 10000)
    Pause(ACTION_DELAY)
end

function UseSongOfHealing()
    if not USE_SONG_OF_HEALING then return end
    if Skills.GetValue("Musicianship") < 50 then return end
    if Cooldown("SongOfHealing") then return end
    if Player.Hits < 50 then return end

    local instrument 
    for i, graphicId in ipairs(INSTRUMENTS) do
        instrument = Items.FindByType(graphicId)
        if instrument ~= nil then break end
    end

    if not instrument then return end

    Journal.Clear()
    Spells.Cast('SongOfHealing')
    Targeting.WaitForTarget(1000)
    if Journal.Contains("What instrument shall you play?") then
        Targeting.Target(instrument.Serial)
        Targeting.WaitForTarget(1000)
    end

    Pause(ACTION_DELAY)

    if Journal.Contains("Your song creates a healing aura around you") then
        Cooldown("SongOfHealing", SONG_OF_HEALING_RECAST) -- 3:07
        Player.Say("+ Song of Healing +", 67)
    elseif Journal.Contains("You are already under the effects of this song") then
        Cooldown("SongOfHealing", 25 * 1000)
    end
end

function UseSongOfFortune()
    if not USE_SONG_OF_FORTUNE then return end
    if Skills.GetValue("Musicianship") < 50 then return end
    if Cooldown("SongOfFortune") then return end
    if Player.Hits < 50 then return end
    if USE_SONG_OF_HEALING and not Cooldown("SongOfHealing") then return end

    local instrument 
    for i, graphicId in ipairs(INSTRUMENTS) do
        instrument = Items.FindByType(graphicId)
        if instrument ~= nil then break end
    end

    if not instrument then return end

    Journal.Clear()
    Spells.Cast('SongOfFortune')
    Targeting.WaitForTarget(1000)
    if Journal.Contains("What instrument shall you play?") then
        Targeting.Target(instrument.Serial)
        Targeting.WaitForTarget(1000)
    end

    Cooldown("SongOfFortune", SONG_OF_FORTUNE_RECAST)
    Pause(ACTION_DELAY)
end

function PickupMushrooms(mobileTarget) 
    if not PICKUP_MUSHROOMS then return end
    if mobileTarget ~= nil then return end
    local shrooms = Items.FindByFilter({ graphics = MUSHROOM_GRAPHIC_ID, rangemax = 2, onground = true  })
    if #shrooms > 0 then
        Player.UseObject(shrooms[1].Serial)
        Messages.Overhead("OMG ", 37, shrooms[1].Serial)
        Pause(ACTION_DELAY)
    end
end

local oneHandedWeapon = nil
if REEQUIP_WEAPON then
    oneHandedWeapon = Items.FindByLayer(1)
    if oneHandedWeapon then
        Messages.Print("Found weapon: " .. oneHandedWeapon.Name)
    end
end

function ReequipWeapon()
    if not REEQUIP_WEAPON then return end
    if not oneHandedWeapon then return end
    if Items.FindByLayer(1) then return end
    if Cooldown("ReequipWeapon") then return end

    Player.Equip(oneHandedWeapon.Serial)
    Pause(ACTION_DELAY)
    Cooldown("ReequipWeapon", 1000)
end

Journal.Clear()
Messages.Print("Starting Dexmaster 5000")
while not Player.IsDead and not Player.IsHidden do
    Pause(1)
    targetMobile = AutoAttack()
    UseBandage()
    PopPouch()
    ApplyPoison(mobileTarget)
    UseInflammablePots(mobileTarget)
    UseDiscord(mobileTarget)
    UseSongOfHealing()
    UseSongOfFortune()
    ReequipWeapon()
    PickupMushrooms(mobileTarget)
    AutoLoot()
end