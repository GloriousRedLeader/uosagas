------------------------------------------------------------------------------------
-- START OPTIONS for AUTO DEXER / ARCHER / HEALER / AUTOLOOTER / POUCHPOPPER / POISON
-- by OMG Arturo
------------------------------------------------------------------------------------

-- Milliseconds of delay between actions
local ACTION_DELAY = 550

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
local POISONS = true

-- Required when POISONS = true. Only poison THIS weapon graphic because 
-- poisoners dont always want to poison EVERY weapon. For example switch 
-- to a war fork on mobs that are immune.
--local WEAPON_GRAPHIC = 0x1405 -- Fork
local WEAPON_GRAPHIC = 0x1401 -- Kryss

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
    0x0040CC3E, -- lady lumps
    0x00466D56, -- pink floyd
    0x003D131B, -- xufu
}

-- Auto pop pouches
local USE_POUCHES = true

-- Primitive auto looter. Does not scavenge.
local AUTOLOOT = false

-- IF this is true and you have more than 20 discordance
local USE_DISCORD = true

-- Auto looter, add graphic ids here. Only applies when AUTOLOOT = true
local graphicIdLootableItemPriorityList = 
{
    -- (highest priority)
    0xFDAD,  -- Eren Coin
    0x0F91,  -- Fragment
    0x0E73,  -- Skill Cap Ball
    0xFD8F,  -- Mastery Gem
    0xFD8C,  -- Soul
    0x2BF7,  -- Mystic Crafting Material
    0xFF3A,  -- Skill Scroll 
    0x9FF8,  -- Paragon Chest
    0x9FF9,  -- Paragon Chest
    --0x2D9D,  -- Grimoire
    0x573B,  -- Pigments
    0x0EED,  -- Gold
    0x0F26,  -- Diamond
    0x0F13,  -- Ruby
    0x0F16,  -- Amethyst
    0x0F10,  -- Emerald
    0x0F19,  -- Saphire
    0x0F25,  -- Amber
    0x0E21,  -- Bandage
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
--    0x1401    -- Kryss
    -- (lowest priority)
}

------------------------------------------------------------------------------------
-- END OPTIONS 
-- by OMG Arturo
------------------------------------------------------------------------------------

local POISON_IMMUNE_MOBS = {
    "a wanderer of the void",
    "a crystal elemental",
    "a dread spider",
    "a lost soul",
}

local INSTRUMENTS = {
    0x0E9C, -- DRUM
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
                                Messages.Print("Healing Friend " .. ally.Name)
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

        if SKIP_DEMONS and mobile.Graphic == 0x0009 then
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
    if not POISONS then return end
    if not mobileTarget then return end
    if containsString(POISON_IMMUNE_MOBS, mobileTarget.Name) then return end
    if mobileTarget.IsPoisoned then return end

    if os.clock() > checkPoison then
		wep = Items.FindByLayer(1)
		if wep ~= nil and wep.Properties ~= nil and wep.Graphic == WEAPON_GRAPHIC then
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
			Messages.Overhead('NO WEAPON found', 34, Player.Serial)
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
    AutoLoot()
end