.PHONY: all build nix-build nix-flake-build

all: nix-build

mCargo.nix:
	~/nix/vendor/rust/cargo2nix/target/cargo2nix --overwrite # Corrected path for cargo2nix

build:
	cargo build

nix-build:
	nix develop --command cargo build

nix-flake-build:
	nix build

clean:
	rm -f Cargo.nix
	cargo clean
	nix store gc --optimise
