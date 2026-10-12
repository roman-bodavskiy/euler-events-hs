{
  inputs = {

    common.url = "github:nammayatri/common?ref=ghc-98-upgrade";

    nixpkgs.follows = "common/nixpkgs";
    flake-parts.follows = "common/flake-parts";
    haskell-flake.follows = "common/haskell-flake";

    prometheus-haskell.url = "github:nammayatri/prometheus-haskell?ref=ghc-98-upgrade";
    prometheus-haskell.inputs.haskell-flake.follows = "haskell-flake";
  };
  outputs = inputs@{ self, nixpkgs, flake-parts, ... }:
    flake-parts.lib.mkFlake { inherit inputs; } ({ withSystem, ... }: {
      systems = nixpkgs.lib.systems.flakeExposed;
      imports = [
        inputs.common.flakeModules.ghc98
        inputs.haskell-flake.flakeModule
      ];
      perSystem = { self', pkgs, lib, config, ... }: {
        packages.default = self'.packages.euler-events-hs;
        haskellProjects.default = {
          basePackages = config.haskellProjects.ghc98.outputs.finalPackages;
          imports = [
            inputs.prometheus-haskell.haskellFlakeProjectModules.output
          ];

          packages = {};

          settings = {
            prometheus-client = {
              check = false;
            };
            prometheus-proc = {
              jailbreak = true;
            };
            euler-events-hs = {
              jailbreak = true;
              check = false;
            };
          };
        };
      };
    });
}
