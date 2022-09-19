cwlVersion: v1.2
class: CommandLineTool
id: manta 
doc: "Calls structural variants."
requirements:
  - class: ShellCommandRequirement
  - class: InlineJavascriptRequirement
  - class: ResourceRequirement
    ramMin: $(inputs.ram * 1000)
    coresMin: $(inputs.cpu)
  - class: DockerRequirement
    dockerPull: 'pgc-images.sbgenomics.com/d3b-bixu/manta:1.6.0'

baseCommand: []
arguments:
  - position: 0
    shellQuote: false
    valueFrom: >
      /manta-1.6.0.centos6_x86_64/bin/configManta.py --runDir=./
  - position: 10
    prefix: "&&"
    valueFrom: >
      ./runWorkflow.py -m local

inputs:
    config: {type: 'File?', inputBinding: {position: 2, prefix: "--config"}, doc: "configuration file to override defaults in global config file (/manta-1.6.0.centos6_x86_64/bin/configManta.py.ini)" }
    input_tumor_reads: {type: 'File?', inputBinding: {position: 2, prefix: "--tumorBam"}, secondaryFiles: [{pattern: '.crai', required: false}, {pattern: '.bai', required: false}], doc: "Tumor sample BAM or CRAM file. Only up to one tumor bam file accepted."}
    input_normal_reads:
      type:
        - 'null'
        - type: array
          items: File
          inputBinding:
            prefix: "--normalBam"
      inputBinding:
        position: 2
      secondaryFiles: [{pattern: '.crai', required: false}, {pattern: '.bai', required: false}]
      doc: |
        Normal sample BAM or CRAM file(s). May be specified more than once, multiple inputs will be treated as each BAM file representing a different sample.
    exome: { type: 'boolean?', inputBinding: {position: 2, prefix: "--exome"}, doc: "Set options for WES input: turn off depth filters" } 
    rna: { type: 'boolean?', inputBinding: {position: 2, prefix: "--rna"}, doc: "Set options for RNA-Seq input. Must specify exactly one bam input file" }
    unstranded_rna: { type: 'boolean?', inputBinding: {position: 2, prefix: "--unstrandedRNA"}, doc: "Set if RNA-Seq input is unstranded: Allows splice-junctions on either strand" }
    indexed_reference_fasta: { type: 'File', inputBinding: {position: 2, prefix: "--referenceFasta"}, secondaryFiles: [{pattern: '^.dict', required: true}, {pattern: '.fai', required: true}], doc: "samtools-indexed reference fasta file"}
    call_regions: { type: 'File?', inputBinding: {position: 2, prefix: "--callRegions"}, doc: "bgzip-compressed/tabix-indexed BED file containing the set of regions to call. No VCF output will be provided outside of these regions." }
    cpu: {type: 'int?', default: 16, inputBinding: {position:12, prefix: "-j"}, doc: "CPUs to allocate to this task"}
    ram: {type: 'int?', default: 32, doc: "GB of RAM to allocate to this task"}

outputs:
  candidate_sv:
    type: 'File?'
    outputBinding:
      glob: 'results/variants/*candidateSV.vcf.gz'
    secondaryFiles: [{pattern: '.tbi', required: true}]
  diploid_sv:
    type: 'File?'
    outputBinding:
      glob: 'results/variants/*diploidSV.vcf.gz'
    secondaryFiles: [{pattern: '.tbi', required: true}]
  somatic_sv:
    type: 'File?'
    outputBinding:
      glob: 'results/variants/*somaticSV.vcf.gz'
    secondaryFiles: [{pattern: '.tbi', required: true}]
  tumor_sv:
    type: 'File?'
    outputBinding:
      glob: 'results/variants/*tumorSV.vcf.gz'
    secondaryFiles: [{pattern: '.tbi', required: true}]
  small_indels:
    type: File
    outputBinding:
      glob: 'results/variants/*candidateSmallIndels.vcf.gz'
    secondaryFiles: [{pattern: '.tbi', required: true}]
