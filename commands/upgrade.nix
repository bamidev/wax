{ odooMajorVersion, ... }:
''
  if [ ${toString odooMajorVersion} -lt 10 ]; then
    wax/venv/bin/python wax/repos/odoo/odoo.py -c wax/odoo.cfg --stop-after-init -u ''$1
  else
    wax/venv/bin/python wax/repos/odoo/odoo-bin -c wax/odoo.cfg --stop-after-init -u ''$1
  fi
''
