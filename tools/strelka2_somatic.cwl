cwlVersion: v1.2
class: CommandLineTool
id: strelka2_somatic
requirements:
  - class: ShellCommandRequirement
  - class: InlineJavascriptRequirement
  - class: ResourceRequirement
    ramMin: $(inputs.ram * 1000)
    coresMin: $(inputs.cpu)
  - class: DockerRequirement
    dockerPull: 'pgc-images.sbgenomics.com/d3b-bixu/strelka:v2.9.10'

baseCommand: [/strelka-2.9.10.centos6_x86_64/bin/configureStrelkaSomaticWorkflow.py, --runDir=./]
arguments:
  - position: 10
    prefix: "&&"
    shellQuote: false
    valueFrom: >-
      ./runWorkflow.py -m local

inputs:
  tumor_bam: { type: 'File', inputBinding: { prefix: '--tumorBam',  position: 1 }, secondaryFiles: [{pattern: '.bai', required: false,}, {pattern: '^.bai', required: false}, {pattern: '.crai', required: false}, {pattern: '^.crai', required: false}], doc: "Tumor sample BAM or CRAM file." }
  normal_bam: { type: 'File', inputBinding: { prefix: '--normalBam',  position: 1 }, secondaryFiles: [{pattern: '.bai', required: false,}, {pattern: '^.bai', required: false}, {pattern: '.crai', required: false}, {pattern: '^.crai', required: false}], doc: "Normal sample BAM or CRAM file." }
  reference: { type: 'File', secondaryFiles: [{pattern: '.fai', required: true}], inputBinding: { prefix: '--referenceFasta', position: 1 }, doc: "Samtools-indexed reference fasta file" }
  indel_candidates: { type: ['null', { type: 'array', items: File, inputBinding: { prefix: '--indelCandidates'}}], secondaryFiles: [{pattern: '.tbi', required: true}], inputBinding: { position: 1 }, doc: "Specify a VCF of candidate indel alleles. These alleles are always evaluated but only reported in the output when they are inferred to exist in the sample. The VCF must be tabix indexed. All indel alleles must be left-shifted/normalized, any unnormalized alleles will be ignored. This option may be specified more than once, multiple input VCFs will be merged." }
  forced_gt: { type: ['null', { type: 'array', items: File, inputBinding: { prefix: '--forcedGT' }}], secondaryFiles: [{pattern: '.tbi', required: true}], inputBinding: { position: 1 }, doc: "Specify a VCF of candidate alleles. These alleles are always evaluated and reported even if they are unlikely to exist in the sample. The VCF must be tabix indexed. All indel alleles must be left-shifted/normalized, any unnormalized allele will trigger a runtime error. This option may be specified more than once, multiple input VCFs will be merged. Note that for any SNVs provided in the VCF, the SNV site will be reported (and for gVCF, excluded from block compression), but the specific SNV alleles are ignored." }
  exome: { type: 'boolean?', inputBinding: { position: 1, prefix: '--exome' }, doc: "Set options for exome or other targeted input: note in particular that this flag turns off high-depth filters." }
  call_regions: { type: 'File?', secondaryFiles: [{pattern: '.tbi', required: true}], inputBinding: { position: 1, prefix: '--callRegions' }, doc: "bgzip-compressed/tabix-indexed BED file containing the set of regions to call. No VCF output will be provided outside of these regions." }
  config: { type: 'File?', inputBinding: { position: 1, prefix: '--config' }, doc: "Config INI containing variables that cannot be set through the command line." }
  cpu: { type: 'int?', default: 20, inputBinding: { prefix: '-j', position: 11 }, doc: "Number of cores to allocate to this task." }
  ram: { type: 'int?', default: 20, doc: "GB of memory to allocate to this task." }

outputs:
  indels:
    type: 'File'
    outputBinding:
      glob: "results/variants/somatic.indels.vcf.gz"
    secondaryFiles: [{pattern: '.tbi', required: true}]
  snvs:
    type: 'File'
    outputBinding:
      glob: "results/variants/somatic.snvs.vcf.gz" 
    secondaryFiles: [{pattern: '.tbi', required: true}]
  realigned_normal_bam:
    type: 'File?'
    outputBinding:
      glob: "results/realigned/realigned.normal.bam"
    secondaryFiles: [{pattern: '.bai', required: true}]
    doc: "Strelka2 Realigned Normal BAM. Can be obtained by providing a config file with isWriteRealignedBam set to 1."
  realigned_tumor_bam:
    type: 'File?'
    outputBinding:
      glob: "results/realigned/realigned.normal.bam"
    secondaryFiles: [{pattern: '.bai', required: true}]
    doc: "Strelka2 Realigned Tumor BAM. Can be obtained by providing a config file with isWriteRealignedBam set to 1."
