------------------------------------------------------------------------------------
-- START OPTIONS for script that will check if your weapon has poison. It is way
-- easier than mousing over, praise mao.
-- by OMG Arturo
------------------------------------------------------------------------------------

-- n/a

------------------------------------------------------------------------------------
-- END OPTIONS 
-- by OMG Arturo
------------------------------------------------------------------------------------

wep = Items.FindByLayer(1)
if wep ~= nil and wep.Properties ~= nil then
	if string.find(wep.Properties, 'Poison') == nil then
		Messages.Overhead("You dont have poison", 44, Player.Serial)
	else
		Messages.Overhead("You do have poison", 74, Player.Serial)
	end
		
else
	Messages.Overhead('NO WEAPON found', 34, Player.Serial)
end