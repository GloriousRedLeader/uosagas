




--========= Magery & Resist Trainer ========--
-- Author: aKKa
-- Server: UO Sagas
-- Description: Trains Magery by casting spells on self. Also trains resisting spells.
--              Automatically meditates for mana and heals when low on health.
--==========================================--


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


local magerySpells = {
    { min = 70, spell = 'FlameStrike' },
    { min = 50, spell = 'ManaDrain' },
    { min = 40, spell = 'Fireball' },
    { min = 0,  spell = 'Cure' }
}

local meditationMessages = {
    { value = 'You cannot focus your concentration', pause = 10000 },
    { value = 'You must wait a few moments to use another skill', pause = 1000 },
    { value = 'You stop meditation', pause = 100 },
    { value = 'You are at peace', pause = 100 }
}



-- Determines which healing spell to use based on missing health.
-- @return {string} 'GreaterHeal' if more than 10 HP is missing, otherwise 'Heal'.
function GetHealingSpellString()
    if Player.HitsMax - Player.Hits <= 20 then
        return 'Heal'
    else
        return 'GreaterHeal'
    end
end



function Crane()


    while Player.Hits < Player.HitsMax or Player.Mana < Player.MaxMana do

	
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

		Pause(1000)	
	
		if Player.Mana < Player.MaxMana then
			Journal.Clear()
			Skills.Use('Meditation')
			Pause(10000)
			for _, message in ipairs(meditationMessages) do
				if Journal.Contains(message.value) then
					if message.value == 'You are at peace' then
						return
					else
						Pause(message.pause)
						Skills.Use('Meditation')
					end
				end
			end
		end
		
    end


end

-- Main training loop.
-- Continues until Magery skill reaches 100.
while Skills.GetValue('Magery') or Skills.GetValue('Resist') < 100 do
    Pause(50)
    --if Player.Mana <= 40 or Journal.Contains('insufficient mana') then
    --    Meditate()
    --end

    Crane()
	
	currentMagery = Skills.GetValue('Magery')
	for _, data in ipairs(magerySpells) do
		if currentMagery >= data.min then
			Spells.Cast(data.spell)
			break
		end
	end

	if Targeting.WaitForTarget(5000) then
		Targeting.Target(Player.Serial)
		Pause(800)
	end
    
end
