cwlVersion: v1.2
class: Workflow
id: canine_tumor_only_variant_filter_module
doc: "Port of Canine Tumor Only Variant Filter Module"

requirements:
- class: ScatterFeatureRequirement
- class: StepInputExpressionRequirement
- class: MultipleInputFeatureRequirement
- class: InlineJavascriptRequirement

inputs:
  input_vcf: { type: 'File', doc: "VCF file to annotate." }
  output_basename: { type: 'string', doc: "String to use as base for output filenames." }
  disable_workflow: { type: 'boolean?', doc: "For when this workflow is wrapped into a larger workflow, you can use this value in the when statement to toggle the running of this workflow." }

  # Resource Control
  bcftools_ram: { type: 'int?', doc: "Maximum GB of RAM to allocate to BCFtools." }
  bcftools_cpu: { type: 'int?', doc: "Number of CPUs to allocate to BCFtools." }

outputs:
  filtered_vcf: { type: 'File', outputSource: bcftools_concat_sort_index/output }

steps:
  bcftools_view_view_index_filtered:
    run: ../tools/bcftools_view_view_index.cwl
    in:
      input_vcf:  input_vcf
      include:
        source: disable_workflow # Sinking this someplace it will do nothing to circumvent graph not connected cavatica error
        valueFrom: |
          INFO/CC>=3 & (INFO/GNOMAD_EXOME=1 | INFO/GNOMAD_GENOME=1 | INFO/TOPMED=1) & (INFO/COSMIC_CNT>=1 | INFO/COSMIC_NC_CNT>=1)
      exclude:
        valueFrom: |
          (INFO/TOPMED_AC>5 | INFO/GNOMAD_GENOME_AC>5 | INFO/GNOMAD_EXOME_AC>5)
      output_filename:
        valueFrom: "temp.filtered_db.vcf.gz"
      output_type:
        valueFrom: "z"
      cpu: bcftools_cpu
      ram: bcftools_ram
    out: [output]

  bcftools_view_view_index_no_db:
    run: ../tools/bcftools_view_view_index.cwl
    in:
      input_vcf:  input_vcf
      include:
        valueFrom: |
          INFO/CC>=3
      exclude:
        valueFrom: |
          (INFO/TOPMED_AC>5 | INFO/GNOMAD_GENOME_AC>5 | INFO/GNOMAD_EXOME_AC>5)
      output_filename:
        valueFrom: "temp.not_in_db.vcf.gz"
      output_type:
        valueFrom: "z"
      cpu: bcftools_cpu
      ram: bcftools_ram
    out: [output]

  bcftools_concat_sort_index:
    run: ../tools/bcftools_concat_sort_index.cwl
    in:
      input_vcfs: [bcftools_view_view_index_filtered/output, bcftools_view_view_index_no_db/output]
      output_filename:
        source: output_basename
        valueFrom: $(self).db.flt.vcf.gz
      allow_overlaps:
        valueFrom: $(1 == 1)
      output_type:
        valueFrom: "z"
      tbi:
        valueFrom: $(1 == 1)
      cpu: bcftools_cpu
      ram: bcftools_ram
    out: [output]

$namespaces:
  sbg: https://sevenbridges.com
