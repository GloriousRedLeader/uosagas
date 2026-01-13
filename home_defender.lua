-- Qwozy's Home Defender! INSTA-BAN --
-- Insta-bans the closest target possible and keeps checking for more.

Messages.Print("================================", 89)
Messages.Print("**Running Qwozy's Home Defender**", 68)
Messages.Print("Status: Scanning for nearby intruders", 33)
Messages.Print("================================", 89)


while true do
    local filter = {
        notorieties = {1, 3, 4, 6},  -- 1=criminals, 3=grey, 4=enemy, 6=red
        dead = false,
        human = false,              -- Avoid targeting players unless red/grey
        rangemax = 10
    }

    local targets = Mobiles.FindByFilter(filter)

    if targets and #targets > 0 then
        local target = targets[1]
        Player.Say('I ban thee!')
        if Targeting.WaitForTarget(200) then
            Targeting.Target(target.Serial)
            Messages.Overhead("Banning " .. target.Name, 33, Player.Serial)
        end
    else
        Messages.Overhead("No valid targets found.", 63, Player.Serial)
    end

    Pause(200)
end