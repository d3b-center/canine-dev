cwlVersion: v1.2
class: CommandLineTool
id: snpeff_annotate_bcftools_view_index
doc: |
  BCFTOOLS view and optionally index 
requirements:
  - class: InlineJavascriptRequirement
  - class: ShellCommandRequirement
  - class: ResourceRequirement
    ramMin: $(inputs.ram*1000)
    coresMin: $(inputs.cpu)
  - class: DockerRequirement
    dockerPull: 'ghcr.io/tgen/jetstream_containers/tgen_phoenix_snpeff:20210113-skylake'
baseCommand: []
arguments:
  - position: 0
    shellQuote: false
    valueFrom: >
      snpEff ann 
  - position: 0
    shellQuote: false
    prefix: "|"
    valueFrom: >
      bcftools view
  - position: 90
    shellQuote: false
    valueFrom: >
      $(inputs.output_type == "b" || inputs.output_type == "z" ? "&& bcftools index --threads " + inputs.cpu : "")

inputs:
  # SnpEff Ann Required
  input_vcf: { type: 'File', inputBinding: { position: 9 }, doc: "File containing variants" }
  snpeff_database: { type: 'string', inputBinding: { position: 8 }, doc: "Directory containing SnpEff database information" }

  # SnpEff Ann Options
  chr: { type: 'string?', inputBinding: { position: 2, prefix: "-chr"}, doc: "Prepend 'string' to chromosome name (e.g. 'chr1' instead of '1'). Only on TXT output." }
  classic: { type: 'boolean?', inputBinding: { position: 2, prefix: "-classic"}, doc: "Use old style annotations instead of Sequence Ontology and Hgvs." }
  in_format: { type: 'string?', inputBinding: { position: 2, prefix: "-i"}, doc: "Input format [ vcf, bed ]. Default: VCF." }
  fileList: { type: 'boolean?', inputBinding: { position: 2, prefix: "-fileList"}, doc: "Input actually contains a list of files to process." }
  out_format: { type: 'string?', inputBinding: { position: 2, prefix: "-o"}, doc: "Ouput format [ vcf, gatk, bed, bedAnn ]. Default: VCF." }
  stats: { type: 'string?', inputBinding: { position: 2, prefix: "-stats"}, doc: "Name for HTML summary file. Default is 'snpEff_summary.html'" }
  csvStats: { type: 'string?', inputBinding: { position: 2, prefix: "-csvStats"}, doc: "Name for CSV summary file." }
  noStats: { type: 'boolean?', inputBinding: { position: 2, prefix: "-noStats"}, doc: "Do not create stats (summary) file" }
   
  # SnpEff Ann Results Filter Arguments
  filterInterval: { type: 'boolean?', inputBinding: { position: 2, prefix: "-filterInterval"}, doc: "Only analyze changes that intersect with the intervals specified in this file (you may use this option many times)" }
  no_downstream: { type: 'boolean?', inputBinding: { position: 2, prefix: "-no-downstream"}, doc: "Do not show DOWNSTREAM changes" }
  no_intergenic: { type: 'boolean?', inputBinding: { position: 2, prefix: "-no-intergenic"}, doc: "Do not show INTERGENIC changes" }
  no_intron: { type: 'boolean?', inputBinding: { position: 2, prefix: "-no-intron"}, doc: "Do not show INTRON changes" }
  no_upstream: { type: 'boolean?', inputBinding: { position: 2, prefix: "-no-upstream"}, doc: "Do not show UPSTREAM changes" }
  no_utr: { type: 'boolean?', inputBinding: { position: 2, prefix: "-no-utr"}, doc: "Do not show 5_PRIME_UTR or 3_PRIME_UTR changes" }
  no_effect: { type: 'boolean?', inputBinding: { position: 2, prefix: "-no"}, doc: "Do not show 'EffectType'. This option can be used several times." }

  # SnpEff Ann Annotations Arguments
  cancer: { type: 'boolean?', inputBinding: { position: 2, prefix: "-cancer"}, doc: "Perform 'cancer' comparisons (Somatic vs Germline). Default: false" }
  cancerSamples: { type: 'File?', inputBinding: { position: 2, prefix: "-cancerSamples"}, doc: "Two column TXT file defining 'oringinal \t derived' samples." }
  formatEff: { type: 'boolean?', inputBinding: { position: 2, prefix: "-formatEff"}, doc: "Use 'EFF' field compatible with older versions (instead of 'ANN')." }
  geneId: { type: 'boolean?', inputBinding: { position: 2, prefix: "-geneId"}, doc: "Use gene ID instead of gene name (VCF output). Default: false" }
  hgvs: { type: 'boolean?', inputBinding: { position: 2, prefix: "-hgvs"}, doc: "Use HGVS annotations for amino acid sub-field. Default: true" }
  hgvsOld: { type: 'boolean?', inputBinding: { position: 2, prefix: "-hgvsOld"}, doc: "Use old HGVS notation. Default: false" }
  hgvs1LetterAa: { type: 'boolean?', inputBinding: { position: 2, prefix: "-hgvs1LetterAa"}, doc: "Use one letter Amino acid codes in HGVS notation. Default: false" }
  hgvsTrId: { type: 'boolean?', inputBinding: { position: 2, prefix: "-hgvsTrId"}, doc: "Use transcript ID in HGVS notation. Default: false" }
  lof: { type: 'boolean?', inputBinding: { position: 2, prefix: "-lof"}, doc: "Add loss of function (LOF) and Nonsense mediated decay (NMD) tags." }
  noHgvs: { type: 'boolean?', inputBinding: { position: 2, prefix: "-noHgvs"}, doc: "Do not add HGVS annotations." }
  noLof: { type: 'boolean?', inputBinding: { position: 2, prefix: "-noLof"}, doc: "Do not add LOF and NMD annotations." }
  noShiftHgvs: { type: 'boolean?', inputBinding: { position: 2, prefix: "-noShiftHgvs"}, doc: "Do not shift variants according to HGVS notation (most 3prime end)." }
  oicr: { type: 'boolean?', inputBinding: { position: 2, prefix: "-oicr"}, doc: "Add OICR tag in VCF file. Default: false" }
  sequenceOntology: { type: 'boolean?', inputBinding: { position: 2, prefix: "-sequenceOntology"}, doc: "Use Sequence Ontology terms. Default: true" }

  # SnpEff Generic Arguments
  config: { type: 'File?', inputBinding: { position: 2, prefix: "-c"}, doc: "Specify config file" }
  configOption: { type: 'string?', inputBinding: { position: 2, prefix: "-configOption"}, doc: "Override a config file option" }
  debug: { type: 'boolean?', inputBinding: { position: 2, prefix: "-d"}, doc: "Debug mode (very verbose)." }
  dataDir: { type: 'Directory?', inputBinding: { position: 2, prefix: "-dataDir"}, doc: "Override data_dir parameter from config file." }
  download: { type: 'boolean?', inputBinding: { position: 2, prefix: "-download"}, doc: "Download a SnpEff database, if not available locally. Default: true" }
  nodownload: { type: 'boolean?', inputBinding: { position: 2, prefix: "-nodownload"}, doc: "Do not download a SnpEff database, if not available locally." }
  noLog: { type: 'boolean?', inputBinding: { position: 2, prefix: "-noLog"}, doc: "Do not report usage statistics to server" }
  threads: { type: 'boolean?', inputBinding: { position: 2, prefix: "-t"}, doc: "Use multiple threads (implies '-noStats'). Default 'off'" }
  quiet: { type: 'boolean?', inputBinding: { position: 2, prefix: "-q"}, doc: "Quiet mode (do not show any messages or errors)" }
  verbose: { type: 'boolean?', inputBinding: { position: 2, prefix: "-v"}, doc: "Verbose mode" }

  # SnpEff Database Arguments
  canon: { type: 'boolean?', inputBinding: { position: 2, prefix: "-canon"}, doc: "Only use canonical transcripts." }
  canonList: { type: 'File?', inputBinding: { position: 2, prefix: "-canonList"}, doc: "Only use canonical transcripts, replace some transcripts using the 'gene_id transcript_id' entries in this file." }
  interaction: { type: 'boolean?', inputBinding: { position: 2, prefix: "-interaction"}, doc: "Annotate using inteactions (requires interaciton database). Default: true" }
  interval: { type: 'File?', inputBinding: { position: 2, prefix: "-interval"}, doc: "Use a custom intervals in TXT/BED/BigBed/VCF/GFF file (you may use this option many times)" }
  maxTSL: { type: 'string?', inputBinding: { position: 2, prefix: "-maxTSL"}, doc: "Only use transcripts having Transcript Support Level lower than <TSL_number>." }
  motif: { type: 'boolean?', inputBinding: { position: 2, prefix: "-motif"}, doc: "Annotate using motifs (requires Motif database). Default: true" }
  nextProt: { type: 'boolean?', inputBinding: { position: 2, prefix: "-nextProt"}, doc: "Annotate using NextProt (requires NextProt database)." }
  noGenome: { type: 'boolean?', inputBinding: { position: 2, prefix: "-noGenome"}, doc: "Do not load any genomic database (e.g. annotate using custom files)." }
  noExpandIUB: { type: 'boolean?', inputBinding: { position: 2, prefix: "-noExpandIUB"}, doc: "Disable IUB code expansion in input variants" }
  noInteraction: { type: 'boolean?', inputBinding: { position: 2, prefix: "-noInteraction"}, doc: "Disable inteaction annotations" }
  noMotif: { type: 'boolean?', inputBinding: { position: 2, prefix: "-noMotif"}, doc: "Disable motif annotations." }
  noNextProt: { type: 'boolean?', inputBinding: { position: 2, prefix: "-noNextProt"}, doc: "Disable NextProt annotations." }
  onlyReg: { type: 'boolean?', inputBinding: { position: 2, prefix: "-onlyReg"}, doc: "Only use regulation tracks." }
  onlyProtein: { type: 'boolean?', inputBinding: { position: 2, prefix: "-onlyProtein"}, doc: "Only use protein coding transcripts. Default: false" }
  onlyTr: { type: 'File?', inputBinding: { position: 2, prefix: "-onlyTr"}, doc: "Only use the transcripts in this file. Format: One transcript ID per line." }
  reg: { type: 'string?', inputBinding: { position: 2, prefix: "-reg"}, doc: "Regulation track to use (this option can be used add several times)." }
  spliceSiteSize: { type: 'int?', inputBinding: { position: 2, prefix: "-spliceSiteSize"}, doc: "Set size for splice sites (donor and acceptor) in bases. Default: 2" }
  spliceRegionExonSize: { type: 'int?', inputBinding: { position: 2, prefix: "-spliceRegionExonSize"}, doc: "Set size for splice site region within exons. Default: 3 bases" }
  spliceRegionIntronMin: { type: 'int?', inputBinding: { position: 2, prefix: "-spliceRegionIntronMin"}, doc: "Set minimum number of bases for splice site region within intron. Default: 3 bases" }
  spliceRegionIntronMax: { type: 'int?', inputBinding: { position: 2, prefix: "-spliceRegionIntronMax"}, doc: "Set maximum number of bases for splice site region within intron. Default: 8 bases" }
  strict: { type: 'boolean?', inputBinding: { position: 2, prefix: "-strict"}, doc: "Only use 'validated' transcripts (i.e. sequence has been checked). Default: false" }
  upDownStreamLen: { type: 'int?', inputBinding: { position: 2, prefix: "-upDownStreamLen"}, doc: "Set upstream downstream interval length (in bases)" }

  # View Required Inputs
  output_filename: { type: 'string', inputBinding: { position: 12, prefix: "--output-file"}, doc: "output file name [stdout]" }

  # View Generic Arguments
  drop_genotypes: { type: 'boolean?', inputBinding: { position: 12, prefix: "--drop-genotypes"}, doc: "drop individual genotype information (after subsetting if -s option set)" }
  header_only: { type: 'boolean?', inputBinding: { position: 12, prefix: "--header-only"}, doc: "print the header only in VCF output" }
  no_header: { type: 'boolean?', inputBinding: { position: 12, prefix: "--no-header"}, doc: "suppress the header in VCF output" }
  compression_level: { type: 'int?', inputBinding: { position: 12, prefix: "--compression-level"}, doc: "compression level: 0 uncompressed, 1 best speed, 9 best compression [-1]" }
  no_version_view: { type: 'boolean?', inputBinding: { position: 12, prefix: "--no-version"}, doc: "do not append version and command line to the header" }
  output_type:
    type:
      - 'null'
      - type: enum
        name: output_type
        symbols: ["b", "u", "v", "z"]
    inputBinding:
      prefix: "--output-type"
      position: 12
    doc: |
      b: compressed BCF, u: uncompressed BCF, z: compressed VCF, v: uncompressed VCF [v]
  regions_view: { type: 'string?', inputBinding: { position: 12, prefix: "--regions"}, doc: "restrict to comma-separated list of regions" }
  regions_file_view: { type: 'File?', inputBinding: { position: 12, prefix: "--regions-file"}, doc: "restrict to regions listed in a file" }
  targets: { type: 'string?', inputBinding: { position: 12, prefix: "--targets"}, doc: "similar to --regions but streams rather than index-jumps. Exclude regions with '^' prefix" }
  targets_file_include: { type: 'File?', inputBinding: { position: 12, prefix: "--targets-file"}, doc: "similar to --regions-file but streams rather than index-jumps." }
  targets_file_exclude: { type: 'File?', inputBinding: { position: 12, prefix: "--targets-file ^", separate: false, shellQuote: false }, doc: "similar to --regions-file but streams rather than index-jumps. Excludes regions in file" }

  # View Subset Arguments
  trim_alt_alleles: { type: 'boolean?', inputBinding: { position: 12, prefix: "--trim-alt-alleles"}, doc: "trim ALT alleles not seen in the genotype fields (or their subset with -s/-S)" }
  no_update: { type: 'boolean?', inputBinding: { position: 12, prefix: "--no-update"}, doc: "do not (re)calculate INFO fields for the subset (currently INFO/AC and INFO/AN)" }
  samples: { type: 'string?', inputBinding: { position: 12, prefix: "--samples"}, doc: "comma separated list of samples to include (or exclude with '^' prefix)" }
  samples_file_include: { type: 'File?', inputBinding: { position: 12, prefix: "--samples-file"}, doc: "file of samples to include" }
  samples_file_exclude: { type: 'File?', inputBinding: { position: 12, prefix: "--samples-file ^", separate: false, shellQuote: false }, doc: "file of samples to exclude" }
  force_samples: { type: 'boolean?', inputBinding: { position: 12, prefix: "--force-samples"}, doc: "only warn about unknown subset samples" }

  # View Filter Arguments
  min_ac: { type: 'string?', inputBinding: { position: 12, prefix: "--min-ac"}, doc: "minimum count for non-reference (nref), 1st alternate (alt1), least frequent (minor), most frequent (major) or sum of all but most frequent (nonmajor) alleles [nref]" }
  max_ac: { type: 'string?', inputBinding: { position: 12, prefix: "--max-ac"}, doc: "maximum count for non-reference (nref), 1st alternate (alt1), least frequent (minor), most frequent (major) or sum of all but most frequent (nonmajor) alleles [nref]" }
  apply_filters: { type: 'string?', inputBinding: { position: 12, prefix: "--apply-filters"}, doc: "require at least one of the listed FILTER strings (e.g. 'PASS,.)'" }
  genotype: { type: 'string?', inputBinding: { position: 12, prefix: "--genotype"}, doc: "require one or more hom/het/missing genotype or, if prefixed with '^', exclude sites with hom/het/missing genotypes" }
  include: { type: 'string?', inputBinding: { position: 12, prefix: "--include"}, doc: "include sites for which the expression is true (see man page for details)" }
  exclude: { type: 'string?', inputBinding: { position: 12, prefix: "--exclude"}, doc: "exclude sites for which the expression is true (see man page for details)" }
  known: { type: 'boolean?', inputBinding: { position: 12, prefix: "--known"}, doc: "select known sites only (ID is not/is '.')" }
  novel: { type: 'boolean?', inputBinding: { position: 12, prefix: "--novel"}, doc: "select novel sites only (ID is not/is '.')" }
  min_alleles: { type: 'int?', inputBinding: { position: 12, prefix: "--min-alleles"}, doc: "minimum number of alleles listed in REF and ALT (e.g. -m2 -M2 for biallelic sites)" }
  max_alleles: { type: 'int?', inputBinding: { position: 12, prefix: "--max-alleles"}, doc: "maximum number of alleles listed in REF and ALT (e.g. -m2 -M2 for biallelic sites)" }
  phased: { type: 'boolean?', inputBinding: { position: 12, prefix: "--phased"}, doc: "select sites where all samples are phased" }
  exclude_phased: { type: 'boolean?', inputBinding: { position: 12, prefix: "--exclude-phased"}, doc: "exclude sites where all samples are phased" }
  min_af: { type: 'string?', inputBinding: { position: 12, prefix: "--min-af"}, doc: "minimum frequency for non-reference (nref), 1st alternate (alt1), least frequent (minor), most frequent (major) or sum of all but most frequent (nonmajor) alleles [nref]" }
  max_af: { type: 'string?', inputBinding: { position: 12, prefix: "--max-af"}, doc: "maximum frequency for non-reference (nref), 1st alternate (alt1), least frequent (minor), most frequent (major) or sum of all but most frequent (nonmajor) alleles [nref]" }
  uncalled: { type: 'boolean?', inputBinding: { position: 12, prefix: "--uncalled"}, doc: "select sites without a called genotype" }
  exclude_uncalled: { type: 'boolean?', inputBinding: { position: 12, prefix: "--exclude-uncalled"}, doc: "select sites without a called genotype" }
  include_variant_types: { type: 'string?', inputBinding: { position: 12, prefix: "--types"}, doc: "select comma-separated list of variant types: snps,indels,mnps,ref,bnd,other" }
  exclude_variant_types: { type: 'string?', inputBinding: { position: 12, prefix: "--exclude-types"}, doc: "exclude comma-separated list of variant types: snps,indels,mnps,ref,bnd,other [null]" }
  private: { type: 'boolean?', inputBinding: { position: 12, prefix: "--private"}, doc: "select sites where the non-reference alleles are exclusive (private) to the subset samples" }
  exclude_private: { type: 'boolean?', inputBinding: { position: 12, prefix: "--exclude-private"}, doc: "exclude sites where the non-reference alleles are exclusive (private) to the subset samples" }

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
      position: 12
      prefix: "--threads"
  ram:
    type: 'int?'
    default: 16
    inputBinding:
      position: 2
      valueFrom: "-Xmx${ return Math.floor(inputs.self*1000/1.074-1) }m"
    doc: "GB size of RAM to allocate to this task."
outputs:
  output:
    type: 'File'
    secondaryFiles: [{pattern: '.tbi', required: false}, {pattern: '.csi', required: false}]
    outputBinding:
      glob: $(inputs.output_filename)
