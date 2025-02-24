local ls = require('luasnip')

ls.setup({
    config= function()
        require("luasnip.loaders.from_lua").lazy_load({ paths = { "../../LuaSnip" } })
    end
})
