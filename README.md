# Wax

Wax is a build system and development environment for Odoo, in Nix.
It is a nix flake, and uses standard tools like `virtualenv` and `git` to set up the development
environment. There is no need to prepare your system with the correct python interpreter or correct
c development files. You just need to have the nix package manager installed, and have the flake
feature enabled.

Almost all generated files are put inside in the `wax` directory of your working directory, so that
you only need to add one entry to your `.gitignore` file, and so that your work environment stays
tidy. There are however several lock files generated to keep your environment reproducable.

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

  repos = {
    odoo = {
      ref = "16.0";
      url = "https://github.com/odoo/odoo.git";
      remotes = {   # Git remotes here
        bamidev = "https://github.com/bamidev/odoo.git";
      };
      merges = {    # All commits that will be merged into the repo
        bamidev = "16.0-fix-a-thing";
      };
    }

    partner-contact = {
      # When the ref attribute is not set, will default to what is in odooVersion
      # When the url attribute is not set, will default to https://github.com/OCA/partner-contact.git
      remotes = {
        therp = "https://github.com/Therp/partner-contact.git";
      };
      # When multiple branches from the same repo need to be merged in, we can't use attrsets, so
      # use lists instead:
      merges = [
        ["therp" "16.0-add-partner_multi_relation_address"]
        ["therp" "16.0-add-partner_multi_relation_function"]
      ];
    };

    # Leaving these empty means you will get standard server-tools and web repos from the OCA
    server-tools = {};
    web = {};
  };

  pythonRequirements = [
    "psycopg2"
    "debugpy"
  ];
}
```


## Commands

Assuming you have your configuration like as the example above, you can enter the development
environment with `nix develop`. After everything has been installed and you're inside the
environment, the TL;DR to get started is:

```
build
run
```

### build

The `build` command will set everything up. You can just remove the `wax` folder if you want
to completely rebuild everyting from scratch again.
Moreover, the `build` command really just runs the following commands inchronological order:

### build-venv

`build-venv` builds the virtual environment. If you need to update a repository to a later commit,
you can remove the commit hash from the `repos.lock` file (or remove the file altogether), and run
`build-venv` again.
Building the virtual environment may fail if you have `pythonRequirements` that are causing
conflicts with eachother, or in combination with the packages or python version that are provided
through Wax itself. To fix this, you can try:

```
rm -rf requirements.lock wax/venv
build-venv
```

### build-repos

`build-repos` builds the git repositories. To rebuild them, you can do:
```
rm -rf wax/repos
build-repos
```


### build-addons

`build-addons` builds the directory of addon links `wax/addons`. You don't need to delete anything
to reset it, just run `build-addons` and it will be completely rebuild.

### build-config

`build-config` (re)builds the odoo configuration file.

### shell

There is also the `shell` command, to run the Odoo shell.

### run

Runs Odoo. You may not see any output in most cases, because by default, the output is logged to
`wax/log/odoo.log`.

## Configuration

Most configuration is done within your flake, within the `config` attrset.

There will be more documentation about the config soon. For the moment, you will have to make do
with the example above.
