-- Name: Coordinate Manager
-- Authors: Coolskin from Tacuba's script
-- Description: Manage and navigate to geographical coordinates.
-- Last Updated: September 16, 2025

-- ===================================================================
-- SCRIPT CONFIGURATION
-- You can easily customize the script's behavior by changing these variables.
-- ===================================================================

-- ### Navigation Parameters ###
local approach_distance = 30
local final_arrival_distance = 8

-- ### List & Display Parameters ###
local destinations_per_page = 10

-- ### Initial Data ###
local initial_destinations = {
    "3285,1301", "3752,1439", "2582,592", "3701,2241", "3835,2345",
    "3633,2628", "1423,1648", "3099,158", "1389,1321", "1713,559",
    "2121,188", "3705,222", "4224,791", "2076,2960", "4372,2031",
    "2749,3237", "3754,95", "4382,2322", "4402,759", "1197,2280",
    "4592,1485", "3832,3040", "1416,312", "1286,2612", "4721,1250",
    "4354,360", "4371,2695", "3894,3163", "1089,546", "879,1054",
    "4708,894", "1521,3083", "773,1610", "4820,1088", "4727,746",
    "849,2226", "1126,2924", "4973,2105", "550,1708",
    "746,2645", "866,2857", "4466,3205", "416,1836", "941,3128",
    "521,607", "301,1568", "588,2919", "3688,4002", "4753,3483",
    "721,3408", "4953,3348", "4277,3949", "4122,4050", "4811,3562",
    "4553,3887", "535,336", "5075,3862","4204,3780",}
    -- ===================================================================
    -- SECTION 1: GLOBAL VARIABLES
    -- ===================================================================

    local coordLabel, statusLabel
    local shipStatus = "Stopped"
    local current_destination_page = 1
    local should_redraw_destinations = false
    local current_navigation_task, ship_heading
    local destinations = {}
    local is_redrawing = false
    local storage_book_serial = nil
    local manager_window_pos = { x = 400, y = 250 }
    local should_export_client_map = false
    local client_map_export_data = nil

    -- ====================================
    -- SECTION 2: FUNCTION DEFINITIONS
    -- ====================================

    --
    -- Helper functions and Navigation
    --
    local function ConvertXYtoNEWS(x,y)local w,h,cx,cy=5120,4096,1323.1624,1624;local nlon=(((x-cx)*360)/w);if nlon<0 then nlon=nlon+360 end;local nlat=(((y-cy)*360)/h);if nlat<0 then nlat=nlat+360 end;local dlat,lath,dlon,lonh;if nlat>180 then dlat=360-nlat;lath="N" else dlat=nlat;lath="S" end;if nlon>180 then dlon=360-nlon;lonh="W" else dlon=nlon;lonh="E" end;local ld,lm=math.floor(dlat),math.floor((dlat-math.floor(dlat))*60);local lod,lom=math.floor(dlon),math.floor((dlon-math.floor(dlon))*60);return ld.."d "..lm.."'"..lath..", "..lod.."d "..lom.."'"..lonh;end
    local function round(n) return math.floor(n+0.5) end
    local function ConvertNEWStoXY(s) local w,h,cx,cy=5120,4096,1323.1624,1624;local ld,lm,lh,lod,lom,loh=string.match(s or "","(%d+)d (%d+)'([NS]), (%d+)d (%d+)'([EW])");if not ld then return nil,nil end;ld,lm,lod,lom=tonumber(ld),tonumber(lm),tonumber(lod),tonumber(lom);local declat,declon=ld+(lm/60),lod+(lom/60);local nlat;if lh=="N" then nlat=360-declat else nlat=declat end;local nlon;if loh=="W" then nlon=360-declon else nlon=declon end;local xf,yf=(nlon*(w/360)+cx)%w,(nlat*(h/360)+cy)%h;return round(xf),round(yf) end
    local function parseCoordinateString(coordString)
        local x, y, g
        x, y = ConvertNEWStoXY(coordString)
        if x and y then
            g = coordString
            return x, y, g
        end
        local xs, ys = coordString:match("^%s*(%d+)[%s,]+(%d+)%s*$")
        if xs and ys then
            x, y = tonumber(xs), tonumber(ys)
            g = ConvertXYtoNEWS(x, y)
            if g then
                return x, y, g
            end
        end
        return nil, nil, nil
    end
    local function calculateDistance(x1,y1,x2,y2) return math.floor(math.sqrt((x2-x1)^2+(y2-y1)^2)) end
    local function atan2(y,x) if x>0 then return math.atan(y/x) elseif x<0 then return math.atan(y/x)+(y>=0 and math.pi or -math.pi) elseif x==0 then return y>0 and math.pi/2 or(y<0 and -math.pi/2 or 0)end return 0 end
    local function getBearing(x1,y1,x2,y2) return(math.deg(atan2(x2-x1,y1-y2))+360)%360 end
    local function angleDiff(a1,a2) local d=a2-a1;while d<-180 do d=d+360 end;while d>180 do d=d-360 end;return d end
    function navigateTo(x,y) if shipStatus=="Anchor Dropped"then Messages.Overhead("Anchor is down. Raising it first...",60);Player.Say("Raise Anchor");Pause(2000)end;Messages.Overhead("Navigation starting...",85);current_navigation_task={target_x=x,target_y=y,status="ALIGN_FOR_X"} end
    function stopNavigation() if current_navigation_task then Player.Say("Stop");Messages.Overhead("Auto-navigation stopped.",85,Player.Serial);current_navigation_task=nil;ship_heading=nil;shipStatus="Stopped"end end

    --
    -- Import/Export UI and Logic
    --

    function create_export_window_with_data(title, data_lines)
        local winName = title:gsub("[^%w]+","") .. "DisplayWindow"
        if UI.WindowExists(winName) then UI.DestroyWindow(winName) end

        local win = UI.CreateWindow(winName, title)
        win:SetPosition(900, 250)
        win:AddLabel(20, 35, "You can copy the text from the box below."):SetColor(1, 1, 0.8, 1)

        local full_text = table.concat(data_lines, "\n")

        -- Using a read-only textbox to display the data.
        local textBox = win:AddTextBox(20, 60, 460, full_text)

        -- Dynamically calculate window height based on content.
        local num_lines = #data_lines
        local text_height = num_lines * 15
        local total_height = 120 + text_height
        win:SetSize(500, total_height)

        win:AddButton(200, total_height - 35, "Close"):SetOnClick(function() UI.DestroyWindow(winName); return end)
        end

        local function importGeoLogic(t)local c=0;for s in t:gmatch("([^;]+)")do local g=s:match("^%s*(.-)%s*$");if g and g~=""then local x,y=ConvertNEWStoXY(g);if x then table.insert(destinations,{geo=g,x=x,y=y,selected=false});c=c+1 end end;if(c>0 and c%20==0)then Pause(1)end end;if c>0 then should_redraw_destinations=true else Messages.Overhead("No new GEO found.",33)end; return end
        local function importXyLogic(t)local c=0;for s in t:gmatch("([^;]+)")do local xs,ys=s:match("^%s*(%d+)[%s,]+(%d+)%s*$");if xs and ys then local x,y=tonumber(xs),tonumber(ys);local g=ConvertXYtoNEWS(x,y);if g then table.insert(destinations,{geo=g,x=x,y=y,selected=false});c=c+1 end end;if(c>0 and c%20==0)then Pause(1)end end;if c>0 then should_redraw_destinations=true else Messages.Overhead("No new X,Y found.",33)end; return end

        --
        -- The Main Manager Window
        --

        function populateManagerWindow(win)
            local dm_lat_hem_local, dm_lon_hem_local = nil, nil
            local quickAddInput, latDegInput, latMinInput, lonDegInput, lonMinInput, latN, latS, lonE, lonW

            -- Status Display
            win:AddLabel(380, 25, "Status:"):SetColor(1,1,0.8,1)
            statusLabel = win:AddLabel(440, 25, shipStatus)
            statusLabel:SetColor(1,1,0.3,1)
            win:AddLabel(380, 45, "Coords:"):SetColor(1,1,0.8,1)
            coordLabel = win:AddLabel(440, 45, 'n/a')
            coordLabel:SetColor(0.3,1,0.3,1)

            -- Add Coords
            win:AddLabel(20, 25, "Quick Add (GEO or X,Y):"):SetColor(1,1,0.8,1); quickAddInput = win:AddTextBox(20, 45, 280, "")
            win:AddButton(310, 43, "Add##Quick"):SetOnClick(function()
                if is_redrawing then return end
                local t = quickAddInput:GetText()
                local x,y,g = parseCoordinateString(t)
                if x and y and g then
                    table.insert(destinations,{geo=g,x=x,y=y,selected=false})
                    quickAddInput:SetText("")
                    is_redrawing = true
                    should_redraw_destinations=true
                else
                    Messages.Overhead("Invalid format.",33)
                end
                return
            end)
            local y_lat=85; win:AddLabel(20, y_lat, 'Latitude:'); latDegInput=win:AddTextBox(90, y_lat-2, 40, ""); win:AddLabel(135, y_lat, 'd'); latMinInput=win:AddTextBox(150, y_lat-2, 40, ""); win:AddLabel(195, y_lat, "'"); latN=win:AddCheckbox(210, y_lat, 'N', false); latS=win:AddCheckbox(250, y_lat, 'S', false)
            local y_lon=y_lat+30; win:AddLabel(20, y_lon, 'Longitude:'); lonDegInput=win:AddTextBox(90, y_lon-2, 40, ""); win:AddLabel(135, y_lon, 'd'); lonMinInput=win:AddTextBox(150, y_lon-2, 40, ""); win:AddLabel(195, y_lon, "'"); lonE=win:AddCheckbox(210, y_lon, 'E', false); lonW=win:AddCheckbox(250, y_lon, 'W', false)
            latN:SetOnCheckedChanged(function(c)if c then dm_lat_hem_local="N"; latS:SetChecked(false)end; return end); latS:SetOnCheckedChanged(function(c)if c then dm_lat_hem_local="S"; latN:SetChecked(false)end; return end)
                lonE:SetOnCheckedChanged(function(c)if c then dm_lon_hem_local="E"; lonW:SetChecked(false)end; return end); lonW:SetOnCheckedChanged(function(c)if c then dm_lon_hem_local="W"; lonE:SetChecked(false)end; return end)
                    win:AddButton(310, y_lat+12, 'Add##Manual'):SetOnClick(function()
                        if is_redrawing then return end
                        if not dm_lat_hem_local or not dm_lon_hem_local then Messages.Overhead("Please select a hemisphere for Lat/Lon.", 33); return end
                        local g=string.format("%sd %s'%s, %sd %s'%s",latDegInput:GetText(),latMinInput:GetText(),dm_lat_hem_local,lonDegInput:GetText(),lonMinInput:GetText(),dm_lon_hem_local);local x,y=ConvertNEWStoXY(g)
                        if x and y then
                            table.insert(destinations,{geo=g,x=x,y=y,selected=false})
                            latDegInput:SetText(""); latMinInput:SetText(""); lonDegInput:SetText(""); lonMinInput:SetText("")
                            latN:SetChecked(false, true); latS:SetChecked(false, true); lonE:SetChecked(false, true); lonW:SetChecked(false, true)
                            dm_lat_hem_local, dm_lon_hem_local = nil, nil
                            is_redrawing = true
                            should_redraw_destinations=true
                        else
                            Messages.Overhead("Invalid data.",33)
                        end
                        return
                    end)

                    -- Actions
                    win:AddButton(20,185,"Refresh"):SetOnClick(function() if is_redrawing then return end; is_redrawing = true; should_redraw_destinations=true; return end);win:AddButton(130,185,"Go to Selected"):SetOnClick(function()local s;for _,d in ipairs(destinations)do if d.selected then s=d;break end end;if s then navigateTo(s.x,s.y)end; return end);win:AddButton(470,185,"Close"):SetOnClick(function()UI.DestroyWindow("ManagerWindow"); return end)

                        -- Destination List
                        win:AddLabel(20,215,'SAVED DESTINATIONS'):SetColor(0.8,0.8,1,1)
                        local px,py=Player.X,Player.Y;if px and py then for _,d in ipairs(destinations)do d.distance=calculateDistance(px,py,d.x,d.y)end;table.sort(destinations,function(a,b)return a.distance<b.distance end)end
                        local yPos=245;local start_index=(current_destination_page-1)*destinations_per_page+1;local end_index=math.min(start_index+destinations_per_page-1,#destinations)
                        for i=start_index,end_index do local d=destinations[i];if d then local tc={1,1,1,1};if d.selected then tc={0.6,0.8,1,1}end;local cb=win:AddCheckbox(40,yPos,"##cb"..i,d.selected);cb:SetOnCheckedChanged(function(c)for _,d2 in ipairs(destinations)do d2.selected=false end;d.selected=c; return end);win:AddLabel(65,yPos,d.geo):SetColor(tc[1],tc[2],tc[3],tc[4]);win:AddLabel(240,yPos,string.format("[X:%d Y:%d]",d.x,d.y)):SetColor(1,1,0.4,1);win:AddLabel(360,yPos,string.format("[%s tiles]",d.distance or"N/A")):SetColor(0.7,0.7,0.7,1);win:AddButton(500,yPos-5,"X##del"..i):SetOnClick(function() if is_redrawing then return end; is_redrawing = true; for idx, val in ipairs(destinations) do if val == d then table.remove(destinations, idx); break; end; end; should_redraw_destinations=true; return end);yPos=yPos+25 end end

                        -- Pagination
                        local y_pag=245+(destinations_per_page*25)+20; local total_p=math.max(1,math.ceil(#destinations/destinations_per_page));
                        if current_destination_page>1 then win:AddButton(40,y_pag,'< Prev'):SetOnClick(function() if is_redrawing then return end; is_redrawing = true; current_destination_page=current_destination_page-1;should_redraw_destinations=true; return end)end
                        win:AddLabel(120,y_pag+3,string.format("Page %d of %d",current_destination_page,total_p))
                        if current_destination_page<total_p then win:AddButton(240,y_pag,'Next >'):SetOnClick(function() if is_redrawing then return end; is_redrawing = true; current_destination_page=current_destination_page+1;should_redraw_destinations=true; return end)end

                        -- Import / Export Section
                        local y_data = y_pag + 40
                        win:AddLabel(20, y_data, "IMPORT DATA (paste below, separated by ';')"):SetColor(0.8,0.8,1,1)
                        local importTextBox = win:AddTextBox(20, y_data + 20, 520, "")
                        win:AddButton(20, y_data + 50, "Import GEO"):SetOnClick(function()
                            local txt = importTextBox:GetText()
                            if txt and txt ~= "" then
                                importGeoLogic(txt)
                                importTextBox:SetText("")
                            else
                                Messages.Overhead("Nothing to import.", 33)
                            end
                            return
                        end)
                        win:AddButton(130, y_data + 50, "Import X,Y"):SetOnClick(function()
                            local txt = importTextBox:GetText()
                            if txt and txt ~= "" then
                                importXyLogic(txt)
                                importTextBox:SetText("")
                            else
                                Messages.Overhead("Nothing to import.", 33)
                            end
                            return
                        end)

                        y_data = y_data + 90
                        win:AddLabel(20, y_data, "EXPORT ACTIONS (to journal)"):SetColor(0.8,0.8,1,1)
                        win:AddButton(20, y_data + 25, "Export X,Y"):SetOnClick(function()
                            if #destinations == 0 then Messages.Overhead("No destinations to export.", 33); return end
                            local l = {}; for _, d in ipairs(destinations) do table.insert(l, string.format("%d,%d", d.x, d.y)) end
                            Messages.Print("--- EXPORT (X,Y) ---"); Messages.Print(table.concat(l, "; ")); Messages.Print("--- EXPORT FIN ---")
                            Messages.Overhead("X,Y list exported to journal.", 85)
                            return
                        end)
                        win:AddButton(130, y_data + 25, "Export Client Map"):SetOnClick(function()
                            if #destinations == 0 then
                                Messages.Overhead("No destinations to export.", 33)
                                return
                            end
                            should_export_client_map = true
                            Messages.Overhead("Exporting Client Map data to journal...", 85)
                            return
                        end)
                    end

                    function createManagerWindow()
                        if UI.WindowExists("ManagerWindow") then return end
                        local win = UI.CreateWindow("ManagerWindow", "Coordinate Manager")
                        win:SetPosition(manager_window_pos.x, manager_window_pos.y); win:SetSize(560, 720); win:SetResizable(true)
                        populateManagerWindow(win)
                    end

                    -- ====================================
                    -- SECTION 3: SCRIPT INITIALIZATION
                    -- ====================================

                    for _,coordText in ipairs(initial_destinations) do
                        local x,y,g = parseCoordinateString(coordText)
                        if x and y and g then
                            table.insert(destinations,{geo=g,x=x,y=y,selected=false})
                        end
                    end

                    -- Create the main window when the script starts
                    createManagerWindow()

                    -- ====================================
                    -- SECTION 4: MAIN SCRIPT LOOP
                    -- ====================================
                    while true do
                        Pause(100)
                        if not UI.WindowExists("ManagerWindow") then
                            break
                        end

                        if should_export_client_map then
                            should_export_client_map = false
                            Messages.Print("--- EXPORT (Client Map) ---")
                            client_map_export_data = {}
                            for _, d in ipairs(destinations) do
                                local line = string.format("%d,%d,0,%s,exit,red,4", d.x, d.y, d.geo:gsub(",", ""):gsub("%s+", "-"))
                                Messages.Print(line)
                                table.insert(client_map_export_data, line)
                                Pause(20) -- Pause is safe here in the main loop
                            end
                            Messages.Print("--- EXPORT FIN ---")
                            Messages.Overhead("Client map data exported to journal.", 85)
                            create_export_window_with_data("Client Map Export", client_map_export_data)
                        end

                        if should_redraw_destinations then
                            should_redraw_destinations=false
                            if UI.WindowExists("ManagerWindow")then
                                is_redrawing = true
                                local win = UI.GetWindow("ManagerWindow")
                                if win then
                                    win:ClearControls()
                                    populateManagerWindow(win)
                                end
                                is_redrawing = false
                            end
                        end

                        if coordLabel and statusLabel and not coordLabel.IsDisposed and not statusLabel.IsDisposed then
                            coordLabel:SetText('('..Player.X..', '..Player.Y..')')
                            statusLabel:SetText(shipStatus)
                        end

                        if current_navigation_task then
                            local task = current_navigation_task

                            if calculateDistance(Player.X, Player.Y, task.target_x, task.target_y) <= final_arrival_distance then
                                stopNavigation()
                            elseif task.status == "ALIGN_FOR_X" then
                                local x_diff = task.target_x - Player.X
                                if math.abs(x_diff) <= 10 then
                                    task.status = "ALIGN_FOR_Y"
                                else
                                    shipStatus = "Aligning for X-Axis"
                                    local desired_heading = (x_diff > 0) and 90 or 270
                                    local last_pos = { x = Player.X, y = Player.Y }
                                    Player.Say("Forward One")
                                    Pause(1200)
                                    if Player.X ~= last_pos.x or Player.Y ~= last_pos.y then
                                        ship_heading = getBearing(last_pos.x, last_pos.y, Player.X, Player.Y)
                                        if math.abs(angleDiff(ship_heading, desired_heading)) > 25 then
                                            Player.Say((angleDiff(ship_heading, desired_heading) > 0) and "Turn Right" or "Turn Left")
                                            Pause(1500)
                                        else
                                            Player.Say("Forward")
                                            task.status = "CRUISE_ON_X"
                                        end
                                    end
                                end
                            elseif task.status == "CRUISE_ON_X" then
                                shipStatus = "Cruising on X-Axis"
                                if math.abs(Player.X - task.target_x) <= approach_distance then
                                    Player.Say("Stop")
                                    Pause(500)
                                    task.status = "PRECISION_MOVE_X"
                                end
                            elseif task.status == "PRECISION_MOVE_X" then
                                shipStatus = "Precision X-Axis"
                                if math.abs(Player.X - task.target_x) <= 5 then
                                    task.status = "ALIGN_FOR_Y"
                                else
                                    Player.Say("Forward One")
                                    Pause(1000)
                                    task.status = "ALIGN_FOR_X"
                                end
                            elseif task.status == "ALIGN_FOR_Y" then
                                local y_diff = task.target_y - Player.Y
                                if math.abs(y_diff) <= 5 then
                                    stopNavigation()
                                else
                                    shipStatus = "Aligning for Y-Axis"
                                    local desired_heading = (y_diff > 0) and 180 or 0
                                    local last_pos = { x = Player.X, y = Player.Y }
                                    Player.Say("Forward One")
                                    Pause(1200)
                                    if Player.X ~= last_pos.x or Player.Y ~= last_pos.y then
                                        ship_heading = getBearing(last_pos.x, last_pos.y, Player.X, Player.Y)
                                        if math.abs(angleDiff(ship_heading, desired_heading)) > 25 then
                                            Player.Say((angleDiff(ship_heading, desired_heading) > 0) and "Turn Right" or "Turn Left")
                                            Pause(1500)
                                        else
                                            if calculateDistance(Player.X, Player.Y, task.target_x, task.target_y) <= approach_distance then
                                                task.status = "PRECISION_MOVE_Y"
                                            else
                                                Player.Say("Forward")
                                                task.status = "CRUISE_ON_Y"
                                            end
                                        end
                                    end
                                end
                            elseif task.status == "CRUISE_ON_Y" then
                                shipStatus = "Cruising on Y-Axis"
                                if calculateDistance(Player.X, Player.Y, task.target_x, task.target_y) <= approach_distance then
                                    Player.Say("Stop")
                                    Pause(500)
                                    task.status = "PRECISION_MOVE_Y"
                                end
                            elseif task.status == "PRECISION_MOVE_Y" then
                                shipStatus = "Precision Y-Axis"
                                if calculateDistance(Player.X, Player.Y, task.target_x, task.target_y) <= final_arrival_distance then
                                    stopNavigation()
                                else
                                    Player.Say("Forward One")
                                    Pause(1000)
                                    task.status = "ALIGN_FOR_Y"
                                end
                            end
                        end
                        Pause(400)
                    end