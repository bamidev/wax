{ odooMajorVersion }:
''
  OPTS="-c wax/odoo.cfg --load=odoo_repl"
  if [ ${toString odooMajorVersion} -lt 10 ]; then
    wax/venv/bin/python wax/repos/odoo/odoo.py shell $OPTS ''$@
  else
    wax/venv/bin/python wax/repos/odoo/odoo-bin shell $OPTS --load=odoo_repl ''$@
  fi
''
