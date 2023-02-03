cwlVersion: v1.2
class: CommandLineTool
id: gatk_filtermutectcalls
doc: "Filter somatic SNVs and indels called by Mutect2"
requirements:
  - class: InlineJavascriptRequirement
  - class: ShellCommandRequirement
  - class: ResourceRequirement
    ramMin: $(inputs.max_memory*1000)
    coresMin: $(inputs.cpu)
  - class: DockerRequirement
    dockerPull: 'broadinstitute/gatk:4.1.8.0'
baseCommand: []
arguments:
  - position: 0
    shellQuote: false
    valueFrom: >-
      gatk
  - position: 1
    shellQuote: false
    prefix: "--java-options"
    valueFrom: >-
      $("\"-Xmx"+Math.floor(inputs.max_memory*1000/1.074 - 1)+"M\"")
  - position: 2
    shellQuote: false
    valueFrom: >-
      FilterMutectCalls 
  - position: 3
    shellQuote: false
    prefix: "--output"
    valueFrom: >-
      ${var pre = inputs.output_prefix ? inputs.output_prefix : inputs.input_unfiltered_vcf.nameroot; var ext = 'mutect2.filtered.vcf.gz'; return pre+'.'+ext}
  - position: 3
    shellQuote: false
    prefix: "--filtering-stats"
    valueFrom: >-
      ${var pre = inputs.output_prefix ? inputs.output_prefix : inputs.input_unfiltered_vcf.nameroot; var ext = 'mutect2.filtering.stats'; return pre+'.'+ext}
inputs:
  # Required Arguments
  indexed_reference_fasta: { type: 'File', inputBinding: { position: 2, prefix: "--reference"}, doc: "Reference sequence file" }
  input_unfiltered_vcf: { type: 'File', inputBinding: { position: 2, prefix: "--variant"}, doc: "A VCF file containing variants" }
  
  # Optional File Arguments
  input_contamination_table: { type: 'File?', inputBinding: { position: 2, prefix: "--contamination-table"}, doc: "Tables containing contamination information." }
  input_exclude_intervals_list: { type: 'File?', inputBinding: { position: 2, prefix: "--exclude-intervals"}, doc: "One or more genomic intervals to exclude from processing." }
  input_reads: { type: 'File?', inputBinding: { position: 2, prefix: "--input"}, doc: "BAM/SAM/CRAM file containing reads." }
  input_intervals_list: { type: 'File?', inputBinding: { position: 2, prefix: "--intervals"}, doc: "One or more genomic intervals over which to operate." }
  input_orientation_bias_artifact_priors: { type: 'File?', inputBinding: { position: 2, prefix: "--orientation-bias-artifact-priors"}, doc: "tar.gz files containing tables of prior artifact probabilities for the read orientation filter model, one table per tumor sample." }
  input_sequence_dictionary: { type: 'File?', inputBinding: { position: 2, prefix: "--sequence-dictionary"}, doc: "Use the given sequence dictionary as the master/canonical sequence dictionary. Must be a .dict file." }
  input_tumor_segmentation: { type: 'File?', inputBinding: { position: 2, prefix: "--tumor-segmentation"}, doc: "Tables containing tumor segments' minor allele fractions for germline hets emitted by CalculateContamination" }
  input_mutect_stats: { type: 'File?', inputBinding: { position: 2, prefix: "--stats"}, doc: "The Mutect stats file output by Mutect2" }

  # Custom Interval Arguments
  input_exclude_intervals:
    type:
      - 'null'
      - type: array
        items: string
        inputBinding:
          prefix: "--exclude-intervals"
    inputBinding:
      position: 3
    doc: |
      One or more genomic intervals to exclude from processing.
  input_intervals:
    type:
      - 'null'
      - type: array
        items: string
        inputBinding:
          prefix: "--intervals"
    inputBinding:
      position: 3
    doc: |
      One or more genomic intervals over which to operate.

  # Number Arguments
  contamination_estimate: { type: 'float?', inputBinding: { position: 2, prefix: "--contamination-estimate"}, doc: "Estimate of contamination." }
  f_score_beta: { type: 'float?', inputBinding: { position: 2, prefix: "--f-score-beta"}, doc: "F score beta, the relative weight of recall to precision, used if OPTIMAL_F_SCORE strategy is chosen" }
  false_discovery_rate: { type: 'float?', inputBinding: { position: 2, prefix: "--false-discovery-rate"}, doc: "Maximum false discovery rate allowed if FALSE_DISCOVERY_RATE threshold strategy is chosen" }
  initial_threshold: { type: 'float?', inputBinding: { position: 2, prefix: "--initial-threshold"}, doc: "Initial artifact probability threshold used in first iteration" }
  log_artifact_prior: { type: 'float?', inputBinding: { position: 2, prefix: "--log-artifact-prior"}, doc: "Initial ln prior probability that a called site is not a technical artifact" }
  log_indel_prior: { type: 'float?', inputBinding: { position: 2, prefix: "--log-indel-prior"}, doc: "Initial ln prior probability that a site has a somatic indel" }
  log_snv_prior: { type: 'float?', inputBinding: { position: 2, prefix: "--log-snv-prior"}, doc: "Initial ln prior probability that a site has a somatic SNV" }
  max_n_ratio: { type: 'float?', inputBinding: { position: 2, prefix: "--max-n-ratio"}, doc: "Maximum fraction of non-ref bases in the pileup that are N (unknown)" }
  min_allele_fraction: { type: 'float?', inputBinding: { position: 2, prefix: "--min-allele-fraction"}, doc: "Minimum allele fraction required" }
  normal_p_value_threshold: { type: 'float?', inputBinding: { position: 2, prefix: "--normal-p-value-threshold"}, doc: "P value threshold for normal artifact filter" }
  pcr_slippage_rate: { type: 'float?', inputBinding: { position: 2, prefix: "--pcr-slippage-rate"}, doc: "The frequency of polymerase slippage in contexts where it is suspected" }
  distance_on_haplotype: { type: 'int?', inputBinding: { position: 2, prefix: "--distance-on-haplotype"}, doc: "On second filtering pass, variants with same PGT and PID tags as a filtered variant within this distance are filtered." }
  interval_exclusion_padding: { type: 'int?', inputBinding: { position: 2, prefix: "--interval-exclusion-padding"}, doc: "Amount of padding (in bp) to add to each interval you are excluding." }
  interval_padding: { type: 'int?', inputBinding: { position: 2, prefix: "--interval-padding"}, doc: "Amount of padding (in bp) to add to each interval you are including." }
  long_indel_length: { type: 'int?', inputBinding: { position: 2, prefix: "--long-indel-length"}, doc: "Indels of this length or greater are treated specially by the mapping quality filter." }
  max_alt_allele_count: { type: 'int?', inputBinding: { position: 2, prefix: "--max-alt-allele-count"}, doc: "Maximum alt alleles per site." }
  max_events_in_region: { type: 'int?', inputBinding: { position: 2, prefix: "--max-events-in-region"}, doc: "Maximum events in a single assembly region. Filter all variants if exceeded." }
  max_median_fragment_length_difference: { type: 'int?', inputBinding: { position: 2, prefix: "--max-median-fragment-length-difference"}, doc: "Maximum difference between median alt and ref fragment lengths" }
  min_median_base_quality: { type: 'int?', inputBinding: { position: 2, prefix: "--min-median-base-quality"}, doc: "Minimum median base quality of alt reads" }
  min_median_mapping_quality: { type: 'int?', inputBinding: { position: 2, prefix: "--min-median-mapping-quality"}, doc: "Minimum median mapping quality of alt reads" }
  min_median_read_position: { type: 'int?', inputBinding: { position: 2, prefix: "--min-median-read-position"}, doc: "Minimum median distance of variants from the end of reads" }
  min_reads_per_strand: { type: 'int?', inputBinding: { position: 2, prefix: "--min-reads-per-strand"}, doc: "Minimum alt reads required on both forward and reverse strands" }
  min_slippage_length: { type: 'int?', inputBinding: { position: 2, prefix: "--min-slippage-length"}, doc: "Minimum number of reference bases in an STR to suspect polymerase slippage" }
  unique_alt_read_count: { type: 'int?', inputBinding: { position: 2, prefix: "--unique-alt-read-count"}, doc: "Minimum unique (i.e. deduplicated) reads supporting the alternate allele" }

  # String Array Arguments
  disable_read_filter:
    type:
      - 'null'
      - type: array
        items: string
        inputBinding:
          prefix: "--disable-read-filter"
    inputBinding:
      position: 3
    doc: |
      Read filters to be disabled before analysis This argument may be specified 0 or more times.
  read_filter:
    type:
      - 'null'
      - type: array
        items: string
        inputBinding:
          prefix: "--read-filter"
    inputBinding:
      position: 3
    doc: |
      Read filters to be applied before analysis. This argument may be specified 0 or more times.

  # Boolean Arguments
  add_output_sam_program_record: { type: 'boolean?', inputBinding: { position: 2, prefix: "--add-output-sam-program-record"}, doc: "If true, adds a PG tag to created SAM/BAM/CRAM files." }
  add_output_vcf_command_line: { type: 'boolean?', inputBinding: { position: 2, prefix: "--add-output-vcf-command-line"}, doc: "If true, adds a command line header line to created VCF files." }
  create_output_bam_index: { type: 'boolean?', inputBinding: { position: 2, prefix: "--create-output-bam-index"}, doc: "If true, create a BAM/CRAM index when writing a coordinate-sorted BAM/CRAM file." }
  create_output_bam_md5: { type: 'boolean?', inputBinding: { position: 2, prefix: "--create-output-bam-md5"}, doc: "If true, create a MD5 digest for any BAM/SAM/CRAM file created" }
  create_output_variant_index: { type: 'boolean?', inputBinding: { position: 2, prefix: "--create-output-variant-index"}, doc: "If true, create a VCF index when writing a coordinate-sorted VCF file." }
  create_output_variant_md5: { type: 'boolean?', inputBinding: { position: 2, prefix: "--create-output-variant-md5"}, doc: "If true, create a a MD5 digest any VCF file created." }
  disable_bam_index_caching: { type: 'boolean?', inputBinding: { position: 2, prefix: "--disable-bam-index-caching"}, doc: "If true, don't cache bam indexes, this will reduce memory requirements but may harm performance if many intervals are specified. Caching is automatically disabled if there are no intervals specified." }
  disable_sequence_dictionary_validation: { type: 'boolean?', inputBinding: { position: 2, prefix: "--disable-sequence-dictionary-validation"}, doc: "If specified, do not check the sequence dictionaries from our inputs for compatibility. Use at your own risk!" }
  lenient: { type: 'boolean?', inputBinding: { position: 2, prefix: "--lenient"}, doc: "Lenient processing of VCF files" }
  mitochondria_mode: { type: 'boolean?', inputBinding: { position: 2, prefix: "--mitochondria-mode"}, doc: "Set filters to mitochondrial defaults" }
  sites_only_vcf_output: { type: 'boolean?', inputBinding: { position: 2, prefix: "--sites-only-vcf-output"}, doc: "If true, don't emit genotype fields when writing vcf file output." }
  disable_tool_default_read_filters: { type: 'boolean?', inputBinding: { position: 2, prefix: "--disable-tool-default-read-filters"}, doc: "Disable all tool default read filters (WARNING: many tools will not function correctly without their default read filters on)" }

  # Enum Arguments
  interval_merging_rule:
    type:
      - 'null'
      - type: enum
        name: interval_merging_rule
        symbols: ["ALL","OVERLAPPING_ONLY"]
    inputBinding:
      position: 3
      prefix: "--interval-merging-rule"
    doc: |
      By default, the program merges abutting intervals (i.e. intervals that are
      directly side-by-side but do not actually overlap) into a single continuous
      interval. However you can change this behavior if you want them to be treated
      as separate intervals instead.
  interval_set_rule:
    type:
      - 'null'
      - type: enum
        name: interval_set_rule
        symbols: ["UNION","INTERSECTION"]
    inputBinding:
      position: 3
      prefix: "--interval-set-rule"
    doc: |
      By default, the program will take the UNION of all intervals specified using -L
      and/or -XL. However, you can change this setting for -L, for example if you
      want to take the INTERSECTION of the sets instead. E.g. to perform the analysis
      only on chromosome 1 exomes, you could specify -L exomes.intervals -L 1
      --interval-set-rule INTERSECTION. However, it is not possible to modify the
      merging approach for intervals passed using -XL (they will always be merged
      using UNION). Note that if you specify both -L and -XL, the -XL interval set
      will be subtracted from the -L interval set.
  read_validation_stringency:
    type:
      - 'null'
      - type: enum
        name: read_validation_stringency
        symbols: ["STRICT","LENIENT","SILENT"]
    inputBinding:
      position: 3
      prefix: "--read-validation-stringency"
    doc: |
      Validation stringency for all SAM/BAM/CRAM/SRA files read by this program. The
      default stringency value SILENT can improve performance when processing a BAM
      file in which variable-length data (read, qualities, tags) do not otherwise
      need to be decoded.
  threshold_strategy:
    type:
      - 'null'
      - type: enum
        name: threshold_strategy
        symbols: ["CONSTANT","FALSE_DISCOVERY_RATE","OPTIMAL_F_SCORE"]
    inputBinding:
      position: 3
      prefix: "--threshold-strategy"
    doc: |
      The method for optimizing the posterior probability threshold

  output_prefix:
    type: 'string?'
    doc: "String to use as the prefix for the outputs."
  max_memory:
    type: 'int?'
    default: 8
    doc: "Maximum GB of RAM to allocate for this tool."
  cpu:
    type: 'int?'
    default: 2
    doc: "Number of CPUs to allocate to this task."
outputs:
  stats_table:
    type: File
    outputBinding:
      glob: '*.mutect2.filtering.stats'
  filtered_vcf:
    type: File
    secondaryFiles: [{ pattern: '.tbi', required: true }]
    outputBinding:
      glob: '*.mutect2.filtered.vcf.gz'
      outputEval: |
        ${
          var outfile = self[0];
          if (!("metadata" in outfile)) { outfile.metadata = {} };
          outfile.metadata["toolname"] = "mutect2";
          return outfile;
        }
