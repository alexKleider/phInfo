#!/bin/bash
set -o errexit
set -o nounset
set -o pipefail

{

  repo=${1:-alexKleider/phInfo}
  branch=${2:-master}

  dir="phInfo-$(echo -n $branch | tr -C a-z - )"

  if [[ ! -d "./$dir" ]]; then
    # Download the scripts
    wget "https://github.com/$repo/archive/$branch.tar.gz" -O - | tar xvz
  fi


  cd "./$dir"
  exec ./ubuntu.sh
}
