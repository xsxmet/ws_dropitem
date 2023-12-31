CONFIG = {}

CONFIG.Weights = {
    ["weapon"] = 1,
    ["account"] = 1,
}

function HelpNotify(msg)
    SetTextComponentFormat("STRING")
    AddTextComponentString(msg)
    DisplayHelpTextFromStringLabel(0, 0, 1, -1)
end

function Notify(msg)
    TriggerEvent("ws_notify", "info", "Information", msg, 5000)
end