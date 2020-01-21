#!/bin/zsh

cd $2
if [[ "$3" == "nil" ]] {
  unzip $1
} else {
  unzip $1 -P$3
}

