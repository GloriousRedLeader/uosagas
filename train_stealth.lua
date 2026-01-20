------------------------------------------------------------------------------------
-- START OPTIONS for script trains hiding, stealth, and detect hidden
-- by OMG Arturo
------------------------------------------------------------------------------------

-- (no options)

------------------------------------------------------------------------------------
-- END OPTIONS 
-- by OMG Arturo
------------------------------------------------------------------------------------

while Skills.GetValue('Hiding') < 100 do
	Skills.Use('Hiding')
	Pause(10000)
end

while Skills.GetValue('Stealth') < 100 do
    if Player.IsHidden == true then
          Skills.Use('Stealth')
        Pause(10200)
    else
    Skills.Use('Hiding')
    Pause(10200)
    end
end

while Skills.GetValue('Detecting Hidden') < 100 do
	Skills.Use('Detecting Hidden')
	Pause(775)
	Targeting.TargetSelf()
	Pause(2000)
end
