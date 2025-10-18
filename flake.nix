{
  description = "Nix flake for allocator-api2";

  inputs = {
    nixpkgs.url = "github:meta-introspector/nixpkgs?ref=feature/CRQ-016-nixify";
    rust-overlay.url = "github:meta-introspector/rust-overlay?ref=feature/CRQ-016-nixify";
    flake-utils.url = "github:meta-introspector/flake-utils?ref=feature/CRQ-016-nixify";
  };

  outputs = { self, nixpkgs, rust-overlay, flake-utils }: 
    flake-utils.lib.eachDefaultSystem
      (system:
        let
          overlays = [ rust-overlay.overlays.default ];
          pkgs = import nixpkgs {
            inherit system overlays;
          };
          rustToolchain = pkgs.rust-bin.nightly.latest.default;
        in
        {
          devShells.default = pkgs.mkShell {
            buildInputs = [ rustToolchain ];
            shellHook = ''
              export RUST_SRC_PATH=${rustToolchain}/lib/rustlib/src/rust/library
            '';
          };
        }
      );
}