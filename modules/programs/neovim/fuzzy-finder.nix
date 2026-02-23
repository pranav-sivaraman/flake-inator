{
  flake.aspects.shell = {
    homeManager = {
      programs.nvf.settings.vim = {
        fzf-lua.enable = true;

        keymaps = [
          {
            mode = "n";
            key = "<leader>ff";
            action = "<cmd>FzfLua files<CR>";
            desc = "Find files";
          }
          {
            mode = "n";
            key = "<leader>fg";
            action = "<cmd>FzfLua git_files<CR>";
            desc = "Find git files";
          }
          {
            mode = "n";
            key = "<leader>fw";
            action = "<cmd>FzfLua live_grep<CR>";
            desc = "Live grep";
          }
          {
            mode = "n";
            key = "<leader>fb";
            action = "<cmd>FzfLua buffers<CR>";
            desc = "Find buffers";
          }
          {
            mode = "n";
            key = "<leader>fo";
            action = "<cmd>FzfLua oldfiles<CR>";
            desc = "Find recent files";
          }
          {
            mode = "n";
            key = "<leader>fd";
            action = "<cmd>FzfLua diagnostics_document<CR>";
            desc = "Document diagnostics";
          }
          {
            mode = "n";
            key = "<leader>fr";
            action = "<cmd>FzfLua lsp_references<CR>";
            desc = "LSP references";
          }
          {
            mode = "n";
            key = "gd";
            action = "<cmd>FzfLua lsp_definitions<CR>";
            desc = "Go to definition";
          }
        ];
      };
    };
  };
}
