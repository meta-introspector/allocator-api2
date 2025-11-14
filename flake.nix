{
  inputs = {
    nixpkgs.url = "github:meta-introspector/nixpkgs?ref=feature/CRQ-016-nixify";
    flake-utils.url = "github:meta-introspector/flake-utils?ref=feature/CRQ-016-nixify";
    cargo2nix.url = "github:cargo2nix/cargo2nix/release-0.12";
    rust-overlay.url = "github:meta-introspector/rust-overlay?ref=feature/CRQ-016-nixify";
  };

  outputs = inputs: with inputs;
    flake-utils.lib.eachDefaultSystem
      (system:
        let
          pkgs = import nixpkgs {
            inherit system;
            overlays = [ cargo2nix.overlays.default rust-overlay.overlays.default ];
            config = {
              permittedInsecurePackages = [ "openssl-1.1.1w" ];
            };
          };
          myRustc = pkgs.rust-bin.nightly."2025-09-16".default;
          rustPkgs = pkgs.rustBuilder.makePackageSet {
            packageFun = import ./Cargo.nix;
            rustToolchain = myRustc;
            # rootFeatures = [ ... ]; # Add specific features if needed
            # packageOverrides = pkgs: [ ... ]; # Add specific overrides if needed
          };
          workspaceShell = pkgs.mkShell {
            packages = [ pkgs.statix pkgs.openssl_1_1.dev ];
            shellHook = ''
!              export PKG_CONFIG_PATH=${pkgs.openssl_1_1.dev}/lib/pkgconfig:$PKG_CONFIG_PATH
            '';
          };
          
        in
          rec {
            devShells = {
              default = workspaceShell;
            };
            
            packages = rec {
              allocator-api2 = rustPkgs.workspace.allocator-api2 {};
              default = allocator-api2;
            };
            apps = rec {
              allocator-api2-app = { type = "app"; program = "${packages.default}/bin/allocator-api2"; };
              default = allocator-api2-app;
            };
          }
      );
}
