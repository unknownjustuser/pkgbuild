#!/bin/bash
# shellcheck disable=SC2046
# shellcheck disable=SC2035

./setup.sh

for dir in packages/*/; do
  pushd "$dir" || exit
  bash ../../build-pkgbuild.sh
  popd || exit
done

./build-txt.sh
./push.sh
