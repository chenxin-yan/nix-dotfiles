{
  features.mise.homeManager = {
    programs.mise = {
      enable = true;
      globalConfig = {
        settings = {
          experimental = true;
          node.compile = false;
        };
      };
    };
  };
}
