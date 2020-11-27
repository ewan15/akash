#!/bin/bash

set -e

pricing_script_path="/boot/pricing.sh"
pricing_script_size=$(stat -c%s ${pricing_script_path?})

if [ "$pricing_script_size" -gt 0 ]; then
  echo 'setting up bid price script'
  export AKASH_BID_PRICE_SCRIPT_PATH=$pricing_script_path
  export 'AKASH_BID_PRICE_STRATEGY'='shellScript'
fi

##
# Configuration sanity check
##

# shellcheck disable=SC2015
[ -f "$AKASH_BOOT_KEYS/key.txt" ] && [ -f "$AKASH_BOOT_KEYS/key-pass.txt" ] || {
  echo "Key information not found; AKASH_BOOT_KEYS is not configured properly"
  exit 1
}

env | sort

##
# Import key
##
/bin/akash --home="$AKASH_HOME" keys import --keyring-backend="$AKASH_KEYRING_BACKEND"  "$AKASH_FROM" \
  "$AKASH_BOOT_KEYS/key.txt" < "$AKASH_BOOT_KEYS/key-pass.txt"

##
# Run daemon
##
#/akash --home=$AKASH_HOME provider run --cluster-k8s
/bin/akash --home="$AKASH_HOME" --node="$AKASH_NODE" --chain-id="$AKASH_CHAIN_ID" --keyring-backend="$AKASH_KEYRING_BACKEND" --from="$AKASH_FROM" provider run --cluster-k8s
