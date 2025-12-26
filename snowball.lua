-- 0x0913

local sb = Items.FindByType(0x0913)

Messages.Print("Pick target")
target = Targeting.GetNewTarget()

Messages.Print(sb.Name)

while true do
    Player.UseObject(sb.Serial)
    Targeting.WaitForTarget(3000)
    Targeting.Target(target)
    Pause(750)    
end