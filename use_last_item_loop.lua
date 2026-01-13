------------------------------------------------------------------------------------
-- START OPTIONS for a script that prompts use to select an item, e.g. a keg.
-- it will then loop forever and click on that item every 1 second.
-- by OMG Arturo
------------------------------------------------------------------------------------


local delay = 1000

------------------------------------------------------------------------------------
-- END OPTIONS 
-- by OMG Arturo
------------------------------------------------------------------------------------

obj = Targeting.GetNewTarget()
while true do
    Player.UseObject(obj)
    Pause(delay)
end