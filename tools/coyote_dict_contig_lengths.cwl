cwlVersion: v1.2
class: CommandLineTool
id: coyote_dict_contig_lengths
doc: |
  Convert reference dict to contig lengths for Coyote pipeline
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
    - entryname: dict_to_contig_lengths.sh 
      writable: false
      entry: |
        set -eu
        set -o pipefail

        cut -f2,3 $(inputs.reference_dict.path) | \
          awk 'NR>1' | \
          sed 's/SN://g' | \
          sed 's/LN://g' > \
          contig_lengths.txt

baseCommand: [/bin/bash, dict_to_contig_lengths.sh]

inputs:
  # Required Inputs
  reference_dict: { type: 'File', doc: "Reference dict" }

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
      glob: "contig_lengths.txt" 
