------------------------------------------------------------------------------------
-- START OPTIONS for DISCORD TRAINER
-- by OMG Arturo
------------------------------------------------------------------------------------

-- Milliseconds of delay between actions
local ACTION_DELAY = 550

-- Will auto attack monsters so you dont have to. Warning: Will
-- attack grays and reds  if you configure it!
local AUTO_ATTACK = true

-- Tiles to look for bad guys
local ATTACK_RANGE = 3

-- Auto bandage yourself or allies
-- Cooldown 10 seconds
local USE_BANDAGES = true

-- Will use bandages on friends defined in FRIEND_SERIALS below
local BANDAGES_ON_FRIENDS = true

-- A decimal representing percentage of a friend's health bar. Bandage healing will
-- only kick in if they are below this threshold, e.g. 0.9  (less than 90%)
local BANDAGE_FRIENDS_MIN_THRESHOLD_HP = 0.9

-- Heal damaged friend by their serial if they are close.
-- Only applicable when BANDAGES = true
local FRIEND_SERIALS = { 
    0x0046C66E, -- omg artie
    0x0012705D, -- omg arthur
    0x003A3990, -- omg arturo
    0x0012DDAB,  -- mr karl
    0x0013C547, -- Blood Draw
    0x00110988, -- fastball
    0x001DB49D, -- bash
    0x003EC94F, -- Bruenor te dwarf
    0x0040CC3E, -- lady lumps
    0x00466D56, -- pink floyd
    0x003D131B, -- xufu
}


------------------------------------------------------------------------------------
-- END OPTIONS 
-- by OMG Arturo
------------------------------------------------------------------------------------

local INSTRUMENTS = {
    0x0E9C, -- DRUM
    0x0E9D, -- TAMBOURINE
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

function UseBandage()
    if not USE_BANDAGES then return end
    if Cooldown("BandageSelf") then return end
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

local mobileTarget = nil
local checkRetarget = os.clock() + 1
math.randomseed(os.time())
function AutoAttack()
    mobileTarget = nil
    if not AUTO_ATTACK then return end
    if os.clock() < checkRetarget then return end
    local mobileList = Mobiles.FindByFilter({ rangemax=ATTACK_RANGE, dead = false, notorieties = { 3, 4, 5, 6} })
    if #mobileList == 0 then return end
    local randomIndex = math.random(#mobileList)

    mobileTarget = mobileList[randomIndex]

    if mobileTarget.NotorietyFlag == "Innocent" or mobileTarget.NotorietyFlag == "Ally" or mobileTarget.NotorietyFlag == "Invulnerable" then return end

    checkRetarget = os.clock() + 3
    return mobileTarget
end

function UseDiscord(mobileTarget)
    if Cooldown("Discord") then return end
    if not mobileTarget then return end

    local instrument 
    for i, graphicId in ipairs(INSTRUMENTS) do
        instrument = Items.FindByType(graphicId)
        if instrument ~= nil then break end
    end

    if not instrument then return end

    Journal.Clear()
    Spells.Cast('SongOfDiscordance')
    Targeting.WaitForTarget(1000)
    if Journal.Contains("What instrument shall you play?") then
        Targeting.Target(instrument.Serial)
        Targeting.WaitForTarget(1000)
    end
    Targeting.Target(mobileTarget.Serial)
    Messages.Print("Discording " .. mobileTarget.Name)

    Cooldown("Discord", 2000)
    Pause(ACTION_DELAY)
end


Journal.Clear()
Messages.Print("Starting Train Discord")
while not Player.IsDead and not Player.IsHidden do
    Pause(1)
    targetMobile = AutoAttack()
    UseBandage()
    UseDiscord(mobileTarget)
end