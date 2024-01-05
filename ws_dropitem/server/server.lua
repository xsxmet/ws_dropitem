local ESX = exports['es_extended']:getSharedObject()
local Ground = {}
local GroundId = 0

RegisterNetEvent("ws_dropitem:registerDrop", function(data)
    local source = source
    local xPlayer = ESX.GetPlayerFromId(source)

    if xPlayer ~= nil and data ~= nil then
        if data.item ~= nil and data.coords ~= nil then 
            local success, itemdata, error = GetItemType(xPlayer, data.item)

            if success then 
                local DropAtCoords = false

                for _, ground in ipairs(Ground) do
                    local distance = #(ground.coords - data.coords)

                    if distance < 1 then
                        DropAtCoords = true
                        local ItemExists = false

                        for _, item in ipairs(ground.items) do
                            if item.name == itemdata.name then
                                ItemExists = true

                                RemoveItemFromInventory(xPlayer, itemdata, itemdata.count, function()
                                    item.count = item.count + itemdata.count
                                    TriggerClientEvent("ws_dropitem:updateGround", -1, Ground)
                                end)
                            end
                        end

                        if not ItemExists then
                            RemoveItemFromInventory(xPlayer, itemdata, itemdata.count, function()
                                table.insert(ground.items, itemdata)
                                TriggerClientEvent("ws_dropitem:updateGround", -1, Ground)
                            end)
                        end
                    end
                end

                if not DropAtCoords then 
                    RemoveItemFromInventory(xPlayer, itemdata, itemdata.count, function()
                        GroundId = GroundId + 1

                        Ground[GroundId] = {
                            groundId = GroundId,
                            coords = data.coords,
                            items = {},
                        }
    
                        table.insert(Ground[GroundId].items, itemdata)
                        TriggerClientEvent("ws_dropitem:updateGround", -1, Ground)
                    end)                    
                end
            else
                TriggerClientEvent("ws_dropitem:Notify", xPlayer.source, error)
            end
        end
    end
end)

RegisterNetEvent("ws_dropitem:takeItem", function(groundId, item, count)
    local source = source
    local xPlayer = ESX.GetPlayerFromId(source)

    if xPlayer ~= nil and groundId ~= nil and item ~= nil and count ~= nil then
        if Ground[groundId] ~= nil then
            local ItemExists = false

            for i, groundItem in ipairs(Ground[groundId].items) do
                if groundItem.name == item.name then
                    ItemExists = true

                    if item.type == "weapon" then 
                        GiveGroundItem(xPlayer, item, groundItem.count, function()
                            table.remove(Ground[groundId].items, i)
                            TriggerClientEvent("ws_dropitem:updateGround", -1, Ground)
                        end)
                    else
                        if count > groundItem.count then
                            TriggerClientEvent("ws_dropitem:Notify", xPlayer.source, ("Du kannst nicht mehr als %sx aufheben"):format(groundItem.count))
                            return
                        end

                        if count == groundItem.count then
                            GiveGroundItem(xPlayer, item, count, function()
                                table.remove(Ground[groundId].items, i)
                                TriggerClientEvent("ws_dropitem:updateGround", -1, Ground)
                            end)
                        else
                            GiveGroundItem(xPlayer, item, count, function()
                                groundItem.count = groundItem.count - count
                                TriggerClientEvent("ws_dropitem:updateGround", -1, Ground)
                            end)
                        end
                    end
                end
            end

            if not ItemExists then
                TriggerClientEvent("ws_dropitem:Notify", xPlayer.source, "Dieser Gegenstand existiert nicht mehr")
            end 
        end
    end
end)

function GiveGroundItem(xPlayer, item, count, fcb) 
    if item.type == "item" then
        if xPlayer.canCarryItem(item.name, count) then 
            xPlayer.addInventoryItem(item.name, count)
            TriggerClientEvent("ws_dropitem:Notify", xPlayer.source, ("Du hast %sx %s aufgehoben"):format(count, item.label))
            fcb(true)
        else
            TriggerClientEvent("ws_dropitem:Notify", xPlayer.source, "Dieser Gegenstand Passt nicht in dein inventar")
        end
    elseif item.type == "weapon" then
        if not xPlayer.hasWeapon(item.name) then 
            xPlayer.addWeapon(item.name, count)
            TriggerClientEvent("ws_dropitem:Notify", xPlayer.source, ("Du hast %s mit %s Schuss aufgehoben"):format(item.label, count))
            fcb(true)
        else
            TriggerClientEvent("ws_dropitem:Notify", xPlayer.source, "Du besitzt diese Waffe bereits")
        end
    elseif item.type == "account" then
        xPlayer.addAccountMoney(item.name, count)
        TriggerClientEvent("ws_dropitem:Notify", xPlayer.source, ("Du hast %s$ %s aufgehoben"):format(count, item.label))
        fcb(true)
    end
end

function RemoveItemFromInventory(xPlayer, item, count, cb)
    if item.type == "item" then
        xPlayer.removeInventoryItem(item.name, count)
        TriggerClientEvent("ws_dropitem:Notify", xPlayer.source, ("Du hast %sx %s fallen gelassen"):format(count, item.label))
        cb(true)
    elseif item.type == "weapon" then
        xPlayer.removeWeapon(item.name)
        TriggerClientEvent("ws_dropitem:Notify", xPlayer.source, ("Du hast %s mit %s Schuss fallen gelassen"):format(item.label, count))
        cb(true)
    elseif item.type == "account" then
        xPlayer.removeAccountMoney(item.name, count)
        TriggerClientEvent("ws_dropitem:Notify", xPlayer.source, ("Du hast %s$ %s fallen gelassen"):format(count, item.label))
        cb(true)
    end
end

function GetItemType(xPlayer, item)
    if item.type == "item" then
        local xItem = xPlayer.getInventoryItem(item.name)

        if xItem ~= nil then
            if xItem.count >= item.count then
                return true, {
                    name = xItem.name,
                    label = xItem.label,
                    count = item.count,
                    type = item.type,
                    weight = xItem.weight,
                }
            else
                return false, {}, ("Du hast nicht genug %s"):format(xItem.label)
            end
        else
            return false, {}, ("xItem %s Existert nicht"):format(item.name)
        end
    elseif item.type == "weapon" then
        local xWeapon = xPlayer.getWeapon(string.upper(item.name))

        if xWeapon ~= nil then  
            return true, {
                name = xPlayer.getLoadout()[xWeapon].name,
                label = xPlayer.getLoadout()[xWeapon].label,
                count = xPlayer.getLoadout()[xWeapon].ammo,
                type = item.type,
                weight = CONFIG.Weights[item.type],
            }
        else
            return false, {}, ("Du besitzt die Waffe %s nicht"):format(ESX.GetWeaponLabel(string.upper(item.name)))
        end
    elseif item.type == "account" then
        local xAccount = xPlayer.getAccount(item.name)

        if xAccount ~= nil then
            if xAccount.money >= item.count then
                return true, {
                    name = xAccount.name,
                    label = xAccount.label,
                    count = item.count,
                    type = item.type,
                    weight = CONFIG.Weights[item.type],
                }
            else
                return false, {}, ("Du hast nicht genug %s"):format(xAccount.label)
            end
        else
            return false, {}, ("xAccount %s Existert nicht"):format(item.name)
        end
    end
end
