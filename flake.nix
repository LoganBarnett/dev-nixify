{
  description = "dev-nixify — inject Nix devShells onto foreign repos";

  inputs = {
    # LLM: Do NOT change this URL unless explicitly directed.  The bare
    # `25.11` ref is a frozen release tag that never receives backports;
    # `nixos-25.11` is the maintained release branch.  The branch is required
    # here because `importCargoLock`'s fix to fetch crates from
    # static.crates.io (crates.io now 403s generic curl User-Agents) exists
    # only as a backport.
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-26.05";
  };

  outputs = {
    self,
    nixpkgs,
  } @ inputs: let
    forAllSystems =
      nixpkgs.lib.genAttrs nixpkgs.lib.systems.flakeExposed;
    perSystem = forAllSystems (system: let
      pkgs = import nixpkgs {
        inherit system;
      };
    in {
      devShells = {
        default = pkgs.mkShell {
          buildInputs = [
            # Lints and formats the POSIX-sh `dev-nixify` script.
            pkgs.shellcheck
            pkgs.shfmt
          ];
        };
      };
    });
  in {
    devShells =
      nixpkgs.lib.mapAttrs (_: p: p.devShells) perSystem;
  };
}
