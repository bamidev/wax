{ odooMajorVersion }:
''
  if [ ${toString odooMajorVersion} -lt 10 ]; then
    wax/venv/bin/python wax/repos/odoo/odoo.py shell -c wax/odoo.cfg ''$@
  else
    wax/venv/bin/python wax/repos/odoo/odoo-bin shell -c wax/odoo.cfg ''$@
  fi
''
