cwlVersion: v1.2
class: CommandLineTool
id: octopus 
doc: |
  Octopus is a mapping-based variant caller that implements several calling
  models within a unified haplotype-aware framework. Octopus takes inspiration
  from particle filtering by constructing a tree of haplotypes and dynamically
  pruning and extending the tree based on haplotype posterior probabilities in a
  sequential manner. This allows octopus to implicitly consider all possible
  haplotypes at a given loci in reasonable time.
requirements:
  - class: InlineJavascriptRequirement
  - class: ShellCommandRequirement
  - class: ResourceRequirement
    ramMin: $(inputs.ram*1000)
    coresMin: $(inputs.cpu)
  - class: DockerRequirement
    dockerPull: 'pgc-images.sbgenomics.com/d3b-bixu/octopus:0.6.3-beta'
  - class: InitialWorkDirRequirement
    listing: [$(inputs.premade_cache)]
baseCommand: [octopus]
inputs:
  premade_cache: { type: 'Directory?', doc: "Premade cache of genome" }
  reference: { type: 'File', secondaryFiles: [{ pattern: '.fai', required: true }], inputBinding: { position: 2, prefix: "--reference"}, doc: "FASTA format reference genome file to be analysed. Target regions will be extracted from the reference index if not provded explicitly" }
  reads: { type: 'File[]?', secondaryFiles: [{ pattern: '.bai', required: false }, { pattern: '^.bai', required: false }, { pattern: '.crai', required: false }, { pattern: '^.crai', required: false }], inputBinding: { position: 2, prefix: "--reads"}, doc: "Space-separated list of BAM/CRAM files to be analysed. May be specified multiple times" }
  reads_file: { type: 'File?', inputBinding: { position: 2, prefix: "--reads-file"}, doc: "Files containing lists of BAM/CRAM files, one per line, to be analysed" }
  output_vcf_filename: { type: 'string', inputBinding: { position: 2, prefix: "--output"}, doc: "string to where output is written. If unspecified, calls are written to stdout" }
  output_sam_dirname: { type: 'string?', inputBinding: { position: 2, prefix: "--bamout"}, doc: "Name for output directory containing SAM files" }
  output_data_profile_filename: { type: 'string?', inputBinding: { position: 2, prefix: "--data-profile"}, doc: "Output a profile of polymorphisms and errors found in the data" }

  # Backend Arguments
  fast: { type: 'boolean?', inputBinding: { position: 2, prefix: "--fast"}, doc: "Turns off some features to improve runtime, at the cost of decreased calling accuracy. Equivalent to '-a off -l minimal -x 50`" }
  very_fast: { type: 'boolean?', inputBinding: { position: 2, prefix: "--very-fast"}, doc: "The same as fast but also disables inactive flank scoring" }
  max_reference_cache_footprint: { type: 'string?', inputBinding: { position: 2, prefix: "--max-reference-cache-footprint"}, doc: "Maximum memory footprint for cached reference sequence" }
  target_read_buffer_footprint: { type: 'string?', inputBinding: { position: 2, prefix: "--target-read-buffer-footprint"}, doc: "None binding request to limit the memory footprint of buffered read data" }
  max_open_read_files: { type: 'int?', inputBinding: { position: 2, prefix: "--max-open-read-files"}, doc: "Limits the number of read files that can be open simultaneously" }
#  target_working_memory: { type: 'string?', inputBinding: { position: 2, prefix: "--target-working-memory"}, doc: "Target working memory footprint for analysis not including read or reference footprint" }

  # Input/Output Arguments
  one_based_indexing: { type: 'boolean?', inputBinding: { position: 2, prefix: "--one-based-indexing"}, doc: "Notifies that input regions are given using one based indexing rather than zero based" }
  regions: { type: 'string[]?', inputBinding: { position: 2, prefix: "--regions"}, doc: "Space-separated list of regions (chrom:begin-end) to be analysed. May be specified multiple times" }
  regions_file: { type: 'File?', inputBinding: { position: 2, prefix: "--regions-file"}, doc: "File? containing a list of regions (chrom:begin-end), one per line, to be analysed" }
  skip_regions: { type: 'string[]?', inputBinding: { position: 2, prefix: "--skip-regions"}, doc: "Space-separated list of regions (chrom:begin-end) to skip May be specified multiple times" }
  skip_regions_file: { type: 'File?', inputBinding: { position: 2, prefix: "--skip-regions-file"}, doc: "File? of regions (chrom:begin-end), one per line, to skip" }
  samples: { type: 'string[]?', inputBinding: { position: 2, prefix: "--samples"}, doc: "Space-separated list of sample names to analyse" }
  samples_file: { type: 'File?', inputBinding: { position: 2, prefix: "--samples-file"}, doc: "File? of sample names to analyse, one per line, which must be a subset of the samples that appear in the read files" }
  ignore_unmapped_contigs: { type: 'boolean?', inputBinding: { position: 2, prefix: "--ignore-unmapped-contigs"}, doc: "Ignore any contigs that are not present in the read files" }
  pedigree: { type: 'File?', inputBinding: { position: 2, prefix: "--pedigree"}, doc: "PED file containing sample pedigree" }
  contig_output_order: { type: 'string?', inputBinding: { position: 2, prefix: "--contig-output-order"}, doc: "The order contigs should be written to the output" }
  sites_only: { type: 'boolean?', inputBinding: { position: 2, prefix: "--sites-only"}, doc: "Only reports call sites (i.e. without sample genotype information)" }
  legacy: { type: 'boolean?', inputBinding: { position: 2, prefix: "--legacy"}, doc: "Outputs a legacy version of the final callset in addition to the native version" }
  regenotype: { type: 'File?', inputBinding: { position: 2, prefix: "--regenotype"}, doc: "VCF file specifying calls to regenotype, only sites in this files will appear in the final output" }
  full_bamout: { type: 'boolean?', inputBinding: { position: 2, prefix: "--full-bamout"}, doc: "Output all reads when producing realigned bam outputs rather than just variant read minibams" }

  # Read Transformations Arguments
  read_transforms:
    type:
      - 'null'
      - type: enum
        name: read_transforms
        symbols: ["0","1"]
    inputBinding:
      prefix: "--read-transforms"
    doc: |
      Enable all read transformations
  mask_low_quality_tails: { type: 'int?', inputBinding: { position: 2, prefix: "--mask-low-quality-tails"}, doc: "Masks read tail bases with base quality less than this" }
  mask_tails: { type: 'int?', inputBinding: { position: 2, prefix: "--mask-tails"}, doc: "Unconditionally mask this many read tail sbases" }
  soft_clip_masking:
    type:
      - 'null'
      - type: enum
        name: soft_clip_masking
        symbols: ["0","1"]
    inputBinding:
      prefix: "--soft-clip-masking"
    doc: |
      Turn on or off soft clip base recalibration
  soft_clip_mask_threshold: { type: 'int?', inputBinding: { position: 2, prefix: "--soft-clip-mask-threshold"}, doc: "Only soft clipped bases with quality less than this will be recalibrated, rather than all bases" }
  mask_soft_clipped_boundary_bases: { type: 'int?', inputBinding: { position: 2, prefix: "--mask-soft-clipped-boundary-bases"}, doc: "Masks this number of adjacent non soft clipped bases when soft clipped bases are present" }
  adapter_masking:
    type:
      - 'null'
      - type: enum
        name: adapter_masking
        symbols: ["0","1"]
    inputBinding:
      prefix: "--adapter-masking"
    doc: |
      Enable adapter detection and masking
  overlap_masking:
    type:
      - 'null'
      - type: enum
        name: overlap_masking
        symbols: ["0","1"]
    inputBinding:
      prefix: "--overlap-masking"
    doc: |
      Enable read segment overlap masking
  mask_inverted_soft_clipping:
    type:
      - 'null'
      - type: enum
        name: mask_inverted_soft_clipping
        symbols: ["0","1"]
    inputBinding:
      prefix: "--mask-inverted-soft-clipping"
    doc: |
      Mask soft clipped sequence that is an inverted copy of a proximate sequence
  mask_3prime_shifted_soft_clipped_heads:
    type:
      - 'null'
      - type: enum
        name: mask_3prime_shifted_soft_clipped_heads
        symbols: ["0","1"]
    inputBinding:
      prefix: "--mask-3prime-shifted-soft-clipped-heads"
    doc: |
      Mask soft clipped read head sequence that is a copy of a proximate 3' sequence

  # Read Filtering Arguments
  read_filtering:
    type:
      - 'null'
      - type: enum
        name: read_filtering 
        symbols: ["0","1"]
    inputBinding:
      prefix: "--read-filtering"
    doc: |
      Enable all read filters
  consider_unmapped_reads: { type: 'boolean?', inputBinding: { position: 2, prefix: "--consider-unmapped-reads"}, doc: "Allows reads marked as unmapped to be used for calling" }
  min_mapping_quality: { type: 'int?', inputBinding: { position: 2, prefix: "--min-mapping-quality"}, doc: "Minimum read mapping quality required to consider a read for calling" }
  good_base_quality: { type: 'int?', inputBinding: { position: 2, prefix: "--good-base-quality"}, doc: "Base quality threshold used by min-good-bases and min-good-base-fraction filters" }
  min_good_base_fraction: { type: 'float?', inputBinding: { position: 2, prefix: "--min-good-base-fraction"}, doc: "Base quality threshold used by min-good-bases filter" }
  min_good_bases: { type: 'int?', inputBinding: { position: 2, prefix: "--min-good-bases"}, doc: "Minimum number of bases with quality min-base-quality before read is considered" }
  allow_qc_fails: { type: 'boolean?', inputBinding: { position: 2, prefix: "--allow-qc-fails"}, doc: "Filters reads marked as QC failed" }
  min_read_length: { type: 'int?', inputBinding: { position: 2, prefix: "--min-read-length"}, doc: "Filters reads shorter than this" }
  max_read_length: { type: 'int?', inputBinding: { position: 2, prefix: "--max-read-length"}, doc: "Filter reads longer than this" }
  allow_marked_duplicates: { type: 'boolean?', inputBinding: { position: 2, prefix: "--allow-marked-duplicates"}, doc: "Allows reads marked as duplicate in alignment record" }
  allow_octopus_duplicates: { type: 'boolean?', inputBinding: { position: 2, prefix: "--allow-octopus-duplicates"}, doc: "Allows reads considered duplicates by octopus" }
  allow_secondary_alignments: { type: 'boolean?', inputBinding: { position: 2, prefix: "--allow-secondary-alignments"}, doc: "Allows reads marked as secondary alignments" }
  allow_supplementary_alignments: { type: 'boolean?', inputBinding: { position: 2, prefix: "--allow-supplementary-alignments"}, doc: "Allows reads marked as supplementary alignments" }
  no_reads_with_unmapped_segments: { type: 'boolean?', inputBinding: { position: 2, prefix: "--no-reads-with-unmapped-segments"}, doc: "Filter reads with unmapped template segments to be used for calling" }
  no_reads_with_distant_segments: { type: 'boolean?', inputBinding: { position: 2, prefix: "--no-reads-with-distant-segments"}, doc: "Filter reads with template segments that are on different contigs" }
  no_adapter_contaminated_reads: { type: 'boolean?', inputBinding: { position: 2, prefix: "--no-adapter-contaminated-reads"}, doc: "Filter reads with possible adapter contamination" }
  disable_downsampling: { type: 'boolean?', inputBinding: { position: 2, prefix: "--disable-downsampling"}, doc: "Disables downsampling" }
  downsample_above: { type: 'int?', inputBinding: { position: 2, prefix: "--downsample-above"}, doc: "Downsample reads in regions where coverage is over this" }
  downsample_target: { type: 'int?', inputBinding: { position: 2, prefix: "--downsample-target"}, doc: "The target coverage for the downsampler" }

  # Candidate Variant Generation Arguments
  raw_cigar_candidate_generator:
    type:
      - 'null'
      - type: enum
        name: raw_cigar_candidate_generator
        symbols: ["0","1"]
    inputBinding:
      prefix: "--raw-cigar-candidate-generator"
    doc: |
      Enable candidate generation from raw read alignments (CIGAR strings)
  repeat_candidate_generator:
    type:
      - 'null'
      - type: enum
        name: repeat_candidate_generator
        symbols: ["0","1"]
    inputBinding:
      prefix: "--repeat-candidate-generator"
    doc: |
      Enable candidate generation from adjusted read alignments (CIGAR strings) around tandem repeats
  assembly_candidate_generator:
    type:
      - 'null'
      - type: enum
        name: assembly_candidate_generator
        symbols: ["0","1"]
    inputBinding:
      prefix: "--assembly-candidate-generator"
    doc: |
      Enable candidate generation using local re-assembly
  source_candidates: { type: 'File[]?', inputBinding: { position: 2, prefix: "--source-candidates"}, doc: "Variant file paths containing known variants. These variants will automatically become candidates" }
  source_candidates_file: { type: 'File?', inputBinding: { position: 2, prefix: "--source-candidates-file"}, doc: "File?s containing lists of source candidate variant files" }
  min_source_quality: { type: 'float?', inputBinding: { position: 2, prefix: "--min-source-quality"}, doc: "Only variants with quality above this value are considered for candidate generation" }
  use_filtered_source_candidates:
    type:
      - 'null'
      - type: enum
        name: use_filtered_source_candidates
        symbols: ["0","1"]
    inputBinding:
      prefix: "--use-filtered-source-candidates"
    doc: |
      Use variants from source VCF records that have been filtered
  min_base_quality: { type: 'int?', inputBinding: { position: 2, prefix: "--min-base-quality"}, doc: "Only bases with quality above this value are considered for candidate generation" }
  min_supporting_reads: { type: 'int?', inputBinding: { position: 2, prefix: "--min-supporting-reads"}, doc: "Minimum number of reads that must support a variant if it is to be considered a candidate. By default octopus will automatically determine this value" }
  max_variant_size: { type: 'int?', inputBinding: { position: 2, prefix: "--max-variant-size"}, doc: "Maximum candidate variant size to consider (in region space)" }
  kmer_sizes: { type: 'int[]?', inputBinding: { position: 2, prefix: "--kmer-sizes"}, doc: "Kmer sizes to use for local assembly" }
  num_fallback_kmers: { type: 'int?', inputBinding: { position: 2, prefix: "--num-fallback-kmers"}, doc: "How many local assembly fallback kmer sizes to use if the default sizes fail" }
  fallback_kmer_gap: { type: 'int?', inputBinding: { position: 2, prefix: "--fallback-kmer-gap"}, doc: "The gap size used to generate local assembly fallback kmers" }
  max_region_to_assemble: { type: 'int?', inputBinding: { position: 2, prefix: "--max-region-to-assemble"}, doc: "The maximum region size that can be used for local assembly" }
  max_assemble_region_overlap: { type: 'int?', inputBinding: { position: 2, prefix: "--max-assemble-region-overlap"}, doc: "The maximum number of bases allowed to overlap assembly regions" }
  assemble_all: { type: 'boolean?', inputBinding: { position: 2, prefix: "--assemble-all"}, doc: "Forces all regions to be assembled" }
  assembler_mask_base_quality: { type: 'int?', inputBinding: { position: 2, prefix: "--assembler-mask-base-quality"}, doc: "Aligned bases with quality less than this will be converted to reference before being inserted into the De Bruijn graph" }
  min_kmer_prune: { type: 'int?', inputBinding: { position: 2, prefix: "--min-kmer-prune"}, doc: "Minimum number of read observations to keep a kmer in the assembly graph before bubble extraction" }
  max_bubbles: { type: 'int?', inputBinding: { position: 2, prefix: "--max-bubbles"}, doc: "Maximum number of bubbles to extract from the assembly graph" }
  min_bubble_score: { type: 'float?', inputBinding: { position: 2, prefix: "--min-bubble-score"}, doc: "Minimum bubble score that will be extracted from the assembly graph" }

  # Haplotype Generation Arguments
  max_haplotypes: { type: 'int?', inputBinding: { position: 2, prefix: "--max-haplotypes"}, doc: "Maximum number of candidate haplotypes the caller may consider. If a region contains more candidate haplotypes than this then filtering is applied" }
  haplotype_holdout_threshold: { type: 'int?', inputBinding: { position: 2, prefix: "--haplotype-holdout-threshold"}, doc: "Forces the haplotype generator to temporarily hold out some alleles if the number of haplotypes in a region exceeds this threshold" }
  haplotype_overflow: { type: 'int?', inputBinding: { position: 2, prefix: "--haplotype-overflow"}, doc: "Regions with more haplotypes than this will be skipped" }
  max_holdout_depth: { type: 'int?', inputBinding: { position: 2, prefix: "--max-holdout-depth"}, doc: "Maximum number of holdout attempts the haplotype generator can make before the region is skipped" }
  extension_level:
    type:
      - 'null'
      - type: enum
        name: extension_level 
        symbols: ["conservative", "normal", "optimistic", "aggressive"]
    inputBinding:
      prefix: "--extension-level"
      position: 2
    doc: |
      Level of haplotype extension. Possible values are: conservative, normal, optimistic, aggressive
  haplotype_extension_threshold: { type: 'float?', inputBinding: { position: 2, prefix: "--haplotype-extension-threshold"}, doc: "Haplotypes with posterior probability less than this can be filtered before extension" }
  dedup_haplotypes_with_prior_model:
    type:
      - 'null'
      - type: enum
        name: dedup_haplotypes_with_prior_model
        symbols: ["0","1"]
    inputBinding:
      prefix: "--dedup-haplotypes-with-prior-model"
    doc: |
      Remove duplicate haplotypes using mutation prior model
  protect_reference_haplotype:
    type:
      - 'null'
      - type: enum
        name: protect_reference_haplotype
        symbols: ["0","1"]
    inputBinding:
      prefix: "--protect-reference-haplotype"
    doc: |
      Protect the reference haplotype from filtering

  # Calling Arguments
  caller:
    type:
      - 'null'
      - type: enum
        name: caller
        symbols: ["cancer", "cell", "polyclone", "population", "trio"]
    inputBinding:
      prefix: "--caller"
      position: 2
    doc: |
      Which of the octopus callers to use
  organism_ploidy: { type: 'int?', inputBinding: { position: 2, prefix: "--organism-ploidy"}, doc: "All contigs with unspecified ploidies are assumed the organism ploidy" }
  contig_ploidies: { type: 'string[]?', inputBinding: { position: 2, prefix: "--contig-ploidies"}, doc: "Space-separated list of contig (contig=ploidy) or sample contig (sample:contig=ploidy) ploidies" }
  contig_ploidies_file: { type: 'File?', inputBinding: { position: 2, prefix: "--contig-ploidies-file"}, doc: "File? containing a list of contig (contig=ploidy) or sample contig (sample:contig=ploidy) ploidies, one per line" }
  min_variant_posterior: { type: 'float?', inputBinding: { position: 2, prefix: "--min-variant-posterior"}, doc: "Report variant alleles with posterior probability (phred scale) greater than this" }
  refcall:
    type:
      - 'null'
      - type: enum
        name: refcall
        symbols: ["positional", "blocked"]
    inputBinding:
      prefix: "--refcall"
      position: 2
    doc: |
      Caller will report reference confidence calls for each position (positional), or in automatically sized blocks (blocked)
  refcall_block_merge_threshold: { type: 'float?', inputBinding: { position: 2, prefix: "--refcall-block-merge-threshold"}, doc: "Threshold to merge adjacent refcall positions when using blocked refcalling" }
  min_refcall_posterior: { type: 'float?', inputBinding: { position: 2, prefix: "--min-refcall-posterior"}, doc: "Report reference alleles with posterior probability (phred scale) greater than this" }
  snp_heterozygosity: { type: 'float?', inputBinding: { position: 2, prefix: "--snp-heterozygosity"}, doc: "Germline SNP heterozygosity for the given samples" }
  snp_heterozygosity_stdev: { type: 'float?', inputBinding: { position: 2, prefix: "--snp-heterozygosity-stdev"}, doc: "Standard deviation of the germline SNP heterozygosity used for the given samples" }
  indel_heterozygosity: { type: 'float?', inputBinding: { position: 2, prefix: "--indel-heterozygosity"}, doc: "Germline indel heterozygosity for the given samples" }
  use_uniform_genotype_priors: { type: 'boolean?', inputBinding: { position: 2, prefix: "--use-uniform-genotype-priors"}, doc: "Use a uniform prior model when calculating genotype posteriors" }
  max_genotypes: { type: 'int?', inputBinding: { position: 2, prefix: "--max-genotypes"}, doc: "The maximum number of genotypes to evaluate" }
  max_joint_genotypes: { type: 'int?', inputBinding: { position: 2, prefix: "--max-joint-genotypes"}, doc: "The maximum number of joint genotype vectors to consider when computing joint genotype posterior probabilities" }
  use_independent_genotype_priors: { type: 'boolean?', inputBinding: { position: 2, prefix: "--use-independent-genotype-priors"}, doc: "Use independent genotype priors for joint calling" }
  model_posterior:
    type:
      - 'null'
      - type: enum
        name: model_posterior
        symbols: ["0","1"]
    inputBinding:
      prefix: "--model-posterior"
    doc: |
      Calculate model posteriors for every call
  inactive_flank_scoring:
    type:
      - 'null'
      - type: enum
        name: inactive_flank_scoring 
        symbols: ["0","1"]
    inputBinding:
      prefix: "--inactive-flank-scoring"
    doc: |
      Disables additional calculation to adjust alignment score when there are inactive candidates in haplotype flanking regions.
  model_mapping_quality:
    type:
      - 'null'
      - type: enum
        name: model_mapping_quality 
        symbols: ["0","1"]
    inputBinding:
      prefix: "--model-mapping-quality"
    doc: |
      Include the read mapping quality in the haplotype likelihood calculation 
  sequence_error_model: { type: 'string?', inputBinding: { position: 2, prefix: "--sequence-error-model"}, doc: "The sequencer error model to use" }
  max_vb_seeds: { type: 'int?', inputBinding: { position: 2, prefix: "--max-vb-seeds"}, doc: "Maximum number of seeds to use for Variational Bayes algorithms" }

  # Calling Cancer Arguments
  normal_sample: { type: 'string?', inputBinding: { position: 2, prefix: "--normal-sample"}, doc: "Normal sample - all other samples are considered tumour" }
  max_somatic_haplotypes: { type: 'int?', inputBinding: { position: 2, prefix: "--max-somatic-haplotypes"}, doc: "Maximum number of somatic haplotypes that may be considered" }
  somatic_snv_mutation_rate: { type: 'float?', inputBinding: { position: 2, prefix: "--somatic-snv-mutation-rate"}, doc: "Expected SNV somatic mutation rate, per megabase pair, for this sample" }
  somatic_indel_mutation_rate: { type: 'float?', inputBinding: { position: 2, prefix: "--somatic-indel-mutation-rate"}, doc: "Expected INDEL somatic mutation rate, per megabase pair, for this sample" }
  min_expected_somatic_frequency: { type: 'float?', inputBinding: { position: 2, prefix: "--min-expected-somatic-frequency"}, doc: "Minimum expected somatic allele frequency in the sample" }
  min_credible_somatic_frequency: { type: 'float?', inputBinding: { position: 2, prefix: "--min-credible-somatic-frequency"}, doc: "Minimum credible somatic allele frequency that will be reported" }
  tumour_germline_concentration: { type: 'float?', inputBinding: { position: 2, prefix: "--tumour-germline-concentration"}, doc: "Concentration parameter for germline haplotypes in tumour samples" }
  credible_mass: { type: 'float?', inputBinding: { position: 2, prefix: "--credible-mass"}, doc: "Mass of the posterior density to use for evaluating allele frequencies" }
  min_somatic_posterior: { type: 'float?', inputBinding: { position: 2, prefix: "--min-somatic-posterior"}, doc: "Minimum posterior probability (phred scale) to emit a somatic mutation call" }
  normal_contamination_risk:
    type:
      - 'null'
      - type: enum
        name: normal_contamination_risk
        symbols: ["low", "high"]
    inputBinding:
      prefix: "--normal-contamination-risk"
    doc: |
      The risk the normal sample has contamination from the tumour
  somatics_only: { type: 'boolean?', inputBinding: { position: 2, prefix: "--somatics-only"}, doc: "Only emit SOMATIC mutations" }

  # Calling Cell Arguments
  max_phylogeny_size: { type: 'int?', inputBinding: { position: 2, prefix: "--max-phylogeny-size"}, doc: "Maximum number of nodes in cell phylogeny to consider" }
  dropout_concentration: { type: 'float?', inputBinding: { position: 2, prefix: "--dropout-concentration"}, doc: "Allelic dropout concentration paramater" }

  # Calling Polyclone Arguments
  max_clones: { type: 'int?', inputBinding: { position: 2, prefix: "--max-clones"}, doc: "Maximum number of unique clones to consider" }
  min_clone_frequency: { type: 'float?', inputBinding: { position: 2, prefix: "--min-clone-frequency"}, doc: "Minimum expected clone frequency in the sample" }

  # Calling Trio Arguments
  maternal_sample: { type: 'string?', inputBinding: { position: 2, prefix: "--maternal-sample"}, doc: "Maternal sample" }
  paternal_sample: { type: 'string?', inputBinding: { position: 2, prefix: "--paternal-sample"}, doc: "Paternal sample" }
  denovo_snv_mutation_rate: { type: 'float?', inputBinding: { position: 2, prefix: "--denovo-snv-mutation-rate"}, doc: "SNV de novo mutation rate, per base per generation" }
  denovo_indel_mutation_rate: { type: 'float?', inputBinding: { position: 2, prefix: "--denovo-indel-mutation-rate"}, doc: "INDEL de novo mutation rate, per base per generation" }
  min_denovo_posterior: { type: 'float?', inputBinding: { position: 2, prefix: "--min-denovo-posterior"}, doc: "Minimum posterior probability (phred scale) to emit a de novo mutation call" }
  denovos_only: { type: 'boolean?', inputBinding: { position: 2, prefix: "--denovos-only"}, doc: "Only emit DENOVO mutations" }

  # Phasing Arguments
  phasing_level:
    type:
      - 'null'
      - type: enum
        name: phasing_level 
        symbols: ["minimal", "conservative", "moderate", "normal", "aggressive"]
    inputBinding:
      prefix: "--phasing-level"
    doc: |
      Level of phasing - longer range phasing can improve calling accuracy at the cost of runtime speed. Possible values are: minimal, conservative, moderate, normal, aggressive.
  min_phase_score: { type: 'float?', inputBinding: { position: 2, prefix: "--min-phase-score"}, doc: "Minimum phase score (phred scale) required to report sites as phased" }

  # Variant Filtering Arguments
  call_filtering:
    type:
      - 'null'
      - type: enum
        name: call_filtering 
        symbols: ["0","1"]
    inputBinding:
      prefix: "--call-filtering"
    doc: |
      Turn variant call filtering on or off
  filter_expression: { type: 'string?', inputBinding: { position: 2, prefix: "--filter-expression"}, doc: "Boolean expression to use to filter variant calls" }
  somatic_filter_expression: { type: 'string?', inputBinding: { position: 2, prefix: "--somatic-filter-expression"}, doc: "Boolean expression to use to filter somatic variant calls" }
  denovo_filter_expression: { type: 'string?', inputBinding: { position: 2, prefix: "--denovo-filter-expression"}, doc: "Boolean expression to use to filter somatic variant calls" }
  refcall_filter_expression: { type: 'string?', inputBinding: { position: 2, prefix: "--refcall-filter-expression"}, doc: "Boolean expression to use to filter homozygous reference calls" }
  use_calling_reads_for_filtering:
    type:
      - 'null'
      - type: enum
        name: use_calling_reads_for_filtering 
        symbols: ["0","1"]
    inputBinding:
      prefix: "--use-calling-reads-for-filtering"
    doc: |
      Use the original reads used for variant calling for filtering
  keep_unfiltered_calls: { type: 'boolean?', inputBinding: { position: 2, prefix: "--keep-unfiltered-calls"}, doc: "Keep a copy of unfiltered calls" }
  annotations: { type: 'string[]?', inputBinding: { position: 2, prefix: "--annotations"}, doc: "Annotations to write to final VCF" }
  filter_vcf: { type: 'File?', inputBinding: { position: 2, prefix: "--filter-vcf"}, doc: "Filter the given Octopus VCF without calling" }
  forest_file: { type: 'File?', inputBinding: { position: 2, prefix: "--forest-file"}, doc: "Trained Ranger random forest file" }
  somatic_forest_file: { type: 'File?', inputBinding: { position: 2, prefix: "--somatic-forest-file"}, doc: "Trained Ranger random forest file for somatic variants" }

  cpu:
    type: 'int?'
    default: 4
    doc: "Number of CPUs to allocate to this task."
    inputBinding:
      position: 2
      prefix: "--threads"
  ram:
    type: 'int?'
    default: 8
    doc: "GB size of RAM to allocate to this task."
    inputBinding:
      position: 2
      prefix: "--target-working-memory"
      valueFrom: $(self)G
outputs:
  debug_log:
    type: 'File'
    outputBinding:
      glob: "octopus_debug.log"
  trace_log:
    type: 'File'
    outputBinding:
      glob: "octopus_trace.log"
  vcf:
    type: 'File'
    outputBinding:
      glob: $(inputs.output_vcf_filename)
  legacy_vcf:
    type: 'File?'
    outputBinding:
      glob: '*.legacy.vcf'
  bam:
    type: 'Directory?'
    outputBinding:
      glob: $(inputs.output_sam_dirname)
  data_profile:
    type: 'File?'
    outputBinding:
      glob: $(inputs.output_data_profile_filename)
  cache:
    type: 'Directory?'
    outputBinding:
      glob: ".cache"
