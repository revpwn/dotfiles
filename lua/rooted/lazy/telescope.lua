return {
  {
    "nvim-telescope/telescope.nvim",
    event        = "VimEnter",
    branch       = "0.1.x",
    dependencies = {
      "nvim-lua/plenary.nvim",
      {
        "nvim-telescope/telescope-fzf-native.nvim",
        build = "make",
        cond  = function() return vim.fn.executable("make")==1 end,
      },
      "nvim-telescope/telescope-ui-select.nvim",
      { "nvim-tree/nvim-web-devicons", enabled = vim.g.have_nerd_font },
    },
    config = function()
      local telescope = require("telescope")
      telescope.setup({
        extensions = {
          ["ui-select"] = require("telescope.themes").get_dropdown(),
        },
      })
      pcall(telescope.load_extension, "fzf")
      pcall(telescope.load_extension, "ui-select")

      local builtin = require("telescope.builtin")
      local km = vim.keymap.set
      km("n", "<leader>sh", builtin.help_tags,     { desc = "[S]earch [H]elp" })
      km("n", "<leader>sf", builtin.find_files,    { desc = "[S]earch [F]iles" })
      km("n", "<leader>ss", builtin.builtin,       { desc = "[S]earch [S]elect" })
      km("n", "<leader>sg", builtin.live_grep,     { desc = "[S]earch by [G]rep" })
      km("n", "<leader>sd", builtin.diagnostics,   { desc = "[S]earch [D]iagnostics" })
      km("n", "<leader>sr", builtin.resume,        { desc = "[S]earch [R]esume" })
      km("n", "<leader><leader>", builtin.buffers,  { desc = "[ ] Find buffers" })

      km("n", "<leader>/", function()
        builtin.current_buffer_fuzzy_find(
          require("telescope.themes").get_dropdown({ winblend=10, previewer=false })
        )
      end, { desc = "[/] Fuzzy search in buffer" })

      km("n", "<leader>sn", function()
        builtin.find_files({ cwd = vim.fn.stdpath("config") })
      end, { desc = "[S]earch [N]vim files" })
    end,
  },
}

