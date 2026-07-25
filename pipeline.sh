#!/bin/bash

set -euo pipefail


echo "Select the type of Reads: 
1. Single End
2. Paired End
3. Exit"
read -p "Option :" option

case $option in
   1) MODO="single" ;;
   2) MODO="paired" ;;
   3) echo "Exit..."; exit 0 ;;
   *) echo "Invalid option"; exit 1 ;;
esac

#Export of MODO variable  according to the type of reads selected
export MODO

#Run the scripts
bash ./scripts/fastqc.sh
bash ./scripts/hisat2.sh
bash ./scripts/featurecounts.sh
