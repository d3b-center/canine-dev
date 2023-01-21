cwlVersion: v1.2
class: Workflow
id: canine_manta_module
doc: "Port of Canine Manta Somatic Module"

requirements:
- class: ScatterFeatureRequirement
- class: StepInputExpressionRequirement
- class: MultipleInputFeatureRequirement
- class: InlineJavascriptRequirement

inputs:
  indexed_reference_fasta: { type: 'File', secondaryFiles: [{ pattern: ".fai", required: true }, { pattern: "^.dict", required: true }], doc: "Reference fasta with FAI and DICT indicies" }
  input_tumor_reads: { type: 'File', secondaryFiles: [{ pattern: ".bai", required: false },{ pattern: "^.bai", required: false },{ pattern: ".crai", required: false },{ pattern: "^.crai", required: false }], doc: "BAM/SAM/CRAM file containing mapped reads from the tumor sample" }
  input_normal_reads: { type: 'File', secondaryFiles: [{ pattern: ".bai", required: false },{ pattern: "^.bai", required: false },{ pattern: ".crai", required: false },{ pattern: "^.crai", required: false }], doc: "BAM/SAM/CRAM file containing mapped reads from the normal sample" }
  tumor_sample_name: { type: 'string', doc: "BAM sample name of tumor" }
  call_regions: { type: 'File', secondaryFiles: [{ pattern: ".tbi", required: true}], doc: "Calling regions BED file that has been bgzipped and tabix indexed" }
  config: { type: 'File', doc: "Custom config.ini file for Manta. Used to override defaults set in the global config file" }
  exome: { type: 'boolean?', doc: "Run Manta in exome mode? Turns off depth filters" }
  samtools_stats: { type: 'File', doc: "File containing samtools stats insert size summary information." }
  annotation_bed: { type: 'File', doc: "BED file containing annotations for called variants" }
  output_basename: { type: 'string', doc: "String to use as basename for outputs." }

  # Resource Control
  manta_ram: { type: 'int?', doc: "Maximum GB of RAM to allocate to Manta." }
  manta_cpu: { type: 'int?', doc: "Number of CPUs to allocate to Manta." }

outputs:
  manta_somatic_pass_svs: { type: 'File', outputSource: bcftools_view_index_anno/output }
  manta_small_indels: { type: 'File', outputSource: manta/small_indels }

steps:
  manta:
    run: ../tools/manta.cwl
    in:
      indexed_reference_fasta: indexed_reference_fasta
      input_tumor_reads: input_tumor_reads
      input_normal_reads:
        source: input_normal_reads
        valueFrom: $([self])
      config: config
      call_regions: call_regions
      exome: exome
      cpu: manta_cpu
      ram: manta_ram
    out: [candidate_sv, diploid_sv, somatic_sv, tumor_sv, small_indels]

  bcftools_filter_index:
    run: ../tools/bcftools_filter_index.cwl
    in:
      input_vcf: manta/somatic_sv
      output_filename:
        valueFrom: somaticSV.pass.vcf.gz
      include:
        valueFrom: |
          FILTER == "PASS"
      output_type:
        valueFrom: "z"
      tbi:
        valueFrom: $(1 == 1)
    out: [output]

  manta_harvest_samtools_stats:
    run: ../tools/manta_harvest_samtools_stats.cwl
    in:
      samtools_stats: samtools_stats
    out: [insert_size, std_is]

  coyote_manta_prepare_sv_vcf:
    run: ../tools/coyote_manta_prepare_sv_vcf.cwl
    in:
      input_vcf: bcftools_filter_index/output
      tumor_bam_file: input_tumor_reads
      normal_bam_file: input_normal_reads
      tumor_name: tumor_sample_name
      refgen: indexed_reference_fasta
      output_filename:
        valueFrom: somaticSV.pass.flag.vcf
      insert_size: manta_harvest_samtools_stats/insert_size
      sigma: manta_harvest_samtools_stats/std_is
      minmapq:
        valueFrom: $(15)
    out: [output]

  bcftools_view_index_flag:
    run: ../tools/bcftools_view_index.cwl
    in:
      input_vcf: coyote_manta_prepare_sv_vcf/output
      output_filename:
        valueFrom: somaticSV.pass.flag.vcf.gz
      output_type:
        valueFrom: "z"
      tbi:
        valueFrom: $(1 == 1)
    out: [output]

  coyote_manta_sv_annotation_parallel:
    run: ../tools/coyote_manta_sv_annotation_parallel.cwl
    in:
      input_vcf: bcftools_view_index_flag/output
      annotation_bed: annotation_bed
      output_filename:
        source: output_basename
        valueFrom: somaticSV.pass.flag.anno.vcf
    out: [output]

  bcftools_view_index_anno:
    run: ../tools/bcftools_view_index.cwl
    in:
      input_vcf: coyote_manta_sv_annotation_parallel/output
      output_filename:
        source: output_basename
        valueFrom: $(self).manta.somaticSV.pass.vcf.gz
      output_type:
        valueFrom: "z"
      tbi:
        valueFrom: $(1 == 1)
    out: [output]

$namespaces:
  sbg: https://sevenbridges.com

hints:
- class: "sbg:maxNumberOfParallelInstances"
  value: 2
