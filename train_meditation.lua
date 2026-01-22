------------------------------------------------------------------------------------
-- START OPTIONS for MEditation TRAINER. Yeah, I made one.
-- On sagas you get more gains by passively regenerating, not actively meditating.
-- Using flamestrike because it might gain resists too.
-- by OMG Arturo
------------------------------------------------------------------------------------
-- n/a

------------------------------------------------------------------------------------
-- END OPTIONS 
-- by OMG Arturo
------------------------------------------------------------------------------------

while true do
    if Player.Mana > 90 and Player.Hits > 90 then
        Spells.Cast('FlameStrike')
        Targeting.WaitForTarget(3000)
        Targeting.TargetSelf()
        Pause(3000)
        Spells.Cast('GreaterHeal')
        Targeting.WaitForTarget(2000)
        Targeting.TargetSelf()
        Pause(3000)
    end
    Pause(5000)
end