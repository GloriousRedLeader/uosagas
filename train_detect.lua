------------------------------------------------------------------------------------
-- START OPTIONS for script trains detect hidden skill
-- by OMG Arturo
------------------------------------------------------------------------------------

-- (no options)

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
--while Skills.GetValue('Detecting Hidden') < 120 do
    Skills.Use('Detecting Hidden')
    Targeting.WaitForTarget(1000)
    Targeting.TargetSelf()
    Pause(1500)

    if not Player.IsHidden then
        Player.SayParty("I have been revealed!!!!")
        Pause(1500)
    end
end
