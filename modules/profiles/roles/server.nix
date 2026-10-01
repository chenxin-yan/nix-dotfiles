# Runs unattended and is reached over the network.
{ config, ... }:
{
  features.server.includes = with config.features; [
    fleet
  ];
}
