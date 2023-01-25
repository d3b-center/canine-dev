cwlVersion: v1.2
class: CommandLineTool
id: gridss
doc: "Driver script for running GRIDSS."
requirements:
  - class: InlineJavascriptRequirement
  - class: ShellCommandRequirement
  - class: ResourceRequirement
    ramMin: $(inputs.ram*1000)
    coresMin: $(inputs.cpu)
  - class: DockerRequirement
    dockerPull: 'dmiller15/gridss:2.6.3'
baseCommand: []
arguments:
  - position: 99
    prefix: ''
    shellQuote: false
    valueFrom: |
      1>&2
inputs:
  indexed_reference:
    type: 'File'
    doc: "Reference fasta. Must have a .fai index file and a bwa index."
    secondaryFiles: [{ pattern: ".fai", required: true }, { pattern: ".amb", required: true }, { pattern: ".ann", required: true }, { pattern: ".bwt", required: true }, { pattern: ".pac", required: true }, { pattern: ".sa", requred: true }]
    inputBinding:
      position: 2
      prefix: "--reference"
  assembly_output_filename:
    type: 'string'
    doc: "Name of the GRIDSS assembly BAM. This file will be created by GRIDSS."
    inputBinding:
      position: 2
      prefix: "--assembly"
  vcf_output_filename:
    type: 'string'
    doc: "Name of output VCF"
    inputBinding:
      position: 2
      prefix: "--output"
  input_bams:
    type: 'File[]'
    doc: "Input bam files."
    inputBinding:
      position: 10
  cpu:
    type: 'int?'
    doc: "Number of CPUs to allocate to this task."
    inputBinding:
      position: 2
      prefix: "--threads"
  ram:
    type: 'int?'
    doc: "GB of RAM to allocate to this task."
  jvmheap:
    type: 'int?'
    doc: "GB size of JVM heap for assembly and variant calling. Defaults to 25 to ensure GRIDSS runs on all cloud instances with approximate 32gb memory."
    inputBinding:
      position: 2
      prefix: "--jvmheap"
      valueFrom: $(self)g
  blacklist:
    type: 'File?'
    doc: "BED file containing regions to ignore"
    inputBinding:
      position: 2
      prefix: "--blacklist"
  steps:
    type: 'string?'
    doc: |
      GRIDSS steps to run: ["All","PreProcess","Assemble","Call"]. Defaults to all steps. Multiple steps are specified using comma separators.
    inputBinding:
      position: 2
      prefix: "--steps"
  configuration:
    type: 'File?'
    doc: "configuration file use to override default GRIDSS settings."
    inputBinding:
      position: 2
      prefix: "--configuration"
  labels:
    type: 'string?'
    doc: |
      Comma separated labels to use in the output VCF for the input files. Supporting
      read counts for input files with the same label are aggregated (useful for
      multiple sequencing runs of the same sample). Labels default to input
      filenames, unless a single read group with a non-empty sample name exists in
      which case the read group sample name is used (which can be disabled by
      "useReadGroupSampleNameCategoryLabel=false" in the configuration file). If
      labels are specified, they must be specified for all input files.
    inputBinding:
      position: 2
      prefix: "--labels"
  maxcoverage:
    type: 'long?'
    doc: "maximum coverage. Regions with coverage in excess of this are ignored."
    inputBinding:
      position: 2
      prefix: "--maxcoverage"
  picardoptions:
    type: 'string?'
    doc: "additional standard Picard command line options. Useful options include VALIDATION_STRINGENCY=LENIENT and COMPRESSION_LEVEL=0"
    inputBinding:
      position: 2
      prefix: "--picardoptions"
outputs:
  vcf:
    type: 'File'
    outputBinding:
      glob: $(inputs.vcf_output_filename)
  assembly:
    type: 'File'
    outputBinding:
      glob: $(inputs.assembly_output_filename)
