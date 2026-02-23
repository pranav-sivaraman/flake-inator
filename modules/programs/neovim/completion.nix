{ lib, ... }:
{
  flake.aspects.shell = {
    homeManager =
      { pkgs, ... }:
      {
        programs.nvf.settings.vim = {
          autocomplete.blink-cmp = {
            enable = true;
            setupOpts = {
              keymap = {
                preset = "super-tab";
              };
              sources.providers.buffer = {
                transform_items = lib.generators.mkLuaInline ''
                  function(a, items)
                    local keyword = a.get_keyword()
                    local correct, case
                    if keyword:match('^%l') then
                      correct = '^%u%l+$'
                      case = string.lower
                    elseif keyword:match('^%u') then
                      correct = '^%l+$'
                      case = string.upper
                    else
                      return items
                    end

                    -- avoid duplicates from the corrections
                    local seen = {}
                    local out = {}
                    for _, item in ipairs(items) do
                      local raw = item.insertText
                      if raw:match(correct) then
                        local text = case(raw:sub(1,1)) .. raw:sub(2)
                        item.insertText = text
                        item.label = text
                      end
                      if not seen[item.insertText] then
                        seen[item.insertText] = true
                        table.insert(out, item)
                      end
                    end
                    return out
                  end
                '';
              };
              completion = {
                trigger = {
                  show_in_snippet = false;
                };
                menu.draw.components = {
                  kind_icon = {
                    text = lib.generators.mkLuaInline ''
                      function(ctx)
                        local icon = ctx.kind_icon
                        if vim.tbl_contains({ "Path" }, ctx.source_name) then
                          local dev_icon, _ = require("nvim-web-devicons").get_icon(ctx.label)
                          if dev_icon then
                            icon = dev_icon
                          end
                        else
                          icon = require("lspkind").symbol_map[ctx.kind] or ""
                        end
                        return icon .. ctx.icon_gap
                      end
                    '';
                    highlight = lib.generators.mkLuaInline ''
                      function(ctx)
                        local hl = ctx.kind_hl
                        if vim.tbl_contains({ "Path" }, ctx.source_name) then
                          local dev_icon, dev_hl = require("nvim-web-devicons").get_icon(ctx.label)
                          if dev_icon then
                            hl = dev_hl
                          end
                        end
                        return hl
                      end
                    '';
                  };
                };
              };
            };
          };

          lsp.lspkind.enable = true;
        };
      };
  };
}
