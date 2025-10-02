{ lib, config }:
let
  defaultOdooConfig = {
    options = {
      addons_path = "./wax/addons";
      db_name = config.databaseName or "";
      dbfilter = if config.databaseName != null then "^" + config.databaseName + "$" else null;
      logfile = "./wax/log/odoo.log";
    };
  };
  odooConfig = lib.attrsets.recursiveUpdate defaultOdooConfig config.odooConfig;
in
''
  set -e
  cat > wax/odoo.cfg <<HEREDOC
  ${lib.generators.toINI { } odooConfig}
  HEREDOC
''
