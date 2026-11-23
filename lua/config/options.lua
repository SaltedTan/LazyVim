-- Options are automatically loaded before lazy.nvim startup
-- Default options that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/options.lua
-- Add any additional options here

vim.opt.clipboard = "unnamedplus"

if vim.env.SSH_TTY or vim.env.SSH_CONNECTION then
  local osc52 = require("vim.ui.clipboard.osc52")
  vim.g.clipboard = {
    name = "OSC 52",
    copy = { ["+"] = osc52.copy("+"), ["*"] = osc52.copy("*") },
    -- Pasting via OSC 52 is poorly supported and can hang, so paste from Neovim's own register
    paste = {
      ["+"] = function() return vim.split(vim.fn.getreg('"'), "\n") end,
      ["*"] = function() return vim.split(vim.fn.getreg('"'), "\n") end,
    },
  }
end
