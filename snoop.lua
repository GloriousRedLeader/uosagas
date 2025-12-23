-- Find mobiles by filter criteria
filter = {female=true, rangemax=1, notorieties={1, 3, 4, 5, 6}}

list = Mobiles.FindByFilter(filter)
for index, mobile in ipairs(list) do
    if mobile.Serial ~= Player.Serial then
        Messages.Print('Found mobile at location x:'..mobile.X..' y:'..mobile.Y .. ' name : ' .. mobile.Name)
        Player.UseObject(mobile.Serial)
        break
    end

end