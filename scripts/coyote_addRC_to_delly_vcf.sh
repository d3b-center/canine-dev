#!/bin/bash
set -eu
set -o pipefail

SHORT=c:,d:,h
LONG=city1:,city2:,help
OPTS=$(getopt --alternative --name weather --options $SHORT --longoptions $LONG -- "$@")

PYTHON_SCRIPT=$1
PASS_VCF=$2
TUMOR_BAM=$3
NORMAL_BAM=$4
SLOP=$5
PASS_VCF_BASENAME="$(basename -- $PASS_VCF)"

if [[ $(grep -m 1 -c "ENDPOSSV" $PASS_VCF) -ne 1 ]]
then
	sed 's/ID=END/ID=ENDPOSSV/ ; s/;END=/;ENDPOSSV=/' $PASS_VCF > $PASS_VCF_BASENAME.mod
	python $PYTHON_SCRIPT -i $PASS_VCF_BASENAME.mod -t $TUMOR_BAM -n $NORMAL_BAM -s $SLOP
elif [[ -e $PASS_VCF ]]
then
	mv $PASS_VCF $PASS_VCF_BASENAME.mod_addDist.vcf
fi
