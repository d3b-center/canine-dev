cwlVersion: v1.2
class: CommandLineTool
id: coyote_temp_rna_vcf
doc: |
  Create a temp VCF with RNA INFO keys for the Coyote pipeline
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
    - $(inputs.output_header)
    - entryname: temp_rna_vcf.sh
      writable: false
      entry: |
        set -eu
        set -o pipefail

        awk '{
          OFS = "\t" ;
          if ( $5 == "." && $6 == "." )
            print $1, $2, ".", $3, $4, ".", ".", "RNA_REF_COUNT=0;RNA_ALT_COUNT=0;RNA_ALT_FREQ=0.00";
          else if ( $5 >= 1 && $6 >= 1 )
            print $1, $2, ".", $3, $4, ".", ".", "RNA_REF_COUNT="$5";RNA_ALT_COUNT="$6";RNA_ALT_FREQ="$6/($5+$6);
          else if ( $5 == "." && $6 >= 1 )
            print $1, $2, ".", $3, $4, ".", ".", "RNA_REF_COUNT=0;RNA_ALT_COUNT="$6";RNA_ALT_FREQ=1.0";
          else if ( $5 >= 1 && $6 == "." )
            print $1, $2, ".", $3, $4, ".", ".", "RNA_REF_COUNT="$5";RNA_ALT_COUNT=0;RNA_ALT_FREQ=0.00";
          else if ( $5 >= 1 && $6 == 0 )
            print $1, $2, ".", $3, $4, ".", ".", "RNA_REF_COUNT="$5";RNA_ALT_COUNT=0;RNA_ALT_FREQ=0.00";
          else if ( $5 == 0 && $6 >= 1 )
            print $1, $2, ".", $3, $4, ".", ".", "RNA_REF_COUNT=0;RNA_ALT_COUNT="$6";RNA_ALT_FREQ=1.00";
          else if ( $5 == 0 && $6 == 0 )
            print $1, $2, ".", $3, $4, ".", ".", "RNA_REF_COUNT=0;RNA_ALT_COUNT=0;RNA_ALT_FREQ=0.00";
          }' $(inputs.input_counts.path) >> $(inputs.input_header.basename)

baseCommand: [/bin/bash, temp_rna_vcf.sh]

inputs:
  # Required Inputs
  input_counts: { type: 'File', doc: "Temp RNA counts TXT made by bcftools query" }
  input_header: { type: 'File', doc: "Temp RNA header file" }

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
      glob: $(inputs.input_header.basename)
