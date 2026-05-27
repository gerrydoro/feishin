# Feishin Nix Module

This module provides a NixOS service for running the Feishin web application.

## Usage

To enable the Feishin service, add the following to your NixOS configuration:

```nix
{ pkgs, ... }:

{
  services.feishin.enable = true;
  
  # Optional: Change the host and port
  services.feishin.host = "0.0.0.0";
  services.feishin.port = 8080;
  
  # Optional: Configure application settings
  services.feishin.settings = {
    server = {
      hostname = "navidrome.example.com";
      port = 4533;
      type = "navidrome";
    };
    player = {
      volume = 80;
      repeat = "all";
    };
    theme = {
      name = "dark";
      primaryColor = "#1E003D";
    };
  };
}
```

## Options

- `services.feishin.enable`: Enable the Feishin web application service.
- `services.feishin.host`: The host to bind the Feishin web application to (default: "127.0.0.1").
- `services.feishin.port`: The port to bind the Feishin web application to (default: 8080).
- `services.feishin.settings`: Declarative settings for the Feishin web application.
- `services.feishin.package`: The Feishin package to use (default: pkgs.feishin).

## Features

- Builds the Feishin web application using Vite
- Serves the application with a built-in HTTP server
- Configurable host and port settings
- Declarative configuration for application settings
- Automatic user and group creation
- Firewall configuration for the specified port

## Example Configuration

```nix
{
  services.feishin = {
    enable = true;
    host = "0.0.0.0";
    port = 8080;
    settings = {
      server = {
        hostname = "localhost";
        port = 4533;
        type = "navidrome";
      };
      player = {
        volume = 75;
        repeat = "all";
        shuffle = false;
      };
      theme = {
        name = "dark";
        primaryColor = "#1E003D";
      };
    };
  };
}