cwlVersion: v1.2
class: Workflow
id: canine_add_rna_header_to_vcf_module
doc: "Port of Canine RNA Variant Check: add_rna_header_to_vcf Module"

requirements:
- class: ScatterFeatureRequirement
- class: StepInputExpressionRequirement
- class: MultipleInputFeatureRequirement
- class: InlineJavascriptRequirement

inputs:
  input_vcf: { type: 'File', doc: "VCF file to which RNA headers." }
  output_filename: { type: 'string', doc: "Name for reheadered VCF output file." }

  # Resource Control
  bcftools_ram: { type: 'int?', doc: "Maximum GB of RAM to allocate to BCFtools." }
  bcftools_cpu: { type: 'int?', doc: "Number of CPUs to allocate to BCFtools." }

outputs:
  rna_headered_vcf: { type: 'File', outputSource: bcftools_index_csi/output }

steps:
  coyote_temp_rna_header:
    run: ../tools/coyote_temp_rna_header.cwl
    in: []
    out: [output]

  bcftools_annotate:
    run: ../tools/bcftools_annotate.cwl
    in:
      input_vcf: input_vcf
      output_filename: output_filename
      header_lines: coyote_temp_rna_header/output
      output_type:
        valueFrom: "z"
      cpu: bcftools_cpu
      ram: bcftools_ram
    out: [output]

  bcftools_index_tbi:
    run: ../tools/bcftools_index.cwl
    in:
      input_vcf: bcftools_annotate/output
      tbi:
        valueFrom: $(1 == 1)
      cpu: bcftools_cpu
      ram: bcftools_ram
    out: [output]

  bcftools_index_csi:
    run: ../tools/bcftools_index.cwl
    in:
      input_vcf: bcftools_index_tbi/output
      cpu: bcftools_cpu
      ram: bcftools_ram
    out: [output]

$namespaces:
  sbg: https://sevenbridges.com

hints:
- class: "sbg:maxNumberOfParallelInstances"
  value: 2
