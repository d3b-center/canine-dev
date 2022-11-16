cwlVersion: v1.2
class: CommandLineTool
id: coyote_temp_rna_header
doc: |
  Create a temp header for bcftools with RNA information 
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
    - entryname: temp_rna_header.sh 
      writable: false
      entry: |
        set -eu
        set -o pipefail

        echo "##INFO=<ID=RNA_REF_COUNT,Number=.,Type=Integer,Description=\"Count of REF alleles seen in RNA\">" > $(inputs.output_filename) 
        echo "##INFO=<ID=RNA_ALT_FREQ,Number=.,Type=Float,Description=\"Frequency of ALT alleles seen in RNA\">" >> $(inputs.output_filename)
        echo "##INFO=<ID=RNA_ALT_COUNT,Number=.,Type=Integer,Description=\"Count of ALT alleles seen in RNA\">" >> $(inputs.output_filename)

baseCommand: [/bin/bash, temp_rna_header.sh]

inputs:
  output_filename: { type: 'string?', default: "temp_header", doc: "Name for output header file" }

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
