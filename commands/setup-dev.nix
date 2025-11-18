{ config, lib, odooMajorVersion }:
lib.concatStrings (
  lib.lists.forEach config.dev.pythonPackages (p: ''
    wax/venv/bin/pip install ${p}
  '')
) + ''
  wax/venv/bin/pip install ${if odooMajorVersion >= 15 then "-e" else ""} wax/repos/odoo
''
