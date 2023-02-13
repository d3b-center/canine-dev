cwlVersion: v1.2
class: Workflow
id: canine_tucon_module
doc: "Port of Canine Tucon Module"

requirements:
- class: ScatterFeatureRequirement
- class: StepInputExpressionRequirement
- class: MultipleInputFeatureRequirement
- class: InlineJavascriptRequirement

inputs:
  input_vcf: { type: 'File', doc: "VCF file on which to call Tucon metrics." }
  output_basename: { type: 'string', doc: "String to use as base for output filenames." }
  disable_workflow: { type: 'boolean?', doc: "For when this workflow is wrapped into a larger workflow, you can use this value in the when statement to toggle the running of this workflow." }
  total_callers: { type: 'int', doc: "Total callers run to generate this VCF." } 

  # Resource Control
  bcftools_ram: { type: 'int?', doc: "Maximum GB of RAM to allocate to BCFtools." }
  bcftools_cpu: { type: 'int?', doc: "Number of CPUs to allocate to BCFtools." }

outputs:
  tucon_tsv: { type: 'File', outputSource: tucon/output }

steps:
  bcftools_view_index:
    run: ../tools/bcftools_view_index.cwl
    in:
      input_vcf: input_vcf
      include:
        source: total_callers
        valueFrom: |
          $(self > 3 ? "INFO/CC>=" + (self - 2) : "INFO/CC>=" + (self - 1))
      output_filename:
        source: output_basename
        valueFrom: $(self).flt.vcf.gz
      output_type:
        source: disable_workflow # hiding this here because I hate cavatica
        valueFrom: "z"
      tbi:
        valueFrom: $(1 == 1)
      cpu: bcftools_cpu
      ram: bcftools_ram
    out: [output]

  tucon:
    run: ../tools/tucon.cwl
    in:
      input_vcf: bcftools_view_index/output
      output_filename:
        source: output_basename
        valueFrom: $(self)_tucon.tsv
    out: [output]

$namespaces:
  sbg: https://sevenbridges.com
