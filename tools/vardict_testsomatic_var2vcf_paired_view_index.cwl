cwlVersion: v1.2
class: CommandLineTool
id: vardict_testsomatic_var2vcf_paired_view_index 
doc: |
  Runs Vardict, testsomatic.R, var2vcf_paired.pl, bcftools view, and optionally index
requirements:
  - class: InlineJavascriptRequirement
  - class: ShellCommandRequirement
  - class: ResourceRequirement
    ramMin: $(inputs.ram*1000)
    coresMin: $(inputs.cpu)
  - class: DockerRequirement
    dockerPull: 'dmiller15/vardictjava:1.7.0'
baseCommand: []
arguments:
  - position: 0
    shellQuote: false
    valueFrom: >
      JAVAOPTS="-Xmx${return Math.floor(inputs.ram*1000/1.074-1)}m" VarDict
  - position: 10
    shellQuote: false
    valueFrom: >
      | testsomatic.R
  - position: 20
    shellQuote: false
    valueFrom: >
      | var2vcf_paired.pl
  - position: 30
    shellQuote: false
    valueFrom: >
      | bcftools view --threads $(inputs.cpu)
  - position: 90
    shellQuote: false
    valueFrom: >
      $(inputs.output_type == "b" || inputs.output_type == "z" ? "&& bcftools index --threads " + inputs.cpu : "")

inputs:
  # Required Arguments
  input_bam_file: { type: 'File', secondaryFiles: [{ pattern: '.bai', required: true }], inputBinding: { position: 2, prefix: '-b' }, doc: "Indexed BAM File" }
  indexed_reference_fasta: { type: 'File', secondaryFiles: [{ pattern: '.fai', required: true }], inputBinding: { position: 2, prefix: '-G' }, doc: "The reference fasta. Should be indexed (.fai)." }
  output_filename: { type: 'string', inputBinding: { position: 32, prefix: "--output-file"}, doc: "output file name" } 

  # VarDict Arguments
  indel_3_prime: { type: 'boolean?', inputBinding: { position: 2, prefix: '-3' }, doc: "Indicate to move indels to 3-prime if alternative alignment can be achieved." }
  std: { type: 'int?', inputBinding: { position: 2, prefix: '-A' }, doc: "The number of STD. A pair will be considered for DEL if INSERT > INSERT_SIZE + INSERT_STD_AMT * INSERT_STD. Default: 4" }
  amplicon: { type: 'string?', inputBinding: { position: 2, prefix: '--amplicon' }, doc: "Indicate it's amplicon based calling. Reads that don't map to the amplicon will be skipped.  A read pair is considered belonging to the amplicon if the edges are less than int bp to the amplicon, and overlap fraction is at least float. Default: 10:0.95" }
  adaptor: { type: 'string?', inputBinding: { position: 2, prefix: '-adaptor' }, doc: "Filter adaptor sequences so that they are not used in realignment. Multiple adaptors can be supplied by setting them with comma, like: --adaptor ACGTTGCTC,ACGGGGTCTC,ACGCGGCTAG"}
  bias_min_reads: { type: 'int?', inputBinding: { position: 2, prefix: '-B' }, doc: "The minimum # of reads to determine strand bias, default 2"}
  chimeric: { type: 'boolean?', inputBinding: { position: 2, prefix: '-chimeric' }, doc: "Indicate to turn off chimeric reads filtering." } 
  debug: { type: 'boolean?', inputBinding: { position: 2, prefix: '--debug' }, doc: "Debug mode. Will print some error messages and append full genotype at the end." }
  delimiter: { type: 'string?', inputBinding: { position: 2, prefix: '-d' }, doc: "The delimiter for split region_info, default to tab" }
  deldupvar: { type: 'boolean?', inputBinding: { position: 2, prefix: '-deldupvar' }, doc: "Turn on deleting of duplicate variants. Variants in this mode are considered and outputted only if start position of variant is inside the region interest." }
  hexical_read_filter: { type: 'string?', inputBinding: { position: 2, prefix: '-F' }, doc: "The hexical to filter reads using samtools. Default: 0x504 (filter 2nd alignments, unmapped reads and duplicates). Use -F 0 to turn it off." }
  allele_frequency_max: { type: 'float?', inputBinding: { position: 2, prefix: '-f' }, doc: "The threshold for allele frequency, default: 0.01 or 1%" }
  header: { type: 'boolean?', inputBinding: { position: 2, prefix: '--header' }, doc: "Print a header row describing columns" } 
  indel_size: { type: 'int?', inputBinding: { position: 2, prefix: '-I' }, doc: "The indel size. Default: 50" }
  splice: { type: 'boolean?', inputBinding: { position: 2, prefix: '--splice' }, doc: "Output splicing read counts" }
  crispr_cutting_site: { type: 'string?', inputBinding: { position: 2, prefix: '--crispr' }, doc: "The genomic position that CRISPR/Cas9 suppose to cut, typically 3bp from the PAM NGG site and within the guide. For CRISPR mode only. It will adjust the variants (mostly In-Del) start and end sites to as close to this location as possible, if there are alternatives. The option should only be used for CRISPR mode." }
  crispr_filtering_bp: { type: 'string?', inputBinding: { position: 2, prefix: '-j' }, doc: "In CRISPR mode, the minimum amount in bp that a read needs to overlap with cutting site. If a read does not meet the criteria, it will not be used for variant calling, since it is likely just a partially amplified PCR. Default: not set, or no filtering" }
  n_depth: { type: 'boolean?', inputBinding: { position: 2, prefix: '-K' }, doc: "Include Ns in the total depth calculation" } 
  local_realignment:
    type:
      - 'null'
      - type: enum
        name: local_realignment
        symbols: ["0","1"]
    inputBinding:
      prefix: "-k"
    doc: |
      Indicate whether to perform local realignment. Default: 1. Set to 0 to disable it. For Ion or PacBio, 0 is recommended.
  sv_length_min: { type: 'int?', inputBinding: { position: 2, prefix: '-L' }, doc: "The minimum structural variant length to be presented using <DEL> <DUP> <INV> <INS>, etc. Default: 1000. Any indel, complex variants less than this will be spelled out with exact nucleotides." }
  read_match_min: { type: 'int?', inputBinding: { position: 2, prefix: '-M' }, doc: "The minimum matches for a read to be considered. If, after soft-clipping, the matched bp is less than INT, then the read is discarded. It's meant for PCR based targeted sequencing where there's no insert and the matching is only the primers. Default: 0, or no filtering" }
  read_mismatch_max: { type: 'int?', inputBinding: { position: 2, prefix: '-m' }, doc: "If set, reads with mismatches more than INT will be filtered and ignored. Gaps are not counted as mismatches. Valid only for bowtie2/TopHat or BWA aln followed by sampe. BWA mem is calculated as NM - Indels. Default: 8, or reads with more than 8 mismatches will not be used." }
  monomer_frequency_min: { type: 'float?', inputBinding: { position: 2, prefix: '-mfreq' }, doc: "The variant frequency threshold to determine variant as good in case of monomer MSI. Default: 0.25" }
  nonmonomer_frequency_min: { type: 'float?', inputBinding: { position: 2, prefix: '-nmfreq' }, doc: "The variant frequency threshold to determine variant as good in case of non-monomer MSI. Default: 0.1" }
  sample_name: { type: 'string?', inputBinding: { position: 2, prefix: '-N' }, doc: "The sample name to be used directly. Will overwrite -n (sample_name_regex) option" }
  sample_name_regex: { type: 'string?', inputBinding: { position: 2, prefix: '-n' }, doc: "The regular expression to extract sample name from BAM filenames." }
  read_mean_mapq_min: { type: 'string?', inputBinding: { position: 2, prefix: '-O' }, doc: "The reads should have at least mean MapQ to be considered a valid variant. Default: no filtering" }
  read_mapq_min: { type: 'int?', inputBinding: { position: 2, prefix: '-Q' }, doc: "If set, reads with mapping quality less than INT will be filtered and ignored" }
  qratio: { type: 'float?', inputBinding: { position: 2, prefix: '-o' }, doc: "The Qratio of (good_quality_reads)/(bad_quality_reads+0.5). The quality is defined by -q option. Default: 1.5" }
  read_position_filter: { type: 'int?', inputBinding: { position: 2, prefix: '-P' }, doc: "The read position filter.  If the mean variants position is less that specified, it's considered false positive. Default: 5" }
  always_pileup: { type: 'boolean?', inputBinding: { position: 2, prefix: '-p' }, doc: "Do pileup regardless of the frequency" }
  base_phred_min: { type: 'int?', inputBinding: { position: 2, prefix: '-q' }, doc: "The phred score for a base to be considered a good call. Default: 25 (for Illumina)" }
  region: { type: 'string?', inputBinding: { position: 2, prefix: '-R' }, doc: "The region of interest. In the format of chr:start-end. If end is omitted, then a single position. No BED is needed." }
  variant_reads_min: { type: 'int?', inputBinding: { position: 2, prefix: '-r' }, doc: "The minimum # of variant reads, default 2" }
  trim: { type: 'int?', inputBinding: { position: 2, prefix: '--trim' }, doc: "Trim bases after [INT] bases in the reads" }
  dedup: { type: 'boolean?', inputBinding: { position: 2, prefix: '--dedup' }, doc: "Indicate to remove duplicated reads.  Only one pair with same start positions will be kept" }
  nosv: { type: 'boolean?', inputBinding: { position: 2, prefix: '--nosv' }, doc: "Turn off structural variant calling." }
  unique_forward: { type: 'boolean?', inputBinding: { position: 2, prefix: '-u' }, doc: "Indicate unique mode, which when mate pairs overlap, the overlapping part will be counted only once using forward read only." }
  unique_first: { type: 'boolean?', inputBinding: { position: 2, prefix: '-UN' }, doc: "Indicate unique mode, which when mate pairs overlap, the overlapping part will be counted only once using first read only." }
  mutation_frequency_min: { type: 'float?', inputBinding: { position: 2, prefix: '-V' }, doc: "The lowest frequency in the normal sample allowed for a putative somatic mutation. Defaults to 0.05" }
  output_vcf: { type: 'boolean?', inputBinding: { position: 2, prefix: '-v' }, doc: "VCF format output" }
  read_strictness:
    type:
      - 'null'
      - type: enum
        name: read_strictness 
        symbols: ["STRICT", "LENIENT", "SILENT"]
    inputBinding:
      prefix: "-VS"
    doc: |
      How strict to be when reading a SAM or BAM.
      STRICT - throw an exception if something looks wrong.
      LENIENT- Emit warnings but keep going if possible.
      SILENT - Like LENIENT, only don't emit warning messages.
      Default: LENIENT
  insert_std: { type: 'int?', inputBinding: { position: 2, prefix: '--insert-std' }, doc: "The insert size STD. Used for SV calling. Default: 100" }
  insert_size: { type: 'int?', inputBinding: { position: 2, prefix: '--insert-size' }, doc: "The insert size. Used for SV calling. Default: 300" }
  indel_extension: { type: 'int?', inputBinding: { position: 2, prefix: '-X' }, doc: "Extension of bp to look for mismatches after insersion or deletion.  Default to 2 bp, or only calls when they're within 2 bp." }
  segment_extension: { type: 'int?', inputBinding: { position: 2, prefix: '-x' }, doc: "The number of nucleotide to extend for each segment, default: 0" }
  ref_extension: { type: 'int?', inputBinding: { position: 2, prefix: '--ref-extension' }, doc: "Extension of bp of reference to build lookup table. Default to 1200 bp. Increase the number will slowdown the program. The main purpose is to call large indels with 1000 bp that can be missed by discordant mate pairs." }
  verbose: { type: 'boolean?', inputBinding: { position: 2, prefix: '--verbose' }, doc: "Verbose logging" }
  downsample: { type: 'float?', inputBinding: { position: 2, prefix: '--downsample' }, doc: "For downsampling fraction. e.g. 0.7 means roughly 70% downsampling. Default: No downsampling. Use with caution. The downsampling will be random and non-reproducible." }
  zero_based_coords:
    type:
      - 'null'
      - type: enum
        name: local_realignment
        symbols: ["0","1"]
    inputBinding:
      prefix: "-k"
    doc: |
      Indicate whether coordinates are zero-based, as IGV uses.  Default: 1 for BED file or amplicon BED file.
      Use 0 to turn it off. When using the -R option, it's set to 0

  # Vardict Column Arguments
  chrom_column: { type: 'int?', inputBinding: { position: 2, prefix: '-c' }, doc: "The column for chromosome" }
  gene_column: { type: 'int?', inputBinding: { position: 2, prefix: '-g' }, doc: "The column for gene name, or segment annotation" }
  region_start_column: { type: 'int?', inputBinding: { position: 2, prefix: '-S' }, doc: "The column for region start, e.g. gene start" }
  region_end_column: { type: 'int?', inputBinding: { position: 2, prefix: '-E' }, doc: "The column for region end, e.g. gene end" }
  segment_start_column: { type: 'int?', inputBinding: { position: 2, prefix: '-s' }, doc: "The column for segment starts in the region, e.g. exon starts" }
  segment_end_column: { type: 'int?', inputBinding: { position: 2, prefix: '-e' }, doc: "The column for segment ends in the region, e.g. exon ends" }

  # var2vcf_paired Arguments
  drop_chr: { type: 'boolean?', inputBinding: { position: 32, prefix: '-C' }, doc: "If set, chrosomes will have names of 1,32,3,X,Y, instead of chr1, chr32, chrX, chrY" }
  pass_only: { type: 'boolean?', inputBinding: { position: 32, prefix: '-S' }, doc: "If set, variants that didn't pass filters will not be present in VCF file" }
  somatic_only: { type: 'boolean?', inputBinding: { position: 32, prefix: '-M' }, doc: "If set, output only candidate somatic" }
  all_variants: { type: 'boolean?', inputBinding: { position: 32, prefix: '-A' }, doc: "Indicate to output all variants at the same position.  By default, only the variant with the highest allele frequency is converted to VCF." }
  candidate_proximity_max: { type: 'int?', inputBinding: { position: 32, prefix: '-c' }, doc: "If two somatic candidates are within {int} bp, they're both filtered. Default: 0 or no filtering" }
  nonmonomer_max: { type: 'int?', inputBinding: { position: 32, prefix: '-I' }, doc: "The maximum non-monomer MSI allowed for a HT variant with AF < 0.6. By default, 132, or any variants with AF < 0.6 in a region with > 12 non-monomer MSI will be considered false positive. For monomers, that number is 10." }
  read_mean_mismatch_max: { type: 'float?', inputBinding: { position: 32, prefix: '-m' }, doc: "The maximum mean mismatches allowed. Default: 5.25, or if a variant is supported by reads with more than 5.25 mismathes, it'll be considered false positive. Mismatches don't includes indels in the alignment." }
  sample_names: { type: 'string?', inputBinding: { position: 32, prefix: '-N' }, doc: "The sample name(s). If only one name is given, the matched will be simply names as 'name-match'. Two names are given separated by '|', such as 'tumor|blood'." }
  p_value_max: { type: 'float?', inputBinding: { position: 32, prefix: '-P' }, doc: "The maximum p-value. Default to 0.05." }
  mean_pos_min: { type: 'float?', inputBinding: { position: 32, prefix: '-p' }, doc: "The minimum mean position of variants in the read. Default: 5." }
  mean_bq_min: { type: 'float?', inputBinding: { position: 32, prefix: '-q' }, doc: "The minimum mean base quality. Default to 22.5 for Illumina sequencing" }
  mapq_min: { type: 'float?', inputBinding: { position: 32, prefix: '-Q' }, doc: "The minimum mapping quality. Default to 0 for Illumina sequencing" }
  total_depth_min: { type: 'int?', inputBinding: { position: 32, prefix: '-d' }, doc: "The minimum total depth. Default to 5" }
  var_depth_min: { type: 'int?', inputBinding: { position: 32, prefix: '-v' }, doc: "The minimum variant depth. Default to 3" }
  allele_freq_min: { type: 'float?', inputBinding: { position: 32, prefix: '-f' }, doc: "The minimum allele frequency. Default to 0.02" }
  signal_noise_ratio: { type: 'float?', inputBinding: { position: 32, prefix: '-o' }, doc: "The minimum signal to noise, or the ratio of hi/(lo+0.5).  Default to 1.5.  Set it higher for deep sequencing." }
  genotype_frequency: { type: 'float?', inputBinding: { position: 32, prefix: '-F' }, doc: "The minimum allele frequency to consider to be homozygous. Default to 0.2. Thus frequency > 0.8 (1-0.2) will be considered homozygous '1/1', between 0.5 - (1-0.2) will be '1/0', between (-f) - 0.5 will be '0/1', below (-f) will be '0/0'." }

  # View Generic Arguments
  drop_genotypes: { type: 'boolean?', inputBinding: { position: 32, prefix: "--drop-genotypes"}, doc: "drop individual genotype information (after subsetting if -s option set)" }
  header_only: { type: 'boolean?', inputBinding: { position: 32, prefix: "--header-only"}, doc: "print the header only in VCF output" }
  no_header: { type: 'boolean?', inputBinding: { position: 32, prefix: "--no-header"}, doc: "suppress the header in VCF output" }
  compression_level: { type: 'int?', inputBinding: { position: 32, prefix: "--compression-level"}, doc: "compression level: 0 uncompressed, 1 best speed, 9 best compression [-1]" }
  no_version_view: { type: 'boolean?', inputBinding: { position: 32, prefix: "--no-version"}, doc: "do not append version and command line to the header" }
  output_type:
    type:
      - 'null'
      - type: enum
        name: output_type
        symbols: ["b", "u", "v", "z"]
    inputBinding:
      prefix: "--output-type"
      position: 32
    doc: |
      b: compressed BCF, u: uncompressed BCF, z: compressed VCF, v: uncompressed VCF [v]
  regions_view: { type: 'string?', inputBinding: { position: 32, prefix: "--regions"}, doc: "restrict to comma-separated list of regions" }
  regions_file_view: { type: 'File?', inputBinding: { position: 32, prefix: "--regions-file"}, doc: "restrict to regions listed in a file" }
  targets: { type: 'string?', inputBinding: { position: 32, prefix: "--targets"}, doc: "similar to --regions but streams rather than index-jumps. Exclude regions with '^' prefix" }
  targets_file_include: { type: 'File?', inputBinding: { position: 32, prefix: "--targets-file"}, doc: "similar to --regions-file but streams rather than index-jumps." }
  targets_file_exclude: { type: 'File?', inputBinding: { position: 32, prefix: "--targets-file ^", separate: false, shellQuote: false }, doc: "similar to --regions-file but streams rather than index-jumps. Excludes regions in file" }

  # View Subset Arguments
  trim_alt_alleles: { type: 'boolean?', inputBinding: { position: 32, prefix: "--trim-alt-alleles"}, doc: "trim ALT alleles not seen in the genotype fields (or their subset with -s/-S)" }
  no_update: { type: 'boolean?', inputBinding: { position: 32, prefix: "--no-update"}, doc: "do not (re)calculate INFO fields for the subset (currently INFO/AC and INFO/AN)" }
  samples: { type: 'string?', inputBinding: { position: 32, prefix: "--samples"}, doc: "comma separated list of samples to include (or exclude with '^' prefix)" }
  samples_file_include: { type: 'File?', inputBinding: { position: 32, prefix: "--samples-file"}, doc: "file of samples to include" }
  samples_file_exclude: { type: 'File?', inputBinding: { position: 32, prefix: "--samples-file ^", separate: false, shellQuote: false }, doc: "file of samples to exclude" }
  force_samples: { type: 'boolean?', inputBinding: { position: 32, prefix: "--force-samples"}, doc: "only warn about unknown subset samples" }

  # View Filter Arguments
  min_ac: { type: 'string?', inputBinding: { position: 32, prefix: "--min-ac"}, doc: "minimum count for non-reference (nref), 1st alternate (alt1), least frequent (minor), most frequent (major) or sum of all but most frequent (nonmajor) alleles [nref]" }
  max_ac: { type: 'string?', inputBinding: { position: 32, prefix: "--max-ac"}, doc: "maximum count for non-reference (nref), 1st alternate (alt1), least frequent (minor), most frequent (major) or sum of all but most frequent (nonmajor) alleles [nref]" }
  apply_filters: { type: 'string?', inputBinding: { position: 32, prefix: "--apply-filters"}, doc: "require at least one of the listed FILTER strings (e.g. 'PASS,.)'" }
  genotype: { type: 'string?', inputBinding: { position: 32, prefix: "--genotype"}, doc: "require one or more hom/het/missing genotype or, if prefixed with '^', exclude sites with hom/het/missing genotypes" }
  include: { type: 'string?', inputBinding: { position: 32, prefix: "--include"}, doc: "include sites for which the expression is true (see man page for details)" }
  exclude: { type: 'string?', inputBinding: { position: 32, prefix: "--exclude"}, doc: "exclude sites for which the expression is true (see man page for details)" }
  known: { type: 'boolean?', inputBinding: { position: 32, prefix: "--known"}, doc: "select known sites only (ID is not/is '.')" }
  novel: { type: 'boolean?', inputBinding: { position: 32, prefix: "--novel"}, doc: "select novel sites only (ID is not/is '.')" }
  min_alleles: { type: 'int?', inputBinding: { position: 32, prefix: "--min-alleles"}, doc: "minimum number of alleles listed in REF and ALT (e.g. -m2 -M2 for biallelic sites)" }
  max_alleles: { type: 'int?', inputBinding: { position: 32, prefix: "--max-alleles"}, doc: "maximum number of alleles listed in REF and ALT (e.g. -m2 -M2 for biallelic sites)" }
  phased: { type: 'boolean?', inputBinding: { position: 32, prefix: "--phased"}, doc: "select sites where all samples are phased" }
  exclude_phased: { type: 'boolean?', inputBinding: { position: 32, prefix: "--exclude-phased"}, doc: "exclude sites where all samples are phased" }
  min_af: { type: 'string?', inputBinding: { position: 32, prefix: "--min-af"}, doc: "minimum frequency for non-reference (nref), 1st alternate (alt1), least frequent (minor), most frequent (major) or sum of all but most frequent (nonmajor) alleles [nref]" }
  max_af: { type: 'string?', inputBinding: { position: 32, prefix: "--max-af"}, doc: "maximum frequency for non-reference (nref), 1st alternate (alt1), least frequent (minor), most frequent (major) or sum of all but most frequent (nonmajor) alleles [nref]" }
  uncalled: { type: 'boolean?', inputBinding: { position: 32, prefix: "--uncalled"}, doc: "select sites without a called genotype" }
  exclude_uncalled: { type: 'boolean?', inputBinding: { position: 32, prefix: "--exclude-uncalled"}, doc: "select sites without a called genotype" }
  include_variant_types: { type: 'string?', inputBinding: { position: 32, prefix: "--types"}, doc: "select comma-separated list of variant types: snps,indels,mnps,ref,bnd,other" }
  exclude_variant_types: { type: 'string?', inputBinding: { position: 32, prefix: "--exclude-types"}, doc: "exclude comma-separated list of variant types: snps,indels,mnps,ref,bnd,other [null]" }
  private: { type: 'boolean?', inputBinding: { position: 32, prefix: "--private"}, doc: "select sites where the non-reference alleles are exclusive (private) to the subset samples" }
  exclude_private: { type: 'boolean?', inputBinding: { position: 32, prefix: "--exclude-private"}, doc: "exclude sites where the non-reference alleles are exclusive (private) to the subset samples" }

  # Index Arguments
  force: { type: 'boolean?', inputBinding: { position: 92, prefix: "--force"}, doc: "overwrite index if it already exists" }
  min_shift: { type: 'int?', inputBinding: { position: 92, prefix: "--min-shift"}, doc: "set minimal interval size for CSI indices to 2^INT [14]" }
  csi: { type: 'boolean?', inputBinding: { position: 92, prefix: "--csi"}, doc: "generate CSI-format index for VCF/BCF files [default]" }
  tbi: { type: 'boolean?', inputBinding: { position: 92, prefix: "--tbi"}, doc: "generate TBI-format index for VCF files" }
  nrecords: { type: 'boolean?', inputBinding: { position: 92, prefix: "--nrecords"}, doc: "print number of records based on existing index file" }
  stats: { type: 'boolean?', inputBinding: { position: 92, prefix: "--stats"}, doc: "print per contig stats based on existing index file" }

  cpu:
    type: 'int?'
    default: 4
    doc: "Number of CPUs to allocate to this task."
    inputBinding:
      position: 2
      prefix: '-th'
  ram:
    type: 'int?'
    default: 32 
    doc: "GB size of RAM to allocate to this task."
outputs:
  output:
    type: 'File'
    outputBinding:
      glob: $(inputs.output_filename)
