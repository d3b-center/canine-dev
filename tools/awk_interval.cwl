cwlVersion: v1.2
class: CommandLineTool
id: awk_interval 
doc: |
  TGEN awk command to get min interval size from an interval list. 
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

        MIN_INTERVAL=`awk -F'\t' -v MAX_LENGTH=$(inputs.max_length) 'BEGIN { MIN = MAX_LENGTH } $1 !~ /@/ { if ( $3-$2 < MIN ) { MIN = $3-$2 }} END { print MIN }' $(inputs.interval_list.path)`

        echo -e "$MIN_INTERVAL" > out.txt 
baseCommand: [/bin/bash, coyote_awk_bamstats.sh]

inputs:
  # Required Inputs
  enable_tool: { type: 'string?', doc: "Killswitch for tool in workflow" }
  max_length: { type: 'int', doc: "Max length value from the normal bam stats file" }
  interval_list: { type: 'File', doc: "Interval list to awk from" }

  cpu:
    type: 'int?'
    default: 1
    doc: "Number of CPUs to allocate to this task."
  ram:
    type: 'int?'
    default: 2
    doc: "GB size of RAM to allocate to this task."
outputs:
  min_interval:
    type: int
    outputBinding:
      glob: "out.txt"
      loadContents: true
      outputEval: |
        ${
          var field = parseInt(self[0].contents.split('\n')[0].split('\t')[0]);
          return field;
        }
