{ lib, config }:
let
  defaultOdooConfig = {
    options = {
      addons_path = "./wax/addons";
      db_name = config.database.name or "";
      dbfilter = if config.database.name != null then "^" + config.database.name + "$" else null;
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
