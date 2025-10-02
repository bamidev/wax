{ config, lib }:
let
  link_specific_addons =
    { repo }:
    lib.strings.concatStrings (
      lib.lists.forEach config.repos.${repo}.addons (addon: ''
        ln -f -s "$(pwd)/wax/repos/${repo}/${addon}" "wax/addons/${addon}"
      '')
    );
in
''
  set -e

  link_addons() {
    for ADDON in $(ls wax/repos/$1); do
      ln -f -s "$(pwd)/wax/repos/$1/$ADDON" "wax/addons/$ADDON"
    done
  }

  rm -r wax/addons || true
  mkdir wax/addons
  ${lib.strings.concatStrings (
    lib.attrsets.mapAttrsToList (repoName: repoConfig: ''
      ${
        if repoName == "odoo" then
          ''
            link_addons odoo/addons
          ''
        else if (lib.attrsets.hasAttrByPath [ "addons" ] repoConfig) then
          (link_specific_addons { repo = repoName; })
        else
          ''
            link_addons "${repoName}"
          ''
      }
    '') config.repos
  )}
''
