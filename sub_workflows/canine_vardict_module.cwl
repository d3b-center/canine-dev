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
  calling_intervals: { type: 'File', doc: "YAML file contianing the intervals in which to perform variant calling." }
  input_tumor_reads: { type: 'File', secondaryFiles: [{ pattern: ".bai", required: false },{ pattern: "^.bai", required: false },{ pattern: ".crai", required: false },{ pattern: "^.crai", required: false }], doc: "BAM/SAM/CRAM file containing reads from the tumor sample" }
  input_normal_reads: { type: 'File', secondaryFiles: [{ pattern: ".bai", required: false },{ pattern: "^.bai", required: false },{ pattern: ".crai", required: false },{ pattern: "^.crai", required: false }], doc: "BAM/SAM/CRAM file containing reads from the normal sample" }
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

steps:
  # Need to modify this script to use bedtools
  calling_intervals_yaml_to_beds:
    run: ../tools/calling_intervals_yaml_to_beds.cwl
    in:
      input_yaml: calling_intervals
    out: [outputs]

  vardict_testsomatic_var2vcf_paired_view_index:
    run: ../tools/vardict_testsomatic_var2vcf_paired_view_index.cwl
    scatter: [regions_file]
    in:
      input_bam_files:
        source: [input_normal_reads, input_tumor_reads] # Need to figure out to handle this
      sample_name: tumor_sample_name # Perhaps steal from samples_name variable or something else?
      indexed_reference_fasta: indexed_reference_fasta
      hexical_read_filter:
        valueFrom: "0x500"
      read_mean_mapq_min:
        valueFrom: $(5)
      read_mapq_min:
        valueFrom: $(1)
      base_phred_min:
        valueFrom: $(20)
      dedup:
        valueFrom: $(1 == 1)
      nosv:
        valueFrom: $(1 == 1)
      unique_first:
        valueFrom: $(1 == 1)
      chrom_column:
        valueFrom: $(1)
      region_start_column:
        valueFrom: $(2)
      region_end_column:
        valueFrom: $(3)
      regions_file: calling_intervals_yaml_to_beds/outputs 
      sample_names:
        source: [tumor_sample_name, normal_sample_name] # Need to figure out how to handle this
      mapq_min:
        valueFrom: $(1)
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
      input_vcfs: vardict_testsomatic_var2vcf_paired_view_index/output 
      output_filename:
        source: output_basename
        valueFrom: $(self).vardict.all.vcf.gz
      output_type:
        valueFrom: "z"
      allow_overlaps:
        valueFrom: $(1 == 1)
      tbi:
        valueFrom: $(1 == 1)
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
          'FILTER == "PASS" & INFO/STATUS == "StrongSomatic"'
      targets_file: targets_file
    out: [output]

# vcf stats for pass vcf
# vcf stats for all vcf

$namespaces:
  sbg: https://sevenbridges.com

hints:
- class: "sbg:maxNumberOfParallelInstances"
  value: 2
