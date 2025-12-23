local graphicLootbag = 0x0E79
local actionDelay = 550             -- Milliseconds of delay between actions
local autoAttackRed = true         -- Auto attack reds
local POISONS = true
local AUTOLOOT = true
local BANDAGES = true
local WEAPON_GRAPHIC = 0x1405

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
   -- 0x0F3F   -- Arrows
    -- (lowest priority)
}





--XX--XX--XX--XX--XX--XX--XX--XX--XX--XX--XX--XX--XX--XX--XX--XX--





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
--function GetSortedItemList(lootbag)
function GetSortedItemList()
    local seriableIdLootPriorityList = {}
    local itemList = Items.FindByFilter({})
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
--healingEnabled = true
healingActive = false
lastHealTime = 0
healCooldown = 12500
function AutoHeal()
    local currentTime = os.time() * 1000
    --if healingEnabled and Player.Hits < 100 and not healingActive then
    if BANDAGES and (Player.Hits < Player.HitsMax or Player.IsPoisoned) and not healingActive then
        if Player.UseObjectByType(0xE21) then
            if Targeting.WaitForTarget(5000) then
                Targeting.TargetSelf()
                healingActive = true
                lastHealTime = currentTime
            end
        end
    end

    if healingActive and (currentTime - lastHealTime >= healCooldown) then
        healingActive = false
    end
    
    if scavengeEnabled and healingActive == false then
	    filter = {onground=true, rangemax=2, graphics=itemsToSearchFor}
	    
	    list = Items.FindByFilter(filter)
	    for index, item in ipairs(list) do
	        Player.PickUp(item.Serial, 1000)
	        Pause(100)
	        Player.DropInBackpack()
	        Pause(100)
	    end
	    -- Important Pause for CPU
	    Pause(150)
    end

    Pause(50)
end

-----------------------------------------------------------------
local mobileTarget = nil
local mobileTargetLast = nil
local mobileTargetHitpoints = math.huge
function AutoAttack()
    local mobileList = Mobiles.FindByFilter({})
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
--Messages.Print("Auto looter started...", 69, Player.Serial)

Journal.Clear()

--local lootbag = Items.FindByType(graphicLootbag)
--local lootbag = Player.Backpack
--local lootbag = Items.FindBySerial(Player.Backpack.Serial)
--if lootbag == nil then
--    Messages.Print("No lootbag found!", 69, Player.Serial)
--else
--    Messages.Print("Lootbag found!", 69, Player.Serial)
--end


while true do
    Pause(1)
    AutoAttack()
    AutoHeal()
    ApplyPoison()
    AutoLoot()
    --local corpse = FindCorpse()
    --if corpse ~= nil then
    --    Player.UseObject(corpse.Serial)
    --    Pause(actionDelay)
   --     IgnoreCorpse(corpse.Serial)
   -- end
--    local sortedItemList = GetSortedItemList(lootbag)
    
--    if AUTOLOOT then 
--        local sortedItemList = GetSortedItemList()
--        if #sortedItemList > 0 then
--            Messages.Print("> " .. sortedItemList[1].Name, 69, Player.Serial)
--            Player.PickUp(sortedItemList[1].Serial, sortedItemList[1].Amount)
--        Player.DropInContainer(lootbag.Serial)
--        Player.DropInContainer(Player.Backpack.Serial)
--            Player.DropInBackpack()

--            Pause(actionDelay)
--        end
--    end
    --if Journal.Contains('You must wait a few') ~= true then
    --   Journal.Clear()
	--   Skills.Use('Hiding')
    --   Pause(3000)
    --end
end