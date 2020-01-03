#!/usr/bin/env bash
sudo /usr/sbin/ntpd -gq

sudo chown tgic:tgic -R /home/tgic
sudo rm -rf "$HOME/.config/@tgic"
sudo rm -rf "$HOME/.config/tgic-core"

shopt -s expand_aliases
alias ark="$HOME/core-bridgechain/packages/core/bin/run"
echo 'alias tgic="$HOME/core-bridgechain/packages/core/bin/run"' >> ~/.bashrc
alias brc='source ~/.bashrc'
echo 'export PATH=$(yarn global bin):$PATH' >> ~/.bashrc
export PATH=$(yarn global bin):$PATH
ark config:publish --network=$NETWORK
sudo rm -rf $HOME/.config/tgic-core/$NETWORK/.env


if [ "$MODE" = "forger" ]; then
  SECRET=`openssl rsautl -decrypt -inkey /run/secrets/secret.key -in /run/secrets/secret.dat`
  CORE_FORGER_PASSWORD=`openssl rsautl -decrypt -inkey /run/secrets/bip.key -in /run/secrets/bip.dat`

  # configure
  if [ -n "$SECRET" ] && [ -n "$CORE_FORGER_PASSWORD" ]; then
    tgic config:forger:bip38 --bip39 "$SECRET" --password "$CORE_FORGER_PASSWORD"
  elif [ "$MODE" = "forger" ] && [ -z "$SECRET" ] && [ -z "$CORE_FORGER_PASSWORD" ]; then
    echo "set SECRET and/or CORE_FORGER_PASWORD if you want to run a forger"
    exit
  elif [ -n "$SECRET" ] && [ -z "$CORE_FORGER_PASSWORD" ]; then
    tgic config:forger:bip39 --bip39 "$SECRET"
  fi
fi

# relay
if [[ "$MODE" = "relay" ]]; then
    tgic relay:start --no-daemon
fi

# forging
if [ "$MODE" = "forger" ] && [ -n "$SECRET" ] && [ -n "$CORE_FORGER_PASSWORD" ]; then
    export CORE_FORGER_BIP38=$(grep bip38 /home/node/.config/ark-core/$NETWORK/delegates.json | awk '{print $2}' | tr -d '"')
    export CORE_FORGER_PASSWORD
    sudo rm -rf /run/secrets/*
    tgic core:start --no-daemon
elif [ "$MODE" = "forger" ] && [ -z "$SECRET" ] && [ -z "$CORE_FORGER_PASSWORD" ]; then
    echo "set SECRET and/or CORE_FORGER_PASWORD if you want to run a forger"
    exit
    elif [ "$MODE" = "forger" ] && [ -n "$SECRET" ] && [ -z "$CORE_FORGER_PASSWORD" ]; then
    tgic core:start --no-daemon
fi