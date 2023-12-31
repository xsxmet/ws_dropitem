-- Client Exports

exports["ws_dropitem"]:DropItemOnGround({
    coords = GetEntityCoords(PlayerPedId()),
    item = {
        name = "schutzweste", -- item name or weapon name (uppercase) or account name (money, black_money, bank, etc.)
        type = "item", -- weapon, item, account
        count = 1, -- item count, if type weapon it automaticly set to weaponamo dont need to set it 
    },
})

-- Drop Item Test Command

RegisterCommand("drop", function(_, args)
    if args == nil or args[1] == nil then
        Notify("Benutze /drop [item/weapon/account]")
        return
    end

    if args[1] == "item" then
        exports[GetCurrentResourceName()]:DropItemOnGround({
            coords = GetEntityCoords(PlayerPedId()),
            item = {
                name = "schutzweste",
                type = "item",
                count = 1,
            },
        })
    elseif args[1] == "weapon" then
        exports[GetCurrentResourceName()]:DropItemOnGround({
            coords = GetEntityCoords(PlayerPedId()),
            item = {
                name = "WEAPON_PISTOL",
                type = "weapon",
                count = 1,
            },
        })
    elseif args[1] == "account" then
        exports[GetCurrentResourceName()]:DropItemOnGround({
            coords = GetEntityCoords(PlayerPedId()),
            item = {
                name = "money",
                type = "account",
                count = 1,
            },
        })
    end  
end)