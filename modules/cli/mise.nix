{
  features.mise.homeManager = {
    programs.mise = {
      enable = true;
      enableZshIntegration = true;
      globalConfig = {
        settings = {
          experimental = true;
          node.compile = false;
        };
      };
    };
  };
}
