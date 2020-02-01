#!/bin/zsh

password="⑨"

cd $2

if [[ "$3" == "nil" ]] {
  echo "only one, use default password"
  7z x $1 -p${password}
} else {
  echo "use user password"
  7z x $1 -p $3  
}

