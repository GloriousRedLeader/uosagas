--[[
    UO Sagas

    OMG Arthur

    Item ID and sort Grimoires.

    Put all unidentified items in a container. Have a wand in your pack.
    This will identify all items in the container and put the garbage ones
    in your pack so you can sell them. The good ones will remain in container.

    Use the REQUIRED variables below to configure which types of things you want to keep.
    Right now this only works with Grimoires.
--]]

-- Instructions: Secure a chest in your house. Get the serial. Plug the serial in below.
-- Put a wand in your backpack. Put all the unidentified items in the chest. Press play.
-- It is a little weird. But eventually it will id everything. I think.

-- This is the container serial with all your items to identify
-- Use -info to get the serial.
local CONTAINER_SERIAL = 0x43787825

-- Add other weapons here. I think that would work. Not sure about armor though
-- since they have different modifier names.
local ITEM_IDS_TO_MUCK_WITH = {
    0x2D9D -- Grimoire
}

-- None (100 charges),
-- Durable (135 charges)
-- Substantial (170 charges)
-- Massive (205 charges)
-- Fortified (240 charges)
-- Indestructible (275 charges)
local REQUIRED_DURABILITY = { "Substantial", "Massive", "Fortified", "Indesructible" } 

-- None
-- enchanted (+5 eval)
-- supassingly enchanted (+10 eval)
-- eminently enchanted (+15 eval)
-- exeedingly enchanted (+20 eval)
-- supremly enchanted (+25 eval)
local REQUIRED_EVAL = { "Surpassingly", "Eminently", "Exceedingly", "Supremely" }

-- None
-- Ruin (10% more base damage)
-- Might (20% more base damage)
-- Force (30% more base damage)
-- Power (40% more base damage)
-- Vanq (50% more base damage)
local REQUIRED_DAMAGE = { "Might", "Force", "Power", "Vanquishing" } 

local ITEM_MOVE_DELAY_MS = 666

-- Lua doesn't have _in_array
local function has_value (tab, val)
    for index, value in ipairs(tab) do
        if value == val then
            return true
        end
    end

    return false
end

local function has_any_mod(itemName, mods)
    for _, mod in ipairs(mods) do
        if string.find(itemName, mod) then
            return true
        end
    end
    return false
end

local function get_wand()
	local items = Items.FindByFilter({ name = "Wand", container = False, hues = {0}	})
	for i, item in ipairs(items) do
		if item ~= nil and item.Name ~= nil and item.RootContainer == Player.Serial and not string.find(item.Properties, "Identification Charges: 0") then
			return item
		end
	end
	error("Stopping. You need a wand in backpack with charges")
end

Messages.Print('Opening Container')
Player.UseObject(CONTAINER_SERIAL)
Pause(1000)

for _, item in ipairs(Items.GetContainerItems(CONTAINER_SERIAL)) do
    if item ~= nil then
        if string.find(item.Name, "Unidentified") then
            Messages.Print(item.Name)  
            wand = get_wand()
    		Pause(100)      
            Player.UseObject(wand.Serial)
		    Targeting.WaitForTarget(750)
		    Targeting.Target(item.Serial)
		    Pause(1000)
        end
    end
end

for _, item in ipairs(Items.GetContainerItems(CONTAINER_SERIAL)) do
    if item ~= nil then
        if has_value(ITEM_IDS_TO_MUCK_WITH, item.Graphic) and not string.find(item.Name, "Unidentified") then
            if has_any_mod(item.Name, REQUIRED_DURABILITY)
                and has_any_mod(item.Name, REQUIRED_EVAL)
                and has_any_mod(item.Name, REQUIRED_DAMAGE) then
                
                Messages.Print("Found a really good item " .. item.Name, 77)

            else
                Messages.Print("Crap item " .. item.Name, 33)
                Player.PickUp(item.Serial)
                Pause(ITEM_MOVE_DELAY_MS)
                Player.DropInBackpack()
                Pause(ITEM_MOVE_DELAY_MS)
            end
        end
    end
end
