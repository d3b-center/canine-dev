cwlVersion: v1.2
class: CommandLineTool
id: coyote_awk_bamstats 
doc: |
  TGEN awk commands to get information from the 
requirements:
  - class: InlineJavascriptRequirement
  - class: ShellCommandRequirement
  - class: ResourceRequirement
    ramMin: $(inputs.ram*1000)
    coresMin: $(inputs.cpu)
  - class: DockerRequirement
    dockerPull: 'staphb/bcftools:1.10.2'
  - class: InitialWorkDirRequirement
    listing:
    - entryname: coyote_omega_awk.sh 
      writable: false
      entry: |
        set -eu
        set -o pipefail

        if [ $(inputs.male) ]
        then
          awk -F'\t' '{ if ($1 == "X" || $1 == "Y") { $4 = $4-1} ; { OFS = "\t" ; print $0 }}' $(inputs.input_denoised_cr.path) > \
            $(inputs.output_basename).denoisedCR.genderCorrected.tsv
    
          awk -F'\t' '{ if ($1 == "X" || $1 == "Y") { $6 = $6-1 ; $7 = $7-1 ; $8 = $8-1 } ; { OFS = "\t" ; print $0 }}' $(inputs.input_model_final.path) > \
            $(inputs.output_basename).modelFinal.genderCorrected.seg
    
        else
          cp $(inputs.input_denoised_cr.path) $(inputs.output_basename).denoisedCR.genderCorrected.tsv
          cp $(inputs.input_model_final.path) $(inputs.output_basename).modelFinal.genderCorrected.seg
        fi
    
        for CHR in {1..39}
        do
          if [[ $CHR -eq "39" ]]
          then
            CHR="X"
          else
            CHR="$CHR"
          fi
    
          declare START_$CHR=\$(awk -F'\t' -v CHROM=$CHR '$1 == CHROM' $(inputs.output_basename).modelFinal.genderCorrected.seg | sort -k2,2n | awk -F'\t' 'NR == 1 { print $2 }')
          export START_$CHR
          declare STOP_$CHR=\$(awk -F'\t' -v CHROM=$CHR '$1 == CHROM' $(inputs.output_basename).modelFinal.genderCorrected.seg | sort -k3,3nr | awk -F'\t' 'NR == 1 { print $3 }')
          export STOP_$CHR
        done
    
        for CHR in {1..39}
        do
          if [[ ${CHR} -eq "39" ]]
          then
            CHR="X"
          else
            CHR="$CHR"
          fi
    
          eval "START=\\\${START_${CHR}}"
          eval "STOP=\\\${STOP_${CHR}}"
    
          START_C=\$(awk -v CHR=$CHR '$1==CHR { print $2 }' inputs.input_centromeres.path)
          STOP_C=\$(awk -v CHR=$CHR '$1==CHR { print $3 }' inputs.input_centromeres.path)
    
          if [[ $START -ge $START_C ]]
          then
            START=$STOP_C
          fi
    
          export CHR
          export START
          export START_C
          export STOP
          export STOP_C
    
          echo -e "$CHR\t$START\t$STOP"
          echo -e "$CHR\t$START_C\t$STOP_C"
    
          LINES=\$(wc -l < $(inputs.output_basename).modelFinal.genderCorrected.seg)
          HEADER=\$(grep -c "@" $(inputs.output_basename).modelFinal.genderCorrected.seg || :)
    
          awk -F'\t' -v HEADER="$HEADER" -v CHROM="$CHR" -v START="$START" -v STOP="$STOP" -v LINES="$LINES" -v STARTC="$START_C" -v STOPC="$STOP_C" 'BEGIN { INC=1 } ;
            # Skip GATK header
            $0 ~ /^@/ { next } ;
            # Print the header
            NR == HEADER + 1 { print $0 ; next } ;
            # Remove segments that fall within the centromere
            $2 == CHROM && $3 >= STARTC && $4 <= STOPC { next } ;
            # Store the second line in the seg file and set the INC to 2 if we are working on the chromosome
            NR == HEADER + 2 && $1 == CHROM { C1=$1 ; C2=$2 ; C3=$3 ; C4=$4 ; C5=$5 ; C6=$6 ; C7=$7 ; C8=$8 ; C9=$9 ; C10=$10 ; C11=$11 ; INC=2 ; next } ;
            NR == HEADER + 2 && $1 != CHROM { C1=$1 ; C2=$2 ; C3=$3 ; C4=$4 ; C5=$5 ; C6=$6 ; C7=$7 ; C8=$8 ; C9=$9 ; C10=$10 ; C11=$11 ; next } ;
            ## Last line of seg file
            NR == LINES && $1 == CHROM && INC == 1 { OFS = "\t" ; print C1,C2,C3,C4,C5,C6,C7,C8,C9,C10,C11 ; print $1,START,STOP,$4,$5,$6,$7,$8,$9,$10,$11 ; next } ;
            NR == LINES && $1 == CHROM && INC == 2 { OFS = "\t" ; print C1,START,C3,C4,C5,C6,C7,C8,C9,C10,C11 ; print $1,$2,STOP,$4,$5,$6,$7,$8,$9,$10,$11 ; next } ;
            NR == LINES && $1 == CHROM && INC == 3 { OFS = "\t" ; print C1,C2,C3,C4,C5,C6,C7,C8,C9,C10,C11 ; print $1,$2,STOP,$4,$5,$6,$7,$8,$9,$10,$11 ; next } ;
            NR == LINES && $1 != CHROM && INC == 2 { OFS = "\t" ; print C1,START,STOP,C4,C5,C6,C7,C8,C9,C10,C11 ; print $1,$2,$3,$4,$5,$6,$7,$8,$9,$10,$11 ; next } ;
            NR == LINES && $1 != CHROM && INC == 3 { OFS = "\t" ; print C1,C2,STOP,C4,C5,C6,C7,C8,C9,C10,C11 ; print $1,$2,$3,$4,$5,$6,$7,$8,$9,$10,$11 ; next } ;
            NR == LINES && $1 != CHROM { OFS = "\t" ; print C1,C2,C3,C4,C5,C6,C7,C8,C9,C10,C11 ; print $1,$2,$3,$4,$5,$6,$7,$8,$9,$10,$11 ; next } ;
            ### Segment is the current chromosome we are working on
            ## First segment in the CHROM, print previous segment variables
            NR != LINES && $1 == CHROM && INC == 1 { OFS = "\t" ; print C1,C2,C3,C4,C5,C6,C7,C8,C9,C10,C11 ; C1=$1 ; C2=$2 ; C3=$3 ; C4=$4 ; C5=$5 ; C6=$6 ; C7=$7 ; C8=$8 ; C9=$9 ; C10=$10 ; C11=$11 ; INC=2 ; next } ;
            ## Second segment for CHROM, Tests and print is for the First segment
            # If the previous segments start is >= the centromere stop
            NR != LINES && $1 == CHROM && INC == 2 && C2 >= STOPC { OFS = "\t" ; print C1,START,C3,C4,C5,C6,C7,C8,C9,C10,C11 ; C1=$1 ; C2=$2 ; C3=$3 ; C4=$4 ; C5=$5 ; C6=$6 ; C7=$7 ; C8=$8 ; C9=$9 ; C10=$10 ; C11=$11 ; INC=3 ; next } ;
            NR != LINES && $1 == CHROM && INC == 2 && C2 < STARTC && C3 < STOPC && $2 > STARTC && $3 > STOPC { OFS = "\t" ; print C1,START,STARTC,C4,C5,C6,C7,C8,C9,C10,C11 ; C1=$1 ; C2=STOPC ; C3=$3 ; C4=$4 ; C5=$5 ; C6=$6 ; C7=$7 ; C8=$8 ; C9=$9 ; C10=$10 ; C11=$11 ; INC=3 ; next } ;
            NR != LINES && $1 == CHROM && INC == 2 && C2 < STARTC && C3 < STOPC && $2 < STARTC { OFS = "\t" ; print C1,START,C3,C4,C5,C6,C7,C8,C9,C10,C11 ; C1=$1 ; C2=$2 ; C3=$3 ; C4=$4 ; C5=$5 ; C6=$6 ; C7=$7 ; C8=$8 ; C9=$9 ; C10=$10 ; C11=$11 ; INC=3 ; next } ;
            NR != LINES && $1 == CHROM && INC == 2 && C3 > STOPC { OFS = "\t" ; print C1,START,C3,C4,C5,C6,C7,C8,C9,C10,C11 ; C1=$1 ; C2=$2 ; C3=$3 ; C4=$4 ; C5=$5 ; C6=$6 ; C7=$7 ; C8=$8 ; C9=$9 ; C10=$10 ; C11=$11 ; INC=3 ; next } ;
            # Third segment for CHROM
            NR != LINES && $1 == CHROM && INC == 3 && C2 < STARTC && C3 < STOPC && $2 > STARTC && $3 > STOPC { OFS = "\t" ; print C1,C2,STARTC,C4,C5,C6,C7,C8,C9,C10,C11 ; C1=$1 ; C2=STOPC ; C3=$3 ; C4=$4 ; C5=$5 ; C6=$6 ; C7=$7 ; C8=$8 ; C9=$9 ; C10=$10 ; C11=$11 ; next } ;
            NR != LINES && $1 == CHROM && INC == 3 && C2 < STARTC && C3 < STOPC && $2 < STARTC { OFS = "\t" ; print C1,C2,C3,C4,C5,C6,C7,C8,C9,C10,C11 ; C1=$1 ; C2=$2 ; C3=$3 ; C4=$4 ; C5=$5 ; C6=$6 ; C7=$7 ; C8=$8 ; C9=$9 ; C10=$10 ; C11=$11 ; next } ;
            NR != LINES && $1 == CHROM && INC == 3 { OFS = "\t" ; print C1,C2,C3,C4,C5,C6,C7,C8,C9,C10,C11 ; C1=$1 ; C2=$2 ; C3=$3 ; C4=$4 ; C5=$5 ; C6=$6 ; C7=$7 ; C8=$8 ; C9=$9 ; C10=$10 ; C11=$11 ; next } ;
            ## Segment is on a Chromosome that is NOT our current CHROM
            NR != LINES && $1 != CHROM && INC == 2 { OFS = "\t" ; print C1,START,STOP,C4,C5,C6,C7,C8,C9,C10,C11 ; C1=$1 ; C2=$2 ; C3=$3 ; C4=$4 ; C5=$5 ; C6=$6 ; C7=$7 ; C8=$8 ; C9=$9 ; C10=$10 ; C11=$11 ; INC=1 ; next } ;
            NR != LINES && $1 != CHROM && INC == 3 { OFS = "\t" ; print C1,C2,STOP,C4,C5,C6,C7,C8,C9,C10,C11 ; C1=$1 ; C2=$2 ; C3=$3 ; C4=$4 ; C5=$5 ; C6=$6 ; C7=$7 ; C8=$8 ; C9=$9 ; C10=$10 ; C11=$11 ; INC=1 ; next } ;
            NR != LINES && $1 != CHROM && INC == 1 { OFS = "\t" ; print C1,C2,C3,C4,C5,C6,C7,C8,C9,C10,C11 ; C1=$1 ; C2=$2 ; C3=$3 ; C4=$4 ; C5=$5 ; C6=$6 ; C7=$7 ; C8=$8 ; C9=$9 ; C10=$10 ; C11=$11 ; next }' $(inputs.output_basename).modelFinal.genderCorrected.seg > $(inputs.output_basename).modelFinal.genderCorrected.seg.temp
    
          mv $(inputs.output_basename).modelFinal.genderCorrected.seg.temp $(inputs.output_basename).modelFinal.genderCorrected.seg
        done
baseCommand: [/bin/bash, coyote_awk_bamstats.sh]

inputs:
  # Required Inputs
  input_denoised_cr: { type: 'File', doc: "" }
  input_model_final: { type: 'File', doc: "" }
  input_centromere: { type: 'File', doc: "" }
  output_basename: { type: 'string' }
  male: { type: 'boolean' }

  cpu:
    type: 'int?'
    default: 1
    doc: "Number of CPUs to allocate to this task."
  ram:
    type: 'int?'
    default: 2
    doc: "GB size of RAM to allocate to this task."
outputs:
  modelfinal_corr:
    type: File
    outputBinding:
      glob: '*.modelFinal.genderCorrected.seg' 
  denoisedcr_corr:
    type: File
    outputBinding:
      glob: '.denoisedCR.genderCorrected.tsv'
