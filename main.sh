#!/bin/bash
# shellcheck disable=SC2046
# shellcheck disable=SC2035

ls -la
chmod +x *.sh
./setup.sh
./build-pkgbuild.sh
./build-txt.sh
./push.sh
