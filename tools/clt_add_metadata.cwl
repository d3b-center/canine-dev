cwlVersion: v1.2
class: CommandLineTool 
id: clt_add_metadata
doc: |
  Add metadata to a file.
requirements:
  - class: InlineJavascriptRequirement
inputs:
  file: 
    type: File 
  tool_name:
    type: string
outputs:
  output:
    type: File
    outputBinding:
      outputEval: |
        ${
          var outfile = inputs.file;
          outfile.metadata["toolname"] = inputs.tool_name;
          return outfile;
        }
