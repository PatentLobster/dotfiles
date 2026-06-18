require "nvchad.mappings"

-- add yours here

local map = vim.keymap.set

map("n", ";", ":", { desc = "CMD enter command mode" })
map("i", "jk", "<ESC>")
vim.keymap.set('n', '<leader>cc', '<cmd>ClaudeCode<CR>', { desc = 'Toggle Claude Code' })


-- Run the current Go file in a terminal split
map("n", "<leader>gr", function()
  vim.cmd("write")            -- save first
  vim.cmd("terminal go run " .. vim.fn.expand("%"))
end, { desc = "Go run current file" })

-- Build the package in the current directory
map("n", "<leader>gb", function()
  vim.cmd("write")
  vim.cmd("terminal go build")
end, { desc = "Go build package" })


-- Copilot
map("i", "<C-l>", function()
  require("copilot.suggestion").accept()
end, { desc = "Copilot accept" })
-- map({ "n", "i", "v" }, "<C-s>", "<cmd> w <cr>")
