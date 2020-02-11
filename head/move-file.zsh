#!/bin/bash
echo "sdasd\n"
echo $1
echo "\n"
echo $2
echo "\n"


file=$1
file=${file/\[/\\[}
file=${file/\]/\\]}
file=${file/\(/\\(}
file=${file/\)/\\)}
file=${file/\ /\\ }

path=$2
path=${path/\[/\\[}
path=${path/\]/\\]}
path=${path/\(/\\(}
path=${path/\)/\\)}
path=${path/\ /\\ }

echo ${file}
echo ${path}

mv ${file} ${path}


