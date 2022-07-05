cwlVersion: v1.2
class: CommandLineTool
id: delly_call 
doc: |
  Delly Call: discover and genotype structural variants
requirements:
  - class: InlineJavascriptRequirement
  - class: ShellCommandRequirement
  - class: ResourceRequirement
    ramMin: $(inputs.ram*1000)
    coresMin: $(inputs.cpu)
  - class: DockerRequirement
    dockerPull: 'dmiller15/delly:0.7.6'
baseCommand: [delly, call]
inputs:
  input_tumor_bam: { type: 'File', inputBinding: { position: 8 }, doc: "Tumor bam" }
  input_normal_bams: { type: 'File[]?', inputBinding: { position: 9 }, doc: "Normal bam(s)" }
  sv_type:
    type:
      - 'null'
      - type: enum
        name: sv_type
        symbols: ["DEL", "DUP", "INV", "TRA", "INS"]
    inputBinding:
      prefix: "--sv_type"
      position: 2
    doc: |
      SV type to call
  genome: { type: 'File', inputBinding: { position: 2, prefix: "--genome"}, doc: "genome fasta file" }
  exclude: { type: 'File', inputBinding: { position: 2, prefix: "--exclude"}, doc: "file with regions to exclude" }
  output_filename: { type: 'string', inputBinding: { position: 2, prefix: "--outfile"}, doc: "SV BCF output file" }

  # Discovery Arguments 
  map_qual: { type: 'int?', inputBinding: { position: 2, prefix: "--map-qual"}, doc: "min. paired-end mapping quality" }
  mad_cutoff: { type: 'float?', inputBinding: { position: 2, prefix: "--mad-cutoff"}, doc: "insert size cutoff, median+s*MAD (deletions only)" }
  noindels: { type: 'boolean?', inputBinding: { position: 2, prefix: "--noindels"}, doc: "no small InDel calling" }

  # Genotyping Arguments
  geno_vcf: { type: 'File?', inputBinding: { position: 2, prefix: "--vcffile"}, doc: "input VCF/BCF file for re-genotyping" }
  geno_qual: { type: 'int?', inputBinding: { position: 2, prefix: "--geno-qual"}, doc: "min. mapping quality for genotyping" }

  cpu:
    type: 'int?'
    default: 2
    doc: "Number of CPUs to allocate to this task."
  ram:
    type: 'int?'
    default: 4 
    doc: "GB size of RAM to allocate to this task."
outputs:
  bcf:
    type: 'File'
    outputBinding:
      glob: $(inputs.output_filename)
