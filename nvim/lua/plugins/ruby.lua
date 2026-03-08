return {
  {
    "neovim/nvim-lspconfig",
    opts = {
      servers = {
        herb_ls = {
          capabilities = {
            general = {
              positionEncodings = { "utf-8" },
            },
          },
        },
      },
    },
  },
}
