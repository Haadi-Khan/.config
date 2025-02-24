local icons = require "icons"
local colors = require("colors").sections.widgets.battery

local battery = sbar.add("item", "widgets.battery", {
    position = "right",
    icon = {},
    label = { drawing = false },
    background = { drawing = false },
    padding_left = 8,
    padding_right = 4,
    update_freq = 180,
    popup = { align = "center", y_offset = 4 },
})

local battery_percentage = sbar.add("item", {
    position = "popup." .. battery.name,
    icon = {
        string = "Battery:",
        width = 100,
        align = "left",
    },
    label = {
        string = "??%",
        width = 100,
        align = "right",
    },
    background = { drawing = false },
})
local remaining_time = sbar.add("item", {
    position = "popup." .. battery.name,
    icon = {
        string = "Time remaining:",
        width = 100,
        align = "left",
    },
    label = {
        string = "??:??h",
        width = 100,
        align = "right",
    },
    background = { drawing = false },
})

battery:subscribe({ "routine", "power_source_change", "system_woke" }, function()
    sbar.exec("pmset -g batt", function(batt_info)
        local icon = "!"
        local found, _, charge = batt_info:find "(%d+)%%"

        if found then
            charge = tonumber(charge)
        end

        local color = colors.high
        local charging = batt_info:find "AC Power"

        if charging then
            icon = icons.battery.charging
        else
            if found and charge > 80 then
                icon = icons.battery._100
            elseif found and charge > 60 then
                icon = icons.battery._75
            elseif found and charge > 40 then
                icon = icons.battery._50
            elseif found and charge > 30 then
                icon = icons.battery._50
                color = colors.mid
            elseif found and charge > 20 then
                icon = icons.battery._25
                color = colors.mid
            else
                icon = icons.battery._0
                color = colors.low
            end
        end

        battery:set {
            icon = {
                string = icon,
                color = color,
            },
        }

        -- Update battery percentage in the popup
        if found then
            battery_percentage:set { label = charge .. "%" }
        end
    end)
end)

battery:subscribe("mouse.clicked", function()
    local drawing = battery:query().popup.drawing
    battery:set { popup = { drawing = "toggle" } }

    if drawing == "off" then
        sbar.exec("pmset -g batt", function(batt_info)
            local found_time, _, remaining = batt_info:find " (%d+:%d+) remaining"
            local label_time = found_time and remaining .. "h" or "No estimate"

            local found_charge, _, charge = batt_info:find "(%d+)%%"
            local label_charge = found_charge and charge .. "%" or "Unknown"

            remaining_time:set { label = label_time }
            battery_percentage:set { label = label_charge }
        end)
    end
end)
