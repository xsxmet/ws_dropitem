local Ground = {}

Citizen.CreateThread(function()
    while ESX == nil do
        ESX = exports['es_extended']:getSharedObject()
        Citizen.Wait(0)
    end
end)

RegisterNetEvent("ws_dropitem:Notify", function(message)
    Notify(message)
end)

RegisterNetEvent("ws_dropitem:updateGround", function(data)
    Ground = data

    local ped = PlayerPedId()
    local pedcoords = GetEntityCoords(ped)

    for _, ground in ipairs(Ground) do
        local distance = #(pedcoords - ground.coords)

        if distance < 1 and ESX.UI.Menu.IsOpen("default", GetCurrentResourceName(), "drop_menu") then
            OpenDropMenu(ground)
            break
        end
    end
end)

Citizen.CreateThread(function()
    while true do
        Citizen.Wait(0)

        local letsleep = true
        local ped = PlayerPedId()
        local pedcoords = GetEntityCoords(ped)
        
        for i , ground in ipairs(Ground) do
            local distance = #(pedcoords - ground.coords)

            if distance < 15 and #ground.items > 0 then
                letsleep = false

                DrawMarker(2, ground.coords.x, ground.coords.y, ground.coords.z - 0.5, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.3, 0.3, 0.3, 255, 255, 255, 255, true, true, 0, false)
              
                if distance < 1 then
                    HelpNotify("Drücke ~INPUT_PICKUP~ um aufzuheben")
     
                    if IsControlJustPressed(0, 38) then
                        OpenDropMenu(ground)
                    end
                end
            end
        end

        if letsleep then
            Citizen.Wait(500)
        end
    end
end)

function OpenDropMenu(ground)
    local elements = {}

    if #ground.items == 0 then
        ESX.UI.Menu.CloseAll()
        return
    end

    for _, item in ipairs(ground.items) do
        if item.type == "item" then
            table.insert(elements, {
                label = ("%sx %s"):format(item.count, item.label),
                item = item,
            })
        elseif item.type == "weapon" then
            table.insert(elements, {
                label = ("%s mit %s Schuss"):format(item.label, item.count),
                item = item,
            })
        elseif item.type == "account" then
            table.insert(elements, {
                label = ("%s$ %s$"):format(item.count, item.label),
                item = item,
            })
        end
    end

    ESX.UI.Menu.Open("default", GetCurrentResourceName(), "drop_menu", {
        title = "Aufheben",
        align = "top-left",
        elements = elements,
    }, function(data, menu)
        ESX.UI.Menu.Open("dialog", GetCurrentResourceName(), "drop_menu_dialog", {
            title = "Anzahl",
        }, function(data2, menu2)
            local count = tonumber(data2.value)

            if count ~= nil then
                if data.current.item.count >= count then
                    TriggerServerEvent("ws_dropitem:takeItem", ground.groundId, data.current.item, count)
                    menu2.close()
                else
                    Notify(("Du kannst nicht mehr als %sx aufheben"):format(data.current.item.count))
                end
            else
                Notify("Ungültige Menge")
            end
        end, function(data2, menu2)
            menu2.close()
        end)

        TriggerServerEvent("ws_dropitem:takeItem", ground.groundId, data.current.item)
    end, function(data, menu)
        menu.close()
    end)
end

exports("DropItemOnGround", function(data)
    TriggerServerEvent("ws_dropitem:registerDrop", data)
end)