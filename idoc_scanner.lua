------------------------------------------------------------------------------------
-- START OPTIONS for IDOC SCANNER
-- by OMG Arturo
------------------------------------------------------------------------------------

-- n/a
------------------------------------------------------------------------------------
-- END OPTIONS 
-- by OMG Arturo
------------------------------------------------------------------------------------

SIGN_GRAPHICS = {
    0x0BD1,
    0x0BD2
}

while true do
    signs = Items.FindByFilter({ graphics = SIGN_GRAPHICS })
    for index, sign in ipairs(signs) do
        if sign ~= nil then
            if string.find(sign.Properties, 'In Danger') ~= nil then
                Messages.Overhead("IDOC", 37, sign.Serial)
                Messages.Overhead("IDOC", 37, Player.Serial)
            elseif string.find(sign.Properties, 'Greatly Worn') ~= nil then
                Messages.Overhead("Greatly", 47, sign.Serial)
                Messages.Overhead("Greatly", 47, Player.Serial)
            elseif string.find(sign.Properties, 'Fairly Worn') ~= nil then
                Messages.Overhead("Fairly Worn", 57, sign.Serial)
                Messages.Overhead("Fairly Worn", 57, Player.Serial)
            end
        end
    end
    Pause(1000)
end