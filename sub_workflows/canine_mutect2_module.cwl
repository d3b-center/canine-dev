cwlVersion: v1.2
class: Workflow
id: canine_mutect2_module
doc: "Port of Canine Mutect2 Somatic Module"

requirements:
- class: ScatterFeatureRequirement
- class: StepInputExpressionRequirement
- class: MultipleInputFeatureRequirement
- class: InlineJavascriptRequirement

inputs:
  indexed_reference_fasta: { type: 'File', secondaryFiles: [{ pattern: ".fai", required: true }, { pattern: "^.dict", required: true }], doc: "Reference fasta with FAI and DICT indicies" }
  reference_dict: { type: 'File', doc: "sequence dictionary (.dict) file for reference fasta" }
  input_tumor_reads: { type: 'File', secondaryFiles: [{ pattern: ".bai", required: false },{ pattern: "^.bai", required: false },{ pattern: ".crai", required: false },{ pattern: "^.crai", required: false }], doc: "BAM/SAM/CRAM file containing reads from the tumor sample" }
  input_normal_reads: { type: 'File', secondaryFiles: [{ pattern: ".bai", required: false },{ pattern: "^.bai", required: false },{ pattern: ".crai", required: false },{ pattern: "^.crai", required: false }], doc: "BAM/SAM/CRAM file containing reads from the normal sample" }
  calling_intervals: { type: 'File', doc: "YAML file contianing the intervals in which to perform variant calling." }
  af_vcf: { type: 'File', secondaryFiles: [{ pattern: ".tbi", required: false }], doc: "A VCF file containing variants and allele frequencies" }
  targets_file: { type: 'File?', doc: "For exome variant calling, this file contains the targets regions used in library preparation." }
  normal_sample_name: { type: 'string', doc: "BAM sample name of normal" }
  tumor_sample_name: { type: 'string', doc: "BAM sample name of tumor" }
  output_basename: { type: 'string', doc: "String to use as basename for outputs." }

  # Resource Control
  mutect2_max_memory: { type: 'int?', doc: "Maximum GB of RAM to allocate to Mutect2." }
  mutect2_cpu: { type: 'int?', doc: "Number of CPUs to allocate to Mutect2." }
  getpileupsummaries_max_memory: { type: 'int?', doc: "Maximum GB of RAM to allocate to getpileupsummaries." }
  getpileupsummaries_cpu: { type: 'int?', doc: "Number of CPUs to allocate to getpileupsummaries." }
  mergemutectstats_max_memory: { type: 'int?', doc: "Maximum GB of RAM to allocate to mergemutectstats." }
  mergemutectstats_cpu: { type: 'int?', doc: "Number of CPUs to allocate to mergemutectstats." }
  learnreadorientationmodel_max_memory: { type: 'int?', doc: "Maximum GB of RAM to allocate to learnreadorientationmodel." }
  learnreadorientationmodel_cpu: { type: 'int?', doc: "Number of CPUs to allocate to learnreadorientationmodel." }
  gatherpileupsummaries_max_memory: { type: 'int?', doc: "Maximum GB of RAM to allocate to gatherpileupsummaries." }
  gatherpileupsummaries_cpu: { type: 'int?', doc: "Number of CPUs to allocate to gatherpileupsummaries." }
  calculatecontamination_max_memory: { type: 'int?', doc: "Maximum GB of RAM to allocate to calculatecontamination." }
  calculatecontamination_cpu: { type: 'int?', doc: "Number of CPUs to allocate to calculatecontamination." }
  filtermutectcalls_max_memory: { type: 'int?', doc: "Maximum GB of RAM to allocate to filtermutectcalls." }
  filtermutectcalls_cpu: { type: 'int?', doc: "Number of CPUs to allocate to filtermutectcalls." }

outputs:
  mutect2_all_vcf: { type: 'File', outputSource: gatk_filtermutectcalls/filtered_vcf }
  mutect2_pass_vcf: { type: 'File', outputSource: bcftools_filter_index/output }

steps:
  calling_intervals_yaml_to_beds:
    run: ../tools/calling_intervals_yaml_to_beds.cwl
    in:
      input_yaml: calling_intervals
    out: [outputs]
  gatk_mutect2:
    run: ../tools/gatk_mutect2.cwl
    scatter: [input_interval_list]
    in:
      indexed_reference: indexed_reference_fasta
      input_tumor_reads: input_tumor_reads
      input_normal_reads: input_normal_reads
      normal_sample_name: normal_sample_name
      tumor_sample_name: tumor_sample_name
      input_interval_list: calling_intervals_yaml_to_beds/outputs
      independent_mates:
        valueFrom: $(1 == 1)
      max_memory: mutect2_max_memory
      cpu: mutect2_cpu
    out: [vcf, stats, f1r2]
  gatk_getpileupsummaries_tumor:
    run: ../tools/gatk_getpileupsummaries.cwl
    scatter: [input_interval_list]
    in:
      input_reads: input_tumor_reads
      input_variants: af_vcf
      input_interval_list: calling_intervals_yaml_to_beds/outputs
      indexed_reference: indexed_reference_fasta
      interval_set_rule:
        valueFrom: "UNION"
      max_memory: getpileupsummaries_max_memory
      cpu: getpileupsummaries_cpu
    out: [output]
  gatk_getpileupsummaries_normal:
    run: ../tools/gatk_getpileupsummaries.cwl
    scatter: [input_interval_list]
    in:
      input_reads: input_normal_reads
      input_variants: af_vcf
      input_interval_list: calling_intervals_yaml_to_beds/outputs
      indexed_reference: indexed_reference_fasta
      interval_set_rule:
        valueFrom: "UNION"
      max_memory: getpileupsummaries_max_memory
      cpu: getpileupsummaries_cpu
    out: [output]
  bcftools_concat_index:
    run: ../tools/bcftools_concat_index.cwl
    in: #vcfs from mutect2 step
      input_vcfs: gatk_mutect2/vcf
      output_filename:
        source: output_basename
        valueFrom: $(self).mutect2.raw.vcf.gz
      output_type:
        valueFrom: "z"
    out: [vcf]
  gatk_mergemutectstats:
    run: ../tools/gatk_mergemutectstats.cwl
    in:
      input_stats: gatk_mutect2/stats
      output_prefix: output_basename
      max_memory: mergemutectstats_max_memory
      cpu: mergemutectstats_cpu
    out: [merged_stats]
  gatk_learnreadorientationmodel:
    run: ../tools/gatk_learnreadorientationmodel.cwl
    in:
      input_f1r2_tars: gatk_mutect2/f1r2
      output_prefix: output_basename
      max_memory: learnreadorientationmodel_max_memory
      cpu: learnreadorientationmodel_cpu
    out: [output]
  gatk_gatherpileupsummaries_tumor:
    run: ../tools/gatk_gatherpileupsummaries.cwl
    in:
      input_tables: gatk_getpileupsummaries_tumor/output
      reference_dict: reference_dict
      output_prefix:
        source: output_basename
        valueFrom: $(self).tumor-
      max_memory: gatherpileupsummaries_max_memory
      cpu: gatherpileupsummaries_cpu
    out: [output]
  gatk_gatherpileupsummaries_normal:
    run: ../tools/gatk_gatherpileupsummaries.cwl
    in:
      input_tables: gatk_getpileupsummaries_normal/output
      reference_dict: reference_dict
      output_prefix:
        source: output_basename
        valueFrom: $(self).normal-
      max_memory: gatherpileupsummaries_max_memory
      cpu: gatherpileupsummaries_cpu
    out: [output]
  gatk_calculatecontamination:
    run: ../tools/gatk_calculatecontamination.cwl
    in:
      input_tumor_pileup: gatk_gatherpileupsummaries_tumor/output
      input_normal_pileup: gatk_gatherpileupsummaries_normal/output
      output_prefix: output_basename
      max_memory: calculatecontamination_max_memory
      cpu: calculatecontamination_cpu
    out: [contamination_table, segmentation_table]
  gatk_filtermutectcalls:
    run: ../tools/gatk_filtermutectcalls.cwl
    in:
      indexed_reference_fasta: indexed_reference_fasta
      input_unfiltered_vcf: bcftools_concat_index/vcf
      input_mutect_stats: gatk_mergemutectstats/merged_stats
      input_contamination_table: gatk_calculatecontamination/contamination_table
      input_tumor_segmentation: gatk_calculatecontamination/segmentation_table
      input_orientation_bias_artifact_priors: gatk_learnreadorientationmodel/output
      max_alt_allele_count:
        valueFrom: $(2)
      output_prefix: output_basename
      max_memory: filtermutectcalls_max_memory
      cpu: filtermutectcalls_cpu
    out: [stats_table, filtered_vcf]
  bcftools_filter_index:
    run: ../tools/bcftools_filter_index.cwl
    in: #gatk_filtermutectcalls/filtered_vcf
      input_vcf: gatk_filtermutectcalls/filtered_vcf
      output_filename:
        source: output_basename
        valueFrom: $(self).mutect2.pass.vcf.gz
      output_type:
        valueFrom: "z"
      include:
        valueFrom: |
          'FILTER == "PASS"'
      targets_file: targets_file
    out: [output]

$namespaces:
  sbg: https://sevenbridges.com

hints:
- class: "sbg:maxNumberOfParallelInstances"
  value: 2
