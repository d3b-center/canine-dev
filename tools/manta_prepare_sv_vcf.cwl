cwlVersion: v1.2
class: CommandLineTool
id: manta_prepare_sv_vcf
doc: "Prepare SV VCF"
requirements:
  - class: InlineJavascriptRequirement
  - class: ShellCommandRequirement
  - class: DockerRequirement
    dockerPull: 'pgc-images.sbgenomics.com/d3b-bixu/python:3.9-canine-util'
  - class: ResourceRequirement
    ramMin: $(inputs.ram*1000)
    coresMin: $(inputs.cpu)
  - class: InitialWorkDirRequirement
    listing:
    - entryname: manta_prepare_sv_vcf_f94bcc1.py
      writable: false
      entry:
        $include: ../scripts/manta_prepare_sv_vcf_f94bcc1.py
baseCommand: [python, manta_prepare_sv_vcf_f94bcc1.py]
arguments:
  - position: 99
    prefix: ''
    shellQuote: false
    valueFrom: |
      1>&2
inputs:
  input_vcf: { type: 'File', inputBinding: { position: 2, prefix: "--vcf_file" }, doc: "input file VCF file" }
  tumor_bam_file: { type: 'File', inputBinding: { position: 2, prefix: "--tumor_bam_file" }, doc: "Tumor BAM/CRAM file" }
  normal_bam_file: { type: 'File', inputBinding: { position: 2, prefix: "--normal_bam_file" }, doc: "normal BAM/CRAM file" }
  insert_size: { type: 'float', inputBinding: { position: 2, prefix: "--insert-size" }, doc: "mean insert size  captured from samtools stats or picard stats" }
  sigma: { type: 'float', inputBinding: { position: 2, prefix: "--sigma" }, doc: "standard deviation for mean insert size captured from samtools stats or picard stats" }
  tumor_name: { type: 'string', inputBinding: { position: 2, prefix: "--tumor-name" }, doc: "name of the tumor sample found in the vcf header line starting with ##CHROM" }
  slop: { type: 'float?', inputBinding: { position: 2, prefix: "--slop" }, doc: "if provided, will override insert-size +/- sigma so you can provide either insert-size and sigma OR slop only" }
  minmapq: { type: 'int?', inputBinding: { position: 2, prefix: "--minmapq" }, doc: "minimum mapping quality" }
  output_filename: { type: 'string', inputBinding: { position: 2, prefix: "--output" }, doc: "String to use as output_filename(relative or full path)" }
  gz_out: { type: 'boolean?', inputBinding: { position: 2, prefix: "--gz-out" }, doc: "compress the vcf_file using bcftools view ; need bcftools in PATH. DO NOT use if you later gene-annotate the vcf_file" }
  logfile: { type: 'string?', inputBinding: { position: 2, prefix: "--logfile" }, doc: "Name for output log file" }
  refgen: { type: 'File?', inputBinding: { position: 2, prefix: "--refgen" }, doc: "Reference fasta. Required for CRAM inputs" }
  debug: { type: 'boolean?', inputBinding: { position: 2, prefix: "--debug" }, doc: "enable debug information" }

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
outputs:
  output: 
    type: File
    outputBinding:
      glob: $(inputs.output_filename)
