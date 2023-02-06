cwlVersion: v1.2
class: CommandLineTool
id: coyote_tucon 
doc: |
  Custom TUCON protocol for Coyote pipeline
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
    - entryname: tucon.sh 
      writable: false
      entry: |
        set -eu
        set -o pipefail

        FIRST="HELLO"
        SECOND="WORLD"

        declare THIRD_$FIRST="panda"
        export THIRD_$FIRST

        declare THIRD_$SECOND="goodbye"
        export THIRD$SECOND


        eval "START=\\\${THIRD_\${FIRST}}"
        eval "STOP=\\\${THIRD_\${SECOND}}"

        echo -e "$START\t$STOP" >> $(inputs.output_filename)
baseCommand: [/bin/bash, tucon.sh]

inputs:
  # Required Inputs
  output_filename: { type: 'string' }

  cpu:
    type: 'int?'
    default: 1
    doc: "Number of CPUs to allocate to this task."
  ram:
    type: 'int?'
    default: 2
    doc: "GB size of RAM to allocate to this task."
outputs:
  output:
    type: 'File'
    outputBinding:
      glob: $(inputs.output_filename)
