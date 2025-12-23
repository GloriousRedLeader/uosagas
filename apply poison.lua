local poison = Items.FindByType(0x0F0A)
if poison ~= nil then
	local weapon = Items.FindByLayer(1)
	if weapon ~= nil then
		Skills.Use("Poisoning")
		Targeting.WaitForTarget(1000)
		Targeting.Target(poison.Serial)
		Targeting.WaitForTarget(1000)
		Targeting.Target(weapon.Serial)
	end
end
