#!/bin/zsh

password="@"

cd $2
if [[ "$3" == " " ]] {
  echo "only one, use default password"
  unrar x -p$password $1
} else {
  echo "use user password"
  unrar x -p$3 $1
}


