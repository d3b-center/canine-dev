cwlVersion: v1.0
class: CommandLineTool
id: kfdrc-vep99-canine
label: VEP
doc: |
  Simplified descrition of what this tool does:
    1. Untar cache if it is provided
    2. Run VEP on input VCF
    3. BGZIP output VCF
    4. TABIX output VCF

  VEP Parameters:
    1. input_file: Path to input file
    2. output_file: Path for output VCF or STDOUT
    3. stats_file: Path for output stats file
    4. warning_file: Path for output warnings file
    5. vcf: Writes output in VCF format
    6. offline: No database connections will be made, and a cache file or GFF/GTF file is required for annotation
    7. fork: Number of threads to run on
    8. ccds: Adds the CCDS transcript identifier
    9. uniprot: Adds best match accessions for translated protein products from three UniProt-related databases (SWISSPROT, TREMBL and UniParc)
    10. symbol: Adds the gene symbol (e.g. HGNC)
    11. numbers: Adds affected exon and intron numbering to to output. Format is Number/Total
    12. canonical: Adds a flag indicating if the transcript is the canonical transcript for the gene
    13. protein: Add the Ensembl protein identifier to the output where appropriate
    14. assembly: Select the assembly version to use if more than one available. If using the cache, you must have the appropriate assembly's cache file installed
    15. dir_cache: Cache directory to use
    16. cache: Enables use of the cache
    17. merged: Use the merged Ensembl and RefSeq cache
    18. hgvs: Add HGVS nomenclature based on Ensembl stable identifiers to the output
    19. fasta: Specify a FASTA file or a directory containing FASTA files to use to look up reference sequence
    20. check_existing: Checks for the existence of known variants that are co-located with your input
  An example run of this tool will use a command like this:
    /bin/bash -c
    set -eo pipefail
    tar -xzf /path/to/cache.ext &&
    /opt/vep/src/ensembl-vep/vep
      --input_file /path/to/input_vcf.ext
      --output_file STDOUT
      --stats_file output_basename-string-value_stats.tool_name-string-value.html
      --warning_file output_basename-string-value_warnings.tool_name-string-value.txt
      --species canis_familiaris
      --vcf
      --offline
      --fork 16
      --variant_class
      --ccds
      --uniprot
      --symbol
      --numbers
      --canonical
      --protein
      --assembly CanFam3.1
      --dir_cache $PWD
      --cache
      --merged
      --check_existing
      --hgvs
      --fasta /path/to/reference.ext |
    bgzip -c > output_basename-string-value.tool_name-string-value.vep.vcf.gz &&
    tabix output_basename-string-value.tool_name-string-value.vep.vcf.gz
requirements:
  - class: ShellCommandRequirement
  - class: InlineJavascriptRequirement
  - class: ResourceRequirement
    ramMin: 24000
    coresMin: 16
  - class: DockerRequirement
    dockerPull: 'ensemblorg/ensembl-vep:release_99.0'
baseCommand: ["/bin/bash", "-c"]
arguments:
  - position: 1
    shellQuote: false
    valueFrom: >-
      set -eo pipefail;
      tar -xvf  $(inputs.cache.path) &&
      /opt/vep/src/ensembl-vep/vep
      --input_file $(inputs.input_vcf.path)
      --output_file STDOUT
      --stats_file $(inputs.output_basename)_stats.$(inputs.tool_name).html
      --warning_file $(inputs.output_basename)_warnings.$(inputs.tool_name).txt
      --vcf
      --offline
      --fork 16
      --ccds
      --uniprot
      --symbol
      --numbers
      --canonical
      --protein
      --species $(inputs.species)
      --cache_version  $(inputs.cache_version)
      --assembly $(inputs.assembly)
      --dir_cache $PWD --cache --merged
      --hgvs --fasta $(inputs.reference.path) |
      bgzip -c > $(inputs.output_basename).$(inputs.tool_name).vep.vcf.gz &&
      tabix $(inputs.output_basename).$(inputs.tool_name).vep.vcf.gz
inputs:
  input_vcf: { type: File, secondaryFiles: [.tbi], doc: "VCF file (with associated index) to be annotated" }
  reference_gzipped: { type: 'File',  secondaryFiles: [.fai,.gzi], doc: "Fasta genome assembly with indexes" }
  cache: { type: 'File', doc: "tar gzipped cache from ensembl/local converted cache" }
  output_basename: { type: string, doc: "String that will be used in the output filenames" }
  tool_name: { type: string, doc: "Tool name to be used in output filenames" }
  assembly: {type: string, doc: "Type of reference  assembly used. Ex: CanFam3.1 for canine"}
  species: {type: string, doc: "VCF file source species, Ex: canis_familiaris for canine"}
  cache_version: {type: string, doc: "Version of ensembl cache file, Ex: 99, 98"}
outputs:
  output_vcf: { type: File, outputBinding: { glob: '*.vcf.gz' }, secondaryFiles: ['.tbi'] }
  output_html: { type: File, outputBinding: { glob: '*.html' } }
  warn_txt: { type: 'File?', outputBinding: { glob: '*.txt' } }
