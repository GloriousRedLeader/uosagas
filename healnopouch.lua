Messages.Overhead('Healing Started', 34)
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

checkPoison = os.clock() + 1
while not Player.IsDead do
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
	

    Pause(250)
    
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
