# Wax

Wax is a build system and development environment for Odoo, in Nix.
It is a nix flake, and uses tools like virtualenv and gitaggregator to set up the development environment.
There is no need to prepare your system with the correct python interpreter or corect c development files.
You just need to have the nix package manager installed, and have the flake feature enabled.

All generated files are put inside in the `wax` directory of your working directory,
so that you only need to add one entry to your `.gitignore` file,
and so that your work environment stays tidy.

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
  odooVersion = "16.0";
  databaseName = "my-database";

  odooConfig = {
    options = {
      workers = 4;
    };
  };
}
```


## Commands

In the directory of your flake.nix file, enter the development environment with `nix develop`, edit the `etc/repos.yaml` and `etc/requirements.txt` files, and then you can use the following commands to start running Odoo:
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

If you've edited the `etc/repos.yaml` 

There is also the `shell` command to run the Odoo shell.


## Configuration

`etc/repos.yaml`:
You can write the `etc/repos.yaml` file to configure git-aggregator.
But there is one more feature that is available in this file.
You can specify a whitelist of addons for any repository, if you want only a limited collection of addons from that repository.
For example:
```
OCA/partner-contact:
  remotes:
    oca: https://github.com/OCA/partner-contact
  merges:
    - oca ${ODOO_VERSION}
  addons:
    - base_location
    - partner_firstname
    - partner_pricelist_search
```
This makes the above 3 addons available in `wax/addons`, which is set as the `addons_path` setting in the Odoo configuration by default.

There are pre-defined variables available in this yaml file, as you might have noticed in the example above.
In a wax environment that has already been set up, the available variables can be found in the `wax/env-variables` file.

`etc/requirements.txt`:
This is the usual requirements.txt file that will be used to install Python package in the virtual environment located in `wax/venv`.
There are other (default) packages that are being installed first though.

`requirements.lock`:
If this file didn't exist in the work directory yet, it will be created after a call to `setup` (or when entering the `nix develop` environment).
If you added some new files to `etc/requirements.txt`, you should remove `requirements.lock` so that the new packages can be installed.
As long as the lock file exists, only the contents of the lock file will be installed in the `setup`.

Those are the only 3 configuration files that are hanging around.
The odoo configuration file is being generated from the `config` nix expression (see the example above).
