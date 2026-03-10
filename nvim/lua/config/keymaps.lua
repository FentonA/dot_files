-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here

-- Clickk test runners
vim.keymap.set("n", "<leader>tu", "<cmd>split | terminal just test-user<cr>", { desc = "Test user-service" })
vim.keymap.set("n", "<leader>tc", "<cmd>split | terminal just test-content<cr>", { desc = "Test content-service" })
vim.keymap.set("n", "<leader>te", "<cmd>split | terminal just test-engagement<cr>", { desc = "Test engagement-service" })
vim.keymap.set("n", "<leader>ta", "<cmd>split | terminal just test<cr>", { desc = "Test all services" })
