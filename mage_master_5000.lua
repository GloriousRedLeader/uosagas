------------------------------------------------------------------------------------
-- START OPTIONS for Mage script
-- 1. Smart heal (heal or g heal)
-- 2. Cures via pots or an nox or bandages
-- 3. Pops pouches
-- 4. Uses bandages
-- by OMG Arturo
------------------------------------------------------------------------------------

-- Auto pop pouches
-- Broken here because casting spells is considered paralyzed.
local USE_POUCHES = false

-- Smart healing will use lesser heal vs greater heal.
-- Requires at least 70 magery or it does nothing.
local USE_HEAL_SPELLS = true

-- Whether to use magery Heal and Greater heal on friends defined in FRIEND_SERIALS. Will always
-- prioritize your own safety over theirs.
local HEAL_SPELLS_ON_FRIENDS = true

-- A decimal representing percentage of a friend's HP. If their health is below this, and
-- you yourself are not poisoned or at low health,then it will attempt to heal friends
local HEAL_SPELL_FRIENDS_MIN_THRESHOLD_HP = 0.85

-- Auto bandage yourself or allies
-- Cooldown 10 seconds
local USE_BANDAGES = true

-- Will use bandages on friends defined in FRIEND_SERIALS below
local BANDAGES_ON_FRIENDS = true

-- A decimal representing percentage of a friend's health bar. Bandage healing will
-- only kick in if they are below this threshold, e.g. 0.9  (less than 90%)
local BANDAGE_FRIENDS_MIN_THRESHOLD_HP = 0.9

-- Whether to use heal pots if you got them
-- Cooldown: 10 seconds
local USE_HEAL_POTS = true

-- A decimal representing percentage of your health bar. Will only use heal pot
-- if less than this threshold, e.g. 0.4 (less than 40% hp) 
local HEAL_POT_MIN_THRESHOLD_HP = 0.4

-- Uses these over an nox spell. Will spam them until cured if they are in pack. Otherwise
-- will attempt to use arch cure (below)
-- Cooldown: None
local USE_CURE_POTS = true

-- Attempts to use the an nox spell if you don't have any cure pots or USE_CURE_POTS = false.
-- Requires 11 mana, and the target to be in three tiles and over 70 magery.
local USE_CURE_SPELL = true

-- Attempts to cure friends defined in FRIEND_SERIALS if they are within 3 tiles.
-- Only applies when USE_CURE_SPELL is true.
local CURE_SPELL_ON_FRIENDS = true

-- Bandage / cast heals on damaged friends by their serial if they are in frange.
-- Only applies when any of the following are enabled:
-- CURE_SPELL_ON_FRIENDS, BANDAGES_ON_FRIENDS, HEAL_SPELLS_ON_FRIENDS
local FRIEND_SERIALS = { 
    0x0046C66E, -- omg artie
    0x0012705D, -- omg arthur
    0x003A3990, -- omg arturo
    0x0012DDAB,  -- mr karl
    0x0013C547, -- Blood Draw
}

-- Milliseconds of delay between actions adjust for your latency
local ACTION_DELAY = 750

------------------------------------------------------------------------------------
-- END OPTIONS 
-- by OMG Arturo
------------------------------------------------------------------------------------

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

function UseBandage()
    if not USE_BANDAGES then return end
    if Cooldown("BandageSelf") then return end
    if Skills.GetValue("Healing") < 40 then return end

    local bandage = Items.FindByType(0x0E21)
    if not bandage then return end -- No bandages, no healing

    -- 1. Check Self First
    if Player.Hits < Player.HitsMax or Player.IsPoisoned then
            if Player.UseObject(bandage.Serial) then
                if Targeting.WaitForTarget(500) then
                    Targeting.TargetSelf()
                    -- Standard self-heal formula based on Dex
                    local selfDelay = (8.0 + 0.85 * ((130 - Player.Dex) / 20)) * 1100
                    Messages.Print("Healing self")
                    Cooldown("BandageSelf", selfDelay)
                    Pause(ACTION_DELAY)
                    return 
                end
            end
        return -- Prioritize self; exit if self-healing is needed/active
    end

    -- 2. Check Allies if Self is Healthy
    if BANDAGES_ON_FRIENDS then
        for _, serial in ipairs(FRIEND_SERIALS) do
            if serial == Player.Serial then
                goto continue
            end

            -- Find the mobile object for this serial
            local ally = Mobiles.FindBySerial(serial)
        
            -- Check if ally exists, is alive, in range (2 tiles), and missing > 10% HP
            if ally and ally.Hits > 0 and ally.Distance <= 1 then
                local hpPercent = (ally.Hits / ally.HitsMax)
            
                if hpPercent <= BANDAGE_FRIENDS_MIN_THRESHOLD_HP or ally.IsPoisoned then
                    if not Cooldown("BandageSelf") then -- Shares global bandage cooldown
                        if Player.UseObject(bandage.Serial) then
                            if Targeting.WaitForTarget(500) then
                                Targeting.Target(ally.Serial)
                                Messages.Print("Healing Friend " .. ally.Name)
                                Cooldown("BandageSelf", 5000)
                                Pause(ACTION_DELAY)
                                return -- Heal one person at a time
                            end
                        end
                    end
                end
            end
            ::continue::
        end
    end
    return false
end

function PopPouch()
   if USE_POUCHES and Player.IsParalyzed then
		local items = Items.FindByFilter({
		    graphics = {0x0E79},
		    hues = {0x0025}
		})
		for i, item in ipairs(items) do
		    if item.RootContainer == Player.Serial then
			Player.UseObject(item.Serial)
			break
		    end
		end
	end		
end

function UseHealPot()
    if not USE_HEAL_POTS then return end
    if Cooldown("HealPot") then return end

    local pot = Items.FindByType(0x0F0C)
    if not pot then return end -- No heal pots, no healing

    if Player.Hits / Player.HitsMax < HEAL_POT_MIN_THRESHOLD_HP and not Player.IsPoisoned then
        Messages.Overhead("Drinking Heal", 155, Player.Serial)
        Player.UseObject(pot.Serial)
        Cooldown("HealPot", 10000)
        Pause(ACTION_DELAY)
        return 
    end
end

function UseHealSpells()
    if not USE_HEAL_SPELLS then return end
    if Player.IsPoisoned then return end
    if Skills.GetValue("Magery") < 70 then return end

    -- 1. Check Self First
    if Player.Hits / Player.HitsMax <= 0.90 then
        local percentHp = Player.Hits / Player.HitsMax

        -- This whole mess decides whether we shoulduse heal vs. greater heal. Depends on HP
        -- And whether there is a perceived threat nearby (red pks, orange faction, or gray criminals)
        -- Greater Heal does about 45. Heal does about 12.
        local mobileList = Mobiles.FindByFilter({ rangemax=5, dead = false, noterieties = { 3, 4, 5, 6} })
        local danger = #mobileList > 1 -- We show up in list

        for index, mobile in ipairs(mobileList) do
            local mobile = mobileList[index]
            Messages.Print(mobile.Name)
        end

        Messages.Print("Danger mobs count = " .. tostring(#mobileList))

        -- Heal
        if (danger or percentHp > 0.7) and Player.Mana >= 4 then
            Spells.Cast("Heal")
            Targeting.WaitForTarget(750)
            Targeting.TargetSelf()
            Pause(ACTION_DELAY)
            return
        end

        -- Greater Heal
        if not danger and Player.Mana >= 11 then
            Spells.Cast("GreaterHeal")
            Targeting.WaitForTarget(1250)
            Targeting.TargetSelf()
            Pause(ACTION_DELAY)
            return
        end
    end

    -- Next heal allies if we aren't in danger ourselves
    if HEAL_SPELLS_ON_FRIENDS and Player.Hits / Player.HitsMax > 0.90 then
        for _, serial in ipairs(FRIEND_SERIALS) do

            if serial == Player.Serial then
                goto continue
            end

            -- Find the mobile object for this serial
            local ally = Mobiles.FindBySerial(serial)
        
            -- Check if ally exists, is alive, in range (2 tiles), and missing > 10% HP
            if ally and ally.Hits > 0 and ally.Distance <= 5 and not ally.IsYellowHits then
            
                local hpPercent = (ally.Hits / ally.HitsMax)
                if hpPercent <= HEAL_SPELL_FRIENDS_MIN_THRESHOLD_HP and not ally.IsPoisoned then
                    -- Greater heal
                    if hpPercent >= 0.25 and hpPercent <= 0.60 and Player.Mana >= 11 then
                        Messages.Overhead("Greater Heal on " .. ally.Name, 1153, Player.Serial)
                        Spells.Cast("GreaterHeal")
                        Targeting.WaitForTarget(1250)
                        Targeting.Target(ally.Serial)
                        Pause(ACTION_DELAY)

                    -- Heal
                    elseif Player.Mana >= 4 then
                        Messages.Overhead("Heal on " .. ally.Name, 1153, Player.Serial)    
                        Spells.Cast("Heal")
                        Targeting.WaitForTarget(1250)
                        Targeting.Target(ally.Serial)
                        Pause(ACTION_DELAY)
                    end
                end
            end
            ::continue::
        end
    end
end

function UseCurePot()
    if not USE_CURE_POTS then return end
    if not Player.IsPoisoned then return end

    local pot = Items.FindByType(0x0F07)
    if not pot then return end -- No cure pots, no healing

    Player.UseObject(pot.Serial)
    Messages.Overhead("Drinking Cure", 1128, Player.Serial)
    Pause(ACTION_DELAY)
    return
end

function UseCureSpell()
    if not USE_CURE_SPELL then return end
    if Skills.GetValue("Magery") < 70 then return end

    if Player.IsPoisoned and Player.Mana >= 11 then
        Messages.Overhead("Cure self", 1153, Player.Serial)    
        Spells.Cast("ArchCure")
        Targeting.WaitForTarget(1250)
        Targeting.TargetSelf()
        Pause(ACTION_DELAY)
        return
    end

    -- Next cure allies if we aren't in danger ourselves
    if CURE_SPELL_ON_FRIENDS and Player.Hits / Player.HitsMax >= 0.90 then
        for _, serial in ipairs(FRIEND_SERIALS) do

            if serial == Player.Serial then
                goto continue
            end

            -- Find the mobile object for this serial
            local ally = Mobiles.FindBySerial(serial)
        
            -- Check if ally exists, is alive, in range (2 tiles), and missing > 10% HP
            if ally and ally.Hits > 0 and ally.Distance <= 5 and ally.IsPoisoned then
                Messages.Overhead("Cure on " .. ally.Name, 1153, Player.Serial)    
                Spells.Cast("ArchCure")
                Targeting.WaitForTarget(1250)
                Targeting.Target(ally.Serial)
                Pause(ACTION_DELAY)
                return 
            end
            ::continue::
        end
    end
end

Journal.Clear()
Messages.Print("Starting Mage Master 5000")

while not Player.IsDead and not Player.IsHidden do
    Pause(10)
    UseBandage()
    PopPouch()
    UseCurePot()
    UseCureSpell()
    UseHealPot()
    UseHealSpells()
end