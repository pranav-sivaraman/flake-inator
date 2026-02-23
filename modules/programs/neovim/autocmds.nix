{ lib, ... }:
{
  flake.aspects.shell = {
    homeManager =
      { ... }:
      {
        programs.nvf.settings.vim = {
          augroups = [
            {
              name = "RelativeNumberModes";
              clear = true;
            }
          ];

          autocmds = [
            {
              event = [ "ModeChanged" ];
              pattern = [ "*:[V\x16i]*" ];
              group = "RelativeNumberModes";
              desc = "Show relative line numbers in visual and insert modes";
              callback = lib.generators.mkLuaInline ''
                function()
                  vim.wo.relativenumber = vim.wo.number
                end
              '';
            }
            {
              event = [ "ModeChanged" ];
              pattern = [ "[V\x16i]*:*" ];
              group = "RelativeNumberModes";
              desc = "Hide relative line numbers when leaving visual/insert modes";
              callback = lib.generators.mkLuaInline ''
                function()
                  vim.wo.relativenumber = string.find(vim.fn.mode(), '^[V\22i]') ~= nil
                end
              '';
            }
            {
              event = [ "TextYankPost" ];
              pattern = [ "*" ];
              desc = "Highlight yanked text";
              callback = lib.generators.mkLuaInline ''
                function()
                  if vim.fn.has('nvim-0.11') == 0 then
                    vim.highlight.on_yank({ higroup = "Search" })
                  else
                    vim.hl.on_yank({ higroup = "Search" })
                  end
                end
              '';
            }
            {
              event = [ "BufRead" ];
              desc = "Restore cursor position to last known location";
              callback = lib.generators.mkLuaInline ''
                function(opts)
                  vim.api.nvim_create_autocmd('BufWinEnter', {
                    once = true,
                    buffer = opts.buf,
                    callback = function()
                      local ft = vim.bo[opts.buf].filetype
                      local last_known_line = vim.api.nvim_buf_get_mark(opts.buf, '"')[1]
                      if
                        not (ft:match('commit') and ft:match('rebase'))
                        and last_known_line > 1
                        and last_known_line <= vim.api.nvim_buf_line_count(opts.buf)
                      then
                        vim.api.nvim_feedkeys([[g`"]], 'nx', false)
                      end
                    end,
                  })
                end
              '';
            }
          ];
        };
      };
  };
}
