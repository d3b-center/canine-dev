cwlVersion: v1.2
class: Workflow
id: canine_deepvariant_module
doc: "Port of Canine Deepvariant Module"

requirements:
- class: ScatterFeatureRequirement
- class: StepInputExpressionRequirement
- class: MultipleInputFeatureRequirement
- class: InlineJavascriptRequirement
- class: SubworkflowFeatureRequirement

inputs:
  # Killswitches
  disable_bcftools: { type: 'boolean?', doc: "Set to true to disable bcftools GCA annotation." }
  disable_tumor_only_var_filt: { type: 'boolean?', default: true, doc: "Set to true to disable tumor only variant filtering." }
  disable_snpeff: { type: 'boolean?', doc: "Set to true to disable SnpEff annotation." }
  disable_vep: { type: 'boolean?', doc: "Set to true to disable VEP annotation." }

  # Deepvariant
  indexed_reference_fasta: { type: 'File', secondaryFiles: [{ pattern: ".fai", required: true }, { pattern: "^.dict", required: true }], doc: "Reference fasta with FAI and DICT indicies" }
  input_reads: { type: 'File', secondaryFiles: [{ pattern: ".bai", required: false },{ pattern: "^.bai", required: false },{ pattern: ".crai", required: false },{ pattern: "^.crai", required: false }], doc: "BAM/SAM/CRAM file containing reads from sample" }
  deepvariant_model: { type: 'File', secondaryFiles: [{ pattern: "^.index", required: true }, { pattern: "^.meta", required: true }], doc: "Model for deepvariant: model.ckpt" }
  targets_file: { type: 'File?', doc: "For exome variant calling, this file contains the targets regions used in library preparation." }
  num_shards: { type: 'int?', default: 40, doc: "Number of shards to create." }
  output_basename: { type: 'string', doc: "String to use as basename for outputs." }

  # Annotation
  input_gca_annotations_vcf: { type: 'File?', secondaryFiles: [ { pattern: '.tbi', required: true } ], doc: "VCF containing EVA GCA annotations: GCA_000002285.2_current_ids_renamed.vcf.gz" }
  snpeff_config: { type: 'File?', doc: "SnpEff config file" }
  snpeff_database: { type: 'string?', doc: "Name of SnpEff database information" }
  snpeff_tar: { type: 'File?', doc: "TAR containing SnpEff config file and cache information" }
  snpeff_cachename: { type: 'string?', doc: "Name of snpeff cache directory contained in snpeff_tar" }
  vep_tar: { type: 'File?', doc: "TAR containing VEP cache information" }
  vep_cachename: { type: 'string?', doc: "Name of vep cache directory contained in vep_tar" }

  # Resource Control
  snpeff_ram: { type: 'int?', doc: "Maximum GB of RAM to allocate to SNPeff." }
  snpeff_cpu: { type: 'int?', doc: "Number of CPUs to allocate to SNPeff." }
  vep_ram: { type: 'int?', doc: "Maximum GB of RAM to allocate to VEP." }
  vep_cpu: { type: 'int?', doc: "Number of CPUs to allocate to VEP." }

outputs:
  deepvariant_all_vcf: { type: 'File', outputSource: bcftools_index/output }
  deepvariant_pass_vcf: { type: 'File', outputSource: bcftools_filter_index/output }
  deepvariant_all_vcf_stats: { type: 'File', outputSource: bcftools_stats_all/stats }
  deepvariant_pass_vcf_stats: { type: 'File', outputSource: bcftools_stats_pass/stats }
  bcftools_vcf: { type: 'File?', outputSource: canine_annotation_module/bcftools_vcf }
  tumor_only_vcf: { type: 'File?', outputSource: canine_annotation_module/tumor_only_vcf }
  snpeff_all_vcf: { type: 'File?', outputSource: canine_annotation_module/snpeff_all_vcf }
  snpeff_canon_vcf: { type: 'File?', outputSource: canine_annotation_module/snpeff_canon_vcf }
  vep_all_vcf: { type: 'File?', outputSource: canine_annotation_module/vep_all_vcf }
  vep_con_vcf: { type: 'File?', outputSource: canine_annotation_module/vep_con_vcf }

steps:
  expr_make_int_array:
    run: ../tools/expr_make_int_array.cwl
    in:
      length: num_shards
    out: [output]

  deepvariant_make_examples:
    run: ../tools/deepvariant_make_examples.cwl
    scatter: [task]
    in:
      mode:
        valueFrom: "calling"
      task: expr_make_int_array/output
      task_total: num_shards
      ref: indexed_reference_fasta
      reads:
        source: input_reads
        valueFrom: $([self])
      examples_outname:
        source: output_basename
        valueFrom: $(self).ex.tfrecord@$(inputs.task_total).gz
      gvcf_outname: 
        source: output_basename
        valueFrom: $(self).gvcf.tfrecord@$(inputs.task_total).gz
    out: [examples, gvcf]

  deepvariant_call_variants:
    hints:
      - class: 'sbg:AWSInstanceType'
        value: p3.2xlarge
    run: ../tools/deepvariant_call_variants.cwl
    in:
      checkpoint: deepvariant_model
      examples: deepvariant_make_examples/examples
      outfile:
        source: output_basename
        valueFrom: $(self).cvo.tfrecord.gz
    out: [output]

  deepvariant_postprocess_variants:
    hints:
      - class: 'sbg:AWSInstanceType'
        value: p3.2xlarge
    run: ../tools/deepvariant_postprocess_variants.cwl
    in:
      ref: indexed_reference_fasta
      infile:
        source: deepvariant_call_variants/output
        valueFrom: $([self])
      outfile:
        source: output_basename
        valueFrom: $(self).deepvariant.all.vcf.gz
      nonvariant_site_tfrecord_path:
        source: num_shards
        valueFrom: |
          *.gvcf.tfrecord@$(self).gz 
      nonvariant_site_tfrecord: deepvariant_make_examples/gvcf
      gvcf_outfile:
        source: output_basename
        valueFrom: $(self).deepvariant.all.g.vcf.gz
    out: [output, gvcf]

  bcftools_index:
    run: ../tools/bcftools_index.cwl
    in:
      input_vcf: deepvariant_postprocess_variants/output
      tbi:
        valueFrom: $(1 == 1)
    out: [output]

  bcftools_filter_index:
    run: ../tools/bcftools_filter_index.cwl
    in:
      input_vcf: bcftools_index/output 
      output_filename:
        source: output_basename
        valueFrom: $(self).deepvariant.pass.vcf.gz
      output_type:
        valueFrom: "z"
      include:
        valueFrom: |
          FILTER == "PASS"
      targets_file: targets_file
      tool_name:
        valueFrom: "deepvariant"
    out: [output]

  canine_annotation_module:
    run: ../sub_workflows/canine_annotation_module.cwl
    in:
      input_vcf: bcftools_filter_index/output 
      input_gca_annotations_vcf: input_gca_annotations_vcf
      output_basename:
        source: output_basename
        valueFrom: $(self).constitutional
      snpeff_config: snpeff_config
      snpeff_database: snpeff_database
      snpeff_tar: snpeff_tar
      snpeff_cachename: snpeff_cachename
      vep_tar: vep_tar
      vep_cachename: vep_cachename
      reference_fasta: indexed_reference_fasta
      disable_bcftools: disable_bcftools
      disable_tumor_only_var_filt: disable_tumor_only_var_filt
      disable_snpeff: disable_snpeff
      disable_vep: disable_vep
      snpeff_ram: snpeff_ram
      snpeff_cpu: snpeff_cpu
      vep_ram: vep_ram
      vep_cpu: vep_cpu
    out: [bcftools_vcf, tumor_only_vcf, snpeff_all_vcf, snpeff_canon_vcf, vep_all_vcf, vep_con_vcf]

  bcftools_stats_all:
    run: ../tools/bcftools_stats.cwl
    in:
      input_vcf: bcftools_index/output 
      output_filename:
        source: output_basename
        valueFrom: $(self).deepvariant.all.stats.txt
    out: [stats]

  bcftools_stats_pass:
    run: ../tools/bcftools_stats.cwl
    in:
      input_vcf: bcftools_filter_index/output
      output_filename:
        source: output_basename
        valueFrom: $(self).deepvariant.pass.stats.txt
    out: [stats]

$namespaces:
  sbg: https://sevenbridges.com

hints:
- class: "sbg:maxNumberOfParallelInstances"
  value: 2
