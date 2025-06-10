# Wax

Wax is a build system and development environment for Odoo, in Nix.
It is a nix flake, and uses tools like virtualenv and gitaggregator to set up the environment.
There is no need to prepare your system with the correct python interpreter or c development files of any libraries.
You just need to have the nix package manager installed, and have the flake feature enabled.

## Example flake

Here is an example Nix flake for you Odoo project:

`flake.nix`:
```
{
  description = "A Wax example";

  inputs = {
    wax.url = "github:bamidev/wax";
  };

  outputs = { self, wax }: {
    devShells.x86_64-linux.default = wax.lib.mkOdooShell {
      system = "x86_64-linux";
      config =  import ./config.nix;
    };
  };
}
```

`config.nix`:
```
{
  odooVersion = 16;
  databaseName = "my-database";

  odooConfig = {
    options = {
      workers = 4;
    };
  };
}
```

# Commands

In the directory of your flake.nix file, enter the development environment with `nix develop`, edit the `etc/repos.yaml` and `etc/requirements.txt` files, and then you can use the following commands to start using Odoo:
```
build
run
```

Or if you want to completely reset the environment:
```
rm -rf wax
setup
build
```

For the Odoo versions that support it, there is also the `shell` command to run a Odoo shell.

