#!/usr/bin/env bash

echo "================ Regenerating ./Cargo.nix =================="

cargo run -- "generate" "-n" "./nixpkgs.nix" "-o" "./Cargo.nix"

nix eval --json -f ./tests.nix buildTestConfigs |\
 jq -r .[].pregeneratedBuild |\
 while read cargo_nix; do
   if [ "$cargo_nix" = "null" ]; then
     continue
   fi

   dir=$(dirname "$cargo_nix")

   echo "=============== Regenerating ${cargo_nix} ================"

   cargo run -- "generate" -f "$dir/Cargo.toml" -o "$cargo_nix" ||\
     { echo "Regeneration of ${cargo_nix} failed." >&2 ; exit 1; }
 done
