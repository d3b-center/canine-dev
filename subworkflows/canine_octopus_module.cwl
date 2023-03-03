cwlVersion: v1.2
class: Workflow
id: canine_octopus_module
doc: "Port of Canine Octopus Somatic Module"

requirements:
- class: ScatterFeatureRequirement
- class: StepInputExpressionRequirement
- class: MultipleInputFeatureRequirement
- class: InlineJavascriptRequirement

inputs:
  # Killswitch
  disable_workflow: { type: 'boolean?', doc: "For when this workflow is wrapped into a larger workflow, you can use this value in the when statement to toggle the running of this workflow." }

  calling_intervals: { type: 'File', doc: "YAML file contianing the intervals in which to perform variant calling." }
  indexed_reference_fasta: { type: 'File', secondaryFiles: [{ pattern: ".fai", required: true }, { pattern: "^.dict", required: true }], doc: "Reference fasta with FAI index" }
  input_reads: { type: 'File[]', secondaryFiles: [{ pattern: ".bai", required: false },{ pattern: "^.bai", required: false },{ pattern: ".crai", required: false },{ pattern: "^.crai", required: false }], doc: "BAM/CRAM files to be analysed." }
  normal_sample_name: { type: 'string', doc: "BAM sample name of normal" }
  output_basename: { type: 'string', doc: "String to use as basename for outputs." }
  targets_file: { type: 'File?', doc: "For exome variant calling, this file contains the targets regions used in library preparation." }

  # Resource Control
  octopus_ram: { type: 'int?', doc: "Maximum GB of RAM to allocate to Octopus." }
  octopus_cpu: { type: 'int?', doc: "Number of CPUs to allocate to Octopus." }

outputs:
  octopus_all_vcf: { type: 'File', outputSource: bcftools_concat_sort_index/output }
  octopus_pass_vcf: { type: 'File', outputSource: bcftools_filter_index/output }
  octopus_all_vcf_stats: { type: 'File', outputSource: bcftools_stats_all/stats }
  octopus_pass_vcf_stats: { type: 'File', outputSource: bcftools_stats_pass/stats }

steps:
  calling_intervals_yaml_to_beds:
    run: ../tools/calling_intervals_yaml_to_beds.cwl
    in:
      input_yaml: calling_intervals
    out: [outputs]

  octopus:
    hints:
      - class: 'sbg:AWSInstanceType'
        value: c5.9xlarge
    run: ../tools/octopus.cwl
    scatter: [regions_file]
    in:
      reference: indexed_reference_fasta
      reads: input_reads
      normal_sample: normal_sample_name
      regions_file: calling_intervals_yaml_to_beds/outputs
      caller:
        source: disable_workflow # Sinking this someplace it will do nothing to circumvent graph not connected cavatica error
        valueFrom: "cancer"
      max_reference_cache_footprint:
        valueFrom: "4GB"
      target_read_buffer_footprint:
        valueFrom: "6GB"
      ignore_unmapped_contigs:
        valueFrom: $(1 == 1)
      somatics_only:
        valueFrom: $(1 == 1)
      phasing_level:
        valueFrom: "minimal"
      legacy:
        valueFrom: $(1 == 1)
      annotations:
        valueFrom: $(["AD","ADP","AF","SB"])
      somatic_filter_expression:
        valueFrom: |
          QUAL < 2 | GQ < 20 | MQ < 30 | SMQ < 40 | SD > 0.9 | BQ < 20 | DP < 3 | MF > 0.2 | NC > 5 | FRF > 0.5 | AD < -1 | AF < -1 | ADP > 100000000 | SB < -1
      output_sam_dirname:
        valueFrom: $(inputs.regions_file.basename).realigned
      output_vcf_filename:
        valueFrom: $(inputs.regions_file.basename).octopus.vcf
      cpu: octopus_cpu
      ram: octopus_ram
    out: [debug_log, trace_log, vcf, legacy_vcf, bam, data_profile]

  bcftools_concat_sort_index:
    run: ../tools/bcftools_concat_sort_index.cwl
    in:
      input_vcfs: octopus/legacy_vcf
      output_filename:
        source: output_basename
        valueFrom: $(self).octopus.all.vcf.gz
      output_type:
        valueFrom: "z"
      tbi:
        valueFrom: $(1 == 1)
      tool_name:
        valueFrom: "octopus"
    out: [output]

  bcftools_filter_index:
    run: ../tools/bcftools_filter_index.cwl
    in:
      input_vcf: bcftools_concat_sort_index/output
      include:
        valueFrom: |
          'FILTER == "PASS"'
      targets_file: targets_file
      output_filename:
        source: output_basename
        valueFrom: $(self).octopus.pass.vcf.gz
      output_type:
        valueFrom: "z"
      tbi:
        valueFrom: $(1 == 1)
      tool_name:
        valueFrom: "octopus"
    out: [output]

  bcftools_stats_all:
    run: ../tools/bcftools_stats.cwl
    in:
      input_vcf: bcftools_concat_sort_index/output
      output_filename:
        source: output_basename
        valueFrom: $(self).octopus.all.stats.txt
    out: [stats]

  bcftools_stats_pass:
    run: ../tools/bcftools_stats.cwl
    in:
      input_vcf: bcftools_filter_index/output
      output_filename:
        source: output_basename
        valueFrom: $(self).octopus.pass.stats.txt
    out: [stats]

$namespaces:
  sbg: https://sevenbridges.com

hints:
- class: "sbg:maxNumberOfParallelInstances"
  value: 2
