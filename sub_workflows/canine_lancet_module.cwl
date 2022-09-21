cwlVersion: v1.2
class: Workflow
id: canine_lancet_module
doc: "Port of Canine Lancet Somatic Module"

requirements:
- class: ScatterFeatureRequirement
- class: StepInputExpressionRequirement
- class: MultipleInputFeatureRequirement
- class: InlineJavascriptRequirement

inputs:
  calling_intervals: { type: 'File', doc: "YAML file contianing the intervals in which to perform variant calling." }
  reference_fasta: { type: 'File', doc: "Reference fasta" }
  reference_fai: { type: 'File', doc: "Reference fai" }
  input_tumor_reads: { type: 'File', doc: "BAM file containing mapped reads from the tumor sample" }
  input_normal_reads: { type: 'File', doc: "BAM file containing mapped reads from the normal sample" }
  output_basename: { type: 'string', doc: "String to use as basename for outputs." }
  targets_file: { type: 'File?', doc: "For exome variant calling, this file contains the targets regions used in library preparation." }

  # Resource Control
  lancet_ram: { type: 'int?', doc: "Maximum GB of RAM to allocate to Lancet." }
  lancet_cpu: { type: 'int?', doc: "Number of CPUs to allocate to Lancet." }

outputs:
  lancet_all_vcf: { type: 'File', outputSource: bcftools_concat_sort_index.cwl/vcf }
  lancet_pass_vcf: { type: 'File', outputSource: bcftools_filter_index/output }

steps:
  calling_intervals_yaml_to_beds:
    run: ../tools/calling_intervals_yaml_to_beds.cwl
    in:
      input_yaml: calling_intervals
    out: [outputs]

  lancet:
    run: ../tools/lancet.cwl
    scatter: [bed]
    in:
      normal: input_normal_reads
      tumor: input_tumor_reads
      ref: reference_fasta
      bed: calling_intervals_yaml_to_beds/outputs
      output_filename:
        source: output_basename
        valueFrom: $(self).$(inputs.bed.basename).lancet-uns.vcf
      max_vaf_normal:
        valueFrom: $(0.05)
      max_alt_count_normal:
        valueFrom: $(50)
      cpu: lancet_cpu
      ram: lancet_ram
    out: [vcf]

  bcftools_reheader_sort_index:
    run: ../tools/bcftools_reheader_sort_index.cwl
    scatter: [input_file]
    in:
      input_file: lancet/vcf 
      output_filename:
        valueFrom: $(inputs.input_file.basename.replace("lancet-uns","lancet"))
      output_type:
        valueFrom: "v"
      fai: reference_fai
    out: [output]

  bcftools_concat_sort_index.cwl:
    run: ../tools/bcftools_concat_sort_index.cwl
    in:
      input_vcfs: bcftools_reheader_sort_index/output
      output_filename:
        source: output_basename
        valueFrom: $(self).lancet.all.vcf.gz
      output_type:
        valueFrom: "z"
      tbi:
        valueFrom: $(1 == 1)
    out: [vcf]

  bcftools_filter_index:
    run: ../tools/bcftools_filter_index.cwl
    in:
      input_vcf: bcftools_concat_sort_index.cwl/vcf
      output_filename:
        source: output_basename
        valueFrom: $(self).lancet.pass.vcf.gz
      output_type:
        valueFrom: "z"
      include:
        valueFrom: |
          'FILTER == "PASS"'
      targets_file: targets_file
      tbi:
        valueFrom: $(1 == 1)
    out: [output]

# vcf stats for pass vcf
# vcf stats for all vcf

$namespaces:
  sbg: https://sevenbridges.com

hints:
- class: "sbg:maxNumberOfParallelInstances"
  value: 2