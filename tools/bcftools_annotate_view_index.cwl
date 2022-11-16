cwlVersion: v1.2
class: CommandLineTool
id: bcftools_annotate_view
doc: |
  BCFTOOLS annotate view and optionally index
requirements:
  - class: InlineJavascriptRequirement
  - class: ShellCommandRequirement
  - class: ResourceRequirement
    ramMin: $(inputs.ram*1000)
    coresMin: $(inputs.cpu)
  - class: DockerRequirement
    dockerPull: 'staphb/bcftools:1.10.2'
baseCommand: []
arguments:
  - position: 0
    shellQuote: false
    valueFrom: >
      bcftools annotate --output-type u
  - position: 10
    prefix: "|"
    shellQuote: false
    valueFrom: >
      bcftools view
  - position: 90
    prefix: "&&"
    shellQuote: false
    valueFrom: >
      $(inputs.output_type == "b" || inputs.output_type == "z" ? "bcftools index --threads " + inputs.cpu : "echo DONE")
  - position: 99
    shellQuote: false
    valueFrom: >
      $(inputs.output_type == "b" || inputs.output_type == "z" ? inputs.output_filename : "")

inputs:
  # Required Inputs
  input_vcf: { type: 'File', inputBinding: { position: 9 }, doc: "VCF file to annotate and view" }
  output_filename: { type: 'string', inputBinding: { position: 12, prefix: "--output-file"}, doc: "output file name [stdout]" }

  # Annotate Arguments
  annotations: { type: 'File?', inputBinding: { position: 2, prefix: "--annotations"}, doc: "VCF file or tabix-indexed file with annotations: CHR\tPOS[\tVALUE]+" }
  collapse: 
    type:
      - 'null'
      - type: enum
        name: collapse 
        symbols: ["snps","indels","both","all","some","none"]
    inputBinding:
      prefix: "--collapse"
      position: 2
    doc: |
      treat as identical records with <snps|indels|both|all|some|none>
  columns: { type: 'string?', inputBinding: { position: 2, prefix: "--columns"}, doc: "list of columns in the annotation file, e.g. CHROM,POS,REF,ALT,-,INFO/TAG. See man page for details" }
  exclude: { type: 'string?', inputBinding: { position: 2, prefix: "--exclude"}, doc: "exclude sites for which the expression is true (see man page for details)" }
  header_lines: { type: 'File?', inputBinding: { position: 2, prefix: "--header-lines"}, doc: "File containing lines which should be appended to the VCF header" }
  set_id: { type: 'string?', inputBinding: { position: 2, prefix: "--set-id"}, doc: "set ID column, see man page for details" }
  include: { type: 'string?', inputBinding: { position: 2, prefix: "--include"}, doc: "select sites for which the expression is true (see man page for details)" }
  keep_sites: { type: 'boolean?', inputBinding: { position: 2, prefix: "--keep-sites"}, doc: "leave -i/-e sites unchanged instead of discarding them" }
  merge_logic: { type: 'string?', inputBinding: { position: 2, prefix: "--merge-logic"}, doc: "merge logic for multiple overlapping regions (see man page for details), EXPERIMENTAL" }
  mark_sites: { type: 'string?', inputBinding: { position: 2, prefix: "--mark-sites"}, doc: "add INFO/tag flag to sites which are ('+') or are not ('-') listed in the -a file" }
  no_version: { type: 'boolean?', inputBinding: { position: 2, prefix: "--no-version"}, doc: "do not append version and command line to the header" }
  regions: { type: 'string?', inputBinding: { position: 2, prefix: "--regions"}, doc: "restrict to comma-separated list of regions" }
  regions_file: { type: 'File?', inputBinding: { position: 2, prefix: "--regions-file"}, doc: "restrict to regions listed in a file" }
  rename_chrs: { type: 'File?', inputBinding: { position: 2, prefix: "--rename-chrs"}, doc: "rename sequences according to map file: from\tto" }
  samples: { type: 'string?', inputBinding: { position: 2, prefix: "--samples"}, doc: "comma separated list of samples to annotate (or exclude with '^' prefix)" }
  samples_file: { type: 'File?', inputBinding: { position: 2, prefix: "--samples-file"}, doc: "file of samples to annotate (or exclude with '^' prefix)" }
  single_overlaps: { type: 'boolean?', inputBinding: { position: 2, prefix: "--single-overlaps"}, doc: "keep memory low by avoiding complexities arising from handling multiple overlapping intervals" }
  remove: { type: 'string?', inputBinding: { position: 2, prefix: "--remove"}, doc: "list of annotations (e.g. ID,INFO/DP,FORMAT/DP,FILTER) to remove (or keep with '^' prefix). See man page for details" }

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
  view_samples: { type: 'string?', inputBinding: { position: 12, prefix: "--samples"}, doc: "comma separated list of samples to include (or exclude with '^' prefix)" }
  samples_file_include: { type: 'File?', inputBinding: { position: 12, prefix: "--samples-file"}, doc: "file of samples to include" }
  samples_file_exclude: { type: 'File?', inputBinding: { position: 12, prefix: "--samples-file ^", separate: false, shellQuote: false }, doc: "file of samples to exclude" }
  force_samples: { type: 'boolean?', inputBinding: { position: 12, prefix: "--force-samples"}, doc: "only warn about unknown subset samples" }

  # View Filter Arguments
  min_ac: { type: 'string?', inputBinding: { position: 12, prefix: "--min-ac"}, doc: "minimum count for non-reference (nref), 1st alternate (alt1), least frequent (minor), most frequent (major) or sum of all but most frequent (nonmajor) alleles [nref]" }
  max_ac: { type: 'string?', inputBinding: { position: 12, prefix: "--max-ac"}, doc: "maximum count for non-reference (nref), 1st alternate (alt1), least frequent (minor), most frequent (major) or sum of all but most frequent (nonmajor) alleles [nref]" }
  apply_filters: { type: 'string?', inputBinding: { position: 12, prefix: "--apply-filters"}, doc: "require at least one of the listed FILTER strings (e.g. 'PASS,.)'" }
  genotype: { type: 'string?', inputBinding: { position: 12, prefix: "--genotype"}, doc: "require one or more hom/het/missing genotype or, if prefixed with '^', exclude sites with hom/het/missing genotypes" }
  view_include: { type: 'string?', inputBinding: { position: 12, prefix: "--include"}, doc: "include sites for which the expression is true (see man page for details)" }
  view_exclude: { type: 'string?', inputBinding: { position: 12, prefix: "--exclude"}, doc: "exclude sites for which the expression is true (see man page for details)" }
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
  output_index_filename: { type: 'string?', inputBinding: { position: 92, prefix: "--output-file"}, doc: "optional output index file name" }
  csi: { type: 'boolean?', inputBinding: { position: 92, prefix: "--csi"}, doc: "generate CSI-format index for VCF/BCF files [default]" }
  tbi: { type: 'boolean?', inputBinding: { position: 92, prefix: "--tbi"}, doc: "generate TBI-format index for VCF files" }
  nrecords: { type: 'boolean?', inputBinding: { position: 92, prefix: "--nrecords"}, doc: "print number of records based on existing index file" }
  stats: { type: 'boolean?', inputBinding: { position: 92, prefix: "--stats"}, doc: "print per contig stats based on existing index file" }

  cpu:
    type: 'int?'
    default: 1
    doc: "Number of CPUs to allocate to this task."
    inputBinding:
      position: 2
      prefix: "--threads"
  ram:
    type: 'int?'
    default: 4
    doc: "GB size of RAM to allocate to this task."
outputs:
  output:
    type: 'File'
    secondaryFiles: [{ pattern: '.csi', required: false }, { pattern: '.tbi', required: false }]
    outputBinding:
      glob: $(inputs.output_filename)
