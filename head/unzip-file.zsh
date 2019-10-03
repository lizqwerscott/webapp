#!/bin/zsh

cd $2
if [[ "$3" == " " ]] {
  unzip $1
} else {
  unzip $1 -P$3
}

