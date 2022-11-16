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
    dockerPull: 'staphb/bcftools:1.10.2'
  - class: InitialWorkDirRequirement
    listing:
    - entryname: tucon.sh 
      writable: false
      entry: |
        set -eu
        set -o pipefail

        echo -e "VCF\tMUTATION_COUNT\tTOPMED_COUNT" > $(inputs.output_filename)

        VCF_BASE=$(inputs.input_vcf.basename)
        MUT_COUNT=\$(bcftools view -H $(inputs.input_vcf.path) | wc -l)
        EVA_COUNT=\$(bcftools view -H -i 'INFO/GCA_2285.2=1' $(inputs.input_vcf.path) | wc -l)
        echo -e "$VCF_BASE\t$MUT_COUNT\t$EVA_COUNT" >> $(inputs.output_filename)
baseCommand: [/bin/bash, tucon.sh]

inputs:
  # Required Inputs
  input_vcf: { type: 'File', doc: "VCF file to annotate and view" }
  output_filename: { type: 'string', doc: "output file name [stdout]" }

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
