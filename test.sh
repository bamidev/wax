#!/usr/bin/env bash
rm -rf wax
nix develop . --command build-dev
dropdb odoo
createdb odoo
nix develop . --command run --stop-after-init -i base
