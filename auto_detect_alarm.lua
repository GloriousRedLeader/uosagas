------------------------------------------------------------------------------------
-- START OPTIONS for Early Warning System. Run on a stealthed player near choke point.
-- Will send party chat warning when reds / grays are found. Optionally can spam detect.
-- Will also alert when you are revealed.
-- by OMG Arturo
------------------------------------------------------------------------------------

-- Whether to use detect hidden skill
local USE_DETECT = true

------------------------------------------------------------------------------------
-- END OPTIONS 
-- by OMG Arturo
------------------------------------------------------------------------------------

function findPlayers()
    local all = Mobiles.FindByFilter({
        rangemax = 50,
        dead = false,
        human = true
,
        notorieties={0,4,5,6}
    }) or {}

    for _, mob in ipairs(all) do
        if mob ~= nil and mob.Name ~= nil and mob.Serial ~=Player.Serial and mob.Name ~= "omg arthur" then 
            Player.SayParty(mob.Name.. '-----' ..mob.NotorietyFlag)
            Player.SayParty(mob.Name.. '-----' ..mob.NotorietyFlag)
            Player.SayParty(mob.Name.. '-----' ..mob.NotorietyFlag)
        end
    end
end

while true do
    findPlayers()
    Skills.Use('Detecting Hidden')
    Targeting.WaitForTarget(1000)
    Targeting.TargetSelf()
    Pause(1500)

    if not Player.IsHidden then
        Player.SayParty("I have been revealed!!!!")
        Pause(1500)
    end
end
