class: CommandLineTool
cwlVersion: v1.2
id: samtools_fix_mt
doc: |-
  Try to fix an issue with canine mitochondrial chromosome naming
requirements:
  - class: ShellCommandRequirement
  - class: InlineJavascriptRequirement
  - class: DockerRequirement
    dockerPull: 'staphb/samtools:1.20'
  - class: ResourceRequirement
    ramMin: $(inputs.ram*1000)
    coresMin: $(Math.max(8,inputs.cpu))
baseCommand: []
arguments:
  - position: 0
    shellQuote: false
    valueFrom: >
      samtools view --threads $(Math.max(2, Math.floor(inputs.cpu / 3))) -h $(inputs.input_reads.path)
      | awk -F'\t' -vOFS='\t' '{if ($line !~ /^@/) {$3=($3=="M" ? "MT" : $3); $7=($7=="M" ? "MT" : $7); sub(/SA:Z:M,/,"SA:Z:MT,")} else if ($line ~ /^@SQ/) {$2=($2=="SN:M" ? "SN:MT" : $2)} print $line}'
      | samtools view --threads $(Math.max(6, Math.floor(inputs.cpu / 1.5))) --write-index -hbo $(inputs.input_reads.basename.replace(/bam$/,"fixMT.bam"))##idx##$(inputs.input_reads.basename.replace(/bam$/,"fixMT.bam.bai"))
inputs:
  input_reads: { type: File, doc: "Input BAM/CRAM/SAM file" }
  cpu:
    type: 'int?'
    default: 16
    doc: "Number of CPUs to allocate to this task."
  ram:
    type: 'int?'
    default: 32
    doc: "GB size of RAM to allocate to this task."

outputs:
  output:
    type: File
    secondaryFiles: [{pattern: '.bai', required: false}, {pattern: '^.bai', required: false}, {pattern: '.crai', required: false}, {pattern: '^.crai', required: false}]
    outputBinding:
      glob: '*.*am'

$namespaces:
  sbg: https://sevenbridges.com
