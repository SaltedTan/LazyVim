-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here

-- Compiler Project Shortcuts
vim.keymap.set("n", "<leader>cb", "<cmd>!./build.sh<CR>", { desc = "Run compiler build script" })
vim.keymap.set("n", "<leader>cl", "<cmd>!./update_lsp.sh<CR>", { desc = "Update LSP compile_commands.json" })
