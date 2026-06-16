#!/usr/bin/env bash
set -ex
rm -rf wax
nix develop . --command build-dev
dropdb odoo
createdb odoo
nix develop . --command run --stop-after-init -i base
