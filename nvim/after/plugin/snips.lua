local luasnip = require('luasnip')
local s = luasnip.snippet
local t = luasnip.text_node
local i = luasnip.insert_node
local d = luasnip.dynamic_node
local c = luasnip.choice_node
local sn = luasnip.snippet_node
local fmt = require("luasnip.extras.fmt").fmt

-- Function to check if inside inline math mode
local function in_math_mode()
    local line = vim.api.nvim_get_current_line()
    local col = vim.api.nvim_win_get_cursor(0)[2] + 1 -- Get cursor column position (1-based index)

    -- Find all dollar sign positions
    local dollar_positions = {}
    for i = 1, #line do
        if line:sub(i, i) == "$" then
            table.insert(dollar_positions, i)
        end
    end

    -- If there are an odd number of $, cursor is in math mode
    if #dollar_positions >= 2 then
        for j = 1, #dollar_positions - 1, 2 do
            if dollar_positions[j] < col and col < dollar_positions[j + 1] then
                return true
            end
        end
    end
    return false
end

-- Define the snippet
luasnip.add_snippets("typst", {
    s("mk", { t("$"), i(1), t("$") }, { }),
    s("dm", { t("$ "), i(1), t(" $") }, { }),
    s({
        trig = ";a",
        wordTrig = false, -- Allows triggering inside words
    }, {
        d(1, function()
            if in_math_mode() then
                return sn(nil, { t("alpha") })
            else
                return sn(nil, { t(";a") }) -- If not in math mode, just return "sr"
            end
        end)
    }),
})
