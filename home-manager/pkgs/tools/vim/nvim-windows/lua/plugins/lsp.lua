local servers = {
  rust_analyzer = { settings = { ["rust-analyzer"] = { check = { command = "clippy" } } } },
  clangd = {},
  lua_ls = {
    settings = {
      Lua = {
        runtime = { version = "LuaJIT" },
        diagnostics = { globals = { "vim" } },
        workspace = { checkThirdParty = false, library = vim.api.nvim_get_runtime_file("", true) },
        telemetry = { enable = false },
      },
    },
  },
  pyright = {},
  zls = {},
  ts_ls = {},
  bashls = {},
  cssls = {},
  html = {},
  jsonls = {},
  yamlls = {},
  taplo = {},
}

-- gopls / goimports / gofumpt 需要本地 Go 来安装和运行。
-- 未安装 Go 的机器不反复触发失败安装；安装 Go 并重启后自动补装。
if vim.fn.executable("go") == 1 then
  servers.gopls = { settings = { gopls = { gofumpt = true } } }
end

return {
  {
    "mason-org/mason.nvim",
    cmd = { "Mason", "MasonInstall", "MasonUpdate" },
    opts = {},
    config = function(_, opts)
      require("mason").setup(opts)
      -- 只在工具缺失时刷新 registry；安装完成后启动无需联网。
      vim.schedule(function()
        local registry = require("mason-registry")
        local wanted = {
          "alejandra",
          "autopep8",
          "isort",
          "pylint",
          "python-lsp-server",
          "tombi",
          "stylua",
          "ruff",
          "prettier",
          "shfmt",
        }
        if vim.fn.executable("go") == 1 then
          vim.list_extend(wanted, { "goimports", "gofumpt" })
        end
        local missing = vim.tbl_filter(function(name)
          return not registry.is_installed(name)
        end, wanted)
        if #missing == 0 then
          return
        end
        registry.refresh(function(ok)
          if not ok then
            vim.notify(
              "Mason registry 不可用；请恢复网络后运行 :MasonUpdate 并重启。",
              vim.log.levels.WARN
            )
            return
          end
          for _, name in ipairs(missing) do
            local found, package = pcall(registry.get_package, name)
            if found and not package:is_installed() and not package:is_installing() then
              package:install()
            end
          end
        end)
      end)
    end,
  },
  {
    "neovim/nvim-lspconfig",
    event = { "BufReadPre", "BufNewFile" },
    dependencies = {
      "mason-org/mason.nvim",
      "mason-org/mason-lspconfig.nvim",
      "hrsh7th/cmp-nvim-lsp",
    },
    config = function()
      vim.diagnostic.config({
        virtual_text = { spacing = 2, prefix = "●" },
        signs = true,
        underline = true,
        update_in_insert = false,
        severity_sort = true,
      })
      vim.api.nvim_create_autocmd("LspAttach", {
        group = vim.api.nvim_create_augroup("UserLspMaps", { clear = true }),
        callback = function(args)
          local function map(mode, lhs, rhs, desc)
            vim.keymap.set(mode, lhs, rhs, { buffer = args.buf, desc = desc, silent = true })
          end
          map("n", "gd", vim.lsp.buf.definition, "LSP: definition")
          map("n", "gD", vim.lsp.buf.declaration, "LSP: declaration")
          map("n", "gi", vim.lsp.buf.implementation, "LSP: implementation")
          map("n", "gr", vim.lsp.buf.references, "LSP: references")
          map("n", "gT", vim.lsp.buf.type_definition, "LSP: type definition")
          map("n", "K", vim.lsp.buf.hover, "LSP: hover")
          map({ "n", "i" }, "<C-k>", vim.lsp.buf.signature_help, "LSP: signature")
          map("n", "<leader>rn", vim.lsp.buf.rename, "LSP: rename")
          map({ "n", "x" }, "<leader>ca", vim.lsp.buf.code_action, "LSP: code action")
        end,
      })
      local capabilities = require("cmp_nvim_lsp").default_capabilities()
      for server, opts in pairs(servers) do
        vim.lsp.config(server, vim.tbl_deep_extend("force", { capabilities = capabilities }, opts))
      end
      require("mason-lspconfig").setup({
        ensure_installed = vim.tbl_keys(servers),
        automatic_enable = vim.tbl_keys(servers),
      })
      -- C# 延续旧配置的禁用决定。
    end,
  },
}
