cwlVersion: v1.2
class: Workflow
id: canine_annotation_module
doc: "Port of Canine Annotation Main Module"

requirements:
- class: ScatterFeatureRequirement
- class: StepInputExpressionRequirement
- class: MultipleInputFeatureRequirement
- class: InlineJavascriptRequirement

inputs:
  input_vcf: { type: 'File', doc: "VCF file to annotate." }
  input_gca_annotations_vcf: { type: 'File?', secondaryFiles: [ { pattern: '.tbi', required: true } ], doc: "VCF containing EVA GCA annotations: GCA_000002285.2_current_ids_renamed.vcf.gz" }  
  output_basename: { type: 'string', doc: "String to use as base for output filenames." }
  snpeff_database: { type: 'string?', doc: "Directory containing SnpEff database information" }
  snpeff_config: { type: 'File?', doc: "Config file containing run parameters for SnpEff" }
  vep_cache: { type: 'Directory?', doc: "Directory containing VEP cache information" }
  reference_fasta: { type: 'File?', doc: "Reference genome fasta file with associated FAI index" }

  # Killswitches
  disable_bcftools: { type: 'boolean?', doc: "Set to true to disable bcftools GCA annotation." }
  disable_tumor_only_var_filt: { type: 'boolean?', doc: "Set to true to disable tumor only variant filtering." }
  disable_snpeff: { type: 'boolean?', doc: "Set to true to disable SnpEff annotation." }
  disable_vep: { type: 'boolean?', doc: "Set to true to disable VEP annotation." }

  # Resource Control
  bcftools_ram: { type: 'int?', doc: "Maximum GB of RAM to allocate to BCFtools." }
  bcftools_cpu: { type: 'int?', doc: "Number of CPUs to allocate to BCFtools." }
  snpeff_ram: { type: 'int?', doc: "Maximum GB of RAM to allocate to SNPeff." }
  snpeff_ram: { type: 'int?', doc: "Maximum GB of RAM to allocate to SNPeff." }
  vep_cpu: { type: 'int?', doc: "Number of CPUs to allocate to VEP." }
  vep_cpu: { type: 'int?', doc: "Number of CPUs to allocate to VEP." }

outputs:
  bcftools_vcf: { type: 'File?', outputSource: bcftools_annotate/annotated_vcf }
  tumor_only_vcf: { type: 'File?', outputSource: tumor_only_variant_filter/filtered_vcf }
  snpeff_all_vcf: { type: 'File?', outputSource: snpeff_annotate/snpeff_all_vcf }
  snpeff_canon_vcf: { type: 'File?', outputSource: snpeff_annotate/snpeff_canon_vcf }
  vep_all_vcf: { type: 'File?', outputSource: vep_annotate/vep_all_vcf }
  vep_con_vcf: { type: 'File?', outputSource: vep_annotate/vep_con_vcf }

steps:
  bcftools_annotate:
    run: ../sub_workflows/canine_bcftools_annotate_module.cwl
    when: $(inputs.disable_workflow != true)
    in:
      input_vcf: input_vcf
      input_annotation_vcf: input_gca_annotations_vcf
      output_basename: output_basename
      disable_workflow: disable_bcftools
      bcftools_ram: bcftools_ram 
      bcftools_cpu: bcftools_cpu
    out: [annotated_vcf]

  tumor_only_variant_filter:
    run: ../sub_workflows/canine_tumor_only_variant_filter_module.cwl
    when: $(inputs.disable_workflow != true)
    in:
      input_vcf:
        source: bcftools_annotate/annotated_vcf, input_vcf]
        pickValue: first_non_null
      output_basename: output_basename
      disable_workflow: disable_tumor_only_var_filt
      bcftools_ram: bcftools_ram 
      bcftools_cpu: bcftools_cpu
    out: [filtered_vcf]

  snpeff_annotate:
    run: ../sub_workflows/canine_snpeff_module.cwl
    when: $(inputs.disable_workflow != true)
    in:
      input_vcf:
        source: [tumor_only_variant_filter/filtered_vcf, bcftools_annotate/annotated_vcf, input_vcf]
        pickValue: first_non_null
      snpeff_database: snpeff_database 
      snpeff_config: snpeff_config
      output_basename: output_basename
      disable_workflow: disable_snpeff
      snpeff_ram: snpeff_ram
      snpeff_cpu: snpeff_cpu
    out: [snpeff_all_vcf, snpeff_canon_vcf]

  vep_annotate:
    run: ../sub_workflows/canine_vep_module.cwl
    when: $(inputs.disable_workflow != true)
    in:
      input_vcf:
        source: [tumor_only_variant_filter/filtered_vcf, bcftools_annotate/annotated_vcf, input_vcf]
        pickValue: first_non_null
      vep_cache: vep_cache
      reference_fasta: reference_fasta
      output_basename: output_basename
      disable_workflow: disable_vep
      bcftools_ram: bcftools_ram 
      bcftools_cpu: bcftools_cpu
      vep_ram: vep_ram
      vep_cpu: vep_cpu
    out: [vep_all_vcf, vep_con_vcf]

$namespaces:
  sbg: https://sevenbridges.com

hints:
- class: "sbg:maxNumberOfParallelInstances"
  value: 2
