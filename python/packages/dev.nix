# Developer-tooling python packages (LSP server + plugins, linters, debugger), keyed by odoo major
# version. Not yet ported to every odoo major version - see python/packages/dev/19.nix's header for
# what's covered and why some transitive deps are still missing there.
{
  pkgs,
  lib,
  python,
  pythonDefaultPackages,
  odooPackages,
  odooMajorVersion,
}:
if odooMajorVersion == 19 then
  import ./dev/19.nix {
    inherit
      pkgs
      lib
      python
      pythonDefaultPackages
      odooPackages
      ;
  }
else
  { }
