{ ... }:
{
  programs.helix = {
    enable = true;
    settings = {
      keys = {
        insert = {
          j.j = "normal_mode";
        };
        normal = {
          A-i = "move_line_up";
          A-k = "move_line_down";
          # Workaround for using C-A-i in Zellij
          A-tab = [
            "extend_to_line_bounds"
            "delete_selection"
            "move_line_up"
            "paste_before"
          ];
          C-A-i = [
            "extend_to_line_bounds"
            "delete_selection"
            "move_line_up"
            "paste_before"
          ];
          C-A-k = [
            "extend_to_line_bounds"
            "delete_selection"
            "paste_after"
          ];
        };
      };
      editor = {
        bufferline = "multiple";
        lsp.display-messages = true;
        indent-guides.render = true;
        cursorline = true;
        cursorcolumn = true;
        cursor-shape.insert = "bar";
        scrolloff = 0;
        color-modes = true;
        # whitespace.render = "on-selection";
        statusline = {
          left = [
            "mode"
            "spinner"
            "file-name"
            "version-control"
            "separator"
            "file-modification-indicator"
          ];
          right = [
            "diagnostics"
            "separator"
            "register"
            "selections"
            "primary-selection-length"
            "separator"
            "position"
            "total-line-numbers"
            "position-percentage"
            "file-encoding"
          ];
          separator = "";
        };
      };
    };
  };
}
