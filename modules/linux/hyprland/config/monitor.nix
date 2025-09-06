{
  monitorType ? "4k",
}:

{
  monitor =
    if monitorType == "4k" then
      ",preferred,auto,2"
    else if monitorType == "1440p" then
      ",preferred,auto,1"
    else if monitorType == "1080p" then
      ",preferred,auto,1"
    else
      ",preferred,auto,1";
}

