{ lib, config }: lib.concatStrings (lib.lists.forEach config.dev.pythonPackages (p: ''
  wax/venv/bin/pip install ${p}
''))
