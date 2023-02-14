cwlVersion: v1.2
class: Workflow
id: canine_annotation_module
doc: "Port of Canine Annotation Main Module"

requirements:
- class: ScatterFeatureRequirement
- class: StepInputExpressionRequirement
- class: MultipleInputFeatureRequirement
- class: InlineJavascriptRequirement
- class: SubworkflowFeatureRequirement

inputs:
  input_vcf: { type: 'File', doc: "VCF file to annotate." }
  input_gca_annotations_vcf: { type: 'File?', secondaryFiles: [ { pattern: '.tbi', required: true } ], doc: "VCF containing EVA GCA annotations: GCA_000002285.2_current_ids_renamed.vcf.gz" }
  output_basename: { type: 'string', doc: "String to use as base for output filenames." }
  snpeff_config: { type: 'File?', doc: "SnpEff config file" }
  snpeff_database: { type: 'string?', doc: "Name of SnpEff database information" }
  snpeff_tar: { type: 'File?', doc: "TAR containing SnpEff config file and cache information" }
  snpeff_cachename: { type: 'string?', doc: "Name of snpeff cache directory contained in snpeff_tar" }
  vep_tar: { type: 'File?', doc: "TAR containing VEP cache information" }
  vep_cachename: { type: 'string?', doc: "Name of vep cache directory contained in vep_tar" }
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
  snpeff_cpu: { type: 'int?', doc: "Number of CPUs to allocate to SNPeff." }
  vep_ram: { type: 'int?', doc: "Maximum GB of RAM to allocate to VEP." }
  vep_cpu: { type: 'int?', doc: "Number of CPUs to allocate to VEP." }

outputs:
  bcftools_vcf: { type: 'File?', outputSource: bcftools_annotate/annotated_vcf }
  tumor_only_vcf: { type: 'File?', outputSource: tumor_only_variant_filter/filtered_vcf }
  snpeff_all_vcf: { type: 'File?', outputSource: snpeff_annotate/snpeff_all_vcf }
  snpeff_canon_vcf: { type: 'File?', outputSource: snpeff_annotate/snpeff_canon_vcf }
  vep_all_vcf: { type: 'File?', outputSource: vep_annotate/vep_all_vcf }
  vep_all_warnings: { type: 'File?', outputSource: vep_annotate/vep_all_warnings }
  vep_con_vcf: { type: 'File?', outputSource: vep_annotate/vep_con_vcf }
  vep_con_warnings: { type: 'File?', outputSource: vep_annotate/vep_con_warnings }

steps:
  bcftools_annotate:
    run: ../subworkflows/canine_bcftools_annotate_module.cwl
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
    run: ../subworkflows/canine_tumor_only_variant_filter_module.cwl
    when: $(inputs.disable_workflow != true)
    in:
      input_vcf:
        source: [bcftools_annotate/annotated_vcf, input_vcf]
        pickValue: first_non_null
      output_basename: output_basename
      disable_workflow: disable_tumor_only_var_filt
      bcftools_ram: bcftools_ram
      bcftools_cpu: bcftools_cpu
    out: [filtered_vcf]

  untar_snpeff:
    run: ../tools/untar.cwl
    when: $(inputs.tarfile != null)
    in:
      tarfile: snpeff_tar
      output_name: snpeff_cachename
    out: [output]

  snpeff_annotate:
    run: ../subworkflows/canine_snpeff_module.cwl
    when: $(inputs.disable_workflow != true)
    in:
      input_vcf:
        source: [tumor_only_variant_filter/filtered_vcf, bcftools_annotate/annotated_vcf, input_vcf]
        pickValue: first_non_null
      snpeff_config: snpeff_config
      snpeff_database: snpeff_database
      snpeff_datadir: untar_snpeff/output
      output_basename: output_basename
      disable_workflow: disable_snpeff
      snpeff_ram: snpeff_ram
      snpeff_cpu: snpeff_cpu
    out: [snpeff_all_vcf, snpeff_canon_vcf]

  untar_vep:
    run: ../tools/untar.cwl
    when: $(inputs.tarfile != null)
    in:
      tarfile: vep_tar
      outdir:
        valueFrom: "vep"
      output_name: vep_cachename
    out: [output]

  vep_annotate:
    run: ../subworkflows/canine_vep_module.cwl
    when: $(inputs.disable_workflow != true)
    in:
      input_vcf:
        source: [tumor_only_variant_filter/filtered_vcf, bcftools_annotate/annotated_vcf, input_vcf]
        pickValue: first_non_null
      vep_cache: untar_vep/output
      reference_fasta: reference_fasta
      output_basename: output_basename
      disable_workflow: disable_vep
      bcftools_ram: bcftools_ram
      bcftools_cpu: bcftools_cpu
      vep_ram: vep_ram
      vep_cpu: vep_cpu
    out: [vep_all_vcf, vep_all_warnings, vep_con_vcf, vep_con_warnings]

$namespaces:
  sbg: https://sevenbridges.com

hints:
- class: "sbg:maxNumberOfParallelInstances"
  value: 2
