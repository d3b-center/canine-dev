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
  input_vcf: { type: 'File', doc: "VCF file to annotate." }
  input_annotation_vcf: { type: 'File', secondaryFiles: [ { pattern: '.tbi', required: true } ], doc: "VCF containing EVA GCA annotations: GCA_000002285.2_current_ids_renamed.vcf.gz" }
  output_basename: { type: 'string', doc: "String to use as base for output filenames." }
  disable_workflow: { type: 'boolean?', doc: "For when this workflow is wrapped into a larger workflow, you can use this value in the when statement to toggle the running of this workflow." }

  # Resource Control
  bcftools_ram: { type: 'int?', doc: "Maximum GB of RAM to allocate to BCFtools." }
  bcftools_cpu: { type: 'int?', doc: "Number of CPUs to allocate to BCFtools." }

outputs:
  annotated_vcf: { type: 'File', outputSource: bcftools_view_index_annot/output }

steps:
  bcftools_view_index:
    run: ../tools/bcftools_view_index.cwl
    in:
      input_vcf:  input_vcf
      output_filename:
        source: disable_workflow # hiding this here because I hate cavatica
        valueFrom: "temp.db.bcf"
      output_type:
        valueFrom: "b"
      cpu: bcftools_cpu
      ram: bcftools_ram
    out: [output]

  bcftools_annotate_index:
    run: ../tools/bcftools_annotate_index.cwl
    in:
      input_vcf: bcftools_view_index/output
      output_filename:
        valueFrom: "tempout.bcf"
      annotations: input_annotation_vcf
      mark_sites:
        valueFrom: "GCA_2285.2"
      columns:
        valueFrom: "ID"
      output_type:
        valueFrom: "b"
      cpu: bcftools_cpu
      ram: bcftools_ram
    out: [output]

  bcftools_view_index_annot:
    run: ../tools/bcftools_view_index.cwl
    in:
      input_vcf: bcftools_annotate_index/output
      output_filename:
        source: output_basename
        valueFrom: $(self).db.vcf.gz
      output_type:
        valueFrom: "z"
      tbi:
        valueFrom: $(1 == 1)
      cpu: bcftools_cpu
      ram: bcftools_ram
    out: [output]

$namespaces:
  sbg: https://sevenbridges.com
