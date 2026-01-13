------------------------------------------------------------------------------------
-- START OPTIONS for 
--    Thiefmaster 5000 by omg arturo
--    Stand near a player. Press one button. Steal something.
--    To enable stealing from players you need to be in the thieves guild.
--    To do that you need to have 48 hours logged into the character and have stealing higher than 80.
--    Go to bucks den and type something like 'Perry join'
-- by OMG Arturo
------------------------------------------------------------------------------------

-- Actually do stealing. Should be on when you're ready.
-- Otherwise just helpful for debugging if false
STEAL_ENABLED = false

-- TODO: Steal first item you see for whatever reason
STEAL_FIRST = false

-- When searching 
POP_TRAPPED_POUCHES = false

-- How heavy of items you want to try to steal
MAX_WEIGHT = 10

-- IF a player has more bags and pouches in their backpack, also look in those.
-- Will avoid trapped pouches unless you specifically enable it above.
SCAN_SUB_CONTAINERS = true

-- Graphics for searchable subcontainers
SUB_CONTAINERS = {
    0x0E79, -- Pouch Graphic
    0x0E75 -- Backpack Graphic
}

-- Graphic ID, Name
-- Ordered most important to least important.
-- Use the "*" symbol to match anything with that graphic id
gazer_statuette = 0x20F4
gem = 0xFD8F
soul_gem = 0xFD8C
skill_scroll = 0xFF3A
STEAL_PRIORITY = {
    { gazer_statuette, "*" },
    { gem, "Poisoning Mastery Gem" },
    { gem, "Eval Int Mastery Gem" },
    { gem, "Meditation Mastery Gem" },
    { gem, "Fencing Mastery Gem" },
    { gem, "Base Mastery Gem" },
    { gem, "Resist Mastery Gem" },
    { gem, "Alchemy Mastery Gem" },
    { skill_scroll, "Poisoning" },
    { gem, "*" },
    { soul_gem, "*" },
    { skill_scroll, "*" }
}

------------------------------------------------------------------------------------
-- END OPTIONS 
-- by OMG Arturo
------------------------------------------------------------------------------------

-- Buffer for items to steal when scanning backpacks
potential = {}

-- Lua doesn't have _in_array
local function has_value (tab, val)
    for index, value in ipairs(tab) do
        if value == val then
            return true
        end
    end

    return false
end

-- Parse item.Properties for a weight. Note that some items
-- like the gazer statuette rare don't have weight (it does have Properties though)
local function get_weight(text)
    if text == nil then
        return 0
    end

    local weight = string.match(text, "Weight:%s*(%d+)")
    if weight == nil then
        return 0
    end
    return tonumber(weight)
end

-- Is the item a sub container
local function is_container(item)
    return has_value(SUB_CONTAINERS, item.Graphic)
end

-- Adds items to steal to our potential list. When we're all done
-- The script will prioritize the items by the configuration above.
-- See STEAL_PRIORITY
local function add_to_potential(item)
    for index, p in ipairs(STEAL_PRIORITY) do 
        if item.Properties ~= nil then
            --Messages.Print(item.Properties)
            weight = get_weight(item.Properties)
            --Messages.Print(weight)
            if p[1] == item.Graphic  and weight <= MAX_WEIGHT then  
               -- Messages.Print(p[2])         
                if string.find(p[2], item.Name) or p[2] == "*" then
                    --Messages.Print("ITEM P0 " .. tostring(p[0]))
                    table.insert(potential, { rank =  index, serial = item.Serial, name = item.Name, weight = weight })
                    return true
                end
            end
        end
    end
    return false
end

-- Scans containers recursively
local function scan_container(serial)
    Player.UseObject(serial)
    Pause(650)
    items = Items.FindInContainer(serial)
    for _, item in ipairs(items) do
       -- Messages.Print(tostring(item.Container))
        if add_to_potential(item) then
            --Messages.Print(' Should steal ' .. item.Name .. ' ')
            --Messages.Print('Weight: ' .. tostring(get_weight(item.Properties)))
            --table.insert(potential, item.Serial)
        elseif is_container(item) and SCAN_SUB_CONTAINERS then
            if item.Hue == 0x0025 and POP_TRAPPED_POUCHES then
                Player.UseObject(item.Serial)
                Pause(650)
                scan_container(item.Serial)
            elseif item.Hue ~= 0x0025 then
                scan_container(item.Serial)                
            end
        end
    end
end

-- This is the magic sauce. We can get all containers around use including
-- player backpacks this way.
filter = {onground=false, graphics=0x0E75, rangeMax= 1}
backpacks = Items.FindByFilter(filter)
for _, backpack in ipairs(backpacks) do
    if backpack.Serial ~= Player.Backpack.Serial then
        if backpack.RootContainer ~= Nil then -- Should be other player's serial
            victim = Mobiles.FindBySerial(backpack.RootContainer)
            if victim ~= nil and has_value({'Innocent', 'Criminal', 'Murderer'}, victim.NotorietyFlag)  then
                scan_container(backpack.Serial)
            end
        end

    end
end

-- We've finished scanning the target. Now steal something.
if #potential > 0 then
    --Messages.Print("Found things to steal!")
    --Messages.Print(tostring(#potential))

   -- Messages.Print("Before")
    --for index, item in ipairs(potential) do
    --    Messages.Print(tostring(index) .. " " .. tostring(item.rank) .. " " .. item.name)

--    end
    --Messages.Print("After")
    table.sort(potential, function(a, b)
        return a.rank < b.rank
    end)
    for index, item in ipairs(potential) do
        Messages.Print(tostring(index) .. " " .. tostring(item.rank) .. " " .. item.name)
    end
    itemToSteal = potential[1]
    Messages.Print("Going to steal " .. itemToSteal.name .. " Rank " .. tostring(itemToSteal.rank) .. " " .. tostring(itemToSteal.weight) .. " stones", 30)
    Messages.Overhead("Going to steal " .. itemToSteal.name .. " Rank " .. tostring(itemToSteal.rank) .. " " .. tostring(itemToSteal.weight) .. " stones", 30)

    if STEAL_ENABLED then
        Skills.Use("Stealing")
        Targeting.WaitForTarget(1000)
        Targeting.Target(itemToSteal.serial)
    end
end
Messages.Print("Done")

-- 77 = green
-- 57 = yellowish
-- 37 = dark red
-- 30 = legible pinkred