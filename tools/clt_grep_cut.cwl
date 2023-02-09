cwlVersion: v1.2
class: CommandLineTool
id: clt_grep_cut
doc: |
  Grep and cut until the job is done.
requirements:
  - class: InlineJavascriptRequirement
  - class: ShellCommandRequirement
baseCommand: []
arguments:
  - position: 0
    shellQuote: false 
    valueFrom: >
      grep $(inputs.grep_regex) $(inputs.infile.path) | cut -f$(inputs.cut_field)
stdout: "out.txt"
inputs:
  infile: { type: 'File', doc: "File to grep" }
  grep_regex: { type: 'string', doc: "Grep this from the infile" }
  cut_field: { type: 'int', doc: "Field to cut from grepped lines." }
outputs:
  output:
    type: string
    outputBinding:
      glob: "out.txt"
      loadContents: true
      outputEval: |
        ${
          var field = self[0].contents.split('\n')[0];
          return field;
        }
