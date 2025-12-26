
------------------------------------------------------------------------------------
-- START OPTIONS for AUTO DEXER / ARCHER / HEALER / AUTOLOOTER / POUCHPOPPER
-- by OMG Arturo
------------------------------------------------------------------------------------

-- Milliseconds of delay between actions
local actionDelay = 550             

-- Will auto attack monsters so you dont have too. Warning: Will
-- attack grays and reds  if you configure it!
local AUTO_ATTACK = true

-- When AUTO_ATTACK = true, this will attack red players and MOBS!
local AUTO_ATTACK_REDS = true        

-- When AUTO_ATTACK = true, this will NOT attack demons because mages.
local SKIP_DEMONS = true

-- Auto apply poison to blade to WEAPON_GRAPHIC.
local POISONS = true

-- Required when POISONS = true. Only poison THIS weapon graphic because 
-- poisoners dont always want to poison EVERY weapon. For example switch 
-- to a war fork on mobs that are immune.
--local WEAPON_GRAPHIC = 0x1405 -- Fork
local WEAPON_GRAPHIC = 0x1401 -- Kryss

-- Whether to heal self (or friends if serial is provided below)
local BANDAGES = true

-- Heal damaged friend by their serial if they are close.
-- Only applicable when BANDAGES = true
local FRIEND_SERIALS = { 0x0046C66E, 0x0012705D }

-- Auto pop pouches
local POUCHES = true

-- Primitive auto looter. Does not scavenge.
local AUTOLOOT = true

-- Auto looter, add graphic ids here. Only applies when AUTOLOOT = true
local graphicIdLootableItemPriorityList = 
{
    -- (highest priority)
    0xFDAD,  -- Eren Coin
    0x0E73,  -- Skill Cap Ball
    0xFD8F,  -- Mastery Gem
    0xFD8C,  -- Soul
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
    0x0F3F   -- Arrows
    -- (lowest priority)
}

------------------------------------------------------------------------------------
-- END OPTIONS for AUTO DEXER / ARCHER / HEALER / AUTOLOOTER / POUCHPOPPER
-- by OMG Arturo
------------------------------------------------------------------------------------

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

local graphicIdLootableSet = {}
local graphicIdToPriority = {}
for i, graphic in ipairs(graphicIdLootableItemPriorityList) do
    graphicIdLootableSet[graphic] = true
    graphicIdToPriority[graphic] = i
end

-----------------------------------------------------------------
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
-----------------------------------------------------------------
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
-----------------------------------------------------------------
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

        if container == nil or container.Name == nil or string.find(container.Name:lower(), "corpse") == nil then
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
-----------------------------------------------------------------

function AutoHeal()

    if Cooldown("BandageSelf") then
        return
    end

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
                end
            end
        return -- Prioritize self; exit if self-healing is needed/active
    end

    -- 2. Check Allies if Self is Healthy
    for _, serial in ipairs(FRIEND_SERIALS) do
        -- Find the mobile object for this serial
        local ally = Mobiles.FindBySerial(serial)
        
        -- Check if ally exists, is alive, in range (2 tiles), and missing > 10% HP
        if ally and ally.Hits > 0 and ally.Distance <= 1 then
            local hpPercent = (ally.Hits / ally.HitsMax) * 100
            
            if hpPercent <= 90 or ally.IsPoisoned then
                if not Cooldown("BandageSelf") then -- Shares global bandage cooldown
                    if Player.UseObject(bandage.Serial) then
                        if Targeting.WaitForTarget(500) then
                            Targeting.Target(ally.Serial)
                            Messages.Print("Healing Friend " .. ally.Name)
                            -- Use the specific 4-second ally cooldown (4000ms)
                            Cooldown("BandageSelf", 5000)
                            break -- Heal one person at a time
                        end
                    end
                end
            end
        end
    end
end



function AutoHeal3()

    if BANDAGES then
        if Player.Hits < Player.HitsMax or Player.IsPoisoned then
            local bandage = Items.FindByType(0x0E21)
            if bandage and not Cooldown("BandageSelf") then
                if Player.UseObject(bandage.Serial) then
                    if Targeting.WaitForTarget(500) then
                        Targeting.TargetSelf()
                        Cooldown("BandageSelf", (8.0 + 0.85 * ((130 - Player.Dex) / 20)) * 1100)
                    end
                end
            end
       
            
        end
    end
end

-----------------------------------------------------------------

local function compareByDistance(a, b)
    -- This function must return true if 'a' should precede 'b'
    -- (i.e., if 'a's distance is less than 'b's distance for ascending order)
    return a.Distance < b.Distance
end

local mobileTarget = nil
local mobileTargetLast = nil
local mobileTargetHitpoints = math.huge
function AutoAttack()
    if not AUTO_ATTACK then
        return 
    end
    local mobileList = Mobiles.FindByFilter({})
    table.sort(mobileList, compareByDistance)
    for index, mobile in ipairs(mobileList) do
        local mobile = mobileList[index]
        if mobile == nil then
            goto continue
        end

        if mobile.Distance == nil then
            goto continue
        else
            if mobile.Distance > 5 then
                goto continue
            end
        end

        if autoAttackRed == false then
            if mobile.NotorietyFlag == "Murderer" then
                goto continue
            end
        end

        if mobile.NotorietyFlag == "Innocent" or mobile.NotorietyFlag == "Ally" or mobile.NotorietyFlag == "Invulnerable" then
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
        ::continue::
    end
    
    mobileTargetHitpoints = math.huge
    if mobileTarget ~= nil then
        if mobileTargetLast == nil or mobileTarget.Serial ~= mobileTargetLast.Serial then
            mobileTargetLast = mobileTarget
            Messages.Print("Attacking...", 69, Player.Serial)
            Player.Attack(mobileTarget.Serial)
        end
    end
end
-----------------------------------------------------------------
checkPoison = os.clock() + 1
function ApplyPoison()
    if POISONS and os.clock() > checkPoison then
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

-----------------------------------------------------------------
function AutoLoot()
    if AUTOLOOT then 
        local sortedItemList = GetSortedItemList()
        if #sortedItemList > 0 then
            Messages.Print("> " .. sortedItemList[1].Name, 69, Player.Serial)
            Player.PickUp(sortedItemList[1].Serial, sortedItemList[1].Amount)
            Player.DropInBackpack()
            Pause(actionDelay)
        end
    end
end
-----------------------------------------------------------------
function PopPouch()
   if POUCHES and Player.IsParalyzed then
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
-----------------------------------------------------------------

Journal.Clear()
Messages.Print("Starting Dexmaster 5000")
--while true do
while not Player.IsDead and not Player.IsHidden do
    Pause(1)
    AutoAttack()
    AutoHeal()
    PopPouch()
    ApplyPoison()
    AutoLoot()
end