cwlVersion: v1.2
class: CommandLineTool
id: awk_bamstats
doc: |
  TGEN awk commands to get information from the tumor and normal samtools BAMstats files.
requirements:
  - class: InlineJavascriptRequirement
  - class: ShellCommandRequirement
  - class: ResourceRequirement
    ramMin: $(inputs.ram*1000)
    coresMin: $(inputs.cpu)
  - class: DockerRequirement
    dockerPull: 'ubuntu:20.04'
  - class: InitialWorkDirRequirement
    listing:
    - entryname: coyote_awk_bamstats.sh
      writable: false
      entry: |
        set -eu

        MAX_LENGTH=`awk -F'\t' '$2 ~ /maximum length/ { print $3 ; exit }' $(inputs.normal_bam_stats.path)`
        NORMAL_AVERAGE_DEPTH=`awk -F'\t' '$1 ~ /^COV/ { TOT=$4 + TOT ; SUM=($3*$4)+SUM} END { print int(SUM/TOT)}' $(inputs.normal_bam_stats.path)`
        TUMOR_AVERAGE_DEPTH=`awk -F'\t' '$1 ~ /^COV/ { TOT=$4 + TOT ; SUM=($3*$4)+SUM} END { print int(SUM/TOT)}' $(inputs.tumor_bam_stats.path)`

        echo -e "$MAX_LENGTH\t$NORMAL_AVERAGE_DEPTH\t$TUMOR_AVERAGE_DEPTH" > out.txt
baseCommand: [/bin/bash, coyote_awk_bamstats.sh]

inputs:
  # Required Inputs
  tumor_bam_stats: { type: 'File', doc: "BAM stats from the normal bam" }
  normal_bam_stats: { type: 'File', doc: "BAM stats from the tumor bam" }

  cpu:
    type: 'int?'
    default: 1
    doc: "Number of CPUs to allocate to this task."
  ram:
    type: 'int?'
    default: 2
    doc: "GB size of RAM to allocate to this task."
outputs:
  max_length:
    type: int
    outputBinding:
      glob: "out.txt"
      loadContents: true
      outputEval: |
        ${
          var field = parseInt(self[0].contents.split('\n')[0].split('\t')[0]);
          return field;
        }
  normal_average_depth:
    type: int
    outputBinding:
      glob: "out.txt"
      loadContents: true
      outputEval: |
        ${
          var field = parseInt(self[0].contents.split('\n')[0].split('\t')[1]);
          return field;
        }
  tumor_average_depth:
    type: int
    outputBinding:
      glob: "out.txt"
      loadContents: true
      outputEval: |
        ${
          var field = parseInt(self[0].contents.split('\n')[0].split('\t')[1]);
          return field;
        }
