cwlVersion: v1.2
class: CommandLineTool
id: msisensor_pro_msi 
doc: |
  MSISENSOR PRO MSI
  This module evaluate MSI using the difference between normal and tumor length distribution of microsatellites. You need to input (-d) microsatellites file and two bam files (-t, -n).
requirements:
  - class: InlineJavascriptRequirement
  - class: ShellCommandRequirement
  - class: ResourceRequirement
    ramMin: $(inputs.ram*1000)
    coresMin: $(inputs.cpu)
  - class: DockerRequirement
    dockerPull: 'dmiller15/tgen_msisensor:1.1.a'
baseCommand: [msisensor-pro, msi]
inputs:
  # Required Arguments
  hp_ms_file: { type: 'File', inputBinding: { position: 2, prefix: "-d"}, doc: "homopolymers and microsatellites file" }
  normal_bam_file: { type: 'File', secondaryFiles: [{ pattern: '.bai', required: true }], inputBinding: { position: 2, prefix: "-n"}, doc: "normal bam file with index" }
  tumor_bam_file: { type: 'File', secondaryFiles: [{ pattern: '.bai', required: true }], inputBinding: { position: 2, prefix: "-t"}, doc: "tumor bam file with index" }
  output_filename: { type: 'string', inputBinding: { position: 2, prefix: "-o"}, doc: "output prefix" }

  # Optional Arguments
  bed_file: { type: 'File?', inputBinding: { position: 2, prefix: "-e"}, doc: "bed file, optional" }
  fdr: { type: 'float?', inputBinding: { position: 2, prefix: "-f"}, doc: "FDR threshold for somatic sites detection, default=0.05" }
  coverage: { type: 'int?', inputBinding: { position: 2, prefix: "-c"}, doc: "coverage threshold for msi analysis, WXS: 20; WGS: 15, default=15" }
  normalize: { type: 'boolean?', inputBinding: { position: 2, prefix: "-z"}, doc: "coverage normalization for paired tumor and normal data, 0: no; 1: yes, default=0" }
  region: { type: 'string?', inputBinding: { position: 2, prefix: "-r"}, doc: "choose one region, format: 1:10000000-20000000" }
  min_hp_size: { type: 'int?', inputBinding: { position: 2, prefix: "-p"}, doc: "minimal homopolymer size for distribution analysis, default=8" }
  max_hp_size: { type: 'int?', inputBinding: { position: 2, prefix: "-m"}, doc: "maximal homopolymer size for distribution analysis, default=50" }
  min_ms_size: { type: 'int?', inputBinding: { position: 2, prefix: "-s"}, doc: "minimal microsatellite size for distribution analysis, default=5" }
  max_ms_size: { type: 'int?', inputBinding: { position: 2, prefix: "-w"}, doc: "maximal microsatellite size for distribution analysis, default=40" }
  window: { type: 'int?', inputBinding: { position: 2, prefix: "-u"}, doc: "span size around window for extracting reads, default=500" }
  only_hp: { type: 'boolean?', inputBinding: { position: 2, prefix: "-x"}, doc: "output homopolymer only, 0: no; 1: yes, default=0" }
  only_ms: { type: 'boolean?', inputBinding: { position: 2, prefix: "-y"}, doc: "output microsatellites only, 0: no; 1: yes, default=0" }
  no_coverage: { type: 'boolean?', inputBinding: { position: 2, prefix: "-0"}, doc: "output site have no read coverage, 1: no; 0: yes, default=0" }

  cpu:
    type: 'int?'
    default: 4
    doc: "Number of CPUs to allocate to this task."
    inputBinding:
      position: 2
      prefix: "-b"
  ram:
    type: 'int?'
    default: 8
    doc: "GB size of RAM to allocate to this task."
outputs:
  output:
    type: 'File'
    outputBinding:
      glob: $(inputs.output_filename)
