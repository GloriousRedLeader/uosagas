checkPoison = os.clock() + 1
ATTACK = true
HEAL_FRIEND_SERIAL=0x003AA6A5 -- gkg
--HEAL_FRIEND_SERIAL=0x003A3990 --omg arturo
while not Player.IsDead do


    if ATTACK then
        Messages.Print("OMG")
        filter = {rangemax=3, notorieties={0, 4, 3, 5}}

        list = Mobiles.FindByFilter(filter)
        if #list > 0 then
            Player.Attack(list[1].Serial)
            Pause(500)
        end

       
    end

--	friend = Mobiles.FindByName('gkg')
    --friend = Mobiles.FindBySerial(0x003AA6A5)
    friend = Mobiles.FindBySerial(HEAL_FRIEND_SERIAL) 
	if friend ~= nil and friend.Hits ~= nil and friend.HitsMax ~= nil and friend.HitsMax - friend.Hits > 2 and friend.Distance < 2 then
		local bandage = Items.FindByType(0x0E21)
        if bandage ~= nil then
            if Player.UseObject(bandage.Serial) then
                if Targeting.WaitForTarget(1500) then
					Targeting.Target(friend.Serial)
                    Pause(1500)
                    Skills.Use('Hiding')
					Pause(4500)
                end
            end
        end
	end
	Pause(1000)

 

	
	if false and os.clock() > checkPoison then
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