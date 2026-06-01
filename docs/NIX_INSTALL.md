# Feishin Nix Installation Guide

To install Feishin on your NixOS machine:

1. Add the flake to your configuration:
   ```nix
   {
     inputs.feishin.url = "github:jeffvli/feishin";
     # ...
     outputs = { self, nixpkgs, feishin }: {
       nixosConfigurations.my-machine = nixpkgs.lib.nixosSystem {
         modules = [
           feishin.nixosModules.default
           {
             services.feishin = {
               enable = true;
               host = "0.0.0.0";
               port = 8080;
             };
           }
         ];
       };
     };
   }
   ```

2. Rebuild your system:
   ```bash
   nixos-rebuild switch
   ```
