cwlVersion: v1.2
class: Workflow
id: canine_bcftools_annotate_module
doc: "Port of Canine BCFtools Annotate Module"

requirements:
- class: ScatterFeatureRequirement
- class: StepInputExpressionRequirement
- class: MultipleInputFeatureRequirement
- class: InlineJavascriptRequirement

inputs:
  input_vcf: { type: 'File', doc: "VCF file to which RNA headers." }
  output_filename: { type: 'string', doc: "Name for reheadered VCF output file." }
  eva_gca: { type: 'File', doc: "canfam3.1_tgen GCA_000002285.2_current_ids_renamed vcf file" }

  # Resource Control
  bcftools_ram: { type: 'int?', doc: "Maximum GB of RAM to allocate to BCFtools." }
  bcftools_cpu: { type: 'int?', doc: "Number of CPUs to allocate to BCFtools." }

outputs:
  bcftools_annotated_vcf: { type: 'File', outputSource: bcftools_index_csi/output }

steps:
  bcftools_view_index_bcf:
    run: ../tools/bcftools_view_index.cwl
    in:
      input_vcf: input_vcf
      output_filename:
        valueFrom: "temp.db.bcf"
      output_type:
        valueFrom: "b"
      cpu: bcftools_cpu
      ram: bcftools_ram
    out: [output]

  bcftools_annotate:
    run: ../tools/bcftools_annotate.cwl
    in:
      input_vcf: bcftools_view_index_bcf/output
      output_filename:
        valueFrom: "tempout.bcf"
      annotations: eva_gca
      mark_sites:
        valueFrom: "GCA_2285.2"
      columns:
        valueFrom: "ID"
      output_type:
        valueFrom: "b"
      cpu: bcftools_cpu
      ram: bcftools_ram
    out: [output]

  bcftools_view_index_vcf:
    run: ../tools/bcftools_view_index.cwl
    in:
      input_vcf: bcftools_annotate/output
      output_filename: output_filename
      output_type:
        valueFrom: "z"
      tbi:
        valueFrom: $(1 == 1)
      force:
        valueFrom: $(1 == 1)
      cpu: bcftools_cpu
      ram: bcftools_ram
    out: [output]

  bcftools_index_csi:
    run: ../tools/bcftools_index.cwl
    in:
      input_vcf: bcftools_view_index_vcf/output
      force:
        valueFrom: $(1 == 1)
      cpu: bcftools_cpu
      ram: bcftools_ram
    out: [output]

$namespaces:
  sbg: https://sevenbridges.com

hints:
- class: "sbg:maxNumberOfParallelInstances"
  value: 2
