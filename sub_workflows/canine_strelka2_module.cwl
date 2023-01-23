cwlVersion: v1.2
class: Workflow
id: canine_strelka2_module
doc: "Port of Canine Strelka2 Somatic Module"

requirements:
- class: ScatterFeatureRequirement
- class: StepInputExpressionRequirement
- class: MultipleInputFeatureRequirement
- class: InlineJavascriptRequirement

inputs:
  indexed_reference_fasta: { type: 'File', secondaryFiles: [{ pattern: ".fai", required: true }], doc: "Reference fasta with FAI index" }
  input_tumor_reads: { type: 'File', secondaryFiles: [{ pattern: ".bai", required: false },{ pattern: "^.bai", required: false },{ pattern: ".crai", required: false },{ pattern: "^.crai", required: false }], doc: "BAM/CRAM file containing mapped reads from the tumor sample" }
  input_normal_reads: { type: 'File', secondaryFiles: [{ pattern: ".bai", required: false },{ pattern: "^.bai", required: false },{ pattern: ".crai", required: false },{ pattern: "^.crai", required: false }], doc: "BAM/CRAM file containing mapped reads from the normal sample" }
  call_regions: { type: 'File', secondaryFiles: [{ pattern: ".tbi", required: true}], doc: "Calling regions BED file that has been bgzipped and tabix indexed" }
  config: { type: 'File', doc: "Custom config.ini file for Manta. Used to override defaults set in the global config file" }
  indel_candidates: { type: 'File[]?', secondaryFiles: [{pattern: '.tbi', required: true}], doc: "Specify a VCF of candidate indel alleles. These alleles are always evaluated but only reported in the output when they are inferred to exist in the sample. The VCF must be tabix indexed. All indel alleles must be left-shifted/normalized, any unnormalized alleles will be ignored. This option may be specified more than once, multiple input VCFs will be merged." }
  exome: { type: 'boolean?', doc: "Run Strelka2 in exome mode? Sets options for exome or other targeted input: note in particular that this flag turns off high-depth filters." }
  targets_file: { type: 'File?', doc: "For exome variant calling, this file contains the targets regions used in library preparation." }
  normal_sample_name: { type: 'string', doc: "BAM sample name of normal" }
  tumor_sample_name: { type: 'string', doc: "BAM sample name of tumor" }
  output_basename: { type: 'string', doc: "String to use as basename for outputs." }

  # Resource Control
  strelka2_ram: { type: 'int?', doc: "GB of RAM to allocate to Strelka2." }
  strelka2_cpu: { type: 'int?', doc: "Number of CPUs to allocate to Strelka2." }
  samtools_view_ram: { type: 'int?', doc: "GB of RAM to allocate to Samtools View." }
  samtools_view_cpu: { type: 'int?', doc: "Number of CPUs to allocate to Samtools View." }
 

outputs:
  strelka2_all_vcf: { type: 'File', outputSource: bcftools_concat_index/vcf }
  strelka2_pass_vcf: { type: 'File', outputSource: bcftools_filter_index/output }
  strelka2_realigned_normal_cram: { type: 'File?', outputSource: samtools_view_normal_cram/output }
  strelka2_realigned_tumor_cram: { type: 'File?', outputSource: samtools_view_tumor_cram/output }
  strelka2_all_vcf_stats: { type: 'File', outputSource: bcftools_stats_all/stats }
  strelka2_pass_vcf_stats: { type: 'File', outputSource: bcftools_stats_pass/stats }

steps:
  strelka2_somatic:
    run: ../tools/strelka2_somatic.cwl
    in:
      tumor_bam: input_tumor_reads
      normal_bam: input_normal_reads
      reference: indexed_reference_fasta
      indel_candidates: indel_candidates
      exome: exome
      call_regions: call_regions
      config: config
      cpu: strelka2_cpu
      ram: strelka2_ram
    out: [indels, snvs, realigned_normal_bam, realigned_tumor_bam]

  samtools_view_normal_cram:
    run: ../tools/samtools_view.cwl
    when: $(inputs.input_reads != null)
    in:
      input_reads: strelka2_somatic/realigned_normal_bam
      output_cram:
        valueFrom: $(1 == 1)
      output_filename:
        source: normal_sample_name
        valueFrom: $(self).strelka2.realigned.cram 
      reference_fasta: indexed_reference_fasta
      write_index:
        valueFrom: $(1 == 1)
      cpu: samtools_view_cpu
      ram: samtools_view_ram
    out: [output]

  samtools_view_tumor_cram: 
    run: ../tools/samtools_view.cwl
    when: $(inputs.input_reads != null)
    in:
      input_reads: strelka2_somatic/realigned_tumor_bam
      output_cram:
        valueFrom: $(1 == 1)
      output_filename:
        source: tumor_sample_name
        valueFrom: $(self).strelka2.realigned.cram 
      reference_fasta: indexed_reference_fasta
      write_index:
        valueFrom: $(1 == 1)
      cpu: samtools_view_cpu
      ram: samtools_view_ram
    out: [output]

  bcftools_concat_index:
    run: ../tools/bcftools_concat_index.cwl
    in:
      input_vcfs:
        source: [strelka2_somatic/indels, strelka2_somatic/snvs]
      output_filename:
        source: output_basename
        valueFrom: $(self).strelka2.all.vcf.gz
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
        valueFrom: $(self).strelka2.pass.vcf.gz
      output_type:
        valueFrom: "z"
      include:
        valueFrom: |
          FILTER == "PASS"
      targets_file: targets_file 
      tbi:
        valueFrom: $(1 == 1)
    out: [output]

  bcftools_stats_all:
    run: ../tools/bcftools_stats.cwl
    in:
      input_vcf: bcftools_concat_index/vcf
      output_filename:
        source: output_basename
        valueFrom: $(self).strelka2.all.stats.txt
    out: [stats]

  bcftools_stats_pass:
    run: ../tools/bcftools_stats.cwl
    in:
      input_vcf: bcftools_filter_index/output
      output_filename:
        source: output_basename
        valueFrom: $(self).strelka2.pass.stats.txt
    out: [stats]

$namespaces:
  sbg: https://sevenbridges.com

hints:
- class: "sbg:maxNumberOfParallelInstances"
  value: 2
