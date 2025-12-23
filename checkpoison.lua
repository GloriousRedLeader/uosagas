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