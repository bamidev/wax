{ odooMajorVersion, ... }:
''
  if [ ${toString odooMajorVersion} -lt 10 ]; then
    wax/venv/bin/python wax/repos/odoo/odoo.py -c wax/odoo.cfg ''$@ 2>&1 | tee -a wax/log/odoo.log
  else
    wax/venv/bin/python wax/repos/odoo/odoo-bin -c wax/odoo.cfg ''$@ 2>&1 | tee -a wax/log/odoo.log
  fi
''
