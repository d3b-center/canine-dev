cwlVersion: v1.2
class: CommandLineTool
id: coyote_vep
doc: "VEP has endless options so I just cheated and made a custom tool that runs the exact parameters for Coyote."
requirements:
  - class: InlineJavascriptRequirement
  - class: ShellCommandRequirement
  - class: DockerRequirement
    dockerPull: 'ghcr.io/tgen/jetstream_containers/tgen_phoenix_vep:20210113-skylake'
  - class: ResourceRequirement
    ramMin: $(inputs.ram*1000)
    coresMin: $(inputs.cpu)

baseCommand: []

arguments:
  - position: 1
    valueFrom: >
      vep --fork $(inputs.cpu)
      --input_file $(inputs.input_vcf.path)
      --format vcf
      --output_file $(inputs.output_filename)
      --vcf
      --vcf_info_field CSQ
      --species canis_familiaris
      --force_overwrite
      --no_stats
      --cache
      --dir_cache $(inputs.vep_cache.path)
      --cache_version 98
      --offline
      --fasta $(inputs.reference_fasta.path)
      --buffer_size 10000
      --terms SO
      --hgvs
      --hgvsg
      --symbol
      --uniprot
      --domains
      --canonical
      $(inputs.all_or_con == 'all' ? '--flag_pick_allele_gene' : '--pick_allele_gene')
      --pick_order canonical,appris,tsl,biotype,rank,ccds,length

inputs:
  input_vcf: { type: 'File', doc: "Input VCF file to be annotated" }
  output_filename: { type: 'string', doc: "Name for output annotated VCF file" }
  vep_cache: { type: 'Directory', loadListing: deep_listing, doc: "Directory containing VEP cache information" }
  reference_fasta: { type: 'File', doc: "Reference genome fasta file" }
  all_or_con: { type: 'string', doc: "VEP all or con?" }
  cpu:
    type: 'int?'
    default: 4
    doc: "Number of CPUs to allocate to this task."
  ram:
    type: 'int?'
    default: 8
    doc: "GB size of RAM to allocate to this task."

outputs:
  output:
    type: 'File'
    outputBinding:
      glob: $(inputs.output_filename)
