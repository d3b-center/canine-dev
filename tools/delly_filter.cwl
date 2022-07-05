cwlVersion: v1.2
class: CommandLineTool
id: delly_filter
doc: |
  Delly Filter: filter somatic or germline structural variants
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
  # Required Arguments
  input_bcf: { type: 'File', inputBinding: { position: 8 }, doc: "Tumor bam" }
  output_filename: { type: 'File', inputBinding: { position: 2, prefix: "--outfile"}, doc: "Filtered SV BCF output file" }

  # Generic Arguments
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
  filter_mode:
    type:
      - 'null'
      - type: enum
        name: filter_mode
        symbols: ["germline", "somatic"]
    inputBinding:
      prefix: "--filter"
      position: 2
    doc: |
      Filter mode
  altaf: { type: 'float?', inputBinding: { position: 2, prefix: "--altaf"}, doc: "min. fractional ALT support" }
  minsize: { type: 'int?', inputBinding: { position: 2, prefix: "--minsize"}, doc: "min. SV size" }
  maxsize: { type: 'int?', inputBinding: { position: 2, prefix: "--maxsize"}, doc: "max. SV size" }
  ratiogeno: { type: 'float?', inputBinding: { position: 2, prefix: "--ratiogeno"}, doc: "min. fraction of genotyped samples" }
  pass: { type: 'boolean?', inputBinding: { position: 2, prefix: "--pass"}, doc: "Filter sites for PASS" }

  # Somatic Arguments
  samples: { type: 'File?', inputBinding: { position: 2, prefix: "--samples"}, doc: "Two-column sample file listing sample name and tumor or control" }
  coverage: { type: 'int?', inputBinding: { position: 2, prefix: "--coverage"}, doc: "min. coverage in tumor" }
  controlcontamination: { type: 'int?', inputBinding: { position: 2, prefix: "--controlcontamination"}, doc: "max. fractional ALT support in control" }

  # Germline Arguments
  gq: { type: 'int?', inputBinding: { position: 2, prefix: "--gq"}, doc: "min. median GQ for carriers and non-carriers" }
  rddel: { type: 'float?', inputBinding: { position: 2, prefix: "--rddel"}, doc: "max. read-depth ratio of carrier vs. non-carrier for a deletion" }
  rddup: { type: 'float?', inputBinding: { position: 2, prefix: "--rddup"}, doc: "min. read-depth ratio of carrier vs. non-carrier for a duplication" }

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
