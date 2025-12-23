list = Items.FindByFilter({onground=true, graphics=0x0F6C, rangemax=1})
for index, item in ipairs(list) do
    Messages.Print('Found item at location x:'..item.X..' y:'..item.Y..' '..item.Name)
    Player.UseObject(item.Serial)

    Gumps.WaitForGump(585180759, 1000)
    Gumps.PressButton(585180759, 1)
end
Messages.Print("DONE")