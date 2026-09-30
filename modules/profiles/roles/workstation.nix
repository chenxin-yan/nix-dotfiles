# A machine I work on, locally or over SSH.
{ config, ... }:
{
  features.workstation.includes = with config.features; [
    fleet
    development
  ];
}
