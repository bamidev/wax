{
  odooVersion = "16.0";
  databaseName = "odoo";

  odooConfig = {
    options = {
      workers = 4;
    };
  };

  repos.spec = {
    odoo = {
      ref = "16.0";
      url = "https://github.com/odoo/odoo.git";
    };

    partner-contact = {
      # When the ref attribute is not set, will default to what is in odooVersion
      # When the url attribute is not set, will default to https://github.com/OCA/partner-contact.git
      remotes = {
        therp = "https://github.com/OCA/partner-contact.git";
      };
      # TODO: Add some merges to test
      merges = [
      ];
    };

    server-tools = {};
    web = {};
  };

  repos.depth.deepen.base = 500;
  repos.depth.deepen.merge = 50;
  repos.depth.initial.base = 10;
  repos.depth.initial.merge = 20;
}
