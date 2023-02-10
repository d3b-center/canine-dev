cwlVersion: v1.2
class: CommandLineTool
id: deepvariant_make_examples 
doc: "Deepvariant make_examples"
requirements:
  - class: InlineJavascriptRequirement
  - class: ShellCommandRequirement
  - class: ResourceRequirement
    ramMin: $(inputs.max_memory*1000)
    coresMin: $(inputs.cpu)
  - class: DockerRequirement
    dockerPull: 'google/deepvariant:0.10.0'
baseCommand: [/opt/deepvariant/bin/make_examples]
inputs:
  candidates: { type: 'File?', inputBinding: { position: 2, prefix: "--candidates"}, doc: "Candidate DeepVariantCalls in tfrecord format. For DEBUGGING." }
  confident_regions_file: { type: 'File?', inputBinding: { position: 2, prefix: "--confident_regions"}, doc: "Regions that we are confident are hom-ref or a variant in BED format. In BED or other equivalent format, sorted or unsorted. Contig names must match those of the reference genome." }
  custom_pileup_image: { type: 'boolean?', inputBinding: { position: 2, prefix: "--custom_pileup_image"}, doc: "Experimental - please do not set this flag. If True, an additional channel will be added to encode CIGAR op length for indels." }
  customized_classes_labeler_classes_list: { type: 'string?', inputBinding: { position: 2, prefix: "--customized_classes_labeler_classes_list"}, doc: "A comma-separated list of strings that defines customized class labels for variants. This is only set when labeler_algorithm is customized_classes_labeler." }
  customized_classes_labeler_info_field_name: { type: 'string?', inputBinding: { position: 2, prefix: "--customized_classes_labeler_info_field_name"}, doc: "The name from the INFO field of VCF where we should get the customized class labels from. This is only set when labeler_algorithm is customized_classes_labeler." }
  downsample_fraction: { type: 'float?', inputBinding: { position: 2, prefix: "--downsample_fraction"}, doc: "If not 0.0 must be a value between 0.0 and 1.0. Reads will be kept (randomly) with a probability of downsample_fraction from the input BAM. This argument makes it easy to create examples as though the input BAM had less coverage." }
  examples_outname: { type: 'string', inputBinding: { position: 2, prefix: "--examples"}, doc: "Required. Path to write tf.Example protos in TFRecord format." }
  exclude_regions: { type: 'string?', inputBinding: { position: 2, prefix: "--exclude_regions"}, doc: "Optional. Space-separated list of regions we want to exclude from processing. Elements can be region literals (e.g., chr20   10-20). Region exclusion happens after processing the --regions argument, so --region 20 --exclude_regions 20   100 does everything on chromosome 20 excluding base 100" }
  exclude_regions_file:  { type: 'File?', inputBinding: { position: 2, prefix: "--exclude_regions"}, doc: "Optional. List of regions we want to exclude from processing in BED/BEDPE files. Region exclusion happens after processing the --regions argument, so --region 20 --exclude_regions 20   100 does everything on chromosome 20 excluding base 100" }
  gvcf_outname: { type: 'string?', inputBinding: { position: 2, prefix: "--gvcf"}, doc: "Optional. Path where we should write gVCF records in TFRecord of Variant proto format." }
  gvcf_gq_binsize: { type: 'int?', inputBinding: { position: 2, prefix: "--gvcf_gq_binsize"}, doc: "Bin size in which to quantize gVCF genotype qualities. Larger bin size reduces the number of gVCF records at a loss of quality granularity." }
  hts_block_size: { type: 'int?', inputBinding: { position: 2, prefix: "--hts_block_size"}, doc: "Sets the htslib block size. Zero or negative uses default htslib setting; larger values (e.g. 1M) may be beneficial for using remote files. Currently only applies to SAM/BAM reading." }
  hts_logging_level: { type: 'string?', inputBinding: { position: 2, prefix: "--hts_logging_level"}, doc: "Sets the htslib logging threshold." }
  keep_duplicates: { type: 'boolean?', inputBinding: { position: 2, prefix: "--keep_duplicates"}, doc: "If True, keep duplicate reads." }
  keep_secondary_alignments: { type: 'boolean?', inputBinding: { position: 2, prefix: "--keep_secondary_alignments"}, doc: "If True, keep reads marked as secondary alignments." }
  keep_supplementary_alignments: { type: 'boolean?', inputBinding: { position: 2, prefix: "--keep_supplementary_alignments"}, doc: "If True, keep reads marked as supplementary alignments." }
  labeler_algorithm: { type: 'string?', inputBinding: { position: 2, prefix: "--labeler_algorithm"}, doc: "Algorithm to use to label examples in training mode. Must be one of the LabelerAlgorithm enum values in the DeepVariantOptions proto." }
  logging_every_n_candidates: { type: 'int?', inputBinding: { position: 2, prefix: "--logging_every_n_candidates"}, doc: "Print out the log every n candidates. The smaller the number, the more frequent the logging information emits." }
  max_reads_per_partition: { type: 'int?', inputBinding: { position: 2, prefix: "--max_reads_per_partition"}, doc: "The maximum number of reads per partition that we consider before following processing such as sampling and realigner." }
  min_base_quality: { type: 'int?', inputBinding: { position: 2, prefix: "--min_base_quality"}, doc: "Minimum base quality. This field indicates that we are enforcing a minimum base quality score for alternate alleles. Alternate alleles will only be considered if all bases in the allele have a quality greater than min_base_quality." }
  min_mapping_quality: { type: 'int?', inputBinding: { position: 2, prefix: "--min_mapping_quality"}, doc: "By default, reads with any mapping quality are kept. Setting this field to a positive integer i will only keep reads that have a MAPQ >= i. Note this only applies to aligned reads." }
  mode:
    type:
      - 'null'
      - type: enum
        name: mode
        symbols: ["calling", "training"]
    inputBinding:
      prefix: "--mode"
      position: 2
    doc: |
      Mode to run. Must be one of calling or training.
  multi_allelic_mode: { type: 'string?', inputBinding: { position: 2, prefix: "--multi_allelic_mode"}, doc: "How to handle multi-allelic candidate variants. For DEBUGGING" }
  parse_sam_aux_fields: { type: 'boolean?', inputBinding: { position: 2, prefix: "--parse_sam_aux_fields"}, doc: "If True, auxiliary fields of the SAM/BAM/CRAM records are parsed." }
  partition_size: { type: 'int?', inputBinding: { position: 2, prefix: "--partition_size"}, doc: "The maximum number of basepairs we will allow in a region before splittingit into multiple smaller subregions." }
  pileup_image_height: { type: 'int?', inputBinding: { position: 2, prefix: "--pileup_image_height"}, doc: "Height for the pileup image. If 0, uses the default height" }
  pileup_image_width: { type: 'int?', inputBinding: { position: 2, prefix: "--pileup_image_width"}, doc: "Width for the pileup image. If 0, uses the default width" }
  proposed_variants: { type: 'File?', secondaryFiles: [{ pattern: '.tbi', required: true }], inputBinding: { position: 2, prefix: "--proposed_variants"}, doc: "(Only used when --variant_caller=vcf_candidate_importer.) Tabix-indexed VCF file containing the proposed positions and alts for `vcf_candidate_importer`. The GTs will be ignored." }
  reads: { type: 'File[]', secondaryFiles: [{ pattern: '.bai', required: true }], inputBinding: { position: 2, prefix: "--reads"}, doc: "Required. Aligned, sorted, indexed BAM file containing the reads we want to call. Should be aligned to a reference genome compatible with --ref. Can provide multiple BAMs (comma-separated)." }
  realign_reads: { type: 'boolean?', inputBinding: { position: 2, prefix: "--realign_reads"}, doc: "If True, locally realign reads before calling variants." }
  ref: { type: 'File', secondaryFiles: [{ pattern: '.fai', required: true }], inputBinding: { position: 2, prefix: "--ref"}, doc: "Required. Genome reference to use. Must have an associated FAI index as well. Supports text or gzipped references. Should match the reference used to align the BAM file provided to --reads." }
  regions_file: { type: 'File?', inputBinding: { position: 2, prefix: "--regions"}, doc: "Optional. List of regions we want to process in BED/BEDPE files." }
  regions: { type: 'string?', inputBinding: { position: 2, prefix: "--regions"}, doc: "Optional. Space-separated list of regions we want to process. (e.g., chr20:10-20)" }
  sample_name: { type: 'string?', inputBinding: { position: 2, prefix: "--sample_name"}, doc: "Sample name to use for our sample_name in the output Variant/DeepVariantCall protos. If not specified, will be inferred from the header information from --reads." }
  select_variant_types: { type: 'string[]?', inputBinding: { position: 2, prefix: "--select_variant_types"}, doc: "If provided, should be a whitespace-separated string of variant types to keep when generating examples. Permitted values are 'snps', 'indels', 'multi-allelics', and 'all', which select bi-allelic snps, bi-allelic indels, multi-allelic variants of any type, and all variants, respectively. Multiple selectors can be specified, so that --select_variant_types='snps indels' would keep all bi-allelic SNPs and indels" }
  sequencing_type:
    type:
      - 'null'
      - type: enum
        name: sequencing_type
        symbols: ["WGS", "WES"]
    inputBinding:
      prefix: "--sequencing_type"
      position: 2
    doc: |
      A string representing input bam file sequencing_type. Permitted values
      are 'WGS' and 'WES', which represent whole genome sequencing and whole exome
      sequencing, respectively. This flag is experimental and is not currently being
      used.
  sequencing_type_image: { type: 'boolean?', inputBinding: { position: 2, prefix: "--sequencing_type_image"}, doc: "If True, add an additional channel representing the sequencing type of the input example. This flag is experimental and is not currently being used." }
  task: { type: 'int?', inputBinding: { position: 2, prefix: "--task"}, doc: "Task ID of this task" }
  task_total: { type: 'int?', doc: "Total number of task shards being run." }
  training_random_emit_ref_sites: { type: 'float?', inputBinding: { position: 2, prefix: "--training_random_emit_ref_sites"}, doc: "If > 0, emit extra random reference examples with this probability." }
  truth_variants: { type: 'File?', inputBinding: { position: 2, prefix: "--truth_variants"}, doc: "Tabix-indexed VCF file containing the truth variant calls for this labels which we use to label our examples." }
  use_original_quality_scores: { type: 'boolean?', inputBinding: { position: 2, prefix: "--use_original_quality_scores"}, doc: "If True, base quality scores are read from OQ tag." }
  use_ref_for_cram: { type: 'boolean?', inputBinding: { position: 2, prefix: "--use_ref_for_cram"}, doc: "If true, use the --ref argument as the reference file for the CRAM file passed to --reads.  In this case, it is required that the reference file be located on a local POSIX filesystem. To disable, specify --nouse_ref_for_cram." }
  variant_caller: { type: 'string?', inputBinding: { position: 2, prefix: "--variant_caller"}, doc: "The caller to use to make examples. Must be one of the VariantCaller enum values in the DeepVariantOptions proto." }
  vsc_min_count_indels: { type: 'int?', inputBinding: { position: 2, prefix: "--vsc_min_count_indels"}, doc: "Indel alleles occurring at least this many times in our AlleleCount will be advanced as candidates." }
  vsc_min_count_snps: { type: 'int?', inputBinding: { position: 2, prefix: "--vsc_min_count_snps"}, doc: "SNP alleles occurring at least this many times in our AlleleCount will be advanced as candidates." }
  vsc_min_fraction_indels: { type: 'float?', inputBinding: { position: 2, prefix: "--vsc_min_fraction_indels"}, doc: "Indel alleles occurring at least this fraction of all counts in our AlleleCount will be advanced as candidates." }
  vsc_min_fraction_snps: { type: 'float?', inputBinding: { position: 2, prefix: "--vsc_min_fraction_snps"}, doc: "SNP alleles occurring at least this fraction of all counts in our AlleleCount will be advanced as candidates." }
  write_run_info: { type: 'boolean?', inputBinding: { position: 2, prefix: "--write_run_info"}, doc: "If True, write out a MakeExamplesRunInfo proto besides our examples in text_format." }

  cpu:
    type: 'int?'
    default: 1
    doc: "Number of CPUs to allocate to this task."
  ram:
    type: 'int?'
    default: 4
    doc: "Maximum GB of RAM to allocate for this tool."
outputs:
  examples:
    type: File
    outputBinding:
      glob: "*.ex.tfrecord*gz" 
  gvcf:
    type: 'File?'
    outputBinding:
      glob: "*.gvcf.tfrecord*"
