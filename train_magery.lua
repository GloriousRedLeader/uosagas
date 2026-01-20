------------------------------------------------------------------------------------
-- START OPTIONS for script that trains magery. This one is nice because it will 
-- use healing skill if you have it to save time and mana. Original author is aKKa
-- THis particular script also lets you train Eval int separately and detect hidden
-- I have no  idea why I put that in there. Will attempt to use healing if  you 
-- have bandages and healing > 30. 
-- by OMG Arturo
------------------------------------------------------------------------------------

-- Whether to train detect hidden for  whatever reason
local DETECT_HIDDEN = false

-- Whether to train in eval int as well using the skill
local EVAL_INT = false

-- If you want to train EVAL, then plug in a serial of something to evaluate.
local EVAL_INT_TARGET_SERIAL = 0x0046F6AD -- A bull somewhere near Moonvale

local magerySpells = {
--    { min = 70, spell = 'FlameStrike' },
    { min = 90, spell = 'Earthquake' },
    { min = 70, spell = 'ManaVampire' },
    { min = 50, spell = 'ManaDrain' },
    { min = 40, spell = 'Fireball' },
    { min = 0,  spell = 'Cure' }
}

------------------------------------------------------------------------------------
-- END OPTIONS 
-- by OMG Arturo
------------------------------------------------------------------------------------

local meditationMessages = {
    { value = 'You cannot focus your concentration', pause = 10000 },
    { value = 'You must wait a few moments to use another skill', pause = 1000 },
    { value = 'You stop meditation', pause = 100 },
    { value = 'You are at peace', pause = 100 }
}

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

-- Manages the meditation process to restore mana to full.
-- It handles various system messages until mana is at maximum.
function Meditate()
    while Player.Mana < Player.MaxMana do
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

-- Determines which healing spell to use based on missing health.
-- @return {string} 'GreaterHeal' if more than 10 HP is missing, otherwise 'Heal'.
function GetHealingSpellString()
    if Player.HitsMax - Player.Hits <= 20 then
        return 'Heal'
    else
        return 'GreaterHeal'
    end
end

-- Restores the player's health to maximum.
-- It will meditate if mana is low, then cast the appropriate healing spell on the player.
function HealSelf()
    while Player.Hits < Player.HitsMax do
    	local bandage = Items.FindByType(0x0E21)        
        if Skills.GetValue("Healing") > 30 and bandage then
			if  not Cooldown("BandageSelf") then
				if Player.UseObject(bandage.Serial) then
					if Targeting.WaitForTarget(500) then
						Targeting.TargetSelf()
						Cooldown("BandageSelf", (8.0 + 0.85 * ((130 - Player.Dex) / 20)) * 1100)
					end
				end        
			end
            Pause(800)
        else
           Spells.Cast(GetHealingSpellString())
            if Targeting.WaitForTarget(5000) then
               Targeting.Target(Player.Serial)
               Pause(800)
            end
        end
    end
end

-- Main training loop.
-- Continues until Magery skill reaches 100.
while Skills.GetValue('Magery') or Skills.GetValue('Resist') < 100 do
    Pause(50)
    if Player.Mana <= 40 or Journal.Contains('insufficient mana') then
        Meditate()
    end

    if Player.Hits < 80 then
        HealSelf()
    else
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

            if DETECT_HIDDEN then
                Skills.Use('Detecting Hidden')
                Targeting.WaitForTarget(1000)
                Targeting.TargetSelf()
                Pause(1500)
            end

            if EVAL_INT and EVAL_INT_TARGET_SERIAL then
                for i = 1, 10 do
                    Skills.Use("Evaluating Intelligence")   
                    Targeting.WaitForTarget(1000)
                    Targeting.Target(EVAL_INT_TARGET_SERIAL)
                    Pause(1000)
                end
            end
        end
    end
end