require "nvchad.options"

-- add yours here!

local opt = vim.opt

-- Desactivar salto de línea automático (nowrap)
opt.wrap = true


vim.opt.mouse = ""

-- Permitir scroll horizontal cuando el texto es muy largo
--opt.sidescroll = 1
opt.scrolloff = 0
--opt.sidescrolloff = 5
vim.opt.breakindent = true
-- local o = vim.o
-- o.cursorlineopt ='both' -- to enable currsorline!
