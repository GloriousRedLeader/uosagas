--[[
    UO Sagas

    OMG Arthur

    Lootmaster 5000 by omg arturo
    WIP
--]]

-- 0x2203

-- Adjust based on latency
PAUSE_DELAY_MS = 150

LOOT_ITEM_DELAY_MS = 666

-- Add graphics of items you want to loot in order of priority
ITEMS_TO_LOOT = {
    0x0E21, -- Bandage
    0x0EED, -- Gold
    0x0F3F, -- arrow
    0x1BFB, -- bolt
}

--corpseCache = {}

-- Gives us the priority of this item.
-- Returns 0 if no match (lua is 1 based index)
local function get_loot_rank (tab, val)
	for index, value in ipairs(tab) do
		if value == val then
			return index
		end
	end

	return 0
end

--Lua doesn't have _in_array
local function has_value (tab, val)
    for index, value in ipairs(tab) do
        if value == val then
            return true
        end
    end

    return false
end

local Cache = {}
Cache.__index = Cache

function Cache.new(max_size)
    return setmetatable({
        list = {},        -- ordered list (FIFO)
        set = {},         -- value → true (for fast lookup)
        max_size = max_size
    }, Cache)
end

function Cache:push(value)
    if not self.set[value] then
        table.insert(self.list, value)
        self.set[value] = true

        if #self.list > self.max_size then
            local removed = table.remove(self.list, 1)
            self.set[removed] = nil
        end
    end
end

function Cache:exists(value)
    return self.set[value] ~= nil
end

function Cache:pop()
    local removed = table.remove(self.list, 1)
    if removed then self.set[removed] = nil end
    return removed
end

function Cache:print()
    for i, v in ipairs(self.list) do
        print(i, v)
    end
end

local cache = Cache.new(50)

while not Player.IsDead do

	-- Store junk we find in corpses here so we can sort it and then loot 
	-- the high priority stuff first
	lootBuffer = {}


	--lastTarget = Tar

	filter = {onground=true, container=true, corpse=true, rangemax=2}

	corpses = Items.FindByFilter(filter)
	for _, corpse in ipairs(corpses) do
        if not cache:exists(corpse.Serial) then
            
            cache:push(corpse.Serial)

		--Messages.Print('Found item at location x:'..item.X..' y:'..item.Y..' '..item.Name .. ' hue = ' .. item.Hue)
		--if corpse.Properties ~= nil then
		 --   Message.Print(corpse.Properties)
		--end
		--Messages.Print(corpse.Hue)

		    Messages.Print(corpse.Name .. " is " .. tostring(corpse.IsLootable))

		    Player.UseObject(corpse.Serial)
            Gumps.WaitForGump(0, 1000)
    		Pause(LOOT_ITEM_DELAY_MS)

	    	items = Items.FindInContainer(corpse.Serial)
    		for i, item in ipairs(items) do
			    lootRank = get_loot_rank(ITEMS_TO_LOOT, item.Graphic)
    			if lootRank > 0 then
				    --Messages.Print(tostring(i) .. ' ' .. item.Name .. " ... " .. item.Amount)
    				table.insert(lootBuffer, { serial = item.Serial, rank = lootRank, name = item.Name})
			    end
    		end

    	end
    end

    if #lootBuffer > 0 then
        --Messages.Print("Items to Loot")
       	table.sort(lootBuffer, function(a, b)
        	return a.rank < b.rank
    	end)

	    for i, item in ipairs(lootBuffer) do
    		Player.PickUp(item.serial)
            Pause(666)
    		Player.DropInBackpack()
    		Pause(LOOT_ITEM_DELAY_MS * 2)
    		Messages.Print("#" .. item.rank .. " " .. item.name)
    	end
    end

    Pause(PAUSE_DELAY_MS * 2)
end
-- mb - 0x00481E39
-- corpse 0x4720834F