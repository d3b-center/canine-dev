cwlVersion: v1.2
id: grep 
requirements:
  - class: DockerRequirement
    dockerPull: 'ubuntu:20.04'
  - class: InlineJavascriptRequirement
  - class: ResourceRequirement
    ramMin: $(inputs.ram * 1000)
    coresMin: $(inputs.cpu)
class: CommandLineTool
baseCommand: [sed]
stdout: $(inputs.outfile)
inputs:
  enable_tool: { type: 'string?', doc: "Killswitch for tool in workflow" }
  outfile: { type: 'string?', default: "out.txt", doc: "Output filename" } 
  infile: { type: 'File', inputBinding: { position: 9 }, doc: "File to sed" }
  silent: { type: 'boolean?', inputBinding: { position: 2, prefix: "--silent"}, doc: "suppress automatic printing of pattern space" }
  expression: { type: 'string?', inputBinding: { position: 2, prefix: "--expression"}, doc: "add the script to the commands to be executed" }
  expression_file: { type: 'File?', inputBinding: { position: 2, prefix: "--file"}, doc: "add the contents of script-file to the commands to be executed" }
  follow_symlinks: { type: 'boolean?', inputBinding: { position: 2, prefix: "--follow-symlinks"}, doc: "follow symlinks when processing in place" }
  line_length: { type: 'int?', inputBinding: { position: 2, prefix: "--line-length"}, doc: "specify the desired line-wrap length for the `l' command" }
  posix: { type: 'boolean?', inputBinding: { position: 2, prefix: "--posix"}, doc: "disable all GNU extensions." }
  regexp_extended: { type: 'boolean?', inputBinding: { position: 2, prefix: "--regexp-extended"}, doc: "use extended regular expressions in the script (for portability use POSIX -E)." }
  separate: { type: 'boolean?', inputBinding: { position: 2, prefix: "--separate"}, doc: "consider files as separate rather than as a single, continuous long stream." }
  unbuffered: { type: 'boolean?', inputBinding: { position: 2, prefix: "--unbuffered"}, doc: "load minimal amounts of data from the input files and flush the output buffers more often" }
  null_data: { type: 'boolean?', inputBinding: { position: 2, prefix: "--null-data"}, doc: "separate lines by NUL characters" }

  cpu:
    type: 'int?'
    default: 1
    doc: "Number of CPUs to allocate to this task."
  ram:
    type: 'int?'
    default: 2
    doc: "GB size of RAM to allocate to this task."
outputs:
  output:
    type: stdout
