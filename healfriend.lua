checkPoison = os.clock() + 1
while not Player.IsDead do
	friend = Mobiles.FindByName("gkg")
	if friend ~= nil and friend.HitsMax - friend.Hits > 5 then
		local bandage = Items.FindByType(0x0E21)
        if bandage then
            if Player.UseObject(bandage.Serial) then
                if Targeting.WaitForTarget(500) then
					Targeting.Target(friend.Serial)
					Pause(6000)
                end
            end
        end
	end
	Pause(1000)
	
	if true and os.clock() > checkPoison then
		wep = Items.FindByLayer(1)
	--	Messages.Print('omg' .. tostring(Player.Serial))
		if wep ~= nil and wep.Properties ~= nil then
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
				
				
				
			else
--				Messages.Overhead("You do have poison", 74, Player.Serial)
			end
				
		else
			Messages.Overhead('NO WEAPON found', 34, Player.Serial)
		end    
		checkPoison = os.clock() + 3
	end
end