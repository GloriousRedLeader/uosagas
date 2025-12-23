local mortarUsed = false  -- Track if mortar and pestle has been used already
checkHeal = os.clock() + 1
HEAL_FRIEND_SERIAL = 0x003A3990 --omg arturo
--HEAL_FRIEND_SERIAL=0x003AA6A5 -- gkg
while true do
    -- Open Menu
    if not mortarUsed then
        local mortar = Items.FindByType(0x0E9B)
        if mortar then
            Player.UseObject(mortar.Serial)
            Messages.Print("Using mortar and pestle to open the gump...")
            Pause(500)  -- Brief pause to ensure the mortar and pestle is used
            mortarUsed = true  -- Mark the mortar as used
        else
            Messages.Print("Mortar and pestle not found!")
        end
    end
    
    -- Press the "Create Last" button to craft the item
    Gumps.PressButton(2653346093, 21)
    
    -- Wait for the gump
    Gumps.WaitForGump(2653346093, 1000)
    
    -- Brief pause to ensure proper timing before proceeding
    Pause(500)

    -- Scan the journal for "You have worn out your tool!"
    if Journal.Contains("You have worn out your tool!") then
        -- Double-click the mortar and pestle (ID 0x0E9B)
        local mortar = Items.FindByType(0x0E9B)
        if mortar then
            Player.UseObject(mortar.Serial)
            Messages.Print("Using a new mortar and pestle...")
            Pause(500)  -- Brief pause to ensure it is used
            mortarUsed = false  -- Reset the mortar usage flag
        else
            Messages.Print("Mortar and pestle not found!")
        end
        
        -- Clear the journal to avoid repeatedly seeing the same message
        Journal.Clear()
        
        -- Restart the loop after handling the worn-out tool
        Messages.Print("Restarting the script...")
        Pause(1000) 
    end

    -- Wait
    Pause(500)

	if HEAL_FRIEND_SERIAL ~= nil then 
		friend = Mobiles.FindBySerial(HEAL_FRIEND_SERIAL) -- omg arturo
		if friend ~= nil and friend.Hits ~= nil and friend.HitsMax ~= nil and friend.HitsMax - friend.Hits > 2 and os.clock() > checkHeal then
			local bandage = Items.FindByType(0x0E21)
			if bandage ~= nil then
				if Player.UseObject(bandage.Serial) then
					if Targeting.WaitForTarget(1500) then
						Targeting.Target(friend.Serial)
						checkHeal = os.clock() + 4
					end
				end
			end
		end
	end
	
	Pause(500)

end	