-- Make sure to setup `mapleader` and `maplocalleader` before
-- loading lazy.nvim so that mappings are correct.
-- This is also a good place to setup other settings (vim.opt)
vim.g.mapleader = " "
vim.g.maplocalleader = "\\"

vim.cmd("set expandtab")
vim.cmd("set tabstop=2")
vim.cmd("set softtabstop=2")
vim.cmd("set shiftwidth=2")

vim.opt.number = true -- Set document numbering

-- Highlight trailing whitespace
vim.api.nvim_set_hl(0, "TrailingWhitespace", { bg = "#671c17" }) -- Set highlight color
vim.api.nvim_create_autocmd({"BufReadPost", "BufWinEnter", "InsertLeave", "TextChanged"}, {
    pattern = "*",
    callback = function()
        -- Alter 'exclude_filetypes' if whitespace highlighting shows up where it shouldn't
        local exclude_filetypes = { "neo-tree", "TelescopePrompt", "TelescopeResults" }
        if not vim.tbl_contains(exclude_filetypes, vim.bo.filetype) then
          vim.cmd([[match TrailingWhitespace /\s\+$/]])
        end
    end,
})
