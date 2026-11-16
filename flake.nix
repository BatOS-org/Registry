{
  description = "meineapp-Registry: App-Definitionen, NixOS-Modul und Katalog";

  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

  outputs = { self, nixpkgs }:
    let
      lib = nixpkgs.lib;

      # Discover all app folders in apps/ automatically, ID = folder name.
      # Each folder contains default.nix, plus icon.svg/icon.png and README.md.
      appDirs = lib.mapAttrs (dir: _: ./apps/${dir})
        (lib.filterAttrs (dir: type: type == "directory" && builtins.pathExists ./apps/${dir}/default.nix)
          (builtins.readDir ./apps));

      # First icon.<ext> found in the app folder, or null.
      findIcon = dir:
        lib.findFirst builtins.pathExists null
          (map (ext: dir + "/icon.${ext}") [ "svg" "png" ]);

      mkWebappBase = import ./lib/mkWebapp.nix { inherit lib; };
      # id and icon come from the folder, the app file can still override them.
      mkWebappFor = id: dir: args: mkWebappBase ({ inherit id; icon = findIcon dir; } // args);

      apps = lib.mapAttrs (id: dir:
        import dir { inherit lib; mkWebapp = mkWebappFor id dir; }) appDirs;
      mkApp = import ./lib/mkApp.nix { inherit lib; };

      catalog = import ./lib/catalog.nix { inherit lib apps appDirs; rev = self.rev or "dirty"; };

      system = "x86_64-linux";
      pkgs = nixpkgs.legacyPackages.${system};

      # Smallest possible system, so that a single app can be evaluated on its own.
      minimalConfig = {
        boot.loader.grub.enable = false;
        fileSystems."/" = { device = "/dev/disk/by-label/nixos"; fsType = "ext4"; };
        system.stateVersion = "25.11";
      };

      evalApp = id: lib.nixosSystem {
        inherit system;
        modules = [
          self.nixosModules.default
          minimalConfig
          { meineapp.apps.${id}.enable = true; }
        ];
      };
    in
    {
      # For the users' systems
      nixosModules.default = {
        imports = lib.mapAttrsToList mkApp apps;
      };

      # For your app: nix eval --json .#catalog
      inherit catalog;

      # nix flake check: evaluates every app in a minimal system (without building it)
      # and checks that the catalog can be generated as JSON.
      # Full build: nix build .#checks.x86_64-linux.<id>.toplevel
      checks.${system} =
        lib.mapAttrs' (id: _:
          let toplevel = (evalApp id).config.system.build.toplevel; in
          lib.nameValuePair "app-${id}"
            ((pkgs.writeText "eval-${id}" (builtins.unsafeDiscardStringContext toplevel.drvPath))
              // { inherit toplevel; })
        ) apps
        // {
          catalog = pkgs.writeText "catalog.json" (builtins.toJSON catalog);
        };
    };
}
