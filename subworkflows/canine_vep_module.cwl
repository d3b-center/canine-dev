cwlVersion: v1.2
class: Workflow
id: canine_vep_module
doc: "Port of Canine VEP Module"

requirements:
- class: ScatterFeatureRequirement
- class: StepInputExpressionRequirement
- class: MultipleInputFeatureRequirement
- class: InlineJavascriptRequirement

inputs:
  input_vcf: { type: 'File', doc: "VCF file to annotate." }
  vep_cache: { type: 'Directory', loadListing: deep_listing, doc: "Directory containing VEP cache information" }
  reference_fasta: { type: 'File', doc: "Reference genome fasta file" }
  output_basename: { type: 'string', doc: "String to use as base for output filenames." }
  disable_workflow: { type: 'boolean?', doc: "For when this workflow is wrapped into a larger workflow, you can use this value in the when statement to toggle the running of this workflow." }

  # Resource Control
  bcftools_ram: { type: 'int?', doc: "Maximum GB of RAM to allocate to BCFtools." }
  bcftools_cpu: { type: 'int?', doc: "Number of CPUs to allocate to BCFtools." }
  vep_ram: { type: 'int?', doc: "Maximum GB of RAM to allocate to VEP." }
  vep_cpu: { type: 'int?', doc: "Number of CPUs to allocate to VEP." }

outputs:
  vep_all_vcf: { type: 'File', outputSource: bcftools_view_index_all/output }
  vep_con_vcf: { type: 'File', outputSource: bcftools_view_index_con/output }

steps:
  vep_coyote_all:
    run: ../tools/vep_coyote.cwl
    in:
      input_vcf: input_vcf
      output_filename:
        source: output_basename
        valueFrom: $(self).vep.full.vcf
      vep_cache: vep_cache
      reference_fasta: reference_fasta
      all_or_con:
        source: disable_workflow # hiding this here because I hate cavatica
        valueFrom: "all"
      cpu: vep_cpu
      ram: vep_ram
    out: [output]

  bcftools_view_index_all:
    run: ../tools/bcftools_view_index.cwl
    in:
      input_vcf: vep_coyote_all/output
      output_filename:
        source: output_basename
        valueFrom: $(self).vep.full.vcf.gz
      output_type:
        valueFrom: "z"
      force:
        valueFrom: $(1 == 1)
      tbi:
        valueFrom: $(1 == 1)
      cpu: bcftools_cpu
      ram: bcftools_ram
    out: [output]

  vep_coyote_con:
    run: ../tools/vep_coyote.cwl
    in:
      input_vcf: input_vcf
      output_filename:
        source: output_basename
        valueFrom: $(self).vep.pick.vcf
      vep_cache: vep_cache
      reference_fasta: reference_fasta
      all_or_con:
        valueFrom: "con"
      cpu: vep_cpu
      ram: vep_ram
    out: [output]

  bcftools_view_index_con:
    run: ../tools/bcftools_view_index.cwl
    in:
      input_vcf: vep_coyote_con/output
      output_filename:
        source: output_basename
        valueFrom: $(self).vep.pick.vcf.gz
      output_type:
        valueFrom: "z"
      force:
        valueFrom: $(1 == 1)
      tbi:
        valueFrom: $(1 == 1)
      cpu: bcftools_cpu
      ram: bcftools_ram
    out: [output]

$namespaces:
  sbg: https://sevenbridges.com

hints:
- class: "sbg:maxNumberOfParallelInstances"
  value: 2
