-- https://github.com/NvChad/ui/blob/v3.0/lua/nvconfig.lua
-- Please read that file to know all available options :(

---@type ChadrcConfig
local M = {}

M.base46 = {
  theme = "tokyonight",

  hl_override = {
    -- Comentarios
    Comment = { italic = true },
    ["@comment"] = { italic = true },

    -- Tipos / Clases
    ["@type"] = { fg = "#e0af68" },          -- Amarillo/Naranja
    ["@type.builtin"] = { fg = "#e0af68" },  -- Tipos integrados

    -- Métodos / Funciones
    ["@function.method"] = { fg = "#7aa2f7" }, -- Azul
    ["@function"] = { fg = "#7aa2f7" },

    -- Variables
    ["@variable"] = { fg = "#fde047" },       -- Amarillo

    -- Operadores (+, -, =, !=, etc.)
    ["@operator"] = { fg = "#34d399" },       -- Morado
  },
}

-- Opcional: otras configuraciones
-- M.nvdash = { load_on_startup = true }

return M

