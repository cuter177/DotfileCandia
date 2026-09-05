require("nvchad.configs.lspconfig").defaults()
local servers = { "html", "cssls", "pyright", "clangd", "jdtls","vtsls", "ruby_lsp", "vhdl_ls"}

-- vhdl_ls exige rootUri; si no hay vhdl_ls.toml/.git, usa el cwd
vim.lsp.config("vhdl_ls", {
  root_dir = function(bufnr, on_dir)
    local fname = vim.api.nvim_buf_get_name(bufnr)
    local root = vim.fs.root(fname, { "vhdl_ls.toml", ".vhdl_ls.toml", ".git" })
      or vim.uv.cwd()
    on_dir(root)
  end,
})

vim.lsp.enable(servers)

-- read :h vim.lsp.config for changing options of lsp servers 
