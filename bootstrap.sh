#!/bin/bash
set -o errexit
set -o nounset
set -o pipefail

{

  if [[ ! -f ./master.tar.gz ]]; then
    # Download the scripts
    wget 'https://github.com/alexKleider/phInfo/archive/master.tar.gz'
    tar xvf master.tar.gz
  fi


  cd ./phInfo-master
  exec ./ubuntu.sh
}
