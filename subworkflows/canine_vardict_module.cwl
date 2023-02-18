cwlVersion: v1.2
class: Workflow
id: canine_vardict_module
doc: "Port of Canine Vardict Somatic Module"

requirements:
- class: ScatterFeatureRequirement
- class: StepInputExpressionRequirement
- class: MultipleInputFeatureRequirement
- class: InlineJavascriptRequirement

inputs:
  # Killswitch
  disable_workflow: { type: 'boolean?', doc: "For when this workflow is wrapped into a larger workflow, you can use this value in the when statement to toggle the running of this workflow." }

  calling_intervals: { type: 'File', doc: "YAML file contianing the intervals in which to perform variant calling." }
  input_tumor_reads: { type: 'File', secondaryFiles: [{ pattern: ".bai", required: false },{ pattern: "^.bai", required: false }], doc: "BAM file containing reads from the tumor sample" }
  input_normal_reads: { type: 'File', secondaryFiles: [{ pattern: ".bai", required: false },{ pattern: "^.bai", required: false }], doc: "BAM file containing reads from the normal sample" }
  tumor_sample_name: { type: 'string', doc: "BAM sample name of tumor" }
  normal_sample_name: { type: 'string', doc: "BAM sample name of normal" }
  indexed_reference_fasta: { type: 'File', secondaryFiles: [{ pattern: ".fai", required: true }], doc: "Reference fasta with FAI index" }
  targets_file: { type: 'File?', doc: "For exome variant calling, this file contains the targets regions used in library preparation." }
  output_basename: { type: 'string', doc: "String to use as basename for outputs." }

  # Resource Control
  vardict_ram: { type: 'int?', doc: "GB of RAM to allocate to Vardict." }
  vardict_cpu: { type: 'int?', doc: "CPUs to allocate to Vardict." }

outputs:
  vardict_all_vcf: { type: 'File', outputSource: bcftools_concat_index/vcf }
  vardict_pass_vcf: { type: 'File', outputSource: bcftools_filter_index/output }
  varidct_all_vcf_stats: { type: 'File', outputSource: bcftools_stats_all/stats }
  vardict_pass_vcf_stats: { type: 'File', outputSource: bcftools_stats_pass/stats }

steps:
  calling_intervals_yaml_to_beds:
    run: ../tools/calling_intervals_yaml_to_beds.cwl
    in:
      input_yaml: calling_intervals
    out: [outputs]

  bedtools_makewindows:
    run: ../tools/bedtools_makewindows.cwl
    scatter: [bed]
    in:
      bed: calling_intervals_yaml_to_beds/outputs
      window_size:
        valueFrom: $(20000)
      step_size:
        valueFrom: $(19850)
      output_filename:
        valueFrom: chunked_$(inputs.bed.basename)
    out: [output]

  vardict_testsomatic_var2vcf_paired_bcftools_view_index:
    hints:
      - class: 'sbg:AWSInstanceType'
        value: c5.9xlarge
    run: ../tools/vardict_testsomatic_var2vcf_paired_bcftools_view_index.cwl
    scatter: [regions_file]
    in:
      input_bam_files:
        source: [input_tumor_reads, input_normal_reads]
      sample_name: tumor_sample_name
      indexed_reference_fasta: indexed_reference_fasta
      std:
        valueFrom: $(3)
      bias_min_reads:
        valueFrom: $(2)
      hexical_read_filter:
        source: disable_workflow # Sinking this someplace it will do nothing to circumvent graph not connected cavatica error
        valueFrom: "0x500"
      allele_frequency_max:
        valueFrom: $(0.01)
      indel_size:
        valueFrom: $(50)
      local_realignment:
        valueFrom: $(1)
      read_match_min:
        valueFrom: $(0)
      read_mismatch_max:
        valueFrom: $(8)
      read_mean_mapq_min:
        valueFrom: $(5)
      qratio:
        valueFrom: $(1.5)
      read_position_filter:
        valueFrom: $(5)
      read_mapq_min:
        valueFrom: $(1)
      base_phred_min:
        valueFrom: $(20)
      variant_reads_min:
        valueFrom: $(2)
      dedup:
        valueFrom: $(1 == 1)
      nosv:
        valueFrom: $(1 == 1)
      unique_first:
        valueFrom: $(1 == 1)
      mutation_frequency_min:
        valueFrom: $(0.05)
      read_strictness:
        valueFrom: "LENIENT"
      indel_extension:
        valueFrom: $(2)
      segment_extension:
        valueFrom: $(0)
      chrom_column:
        valueFrom: $(1)
      region_start_column:
        valueFrom: $(2)
      region_end_column:
        valueFrom: $(3)
      regions_file: bedtools_makewindows/output
      sample_names:
        source: normal_sample_name
        valueFrom: $([inputs.sample_name, self])
      candidate_proximity_max:
        valueFrom: $(0)
      nonmonomer_max:
        valueFrom: $(12)
      read_mean_mismatch_max:
        valueFrom: $(5.25)
      p_value_max:
        valueFrom: $(0.05)
      mean_pos_min:
        valueFrom: $(5)
      mean_bq_min:
        valueFrom: $(22.5)
      mapq_min:
        valueFrom: $(1)
      total_depth_min:
        valueFrom: $(5)
      var_depth_min:
        valueFrom: $(3)
      allele_freq_min:
        valueFrom: $(0.02)
      genotype_frequency:
        valueFrom: $(0.2)
      signal_noise_ratio:
        valueFrom: $(1.5)
      output_filename:
        source: output_basename
        valueFrom: $(self).vardict.vcf.gz
      output_type:
        valueFrom: "z"
      tbi:
        valueFrom: $(1 == 1)
      cpu: vardict_cpu
      ram: vardict_ram
    out: [output]

  bcftools_concat_index:
    run: ../tools/bcftools_concat_index.cwl
    in:
      input_vcfs: vardict_testsomatic_var2vcf_paired_bcftools_view_index/output
      output_filename:
        source: output_basename
        valueFrom: $(self).vardict.all.vcf.gz
      output_type:
        valueFrom: "z"
      allow_overlaps:
        valueFrom: $(1 == 1)
      tbi:
        valueFrom: $(1 == 1)
      tool_name:
        valueFrom: "vardict"
    out: [vcf]

  bcftools_filter_index:
    run: ../tools/bcftools_filter_index.cwl
    in:
      input_vcf: bcftools_concat_index/vcf
      output_filename:
        source: output_basename
        valueFrom: $(self).vardict.pass.vcf.gz
      output_type:
        valueFrom: "z"
      include:
        valueFrom: |
          FILTER == "PASS" & INFO/STATUS == "StrongSomatic"
      targets_file: targets_file
      tbi:
        valueFrom: $(1 == 1)
      tool_name:
        valueFrom: "vardict"
    out: [output]

  bcftools_stats_all:
    run: ../tools/bcftools_stats.cwl
    in:
      input_vcf: bcftools_concat_index/vcf
      output_filename:
        source: output_basename
        valueFrom: $(self).vardict.all.stats.txt
    out: [stats]

  bcftools_stats_pass:
    run: ../tools/bcftools_stats.cwl
    in:
      input_vcf: bcftools_filter_index/output
      output_filename:
        source: output_basename
        valueFrom: $(self).vardict.pass.stats.txt
    out: [stats]

$namespaces:
  sbg: https://sevenbridges.com

hints:
- class: "sbg:maxNumberOfParallelInstances"
  value: 2
