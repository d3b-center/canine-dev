cwlVersion: v1.2
class: CommandLineTool
id: bcftools_filter_index
doc: |
  BCFTOOLS filter and optionally index
requirements:
  - class: InlineJavascriptRequirement
  - class: ShellCommandRequirement
  - class: ResourceRequirement
    ramMin: $(inputs.ram*1000)
    coresMin: $(inputs.cpu)
  - class: DockerRequirement
    dockerPull: 'staphb/bcftools:1.10.2'
baseCommand: []
arguments:
  - position: 0
    shellQuote: false
    valueFrom: >
      bcftools filter
  - position: 90
    shellQuote: false
    valueFrom: >
      $(inputs.output_type == "b" || inputs.output_type == "z" ? "&& bcftools index --threads " + inputs.cpu : "")
  - position: 99
    shellQuote: false
    valueFrom: >
      $(inputs.output_type == "b" || inputs.output_type == "z" ? inputs.output_filename : "")

inputs:
  # Required inputs
  input_vcf: { type: 'File', inputBinding: { position: 9 }, doc: "VCF to filter and optionally index." }
  output_filename: { type: 'string', inputBinding: { position: 2, prefix: "--output"}, doc: "output file name [stdout]" }

  # Filter options
  snpgap: { type: 'int?', inputBinding: { position: 2, prefix: "--SnpGap"}, doc: "filter SNPs within <int> base pairs of an indel" }
  indelgap: { type: 'int?', inputBinding: { position: 2, prefix: "--IndelGap"}, doc: "filter clusters of indels separated by <int> or fewer base pairs allowing only one to pass" }
  exclude: { type: 'string?', inputBinding: { position: 2, prefix: "--exclude"}, doc: "exclude sites for which the expression is true (see man page for details)" }
  include: { type: 'string?', inputBinding: { position: 2, prefix: "--include"}, doc: "include only sites for which the expression is true (see man page for details" }
  mode:
    type:
      - 'null'
      - type: enum
        name: mode
        symbols: ["+", "x", "+x"]
    inputBinding:
      prefix: "--mode"
      position: 2
    doc: |
      "+": do not replace but add to existing FILTER; "x": reset filters at sites which pass
  no_version: { type: 'boolean?', inputBinding: { position: 2, prefix: "--no-version"}, doc: "do not append version and command line to the header" }
  soft_filter: { type: 'string?', inputBinding: { position: 2, prefix: "--soft-filter"}, doc: "annotate FILTER column with <string> or unique filter name ('Filter%d') made up by the program ('+')" }
  set_gts:
    type:
      - 'null'
      - type: enum
        name: set_gts
        symbols: [".", "0"]
    inputBinding:
      prefix: "--set-GTs"
      position: 2
    doc: |
      set genotypes of failed samples to missing (.) or ref (0)
  regions: { type: 'string?', inputBinding: { position: 2, prefix: "--regions"}, doc: "restrict to comma-separated list of regions" }
  regions_file: { type: 'File?', inputBinding: { position: 2, prefix: "--regions-file"}, doc: "restrict to regions listed in a file" }
  targets: { type: 'string?', inputBinding: { position: 2, prefix: "--targets"}, doc: "similar to --regions but streams rather than index-jumps" }
  targets_file: { type: 'File?', inputBinding: { position: 2, prefix: "--targets-file"}, doc: "similar to --regions-file but streams rather than index-jumps" }
  output_type:
    type:
      - 'null'
      - type: enum
        name: output_type
        symbols: ["b", "u", "v", "z"]
    inputBinding:
      prefix: "--output-type"
      position: 2
    doc: |
      b: compressed BCF, u: uncompressed BCF, z: compressed VCF, v: uncompressed VCF [v]

  # Index Arguments
  force: { type: 'boolean?', inputBinding: { position: 92, prefix: "--force"}, doc: "overwrite index if it already exists" }
  min_shift: { type: 'int?', inputBinding: { position: 92, prefix: "--min-shift"}, doc: "set minimal interval size for CSI indices to 2^INT [14]" }
  csi: { type: 'boolean?', inputBinding: { position: 92, prefix: "--csi"}, doc: "generate CSI-format index for VCF/BCF files [default]" }
  tbi: { type: 'boolean?', inputBinding: { position: 92, prefix: "--tbi"}, doc: "generate TBI-format index for VCF files" }
  nrecords: { type: 'boolean?', inputBinding: { position: 92, prefix: "--nrecords"}, doc: "print number of records based on existing index file" }
  stats: { type: 'boolean?', inputBinding: { position: 92, prefix: "--stats"}, doc: "print per contig stats based on existing index file" }

  # Metadata options
  tool_name: { type: 'string?', default: "bcftools", doc: "Tool name to put in toolname metadata field" }

  cpu:
    type: 'int?'
    default: 1
    doc: "Number of CPUs to allocate to this task."
    inputBinding:
      position: 2
      prefix: "--threads"
  ram:
    type: 'int?'
    default: 4
    doc: "GB size of RAM to allocate to this task."
outputs:
  output:
    type: 'File'
    secondaryFiles: [{pattern: '.tbi', required: false}, {pattern: '.csi', required: false}]
    outputBinding:
      glob: $(inputs.output_filename)
      outputEval: |
        ${
          var outfile = self[0];
          if (!("metadata" in outfile)) { outfile.metadata = {} };
          outfile.metadata["toolname"] = inputs.tool_name;
          return outfile;
        }
