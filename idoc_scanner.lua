------------------------------------------------------------------------------------
-- START OPTIONS for IDOC SCANNER. Turn it on. Cruise control.
-- by OMG Arturo
------------------------------------------------------------------------------------

-- Add as needed.
local SIGN_GRAPHICS = {
    0x0BD1,
    0x0BD2,
    0x0C0C,
    0x0C0E,
    0x0BC1,
    0x0C0D,
    0x0BAE,
    0x0BA5,
    0x0C09,
    0x0BAD,
    0x0BC2,
    0x0BAF,
    0x0C00,
    0x0BC4,
    0x0BDB,
    0x0BC0,
    0x0BF0
}

------------------------------------------------------------------------------------
-- END OPTIONS 
-- by OMG Arturo
------------------------------------------------------------------------------------

while true do
    signs = Items.FindByFilter({ graphics = SIGN_GRAPHICS })
    for index, sign in ipairs(signs) do
        if sign ~= nil and sign.Properties ~= nil then
            if string.find(sign.Properties, 'In Danger') ~= nil then
                Messages.Overhead("IDOC", 37, sign.Serial)
                Messages.Overhead("IDOC", 37, Player.Serial)
            elseif string.find(sign.Properties, 'Greatly Worn') ~= nil then
                Messages.Overhead("Greatly", 47, sign.Serial)
                --Messages.Overhead("Greatly", 47, Player.Serial)
            elseif string.find(sign.Properties, 'Fairly Worn') ~= nil then
                Messages.Overhead("Fairly", 57, sign.Serial)
                --Messages.Overhead("Fairly", 57, Player.Serial)
            elseif string.find(sign.Properties, 'Somewhat Worn') ~= nil then
                Messages.Overhead("Somewhat", 67, sign.Serial)
            elseif string.find(sign.Properties, 'Slightly Worn') ~= nil then
                Messages.Overhead("Slightly", 67, sign.Serial)
            elseif string.find(sign.Properties, 'Like New') ~= nil then
                Messages.Overhead("New", 67, sign.Serial)
            else
                Messages.Overhead("Unkown", 67, sign.Serial)
            end
        end
    end
    Pause(1000)
end