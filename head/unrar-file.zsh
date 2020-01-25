#!/bin/zsh

password="⑨"

cd $2
if [[ "$3" == "nil" ]] {
  echo "only one, use default password"
  unrar x -p$password $1
} else {
  echo "use user password"
  unrar x -p$3 $1
}


