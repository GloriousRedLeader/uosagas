------------------------------------------------------------------------------------
-- START OPTIONS for script that applies poison to blade
-- by OMG Arturo
------------------------------------------------------------------------------------

-- (no options)

------------------------------------------------------------------------------------
-- END OPTIONS 
-- by OMG Arturo
------------------------------------------------------------------------------------

local poison = Items.FindByType(0x0F0A)
if poison ~= nil then
	local weapon = Items.FindByLayer(1)
	if weapon ~= nil then
		Skills.Use("Poisoning")
		Target.WaitForTarget(1000)
		Target.TargetSerial(poison.Serial)
		Target.WaitForTarget(1000)
		Target.TargetSerial(weapon.Serial)
	end
end
