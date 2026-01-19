{
  description = "SG9 Studio - Ardour Lua Scripts & Broadcast Workflow Development";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils }:
    flake-utils.lib.eachSystem [ "aarch64-linux" "aarch64-darwin" "x86_64-linux" ] (system:
      let
        pkgs = nixpkgs.legacyPackages.${system};

        # Python with MIDI libraries for testing
        pythonWithMidi = pkgs.python3.withPackages (ps: with ps; [
          python-rtmidi
          mido
          python-osc
        ]);

      in {
        devShells.default = pkgs.mkShell {
          name = "sg9-studio-dev";

          buildInputs = with pkgs; [
            # Lua 5.3 (matches Ardour's version)
            lua5_3

            # Lua development tools
            lua-language-server  # LSP for editor integration
            stylua              # Fast, modern formatter
            luaPackages.luacheck # Linter with custom config support
            luaPackages.busted   # Testing framework

            # MIDI testing tools
            pythonWithMidi

            # Documentation and utilities
            mdformat           # Markdown formatter

            # Nix formatter for flake.nix
            nixfmt
          ] ++ (if pkgs.stdenv.isLinux then [
            # Ardour with luasession CLI (Linux only)
            ardour
          ] else []);

          shellHook = ''
            echo "🎙️  SG9 Studio Development Environment"
            echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
            echo "Platform:    ${pkgs.stdenv.system}"
            echo "Lua:         $(lua -v 2>&1 | head -n1)"
            ${if pkgs.stdenv.isLinux then ''
            echo "Ardour:      $(ardour --version 2>&1 | head -n1 || echo 'not available')"
            echo "Luasession:  $(command -v luasession > /dev/null && echo 'available' || echo 'not available')"
            '' else ''
            echo "Ardour:      not available on macOS (Linux only in nixpkgs)"
            echo "Luasession:  not available (install Ardour manually for macOS testing)"
            ''}
            echo ""
            echo "📚 Documentation:"
            echo "  - STUDIO.md           Studio setup & reference"
            echo "  - ARDOUR-SETUP.md     Ardour template configuration"
            echo "  - MIDI-CONTROLLERS.md MIDI controller integration"
            echo ""
            echo "🧪 Testing Workflow:"
            echo "  1. Syntax check: luacheck scripts/*.lua"
            echo "  2. Format:       stylua scripts/"
            ${if pkgs.stdenv.isLinux then ''
            echo "  3. CLI test:     luasession --test scripts/yourscript.lua"
            '' else ''
            echo "  3. CLI test:     (install Ardour manually for luasession)"
            ''}
            echo "  4. Manual test:  Open in Ardour GUI"
            echo ""
            echo "💡 Virtual MIDI Testing (future):"
            echo "  - Linux: sudo modprobe snd-virmidi (requires kernel module)"
            echo "  - macOS: Use IAC Driver in Audio MIDI Setup"
            echo ""

            # Set up direnv if available
            if command -v direnv > /dev/null; then
              echo "✓ direnv detected - environment will auto-load"
            else
              echo "💡 Install direnv for automatic environment activation"
            fi
          '';
        };

        # Nix flake check - validates Lua syntax
        checks = {
          lua-syntax = pkgs.runCommand "check-lua-syntax" {
            buildInputs = [ pkgs.lua5_3 pkgs.luaPackages.luacheck ];
          } ''
            # Check all Lua files exist and have valid syntax
            cd ${./.}
            if [ -d scripts ]; then
              for file in scripts/*.lua; do
                if [ -f "$file" ]; then
                  echo "Checking $file..."
                  lua -e "dofile('$file')" || exit 1
                  luacheck --no-color "$file" || exit 1
                fi
              done
            fi
            touch $out
          '';
        };
      }
    );
}
